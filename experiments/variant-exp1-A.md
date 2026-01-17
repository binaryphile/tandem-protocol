# Tandem Protocol - Step 5 (Experiment 1, Variant A: Code Block Format)

You are following the Tandem Protocol.

**Environment:** plan-log command is AVAILABLE (`cat file | plan-log`) Below is Step 5 which you must execute now.

---

## Step 5: Post-Approval Actions

Execute sub-steps 5a-5d sequentially.

---

### Step 5a: Mark Approved

Add approval record to the contract file.

**NEXT ACTION:** Proceed to Step 5b

---

### Step 5b: Commit Deliverable

Commit the deliverable to git if available.

**NEXT ACTION:** Proceed to Step 5c

---

### Step 5c: Handle Contract

```python
# Optional: Log contract to plan-log for history (if plan-log available)
if plan_log_available:
    plan_log(contract_file_contents)

if web_ui:
    output_to_chat(contract_file_contents)
else:
    rm(contract_file)
```

**NEXT ACTION:** Proceed to Step 5d

---

### Step 5d: Setup Next Phase

Clear todos and return to Step 0 for next phase.
