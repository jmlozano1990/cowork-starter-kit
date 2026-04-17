# Assumptions Register — Claude Cowork Config

## About This Document

Every assumption in the product spec is catalogued here with:
- **Confidence:** [CONFIRMED], [ESTIMATED], or [UNTESTED]
- **Risk:** What breaks if this assumption is wrong
- **Validation path:** How to verify before or after shipping

Assumptions are grouped by domain. Review this register before Phase 1 (architecture) and before any preset ships.

Last updated: v1.2 — 2026-04-17T00:00:00Z

---

## A — Cowork Platform Assumptions

### A1 — Project custom instructions accepts ≤350 words
**Confidence:** [UNTESTED — CRITICAL for v1.2]
**Assumption:** Cowork's Project custom instructions field accepts multi-paragraph plain-text up to approximately 400 words without truncation, reformatting, or rendering issues. v1.2 targets ≤350 words (increased from v1.1's ≤300 to support dynamic wizard branching).
**v1.2 update:** Dynamic wizard branches (suggestion flow, writing profile step) add ~30–50 words to each starter file. The ≤350 word target keeps files within the ~400-word assumption limit. If actual field limit is proven <300 words, revert to split architecture: state machine check in instructions (≤150 words), full wizard branches in WIZARD.md referenced by pointer.
**Risk:** If the field has a shorter character limit, the dynamic wizard is truncated silently. Users see a partial wizard with no indication something is wrong. This is the highest-impact technical risk in v1.2.
**Validation path:** Before Phase 4: manually paste a 350-word block into Cowork Project Settings > Custom Instructions. Verify saved text matches input exactly. Test at 300, 350, and 400 words. Document the actual limit.
**Escalation:** If limit is <300 words: redesign starter file to ~150-word state machine check + pointer to WIZARD.md for interview script.

### A2 — SKILL.md files in .claude/skills/ are loaded by Cowork
**Confidence:** [RESOLVED — SUPERSEDED by v1.1]
**Status:** Closed. Confirmed that Cowork does NOT auto-discover SKILL.md files from filesystem. Static skill file delivery delivers zero automatic value in Cowork.
**Resolution:** Skills delivered via: (1) `/skill-creator` wizard conversation (primary), (2) Anthropic pre-built skills (zero-config defaults), (3) ZIP upload via Settings > Customize > Skills > '+' (tertiary).
**No further action required.**

### A3 — Projects feature (March 2026) is stable for documentation guidance
**Confidence:** [ESTIMATED]
**Assumption:** Cowork's Projects feature (launched March 20, 2026) is stable enough for wizard guidance.
**Risk:** Low — GA product confirmed.
**Validation path:** Walk through Projects creation flow to confirm: project-scoped instructions persist, memory is scoped per-project, folder assignment works as documented.

### A4 — Cowork connectors do not require developer credentials
**Confidence:** [ESTIMATED]
**Assumption:** Authorizing Cowork connectors (Google Drive, Gmail, Slack) is a pure OAuth flow — no API keys or developer accounts required.
**Risk:** If any connector requires technical setup, our connector checklist misleads non-technical users.
**Validation path:** Walk through connector authorization for Google Drive and Gmail as a non-developer. Document exact flow.

### A5 — Cowork respects "confirm before delete" in Project custom instructions
**Confidence:** [ESTIMATED]
**Assumption:** Including the safety rule in Project custom instructions causes Cowork to prompt before any deletion.
**Risk:** HIGH. If this instruction is ignored, users remain exposed to the documented 11GB deletion scenario. Safety-critical assumption.
**Validation path:** Set up test workspace with safety instruction. Ask Cowork to "clean up" a folder. Verify Cowork prompts before deleting. Test with ≥3 deletion phrasings.
**Escalation:** If assumption fails, add prominent WARNING to README and SETUP-CHECKLIST.md.

### A6 — No public Cowork configuration API exists
**Confidence:** [ESTIMATED — unchanged]
**Assumption:** No programmatic API for configuring Cowork. All configuration requires manual UI interaction.
**Risk:** Low — if API exists, our approach still works; API would be an upgrade for v2.
**Validation path:** Review Anthropic developer docs and Claude Help Center for any Cowork configuration API.

