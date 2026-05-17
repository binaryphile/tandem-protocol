---
description: "Begin tandem planning for a task"
---

Begin the Tandem Protocol from step 1 (Plan).

1a: Investigate the codebase for the requested task
1b: Ask clarifying questions
1c: Design in plan mode
1d: Auto /i, validate, ExitPlanMode

The user's task description follows this command as arguments.

## Plan filename convention

Pick the convention-compliant plan filename when composing the 1c Design. Claude Code's plan-mode pre-assigns an initial random filename at some path under `~/.claude/plans/`; the system reminder names it explicitly ("A plan file already exists at /home/ted/.claude/plans/X.md"). If the reminder is absent or its format has changed, fall back to `ls -1t ~/.claude/plans/*.md | head -1` to find the most-recent plan file.

Compute the target. If the first whitespace-separated token of `$ARGUMENTS` matches the regex `^[1-9][0-9]*$`, the prefix is that integer — the originating task ID. Otherwise the prefix is `$(date -u +%Y%m%dT%H%M%S)-$RANDOM`. The target filename is `~/.claude/plans/<prefix>-<random>.md`, where `<random>` is the basename of the pre-assigned path with the `.md` extension stripped.

Hardcode both source and target paths into the impl-gate bash. Include the fail-loud rename block from README §1c as the first lines of impl-gate bash, before `evtctl contract`. Use the target path in every `<plan-name>` reference across both gate-bash blocks (`evtctl plan`, `validate-plan`, the byte-match diff).

A non-integer first token — including `0`, negative numbers, leading-plus, `task-5060`, and quoted-numeric forms — falls through to the timestamp form. The fallback is intentional, not error.

See README §1c and design.md §"Plan filename uniqueness — convention" for the full convention rationale, mechanism, residual risks, and the bootstrap exception that grandfathered the cycle (#5060) that introduced the convention.
