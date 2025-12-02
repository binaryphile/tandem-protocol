# Usage Patterns Diagrams - Evidence

**Date:** 2025-12-02
**Deliverable:** README.md Usage Patterns section (lines 124-216)

## Success Criteria
- [x] Three flowchart diagrams showing user interaction patterns
- [x] Pattern 1: Happy Path (approvals only)
- [x] Pattern 2: With Quality Check (grade at GATE 2)
- [x] Pattern 3: Enhanced QA (grade at both gates)
- [x] User-focused perspective (not internal protocol mechanics)
- [x] Obsidian-compatible Mermaid syntax
- [x] Color scheme matches tandem-protocol-concise.md
- [x] Improvement loops after each grade step
- [x] Multi-phase note included

## Actual Results

**Deliverable:** README.md lines 124-213 (90 lines)
**Completed:** 2025-12-02

### Deliverable Details

**Replaced section:** Lines 124-142 "Example workflow"
**New section:** Lines 124-216 "Usage Patterns"

**Three diagrams created:**
1. **Pattern 1: Happy Path** - Simple approve/approve flow
2. **Pattern 2: With Quality Check** - Grade at GATE 2 with improvement loop
3. **Pattern 3: Enhanced QA** - Grade at both gates with improvement loops

**Key features:**
- User-centric view highlighting choices at checkpoints
- GATE 1 (plan approval) and GATE 2 (work approval) clearly marked
- Color coding: Blue (user), Green (LLM), Orange (gates), Green (done)
- Dashed lines for feedback/improvement loops
- "User: Request improvements" step after each grade
- Improvement arrows loop back to gates (not present steps)

### Quality Verification

**Obsidian compatibility:**
- ✅ No URLs with `://` patterns
- ✅ No JavaScript syntax
- ✅ No emojis in node text
- ✅ Blank lines before mermaid blocks
- ✅ Simple node text (no complex characters)

**Color scheme verification:**
- ✅ Decision gates: `#fff3e0` fill, `#ff9800` stroke
- ✅ User actions: `#e3f2fd` fill, `#1976d2` stroke
- ✅ LLM actions: `#e8f5e9` fill, `#388e3c` stroke
- ✅ Success: `#c8e6c9` fill, `#4caf50` stroke
- Matches tandem-protocol-concise.md:51-59 exactly

**Flow accuracy:**
- ✅ Pattern 2: GATE 2 → Request grade → LLM provides grade → User requests improvements → back to GATE 2 → Approve
- ✅ Pattern 3: Both gates follow same pattern
- ✅ Multi-phase note correctly explains Step 5d loop back

### Iteration During Implementation

**User feedback received:**
1. "Add step after LLM provide grade for user to request improvements"
   - Fixed: Added "User: Request improvements" node after each grade
2. "Make improvement arrow point to gate instead of present step"
   - Fixed: Changed `IMP -.-> P1/P2` to `IMP -.-> G1/G2`
3. "Change 'Done' to 'Done, or next phase'"
   - Fixed: Updated all DONE nodes to "Done, or next phase"
4. "Can the boxes all be the same size?"
   - Fixed: Added quotes to all node labels for consistency
5. "Squash the LLM: complete work and present results steps into one"
   - Fixed: Changed to "LLM: Complete & present" (single step)
6. "User: request improvements box is still much larger"
   - Fixed: Changed to "User: Request changes" (shorter text)
7. "Make it clear the difference is thoroughness/complexity at user's decision"
   - Fixed: Added intro paragraph explaining users choose level based on task complexity
   - Updated pattern titles: "Simple Tasks", "Moderate Complexity", "Complex/Critical Work"
   - Added descriptions clarifying when to use each pattern
8. "Make it clear that the two steps for presentation are checkpoints, as well"
   - Started to add note, then user said "nevermind, i'll start calling them gates"
   - Fixed: Removed the checkpoint clarification line that was just added
9. "Is it possible to make the rendered user: request changes box to not encircle the done box?"
   - Fixed: Reordered Mermaid node definitions (approve path before grade path)
   - This guides layout engine to position feedback loops to the side

### Self-Assessment
Grade: A- (91/100)

What went well:
- Clean, user-focused diagrams that highlight control points
- Proper Obsidian compatibility (tested in scratch.md)
- Color scheme matches existing protocol exactly
- Quick iteration on user feedback during implementation
- All three patterns clearly differentiated with complexity guidance
- Consistent box sizing with quoted labels
- Clear user decision framework (choose level based on task needs)

Deductions:
- -4: Required multiple iterations to get improvement step correct
- -2: Box sizing required text adjustments (should have anticipated)
- -3: Added unnecessary checkpoint note when user preferred existing "gates" terminology

## Implementation Approach

1. ✅ Verified line numbers (124-142 confirmed as Example workflow)
2. ✅ Created scratch.md with test diagrams
3. ✅ Replaced section in README with Usage Patterns
4. ✅ Iterated based on user feedback (added improvement steps, fixed loop targets)

# ✅ APPROVED BY USER - 2025-12-02

User approved on 2025-12-02.

Final results: Successfully added three user-centric Mermaid flowcharts to README.md showing different QA thoroughness levels (Happy Path, Quality Check, Enhanced QA). All diagrams are Obsidian-compatible with consistent color scheme, and users can choose complexity level based on task needs.
