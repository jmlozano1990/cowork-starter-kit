# Product Spec — Claude Cowork Config

## Problem

Claude Cowork launched in January 2026 as Anthropic's desktop agent for knowledge workers. It gives users powerful capabilities — local file read/write/create/delete, Google Drive/Gmail/Slack connectors, persistent memory, plugins, skills, custom instructions — but the out-of-the-box experience offers zero guidance on how to configure any of it.

The gap between "Claude Cowork installed" and "Claude Cowork working great for me" is wide. Non-technical users face a blank slate with no clear path to a useful setup. Power users invest a weekend or more in research, trial-and-error, and community guides before getting real value. Beginners give up before reaching the payoff.

**Evidence:**
- Community guides consistently report setup takes "a full weekend to build properly" (ryanstax.substack.com, 2026)
- Most common beginner mistake: skipping context files, custom instructions, and folder setup — the three highest-leverage configuration moves (the-ai-corner.com, 2026)
- Viral Reddit incident: user's Cowork deleted 11GB of files after a vague "clean up" prompt — caused by missing safety-scoped instructions (coworkhow.com, 2026)
- "The improvement in output quality from setting up Global Instructions alone is larger than switching models" (the-ai-corner.com, 2026)

Claude Cowork Config solves this by providing a goal-driven onboarding wizard that takes a beginner from "just installed" to "ready-to-use personalized workspace" in under 15 minutes, with zero code required.

## Target Users

**Primary: Alex — University Student (20, biochemistry)**
Goal: Use AI to study smarter — research, note-taking, flashcard generation, citation management.
Pain: Doesn't know where to start. Generic Claude responses feel like ChatGPT. Doesn't realize Cowork can read their PDFs and organize their notes folder.
Gain: A `/Study` folder pre-configured with Cowork permissions, a focused academic tone, and starter skills for research synthesis and flashcard generation.

**Secondary: Maria — Knowledge Worker (35, researcher / writer / project manager)**
Goal: Use AI as a work multiplier — literature review, report drafting, project tracking, email triage.
Pain: Has tried multiple AI tools, knows they're powerful, but hasn't found a setup that fits her workflow. Spends time re-explaining context every session.
Gain: A personalized workspace with persistent memory context, role-appropriate connectors (Google Drive, Gmail), and tone/output format locked to her professional standard.

Full personas: see `docs/personas.md`

## Core Features (MVP)

> **Configuration Surface Note:** This wizard configures Cowork **Project custom instructions** (scoped to one Project, only active when that project is open). It does NOT configure Global Instructions (account-wide). All references to "instructions" in this spec mean Project custom instructions unless explicitly stated otherwise.

### F1 — Goal-Type Wizard (Entry Point)
A short guided interview (3–5 questions max) that identifies the user's primary use case and maps it to one of 6 goal presets: **Study, Research, Writing, Project Management, Creative, Business/Admin**.

- AC: Wizard presents 6 goal cards with a 1-sentence description each. User can select one or type a custom goal.
- AC: If user types a custom goal, the wizard matches it to the closest preset (fuzzy match) and confirms: "It sounds like [Research]. Is that right?"
- AC: Wizard completes in ≤5 user interactions.
- AC: Each goal type maps to a documented configuration profile (tone + skills + folder structure + connectors).
- AC: WIZARD.md opens with a one-sentence model check: "For best results, use Claude Sonnet or higher. If you're on Claude Pro, tap the model selector (top-left) and select Sonnet before we begin. The wizard works on any model, but Haiku-class responses may require extra back-and-forth." This note is non-blocking.
- AC: WIZARD.md includes this canonical 5-question interview script:
  - **Q1 (Goal):** "Which best describes your main use for Cowork? [Study / Research / Writing / Project Management / Creative / Business/Admin] — or type your own."
  - **Q2 (Output format):** "When Claude gives you information, do you prefer: detailed explanations, bullet points, or structured reports?"
  - **Q3 (Role/context — preset-specific):** One question per preset (e.g. Study: "What subject are you studying?"; Research: "Are your sources mostly PDFs, web pages, or both?"; Writing: "What type of content do you create most?"; PM: "What tools does your team use for project tracking?"; Creative: "Do you work solo or with a team?"; Business/Admin: "What does a typical work day look like for you?")
  - **Q4 (Tools):** "Which of these do you use? [Google Drive / Gmail / Slack / None / Not sure]" — maps to connector checklist
  - **Q5 (Safety check):** Before asking Q5, WIZARD.md tells the user: "One important thing — Cowork can read, write, and delete files in any folder you give it access to. The next setting makes sure it always asks before doing anything like that." Then asks: "Does Cowork have access to any folders with files you'd never want deleted? [Yes / No / Not sure]" — the safety rule is always added regardless of answer; this just calibrates the safety language.
