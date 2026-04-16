# Product Spec — Claude Cowork Config (v1.1)

## Problem

Claude Cowork launched in January 2026 as Anthropic's desktop agent for knowledge workers. It gives users powerful capabilities — local file read/write/create/delete, Google Drive/Gmail/Slack connectors, persistent memory, plugins, skills, custom instructions — but the out-of-the-box experience offers zero guidance on how to configure any of it.

**v1.0 root cause failure (2026-04-15):** The v1.0 WIZARD.md was ignored by Cowork's native intent classifier. When users said "set up my workspace," Cowork ran its own built-in setup skill, asked one generic question, and installed a generic productivity plugin. WIZARD.md was never read. The trigger architecture was fundamentally broken.

**v1.1 fix:** Three-layer trigger architecture where the primary path moves wizard logic into `project-instructions-starter.txt` — a file pasted into Cowork Project custom instructions *before* any conversation, making it system context that Cowork's intent classifier cannot intercept.

## Target Users

**Primary: Alex — University Student (20, biochemistry)**
Goal: Use AI to study smarter — research, note-taking, flashcard generation.
Pain: Doesn't know where to start. Generic responses. Doesn't realize Cowork can read PDFs.
Gain: Personalized workspace with proactive skill offers, academic tone, flashcard/synthesis skills.

**Secondary: Maria — Knowledge Worker (35, researcher / writer / PM)**
Goal: AI as a work multiplier. Persistent context, role-appropriate connectors, professional tone.
Pain: Spends time re-explaining context every session.

Full personas: see `docs/personas.md`

## Configuration Surface Note

This wizard configures Cowork **Project custom instructions** (scoped to one Project). It does NOT configure Global Instructions. All references to "instructions" mean Project custom instructions unless explicitly stated.

## Core Features (MVP)

### F1 — Three-Layer Trigger Architecture [REVISED v1.1]

**Root cause fix:** WIZARD.md is not a reliable runtime path — Cowork's intent classifier intercepts "set up"-type phrases before reading project files. v1.1 introduces three layers:

1. **Primary — `project-instructions-starter.txt`:** A short bootstrap file (~200–300 words) the user pastes into Project Settings > Custom Instructions BEFORE starting any conversation. Contains a state machine check (does `cowork-profile.md` exist with real content?) and onboarding interview script. Custom instructions are injected as system context before Cowork's intent classifier runs — this cannot be intercepted.

2. **Secondary — `/setup-wizard` skill:** A proper Cowork skill at `.claude/skills/setup-wizard/SKILL.md` (repo root, not inside any preset). Contains `name:` and `description:` YAML frontmatter. Provides a guaranteed explicit invocation path that bypasses Cowork's intent classifier. Used for first-run when instructions weren't pasted, or to redo setup.

3. **Tertiary — WIZARD.md:** Documentation and script source only. NOT a runtime path. NOT a fallback. Kept for repo-browser context and contributor reference.

