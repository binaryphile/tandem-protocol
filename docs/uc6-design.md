# UC6 Design: Lesson Capture from Grading

## Design

**Location:** README.md - `/c` grading sections at both gates (actionability note)

**Design principle:** The actionability test is a simple decision rule. Claude can reason through the routing (which guide, etc.) without explicit protocol guidance. Encoding the decision point is sufficient.

### Lesson Entry Format

| Type | When | Mechanism |
|------|------|-----------|
| Lesson | Non-actionable gap during grading | `evtctl interaction "/c -> lesson: [title] -> [guide]"` |

**Example:**
`evtctl interaction "/c -> lesson: Integration test ≠ post-hoc verification -> protocol-guide.md"`

### File Routing Guide

Route lessons to the PI stage where they apply:

| Lesson Type | PI Stage | Target Guide |
|-------------|----------|--------------|
| "Should have explored X" | Plan | planning-guide.md |
| "Misunderstood Y" | Plan | planning-guide.md |
| "Better approach Z" | Plan | planning-guide.md |
| Code quality patterns | Implement | (domain-specific guide) |
| Protocol compliance | (meta) | protocol-guide.md |

### Integration Points

| Event | Lesson Action |
|-------|---------------|
| `/c` grading at either gate | Identify non-actionable gaps, route to guide |
| Completion Gate | Review session for gaps between ask and delivery |

### Actionability Note in Protocol

Both `/c` sections include:
```
# Before deducting: "Can I fix this now?" YES → deduction, NO → capture in guide
```

## Behavioral Test Cases

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | Actionability test at grading | `[Cc]an I fix this now` |
| T2 | Non-actionable → guide routing | `capture.*guide\|guide.*not.*deduct` |
