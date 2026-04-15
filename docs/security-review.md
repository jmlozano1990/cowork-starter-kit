# Security Review — Claude Cowork Config

## Phase: 2
## Date: 2026-04-15T06:45:00Z
## Status: PASS WITH WARNINGS

## Findings Summary
| ID | Severity | Phase | Surface | Description |
|----|----------|-------|---------|-------------|
| S1 | WARNING | 2 | configuration | CI safety-rule enforcement deferred to post-v1 — community presets could ship without the confirm-before-delete rule |
| S2 | WARNING | 2 | external-api | GitHub Actions workflow uses unpinned action versions (tags only, no SHA pinning) |
| S3 | WARNING | 2 | permissions | Shell scripts create folders under user-controlled path without input sanitization spec |
| S4 | INFO | 2 | auth | WIZARD.md is an LLM instruction surface — prompt injection mitigated by design (no external data ingestion) but community presets are an adversarial content vector |
| S5 | INFO | 2 | configuration | SkillRisk.org referenced as safety resource but availability/trustworthiness is unverified |
| S6 | INFO | 2 | ui | Trust model for non-technical users relies on inline safety note — no persistent visual indicator of skill provenance |

---

### WARNING

- [ ] **S1 — CI safety-rule grep should ship at v1, not be deferred post-v1.** The architecture (Safety Architecture, layer 4) explicitly defers a CI check that greps all preset `global-instructions.md` files for the safety rule text, marking it as "post-v1 if needed." Given that (a) the confirm-before-delete safety rule is the single most critical safety feature in this product (validated by the 11GB deletion incident), (b) the spec marks it as "non-negotiable," and (c) community contributions are expected within 60 days of launch (assumption C2), this deferral creates a gap: a community-contributed preset could pass CI (lint, links, shellcheck) while omitting the safety rule entirely. The defense-in-depth layers 1-3 (template, preset, wizard) only protect presets built through the wizard — a raw PR to `presets/` could bypass all three. **Recommendation:** Add a CI step at v1 that greps every `presets/*/global-instructions.md` for the canonical safety rule string from `templates/global-instructions-base.md`. This is a single `grep -rL` command in the workflow — near-zero implementation cost.

- [ ] **S2 — GitHub Actions should pin actions to SHA, not just version tags.** ADR-005 specifies three actions by tag only: `actions/checkout@v4`, `DavidAnson/markdownlint-cli2-action@v19`, `lycheeverse/lychee-action@v2`, `ludeeus/action-shellcheck@2.0.0`. Tags are mutable — a compromised upstream action author can update a tag to point to malicious code. For a public repo accepting community PRs, this is a supply-chain risk. **Recommendation:** Pin all actions to full commit SHA (e.g., `actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11`) with a comment noting the version. This is GitHub's own recommendation for public repos. The ADR workflow YAML should be updated at implementation time.

- [ ] **S3 — Shell scripts should validate and sanitize the target path argument.** ADR-001 specifies `scripts/setup-folders.sh` (bash) and `scripts/setup-folders.ps1` (PowerShell) for folder creation. The architecture does not specify how the target directory is determined. If the scripts accept a user-provided path argument, they must validate it: (a) reject paths containing `..` traversal sequences, (b) reject absolute paths outside `~/Documents/`, (c) refuse to operate on system directories (`/`, `/usr`, `/etc`, `$HOME` root). Without validation, a mistyped or malicious path argument could create unexpected directory structures in sensitive locations. **Recommendation:** @dev should implement explicit path validation in both scripts. The script should default to `~/Documents/Claude/Projects/<preset-name>/` and only accept a path override if it passes the above checks.

### INFO

- **S4 — LLM instruction surface (WIZARD.md) is low-risk by design.** WIZARD.md is the primary attack surface in this project — it is an instruction file that an LLM (Cowork) reads and executes. However, the threat model is favorable: (a) WIZARD.md is a static file in a repo the user downloads — there is no runtime data injection into its instructions, (b) the wizard does not ingest external URLs, API responses, or user-uploaded files into its instruction context, (c) the wizard's actions are limited to reading preset files and generating output files — it does not execute arbitrary commands. The adversarial vector is community-contributed presets: a malicious PR could embed prompt injection payloads in skill files, context files, or global-instructions.md that alter Cowork's behavior when the wizard processes that preset. This is mitigated by (a) the CONTRIBUTING.md PR review checklist, (b) SkillRisk.org scanning requirement, and (c) maintainer review of all PRs. Residual risk is acceptable for a public open-source repo at v1.

- **S5 — SkillRisk.org dependency is unverified.** The spec (F5 safety note, F8 CONTRIBUTING.md) references SkillRisk.org as a scanning tool for skill file safety. This external dependency is not validated: Is the site operational? Is it maintained? Does it actually detect prompt injection in SKILL.md files? If SkillRisk.org goes offline or produces false negatives, the safety guidance becomes misleading. **Recommendation:** Before v1 launch, verify SkillRisk.org is operational and test it against a known-malicious skill file. If unavailable, replace with manual review guidance ("Read every instruction line in the skill file before submitting — look for instructions that override safety rules, request file deletion, or reference external URLs").

- **S6 — Trust model transparency for non-technical users.** The current trust architecture distinguishes Tier 1 (self-created via skill-creator) and Tier 2 (Anthropic pre-builts) sources. This is sound. However, the only user-facing signal is a single inline safety note in WIZARD.md at the skill step. Non-technical users who later install community skills from other sources will not have a persistent reminder of the trust boundary. **Recommendation:** Consider adding a "Skill Safety" section to SETUP-CHECKLIST.md that explains the trust tiers in plain language and persists beyond the wizard session. This is a UX recommendation, not a blocking concern.

