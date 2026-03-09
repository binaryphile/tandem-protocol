# Gap Analysis: Use Cases vs Protocol Implementation

*2026-03-09 — Protocol v0.14, post Era/TOML/mk migration*

## UC Compliance Matrix

| UC | Title | Spec | Design | Test | Verdict | Action |
|----|-------|------|--------|------|---------|--------|
| UC2 | Plan mode & content distinction | current | current | **stale** (plan-log.md) | PARTIAL | update test |
| UC3 | Plan mode entry sequence | current | current | **stale** (Gate 1 naming, stale compliance ceiling) | PARTIAL | update test |
| UC5 | Line reference guidance | current | current | minimal | OK | none |
| UC6 | Lesson capture from grading | current | current | exists | OK | none |
| UC7 | Event logging | current | current | **stale** (plan-log.md) | PARTIAL | update test |
| UC8 | Todo integration | **deleted** | **deleted** | **deleted** | DELETED | domain covered by UC7+UC10 |
| UC9 | Grading cycles & task events | current | current | exists | OK | none |
| UC10 | Task claiming | current | current | minimal | OK | none |

**Summary:** 7 active UCs (UC8 deleted — domain covered by UC7+UC10). 4 current, 3 with stale tests.

## Cross-Cutting Gaps

### Stale test infrastructure
`tests/integration/common.sh` — built for plan-log.md, never migrated to Era:
- `get_contracts()`, `get_completions()`, `get_interactions()` parse plan-log.md with awk
- `completion_gate()` injects plan-log.md references
- `touch plan-log.md` in test setup
- Used by: uc2, uc3, uc7 tests

### Historical file in repo root
`plan-log.md` (49KB) — deprecated since Mar 2, but still in repo. Could mislead new contributors into thinking it's the logging mechanism.

### Protocol features without UC coverage
- TOML attestation validation (mk complete checks contract coverage) — UC7 covers event logging but not the validation mechanic specifically
- Auto-/i cycles at steps 1d and 3b — UC9 covers manual /i but not the auto-improve loop

### Stale experiment artifacts
- `tests/experiments/run-all-experiments.sh` — TaskCreate compliance experiments (Phase 7)
- `tests/hooks/inject-taskapi-context.sh` — SessionStart hook for TaskAPI injection
- `tests/fixtures/valid-*.txt` — contain plan-log.md format examples

## Recommended Tasks

1. **Update test infrastructure** (#15426) — migrate `common.sh` helpers from plan-log.md to Era queries; update uc2, uc3, and uc7 tests
2. ~~**Clean UC8 design doc** (#15427)~~ — DONE: deleted UC8 entirely (spec, design, test)
3. **Archive plan-log.md** (#15428) — move to `docs/archive/` or add header noting it's historical
4. **Clean experiment artifacts** (#15429) — delete or move `tests/experiments/`, `tests/hooks/inject-taskapi-context.sh`, stale fixtures
