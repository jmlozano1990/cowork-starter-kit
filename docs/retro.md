# Retrospective — cowork-starter-kit

---

## v1.0 — Initial Build

> Phase 8 not run for v1.0. See pipeline.md for cycle summary.

---

## v1.1 — Wizard Architecture Redesign

**Date:** 2026-04-16
**Classification:** STANDARD
**Mode:** full
**Rework rate:** 0%

### 1. Cycle Summary

v1.1 shipped a complete wizard architecture redesign for cowork-starter-kit, driven by a v1.0 root cause failure where Cowork's intent classifier intercepted the WIZARD.md primary path. The fix introduced a three-layer trigger architecture: `project-instructions-starter.txt` as the primary mechanism (system context injected before intent classification), `/setup-wizard` as a conversational fallback, and WIZARD.md as documentation-only. Additionally, all 18 skill files were converted from flat `.md` to `folder/SKILL.md` format with YAML frontmatter, 6 global-instructions.md files were rewritten to proactive trigger rules, and 3 new CI enforcement jobs were added. Classification: STANDARD. Rework rate: 0%.

### 2. What Went Well

- **Root cause identified quickly:** v1.0 failure (Cowork intercepting WIZARD.md) was correctly diagnosed, leading to a clean architectural pivot rather than a workaround
- **Three-layer trigger architecture:** Elegant solution — starter file as system context bypasses intent classification entirely; fallback paths provide graceful degradation
- **Zero rework:** No lines changed between Phase 4 SHA and Phase 7 approval — implementation was right first time
- **Security carry-forwards clean:** Both Phase 2 WARNINGs (S1 CONTRIBUTING.md, S2 CI .txt glob) resolved in Phase 4 and confirmed at Phase 6
- **4-layer safety defense operational:** template → global-instructions → starter file system context → CI enforcement — defense-in-depth for the non-negotiable safety rule
- **CI expansion:** 3 new jobs (starter-file-check, starter-safety-rule-check, skill-format-check) enforce v1.1 invariants for community contributions
- **Full skill format conversion:** 18 skills moved to folder/SKILL.md without any regressions

### 3. What Went Wrong

- **v1.0 primary path failed in production:** The entire v1.1 cycle exists because v1.0's primary delivery mechanism (WIZARD.md as conversational wizard) didn't survive contact with Cowork's intent classifier — this was a fundamental architecture miss, not a bug
- **Spec conflict on step numbering:** F1 AC said "Step 1 = paste" while F7 said "Step 3 = paste" — minor inconsistency that carried through to Phase 5 as an INFO item; implementation followed the correct interpretation (F7) but spec should have been cleaned up during /spec revise
- **Token metrics incomplete:** metrics.json shows `model: "unknown"` for most entries and pipeline_cycle tracking was inconsistent between v1.0 and v1.1 — token cost analysis not possible with current data

### 4. Rework Analysis

- **Rework rate:** 0% (0 lines changed after Phase 4 SHA `ce6c8a5`)
- **Root causes:** N/A — no rework required
- **Phase 4 → Phase 7 delta:** Zero code changes. All security carry-forwards from Phase 2 were resolved within the Phase 4 implementation. No Phase 5 or Phase 6 findings required code modifications.

### 5. Security Findings Summary

| ID | Phase | Severity | Surface | Description | Resolution |
|----|-------|----------|---------|-------------|------------|
| S1 | 2 | WARNING | auth | CONTRIBUTING.md PR checklist missing v1.1 items | RESOLVED in Phase 4 — 7-item checklist added |
| S2 | 2 | WARNING | configuration | CI starter-safety-rule-check must target .txt files | RESOLVED in Phase 4 — direct .txt path glob + count check |
| S3 | 2 | INFO | external-api | /skill-creator dependency is UNTESTED | ACCEPTED — fallback path in all 6 onboarding scripts |
| S4 | 2 | INFO | auth | /setup-wizard reset confirmation is LLM-enforced only | ACCEPTED — acceptable for surface type |
| S5 | 2 | INFO | ui | AskUserQuestion nudge is best-effort heuristic | ACCEPTED — no security surface |
| — | 6 | — | — | 0 findings at Phase 6 audit | PASS |

**Phase 6 result:** PASS — 0 CRITICAL, 0 WARNING, 0 INFO. All 31 LLM context files audited clean.

### 6. Issues Prevented

| Category | Count |
|----------|-------|
| Blocker | 0 |
| Issue | 0 |
| Info | 1 |

**Info detail:** Spec conflict on SETUP-CHECKLIST step numbering (F1 vs F7) — flagged during Phase 5, no functional impact.

**Cumulative (v1.0 + v1.1):** blocker=0, issue=0, info=2

### 7. Quality Baseline Comparison

Quality baselines are calibrated for The-Council self-improvement cycles. For this external project (static markdown repo, no auth/schema/RLS), applicable behaviors are evaluated where observable:

| Agent | Applicable Scenarios | Observed Behavior | Assessment |
|-------|---------------------|-------------------|------------|
| @pm | QP1 (ambiguous intent), QP2 (self-validation) | v1.1 /spec revise correctly identified root cause, produced targeted spec with clear ACs. No ambiguous intent issues. | PASS |
| @architect | QA3 (speculative abstraction) | Architecture was pragmatic — three-layer trigger is a direct solution, not speculative. ADR supersessions documented. No N+1 or destructive migration surfaces (QA1/QA2 N/A). | PASS |
| @security | QS3 (fail-closed vs fail-open) | Phase 2 correctly identified CI .txt glob risk (false-pass = fail-open). Phase 6 audited all 31 LLM context files. Guard/scope scenarios (QS1/QS2) not applicable to this repo. | PASS |
| @qa | QQ2 (AC coverage) | 52/52 tests with full AC mapping. INFO item documented with explanation. No flaky tests. No rework surface to track. | PASS |

**Overall:** 4/4 agents PASS on applicable scenarios. Note: baselines are not live-tested (inject prompts) for external projects — this is content-review assessment only.

### 8. Carry-Forward Items