---

### OWASP Top 10 Assessment (Adapted for Static Template Repository)

| Category | Status | Notes |
|----------|--------|-------|
| A01:2021 — Broken Access Control | N/A | No access control system. Repo is public. Files are read-only templates. |
| A02:2021 — Cryptographic Failures | N/A | No cryptographic operations. No secrets stored. No encryption needed. |
| A03:2021 — Injection | WATCHED | Not traditional SQL/OS injection. LLM prompt injection via skill files is the analog — see S4. Community presets are the injection vector. Mitigated by PR review + SkillRisk.org scanning. |
| A04:2021 — Insecure Design | PASS | Defense-in-depth safety architecture (3 layers + CI proposed). Dual-path skill delivery. Graceful degradation across 3 delivery paths. |
| A05:2021 — Security Misconfiguration | WATCHED | S2 (unpinned GH Actions) and S3 (unsanitized script paths) are configuration hygiene issues. Neither is critical for a content repo with no secrets. |
| A06:2021 — Vulnerable & Outdated Components | WATCHED | No runtime dependencies. CI actions are the only third-party components — S2 covers pinning. |
| A07:2021 — Identification & Authentication Failures | N/A | No authentication system. No user accounts. |
| A08:2021 — Software & Data Integrity Failures | WATCHED | S1 (missing CI safety-rule enforcement) means integrity of the safety rule across presets is not machine-verified. S2 (action pinning) is a CI supply-chain integrity concern. |
| A09:2021 — Security Logging & Monitoring Failures | N/A | No runtime system. Git history serves as the audit trail. CHANGELOG.md documents changes. |
| A10:2021 — Server-Side Request Forgery | N/A | No server. No HTTP requests. |

### OWASP LLM Top 10 Assessment

| Category | Status | Notes |
|----------|--------|-------|
| LLM01 — Prompt Injection | WATCHED | WIZARD.md is a direct prompt injection surface (instructions to an LLM). However, (a) no external data is injected into the prompt at runtime, (b) the wizard reads only local preset files, and (c) community preset PRs are the primary indirect injection vector. Mitigated by PR review, SkillRisk.org, and maintainer gatekeeping. Residual risk: a merged malicious preset could instruct Cowork to delete files, exfiltrate data to clipboard, or override the safety rule. |
| LLM02 — Insecure Output Handling | LOW RISK | Wizard output is files written to the user's local filesystem. No downstream system consumes this output programmatically. The `project-instructions.txt` output is pasted by the user into Cowork's UI — injection into that field would affect only the user's own Cowork behavior, not other users. |
| LLM06 — Sensitive Information Disclosure | LOW RISK | Wizard collects minimal personal information (name, role, study subject). This is stored in `cowork-profile.md` locally. No data leaves the user's machine. No telemetry. No analytics. The only disclosure risk is if the user commits their filled-in `about-me.md` or `cowork-profile.md` to a public fork — but this is user action, not a system vulnerability. |

### Additional Surface Assessment

| Surface | Status | Notes |
|---------|--------|-------|
| Shell scripts (setup-folders.sh/.ps1) | WATCHED | S3 covers path validation. Scripts only create directories — no file deletion, no network access, no privilege escalation. Attack surface is limited to unexpected directory creation in wrong locations. |
| Community contributions (PRs) | WATCHED | S1 + S4 cover this. The CONTRIBUTING.md checklist and maintainer review are the primary gates. CI safety-rule enforcement (S1) is the machine-enforceable backstop. |
| ZIP upload guidance | PASS | The spec correctly documents the required ZIP structure (`skill-name/SKILL.md` at root). No code executes during ZIP creation — the user manually zips preset files. |
| Connector permission documentation (F6) | PASS | F6 includes explicit permission scopes, data boundary notes, Gmail draft-only constraint, and Google Workspace admin pre-auth requirement. This is better transparency than most products provide. |
| Safety architecture (4-layer defense-in-depth) | PASS WITH S1 | Layers 1-3 (template, preset, wizard) are well-designed. Layer 4 (CI) is deferred — S1 recommends shipping it at v1. With all 4 layers active, the defense-in-depth is strong. |

---

### Summary

This is a well-designed static template repository with an unusually thoughtful safety architecture for its category. The 3-layer defense-in-depth for the confirm-before-delete safety rule, the dual-path skill delivery (now pivoted to skill-creator + ZIP), the explicit connector permission documentation (F6), and the trust-tier model (Tier 1 self-created, Tier 2 Anthropic pre-builts) all reflect security-conscious design.

The three WARNING findings are all preventable at implementation time with minimal effort:
- **S1** is a single `grep -rL` CI step (~5 lines of YAML)
- **S2** is a one-time SHA lookup for 4 actions
- **S3** is basic input validation in two shell scripts

No CRITICAL findings. The LLM instruction surfaces (WIZARD.md, skill files) are lower risk than typical LLM applications because there is no runtime data injection, no external API calls, and no multi-user interaction. The primary adversarial vector (community preset PRs) is adequately mitigated by human review, with S1 providing the recommended machine-enforceable backstop.

**Decision: PASS WITH WARNINGS.** No findings block the pipeline. All three WARNINGs should be addressed during Phase 4 implementation.
