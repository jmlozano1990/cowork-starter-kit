# Security Review — Claude Cowork Config v1.2 (Dynamic Workspace Architect)

## Phase: 2
## Date: 2026-04-17T13:00:00Z
## Status: PASS WITH WARNINGS

---

## Findings Summary

| ID | Severity | Phase | Surface | Description |
|----|----------|-------|---------|-------------|
| S1 | WARNING | 2 | configuration | CONTRIBUTING.md PR checklist is v1.1 — missing v1.2 items (writing-profile.md template section, curated-skills-registry.md schema, CLAUDE.md alignment check) |
| S2 | WARNING | 2 | configuration | CLAUDE.md word-count ceiling (≤350 words) is unenforced by CI — an oversized CLAUDE.md with a long instruction chain passes all current CI checks |
| S3 | WARNING | 2 | external-api | curated-skills-registry.md source_url has no integrity validation — a PR can add an entry pointing to any URL; no hash pinning, no SHA pinning, and no CI check on the URL field |
| S4 | WARNING | 2 | auth | CLAUDE.md is now the universal auto-load entry point (Layer 1a, ADR-010); blast radius of a malicious CLAUDE.md commit affects all users who open the repo folder — larger blast radius than any preset-specific change |
| S5 | INFO | 2 | external-api | Tier 2 keyword scan is LLM-assisted text review only — obfuscated payloads (base64, unicode escapes, multi-hop references) would not be detected; this is documented as best-effort but the "I understand" confirmation flow may be insufficient for non-technical users |
| S6 | INFO | 2 | configuration | Tier 2 hardcoded repo list in WIZARD.md has no CI enforcement — a malicious PR could add adversarial repos to the search list; WIZARD.md has no content validation jobs |
| S7 | INFO | 2 | configuration | curated-skills-registry.md `source_url: builtin` sentinel is trust-by-convention only — a PR could claim `builtin` for a community skill; no CI validation distinguishes this value from a real GitHub URL |
| S8 | INFO | 2 | logging | Writing profile E6 design is architecturally sound (patterns only, no raw sample storage) — flag for @dev: implementation must extract patterns and discard raw sample text; no CI enforcement of this behavior |

---

### CRITICAL

*(None — pipeline not blocked)*

---

### WARNING

- [ ] **S1 — CONTRIBUTING.md PR checklist must be updated to v1.2 before Phase 4 commit.** The current v1.1 checklist has 7 items (starter file presence, ≤300 word count, safety rule in starter, folder/SKILL.md format, minimum file count, "Try this now" prompts, CI passes). v1.2 adds three new required artifacts that are absent from the checklist:
  - (8) `writing-profile.md` template section present in preset's `context/` with non-placeholder content
  - (9) `curated-skills-registry.md` entry follows schema (name, description, source_url, vetting_date, tier, goal_tags) and the PR includes vetting evidence (date tested, source repo health indicators)
  - (10) CLAUDE.md and all 6 starter files are in sync — any wizard flow change must propagate to all 7 files; PRs that modify one must update all
  - (11) Starter file ≤**350** words (was ≤300 in v1.1 checklist)

  CI backstops items 8 and 11 partially (ADR-014 checks template sections; the word-count gap is covered by S2). Items 9 and 10 require human review. **Recommendation:** @dev must update CONTRIBUTING.md with items 8–11 at v1.2 implementation time.

