#!/bin/bash
# SessionStart hook to inject TaskAPI reminder
# Per https://code.claude.com/docs/en/hooks - SessionStart uses hookSpecificOutput.additionalContext

cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "MANDATORY: When user says 'proceed' at Gate 1, invoke TaskCreate tool for each task. This is required, not optional."
  }
}
EOF
