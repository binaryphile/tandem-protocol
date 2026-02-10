# Tandem Protocol

Structured checkpoints for Claude Code. You approve each step, Claude grades its own work.

**Try it:**
```bash
cd ~ && git clone https://codeberg.org/binaryphile/tandem-protocol.git
mkdir -p ~/.claude/commands && ln -sf ~/tandem-protocol/tandem.md ~/.claude/commands/tandem.md
echo -e "\n# Tandem Protocol\n@~/tandem-protocol/README.md" >> your-project/CLAUDE.md
```

## Example Session

```
You:    /tandem add a config file loader to the CLI
Claude: Questions before planning:
        - YAML, JSON, or TOML?
        - Missing config: error or defaults?
You:    YAML, defaults

Claude: [creates plan] May I proceed?
You:    proceed

Claude: [logs to plan-log.md]
        2024-01-15T10:00:00Z | Contract: Config loader | [ ] YAML parsing, [ ] default fallback

        [implements]

        Done. May I proceed?
You:    proceed
```

Use `/tandem` anytime to refocus when things drift.

## Usage

### When to use `/tandem`

- At session start: `/tandem make a plan to...`
- When Claude skips steps or scope changes
- Anytime things feel off track

## Learn More

See [FEATURES.md](FEATURES.md) for details on:
- **Self-grading cycles** - Grade and improve work before committing
- **Lesson capture** - Route learnings to guides for future sessions
- **Event logging** - Audit trail with Contract/Completion/Interaction entries
- **PI cognitive stages** - Structured thinking for complex tasks
- **Multi-phase projects** - Maintain coherence across sessions

---

# The Protocol

## Overview

```mermaid
flowchart LR
    S1[1: Plan] --> S2{2: Gate}
    S2 --> S3[3: Implement]
    S3 --> S4{4: Gate}
    S4 -.-> S1

    style S1 fill:#e3f2fd,stroke:#1976d2
    style S3 fill:#e3f2fd,stroke:#1976d2
    style S2 fill:#fff3e0,stroke:#f57c00
    style S4 fill:#fff3e0,stroke:#f57c00
```

## 1: Plan

```bash
# 1a: explore
read_codebase
identify_affected_files
note_line_references  # will shift after edits

# 1b: ask
for uncertainty in $requirements; do
    ask_user "$uncertainty"
    wait_response
done

# 1c: design
cat > ~/.claude/plans/phase-n.md << 'PLAN'
## Objective
## Success Criteria
## Changes
## At Step 2   # bash: log contract + create tasks
## At Step 4   # bash: log completion + commit
PLAN

# 1d: present
[[ -z $(grep "At Step 2" ~/.claude/plans/*.md) ]] && exit 1
[[ -z $(grep "At Step 4" ~/.claude/plans/*.md) ]] && exit 1
ask "May I proceed?"
wait  # STOP until user approves
```

## 2: Gate (approve plan)

```bash
case "$response" in
    proceed|yes|approved)
        # 2a: log contract
        # 2b: create tasks
        ;;
    revise)
        # back to 1a
        ;;
esac
```

### 2a: Log Contract

```bash
touch plan-log.md
cat >> plan-log.md << 'EOF'
2026-02-08T12:00:00Z | Contract: Phase N - objective | [ ] criterion1, [ ] criterion2
EOF
```

### 2b: Create Tasks

```bash
S=$(ls -t ~/.claude/tasks/ | head -1)
M=$(ls ~/.claude/tasks/$S/*.json 2>/dev/null | xargs -I{} basename {} .json | sort -n | tail -1 || echo 0)
T1=$((M+1))

cat > ~/.claude/tasks/$S/$T1.json << TASK
{"id": "$T1", "subject": "Task 1", "status": "in_progress", "blocks": [], "blockedBy": []}
TASK
```

## 3: Implement

```bash
# 3a: execute
for task in $tasks; do
    set_status "$task" "in_progress"
    execute "$task"
    set_status "$task" "completed"
done

# 3b: present
show_results
show_verification_commands
ask "May I proceed?"
wait  # STOP until user approves
```

## 4: Gate (approve results)

```bash
case "$response" in
    proceed|yes|approved)
        # 4a: log completion
        # 4b: cleanup tasks
        # 4c: commit
        ;;
    grade)
        log_interaction "grade" "$(self_assess)"
        # back to 3b
        ;;
    improve)
        log_interaction "improve" "$changes"
        # back to 3a
        ;;
esac
```

### 4a: Log Completion

```bash
cat >> plan-log.md << 'EOF'
2026-02-08T12:30:00Z | Completion: Phase N | [x] criterion1 (evidence), [x] criterion2 (evidence)
EOF
```

### 4b: Cleanup Tasks

```bash
S=$(ls -t ~/.claude/tasks/ | head -1)
for f in ~/.claude/tasks/$S/*.json; do
    [ -f "$f" ] && rm "$f"
done
```

### 4c: Commit

```bash
git add -A && git commit -m "Phase N complete

Co-Authored-By: Claude <noreply@anthropic.com>"
```

## Log Entries

| Entry | When | Format |
|-------|------|--------|
| Contract | step 2 | `TS \| Contract: Phase N - obj \| [ ] c1, [ ] c2` |
| Completion | step 4 | `TS \| Completion: Phase N \| [x] c1 (evidence)` |
| Interaction | grade/improve | `TS \| Interaction: action -> outcome` |

## Plan File Template

```markdown
# [Phase Name] Plan

## Objective
[1-2 sentences]

## Success Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]

## Changes
[files + line refs]

## At Step 2
    ```bash
    # 2a + 2b combined
    ```

## At Step 4
    ```bash
    # 4a + 4b + 4c combined
    ```
```

## Principles

```bash
# approval required at gates
[[ "$response" =~ ^(proceed|yes|approved)$ ]] || exit 1

# user controls scope
user_may_defer=true
claude_may_defer=false      # must ask first
claude_may_suggest=true

# feedback loops
case "$response" in
    grade)        self_assess; re_present ;;
    improve)      fix_issues; re_present ;;
    scope_change) explore ;;  # back to step 1
esac
```
