---
name: wrap-up
description: End-of-session wrap-up before closing a context window. Captures only what would cost future-you time if lost — pending actions still owed, and insights worth consolidating into a Logseq graph. Does not replay what was done. Invoke when the user asks to wrap up, close out, "anything to capture", or end the session.
---

# Session wrap-up

The point of this skill is peace of mind before closing a context window: when a fresh session opens, nothing that would otherwise be rediscovered or redone should be lost. It is **not** a session log. Do not replay or summarize what was done this session — that is noise the user does not want.

Apply one filter to everything below:

> Would losing this cost future-me time — because work is unfinished, or because something learned would have to be rediscovered?

If it doesn't pass that test, leave it out. Default to capturing little; when there's nothing worth capturing, say so plainly instead of manufacturing entries. Do real work — actually write the files, don't describe what you would do.

## Prerequisites

- **Logseq** graph root: the dir containing `pages/` and `journals/`. The session's environment context lists these as additional working directories with their literal absolute paths — take the root from there (it differs per machine). `$LOGSEQ_GRAPH` is a fallback if they're not listed. If you can't locate the graph either way, report that and skip the Logseq writes rather than guessing a path.
- **Never pass the graph path (or any space- or variable-bearing path) to Bash.** Embedding `$LOGSEQ_GRAPH`, `$(…)`, or a quoted path with spaces in a shell command forces an expansion the permission system can't pre-match, so every call re-prompts for approval. Use the native file tools instead — **Glob** to find a page, **Grep** to search content, **Read/Write/Edit** to append — they take literal absolute paths, handle spaces, and bypass the shell entirely.
- **Memory** (step 3) assumes a file-based memory at `~/.claude/memory/` with a `MEMORY.md` index. If the project doesn't use one, skip it and say so.

## 1. Pending actions

Find the concrete loose ends this session leaves behind: unfinished work, steps deferred ("later", "next time", "on the other machine"), uncommitted/unpushed changes, cleanup owed, things blocked on something external. For each, ask whether future-you actually needs it — drop the trivially obvious.

Persist the real ones into the Logseq graph as native task bullets, so they survive the close and stay queryable:
- `- LATER <action>` for things to pick up eventually, `- TODO <action>` for nearer-term. Match how the target page already uses these markers.
- Put each under the most relevant topic page (routing in step 2); use today's `journals/YYYY_MM_DD.md` only when nothing fits.
- Don't duplicate a task already written in the graph.

Call out separately anything that blocks closing right now (e.g. unpushed work that would be lost).

## 2. Insights worth consolidating

Capture durable things learned this session that future-you would otherwise have to rediscover: a decision and why, a non-obvious how/why, a gotcha, a resolved unknown. Not activity ("did X, then Y"), and not anything already recorded in the repo, git history, or project docs.

Write these into the Logseq graph:
- Topic pages live at `pages/<title>.md`; Logseq encodes namespace separators in filenames (`/`→`___`, `|`→`%7C`, spaces kept — page `tool/AeroSpace` → `pages/tool___AeroSpace.md`). Inside file content use real slashes in `[[links]]`.
- Routing: identify the insight's topic, then find a matching slug case-insensitively with the **Glob** tool (pattern `*erospace*`) rooted at the `pages/` working directory — not a Bash `find`, which would re-prompt. Append to the most specific page that fits, under a dated bullet, via **Edit**. Fall back to today's `journals/` file only if no page fits. Editing the graph while Logseq is open is fine.
- Match the surrounding note style — bullets, indentation, the user's voice. No filler, no bold-label headers, sparse emoji, no AI tells.

Tell the user exactly which file(s) you wrote to.

## 3. Memory (for Claude, secondary)

Briefly check whether anything this session changes what Claude should carry across future sessions — a durable preference, a project constraint, a corrected assumption. If so, update the closest existing memory in `~/.claude/memory/` rather than duplicating, keep the `MEMORY.md` pointer current, and delete any memory this session proved wrong. This is usually a no-op; don't force it.

## 4. Persist the config repo

The memory written in step 3, plus any CLAUDE.md / settings / rules touched this session, live in a config repo (here `~/.claude`). Persist them so the captures survive the close.

- Scope: **only** this config repo (e.g. `~/.claude`). Never commit or push the nix config repos or any project repo — those are the user's to commit by hand.
- Commit gates on it being a work tree alone: if `git -C ~/.claude rev-parse --is-inside-work-tree` is true, `git -C ~/.claude add -A` and commit a one-liner (e.g. `wrap-up: capture YYYY-MM-DD`). The allowlist `.gitignore` already limits what's tracked. Not a work tree → skip silently.
- Push gates separately on a remote existing: if `git -C ~/.claude remote` is non-empty, push; otherwise stop after the commit.
- The Logseq graph syncs separately; this step does not touch it.

Assume this works — don't narrate the commit or push.

## 5. Verdict

A few lines, no more: what you captured and where, then a plain ready-to-close / not-yet verdict, calling out anything that should be handled first.