- [ ] **S2 — CI has no word-count enforcement on CLAUDE.md or starter files.** The architecture establishes ≤350 words as the security-relevant word budget (ADR-011): at ≤350 words, the wizard bootstrap cannot embed a long-form malicious instruction chain. This is a real (shallow) defense against verbose prompt injection payloads. However, no CI job validates it. The current `claude-md-safety-rule-check` only verifies safety rule presence, not file size. A PR could submit a 2,000-word CLAUDE.md that passes all CI checks.

  Attack scenario: A community PR replaces CLAUDE.md with a 1,500-word instruction chain that passes safety rule check (by including the phrase), adds adversarial goal-detection logic that routes users matching certain profiles to a malicious workspace, and passes all other CI checks (markdown lint, link check). No existing job catches this.

  **Recommendation:** Add a `claude-md-word-count-check` CI job that verifies `CLAUDE.md` ≤ 400 words (upper safety bound). Optionally extend to all 6 starter files. Implementation: `wc -w CLAUDE.md | awk '{if($1 > 400) { print "CLAUDE.md exceeds 400 words: "$1; exit 1 }}'`. This closes the enforcement gap for S2 and is a direct CI-enforcement of ADR-011's security property.

- [ ] **S3 — curated-skills-registry.md source_url has no integrity validation.** The registry (ADR-012) introduces a new trust surface: each entry's `source_url` field is an external pointer. CONTRIBUTING.md requires human vetting of registry PRs, but there is no CI enforcement of URL format, no hash pinning (a URL can change content after vetting), and no mechanism to distinguish a legitimate community skill URL from a URL pointing to a malicious skill that was added in a typosquatting repo.

  Specific risks:
  - **URL rotation attack:** A PR adds a legitimate skill at `github.com/legitimateorg/skill`. After merge, the repo owner renames or replaces the skill content with a malicious SKILL.md. The registry entry still passes all checks (URL still valid, vetting_date is in the past). Users directed to that URL install the now-malicious skill.
  - **Typosquatting:** A PR adds a registry entry for `github.com/anthropics-skills/flashcard-gen` (note: `anthropics-skills` not `anthropics`). The CI link-checker validates the URL resolves — but this is a typosquat of the official Anthropic org.
  - **source_url: builtin fiction (see S7):** A PR claims `source_url: builtin` for a non-Anthropic skill. No CI distinguishes this.

  **Recommendation (v1.2 scope):** (a) Add a CI step that validates `source_url` in `curated-skills-registry.md` matches one of the approved patterns: `builtin`, `https://github.com/` (require HTTPS, block `http://`). This catches the most obvious evasions. (b) Add CONTRIBUTING.md guidance that registry entries must pin to a specific commit SHA in the URL (e.g., `https://github.com/org/repo/blob/<sha>/SKILL.md`), not just a branch URL. This mitigates the URL rotation attack. (c) The `vetting_date` field should be treated as the date the specific SHA was vetted — CONTRIBUTING.md should document this clearly.

  Note: Full automated integrity pinning is v1.3 scope per the spec. The v1.2 recommendation is the minimum: HTTPS-only URL validation in CI, and SHA-pinning guidance in CONTRIBUTING.md.

- [ ] **S4 — CLAUDE.md blast radius escalation requires explicit PR ceremony guidance.** In v1.1, CLAUDE.md was a secondary surface. In v1.2 (ADR-010), CLAUDE.md becomes the universal Layer 1a trigger — auto-loaded for any user who opens the repo folder in Cowork, with no user action required. The blast radius of a malicious CLAUDE.md commit is now the entire user population of the repo, not just users of a specific preset.

  Current controls:
  - CI safety rule check (verifies safety rule text is present)
  - CI word-count check (proposed in S2 — not yet present)
  - Standard PR review process

  Gap: CLAUDE.md has no elevated merge protection relative to other repo files. A social engineering attack (a convincing "wizard improvement" PR that passes CI) reaches all users automatically.

  **Recommendation:** (a) Add a CONTRIBUTING.md note that changes to `CLAUDE.md` require maintainer review and are treated as high-impact changes — equivalent to a security-relevant patch. (b) The CONTRIBUTING.md PR process should add: "PRs modifying `CLAUDE.md` must update all 6 `presets/*/project-instructions-starter.txt` files to match (and vice versa)." This enforces the sync requirement from ADR-010 and also makes it harder to slip a targeted change to only CLAUDE.md without touching the other 6 files. (c) Optionally, add a CI sync check: compute a content signature of the wizard bootstrap block in CLAUDE.md vs. each starter file and fail if they diverge. (This is the `combined-path: eligible` escalation path if the architect decides to add it.)

