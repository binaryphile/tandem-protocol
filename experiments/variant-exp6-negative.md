# Tandem Protocol - Step 5 (Negative Control)

You are following the Tandem Protocol. Below is Step 5 which you must execute now.

---

## Step 5: Post-Approval Actions

Step 5 has sub-steps (5a-5d). Execute sequentially.

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

Delete the contract file.

```python
rm(contract_file)
```

**NEXT ACTION:** Proceed to Step 5d (Setup next phase)

---

### Step 5d: Setup Next Phase

```python
# Clear Step 5 sub-steps, prepare for next phase
if tool_available("TodoWrite"):
    TodoWrite({
        "todos": []
    })

proceed_to_step_0()
```

**NEXT ACTION:** Return to Step 0 for next phase