**AC [v1.1]:**
- `project-instructions-starter.txt` exists for all 6 presets at `presets/<name>/project-instructions-starter.txt`
- Each starter file is ≤300 words (to stay within Cowork's custom instructions field limit — see A1)
- Each starter file contains a Phase 1 onboarding block (state machine check + full interview script) and a Phase 2 ongoing behavior block (session-start rules, proactive skill triggers, safety rule)
- State machine check: if `cowork-profile.md` does not exist (or contains `[Your name]`), auto-run onboarding; if it exists with real content, greet by name and skip onboarding
- Each starter file includes the AskUserQuestion nudge: "For each wizard question, use AskUserQuestion to present the options as clickable buttons if available. If not available, use the numbered list format."
- `.claude/skills/setup-wizard/SKILL.md` exists at repo root with valid YAML frontmatter (`name: setup-wizard`, `description:` present)
- `/setup-wizard` skill includes reset confirmation: "This will reset your profile and re-run onboarding. Your past sessions are unaffected. Confirm? (Yes / No)"
- WIZARD.md includes a top note clarifying its documentation role: "Users: start with `/setup-wizard` or paste `project-instructions-starter.txt`. This file is the script source, not the entry point."
- SETUP-CHECKLIST.md reorders to: Step 1 = paste `project-instructions-starter.txt`, Step 2 = create project, Step 3 = assign folder — pasting instructions must precede any conversation
- README.md Quick Start lists `/setup-wizard` as the primary call-to-action (Step 3)

### F2 — Deep Interview (11 Steps Per Preset) [REVISED v1.1]

After goal selection, a structured per-preset interview calibrates the workspace. v1.1 deepens from 5 questions to ~11 steps covering knowledge questions, skill activations, tools, and space naming.

**UX rules (all presets, all steps) [from @ux review]:**
- Options use **numbered format (1, 2, 3...)** — not lettered (A, B, C)
- "S) Suggest" appears on knowledge-gap questions only (study method, output format, tools) — NOT on personal preference questions (name, creative constraints)
- Step counter hides denominator until after fast-track decision: show "Step 3" not "Step 3 of 11"
- CTA: **`Your answer:`** on its own line (replaces `→ Type a number.`)
- Multi-select example shows natural variations: `1, 3` or just `1 3`
- "You choose" / "suggest" response: one concrete recommendation + one-sentence reason, then "Sound right?" — does not re-list options
- Free-text tolerance: match intent, state interpretation in one sentence, proceed without re-asking
- Skill options: 3 choices (not 4) — `1. Yes — activate  2. No — skip it  3. Show me more`
- Skill presentation: show personalized example using answers from earlier steps, no description block (example alone conveys value)
- "Show me more" latency: acknowledge immediately: "Generating an example — just a moment..."
- After "you choose" recommendation, re-list option numbers inline before asking "Sound right?"
- Time estimate at fast-track: "a few more minutes" (not an exact number)

**Fast-track at Step 5:** After Step 5, pause: "Your basic workspace is ready. 1) Yes, continue — deeper customization  2) Get started now — run /setup-wizard later"

**Per-preset step sequences:**

**Study (11 steps):**
Step 1: Name (free text) | Step 2: Subject area | Step 3: Academic level (6 options + S) | Step 4: Upcoming deadlines (4 options) | Step 5: Study method (5 options + S) | FAST-TRACK PAUSE | Step 6: File types (multi-select) | Step 7: Output format (4 options + S) | Step 8: Academic integrity agreement | Step 9: Skill — Flashcard Generation (personalized example) | Step 10: Skill — Note-Taking | Step 11: Skill — Research Synthesis | Tools (multi-select) | Space name

**Research (11 steps):**
Step 1: Name | Step 2: Research domain | Step 3: Researcher type (5 options + S) | Step 4: Stage of work (4 options) | Step 5: Source types (multi-select 5) | FAST-TRACK PAUSE | Step 6: Output format (4 options + S) | Step 7: Citation style (5 options + S) | Step 8: Source verification behavior | Step 9: Skill — Literature Review Assistant | Step 10: Skill — Source Analysis | Step 11: Skill — Research Synthesis | Tools (multi-select) | Space name

**Writing (11 steps):**
Step 1: Name | Step 2: Content type (6 options + S) | Step 3: Audience (5 options) | Step 4: Publishing frequency (4 options) | Step 5: Voice/style files (3 options) | FAST-TRACK PAUSE | Step 6: Workflow stage help (multi-select 5) | Step 7: Output format (3 options) | Step 8: Tone guardrails (4 options + S) | Step 9: Skill — Voice Matching | Step 10: Skill — Outline Generator | Step 11: Skill — Editing Pass | Tools (multi-select) | Space name

**Project Management (11 steps):**
Step 1: Name | Step 2: Role (5 options + S) | Step 3: Project scale (4 options) | Step 4: Stakeholder communication (4 options) | Step 5: Tracking tools (5 options + S) | FAST-TRACK PAUSE | Step 6: Biggest time drain (5 options) | Step 7: Communication tone (3 options + S) | Step 8: File/folder access (5 options) | Step 9: Skill — Status Update Writer | Step 10: Skill — Meeting Notes Generator | Step 11: Skill — Risk Assessment | Tools (multi-select) | Space name

**Creative (11 steps):**
Step 1: Name | Step 2: Creative medium (6 options + S) | Step 3: Work context (4 options) | Step 4: Creative partner role (5 options) | Step 5: Creative constraints (5 options) | FAST-TRACK PAUSE | Step 6: Feedback style (3 options) | Step 7: Inspiration sources (3 options) | Step 8: Output format (3 options) | Step 9: Skill — Ideation Partner | Step 10: Skill — Creative Brief | Step 11: Skill — Feedback Synthesizer | Tools (multi-select) | Space name

**Business/Admin (11 steps):**
Step 1: Name | Step 2: Role (5 options + S) | Step 3: Communication volume (4 options) | Step 4: Primary communication types (multi-select 5) | Step 5: Formality level (4 options) | FAST-TRACK PAUSE | Step 6: Report/summary format (3 options) | Step 7: Confidentiality sensitivity (3 options) | Step 8: Tools (multi-select) | Step 9: Skill — Email Drafter | Step 10: Skill — Report Summarizer | Step 11: Skill — Action Item Extractor | Space name

**AC [v1.1]:**
- Questions are presented one at a time
- All questions have sensible defaults; user can skip with "I'm not sure / skip"
- All options use numbered format (1, 2, 3) universally — "S) Suggest" appears only on knowledge-gap questions
- Step counter shows "Step N" without denominator until after fast-track decision
- CTA on every question is `**Your answer:**` on its own line
- Fast-track pause appears after Step 5 for all 6 presets
- Skill presentation shows 3 options (Yes / No / Show me more) with personalized example, no description block
- `cowork-profile.md` includes `Upcoming deadlines:` field populated from deadlines step
- `cowork-profile.md` is generated from a fixed template (not freeform), includes: Name, Goal preset, Role/context, Tools, Output format, Setup date, Upcoming deadlines

### F3 — Project Custom Instructions Generator [REVISED v1.1]

`project-instructions-starter.txt` is the primary output artifact. It replaces the old flat `project-instructions.txt` as the first thing a user pastes.

**AC [v1.1]:**
- `project-instructions-starter.txt` is ≤300 words per preset
- Contains Phase 1 (onboarding block with state machine check) and Phase 2 (ongoing behavior: session-start rules, proactive skill triggers summary, safety rule)
- The safety rule ("Always ask for explicit confirmation before deleting, moving, or overwriting any file or folder") is present in every starter file, regardless of preset
- Wizard frames the output as "Project custom instructions" — paste into Project Settings > Custom Instructions BEFORE any conversation
- After wizard completion, Cowork generates `cowork-profile.md` from all answers and says: "Setup complete — your workspace is ready. What would you like to work on?" (does not auto-start tasks)
- First-session completion prompt is **personalized per preset** (action-triggering, not generic "what would you like to do?"):
  - Study: "Your [Subject] study space is ready. Want to start with a concept breakdown, a flashcard set, or share something you're reading?"
  - Research: "Your [Domain] research workspace is ready. Want to start a literature search, organize sources, or discuss your research question?"
  - Writing: "Your writing space is ready. Want to draft something, outline a new piece, or import a draft to work on?"
  - Project Management: "Your [Role] workspace is ready. Want to draft a status update, review a project, or set up your tracking system?"
  - Creative: "Your creative workspace is ready. Want to explore ideas, develop a concept, or get feedback on something you're working on?"
  - Business/Admin: "Your workspace is ready. Want to draft an email, summarize a document, or work through your inbox?"
- Returning-session greeting is deadline-aware: surfaces deadlines within 7 days and asks a contextually relevant opening question

### F4 — Cowork Project Folder Setup [UNCHANGED]

Creates (or documents) the recommended local folder rooted at `~/Documents/Claude/Projects/<preset-name>/`.

- AC: Each preset ships with a documented folder tree (markdown format)
- AC: Folder names follow Cowork conventions (no spaces in critical paths)
- AC: README.md included at folder root explaining each subfolder's purpose
- AC: Folder structure delivered as both a shell script and a manual checklist
- AC: Wizard frames this step as "set up your Cowork Project folder"

### F5 — Skill Starter Kit [REVISED v1.1]

Skills convert from flat `.md` files to proper Cowork `folder/SKILL.md` format with YAML frontmatter. This makes skills first-class Cowork citizens that auto-discover as `/slash-commands`.

**Skill file format (required for all presets):**
```
presets/<name>/.claude/skills/<skill-name>/SKILL.md
```
SKILL.md contains YAML frontmatter with `name:` and `description:` fields, plus skill body (instructions + examples, ≤250 words body).

**Skill activation during onboarding:** After the user says "Yes" to a skill in the wizard, `project-instructions-starter.txt` instructs Cowork: "Run `/skill-creator` to validate the skill is properly installed. If `/skill-creator` is not available, confirm the skill file exists at `.claude/skills/<skill-name>/SKILL.md`."

**AC [v1.1]:**
- All preset skill files are in `folder/SKILL.md` format with valid YAML frontmatter — no flat `.md` skill files remain
- Each preset ships with exactly 3 skills (per the step sequences in F2)
- Each `SKILL.md` contains: `name:` (slug), `description:` (one sentence), and a skill body
- `templates/preset-template/.claude/skills/example-skill/SKILL.md` uses this format (no flat example-skill.md)
- After user activates a skill in onboarding, wizard instructs Cowork to run `/skill-creator` to validate/improve
- WIZARD.md references Anthropic's official pre-built document skills (pptx, xlsx, docx, pdf) as zero-config day-one defaults
- SETUP-CHECKLIST.md includes a step-by-step ZIP upload walkthrough: Settings > Customize > Skills > '+', folder structure requirement (`skill-name/SKILL.md` at root, no double-nesting)
- `skills-as-prompts.md` is RETAINED in all 6 presets as copy-paste fallback (unchanged from v1.0)
- Inline safety note present in WIZARD.md once at the skill step: brief, reassuring, not a warning wall
- WIZARD.md NEVER references ClawHub or unvetted community skill repositories

### F6 — Connector Checklist [UNCHANGED]

Per-preset list of recommended Cowork connectors with plain-English descriptions.

- AC: Connector list is a markdown checklist
- AC: Each entry includes: connector name, what it enables, "do you need this?" decision helper
- AC: Connector entries include actual permission scope and data boundary note
- AC: Gmail entry states: "Note: Claude creates email drafts only — it cannot send emails without you clicking Send manually"
- AC: Google Workspace entry notes IT admin requirement for managed accounts
- AC: Wizard does NOT attempt to configure connectors automatically

### F7 — Output Package [REVISED v1.1]

The output package now leads with `project-instructions-starter.txt` as the first file to use.

- AC: Output includes: `project-instructions-starter.txt`, `cowork-profile.md`, `working-rules.md`, `about-me.md`, `output-format.md`, skill files (folder/SKILL.md format), `skills-as-prompts.md`, folder structure script, connector checklist, `SETUP-CHECKLIST.md`
- AC: `SETUP-CHECKLIST.md` step order: (1) Create Cowork Project, (2) Assign project folder, (3) **Paste `project-instructions-starter.txt` into Project Settings > Custom Instructions — before any conversation**, (4) Start conversation — Cowork auto-runs onboarding, (5) Complete remaining steps after onboarding
- AC: All other SETUP-CHECKLIST.md ACs from v1.0 are retained (memory tip, "Try this now" prompts, "What if something goes wrong?" section, versioning note)
- AC: `docs/OUTPUT-STRUCTURE.md` is updated to document `project-instructions-starter.txt` as the primary output artifact
- AC: All files are plain text or markdown — no binary formats

### F8 — README and Community Onboarding [REVISED v1.1]

- AC: README includes updated ASCII flow diagram showing: "Paste project-instructions-starter.txt → Start conversation → Cowork auto-detects first session → run `/setup-wizard` to redo"
- AC: README Quick Start Step 3 is: "Type `/setup-wizard`" as primary CTA
- AC: All v1.0 README ACs retained (shareable, no jargon, ≤8 steps, star CTA above fold, versions section)
- AC: CONTRIBUTING.md PR checklist updated: (1) `project-instructions-starter.txt` present, (2) starter file ≤300 words, (3) safety rule present in starter file verbatim, (4) all skills in `folder/SKILL.md` format (no flat .md skill files), (5) minimum file count met (≥3 skills, ≥2 context files, ≥1 folder structure, ≥1 connector checklist), (6) at least one "Try this now" prompt present, (7) CI passes

### F9 — Preset Library (6 Presets) [REVISED v1.1]

- AC: Each preset is a standalone folder in `/presets/<name>/`
- AC: Each preset contains: `project-instructions-starter.txt`, ≥3 skills in `folder/SKILL.md` format, `global-instructions.md` (with proactive trigger rules), 2 context files, 1 folder structure doc, 1 connector checklist, `skills-as-prompts.md`
- AC: `global-instructions.md` for each preset uses **proactive trigger rules format** (not passive skill list):
  - For each skill: defines 2–3 explicit trigger conditions and an exact suggested offer phrase
  - Session-start behavior block: check deadlines, surface within-7-days items, ask contextually relevant opening question
  - "Never" block: do not silently use a skill, do not assume subject without asking, do not end without offering to save output
- AC: All presets validated: README opens, files parse as markdown, no broken relative links

### F10 — CI Quality Gates [NEW v1.1]

Three new jobs added to `.github/workflows/quality.yml`:

- AC: `starter-file-check` job: verifies `presets/*/project-instructions-starter.txt` exists for all 6 presets — blocks PR if absent
- AC: `starter-safety-rule-check` job: greps all 6 starter files for the canonical safety rule text — blocks PR if absent
- AC: `skill-format-check` job: verifies all files under `presets/*/.claude/skills/` follow `folder/SKILL.md` convention — fails if flat `.md` skill files are found at the skills directory root

## Out of Scope (v1)

- Web application or GUI
- Automated Cowork connector authorization
- Cloud sync or hosted version
- Custom goal community config search path (deferred to v1.2)
- Multi-language support (English-only)
- Enterprise admin presets
- Personalization engine that learns over time

## Technical Constraints

- **Stack:** Static markdown repo. `project-instructions-starter.txt` is the primary wizard runtime surface. No application runtime.
- **Delivery:** Public GitHub repo. ZIP-downloadable. No package manager required.
- **Platform:** macOS primary, Windows secondary.
- **Word limit:** `project-instructions-starter.txt` must be ≤300 words per preset. If Cowork's actual field limit is shorter than expected (see A1), the Phase 2 ongoing behavior block may need to be trimmed or split.
- **Skill format:** All preset skills must use `folder/SKILL.md` with YAML frontmatter. No flat `.md` skill files.
- **Safety constraint:** Every `project-instructions-starter.txt` AND every `global-instructions.md` MUST contain the "confirm before delete" safety rule verbatim.
- **AskUserQuestion:** The nudge "use AskUserQuestion to present options as clickable buttons" is a best-effort heuristic instruction. Numbered list format is the primary design target; buttons are a stretch/bonus. Never design an AC that requires buttons.
- **`/skill-creator` dependency:** After skill activation, wizard instructs Cowork to run `/skill-creator`. If `/skill-creator` is unavailable or deprecated, fallback is to confirm file exists at `.claude/skills/<name>/SKILL.md`. This fallback must be present in all onboarding scripts.
- **Model floor:** Designed for Claude Sonnet 4.6 or better. WIZARD.md surfaces a soft model warning. Bash/manual fallbacks are model-agnostic.

## User Stories

- As a university student, I can paste `project-instructions-starter.txt` before my first conversation, so that Cowork automatically runs a personalized setup interview without being intercepted by the native setup skill.
- As a knowledge worker, I can type `/setup-wizard` explicitly, so that I get the full onboarding interview regardless of what Cowork's intent classifier would otherwise do.
- As a user who completed setup, I can open a new session and have Cowork greet me by name and surface any deadlines within 7 days, so that I start every session with relevant context.
- As a user who activates a skill during onboarding, I can trust that Cowork validates the skill via `/skill-creator`, so that it auto-discovers as a `/slash-command` rather than staying as a static prompt file.
- As a beginner, I can stop at Step 5 (fast-track), so that I get a working workspace without completing the full 11-step interview.
- As a community contributor, I can follow the CONTRIBUTING.md PR checklist, so that my preset includes all required files in the correct format and passes CI.

## Acceptance Criteria

- [ ] `project-instructions-starter.txt` exists for all 6 presets and is ≤300 words each
- [ ] Every `project-instructions-starter.txt` contains the safety rule verbatim
- [ ] Every `project-instructions-starter.txt` contains the AskUserQuestion nudge
- [ ] State machine check works: wizard auto-runs if `cowork-profile.md` absent, skips if present with real content
- [ ] Fast-track pause appears after Step 5 for all 6 presets
- [ ] All preset skill files are in `folder/SKILL.md` format with valid YAML frontmatter (no flat `.md` skill files)
- [ ] `.claude/skills/setup-wizard/SKILL.md` exists at repo root with valid YAML frontmatter
- [ ] All 6 presets' `global-instructions.md` use proactive trigger rules format (not passive skill list)
- [ ] SETUP-CHECKLIST.md Step 1 is: paste `project-instructions-starter.txt` before any conversation
- [ ] README.md Quick Start uses `/setup-wizard` as primary CTA
- [ ] CI has 3 new jobs: starter-file-check, starter-safety-rule-check, skill-format-check
- [ ] `cowork-profile.md` template includes `Upcoming deadlines:` field
- [ ] All 6 presets' questions use numbered options (1, 2, 3) — not lettered (A, B, C)
- [ ] Skill presentation shows 3 options with `**Your answer:**` CTA (not 4 options, not `→ Type a number.`)
- [ ] `skills-as-prompts.md` present in all 6 presets (unchanged)
- [ ] All 6 presets pass: README opens, files parse as markdown, zero broken relative links
- [ ] CI safety-rule grep passes for all 6 `global-instructions.md` AND all 6 `project-instructions-starter.txt`
- [ ] Smoke test documented as passing: paste starter file into fresh Cowork project, send any first message, verify (a) wizard auto-runs without native skill interception, (b) ≥5 questions appear, (c) `cowork-profile.md` created after completion

## Success Metrics

- **Primary (North Star):** % of users who complete the full wizard AND confirm they used Cowork actively within 7 days — target ≥60% of completers
- **Secondary:** GitHub stars within 30 days of LinkedIn launch post — target ≥200
- **Secondary:** % of preset downloads including Study or Research — target ≥50%
- **Secondary:** Community preset contributions within 60 days — target ≥3
- **Proxy:** Time-to-complete-setup for test user — target ≤15 minutes from clone to first personalized session

## Assumptions [confidence]

See `docs/assumptions.md` for full register. Key assumptions for v1.1:

- [UNTESTED] A1: Cowork's Project custom instructions field accepts ~400 words (≤300 word target provides safety margin)
- [UNTESTED] B2: Users are willing to complete an 11-step interview; fast-track path at Step 5 mitigates drop-off risk
- [UNTESTED] `/skill-creator` is a stable built-in Cowork slash command that produces valid `folder/SKILL.md` format
- [UNTESTED] The AskUserQuestion nudge causes Cowork to render clickable button UI — numbered list format is the guaranteed fallback
- [CONFIRMED] Cowork runs on macOS and Windows (GA April 2026)
- [CONFIRMED] v1.0 root cause: Cowork's intent classifier intercepts "set up"-type phrases before reading project files

## Proposed Changes (v1.1 revisions to v1.0)

| Area | Change | Rationale |
|------|--------|-----------|
| F1 | Three-layer trigger replaces WIZARD.md primary path | v1.0 root cause: WIZARD.md ignored by intent classifier |
| F2 | 11-step deep interview replaces 5-question interview | Too shallow even if triggered; proactive skills require context |
| F2 | Numbered options, `**Your answer:**` CTA, fast-track at Step 5 | UX fixes U1–U8 from @ux Phase 0b review |
| F3 | `project-instructions-starter.txt` is primary output artifact | Must be pasted before any conversation to work |
| F5 | Skills convert to `folder/SKILL.md` format with YAML frontmatter | Enables auto-discovery as `/slash-commands` in Cowork |
| F5 | `/skill-creator` validation after skill activation | Converts static files to properly triggering skills |
| F9 | `global-instructions.md` rewritten with proactive trigger rules | Passive skill list never triggered skills proactively |
| F10 | 3 new CI jobs for starter files and skill format | Enforce new required files for community contributions |
