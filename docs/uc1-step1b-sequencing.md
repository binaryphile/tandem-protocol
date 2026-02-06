# Use Case: UC1 Step 1b Sequencing Rule

**Scope:** Tandem Protocol
**Level:** Blue
**Primary Actor:** LLM (executing protocol)
**Secondary Actors:** User (provides answers), Tool system (AskUserQuestion if available)

## In/Out List

| In Scope | Out of Scope |
|----------|--------------|
| Questions asked via conversation/tool | Question content or format |
| Explicit "no questions" statement | How to formulate good questions |
| Main success path only | Exceptional cases (Claude reasons through these) |

## Context of Use
During Step 1 of Tandem Protocol, after presenting understanding (1a) and before requesting approval (1c), the LLM must gather clarifying information. This use case ensures questions are ASKED to the user rather than embedded as assumptions in the plan.

## Stakeholders & Interests
- User: Gets to answer questions that affect scope; no surprises from undisclosed assumptions
- LLM: Proceeds with clarity; avoids rework from wrong assumptions
- Protocol: Maintains its guarantee of user-controlled scope

## Preconditions
- Step 1a complete (understanding presented)
- Step 1c not yet started (approval not yet requested)

## Success Guarantee
- All clarifying questions asked via conversation or tool
- Answers received and incorporated into plan
- Plan reflects answers, not open questions
- Explicit "no questions" statement if none exist

## Minimal Guarantee
- No questions embedded as assumptions in plan file
- User aware if questions were skipped

## Trigger
LLM identifies need for clarification during Step 1b, OR reaches end of 1a with potential ambiguities.

## Main Success Scenario
1. LLM identifies clarifying questions during understanding phase
2. LLM asks questions to user (via conversation or AskUserQuestion tool)
3. User provides answers
4. LLM incorporates answers into plan
5. LLM proceeds to Step 1c with resolved questions

## Extensions
1a. LLM has no clarifying questions:
    1a1. LLM states explicitly: "No clarifying questions - understanding is complete"
    1a2. Continue to Step 1c

2a. AskUserQuestion tool available:
    2a1. LLM uses tool with structured questions
    2a2. Continue at step 3

2b. AskUserQuestion tool not available:
    2b1. LLM presents questions in conversation
    2b2. Continue at step 3

3a. User defers answering:
    3a1. LLM notes deferral in plan as explicit uncertainty
    3a2. Continue at step 4 with noted limitation

3b. User's answer reveals new questions:
    3b1. Return to step 2 with new questions

4a. Answer changes scope significantly:
    4a1. LLM updates understanding (return to Step 1a)
    4a2. Present revised understanding
    4a3. Return to step 1 (max 2 iterations; if scope still unclear, escalate to user)

## Sub-Variations
- Step 2: Questions may be technical, scope-related, or preference-based
- Step 3: Answers may be partial, conditional, or "your judgment"

## Technology Variations
- Step 2: Could use AskUserQuestion tool, conversation, or future structured input

## Guard Conditions (Behavioral Tests)

| Condition | Expected Behavior |
|-----------|-------------------|
| Questions exist but written into plan | FAIL: Questions must be asked, not embedded |
| Questions asked via conversation | PASS: Conversation shows Q&A exchange |
| Questions asked via AskUserQuestion | PASS: Tool invocation visible |
| No questions, no explicit statement | FAIL: Must state "no questions" explicitly |
| No questions, explicit statement | PASS: Statement serves as verification |
| Plan contains "TBD" or "to be determined" | FAIL: Unresolved questions embedded |
| Plan contains "assuming X" without asking | FAIL: Assumption not validated |

## Verification
Conversation transcript shows one of:
- Q&A exchange before plan finalization
- AskUserQuestion tool invocations with responses
- Explicit "no clarifying questions" statement

## Project Info
- Priority: P1 (High) - Most common compliance failure
- Frequency: Every Step 1 execution
- Behavioral Goal Impact: Strengthens existing goal #3, +0 new goals