### A13 — Cowork Project memory does not auto-ingest context files
**Confidence:** [UNTESTED — unchanged]
**Assumption:** Cowork does not auto-ingest `about-me.md`, `cowork-profile.md`, or `writing-profile.md`. Users must manually seed memory.
**Risk:** If Cowork does auto-ingest, our manual memory-seeding guidance is redundant (harmless but unnecessary).
**Validation path:** Create Cowork Project with context files in project folder. Start fresh session and ask "What do you know about me?" without prompting. Document behavior.

### A14 — `/skill-creator` is a stable built-in Cowork command
**Confidence:** [ESTIMATED — carries from v1.1]
**Assumption:** `/skill-creator` is stable and produces valid `folder/SKILL.md` output. User-validated in one session (2026-04-15).
**Risk:** If deprecated or renamed, skill validation falls back to confirming file exists. Fallback path is a mandatory AC in F5.
**Validation path:** Before Phase 4: verify `/skill-creator` still exists in Cowork and produces expected output format.

### A15 — AskUserQuestion nudge causes Cowork to render clickable button UI
**Confidence:** [UNTESTED — carries from v1.1]
**Assumption:** The AskUserQuestion nudge MAY cause Cowork to render button UI.
**Risk:** Best-effort heuristic. No AC may require button rendering. Numbered list is the guaranteed fallback.
**Validation path:** Test by pasting starter file with nudge into fresh Cowork project. Observe whether buttons appear. Either outcome is acceptable.

---

## B — User Behavior Assumptions

### B1 — Non-technical users will follow a numbered checklist without abandoning
**Confidence:** [ESTIMATED — unchanged]
**Assumption:** A non-technical user can follow the SETUP-CHECKLIST and complete setup in under 18 minutes (revised from 15 min to account for writing profile step).
**Risk:** Checklist drop-off if any step is ambiguous.
**Validation path:** Usability test with 3 non-technical users. Time from README open to first personalized session. Note every pause.

### B2 — Users are willing to complete a ≤12-step interview
**Confidence:** [ESTIMATED — REVISED for v1.2]
**v1.1 state:** 11-step interview with fast-track at Step 5.
**v1.2 change:** Writing profile adds 1 step → 12 steps. Fast-track pause moves to after Step 6.
**Alex's documented tolerance:** Alex has documented tolerance of "Minimal (2–3 max)." The 12-step plan directly contradicts this; fast-track mitigates. v1.2 fast-track pause is at Step 6 (after writing profile, before folder structure and skills).
**Mitigation:** Fast-track at Step 6 is the key mitigation. Alex can exit with a working workspace and writing profile (steps 1–6) without completing folder structure and skill discovery.
**Risk:** If >30% of users exit at fast-track without reaching skills steps, skill adoption will be low.
**Validation path:** Smoke test: measure % of test users who reach Step 9+ (first skill activation). If >40% fast-track and don't return for skill setup, consider making skills step shorter or moving it earlier.

### B3 — The 6 preset categories cover ≥80% of target user goals
**Confidence:** [ESTIMATED — revised]
**v1.2 update:** Dynamic wizard now handles novel goals (Career Manager, Home Renovation, Language Learning). The 80% coverage assumption is less critical — the wizard builds custom workspaces for the remaining 20%.
**Risk:** Reduced from v1.1. If presets are narrow, wizard's novel-goal branch handles the gap.
**Validation path:** Track novel-goal branches in test sessions and via GitHub issue analysis post-launch.

### B4 — Users have Cowork installed (or will install before using wizard)
**Confidence:** [ESTIMATED — unchanged]
**Assumption:** Target audience is "just installed Cowork, don't know what to do next." Wizard does not install Cowork.
**Validation path:** Consider adding "Have you installed Claude Cowork? Y/N" as wizard question 0.