---

### INFO

- **S5 — Tier 2 keyword scan is best-effort; "I understand" confirmation may be insufficient for non-technical users.** ADR-012 documents this limitation explicitly: "The keyword scan is a heuristic performed by reviewing SKILL.md text. It is NOT sandbox execution." The ten flagged keywords (`exec`, `subprocess`, `curl`, `wget`, `$HOME`, `$PATH`, `rm`, `delete`, `os.system`, `eval`) cover obvious patterns but not obfuscated variants. A skill that uses Unicode homoglyphs, base64-encoded shell commands, or multi-hop references (e.g., "fetch the file at https://..." which itself contains the dangerous instruction) would pass the scan.

  For Alex and Maria personas (non-technical), the WARNING + "I understand" flow may not communicate adequate risk. A user who has just been guided through a helpful wizard may click "I understand" as a formality. The opt-in barrier is the primary protection — most users never see Tier 2 — but for those who do, the risk communication needs to be calibrated to the persona.

  This is INFO because: (a) Tier 2 is explicitly opt-in and non-default; (b) the limitation is documented in the architecture; (c) fully automated sandbox execution is deferred to v1.3 as a non-trivial engineering task. No action required at v1.2 beyond the existing documentation. Recommend the wizard framing for Tier 2 include: "These skills are not verified by us. Even if the keyword scan passes, review the full skill file before installing."

- **S6 — WIZARD.md Tier 2 search list has no CI enforcement.** The Tier 2 discovery path (ADR-012) hardcodes four source repos in WIZARD.md: `anthropics/skills`, `travisvn/awesome-claude-skills`, `VoltAgent/awesome-agent-skills`, `EAIconsulting/cowork-skills-library`. These are trusted sources chosen by maintainers. A malicious PR could add adversarial repos to this list, directing users who opt into Tier 2 toward a targeted GitHub org.

  Current protection: WIZARD.md is documentation-only (not a runtime path for the wizard bootstrap), but the Tier 2 instructions in WIZARD.md are LLM-read during the skill discovery phase via `/setup-wizard` invocation. A changed list would affect Tier 2 users.

  Mitigation: WIZARD.md is in the standard PR review flow. The CONTRIBUTING.md PR checklist (once updated per S1) should add "WIZARD.md Tier 2 source list not modified without maintainer approval." Low-probability attack for a public repo with transparent PR history. INFO-level only.

- **S7 — `source_url: builtin` is trust-by-convention only.** The sentinel value `builtin` in `curated-skills-registry.md` identifies Anthropic official skills (Tier 1, zero-config). There is no CI rule that validates `builtin` only appears for entries from Anthropic. A community PR claiming `source_url: builtin` for a third-party skill would be treated by the wizard as Anthropic-official. Current protection: human review. This is the same category as S3 — S3 covers URL rotation and typosquatting; S7 covers the specific `builtin` sentinel misuse. Recommend CONTRIBUTING.md explicitly state: "`source_url: builtin` is reserved for Anthropic official pre-built skills. Community skills must use a full GitHub URL."

- **S8 — Writing profile E6 design is sound but has no implementation enforcement.** ADR-013 specifies: "The raw sample text is NOT stored in writing-profile.md — only extracted patterns are written." This correctly addresses E6 (user pastes sensitive content in writing sample). The security property is: user PII or confidential content in a writing sample is never committed to the file system. However, there is no CI job that enforces this behavior — it is entirely dependent on correct LLM behavior (the wizard must extract and discard, not copy-paste).

  Risk: If the wizard implementation writes the raw sample to `writing-profile.md` (e.g., as a comment or in a "Sample:" field), and the user later commits their workspace to a public fork, sensitive content would be exposed.

  **Recommendation for @dev:** The writing profile template (`templates/writing-profile-template.md`) must not include a "Sample:" or "Raw sample:" field. The template should only have fields for extracted patterns. The wizard instruction in WIZARD.md and starter files should explicitly state: "Extract 2–3 observable patterns. Do NOT copy or quote the sample text in the profile."

