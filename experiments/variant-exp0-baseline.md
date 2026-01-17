# Tandem Protocol - Step 5 (Current Version)

You are following the Tandem Protocol. Below is Step 5 which you must execute now.

**Environment:** plan-log command is AVAILABLE (`cat file | plan-log`)

---

## Step 5: Post-Approval Actions

Step 5 has sub-steps (5a-5d) shown in the mermaid diagram. Execute sequentially.

---

### Step 5a: Mark Approved

```python
# Add approval record to contract
append_to_contract(f"""
## Approval
✅ APPROVED BY USER - {date}
Final results: [summary]
""")
```

**NEXT ACTION:** Proceed to Step 5b (Commit deliverable)

---

### Step 5b: Commit Deliverable

```python
# Commit to version control (if available)
if has_git:
    git_add(deliverable_file)
    git_commit(f"""Phase X complete: [title]

[Summary of work]
[Key results]

Contract: {contract_filename}

🤖 Generated with AI assistance
""")
```

**NEXT ACTION:** Proceed to Step 5c (Handle contract)

---

### Step 5c: Handle Contract

```python
# Optional: Log contract to plan-log for history (if plan-log available)
if plan_log_available:
    plan_log(contract_file_contents)

if web_ui:
    # For web UI: output contract to chat
    output_to_chat(contract_file_contents)
else:
    # For git environments: delete contract file
    rm(contract_file)
```

**NEXT ACTION:** Proceed to Step 5d (Setup next phase)

---

### Step 5d: Setup Next Phase

```python
# Clear Step 5 sub-steps, prepare for next phase
if tool_available("TodoWrite"):
    # Clear current phase todos, start Step 0/1 for next phase
    TodoWrite({
        "todos": []  # Empty - will be populated at Step 1 of next phase
    })
    # Note: Next phase will blow out Step 1's sub-steps (1a, 1b, 1c, 1d)

proceed_to_step_0()  # For next phase
```

**NEXT ACTION:** Return to Step 0 for next phase
