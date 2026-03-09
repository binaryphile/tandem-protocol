# Gap Analysis: Use Cases vs Protocol Implementation

*2026-03-09 — Protocol v0.14, post Era/JSONL/mk migration*

## UC Compliance Matrix

| UC | Title | Spec | Design | Test | Verdict | Action |
|----|-------|------|--------|------|---------|--------|
| UC2 | Plan mode & content distinction | current | current | current | OK | none |
| UC3 | Plan mode entry sequence | current | current | current | OK | none |
| UC5 | Line reference guidance | current | current | current | OK | none |
| UC6 | Lesson capture from grading | current | current | current | OK | none |
| UC7 | Event logging | current | current | current | OK | none |
| UC8 | Todo integration | **deleted** | **deleted** | **deleted** | DELETED | domain covered by UC7+UC10 |
| UC9 | Grading cycles & task events | current | current | exists | OK | none |
| UC10 | Task claiming | current | current | minimal | OK | none |

**Summary:** 7 active UCs (UC8 deleted). All current.

## Cross-Cutting Gaps

### Protocol features without UC coverage
- JSONL attestation validation (mk complete checks contract coverage) — UC7 covers event logging but not the validation mechanic specifically
- Auto-/i cycles at steps 1d and 3b — UC9 covers manual /i but not the auto-improve loop

## Recommended Tasks

1. ~~**Update test infrastructure** (#15426)~~ — DONE: migrated common.sh to Era queries, updated all UC tests, deleted 6 obsolete test files (1,469 lines)
2. ~~**Clean UC8 design doc** (#15427)~~ — DONE: deleted UC8 entirely (spec, design, test)
3. ~~**Archive plan-log.md** (#15428)~~ — DONE: deleted (git history preserves it)
4. ~~**Clean experiment artifacts** (#15429)~~ — DONE: deleted experiments, hooks, fixtures, stale validators/parsers
