---
name: wrap-up
description: End-of-session wrap-up before closing. Scans the conversation for durable facts to save to memory, surfaces remaining TODOs, and appends a dated session summary to the right place in a Logseq graph (topic page when one fits, else today's journal). Invoke when the user asks to wrap up, close out, "anything to capture", or end the session.
---

# Session wrap-up

End-of-session routine: persist what's durable, surface what's unfinished, and log a summary to a Logseq knowledge graph. Run the steps in order, then give a short report and an explicit "ready to close" verdict. Do real work — don't just describe what you would do.

## Prerequisites

- **Memory** (step 1) assumes a file-based memory at `~/.claude/memory/` with a `MEMORY.md` index. If the project doesn't use one, skip step 1 and say so.
- **Logseq** (step 3) needs the graph location in the `LOGSEQ_GRAPH` environment variable (absolute path to the graph's root — the dir containing `pages/` and `journals/`). If it's unset and you can't locate a graph, skip step 3 and report that instead of guessing a path.

## 1. Capture durable facts to memory

Review the whole conversation for facts worth persisting to `~/.claude/memory/`. For each:
- Check existing memories first (read `MEMORY.md`); **update** the closest match rather than duplicating, or delete one that this session proved wrong.
- Only save what's durable and non-obvious — not things derivable from the repo, git history, or project docs, and not conversation-only detail.
- Link related memories with `[[name]]`, and add/maintain the one-line pointer in `MEMORY.md`.

If nothing qualifies, say so explicitly rather than inventing entries.

## 2. Surface remaining TODOs

List concrete loose ends from this session: uncommitted/unpushed changes, steps deferred to another machine, cleanup left behind, anything the user said "later" about. Mark which (if any) block closing. Pull in still-relevant open items from memory if this session touched them.

## 3. Append a session summary to the Logseq graph

Graph root: `$LOGSEQ_GRAPH` (see Prerequisites).
- Topic pages: `pages/<title>.md`. Logseq encodes namespace separators in filenames: `/`→`%2F`, `|`→`%7C`, spaces kept (page `tool/AeroSpace` → `pages/tool%2FAeroSpace.md`). Inside file content use real slashes in `[[links]]`.
- Dated notes: `journals/YYYY_MM_DD.md` (today's date).

**Routing (topic page when one fits, else journal):**
1. Identify the session's primary topic. Search `pages/` for a matching slug case-insensitively (e.g. `find "$LOGSEQ_GRAPH/pages" -iname '*erospace*'`). Editing the graph while Logseq is open is fine — no need to warn about re-indexing.
2. If a clearly relevant page exists, append the summary there under a dated heading/bullet. If two or more topics fit, prefer the most specific page; if none fits, fall back to today's `journals/` file (create it if absent).
3. Write a tight summary: what was decided/done, key file paths or commands, and any `[[wikilinks]]` to related pages. Match the surrounding note style (bullets, indentation) and the user's writing style — no filler, no bold-label headers, sparse emoji.
4. Tell the user exactly which file you wrote to.

## 4. Verdict

State plainly whether the user is ready to close, and call out anything that should be handled first.
