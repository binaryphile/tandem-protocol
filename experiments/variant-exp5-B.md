# Tandem Protocol - Step 5 (Experiment 5, Variant B: Condition Markers)

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

⚙️ CONDITION CHECK: Is the plan-log command available?

- **YES** → Execute: `cat phase-1-contract.md | plan-log`, then `rm phase-1-contract.md`
- **NO** → Skip plan-log, just `rm phase-1-contract.md`

**NEXT ACTION:** Proceed to Step 5d

---

### Step 5d: Setup Next Phase

Clear todos and return to Step 0 for next phase.
