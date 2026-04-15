# Assumptions Register — Claude Cowork Config

## About This Document

Every assumption in the product spec is catalogued here with:
- **Confidence:** [CONFIRMED], [ESTIMATED], or [UNTESTED]
- **Risk:** What breaks if this assumption is wrong
- **Validation path:** How to verify before or after shipping

Assumptions are grouped by domain. Review this register before Phase 1 (architecture) and before any preset ships.

---

## A — Cowork Platform Assumptions

### A1 — Project custom instructions accepts plain-text blocks ~400 words
**Confidence:** [UNTESTED]
**Assumption:** Cowork's Project custom instructions field accepts multi-paragraph plain-text up to approximately 400 words without truncation, reformatting, or rendering issues.
**Risk:** If the field has a shorter character limit, generated instructions will be cut off silently — users will get partial configuration with no indication something is wrong.
**Validation path:** Manually test by pasting a 400-word block into Cowork's Project custom instructions field. Check if saved text matches input exactly. Verify it persists across sessions.

### A2 — SKILL.md files in .claude/skills/ are loaded by Cowork (not just Claude Code)
**Confidence:** [RESOLVED — SUPERSEDED]
**Status:** Closed. Assumption invalidated and architecture updated accordingly.
**Finding:** Confirmed that Cowork does NOT auto-discover SKILL.md files from a `.claude/skills/` filesystem directory the way Claude Code does. Static filesystem skill delivery delivers zero automatic value in Cowork.
**Resolution:** F5 architecture pivots to:
1. **Skill-creator (primary):** Users build 2–3 personalized skills live via Cowork's built-in skill-creator — conversational, goal-specific, no file management.
2. **Anthropic pre-built skills (secondary):** Official pre-built document skills (pptx, xlsx, docx, pdf) as zero-configuration day-one defaults.
3. **ZIP upload (tertiary):** SETUP-CHECKLIST.md documents the ZIP upload path (Settings > Customize > Skills > '+') for users who want to install packaged skills.
**Risk eliminated.** The "cosmetic files" failure mode is removed. Skills are now delivered through Cowork's supported configuration surfaces.
**No further validation required.** Static `.claude/skills/` preset files and the `skills-as-prompts.md` fallback are removed from scope.

### A3 — Projects feature (March 2026) is stable for documentation guidance
**Confidence:** [ESTIMATED]
**Assumption:** Cowork's Projects feature (launched March 20, 2026) is stable enough for us to write setup guidance around it. Non-enterprise users can create and manage projects with persistent instructions and memory.
**Risk:** If Projects is still rough or changes behavior in a patch, our configuration guidance becomes misleading. Low risk — GA product with confirmed launch.
**Validation path:** Manually walk through the Projects creation flow. Confirm: (1) project-scoped instructions persist, (2) memory is scoped per-project, (3) folder assignment works as documented.

### A4 — Cowork connectors do not require developer credentials to authorize
**Confidence:** [ESTIMATED]
**Assumption:** Authorizing Cowork connectors (Google Drive, Gmail, Slack) is a pure OAuth flow in the native Cowork UI — no API keys, developer accounts, or terminal commands required from the user.
**Risk:** If any connector requires technical setup (e.g., creating a Google Cloud project), our connector checklist will be misleading — we'd be pointing non-technical users at steps they can't complete.
**Validation path:** Walk through connector authorization for Google Drive and Gmail in Cowork as a non-developer. Document the exact flow. Update connector checklist accordingly.

### A5 — Cowork respects a "confirm before delete" instruction in Project custom instructions
**Confidence:** [ESTIMATED]
**Assumption:** Including "Always ask for explicit confirmation before deleting any file" in Project custom instructions causes Cowork to prompt the user before any deletion, every time.
**Risk:** High. If this instruction is ignored or inconsistently applied, users remain exposed to the documented 11GB deletion scenario. This is a safety-critical assumption.
**Validation path:** Set up a test workspace with the safety instruction active. Ask Cowork to "clean up" a folder containing test files. Verify Cowork prompts before deleting. Test with at least 3 phrasings of deletion requests ("clean up," "remove duplicates," "delete old files").
**Escalation:** If this assumption fails, add a prominent warning to the README and SETUP-CHECKLIST.md that the safety rule is best-effort and users should always back up before running cleanup tasks.

### A6 — No public Cowork configuration API exists at v1 launch
**Confidence:** [UNTESTED]
**Assumption:** There is no programmatic API for configuring Cowork (no REST endpoint, no CLI, no SDK). All configuration requires manual UI interaction by the user.
**Risk:** If a configuration API exists, we're underbuilding — we could automate setup instead of generating checklists. If no API exists (likely), our checklist approach is correct.
**Validation path:** Review Anthropic developer docs and Claude Help Center for any Cowork configuration API. Check Claude Code docs for any shared configuration protocol.
**Impact:** Low — our approach works either way. If API exists, it's an upgrade opportunity for v2.

### A13 — Cowork Project memory does not auto-ingest context files
**Confidence:** [UNTESTED]
**Assumption:** Cowork Project memory does not auto-ingest context files (`about-me.md`, `cowork-profile.md`). Users must manually seed memory by telling Cowork their role and preferences in a session.
**Risk:** If Cowork does auto-ingest context files from the project folder, the manual memory-seeding step in WIZARD.md becomes redundant (harmless but unnecessary guidance).
**Validation path:** Create a Cowork Project with `about-me.md` in the project folder. Start a fresh session and ask Cowork "What do you know about me?" without any manual prompting. If it surfaces `about-me.md` content unprompted, update the wizard to reflect auto-ingestion.

