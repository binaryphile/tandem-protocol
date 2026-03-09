wl-copy an adversarial, staff-level grading request for the current stage's work.  include
appropriate diffs or samples.

IMPORTANT: The clipboard content itself — what the external LLM will read — must explicitly
request adversarial, staff-level grading. The opening of the request should say something like
"Grade the following adversarially at staff level. Challenge assumptions, find blind spots, and
identify anything a senior engineer would flag in code review." This framing is what makes the
external review valuable — without it, external LLMs default to polite, surface-level feedback.

When calling wl-copy, inline all content directly in the heredoc. Gather diffs, plan
excerpts, and other content in separate bash calls first. Then compose one final
wl-copy << 'EOF' with everything substituted. Do NOT use shell variables ($DIFF, etc.)
inside the heredoc — single-quoted delimiters prevent expansion.