- AC: Custom goal fuzzy matching uses Cowork's LLM judgment. WIZARD.md includes a confirmation step: "It sounds like [Research] — is that right? If not, I'll show you all 6 options."
- AC: WIZARD.md tells Cowork exactly what to generate after Q5: copy the preset's `project-instructions.txt` template, substitute the user's role/context into the one-paragraph context summary, and save as `project-instructions.txt` in the output folder. All other output files are copied verbatim from the preset — they do not change based on answers except `cowork-profile.md`.

### F2 — Persona Depth Questions
After goal selection, 2–3 follow-up questions calibrate the preset for the user's specific context (role, tools they use, output format preference).

- AC: Questions are presented one at a time, not as a form.
- AC: All questions have sensible defaults so user can skip with "I'm not sure / skip".
- AC: Answers are stored in a `cowork-profile.md` file the wizard generates in the user's workspace.
- AC: Profile file is human-readable plain text — no JSON, no config syntax.
- AC: `cowork-profile.md` is generated from a fixed template (fill-in-the-blank format), not freeform LLM generation. Template fields: Name, Goal preset, Role/context (from Q4), Tools in use (from Q2), Output format preference (from Q3), Setup date. Human-readable, no JSON, no code.

### F3 — Project Custom Instructions Generator
Produces a ready-to-paste custom instructions block for a Cowork Project, tailored to the user's goal and answers. This is not a global paste — it becomes the custom instructions for the user's Cowork Project (the project they set up in F4).

