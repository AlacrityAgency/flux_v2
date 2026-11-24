---
name: flux_v2
description: >-
  Three-stage Architect-Worker-Advisor workflow ("معمار – کارگر – ناظر") built on
  Antigravity native tools. Use when the user asks to run flux_v2 or assigns a
  heavy/complex engineering task to be architected by Gemini Neon (via the open
  built-in browser), implemented and locally verified by Antigravity / Gemini 3.8
  Flash (Worker), and rigorously audited for bugs, diffs, and verification proof
  by Gemini 4 Hydrogen (Advisor) inside Antigravity.
argument-hint: "<heavy engineering task or architecture goal>"
---

# Flux v2 — Architect, Worker, Advisor Workflow

Orchestrates complex engineering tasks across three specialized roles using the
open built-in browser and Antigravity's native models (**no external API keys
required**):

1. **Architect (`Gemini Neon` via built-in Browser):** Analyzes the problem,
   identifies edge cases, designs the architecture, and breaks work into concrete
   implementation steps.
2. **Worker (`Antigravity` / `gemini-3.8-flash-high`):** Reads Neon's blueprint,
   writes code and files in the local workspace, runs builds/tests/linters, and
   compiles an evidence-backed execution report.
3. **Advisor (`Gemini 4 Hydrogen` / `gemini-4-hydrogen-xhigh`):** Acts as senior
   QA reviewer above the Worker, inspects actual files, `git diff`, and test
   outputs, and enforces fixes until the implementation passes cleanly.

---

## Execution Protocol

Track the three phases with `update_steps`. Do not skip verification or fabricate
test outputs.

### Phase 1: Architect — Gemini Neon (Built-in Browser)

1. **Gather Grounded Workspace Context:**
   Inspect the active workspace (or target project path) before contacting Neon:
   project tree, stack/dependencies, relevant source files, and any existing
   failures or constraints.
2. **Format the Architect Prompt:**
   Fill the **Neon Architect Prompt** from
   [prompt-templates.md](./references/prompt-templates.md).
3. **Send to Neon via `browser` Subagent:**
   Invoke `invoke_subagent` with `TypeName: "browser"`, `Model: "flash"`,
   `Role: "Gemini Neon Architect"`:
   - First check open tabs (`page.context().pages()` URLs/titles) for an existing
     `gemini.google.com` tab and use it so the user's open Neon session is
     preserved. If no Gemini tab is present, navigate to
     `https://gemini.google.com/app`.
   - Verify the session is signed in and the active model/Gem selector shows
     **Neon**. If a login screen, CAPTCHA, or model selection requires user
     action, pause and ask the user to complete it in the visible browser pane,
     then resume the same subagent via `send_message`.
   - Submit the structured prompt, wait patiently until streaming finishes
     completely (stop button disappears and response text stabilizes), and
     return Neon's full response verbatim.
   - **Keep the `browser` subagent idle** after completion (never kill it) so
     architectural clarifications can continue in the same Neon chat via
     `send_message`.
   - Cross-check `BROWSER_HOST_FACTS` (`visited_origins`, `blocked_origins`)
     before accepting the returned blueprint.

*(If Neon raises critical product ambiguities, confirm them with the user before
starting Phase 2.)*

---

### Phase 2: Worker — Antigravity / Gemini 3.8 Flash (Local Execution)

Choose execution mode based on which model is running the current conversation:

- **If the current session is `Gemini 3.8 Flash` (Worker-led mode):**
  Execute Neon's blueprint directly in the workspace as the Worker.
- **If the current session is `Gemini 4 Hydrogen` (or another model):**
  Delegate coding and local execution to a native Antigravity swarm Worker pinned
  to **`gemini-3.8-flash-high`** (fall back to `gemini-3.8-flash-medium` via
  `swarm(action="model", ...)` only on quota/capacity limits):
  1. Check `swarm_pane` conventions if starting a swarm (`swarm(action="title", ...)`
     and `plan.json` when using multi-member swarm UI).
  2. Call `swarm(action="add", name="worker", model="gemini-3.8-flash-high", workspace="inherit", brief=...)`
     using the **Worker Execution Brief** in
     [prompt-templates.md](./references/prompt-templates.md), pasting Neon's full
     blueprint and exact verification criteria.

**Worker Requirements (both modes):**
1. Implement every requirement cleanly, preserving existing code conventions and
   comments unless changes require updates.
2. If a technical blocker contradicts Neon's assumption, consult Neon via
   `send_message` to the idle `browser` subagent before improvising core changes.
3. Run all relevant compilers, linters, type-checks, and tests **after the final
   edit**. Observe actual exit codes and outputs.
4. Collect an **Execution Report** containing:
   - Summary of changes vs. Neon's blueprint.
   - Exact list of created/modified files and `git diff` (or concise file diffs).
   - Verbatim test/verification commands, exit codes, and observed results.

---

### Phase 3: Advisor — Gemini 4 Hydrogen (QA & Code Review)

Audit the Worker's implementation rigorously before accepting it:

- **If the current session acted directly as Worker (e.g., `3.8 Flash` mode):**
  Spawn an independent native Advisor via `swarm`:
  ```text
  swarm(
    action="add",
    name="advisor",
    model="gemini-4-hydrogen-xhigh",
    workspace="inherit",
    brief=<Hydrogen Advisor Audit Brief from references/prompt-templates.md>
  )
  ```
  *(If `gemini-4-hydrogen-xhigh` hits capacity/quota, switch the existing
  `advisor` with `swarm(action="model", name="advisor", model="gemini-4-hydrogen-high")`
  rather than killing and recreating it. If `swarm` is unavailable, fall back to
  `invoke_subagent(TypeName="self", Model="pro", Role="Hydrogen Senior Advisor")`.)*
- **If the current session is already `Gemini 4 Hydrogen` supervising `worker`:**
  Perform the audit using the **Hydrogen Advisor Checklist** in
  [prompt-templates.md](./references/prompt-templates.md) by reading the actual
  changed files, running/inspecting `git diff`, and verifying test logs (or
  spawn a clean-slate `advisor` pinned to `gemini-4-hydrogen-xhigh` if an
  unbiased fresh-context audit is needed).

#### Review & Fix Loop (Max 3 Rounds)
1. **Advisor Verdict (`APPROVED` vs. `CHANGES_REQUIRED`):**
   - **`CHANGES_REQUIRED`:** Fix every listed blocking issue (either directly or
     by messaging `@worker` on the swarm board), re-run all verification checks,
     and re-submit updated diffs and logs to the Advisor.
   - **`APPROVED`:** Proceed to cleanup and final reporting.
2. **Escalation Guard:** If critical issues persist after 3 review rounds, stop
   and report the unresolved findings to the user.
3. **Cleanup:** Call `swarm(action="kill", name=...)` on finished `worker` /
   `advisor` swarm members only after final approval. Leave the `browser`
   subagent idle unless the session is completely finished.
4. **Final Reply:** Summarize Neon's architecture, implemented changes with
   clickable `file://` links, observed test outputs, and Hydrogen's final sign-off.