---

### OWASP Top 10 Assessment (Adapted for Static Template Repository + LLM System Context)

| Category | Status | Notes |
|----------|--------|-------|
| A01:2021 — Broken Access Control | N/A | No access control system. Public repo. Template files only. No user data, no privileged operations. |
| A02:2021 — Cryptographic Failures | N/A | No secrets. No credentials. No encryption operations. curated-skills-registry.md source_url integrity gap (S3) is trust/integrity, not cryptographic. |
| A03:2021 — Injection | WATCHED | Prompt injection surface has expanded in v1.2. CLAUDE.md is now system context for all repo-folder users (LLM01 — see below). Community preset PRs remain the primary indirect injection vector. S1–S4 recommendations reduce the attack surface. |
| A04:2021 — Insecure Design | PASS WITH S1-S4 | Defense-in-depth architecture is strengthened in v1.2 (5 layers). The identified WARNINGs are gaps in the enforcement layers, not architectural failures. Core design is sound. |
| A05:2021 — Authentication Failures | N/A | No authentication system. No user accounts. |
| A06:2021 — Sensitive Data Exposure | WATCHED | Writing profile introduces a new PII-adjacent surface. E6 design is sound (S8). User's `writing-profile.md` is local only — no server-side storage, no telemetry. Risk is user-action exposure (committing workspace to public fork). |
| A07:2021 — Identification & Authentication Failures | N/A | No auth. No sessions. |
| A08:2021 — Software & Data Integrity Failures | WATCHED | S3 covers registry source_url integrity. S2 covers wizard bootstrap integrity (word count). SHA-pinned CI actions (from v1.1) remain sound. v1.2 introduces curated-skills-registry.md as a new integrity surface without SHA pinning. |
| A09:2021 — Security Logging & Monitoring Failures | N/A | No runtime system. Git history is audit trail. CHANGELOG.md per release. |
| A10:2021 — Server-Side Request Forgery | N/A | No server. No HTTP requests during wizard execution. Tier 2 skill discovery is user-manual (paste-and-review), not automated HTTP. |

### OWASP LLM Top 10 Assessment

| Category | Status | Notes |
|----------|--------|-------|
| LLM01 — Prompt Injection | ELEVATED | v1.2 blast radius increase: CLAUDE.md is now auto-loaded as system context for any user opening the repo folder. A malicious CLAUDE.md commit is a direct prompt injection targeting all users. S2 (word-count CI) and S4 (blast radius guidance) are the recommended mitigations. No external runtime data injection — the injection vector is still community PR content, not live data. |
| LLM02 — Insecure Output Handling | LOW RISK | Wizard output is local files written to the user's machine. No programmatic downstream consumption. writing-profile.md output is new in v1.2 — S8 flags the raw-sample-storage risk. |
| LLM06 — Sensitive Information Disclosure | LOW RISK ELEVATED BY E6 | Writing profile introduces a new pattern: user may paste sensitive content (E6). ADR-013 correctly addresses this architecturally (extract patterns only). Implementation must faithfully execute this — S8 covers the implementation guidance gap. |

### Additional v1.2 Surface Assessment

