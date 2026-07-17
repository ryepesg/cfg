"""mdplain: flatten markdown into plain linear prose.

A short chain. A block pass collapses fenced code blocks into a
one-line note and linearizes GFM tables into label-and-value
sentences (the two shapes pandoc's plain writer keeps visual).
pandoc then strips the remaining structure. A fold pass reduces
typography and symbols to words, a guardrail blanks anything that
is not plain letters, numbers, or basic punctuation, and a squeeze
pass tidies the whitespace left behind.

The pandoc reader disables tex_math_dollars: two dollar amounts in
one paragraph can otherwise parse as an inline math span and get
mangled, depending only on what character sits next to the second
dollar sign.
"""

import re
import subprocess
import sys
import unicodedata

FENCE_OPEN = re.compile(r"^[ \t]*(`{3,}|~{3,})[ \t]*(.*)$")
DELIM_CELL = re.compile(r"^:?-+:?$")


def split_row(line):
    """Split a table row into cells, honoring escaped pipes."""
    line = line.strip().replace("\\|", "\x01")
    line = line.removeprefix("|").removesuffix("|")
    return [c.replace("\x01", "|").strip() for c in line.split("|")]


def looks_row(line):
    """At least one unescaped pipe: could be a table row."""
    return "|" in line.replace("\\|", "")


def is_delim(line):
    """Delimiter row: every cell is dashes with optional colons."""
    if not looks_row(line):
        return False
    return all(DELIM_CELL.match(c) for c in split_row(line))


def table_head(cells):
    plural = "column" if len(cells) == 1 else "columns"
    return "Table, %d %s: %s." % (len(cells), plural, ", ".join(cells))


def table_row(cells, header, rowno):
    """Label each cell with its header so order survives without the grid."""
    parts = []
    for i, cell in enumerate(cells):
        if cell == "":
            continue
        if i < len(header) and header[i] != "":
            label = header[i]
        else:
            label = "column %d" % (i + 1)
        parts.append("%s, %s" % (label, cell))
    if not parts:
        return "Row %d: blank." % rowno
    return "Row %d: %s." % (rowno, "; ".join(parts))


def fence_note(lang, count):
    plural = "" if count == 1 else "s"
    if lang:
        return "Code block, %s, %d line%s, skipped." % (lang, count, plural)
    return "Code block, %d line%s, skipped." % (count, plural)


def block_pass(lines):
    """Fences and tables, the block shapes pandoc keeps visual.

    Fences take precedence: a table inside a code sample is still code.
    A table is a candidate row followed by a delimiter row (GFM rule);
    the candidate is held one line to see whether a delimiter follows.
    """
    out = []
    held = None
    header = None
    rowno = 0
    fence_char = None
    fence_lang = ""
    fence_count = 0

    for line in lines:
        if fence_char is not None:
            if re.match(r"^[ \t]*%s{3,}[ \t]*$" % fence_char, line):
                out.append(fence_note(fence_lang, fence_count))
                fence_char = None
            else:
                fence_count += 1
            continue
        fence = FENCE_OPEN.match(line)
        if fence:
            if header is not None:
                out.append("End of table.")
                header = None
            if held is not None:
                out.append(held)
                held = None
            fence_char = fence.group(1)[0]
            info = fence.group(2).split()
            fence_lang = info[0] if info else ""
            fence_count = 0
            continue
        if header is not None:
            if looks_row(line):
                rowno += 1
                out.append(table_row(split_row(line), header, rowno))
                continue
            out.append("End of table.")
            header = None
        if held is not None:
            if is_delim(line):
                header = split_row(held)
                out.append(table_head(header))
                rowno = 0
                held = None
                continue
            out.append(held)
            held = None
        if looks_row(line) and not is_delim(line):
            held = line
            continue
        out.append(line)

    if held is not None:
        out.append(held)
    if header is not None:
        out.append("End of table.")
    if fence_char is not None:
        out.append(fence_note(fence_lang, fence_count))
    return out


# Applied in order, after pandoc. Guardrail-motivated rules fold symbols
# into words before the guardrail would remove them.
FOLDS = [
    (r"https?://[^\s)]+", "link"),
    (r"\$([0-9][0-9,.]*) ?[Kk]\b", r"\1 thousand dollars"),
    (r"\$([0-9][0-9,.]*) ?[Mm][Nn]?\b", r"\1 million dollars"),
    (r"\$([0-9][0-9,.]*) ?[Bb][Nn]?\b", r"\1 billion dollars"),
    (r"\$([0-9][0-9,.]*)\s*[-–—]\s*\$?([0-9][0-9,.]*)", r"\1 to \2 dollars"),
    (r"\$([0-9][0-9,.]*)", r"\1 dollars"),
    (r"/mo\b", " a month"),
    (r"/yr\b", " a year"),
    (r"^ *- +", ""),        # list markers the plain writer keeps
    (r"^ *[0-9]+\. +", ""),
    (r"^-{3,} *$", ""),     # horizontal rules render as a dash line
    (r"&", " and "),
    (r"%", " percent"),
    (r"@", " at "),
    (r" *—", ", "),    # normalize em dash to a comma
    (r"–", "-"),       # en dash
    (r"[‘’]", "'"),
    (r"[“”„]", '"'),
]
FOLDS = [(re.compile(pat, re.M), rep) for pat, rep in FOLDS]