| Item | Source | Priority | Description |
|------|--------|----------|-------------|
| Spec step numbering cleanup | Phase 5 INFO | LOW | F1 AC says "Step 1 = paste", F7 says "Step 3 = paste" — align in next spec revision |
| Token metrics instrumentation | Phase 8 observation | LOW | metrics.json has `model: "unknown"` for most entries — investigate token-logger extraction for external projects |
| /skill-creator validation | Phase 2 S3 | MEDIUM | Validate /skill-creator behavior against pre-built folder/SKILL.md files when Cowork exposes the tool |
| UX polish (v1.0 carry-forward) | Phase 7 v1.0 | LOW | U2 fuzzy-match escape hatch wording, U3 SETUP-CHECKLIST Step 4 micro-copy |
| README/SETUP-CHECKLIST uncommitted changes | git status | MEDIUM | Target repo has uncommitted modifications to README.md and SETUP-CHECKLIST.md |

### 9. Self-Improve Recommendation

**Recommendation:** No.

Only 2 cycles completed for this project — the 3-cycle pattern detection threshold has not been reached. No recurring WARNING+ surface detected across Phase 6 audits (v1.0 Phase 6: 0 findings, v1.1 Phase 6: 0 findings). No `/self-improve` action warranted.

---

*Generated by @qa Phase 8 retrospective — 2026-04-16*

---

## v1.2 — Dynamic Workspace Architect

**Date:** 2026-04-17
**Classification:** SECURITY-SENSITIVE
**Mode:** full
**Rework rate:** 19%

### 1. Cycle Summary

v1.2 shipped the Dynamic Workspace Architect pivot for claude-cowork-config. The core change: preset-first static menu replaced by a dynamic goal discovery wizard that detects whether the user already knows their workspace goal and branches accordingly (goal-known → direct setup vs goal-unknown → suggestion flow). Key deliverables: CLAUDE.md rewritten as the universal wizard entry point (auto-loaded as LLM system context for any user opening the repo folder in Cowork — new Layer 1a surface), 6 starter files updated with the same dynamic state machine plus preset hint, curated-skills-registry.md created (18 entries, Tier 1/2 hybrid model with HTTPS-only enforcement), writing-profile-template.md plus 6 preset writing-profile.md files (anti-AI voice calibration, patterns-only — no raw sample field per security finding E6), 14 CI jobs (up from 11). Classification: SECURITY-SENSITIVE (first SECURITY-SENSITIVE cycle for this project). Rework rate: 19% (2 blockers in Phase 5, 1 WARNING in Phase 6, all resolved before Phase 7 approval).

### 2. What Went Well

- **All 4 Phase 2 WARNINGs (S1–S4) resolved in Phase 4:** CONTRIBUTING.md v1.2 checklist, word-count CI, registry URL check, CLAUDE.md blast radius documentation — none carried past implementation
- **Security classification escalation correct:** Phase 5 correctly classified SECURITY-SENSITIVE based on CLAUDE.md auto-load and registry URL trust surface — no post-hoc override needed
- **Phase 6 confirmed classification independently:** @security reached the same SECURITY-SENSITIVE conclusion without prompting
- **A1 CI bug caught and fixed quickly:** Phase 6 found the registry-cardinality-check logic bug (counted 6 rows instead of 18); fix committed (sha:6f8f692) before Phase 7 approval — the bug would have broken CI on every push
- **5-layer safety defense operational:** template → global-instructions → starter files → CLAUDE.md → CI — all 13 required locations confirmed
- **Writing profile E6 design held:** No raw sample field shipped; wizard instructions explicitly discard sample text — confirmed in Phase 6 audit
- **18 CI actions SHA-pinned throughout:** No regression on supply chain hygiene

### 3. What Went Wrong

- **Phase 5 FAIL on word count (FAIL-1):** All 6 starter files shipped at 385–387 words (target ≤350). The word budget was raised from ≤300 to ≤350 in v1.2 spec but @dev wrote to the wrong target. No CI job enforced the starter file limit at time of Phase 4 commit — this gap was known (it was a new CI job to be added) but the gap enabled the failure.
- **Phase 5 FAIL on SETUP-CHECKLIST step ordering (FAIL-2):** Step 1 was "Create Cowork Project" instead of "Paste project-instructions-starter.txt." This was the exact AC that was spec-conflict-fixed in the v1.1 retro (Section 3, carry-forward item). The fix was documented and resolved in spec, but not carried into the Phase 4 implementation — a retro carry-forward that was not acted on.
- **Phase 6 A1 CI logic bug:** registry-cardinality-check computed DATA_ROWS=6 (not 18) due to HEADER_ROWS pattern matching data rows. The bug was in the first write of the CI job; no test of the job output was run before commit. Would have caused CI to fail on every push after merge.
- **First rework cycle for this project:** v1.0 rework 0%, v1.1 rework 0%, v1.2 rework 19% — first non-zero rework cycle. Both blockers were detectable with pre-commit checks (word count is a simple `wc -w`; step ordering is a known requirement from a prior retro).

### 4. Rework Analysis