| Surface | Status | Notes |
|---------|--------|-------|
| CLAUDE.md (new universal entry point) | WATCHED | S2 and S4 cover. CI enforces safety rule; word-count enforcement is missing (S2). Blast radius is full user population (S4). Existing `claude-md-safety-rule-check` job is correctly present. |
| curated-skills-registry.md | WATCHED | S3 and S7 cover. New trust surface with no integrity mechanism beyond human review. Minimum v1.2 remediation: HTTPS-only URL validation in CI + SHA-pin guidance in CONTRIBUTING.md. |
| Tier 1 skill recommendations (from registry) | PASS | Wizard reads local registry file — no network calls. Goal-tag filtering is a passive content match. No injection vector in the filter logic. |
| Tier 2 opt-in discovery | WATCHED | S5 and S6 cover. Explicit opt-in gating is sound. Keyword scan limitations are documented. The "I understand" confirmation flow is the right UX pattern but may be insufficient for the target persona. |
| Writing profile step (universal) | PASS WITH S8 | Architecture is sound. Patterns-only storage addresses E6. Template design must not include raw sample fields (S8). |
| 7-file sync problem (CLAUDE.md + 6 starter files) | WATCHED | S1 and S4 cover. Sync is a maintenance burden and an attack surface — a targeted PR could modify only CLAUDE.md. No CI sync check exists. Recommend CONTRIBUTING.md guidance at minimum; CI sync check as stretch. |
| CI job count (10 jobs, all SHA-pinned) | PASS | All 10 planned CI jobs from ADR-014 are documented. SHA pinning from v1.1 is confirmed present (verified in current quality.yml). New writing-profile-template-check job must be added at implementation time. |
| Safety architecture (5-layer defense-in-depth) | PASS | Template → preset → starter file → CLAUDE.md → CI is a sound 5-layer model. The existing CI jobs (safety-rule-check, starter-safety-rule-check, claude-md-safety-rule-check) enforce the critical safety rule across all three runtime surfaces. |

---

### Summary

The v1.2 architecture is a thoughtful evolution of a security-conscious design. The hybrid Tier 1/Tier 2 skill model directly addresses confirmed security research (13.4% critical risk rate in community skills), and the decision to gate Tier 2 behind explicit opt-in is the correct default. The writing profile architecture handles E6 (sensitive writing samples) correctly by design. The 5-layer safety rule defense-in-depth is sound and operationally verified from v1.1.

**The primary security concern in v1.2 is the blast radius escalation of CLAUDE.md.** Elevating CLAUDE.md from a secondary surface to the universal Layer 1a entry point (ADR-010) is architecturally correct but shifts the stakes: a single malicious file at repo root now affects all users, not just preset-specific users. The current enforcement mechanism (safety-rule CI check only, no word-count check) is insufficient for this elevated blast radius. S2 and S4 together address this gap.

**The second concern is the curated-skills-registry.md integrity surface.** S3 is the most technically substantive new finding. The registry is a trust anchor for skill recommendations — if it can be poisoned (by URL rotation, typosquatting, or `builtin` sentinel abuse), the Tier 1 curated path's security guarantee is undermined. The v1.2 minimum remediation (HTTPS-only CI validation + SHA-pin guidance) is achievable without v1.3 features.

**CONTRIBUTING.md staleness (S1) is the highest-leverage fix.** The checklist is the human control point for all community PRs. Updating it before v1.2 launches ensures community contributors operate within the correct security model from day one.

No CRITICAL findings. The four WARNINGs are all addressable at Phase 4 implementation time. The pipeline is not blocked.

**Decision: PASS WITH WARNINGS.**

---

## Phase 2 History

### v1.0 Review (2026-04-15T06:45:00Z)
See original findings above (S1–S6). All v1.0 WARNINGs resolved in Phase 4. Full v1.0 review archived in git history.

### v1.1 Review (2026-04-15T22:00:00Z)
PASS WITH WARNINGS. S1 (CONTRIBUTING.md v1.1 update), S2 (CI .txt glob fix). Both resolved in Phase 4. Full v1.1 review archived in git history.

### v1.2 Review (this document — 2026-04-17T13:00:00Z)
4 WARNINGs (S1–S4), 4 INFOs (S5–S8). No CRITICALs.