# Optional spelling folds for downstream plain-text processing. Keep these out
# of the default path: expanded acronyms and versions are more explicit but
# more verbose. Rules here must be unambiguous and broadly reusable.
SPELL_FOLDS = [
    (re.compile(r"\bOAuth\b", re.I), "O auth"),
    (re.compile(r"\bSKILL\.md\b", re.I), "skill dot M D"),
    (re.compile(r"\bFTS\b"), "F T S"),
    (re.compile(r"\bMCP\b"), "M C P"),
    (re.compile(r"\bCVSS\b"), "C V S S"),
]

SMALL_NUMBERS = {
    0: "zero", 1: "one", 2: "two", 3: "three", 4: "four",
    5: "five", 6: "six", 7: "seven", 8: "eight", 9: "nine",
    10: "ten", 11: "eleven", 12: "twelve", 13: "thirteen",
    14: "fourteen", 15: "fifteen", 16: "sixteen", 17: "seventeen",
    18: "eighteen", 19: "nineteen",
}
TENS = {
    20: "twenty", 30: "thirty", 40: "forty", 50: "fifty",
    60: "sixty", 70: "seventy", 80: "eighty", 90: "ninety",
}


def expand_number(value):
    """Expand a non-negative integer compactly; version components are small."""
    number = int(value)
    if number in SMALL_NUMBERS:
        return SMALL_NUMBERS[number]
    if number < 100:
        tens, ones = divmod(number, 10)
        return TENS[tens * 10] + (" " + SMALL_NUMBERS[ones] if ones else "")
    # Keep large identifiers unambiguous by expanding them digit-by-digit.
    return " ".join(SMALL_NUMBERS[int(digit)] for digit in value)


def spell_fold(text):
    """Expand acronyms and identifiers in the opt-in explicit-text profile."""
    def version_replacement(match):
        prefix = "version " if match.group(1) else ""
        parts = (match.group(2), match.group(3), match.group(4))
        return prefix + " point ".join(expand_number(part) for part in parts)

    def cve_replacement(match):
        year = " ".join(SMALL_NUMBERS[int(digit)] for digit in match.group(1))
        identifier = " ".join(
            SMALL_NUMBERS[int(digit)] for digit in match.group(2)
        )
        return "C V E " + year + " " + identifier

    text = re.sub(r"\bCVE[- ](\d{4})[- ](\d+)\b", cve_replacement, text,
                  flags=re.I)
    text = re.sub(r"\b([vV])?(\d+)\.(\d+)\.(\d+)\b",
                  version_replacement, text)
    for pattern, replacement in SPELL_FOLDS:
        text = pattern.sub(replacement, text)
    return text


KEEP = set(
    "abcdefghijklmnopqrstuvwxyz"
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    "0123456789 \t\n.,;:?!'\"()-"
)


def fold(text, spell=False):
    for pattern, replacement in FOLDS:
        text = pattern.sub(replacement, text)
    if spell:
        text = spell_fold(text)
    # Accents to base letters (NFKD drops the combining marks); the
    # guardrail then blanks whatever survives outside the plain set.
    text = unicodedata.normalize("NFKD", text)
    text = "".join(c for c in text if not unicodedata.combining(c))
    return "".join(c if c in KEEP else " " for c in text)


def squeeze(text):
    lines = [re.sub(r"  +", " ", ln).strip() for ln in text.split("\n")]
    out = []
    for ln in lines:
        if ln == "" and out and out[-1] == "":
            continue
        out.append(ln)
    return "\n".join(out)


def main():
    args = sys.argv[1:]
    spell = False
    if "--spell" in args:
        args.remove("--spell")
        spell = True

    if args:
        text = ""
        for path in args:
            with open(path, encoding="utf-8") as f:
                text += f.read()
    else:
        text = sys.stdin.read()

    blocked = "\n".join(block_pass(text.splitlines())) + "\n"
    plain = subprocess.run(
        ["pandoc", "--from", "gfm-tex_math_dollars",
         "--to", "plain", "--wrap=none"],
        input=blocked, capture_output=True, text=True, check=True,
    ).stdout
    sys.stdout.write(squeeze(fold(plain, spell=spell)))


if __name__ == "__main__":
    main()
