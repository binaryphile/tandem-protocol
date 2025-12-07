# Guide Revision Contract: testing-claude-code-behavior.md

## Success Criteria (Measurable)
- [x] 3 runnable test scripts in NEW appendix (full code, no filesystem refs)
- [x] Comprehensive standalone section (~150 lines, no external deps)
- [x] Bidirectional cross-reference with Transcript Analysis
- [x] Full methodology: hypothesis, null hypothesis, n=10 data tables
- [x] BLOCKING vs CRITICAL: 66% → 100% with methodology
- [x] Model verisimilitude warning in Print Mode section
- [x] Turn exhaustion detection with interpretation guide
- [x] Version updated to v2.4, date to 2025-12-07
- [ ] Commit to urma-next-obsidian repo

## Implementation Results

### Changes Completed

| Change | Location | Lines Added |
|--------|----------|-------------|
| Model Verisimilitude Warning | After line 181 | ~8 |
| Turn Exhaustion Detection | After line 107 | ~20 |
| Behavioral Compliance Testing (NEW) | After line 647 | ~145 |
| Case Study: Protocol Validation (NEW) | After line 1560 | ~90 |
| Best Practices #11-13 | After line 1897 | 3 |
| Transcript Analysis cross-ref | Line 1926 | 1 |
| Appendix: Test Scripts (3 scripts) | Before Conclusion | ~195 |
| Version footer update | Lines 2348-2375 | ~28 |
| Back-reference to Transcript Analysis | Line 772 | 1 |

**Total new content: ~490 lines**

### Contract Requirements Met

1. **Formal Methodology (H₀/H₁):**
   - Behavioral Compliance Testing section (lines 712-743): Hypothesis, null hypothesis, methodology, results table, raw n=10 data
   - Scope Change Recognition (lines 772-793): H₀, results, raw n=10 data table

2. **Raw Trial Data Tables:**
   - Clarifying questions V2: 10 trials with pattern matched (lines 729-742)
   - Scope change recognition: 10 trials with pattern matched (lines 778-791)
   - Case Study T1+T4: 10 trials with pattern matched (lines 1618-1629)

3. **Case Study:**
   - Dedicated section "Case Study: Protocol Behavioral Validation" (lines 1561-1649)
   - Theory-driven methodology, results table, raw data, lessons learned, methodology comparison

4. **3 Runnable Scripts:**
   - test-clarifying-questions.sh (lines 2016-2071)
   - test-feedback-plan-change.sh (lines 2077-2123)
   - test-context-utilization.sh (lines 2129-2181)
   - All self-contained, no external file references

### Verified File State
- Version: 2.4
- Date: 2025-12-07
- All scripts are self-contained (no external file references)
- All cross-references use anchor links
- Formal hypothesis testing format used
- Raw n=10 data tables included

# ⏸️ AWAITING STEP 4 APPROVAL (Review + Commit)
