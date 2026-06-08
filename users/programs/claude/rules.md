# Portable Claude Code tooling rules

Machine-agnostic, tool-level rules. Keep them generic and portable.

## Code Comments

Keep comments sparse — the code should be self-explanatory. Comment only the non-obvious: the *why*, a gotcha, or a cross-file coupling. Don't restate what a line already says, and don't write multi-line explanations where one short line (or none) will do.

## Tooling Conventions

Prefer the Read/Edit tools over Bash `cat`/`sed` for file work. Don't run non-terminating or stdin-blocking commands in the foreground (they get auto-backgrounded into stuck tasks). For builds, activations, and other steps where success matters, run the verification as its own command and show the real exit code — never infer success from an `&&`-chained `echo`, since `|`/`&&` report the *last* command's status, not the one you care about.

When presenting a shell command for the user to copy, never split it across lines with a bare newline. Keep it on one physical line, or if splitting for readability, end each line with a `\` continuation.

**GNU coreutils are on PATH ahead of BSD** (installed unprefixed by `cfg`, for cross-platform GNU parity). `stat`, `date`, `readlink`, `du`, `ln` etc. are GNU, not BSD. Use GNU syntax (`stat -c '%s'`, `date -d`, `readlink -f`) — not BSD (`stat -f`, `date -r`). Don't reach for BSD flags just because the platform is darwin. If you genuinely need a BSD original, call it by absolute path: `/usr/bin/stat -f`, `/bin/ln`.
