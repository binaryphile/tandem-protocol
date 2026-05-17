#!/bin/bash
# Tandem Protocol doc-lint — README vocabulary alignment (UC14 / task #5013)
# Usage: bash tests/doc-lint.sh [README-path]
# Default README-path resolves relative to the script: ../README.md
#
# NOTE: substring 3 ('WHAT — use case') uses U+2014 (em-dash). Editor
# auto-normalization to ASCII '--' will trip this lint. The byte-exact
# requirement is intentional per UC14: typography drift is in scope.
set -uo pipefail

README="${1:-$(dirname "$0")/../README.md}"
PASS=0
FAIL=0

check() {
  local label=$1 substring=$2
  if grep -qF -- "$substring" "$README"; then
    echo "PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $label"
    echo "  literal substring not found in README.md: '$substring'"
    FAIL=$((FAIL + 1))
  fi
}
# NOTE: PASS=$((PASS + 1)) used instead of ((PASS++)) — the latter returns
# exit 1 when PASS=0 (bash arithmetic evaluates to the original value, which
# bash interprets as falsy → exit 1). Current set -uo pipefail tolerates it,
# but a future set -e addition would abort the script on the first PASS
# increment from zero. The assignment form is robust.

echo "=== README vocabulary alignment lint (UC14 / #5013) ==="
check "trigger vocabulary"           'user-visible behavior or operator workflow'
check "A1 anchor"                    'Commit 1 in Phase 3a'
check "A1 alignment target"          'WHAT — use case'
check "A2 carve-in"                  'TDD recommended for new behavioral surface'
check "A2 carve-out"                 'Internal refactors skip doc commits and proceed straight to code'
check "section anchor"               '## 3. Implement'
check "phase anchor"                 '**3a Execute:**'

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
exit $FAIL
