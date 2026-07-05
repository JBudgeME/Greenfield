---
name: prompt-refiner
description: Refine a draft prompt into a structured markdown prompt ready to hand to a coding agent. Use this skill whenever the user wants to refine, restructure, improve, polish, or rewrite a prompt — especially prompts intended for an autonomous coding agent like Claude Code. Trigger on requests such as "refine my prompt", "help me write an agent prompt", "make this prompt better", "turn this into a structured prompt", or any explicit invocation of prompt-refiner. Also trigger when the user greets you and clearly expects a prompt-refinement workflow.
---

# Prompt Refiner

Turn a user's draft prompt into a structured, agent-ready markdown prompt that encodes engineering discipline implicitly — through how the task is described, not by reciting rules at the agent.

## Workflow

1. If the user has not yet provided a draft prompt, ask for it. Tell them you will return a structured prompt as a markdown code block they can paste directly to an agent.
2. Rewrite their draft so that:
   - It captures the **spirit** of the principles in the "Principles to encode" section below.
   - It **enforces** those principles through its instructions — without listing, quoting, or paraphrasing them as a separate rules section.
   - It uses the "Output template" below as its exact skeleton.
3. Return the rewritten prompt as a single fenced markdown code block (` ```markdown ... ``` `). No preamble, no commentary, no postamble.

## Principles to encode (do not surface these in the output)

These are the values the refined prompt must enforce _through how it instructs the agent_. They never appear verbatim in the output.

**Engineering**

- KISS, DRY, YAGNI — simplest solution that fully solves the request; no speculative abstractions or unrequested features.
- Separation of concerns + SRP — UI, logic, data, and config stay separate; each module/function/class has one clear responsibility.
- Composition over inheritance — small, focused, composable pieces.
- Explicit over implicit — validate inputs and data; never assume silently.
- Minimal justified abstractions — abstract only when it clearly reduces duplication or complexity.
- Readable and maintainable — match existing codebase style and conventions; flag harmful ones.

**Safety and error handling**

- Fail fast and loud — surface errors early with actionable messages; never swallow errors or silently skip work.
- State uncertainty explicitly whenever anything is incomplete or unclear.

**Development workflow**

- Think before coding — state assumptions, push back if a simpler approach exists, stop if confused.
- Read before write — explore relevant existing code (exports, callers, utilities, patterns) before modifying.
- Research before asking — present well-reasoned options with recommendations before asking the user.
- Surgical changes — modify only what's needed; never refactor unrelated code.
- Goal-driven — define success criteria and verify the result.
- Tests verify intent — write tests that fail when business logic changes.
- Checkpoint often — summarize what is done, verified, and remaining.
- Surface conflicts — when principles contradict, choose the stronger one, explain why, note the trade-off.
- For framework-specific work, read the installed framework's docs before writing framework-specific code.

## Output template

The refined prompt must follow this template exactly:

```markdown
**Task:** [One-sentence goal]

**Context:** [Why this matters; spec file, related commits, files to read first]

**Workflow:**

1. [Step 1 — usually "read X and Y, confirm current behavior"]
2. [Step 2 — surgical change to specific files]
3. [Step 3 — verify against the success criteria below]

**Success criteria:**

- [Verifiable criterion + how to check, e.g., "tests in `tests/auth/` pass (`npm test auth`)"]
- [Another criterion paired with the command or check that proves it]
- [Include tests for any changed business logic]

**Hard constraints:**

- Do not modify [out-of-scope areas]
- [Other non-negotiables]

**If anything is ambiguous:** research the codebase first, then present 2-3 reasoned options with a recommendation. Do not guess.

Start now by [first required action, usually "reading the spec" or "reading the relevant existing code"].
```

## How to encode principles without listing them

Bake the principles into the _task instructions themselves_. The refined prompt should feel disciplined without containing a code of conduct.

**Examples:**

- Instead of "follow DRY," write _"reuse existing helpers in `lib/` where applicable; do not duplicate logic."_
- Instead of "be surgical," write _"modify only the files required to satisfy the task; leave unrelated code untouched."_
- Instead of "fail fast," write _"validate inputs at function entry and throw clear errors on invalid state."_
- Instead of "read before write," write the first workflow step as _"read `<relevant files>` and summarize current behavior before editing."_
- Instead of "explicit over implicit," write _"name every input and expected output explicitly; do not infer intent from filenames."_

The agent receiving the refined prompt should feel the discipline through how the task is framed — never by reading a rules manifesto.

## Final output rules

- Return only the refined prompt, inside a single fenced markdown code block tagged ` ```markdown `.
- No text before or after the code block. No meta-commentary about what you changed.
- Keep the template structure intact: the headers `**Task:**`, `**Context:**`, `**Workflow:**`, `**Success criteria:**`, `**Hard constraints:**`, the `**If anything is ambiguous:**` line, and a final `Start now by …` line must all be present.
- Each `Success criteria` bullet must pair the _condition_ with how to _check_ it (a command, a file/test path, or an observable outcome) — never a vague "it works."
