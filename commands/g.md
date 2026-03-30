wl-copy an adversarial, staff-level grading request for the current stage's work.  include
appropriate diffs or samples.

IMPORTANT: The clipboard content must start with a short identifier line so the user can
distinguish entries in their clipboard manager (which only shows the first ~60 chars).
Format: `[/g <TICKET-or-PROJECT> v<N>] <stage>` where N increments per /g invocation
in this conversation. Example: `[/g URMA-7655 v3] plan` or `[/g fluentfp v1] impl`.
Infer the ticket/project from context. Track the version number yourself — start at v1
and increment each time /g is invoked.

After the identifier line, explicitly request adversarial, staff-level grading. The opening
should say something like "Grade the following adversarially at staff level. Challenge
assumptions, find blind spots, and identify anything a senior engineer would flag in code
review." This framing is what makes the external review valuable — without it, external
LLMs default to polite, surface-level feedback.

When calling wl-copy, inline all content directly in the heredoc. Gather diffs, plan
excerpts, and other content in separate bash calls first. Then compose one final
wl-copy << 'EOF' with everything substituted. Do NOT use shell variables ($DIFF, etc.)
inside the heredoc — single-quoted delimiters prevent expansion.
