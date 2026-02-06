# UC9 Design: IAPI Stage Model

## Design

**Location:** tandem-protocol.md - Step 1 substeps, Step 4c

**Design principle:** I/A/P stages run in subagents with guide loading; Implement runs directly. All stages capture lessons at phase end.

### IAPI Stage Mapping

| Stage | Protocol Step | Guide | Execution |
|-------|---------------|-------|-----------|
| **I**nvestigate | Plan Mode Entry | investigation-guide.md | Subagent (Explore) |
| **A**nalyze | Step 1a-1b | analysis-guide.md | Subagent (Plan) |
| **P**lan | Step 1c-1e | planning-guide.md | Subagent (Plan) |
| **I**mplement | Step 2 | Domain guides | Direct (no subagent) |

### Subagent Output Format (I/A/P stages)

Subagent returns structured output enabling grading:

```markdown
## Investigation Results

### Patterns Found
- Error handling: centralized in pkg/errors/handler.go
- Logging: structured JSON via zerolog

### Dependencies Identified
- zerolog v1.29 for logging
- pkg/errors for error wrapping

### Lessons Applied
- "Check for existing patterns first": Found error handling pattern before proposing new one

### Lessons Missed
- "Verify test coverage early": Did not check coverage until implementation
```

### Stage-Specific Output

| Stage | Required Sections |
|-------|-------------------|
| Investigate | Patterns Found, Dependencies Identified |
| Analyze | Understanding Grade, Assumptions Made, Gaps Identified, Clarifying Questions |
| Plan | Approach Summary, Success Criteria, Alternatives Considered, Risks |
| Implement | Deliverable, Criteria Met, Verification Results |

### Lesson Structure

Non-actionable lessons are captured as tuples during grading:

```python
# Lesson tuple: (stage, text)
# stage: "I" (Investigate), "A" (Analyze), "P" (Plan), or domain name
lesson = ("I", "Check for existing error handling patterns before proposing new ones")
```

### Lesson Routing (Step 4c)

```python
# At Step 4c when routing lessons
for stage, text in non_actionable_lessons:
    # Determine target guide by stage tag
    guide = {
        "I": "investigation-guide.md",
        "A": "analysis-guide.md",
        "P": "planning-guide.md",
    }.get(stage, f"{stage}-guide.md")  # Domain guides

    # Skip if guide already covers this
    if lesson_already_covered(guide, text):
        continue

    # Append lesson to guide
    append_lesson(guide, text)
```

### Guide Location

Guides are stored per-project at `docs/guides/`:
- `docs/guides/investigation-guide.md`
- `docs/guides/analysis-guide.md`
- `docs/guides/planning-guide.md`

### Plan File Phase Template

Each phase in plan file must include task management with full JSON arguments:

```markdown
## Phase N: [Name]

### Step 1 (IAP)
- **Investigate:** [exploration targets - files, patterns, dependencies]
- **Analyze:** [what to grade - understanding level, assumptions]
- **Plan:** [approach to finalize - success criteria, alternatives]

```python
TaskCreate({"subject": "Phase N: [Name]", "description": "[scope]", "activeForm": "Working on [Name]"})
```

### Step 2 (Implement)
- [deliverable 1]
- [deliverable 2]

### Step 3-4 (Present/Cleanup)
```python
TaskUpdate({"taskId": "N", "status": "completed"})
# Telescope: delete substeps if any
```
```

**Rationale:** Task management instructions at Step 1d lack locality. Embedding them in each plan phase ensures compliance.

## Behavioral Test Cases

| Test ID | What Protocol Must Contain | Grep Pattern |
|---------|---------------------------|--------------|
| T1 | Stage guides referenced | `investigation-guide\|analysis-guide\|planning-guide` |
| T2 | Subagent with guide loading | `[Ss]ubagent.*[Ee]xplore\|[Ss]ubagent.*[Pp]lan` |
| T3 | Lessons Applied/Missed in output | `Lessons Applied\|Lessons Missed` |
| T4 | Lesson routing by stage | `non_actionable_lessons\|"I":.*investigation-guide\|"A":.*analysis-guide` |
