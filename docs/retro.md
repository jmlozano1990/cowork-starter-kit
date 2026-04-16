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
