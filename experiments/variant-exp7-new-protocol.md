# Tandem Protocol - Step 5 (Updated - No plan-log dependency)

You are following the Tandem Protocol. Below is Step 5c which you must execute now.

---

### Step 5c: Handle Contract

```python
# Archive contract to plan history, then delete
if web_ui:
    output_to_chat(contract_file_contents)
else:
    # Append separator + timestamp + contract to history file
    echo("\n---\n")              >> "plan-history.md"
    echo(f"## Archived: {date}") >> "plan-history.md"
    cat(contract_file)           >> "plan-history.md"
    rm(contract_file)
```

**Bash equivalent:**
```bash
echo -e "\n---\n## Archived: $(date -I)\n" >> plan-history.md
cat phase-N-contract.md >> plan-history.md
rm phase-N-contract.md
```

**NEXT ACTION:** Proceed to Step 5d (Setup next phase)