### B5 — Users are willing to answer writing profile questions in non-writing workspaces [NEW v1.2]
**Confidence:** [UNTESTED — MEDIUM risk]
**Assumption:** Users setting up a Study or PM workspace will answer 3–4 writing style questions even though they don't think of themselves as "writers." They understand that Cowork produces written output for all tasks.
**Risk:** Users may skip the writing profile step ("I'm not a writer — skip"), resulting in `writing-profile.md` with only default values. The profile is still generated (not empty) but is less personalized.
**Mitigation:** Wizard framing: "Even in a study/research workspace, I'll be writing summaries and explanations for you — this helps me match your style." The profile generates with substantive defaults even if questions are skipped.
**Validation path:** In smoke test: for non-Writing presets, observe whether test users complete writing profile step or attempt to skip. If >40% skip, revise framing.

---

## C — Delivery & Community Assumptions

### C1 — GitHub + LinkedIn is sufficient for initial distribution
**Confidence:** [ESTIMATED — unchanged]
**Assumption:** LinkedIn post + quality GitHub README generates ≥200 stars within 30 days.
**Validation path:** Track referral source for first 100 GitHub visitors via UTM parameters.

### C2 — Community contributors will add skills and presets
**Confidence:** [UNTESTED — revised for v1.2]
**v1.2 change:** Community contribution now includes two paths: (a) new preset PRs (same as v1.1), (b) skill entries to `curated-skills-registry.md`. The registry path is lower-friction than a full preset PR.
**Assumption:** ≥10 community skill entries will be submitted to `curated-skills-registry.md` within 60 days.
**Risk:** Registry remains sparse — users see fewer curated skill suggestions for novel goals.
**Validation path:** Track PRs against `curated-skills-registry.md` in first 60 days. If contributions are absent, add a "contribute a skill" workflow to CONTRIBUTING.md with a template.

### C3 — Users will use ZIP download, not git clone
**Confidence:** [ESTIMATED — unchanged]
**Assumption:** Non-technical users use GitHub's "Download ZIP." Wizard works without git installed.
**Validation path:** Download repo as ZIP and walk through full wizard flow. Verify no step requires git.

---

## D — Market/Timing Assumptions

### D1 — Cowork's non-technical user base is large enough
**Confidence:** [ESTIMATED — unchanged]
**Assumption:** Claude Pro/Max plans have a meaningful non-technical knowledge worker user base actively trying to use Cowork.
**Validation path:** Track referral sources from Claude subreddits and knowledge worker communities vs. developer communities.

### D2 — No competing product provides this wizard experience for Cowork specifically
**Confidence:** [ESTIMATED — carries from v1.1]
**v1.2 update:** Claude Code skill ecosystem has grown (22,000+ star repos, skills.sh marketplace, Anthropic official skills registry). All of this targets Claude Code users (developers), NOT Cowork users (knowledge workers). Gap remains unserved.
**Risk:** Anthropic ships native Cowork onboarding wizard. Mitigated by: pivot to "advanced configuration" and "preset expansion beyond defaults."
**Validation path:** Search GitHub and Product Hunt monthly for Cowork-specific onboarding tools.

### D3 — Skill security risk justifies curated-first approach [NEW v1.2]
**Confidence:** [CONFIRMED]
**Evidence:** Repello AI research (2026): 13.4% of community skills contain critical security issues. Snyk ToxicSkills research (2026): prompt injection in 36% of tested skills, 1,467 malicious payloads found. Cato Networks documented weaponized Claude skills using ransomware delivery.
**Assumption:** A curated Tier 1 default is required, not optional. Tier 2 opt-in with explicit warnings is the appropriate middle ground.
**Risk:** If we ship Tier 2 as default, we expose non-technical users (Alex, Maria) to 13.4% critical risk rate with no prior safety context. This is unacceptable.
**Validation path:** Already confirmed by security research. No additional validation required — this is a design constraint, not a hypothesis.

### D4 — `curated-skills-registry.md` is maintainable as a static file [NEW v1.2]
**Confidence:** [UNTESTED — LOW risk]
**Assumption:** A manually maintained markdown registry is sufficient for v1.2. Skills remain installable at their documented source URLs without a live API or package manager.
**Risk:** Skills at external URLs become unavailable (repo deleted, renamed, rate-limited). Registry entries become stale.
**Mitigation:** Vetting date in each registry entry. CONTRIBUTING.md instructs contributors to verify URL accessibility before submitting.
**Validation path:** After 60 days post-launch, audit registry entries for broken URLs. If >15% are stale, evaluate adding an automated URL health check to CI.
