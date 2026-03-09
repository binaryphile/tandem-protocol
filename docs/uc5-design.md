# UC5 Design: Line Reference Guidance

## Design

**Location:** README.md - Step 1a (note_line_refs comment), Step 3a (implicit in implementation)

**Design principle:** Protocol covers main success path only. Exceptional cases omitted.

**Problem:** Observed failures where line numbers become stale after edits but aren't updated.

### Mechanism

Step 1a already includes `note_line_refs # will shift after edits` — this is the reminder that line numbers noted during investigation will drift during implementation. The system should re-read affected sections before presenting results at step 3b.

### Integration Points

| Protocol Step | Action |
|---------------|--------|
| Step 1a (Investigate) | Note line refs (with caveat they'll shift) |
| Step 3a (Execute) | After edits, verify line refs still accurate |
| Step 3b (Present) | Present with corrected references |

## Behavioral Test Cases

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | Line reference verification guidance | `verify.*line\|line.*shift\|numbers.*shift\|will shift` |