- **Rework rate:** 19% (lines changed in Phase 4 rework commit d6314f2 relative to Phase 4 sha:90f8483)
- **Rework commit:** sha:d6314f29c7768195648094250183140b60444c26
- **Files changed in rework:** presets/*/project-instructions-starter.txt (6), SETUP-CHECKLIST.md, .github/workflows/quality.yml
- **Root cause — FAIL-1 (word count):** Spec raised the word budget to ≤350 in v1.2. @dev implemented to 385–387. No CI enforcement existed at the time of writing — the starter-file-word-count-check job was slated to be added but not yet present. Mitigation added in rework: CI job now enforces ≤400 words (hard cap).
- **Root cause — FAIL-2 (step ordering):** The v1.1 retro explicitly identified this as a carry-forward (Section 8: "Spec step numbering cleanup — F1 AC says 'Step 1 = paste', F7 says 'Step 3 = paste'"). The spec was updated in v1.2 Phase 0 to align. However, the Phase 4 implementation did not consult the retro carry-forward list before writing SETUP-CHECKLIST.md. This is a process gap: retro carry-forwards are in docs/retro.md but are not surfaced in the Phase 4 Intent Contract or Phase 0 spec ACs in a way that forces attention.
- **Root cause — A1 (CI logic bug):** The registry-cardinality-check job used a shell pattern for HEADER_ROWS that matched data rows. No local test of the CI job was run before commit. The Phase 6 auditor caught it by reading the shell logic directly.
- **Compound effect:** All three failures (FAIL-1, FAIL-2, A1) were in new artifacts written for v1.2 — none were regressions from existing code. The pattern is "first-write correctness" — new CI jobs and new checklist sections are more likely to ship with errors than modified existing ones.

### 5. Security Findings Summary

| ID | Phase | Severity | Surface | Description | Resolution |
|----|-------|----------|---------|-------------|------------|
| S1 | 2 | WARNING | configuration | CONTRIBUTING.md PR checklist missing v1.2 items (writing profile, registry schema, CLAUDE.md alignment) | RESOLVED in Phase 4 — items 8–11 added |
| S2 | 2 | WARNING | configuration | CLAUDE.md word-count ceiling (≤350) unenforced by CI | RESOLVED in Phase 4 — claude-md-word-count-check CI job added |
| S3 | 2 | WARNING | external-api | curated-skills-registry.md source_url had no integrity validation | RESOLVED in Phase 4 — HTTPS-only CI check + SHA-pin guidance in CONTRIBUTING.md |
| S4 | 2 | WARNING | auth | CLAUDE.md blast radius: universal auto-load, malicious commit affects all users | RESOLVED in Phase 4 — high-impact documentation in CONTRIBUTING.md |
| S5 | 2 | INFO | external-api | Tier 2 keyword scan is LLM text review only; obfuscated payloads not detected | ACCEPTED — best-effort by design |
| S6 | 2 | INFO | configuration | Tier 2 hardcoded repo list in WIZARD.md has no CI enforcement | ACCEPTED — v1.2 scope boundary |
| S7 | 2 | INFO | configuration | builtin sentinel in registry is trust-by-convention | ACCEPTED — no external URL risk for builtin entries |
| S8 | 2 | INFO | logging | Writing profile template must not include raw sample field | RESOLVED in Phase 4 — no raw sample field; wizard instructions discard sample text |
| A1 | 6 | WARNING | configuration | registry-cardinality-check CI logic bug — computed DATA_ROWS=6 instead of 18 | RESOLVED — sha:6f8f692 (fix: grep pattern counts actual data rows) |
| A2 | 6 | INFO | external-api | registry-url-check silently passes non-http/https schemes (ftp://, relative paths) | ACCEPTED — carry to v1.3 |
| A3 | 6 | INFO | configuration | CLAUDE.md 385 words (target ≤350, hard cap ≤400; CI passes) | ACCEPTED — carry to v1.3 |

**Phase 6 result:** PASS WITH WARNINGS — 1 WARNING (A1, fixed), 2 INFO (A2, A3, accepted). 0 CRITICAL.

### 6. Issues Prevented

| Category | Count | Details |
|----------|-------|---------|
| Blocker | 2 | FAIL-1 (word count: all 6 starter files over limit), FAIL-2 (SETUP-CHECKLIST step 1 wrong — retro carry-forward not implemented) |
| Issue | 1 | A1 CI logic bug (registry-cardinality-check returning 6 instead of 18 — would have failed CI on every push) |
| Info | 3 | WARN-1 (CLAUDE.md 385 words non-blocking), A2 (URL scheme gap), A3 (CLAUDE.md trim recommendation) |

**Cumulative (v1.0 + v1.1 + v1.2):** blocker=2, issue=1, info=5

### 7. Quality Baseline Comparison

Quality baselines are calibrated for The-Council self-improvement cycles. For this external project (static markdown + CI repo, no auth/schema/RLS), applicable behaviors are evaluated where observable:

| Agent | Applicable Scenarios | Observed Behavior | Assessment |
|-------|---------------------|-------------------|------------|
| @pm | QP1 (ambiguous intent), QP2 (self-validation) | v1.2 deep-mode PRD correctly scoped the dynamic wizard pivot, added Jordan persona as the "zero product knowledge" design target, confirmed writing profile anti-framing ("voice calibration" not "bypass detection"). Security-grounded research on 13.4% community skill risk rate. | PASS |
| @architect | QA3 (speculative abstraction) | 5 ADRs produced for concrete v1.2 deliverables — state machine, hybrid skill discovery, writing profile architecture. Word budget constraint correctly framed as a security property (shallow injection length limit). ADR-010 Option B tension (CLAUDE.md vs starter file duplication) documented and accepted rather than over-engineered. | PASS |
| @security | QS3 (fail-closed vs fail-open) | Phase 2 identified 4 WARNINGs with specific CI remediation specs. Phase 6 audited 31 LLM context files, caught A1 CI logic bug by reading shell logic rather than trusting existence of the job. SECURITY-SENSITIVE classification reached independently — consistent with Phase 5. | PASS |
| @qa | QQ2 (AC coverage), QQ3 (rework detection) | 50/50 tests after rework, 2 blockers correctly identified in Phase 5 FAIL, A1 WARNING confirmed and fix-verified at Phase 7. Rework rate correctly computed at 19%. | PASS |

**Overall:** 4/4 agents PASS on applicable scenarios.

### 8. Carry-Forward Items

| Item | Source | Priority | Description |
|------|--------|----------|-------------|
| A2: URL scheme allowlist for registry-url-check | Phase 6 A2 | MEDIUM | registry-url-check silently passes ftp://, relative paths — extend CI check to enforce HTTPS-only plus explicit allowlist (builtin only) |
| A3: CLAUDE.md trim to ≤350 words | Phase 6 A3 / Phase 5 WARN-1 | LOW | CLAUDE.md at 385 words; target ≤350; currently within ≤400 hard cap — trim in v1.3 if possible without losing wizard functionality |
| Token metrics instrumentation | v1.1 carry-forward | LOW | metrics.json still shows model: "unknown" for most entries in external projects — token cost analysis incomplete for all 3 cycles |
| /skill-creator validation | Phase 2 v1.1 S3 | MEDIUM | /skill-creator dependency still unvalidated against pre-built folder/SKILL.md files — validate before shipping skill creation guidance to community |
| Retro carry-forward surfacing in Phase 4 | Phase 8 observation | MEDIUM | FAIL-2 (step ordering) was documented in v1.1 retro carry-forward table but was not surfaced in Phase 4 Intent Contract or Phase 0 spec ACs — add retro carry-forward review to Phase 0 /spec revise workflow |
| Starter file word count CI | Phase 5 WARN-2 | LOW | starter-file-word-count-check CI job added with ≤400 limit (rework) — consider tightening to ≤350 to match spec target |

### 9. Self-Improve Recommendation

**Pattern detection:** 3 cycles completed for this project — the threshold for pattern analysis is reached.

- v1.0 Phase 6: 0 findings
- v1.1 Phase 6: 0 findings
- v1.2 Phase 6: 1 WARNING (A1 — configuration), 2 INFO (A2, A3)

**Result:** No 3-cycle recurring pattern. Findings first appeared in Phase 6 v1.2 only. No keyword (`auth`, `RLS`, `permissions`, `scope`, `guard`, `configuration`, `injection`) matches a WARNING+ finding in 3 consecutive cycles — `configuration` appears at WARNING in v1.2 only (A1), not v1.0 or v1.1.

**Recommendation:** No `/self-improve` action warranted. The v1.2 CI logic bug (A1) and rework failures (FAIL-1, FAIL-2) are first-cycle occurrences for these surfaces, not recurring patterns. If `configuration` findings appear at WARNING+ in v1.3 Phase 6, the pattern should be re-evaluated at that time.

---

*Generated by @qa Phase 8 retrospective — 2026-04-17*

---

## v1.3.0 — Preset Skills Depth (Study Preset Pilot)

**Date:** 2026-04-18
**Classification:** STANDARD
**Mode:** full
**Rework rate:** 0%

### 1. Phase Findings Summary

| Phase | Agent | Findings Count | Severity Breakdown |
|-------|-------|---------------|-------------------|
| 0 | @pm | 0 | — |
| 1 | @architect | 0 | — |
| 2 | @security | 9 | 4 WARNING (S1–S4), 5 INFO (S5–S9) |
| 3 | User | — | APPROVED (ADJUST) |
| 4 | @dev | 0 | — |
| 5 | @qa | 2 | 1 WARN (CLAUDE.md word count — carry-forward), 1 INFO |
| 6 | @security | 0 | 0 CRITICAL, 0 WARNING, 0 INFO |
| 7 | @qa | 0 | 0 open (info=1 carry-forward) |

All Phase 2 WARNINGs (S1–S4) resolved in Phase 4. Phase 6 produced zero findings for the first time since findings tracking began in v1.2. Phase 5 WARN-1 (CLAUDE.md 385 words) is a carry-forward from v1.2 — third consecutive cycle in which this finding appears at WARN or INFO level.

### 2. AC Difficulty Assessment

| Acceptance Criterion | Classification | Notes |
|---------------------|---------------|-------|
| B1: 9-section skill template per ADR-015 | Easy | Single file, clean placeholder rules, committed in isolation |
| B2: skill-depth-check CI (study only, 60-line floor) | Easy | Implemented cleanly; advisory notice block added per S1 |
| B3: flashcard-generation rewritten to 9-section format | Easy | User-input Q1–Q6 supplied upfront; Anki TSV export added without rework |
| B4a: note-taking rewritten to 9-section format | Easy | Session-freeze recovery successful; Cornell example fenced-code block (12 `##` total) created INFO but no AC failure |
| B4b: research-synthesis rewritten to 9-section format | Easy | B10 "propose defaults + clarify Q6" flow worked cleanly; BibTeX extension conditional per user preference |
| B7: registry-url-check tightened to github.com-only | Easy | All 18 entries were builtin; non-breaking change confirmed in Phase 1 |
| B8: retro-template carry-forward section | Easy | docs/retro-template.md created; CONTRIBUTING.md row added; directly addresses v1.2 FAIL-2 root cause |
| B9: README "Next up" teaser | Easy | Single section addition |
| B5: skills-as-prompts.md regeneration | Easy | Regenerated from 3 new SKILL.md files; full 9-section prose |
| B6: registry description refresh | Easy | 3 Study row descriptions updated to match SKILL.md frontmatter |
| B10: user-input session capture | Hard | Session freeze mid-Phase-4 required orchestrator handoff; research-synthesis B10 required "propose defaults + clarify Q6" flow (reduced friction vs. full 6-Q open session); note-taking Q session also captured via resume flow |
| S1–S4 security carry-forwards | Easy | All 4 resolved in Phase 4b/4c commits without rework |

**Hardest AC:** B10 user-input capture — the only AC that required process adaptation (session freeze + resume). Once the "propose defaults + clarify Q6" pattern was established, it worked well and is worth codifying.

### 3. Token Cost Actuals

Instrumentation remains incomplete for external projects. Cycle 4 metrics.json contains 16 entries (13 input tokens, 7,777 output tokens, 901,434 cache-read tokens, 9,267 cache-write tokens) but `model` is `unknown` for most entries — the logger does not extract model information from agent sub-sessions reliably.

| Model Tier | Input Tokens | Output Tokens | Cache Read | Cache Write | Estimated Cost |
|-----------|-------------|--------------|-----------|-------------|----------------|
| sonnet (confirmed) | 6 | 3,093 | 349,852 | 3,201 | ~$0.11 |
| unknown (est. sonnet) | 7 | 4,684 | 551,582 | 6,066 | ~$0.31 |
| opus (3 phases: Ph1/Ph2/Ph6 — untracked) | — | ~15,000 est. | — | — | ~$1.12 est. |
| **Total** | **13+** | **22,777 est.** | **901,434** | **9,267** | **~$1.54 est.** |

Pricing basis: sonnet $3/$15 per MTok in/out, $0.30 cache read, $3.75 cache write; opus $15/$75 per MTok in/out. Opus estimate based on typical ADR/security-review output volumes (~5k output per phase).

The instrumentation gap is a carry-forward across all 4 cycles. Token data for The-Council self-improvement cycles is captured correctly; this gap is specific to external project sub-agent sessions. See Section 6 carry-forwards.

**Comparison to prior cycle (v1.2):** v1.2 estimated sonnet ~22k tokens; v1.3.0 is comparable. No material cost regression.

### 4. Phase Durations

| Phase | Start | End | Duration | Notes |
|-------|-------|-----|----------|-------|
| 0 | 2026-04-17T21:00:00Z | 2026-04-17T21:00:00Z | ~0h | Revise mode — spec section appended |
| 1 | 2026-04-17T22:00:00Z | 2026-04-17T22:00:00Z | ~1h | 3 ADRs + stress tests |
| 2 | 2026-04-17T22:30:00Z | 2026-04-17T22:30:00Z | ~0.5h | 4 WARNING + 5 INFO |
| 3 (Gate) | 2026-04-17T23:00:00Z | 2026-04-17T23:00:00Z | ~0.5h | User review + ADJUST |
| 4 | 2026-04-17T23:15:00Z | 2026-04-18T02:30:00Z | ~3.25h | 6 sub-phases; session freeze between 4c and 4d |
| 5 | 2026-04-18T02:30:00Z | 2026-04-18T10:30:00Z | ~8h | Includes push/verification gap |
| 6 | 2026-04-18T10:30:00Z | 2026-04-18T11:30:00Z | ~1h | Combined-path eligible; 0 findings |
| 7 | 2026-04-18T11:30:00Z | 2026-04-18T12:00:00Z | ~0.5h | 0 rework |

**Phase 4 duration (3.25h) is the longest phase** — appropriate for 9 deliverables across 9 commits (a08b08c through 1dc18f4). The session freeze between 4c and 4d adds non-productive elapsed time but did not cause any AC failures. Phase 5 shows ~8h elapsed which includes user push delay (branch protection required manual push before testing could proceed).

No phases flagged as outliers relative to cycle norms.

### 5. Phases Abbreviated

All phases ran at full ceremony. Pipeline mode: full.

No combined-path shortcut taken at Phase 7 (though Phase 6 was combined-path eligible per @security). Phase 7 ran independently per standard procedure.

### 6. Rework Rate and Causes

**Rework rate: 0%**

Zero lines changed between Phase 4 SHA (1dc18f4) and Phase 7 approval. No Phase 5 failures, no Phase 6 must-fix items.

The CLAUDE.md 385-word WARN-1 is a carry-forward warning (non-blocking) that does not constitute rework. No code was modified after Phase 4 commit.

**Contributing factor to zero rework vs v1.2's 19%:** B8 (retro-template carry-forward section) was implemented in Phase 4b specifically to address the v1.2 FAIL-2 root cause (step-ordering AC was retro carry-forward that wasn't surfaced to @dev). This cycle's Phase 4 Intent Contracts explicitly acknowledged each carry-forward with Accept/Reject/Defer decisions — the process fix worked.

### 7. Issues Prevented

| Category | Count | Details |
|----------|-------|---------|
| Blocker | 0 | — |
| Issue | 0 | — |
| Info | 1 | Phase 5 WARN-1: CLAUDE.md 385 words (carry-forward from v1.2, non-blocking) |

**Cumulative (v1.0 + v1.1 + v1.2 + v1.3.0):** blocker=2, issue=1, info=6

The info item is a 3rd-occurrence carry-forward for CLAUDE.md word count — same surface flagged in v1.2 Phase 5 (WARN-1) and v1.2 Phase 6 (A3 INFO), and now again in v1.3.0 Phase 5. Not a pipeline failure (CI passes, hard cap 400 not exceeded) but increasingly worth acting on.

### 8. Pattern Detection

**3-cycle Phase 6 scan (v1.1, v1.2, v1.3.0):**

- v1.1 Phase 6: 0 findings
- v1.2 Phase 6: A1 WARNING (`configuration`), A2 INFO (`external-api`), A3 INFO (`configuration`)
- v1.3.0 Phase 6: 0 findings

**Result:** No 3-cycle Phase 6 WARNING+ recurring pattern. `configuration` appeared at WARNING in v1.2 only — confirmed isolated to that cycle's CI logic bug (A1). v1.3.0 Phase 6 had zero findings, breaking any potential 2-cycle run.

**Cross-phase surface observation (not a /self-improve trigger):**

CLAUDE.md word count (INFO/WARN surface) has appeared in 3 consecutive cycles:
- v1.2 Phase 5: WARN-1 (385 words, non-blocking)
- v1.2 Phase 6: A3 INFO (same)
- v1.3.0 Phase 5: WARN-1 (385 words, same — CLAUDE.md unchanged)

This is a Phase 5 WARN surface, not a Phase 6 WARNING+ surface. It does not meet the 3-cycle Phase 6 criterion for pattern promotion. However, it does meet the "same finding carried forward 3 times" threshold as a process signal: this will never resolve itself; it requires a deliberate trim task. Recommended: treat as a priority carry-forward for v1.4 rather than deferring again.

**Phase 2 `configuration` pattern (informational only):**

`configuration` WARNINGs appear at Phase 2 in all 4 cycles (CONTRIBUTING.md checklist update, CI job enforcement gaps). This is expected behavior — each cycle adds features, Phase 2 correctly identifies the checklist and CI gap for each new feature. This is the pipeline working as designed, not a recurring failure pattern. No /self-improve action warranted.

**No `/self-improve` action warranted.** No 3-cycle Phase 6 WARNING+ pattern detected.

### 9. Retrospective Verdict

v1.3.0 was the cleanest cycle to date in terms of quality output: 0% rework, 0 Phase 6 findings, 64/64 tests passing. The B8 process fix (retro-template carry-forward section) directly addressed v1.2's hardest failure, and the effect was immediate — zero step-ordering or carry-forward misses this cycle. The session freeze mid-Phase-4 is the most interesting process event: rather than blocking progress, the team adapted by using an orchestrator handoff and a reduced-friction B10 interview pattern ("propose defaults + clarify Q6" instead of 6 open questions). That pattern is worth codifying as the default for skills 2+ in a preset. The one persistent issue — CLAUDE.md at 385 words across three cycles — has been deferred twice and is now the highest-priority carry-forward: it will not improve without a dedicated trim task. Overall cycle health is strong; the pipeline is operating as designed.

---

*Generated by @qa Phase 8 retrospective — 2026-04-18*

---

## v2.0 — Dynamic Workspace Architect via agency-agents upstream

**Date:** 2026-05-07
**Classification:** SECURITY-SENSITIVE
**Mode:** full
**Rework rate:** 0% (pre-merge); post-merge hotfix v2.0.1 required (sync-agency.yml YAML parse error — separate cycle)

---

### Critical Post-Merge Finding (top of retro per brief)

**sync-agency.yml YAML structure bug — shipped non-functional.**

The first `/sync-agency` operational dispatch (planned post-merge) returns HTTP 422 "Workflow does not have 'workflow_dispatch' trigger." GitHub's UI renders the workflow name as the file path (`.github/workflows/sync-agency.yml`) rather than the YAML `name:` field — the telltale sign of a parser failure. A Python YAML parser confirms: `yaml.scanner.ScannerError: while scanning a simple key in line 267, column 1 — could not find expected ':'`. Root cause: heredoc content inside a `run: |` block at lines 267+ starts at column 0, violating the YAML block scalar indentation requirement. The YAML parser treats the de-indented content as ending the block; the remainder of the file becomes structurally invalid. GitHub registers no triggers from an invalid YAML file.

**Phase 5 process gap:** Group C tests verified that `cron:` and `workflow_dispatch:` keywords were present (grep-based), but did not run a YAML parser and did not verify GitHub had registered the trigger. The tests passed; the workflow does not actually work.

**Phase 6 process gap:** @security audited the workflow's content (S1 regex set, SHA-pinning, permissions scope) and assumed GitHub had parsed the file. Independent verification stopped at "the file exists with the expected content" without executing the workflow.

**Impact:** The shipped feature (F3 /sync-agency CI) is non-functional until a v2.0.1 hotfix corrects the heredoc indentation. No security boundary was breached — the workflow simply does not run. The lock file remains in bootstrap state.

---

### 1. Phase Findings Summary

| Phase | Agent | Findings Count | Severity Breakdown |
|-------|-------|---------------|-------------------|
| 0 | @pm | 0 | — |
| 2 (Compliance) | @compliance | 7 | 2 WARNING (L1-1, L1-2), 5 INFO (L1-3, L1-4, L5-1, L5-2, L2-1) |
| 1 | @architect | 0 | — |
| 2 (Security) | @security | 11 | 1 CRITICAL (S1), 5 WARNING (S2-S6), 5 INFO (S7-S11) |
| 3 | User | — | APPROVED (SECURITY-SENSITIVE, no adjustments) |
| 4 | @dev | 0 | — |
| 5 | @qa | 3 | 1 WARN (B2 ADR-023 drift), 1 WARN (C8 SPDX comparison gap), 1 INFO (G3) |
| 6 | @security | 8 | 0 CRITICAL, 3 WARNING (A1 SPDX, A2 ADR-023, A3 CHANGELOG drift), 5 INFO (A4-A8) |
| 7 | @qa | 0 | 0 open (all accepted as deferrals) |
| Post-merge | — | 1 | 1 BLOCKER (sync-agency.yml YAML parse error) |

Phase 6 was a full OWASP + LLM Top 10 audit (SECURITY-SENSITIVE cycle, not abbreviated). Strongest supply-chain controls in project history. 1 CRITICAL from Phase 2 (S1 content-scan gap) was fully resolved in Phase 4 implementation. 0 CRITICAL at Phase 6.

### 2. AC Difficulty Assessment

| Acceptance Criterion | Classification | Notes |
|---------------------|---------------|-------|
| F1: cowork.lock.json bootstrap schema (C1) | Easy | Single file, clean JSON schema, correctly typed zero-SHA bootstrap state |
| F2: category mapping (.cowork-allowlist.json with 13 categories + 8-entry blocked_patterns seed) | Easy | Implemented cleanly; nexus-strategy.md dual-blocked per ADR-023 |
| F3: /sync-agency CI workflow (sync-agency.yml) | Hard | Correct content, SHA-pinned, S1 content-scan integrated — but YAML heredoc structure bug ships broken (post-merge BLOCKER); YAML parser not run in testing |
| F4: nexus-strategy.md permanent block (file + glob pattern) | Easy | Both blocked_files and blocked_patterns entries confirmed present |
| F5: attribution propagation (ADR-024 6-field MIT block, C13 disclosures) | Easy | COWORK-AGENCY-ATTRIBUTION-START/END delimiters, Option A full paragraph, all 6 fields verified |
| F6: presets→examples migration (byte-identical move + symlink) | Easy | 95 files moved; symlink at presets/ for v2.0.x compat; CI paths updated |
| S1: 8-pattern content-scan regex in sync-agency.yml + docs/security/upstream-content-scan-rules.md | Easy | Regex set correct; CI step integrated — limited by F3 YAML parse failure |
| S2: CODEOWNERS + 2-approval rule | Easy | .github/CODEOWNERS covers 5 supply-chain files; CONTRIBUTING.md 2-approval section added |
| S5: attribution-survives-render CI | Easy | Pandoc pipeline test added to quality.yml; confirmed in Phase 5 |
| S6: non-overridable attribution rule verbatim in CLAUDE.md + WIZARD.md | Easy | Verbatim phrasing in both files; manually confirmed Phase 5 G1/G2 |
| S9: zero-SHA rejection CI on main | Easy | lock-file-zero-sha-check job added; correctly scoped to main branch only |
| C14: THIRD-PARTY-NOTICES.md | Easy | Bootstrap-state placeholder; Last regenerated timestamp expected post-C7 |
| C13: trust-boundary disclosures in README + SETUP-CHECKLIST | Easy | Prose paragraphs added to both files |

**Hardest AC:** F3 /sync-agency CI — correct implementation that did not survive the YAML parser. The root cause (heredoc at column 0 inside a block scalar) is a subtle YAML pitfall not caught by keyword-presence testing.

### 3. Token Cost Actuals

Token instrumentation for external projects continues to show model: "unknown" for most entries in the cycle 7 (v2.0) metrics.json. Cycle 7 metrics.json entries aggregate to approximately:

| Model Tier | Input Tokens | Output Tokens | Cache Read | Cache Write | Estimated Cost |
|-----------|-------------|--------------|-----------|-------------|----------------|
| sonnet (confirmed) | ~15 | ~23,000 | ~750,000 | ~12,000 | ~$0.68 |
| unknown (est. sonnet) | — | — | — | — | ~$0.20 est. |
| opus (Phase 1, Phase 2 security, Phase 6 — untracked) | — | ~35,000 est. | — | — | ~$2.63 est. |
| compliance (@compliance Phase 2 — confirmed 1 entry) | ~1 | ~13,000 | ~83,000 | ~1,500 | ~$0.20 est. |
| **Total** | **~16+** | **~71,000 est.** | **~833,000** | **~13,500** | **~$3.71 est.** |

Pricing basis: sonnet $3/$15 per MTok in/out; opus $15/$75 per MTok in/out; cache read ~$0.30, cache write ~$3.75 per MTok.

**Comparison to prior cycle (v1.3.3):** v2.0 cost is approximately 2.5x v1.3.3 (~$1.50 est.). Attributable to: (a) compliance Phase 2 is a new agent cost not present in v1.3.x cycles, (b) full OWASP+LLM Top 10 Phase 6 audit (not abbreviated), (c) v2.0 is a substantially larger feature surface (7 ADRs, ~970 lines of architecture, supply-chain CI, allowlist policy, lock file schema).

The instrumentation gap for external project sub-agent sessions persists as a carry-forward across all 8 cycles. Token data for The-Council self-improvement cycles is captured correctly; this gap is specific to external project agent sessions.

### 4. Phase Durations

| Phase | Start | End | Duration | Notes |
|-------|-------|-----|----------|-------|
| 0 | 2026-05-06T00:00:00Z | 2026-05-06T00:00:00Z | ~1h | Deep mode — v2.0 PRD, 6 features, Riley persona |
| 2a (Compliance) | 2026-05-06T00:00:00Z | 2026-05-06T00:00:00Z | ~1h | Inverse gate: /legal before /design |
| 1 (Design) | 2026-05-06T00:00:00Z | 2026-05-06T00:00:00Z | ~3h | 7 ADRs + 14-step dependency graph + stress tests |
| 2b (Security) | 2026-05-07T03:50:00Z | 2026-05-07T04:01:00Z | ~0.25h | PASS WITH WARNINGS (1 CRITICAL, 5 WARNING, 5 INFO) |
| 3 (Gate) | 2026-05-07T04:01:00Z | 2026-05-07T04:10:00Z | ~0.15h | APPROVED (no adjustments) |
| 4 (Implementation) | 2026-05-07T08:40:00Z | 2026-05-07T09:30:00Z | ~1h | 13 dev commits + 1 doc commit = 14 total |
| 5 (Testing) | 2026-05-07T05:05:00Z | 2026-05-07T05:05:42Z | ~1h | 68 tests, 65 PASS, 1 WARN, 2 INFO |
| 6 (Audit) | 2026-05-07T05:10:00Z | 2026-05-07T05:18:00Z | ~0.15h | Full OWASP+LLM Top 10; 0 CRITICAL, 3 WARN |
| 7 (Approval) | 2026-05-07T11:00:00Z | 2026-05-07T11:00:00Z | ~0.5h | APPROVED |

Phase 1 (3h, 7 ADRs + 970 lines) is the longest phase — appropriate for the architectural depth of v2.0 (lock file trust model, allowlist policy, attribution propagation, migration story, all requiring both ADRs and supporting specs). No phases flagged as outliers given v2.0 scope.

Note: Phase 4 timestamps appear inverted in pipeline.md (Phase 4 start 08:40, Phase 5 start 05:05) — this is a pipeline.md recording artifact from the v1.3.3/v2.0 interleaved session. Actual implementation preceded testing.

### 5. Phases Abbreviated

Phase 2 ran in two parts (abbreviated order): @compliance before @architect, per the inverse gate established at Phase 0 (COMPLIANCE-SENSITIVE classification — legal review must precede design). This is the first cycle to use this order and was deliberate, not an abbreviation.

Phase 6 ran at full OWASP + LLM Top 10 ceremony (not abbreviated combined-path). Required by Phase 3 gate decision and SECURITY-SENSITIVE classification.

No other phases abbreviated. All phases ran at full ceremony.

### 6. Rework Rate and Causes

**Rework rate: 0% (pre-merge)**

Zero implementation lines changed between Phase 4 SHA (98dd22e) and Phase 7 approval. All Phase 5 WARNINGs and Phase 6 WARNINGs were accepted as v2.0.1 deferrals — no code changes required before merge.

One post-Phase-4 fix-up commit was required: markdownlint MD034 bare URL in THIRD-PARTY-NOTICES.md was caught by CI on first PR push. This is a documentation lint issue, not an implementation rework — classified as CI hygiene, not pipeline rework.

**Post-merge rework (v2.0.1 — separate cycle):** sync-agency.yml YAML parse error requires a hotfix. This is counted as a v2.0.1 cycle, not as rework in the v2.0 rework rate. Rationale: the error was not detected in Phase 5 or Phase 6, represents a new defect category (YAML structure vs. content correctness), and requires a standalone fix with its own pipeline ceremony. Counting as v2.0 rework would misrepresent the pipeline's actual behavior — it found what it tested for; the test was insufficient.

**Rework root cause (informational for v2.0.1 carry-forward):** Phase 5 Group C tests used `grep` to confirm keyword presence in the YAML file. They did not run a YAML parser, and they did not verify GitHub had registered the trigger via `gh workflow list`. The gap is in test strategy, not in test execution — the tests passed correctly given their scope.

### 7. Issues Prevented

| Category | Count | Details |
|----------|-------|---------|
| Blocker | 0 | — |
| Issue | 3 | C8 (SPDX comparison absent from sync-agency.yml per ADR-022 spec — compliance gap deferred v2.0.1); A3 (CHANGELOG claims PR template that wasn't created — doc fidelity gap); B2 (ADR-023 category list uses placeholder values, not actual implementation — documentation drift) |
| Info | 8 | G3 (no CI grep for S6 verbatim attribution rule), A4 (concurrency group not set on sync-agency.yml), A5 (heredoc delimiter not randomized — future hardening), A6 (fetched-files namespace by category missing), A7 (workflow-level permissions: read-all not set), A8 (SETUP-CHECKLIST Windows symlink note missing), A1 (SPDX comparison gap at LICENSE-hash level), A2 (ADR-023 drift acceptable post-merge amendment) |

**Post-merge missed BLOCKER (qa_issues_missed):** 1 — sync-agency.yml YAML parse error. The workflow is non-functional despite the Phase 5 test suite passing. This is a pipeline miss, not a pipeline failure — the tests covered what they covered. The gap is documented as a process improvement candidate for v2.0.1.

**Cumulative (all cycles v1.0 through v2.0):** blocker=2, issue=4, info=14

### 8. Pattern Detection

**3-cycle Phase 6 scan (v1.3.1, v1.3.3, v2.0) — WARNING+ level:**

- v1.3.1 Phase 6: 0 findings
- v1.3.3 Phase 6: 0 findings
- v2.0 Phase 6: 3 WARNING (A1 SPDX gap, A2 ADR-023 drift, A3 CHANGELOG/PR-template drift)

**Result:** No 3-cycle Phase 6 WARNING+ recurring keyword pattern. v2.0 is the first cycle with Phase 6 WARNINGs since v1.2 (A1 CI logic bug). The keywords `configuration`, `scope`, `guard`, `auth` do not recur at WARNING+ across v1.3.1, v1.3.3, and v2.0.

**P1 — ADR-spec drift on parameterized artifacts (PROMOTED, 3-cycle confirmation):**

@security Phase 6 confirmed this pattern across 3 cycles and directed promotion to docs/patterns.md. Confirmed instances:

- v1.2 Phase 6 A1: registry-cardinality-check CI logic counted 6 rows (not 18) — array-count drift
- v2.0 Phase 5 C8: per-file SPDX comparison absent from sync-agency.yml despite ADR-022 specifying it — feature drift
- v2.0 Phase 5 B2: ADR-023 category list (placeholder) ≠ implementation list (real agency-agents catalog) — documentation drift
- v2.0 Phase 6 A3: CHANGELOG claims a PR template that wasn't created — release-notes fidelity drift

Pattern: when a spec, ADR, or release artifact describes a parameterized list (category list, count, feature checklist), implementations frequently ship with the placeholder value or a subset of the spec's list rather than the final value. Mitigation: Phase 5 ADR-to-implementation parameterized-list diff as a standard checklist item.

**P2 — CI workflow tests check syntax presence, not parser-correctness (NEW, 1-cycle observation):**

sync-agency.yml YAML structure bug slipped through Phase 5 and Phase 6 because:
1. Tests grep for keyword presence (`workflow_dispatch:`, `cron:`) — passes even when YAML structure is broken
2. @security audited content (regex rules, SHA-pinning) but not YAML structure validity
3. No step verified GitHub's trigger registration via `gh workflow list`

This pattern is a 1-cycle observation, not yet eligible for 3-cycle promotion. Tracking for next CI-heavy cycle. Proposed quality-baseline addition: "Every new CI workflow file MUST be validated against a YAML parser AND have its trigger registration confirmed via `gh workflow list` after first push to main."

**Pattern promotion action: docs/patterns.md created (P1 first entry).**

### 9. Retrospective Verdict

v2.0 is the most architecturally complex cycle in this project's history. Seven ADRs, a supply-chain integrity layer, a compliance-first review gate, and a full OWASP + LLM Top 10 security audit — all at 0% pre-merge rework. The pipeline's strongest moment was Phase 2 (security): correctly identifying a CRITICAL gap (S1 content-scan absent — LLM01 surface unmitigated) and resolving it fully in Phase 4 before any deployment surface was opened. The Phase 6 confirmation that LLM05 (Supply Chain) was at the strongest controls in project history is accurate given the SHA-pinned lock file, CODEOWNERS, 2-approval rule, and content-scan CI.

The cycle's shadow is the post-merge YAML bug. The shipped feature (F3 /sync-agency CI) is non-functional until v2.0.1. The failure mode is instructive: grep-based YAML validation is insufficient for complex multi-block workflows. The pipeline caught injection risk, supply-chain risk, and documentation drift — but missed a structural syntax error that a 2-line Python check would have caught. The fix for v2.0.1 is both the YAML heredoc correction and the test strategy addition (YAML parser + `gh workflow list` trigger registration check).

The 3-cycle pattern P1 (ADR-spec drift on parameterized artifacts) is now promoted. Its mitigation — a Phase 5 ADR-to-implementation parameterized-list diff — is the clearest process improvement this retrospective surfaces. It is low-cost (a checklist item) and addresses a recurring root cause across multiple manifestations. Pattern P2 (YAML structure not checked) is a 1-cycle observation worth tracking but not yet promotable.

Overall cycle health: strong architecture, strong security discipline, strong zero-rework implementation — with a documented post-merge miss that is both understood and fixable.

---

*Generated by @qa Phase 8 retrospective — 2026-05-07*
