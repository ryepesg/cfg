# Portable Claude Code tooling rules

Machine-agnostic, tool-level rules. Keep them generic and portable.

## Code Comments

Keep comments sparse — the code should be self-explanatory. Comment only the non-obvious: the *why*, a gotcha, or a cross-file coupling. Don't restate what a line already says, and don't write multi-line explanations where one short line (or none) will do.

## Tooling Conventions

Prefer the Read/Edit tools over Bash `cat`/`sed` for file work. Don't run non-terminating or stdin-blocking commands in the foreground (they get auto-backgrounded into stuck tasks). For builds, activations, and other steps where success matters, run the verification as its own command and show the real exit code — never infer success from an `&&`-chained `echo`, since `|`/`&&` report the *last* command's status, not the one you care about.

When presenting a shell command for the user to copy, never split it across lines with a bare newline. Keep it on one physical line, or if splitting for readability, end each line with a `\` continuation.

**GNU coreutils are on PATH ahead of BSD** (installed unprefixed by `cfg`, for cross-platform GNU parity). `stat`, `date`, `readlink`, `du`, `ln` etc. are GNU, not BSD. Use GNU syntax (`stat -c '%s'`, `date -d`, `readlink -f`) — not BSD (`stat -f`, `date -r`). Don't reach for BSD flags just because the platform is darwin. If you genuinely need a BSD original, call it by absolute path: `/usr/bin/stat -f`, `/bin/ln`.

## Suspect surprising output

Empty, errored, or unexpected output is *unverified*, not evidence — the command may not have done what you think. Likely culprits: a shadowing shell function/alias intercepting the binary, a sandbox blocking the call, a wrong or unsupported flag, output on stderr you didn't capture, or a silent non-zero exit. Before concluding "X is absent / broken / done", run a cheap sanity check that isolates the cause — `type -a <cmd>` or `command <cmd>` to bypass a wrapper, a known-good input whose answer you can predict (A/B against it), or a re-run with the real exit code surfaced. Same discipline for MCP tool results: an empty or odd payload often means the call was rejected, mis-scoped, or paginated — not that the data isn't there.