---

## B — User Behavior Assumptions

### B1 — Non-technical users will follow a numbered checklist without abandoning
**Confidence:** [ESTIMATED]
**Assumption:** A non-technical user who downloads the repo can follow an 8-step numbered checklist and complete Cowork configuration in under 15 minutes without giving up.
**Risk:** If the checklist is too long or contains any ambiguous step, drop-off rate spikes. The viral Reddit complaint about complexity suggests a meaningful percentage of Cowork beginners abandon on first friction.
**Validation path:** Usability test with 3 non-technical users. Time them from README open to first personalized Cowork session. Note every step where they pause, re-read, or ask for help.

### B2 — Users are willing to answer 3–5 setup questions before getting value
**Confidence:** [ESTIMATED]
**Assumption:** Beginners will engage with the 3–5 wizard questions without frustration. They are willing to invest 2–3 minutes of input to get a personalized output.
**Risk:** If users skip all questions (choosing defaults) or abandon mid-wizard, the personalization value is lost. However, this is acceptable — the fallback is the generic preset, which is still useful.
**Validation path:** Observe wizard completion rate in test sessions. If >30% of users skip all questions, simplify to 2 questions max or make the default path more prominent.

### B3 — The 6 preset categories cover ≥80% of target user goals
**Confidence:** [ESTIMATED]
**Assumption:** Study, Research, Writing, Project Management, Creative, and Business/Admin cover the most common knowledge worker use cases for Cowork. Fewer than 20% of users have a goal that doesn't fit any preset.
**Risk:** If the categories are too narrow, users see nothing that fits and abandon. If too broad, each preset is too generic to add value.
**Validation path:** GitHub issue analysis after launch — track how often users open issues titled "no preset for my use case" or similar. If >20% of issues are preset requests not covered by v1, prioritize v2 preset expansion.

### B4 — Users have a designated Cowork folder already set up (or will create one during onboarding)
**Confidence:** [ESTIMATED]
**Assumption:** Target users either already have Cowork installed with a designated workspace folder, or they are willing to create one during the wizard flow. The wizard does not need to install Cowork for them.
**Risk:** If users arrive without Cowork installed, the wizard has no value. We assume the entry audience is "just installed Cowork, don't know what to do next."
**Validation path:** Add "Have you installed Claude Cowork? Y/N" as wizard question 0 (before goal selection). If N, show a "Get Cowork first" message with the Anthropic link and exit gracefully.

---

## C — Delivery & Community Assumptions

### C1 — GitHub + LinkedIn is sufficient for initial distribution
**Confidence:** [ESTIMATED]
**Assumption:** A well-positioned LinkedIn post targeting knowledge workers + a high-quality GitHub README will generate enough initial traction (≥200 stars, ≥100 wizard completions) to validate the concept without paid distribution.
**Risk:** LinkedIn algorithm may not surface the post to the right audience. GitHub discoverability is low for non-developer tools — knowledge workers don't browse GitHub.
**Validation path:** Track referral source for first 100 GitHub visitors via UTM parameters in the LinkedIn post URL. If <30% of traffic is from LinkedIn, diversify to Reddit (r/ClaudeAI, r/productivity) and Substack communities.

### C2 — Community contributors will add presets without significant guidance
**Confidence:** [UNTESTED]
**Assumption:** The open-source community will submit new preset PRs if CONTRIBUTING.md is clear and the preset format is simple enough.
**Risk:** Preset contributions may be low-quality (incomplete skill files, wrong folder structure) or absent entirely.
**Validation path:** First 60 days post-launch: monitor PR quality. If contributions are absent or low-quality, add a "preset template" generator script and a PR checklist.

### C3 — Users will not need to clone the repo — ZIP download is sufficient
**Confidence:** [ESTIMATED]
**Assumption:** Non-technical users will use GitHub's "Download ZIP" option rather than git clone. The repo structure must work when downloaded as a ZIP with no git history.
**Risk:** If any wizard step depends on git (e.g., git submodules, git history for versioning), the ZIP experience breaks.
**Validation path:** Download repo as ZIP and walk through full wizard flow. Verify no step requires git to be installed or the repo to be a git repo.

---

## D — Market/Timing Assumptions

### D1 — Cowork's non-technical user base is large enough to sustain a community tool
**Confidence:** [ESTIMATED]
**Assumption:** Claude Pro/Max plans (the plans that include Cowork) have a meaningful non-technical knowledge worker user base — not just developers — who are actively trying to use Cowork for study, research, and writing.
**Risk:** If the current Cowork user base is predominantly developers (who configure their own setups), there's no underserved audience for this tool.
**Validation path:** Track GitHub referrals from Claude-related subreddits and knowledge worker communities vs. developer communities. If >70% of traffic is from developer sources, pivot preset focus to "non-developer team workflows" instead of individual student/researcher personas.

### D2 — No competing product provides this exact wizard experience for Cowork specifically
**Confidence:** [ESTIMATED]
**Assumption:** No existing product (community repo, Anthropic-official, or third-party) provides a goal-driven configuration wizard specifically for Claude Cowork.
**Risk:** If Anthropic ships a native onboarding wizard in a Cowork update, this repo becomes redundant.
**Validation path:** Search GitHub, Product Hunt, and the Claude Help Center monthly. If Anthropic ships native onboarding, pivot repo to "advanced configuration" and "preset expansion beyond defaults."
**Note:** Claude Cowork onboard (aiwithremy) focuses on Claude Code, not Cowork — confirmed gap as of April 2026.