- AC: Output is a plain-text block the user can copy and paste directly into their Cowork Project's custom instructions field.
- AC: Instructions include: tone directive, output format preference, safety rule ("Always ask before deleting files"), and a one-paragraph context summary about the user's role and goals.
- AC: The safety rule (confirm before delete) is present in EVERY generated instructions block, regardless of goal preset.
- AC: Instructions are ≤400 words (within Cowork's typical field limits).
- AC: Wizard frames the output explicitly as "Project custom instructions" — not global settings — so the user pastes it in the right place.
- AC: After generating `project-instructions.txt`, WIZARD.md includes this memory tip: "Cowork has a built-in Project memory. After pasting your custom instructions, try asking Cowork: 'Remember that I am [your role] and I prefer [output format] responses.' Cowork will store this for future sessions in this project."
- AC: WIZARD.md clarifies: "`cowork-profile.md` is a reference file you can share with Cowork manually by saying 'Here's my profile:' and pasting it. It is not auto-loaded — it's yours to use as a quick context-setter."

### F4 — Cowork Project Folder Setup
Creates (or documents) the recommended local folder for the user's Cowork Project, rooted at `~/Documents/Claude/Projects/<preset-name>/`. This is the designated folder path for a Cowork Project — the folder the user assigns when creating or configuring their project in Cowork.

- AC: Each preset ships with a documented folder tree (markdown format) rooted at `~/Documents/Claude/Projects/<preset-name>/`.
- AC: Folder names follow Cowork conventions (no spaces in critical paths, numeric prefixes for ordering where useful).
- AC: README.md is included at the folder root explaining each subfolder's purpose to the user.
- AC: Folder structure is delivered as: (a) a shell script the user can run to create it, OR (b) a manual "create these folders" checklist — both options present.
- AC: Wizard frames this step as "set up your Cowork Project folder" — not generic local organization — so the user understands it connects to their Cowork Project.

### F5 — Skill Starter Kit (Skill-Creator + Anthropic Pre-builts)
Guides users to build 2–3 personalized skills live using Cowork's built-in skill-creator, with Anthropic's official pre-built document skills as zero-friction day-one defaults.

**Primary delivery — skill-creator wizard:** WIZARD.md guides the user through creating 2–3 skills conversationally, goal-specific and tailored to their actual workflow. Skills are built live inside Cowork's skill-creator, not copied from static files.

**Secondary delivery — Anthropic pre-built skills:** WIZARD.md points users to Anthropic's official pre-built document skills (pptx, xlsx, docx, pdf) as ready-to-use defaults requiring no configuration.

**ZIP upload guidance:** SETUP-CHECKLIST.md includes a step-by-step walkthrough for uploading skill ZIPs in Cowork (Settings > Customize > Skills > '+'), including the required folder structure: `skill-name/SKILL.md` at root, no double-nesting.

**Safety note (inline in WIZARD.md):** The wizard includes one brief, reassuring note at the skill-creation step: "Skills can carry risks from untrusted sources. This wizard guides you to create skills yourself or use Anthropic's official pre-built skills — we don't reference external skill repositories in this step. If you ever install skills from other sources later, scan them first at SkillRisk.org." This note appears once — not as a warning banner, not as a blocker.

- AC: WIZARD.md guides the user to create 2–3 personalized skills live via Cowork's skill-creator. Questions are conversational and goal-specific.
- AC: WIZARD.md references Anthropic's official pre-built document skills (pptx, xlsx, docx, pdf) as day-one defaults.
- AC: SETUP-CHECKLIST.md includes a step-by-step ZIP upload walkthrough: Settings > Customize > Skills > '+', with folder structure requirement (`skill-name/SKILL.md` at root, no double-nesting).
- AC: Each skill file is plain-text, under 300 words, and follows the SKILL.md convention.
- AC: Context files include: `about-me.md` (user fills in), `working-rules.md` (pre-filled with safe defaults), `output-format.md` (pre-filled per preset).
- AC: The inline safety note is present in WIZARD.md exactly once at the skill step — brief and reassuring, not a warning wall.
- AC: WIZARD.md NEVER references ClawHub or unvetted community skill repositories. Only Tier 1–2 sources: self-created (skill-creator) and Anthropic pre-builts.
- AC: Static `.claude/skills/` preset files and the `skills-as-prompts.md` fallback approach are NOT included — skill-creator supersedes them.
- AC: Each skill file in `presets/<name>/.claude/skills/` follows this exact format:
  ```
  # Skill: <Name>
  **Description:** One sentence — what this skill helps Cowork do.
  **When to use:** One sentence — what kind of task or prompt activates this skill.
  **Instructions:** The skill prompt (≤250 words) — tell Claude how to approach this type of work.
  **Example prompts:**
  - [Example 1]
  - [Example 2]
  - [Example 3]
  ```
- AC: This format is also used in `templates/preset-template/.claude/skills/example-skill.md`.

### F6 — Connector Checklist
A per-preset list of recommended Cowork connectors (Google Drive, Gmail, Slack, DocuSign, etc.) with plain-English descriptions of what each one enables.

- AC: Connector list is delivered as a markdown checklist the user can work through.
- AC: Each connector entry includes: connector name, what it enables ("Google Drive: lets Claude read and create docs in your Drive"), and a "do you need this?" decision helper ("Only if you store working files in Drive").
- AC: Wizard does NOT attempt to configure connectors automatically — it only generates the checklist and instructions (connector auth is handled by Cowork's native UI).
- AC: Each connector entry includes the actual permission scope it requests. Example: "Google Drive: Cowork requests read/write access. Scope is limited to files you explicitly share or folders you grant access to — not your entire Drive by default."
- AC: Each connector entry includes a one-sentence data boundary note (what Cowork can and cannot access).
- AC: Gmail entry explicitly states: "Note: Claude creates email drafts only — it cannot send emails, even though the authorization screen mentions email permissions. Your emails are never sent without you clicking Send manually."
- AC: Google Workspace / managed account entry notes: "If your Google account is managed by an organization (school or employer), your IT admin must authorize Claude in Google Workspace Admin Console before your personal authorization will work."

### F7 — Output Package
Everything the wizard produces is bundled into a single deliverable folder that the user copies into their Cowork workspace.

- AC: Output folder structure is documented in `docs/OUTPUT-STRUCTURE.md` in the repo.
- AC: Output includes: `cowork-profile.md`, `project-instructions.txt` (Cowork Project custom instructions), `working-rules.md`, `about-me.md`, `output-format.md`, skill files (for ZIP upload), `skills-as-prompts.md` (copied from preset — fallback skill content for manual use if skill upload isn't available), folder structure script, connector checklist.
- AC: A `SETUP-CHECKLIST.md` is included at the root of the output, listing every manual step the user still needs to do in Cowork's native UI (paste instructions, authorize connectors, etc.).
- AC: All files are plain text or markdown — no binary formats, no dependencies.
- AC: SETUP-CHECKLIST.md contains at minimum these steps in order:
  1. Open Cowork → Click "New Project" → Name it after your preset (e.g. "My Study Space")
  2. In Project Settings → assign your project folder: `~/Documents/Claude/Projects/<preset-name>/`
  3. In Project Settings → Custom Instructions → paste the entire contents of `project-instructions.txt`
  4. Open `context/about-me.md` in any text editor → fill in your name, role, and goals → save
  5. For each connector in your `connector-checklist.md`: open Cowork Settings → Connectors → authorize
  6. Upload your skill ZIP: Cowork Settings → Customize → Skills → '+' → select the ZIP from your preset folder. ZIP must have `skill-name/SKILL.md` at root (no double-nesting).
  7. Test your skills: ask Cowork "What skills do you have active?" — verify your preset skills appear
  8. Try your first session (see "Try this now" prompt at bottom of checklist)
  9. If anything didn't work, see the "What if something went wrong?" section
- AC: SETUP-CHECKLIST.md includes a "Memory tip" note: "Cowork remembers things you tell it within a Project. Use the `/memory` command anytime to see, edit, or delete what it has stored."
- AC: The final section of every preset's SETUP-CHECKLIST.md is "Try this now" — two prompts per preset: (a) a file-based prompt for users who already have content in their folder, (b) a file-agnostic prompt that works immediately with zero files, demonstrating the preset's value without any prior content.
  - **File-agnostic prompts (b) — works on day one with zero content:**
    - Study: "Ask Cowork: 'I'm studying [your subject]. Explain the concept of [any concept from your subject] as if I'm encountering it for the first time, then give me 3 practice questions I can answer to check my understanding.'"
    - Research: "Ask Cowork: 'I'm starting a literature review on [your research topic]. What are the 5 most important questions I should be trying to answer, and what types of sources should I look for?'"
    - Writing: "Ask Cowork: 'I need to write [type of content] about [any topic]. Give me 3 different opening paragraphs with different tones — formal, conversational, and punchy — so I can see which feels most like my voice.'"
    - Project Management: "Ask Cowork: 'I'm managing a project to [describe any project]. What are the top 5 risks I should be tracking, and draft a one-paragraph status update I could send to a stakeholder today.'"
    - Creative: "Ask Cowork: 'I'm working on [describe any creative project]. Give me 5 unexpected directions I could take this — include at least one that surprises me.'"
    - Business/Admin: "Ask Cowork: 'Draft a professional email declining a meeting request politely, keeping the relationship warm, in under 100 words. Then draft a version that's 30% more direct.'"
  - **File-based prompts (a) — primary for users with content:**
    - Study: "Ask Cowork: 'Read the PDFs in my Papers/ folder and give me a one-paragraph summary of each one.'"
    - Research: "Ask Cowork: 'Look at my Research/ folder. What sources do I have and what topics do they cover?'"
    - Writing: "Ask Cowork: 'Read my voice-and-style.md and write me a 150-word sample in my voice about [any topic].'"
    - Project Management: "Ask Cowork: 'What's in my Active-Projects/ folder? Summarize the status of each project in 2 sentences.'"
    - Creative: "Ask Cowork: 'Read my inspiration/ folder and suggest 3 creative directions I could explore this week.'"
    - Business/Admin: "Ask Cowork: 'What files are in my Inbox/ folder? Draft a prioritized action list for today.'"
- AC: The file-based "Try this now" prompt uses real folder paths from the preset's folder structure document — it must produce a real result, not a generic answer.
- AC: SETUP-CHECKLIST.md includes a "What if something goes wrong?" section with recovery for these scenarios:
  - **Wizard interrupted mid-session:** "Open Cowork again, open this repo folder, and say: 'Let's continue the setup wizard. My preset is [name].' Your `cowork-profile.md` has your answers if we got that far."
  - **Skill test failed (skills not loading):** "Open `skills-as-prompts.md` in your preset folder. Copy the skill content you want and paste it at the start of your message: 'Using this approach: [paste] — now help me with [task].'"
  - **Connector auth failed:** "If Google Workspace/school/work account: your IT admin needs to authorize Claude first. For personal Google accounts, try disconnecting and re-authorizing. For other issues: support.claude.com"
- AC: SETUP-CHECKLIST.md ends with a "Keeping up to date" note: "When a new version ships, check the Releases tab on GitHub. CHANGELOG.md lists which presets changed. To update a specific preset: download the new `presets/<name>/` folder and replace only the template files. Your `cowork-profile.md` and `project-instructions.txt` are yours — they won't be overwritten."

### F8 — README and Community Onboarding
A high-quality README.md for the GitHub repo that serves as both product documentation and community growth hook.

- AC: README includes: what this is (1 paragraph), who it's for (2–3 sentences), how to use it (numbered steps, ≤8 steps), what you get (bulleted list per preset), and a "contribute a new preset" guide.
- AC: README is shareable — no jargon, no code required to understand.
- AC: README includes a visual (ASCII diagram or table) showing the wizard flow.
- AC: "Star this repo if it helped you" CTA is present above the fold.
- AC: README.md includes a "Versions & Updates" section (≤3 sentences) linking to GitHub Releases and explaining that only preset template files change — user-generated files are never overwritten.
- AC: CONTRIBUTING.md includes an explicit PR review checklist for maintainers: (1) safety rule present verbatim in `project-instructions.txt` (from `templates/global-instructions-base.md`), (2) minimum file count met (≥3 skill files, ≥2 context files, ≥1 folder structure, ≥1 connector checklist), (3) at least one "Try this now" prompt present, (4) CI passes (lint + links + shellcheck), (5) skill files follow the format spec from F5.
- AC: CONTRIBUTING.md links to `templates/preset-template/` as the required starting point for new presets.
- AC: CONTRIBUTING.md instructs contributors to scan any externally sourced skill content at SkillRisk.org before submitting.

### F9 — Preset Library (6 Presets Shipped at Launch)
Six fully documented configuration profiles, each covering: goal description, persona fit, Project custom instructions template, skill files, folder structure, connector checklist.

Presets:
1. **Study** — Students, exam prep, research-heavy coursework
2. **Research** — Academic researchers, analysts, literature review
3. **Writing** — Authors, content creators, journalists, bloggers
4. **Project Management** — PMs, team leads, ops professionals
5. **Creative** — Designers, storytellers, creative strategists
6. **Business/Admin** — Executives, assistants, business owners handling email/scheduling/reporting

- AC: Each preset is a standalone folder in `/presets/<name>/` containing all configuration files.
- AC: Each preset ships with at least 3 skill files, 2 context files, 1 folder structure, 1 connector checklist, and 1 `skills-as-prompts.md` file (fallback skill content for manual use if skill upload isn't available).
- AC: All presets are validated: README opens, files parse as markdown, no broken relative links.

## Out of Scope (v1)

- Web application or GUI — this is a CLI wizard or interactive markdown/script experience only
- Automated Cowork connector authorization (OAuth flows) — Cowork's native UI handles this
- Cloud sync or hosted version — local delivery only
- Plugin/sub-agent creation — preset skill files are instruction files only, not actual Cowork plugins
- Automated file deletion or permission changes on the user's machine beyond folder creation
- Integration with Cowork's API (no public API exists at time of writing — [UNTESTED])
- Multi-language support (English-only v1)
- Enterprise admin configuration presets (out of scope for community tool)
- Personalization engine that learns over time — static presets only at launch

## Technical Constraints

- **Stack:** Shell script (bash) for folder creation + Python (optional) or pure markdown/interactive CLI for wizard flow. Zero-dependency delivery preferred — users should not need to install anything beyond what comes with macOS/Windows.
- **Delivery:** Public GitHub repo. Users `git clone` or download ZIP. No package manager required.
- **Platform:** macOS primary (Claude Cowork GA on macOS first), Windows secondary (PowerShell equivalents for folder scripts).
- **File formats:** Markdown only for all config files. No YAML, TOML, JSON in user-facing files.
- **Cowork configuration surface targeted:** Cowork Project custom instructions, Cowork skill-creator (built-in), Anthropic pre-built skills, ZIP skill upload, local Cowork Project folder (`~/Documents/Claude/Projects/<preset-name>/`), connector checklist (manual). Projects feature (launched March 2026) is required for F3 and F4. Static `.claude/skills/` filesystem delivery is NOT used — superseded by skill-creator and ZIP upload.
- **Zero code barrier:** Every step must be executable by a user who has never opened a terminal. Where a terminal command is used, it must be wrapped in a plain-English explanation and a manual alternative must exist.
- **Safety constraint:** Every generated instructions block MUST include the "confirm before delete" safety rule. This is non-negotiable given the documented 11GB deletion incident.
- **Model floor:** The Cowork-as-wizard primary path is designed for Claude Sonnet 4.6 or better. Haiku-class models cannot reliably meet the ≤5-interaction AC or the fuzzy-match AC. WIZARD.md must surface a soft warning at session start. The bash-script and manual-checklist fallback paths are model-agnostic.
- **Model recommendation for knowledge work:** WIZARD.md should mention the `opusplan` alias (Opus for planning + Sonnet for execution) as the recommended daily-driver model for the Research, Writing, and Project Management presets. Study and Creative presets work well on Sonnet alone.

## User Stories

- As a university student, I can answer 3 questions about my study goals, so that I get a pre-configured Cowork workspace that helps me research, take notes, and generate flashcards without figuring out settings myself.
- As a knowledge worker, I can select my role type from a list, so that I get a Project custom instructions template that reflects my professional tone and output standards.
- As a beginner who just installed Cowork, I can follow the SETUP-CHECKLIST.md step by step, so that I have a working personalized workspace in under 15 minutes.
- As a non-technical user, I can read every configuration file in my output package, so that I understand what it does and can edit it without breaking anything.
- As a community contributor, I can find the `CONTRIBUTING.md` guide, so that I can add a new preset for a use case not covered in v1.
- As a researcher, I can use the Research preset, so that Cowork knows to produce structured literature summaries, use academic citation format, and ask for source folders before starting synthesis tasks.
- As a project manager, I can use the PM preset, so that Cowork knows to produce status updates in my preferred format and connects to my Google Drive project folder.

## Acceptance Criteria

- [ ] Running the wizard produces all required output files (profile, project custom instructions, working-rules, about-me, output-format, setup checklist) and guides the user through live skill creation via skill-creator
- [ ] Every generated Project custom instructions block contains the "confirm before delete" safety rule
- [ ] Wizard completes in ≤5 user interactions from goal selection to output
- [ ] All 6 presets are present as standalone folders in `/presets/`
- [ ] Each preset contains: ≥3 skill files, ≥2 context files, 1 folder structure document, 1 connector checklist
- [ ] All markdown files pass a markdown linter with zero errors
- [ ] README.md explains the product in plain language with no jargon and ≤8 setup steps
- [ ] Folder creation script runs successfully on macOS (bash) and produces the documented structure
- [ ] Manual alternative exists for every automated step (no step requires terminal if user declines)
- [ ] `SETUP-CHECKLIST.md` lists every post-wizard step the user must complete in Cowork's native UI
- [ ] CONTRIBUTING.md is present and explains how to add a new preset
- [ ] All preset files are plain markdown — no binary files, no code dependencies
- [ ] Zero broken relative links in any markdown file (validated by linter or CI check)

## Success Metrics

- **Primary (North Star):** % of users who complete the full wizard AND confirm they used Cowork actively within 7 days — target ≥60% of completers. [UNTESTED — measurement proxy: GitHub README survey link or issue template]
- **Secondary:** GitHub stars within 30 days of LinkedIn launch post — target ≥200 stars as community resonance signal
- **Secondary:** % of preset downloads that include the Study and Research presets (validates primary persona fit) — target ≥50% of downloads include one of these two
- **Secondary:** Community contributions (new presets submitted via PR) within 60 days — target ≥3 community presets
- **Proxy (immediate):** Time-to-complete-setup for a test user following the README — target ≤15 minutes from clone to first Cowork session with personalized config active

## Assumptions [confidence]

See `docs/assumptions.md` for full register. Key assumptions:

- [UNTESTED] Cowork's Project custom instructions field accepts plain-text blocks up to ~400 words without truncation
- [SUPERSEDED] SKILL.md files in `.claude/skills/` — A2 is resolved. Cowork does NOT auto-discover filesystem skills. Architecture pivots to skill-creator + ZIP upload. See `docs/assumptions.md` A2.
- [ESTIMATED] A non-technical user can follow a numbered setup checklist and configure their Cowork workspace in under 15 minutes
- [CONFIRMED] Cowork runs on macOS and Windows (GA April 2026)
- [UNTESTED] The Projects feature (March 2026) is stable enough to build configuration guidance around

## Open Questions for @architect

1. What is the exact delivery mechanism — pure markdown wizard (user reads and applies), interactive bash script, or Python CLI? Recommend deciding at Phase 1.
2. Should presets be versioned independently (semver per preset) or as a monorepo with a single version?
3. Should the GitHub repo include a GitHub Actions CI check for markdown lint and broken links?
