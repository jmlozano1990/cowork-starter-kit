# Product Spec — Claude Cowork Config (v1.2)

> **Cycle:** Dynamic Workspace Architect
> **Status:** Phase 0 — Requirements
> **Date:** 2026-04-17T00:00:00Z
> **Replaces:** v1.1 spec (Wizard Architecture Redesign)

---

## Problem

v1.1 solved the trigger architecture (starter file as system context bypasses intent classification). The wizard now runs reliably. But users still arrive at Step 1 not knowing what they want. The 6-preset menu assumes they can self-identify. They often cannot.

**The compounding failure mode:** A user who doesn't recognize their goal in the preset list either picks the closest-fit preset (gets a generic workspace) or abandons. Neither outcome delivers the "personalized workspace that understands your work" that is Cowork's actual value proposition.

**The v1.2 hypothesis:** If the wizard actively researches, suggests, and proposes workspace components — rather than waiting for the user to know what to ask for — completion quality improves and the setup feels like a collaboration, not a form.

**Validated reference:** The project owner built a "Career Manager" project in Cowork manually over multiple sessions. That process — goal articulation, folder decisions, rule-setting, skill installation — is exactly what the wizard should automate for any user, regardless of their prompting skill or product knowledge.

**Carry-forward from retro:**
- Step numbering conflict (F1 AC vs F7 AC) — resolved in this spec: step numbering in ACs follows the SETUP-CHECKLIST order
- `/skill-creator` validation (A14) — remains UNTESTED; fallback path required
- Token metrics instrumentation gap — noted; out of scope for v1.2

---

## Target Users

**Primary: Alex — University Student (20, biochemistry)**
Goal: Use AI to study smarter. Pain: Doesn't know what Cowork can do, doesn't know how to describe what he needs.
v1.2 gain: Wizard recognizes "studying biochemistry" as a variant of Study, surfaces flashcard/synthesis skills proactively, builds the folder structure without Alex having to design it.

**Secondary: Maria — Knowledge Worker (35, research analyst)**
Goal: AI as a work multiplier with persistent context. Pain: Re-explains herself every session; no per-project instructions set up because it takes time she doesn't have.
v1.2 gain: Wizard builds her Research + PM workspace from conversation, not from menu selection. Writing profile captures her professional voice so every output sounds like Maria, not like a chatbot.

**Tertiary: Sam — The Creator (28, freelance writer)**
Goal: Voice consistency across all outputs. Pain: Every Cowork output sounds like generic AI.
v1.2 gain: Writing profile wizard specifically addresses Sam's core pain — the workspace ships with a `writing-profile.md` calibrated to Sam's actual style.

**New: The "I don't know what I want" user**
This is Alex, Maria, and Sam on their first day with Cowork. They need the wizard to suggest before they can choose. Every wizard step must assume zero product knowledge. The wizard researches for them; they just confirm.

Full updated personas: see `docs/personas.md`.

---

## Configuration Surface Note

This wizard configures Cowork **Project custom instructions** (scoped to one Project). It does NOT configure Global Instructions. All references to "instructions" mean Project custom instructions unless explicitly stated.

---

## Core Features (MVP)

### F1 — Dynamic Wizard (replaces preset-first flow) [NEW v1.2]

The wizard pivots from "pick a preset, then answer questions" to "describe your goal, wizard proposes a workspace." Presets become accelerators (if user's goal matches a preset, wizard uses it as a scaffold), not the primary product.

**Wizard flow:**

```
1. Welcome + Goal Discovery
   "What would you like to use this workspace for?"
   → If vague/uncertain: wizard suggests 3 concrete directions with examples
   → If matches preset: "That sounds like [Study]. I have a good starting point —
      want me to customize it for you?"
   → If novel: "Interesting — let me think about what would work well for [goal].
      Here's what I'd suggest..."

2. Requirements Gathering (wizard proposes, user confirms)
   → Wizard states what it thinks the user needs:
     "For a [Career Manager], most people find these useful:
      1. Job application tracker
      2. Interview prep assistant
      3. Resume/CV tailor
      4. Networking follow-up reminders
      Which sound useful? (pick any, or say 'all')"
   → User picks or adjusts. Wizard refines.

3. User Profile (short guided questions)
   → Name, role/context, relevant background
   → Generates cowork-profile.md

4. Writing Profile (for ALL workspaces — see F6)
   → 3–4 questions: tone, audience, pet peeves, optional writing sample
   → Generates writing-profile.md

5. Workspace Design (wizard proposes, user approves)
   → Folder structure: "Here's what I'd suggest — modify?"
   → Working rules: "These rules match your goal — add/change?"
   → Connections: "These connectors would help — authorize?"

6. Skill Discovery + Installation (see F5)
   → Curated skill recommendations with one-line descriptions
   → User picks; wizard installs

7. Setup Complete
   → Summary of everything built
   → First-session prompt tailored to actual goal
```

**Fast-track preserved:** After requirements gathering (Step 2), offer: "Your basic workspace is ready. 1) Continue — add writing profile, folder structure, and skills  2) Get started now — run /setup-wizard later"

**AskUserQuestion buttons preserved:** Every wizard question includes the nudge: "Use AskUserQuestion to present options as clickable buttons if available. If not available, use numbered list format."

**State machine preserved:** If `cowork-profile.md` exists with real content, greet by name and skip onboarding. If absent (or contains `[Your name]`), run onboarding.

**AC [v1.2]:**
- `project-instructions-starter.txt` exists for all 6 presets AND contains the dynamic wizard flow (not just preset-specific questions)
- Starter file opens with open-ended goal discovery, not a preset menu
- Wizard includes a "suggestion branch": if user responds with uncertainty ("I'm not sure", "maybe", "something like"), wizard proposes 3 concrete options before proceeding
- All 6 presets remain available as accelerator scaffolds — if wizard detects a match, it offers the preset as a starting point
- Novel goals (not matching any preset) trigger a "build from scratch" flow using the same dynamic process
- AskUserQuestion nudge present in all wizard steps
- State machine check preserved: auto-run if `cowork-profile.md` absent, skip if present with real content
- Fast-track pause offered after requirements gathering (before writing profile and skill steps)
- Safety rule present verbatim in every `project-instructions-starter.txt`
- `/setup-wizard` skill updated to invoke dynamic wizard flow
- WIZARD.md updated to document v1.2 changes (remains documentation-only, not a runtime path)

### F2 — Deep Interview (Dynamic + Preset-Backed) [REVISED v1.2]

Interview steps adapt to the detected goal. Preset-matched goals use the v1.1 11-step sequence as a scaffold. Novel goals use a shorter, goal-specific interview built dynamically by the wizard.

**v1.1 UX rules all carry forward (no regression):**
- Numbered options (1, 2, 3...) — not lettered
- "S) Suggest" on knowledge-gap questions only — not personal preference questions
- Step counter shows "Step N" without denominator until after fast-track
- CTA: `**Your answer:**` on its own line
- Multi-select: `1, 3` or `1 3` both valid
- Free-text tolerance: match intent, state interpretation, proceed without re-asking
- Skill options: 3 choices (Yes / No / Show me more)
- "Show me more" latency: acknowledge immediately

**Writing Profile step added (new, universal):**
After the user profile step, for ALL goals (not just Writing preset), the wizard asks 3–4 writing questions:
1. What's your natural writing tone? (1. Casual  2. Professional  3. Academic  4. Mixed — depends on the piece)
2. Who do you write for? (1. Colleagues/team  2. Clients/stakeholders  3. Students/public  4. Personal use only)
3. Any writing habits to preserve or avoid? (1. Keep it concise, I hate fluff  2. I like thorough explanations  3. I use specific jargon my field expects  4. S) Suggest based on my goal)
4. (Optional) Paste a sentence or two from your writing so I can calibrate your voice. Or type "skip."

The wizard generates `writing-profile.md` from these answers. If the user pastes a sample, the wizard extracts voice patterns (sentence rhythm, vocabulary register, characteristic phrases) before generating the profile.

**Per-preset step sequences:** All 6 sequences from v1.1 carry forward unchanged. The writing profile step is inserted after Step 1 (Name) for all presets as the new Step 2, shifting subsequent steps by +1. Total: 12 steps per preset (up from 11). Fast-track pause moves to after Step 6 (was Step 5).

**AC [v1.2]:**
- Writing profile step appears in all 6 preset interview sequences
- Writing profile step appears in novel-goal flows
- `writing-profile.md` is generated for every completed setup, regardless of preset
- Writing profile questions use numbered options with AskUserQuestion nudge
- Optional writing sample input: if provided, wizard states one extracted voice observation before confirming ("I notice you tend toward short declarative sentences — I'll include that in your profile. Sound right?")
- Fast-track pause moves to after Step 6 (post-writing-profile) for all presets
- All v1.1 UX rules confirmed present (no regression AC)

### F3 — Project Custom Instructions Generator [REVISED v1.2]

`project-instructions-starter.txt` is rewritten to support the dynamic wizard flow. Files grow slightly (dynamic branching adds ~30–50 words) but must stay within Cowork's field limit.

**Word budget:** Target ≤350 words per starter file (revised from ≤300; rationale: dynamic branches add necessary content). If Cowork's actual field limit is proven at <300 words (A1 validation required), revert to split architecture (state machine in instructions, interview branches in WIZARD.md referenced by pointer).

**AC [v1.2]:**
- `project-instructions-starter.txt` ≤350 words for all 6 presets
- Every starter file contains: (a) dynamic goal discovery opener, (b) suggestion branch logic, (c) writing profile step, (d) state machine check, (e) safety rule verbatim, (f) AskUserQuestion nudge
- After wizard completion, Cowork generates: `cowork-profile.md`, `writing-profile.md`, and a workspace summary
- First-session completion prompt is goal-specific (not generic "what would you like to do?") — same per-preset phrasing as v1.1, extended to include novel goals with a goal-echoed prompt
- Returning-session greeting remains deadline-aware (unchanged from v1.1)
- Step numbering in SETUP-CHECKLIST.md: Step 1 = paste `project-instructions-starter.txt`, Step 2 = create project, Step 3 = assign folder (aligned with F7 — conflict resolved from retro)

### F4 — Cowork Project Folder Setup [UNCHANGED from v1.1]

Creates (or documents) the recommended local folder structure.

- AC: Each preset ships with a documented folder tree
- AC: Novel-goal folder structure is proposed by wizard and confirmed before creation
- AC: Folder names follow Cowork conventions (no spaces in critical paths)
- AC: README.md included at folder root explaining each subfolder's purpose
- AC: Folder structure delivered as both shell script and manual checklist
- AC: Wizard frames this step as "set up your Cowork Project folder"

### F5 — Skill Discovery (Hybrid Curated + Advanced) [REVISED v1.2]

Skills pivot from static 3-per-preset files to dynamically discovered and vetted recommendations.

**Hybrid model (Option D from plan):**

**Tier 1 — Curated (default for all users):**
- Anthropic official pre-built skills (pptx, xlsx, docx, pdf) — zero-config defaults
- Hand-curated allowlist of skills verified by repo maintainers (community PRs to `curated-skills-registry.md`)
- Recommendations drawn from allowlist based on detected goal
- No network calls required — allowlist ships in repo

**Tier 2 — Advanced (opt-in, non-technical users excluded by default):**
- Broader GitHub skill discovery (search `anthropics/skills`, `travisvn/awesome-claude-skills`, `VoltAgent/awesome-agent-skills`, `EAIconsulting/cowork-skills-library`)
- Shown only after explicit user opt-in: "Want me to search for more skills? (Note: these aren't verified by us — review before installing)"
- Safety warnings shown per skill: star count, last updated, permission surface summary
- User must confirm each Tier 2 skill individually before install instructions

**Skill vetting criteria (Tier 2):**
- Source repo must have >50 GitHub stars OR be from a recognized organization
- Last commit must be within 12 months
- SKILL.md must not contain network calls, subprocess commands, or environment variable references in the body
- Permission surface summary: wizard scans SKILL.md body for keywords (`exec`, `subprocess`, `curl`, `wget`, `$HOME`, `$PATH`, `rm`, `delete`) and surfaces findings
- If any keyword found: show as WARNING before install, require explicit "I understand" confirmation

**What the wizard presents for each skill (both tiers):**
1. Skill name and one-line description
2. What it would do for YOUR specific goal (personalized example from earlier interview answers)
3. Source and safety tier (Tier 1 Curated / Tier 2 Community)
4. Install options: `1. Yes — install  2. No — skip  3. Show me more`

**`/skill-creator` preserved:** After user confirms a skill, wizard instructs Cowork to run `/skill-creator` to validate/improve. Fallback (confirm file exists at `.claude/skills/<name>/SKILL.md`) must be present in all onboarding scripts if `/skill-creator` unavailable.

**`skills-as-prompts.md` preserved:** All 6 presets retain this fallback (unchanged from v1.1).

**`curated-skills-registry.md` (new):** A markdown file at repo root listing vetted skills with: name, description, source URL, vetting date, tier, goal tags. Community PR process for additions (same CONTRIBUTING.md flow as presets).

**AC [v1.2]:**
- `curated-skills-registry.md` exists at repo root with ≥3 entries per preset category (18 minimum entries)
- Each registry entry includes: name, description, source URL, vetting date (ISO 8601), tier (1=curated/2=community), goal tags
- Wizard draws skill recommendations from registry, filtered by detected goal
- Tier 2 discovery is behind an explicit opt-in step — not shown by default
- Tier 2 opt-in shows safety warning and explains what "unverified" means before listing skills
- Per-skill permission scan: wizard checks SKILL.md body for flagged keywords; WARNING shown if found
- Each skill presented with personalized example (using goal and answers from earlier steps)
- 3-option skill presentation preserved (Yes / No / Show me more)
- `/skill-creator` validation preserved with fallback path
- `skills-as-prompts.md` retained in all 6 presets (unchanged)
- CI skill-format-check job unchanged (still validates folder/SKILL.md format)

### F6 — Writing Profile (Universal, All Workspaces) [NEW v1.2]

Every workspace setup generates `writing-profile.md` — not just Writing preset workspaces.

**Rationale:** Every Cowork user produces text. A Career Manager writes emails and cover letters. A Research analyst writes literature reviews. A Study user writes lab reports. The "anti-AI voice" problem is universal, not writing-preset-specific.

**`writing-profile.md` contents:**

```markdown
# Writing Profile — [Name]

## Tone & Voice
- Register: [casual / professional / academic / mixed]
- Audience: [colleagues / clients / students / public]
- Characteristic patterns: [extracted from sample, or from interview answers]

## Style Preferences
- Sentence length: [short and direct / medium / long and detailed]
- Vocabulary: [plain / technical / domain-specific: field name]
- Structure: [flowing prose / bullets / headers / mixed]

## Anti-AI Guidance
- Avoid: [patterns flagged based on tone — e.g., "It's important to note", "In conclusion",
          "As an AI language model", "Certainly!", passive voice overuse]
- Prefer: [natural transitions, active voice, specific examples over generalizations,
          sentence variety, first person where appropriate]
- Voice markers: [specific patterns extracted from writing sample, if provided]

## Workspace-Specific Rules
- [Goal-specific writing conventions — e.g., APA citations for Study, executive summary
  format for Research/PM, resume conventions for Career Manager]

## Pet Peeves
- [User-specified habits to avoid or preserve]
```

**Anti-AI detection guidance philosophy:** The goal is not to "fool detectors." The goal is to produce writing that sounds like the user, not like a generic AI. The wizard frames this as voice calibration, not evasion.

**Writing sample analysis:** If the user pastes a sample, the wizard:
1. Extracts 2–3 observable patterns (sentence rhythm, vocabulary register, characteristic phrases)
2. States them explicitly: "I notice you tend toward short declarative sentences and domain-specific vocabulary. I'll include that."
3. Asks "Sound right?" before including in profile
4. Includes patterns as specific rules in the profile (not vague "match their tone")

**AC [v1.2]:**
- `writing-profile.md` is generated for every completed setup regardless of preset
- Template exists at `templates/writing-profile-template.md`
- Anti-AI guidance section is present in every generated profile
- Wizard explicitly states the purpose: "This profile helps me write in your voice — so your documents sound like you, not like a generic AI"
- Writing sample analysis: if sample provided, wizard extracts and names ≥2 specific patterns before confirming
- Workspace-specific rules section adapts to detected goal (Research workspace gets citation conventions; Writing workspace gets publishing format; Study workspace gets academic integrity framing)
- CI new job: `writing-profile-template-check` — verifies `templates/writing-profile-template.md` exists and contains all required sections

### F7 — Output Package [REVISED v1.2]

Output package adds `writing-profile.md` and `curated-skills-registry.md` as new artifacts.

- AC: Output includes (in order): `project-instructions-starter.txt`, `cowork-profile.md`, `writing-profile.md`, `working-rules.md`, `about-me.md`, `output-format.md`, skill files (folder/SKILL.md format), `skills-as-prompts.md`, folder structure script, connector checklist, `SETUP-CHECKLIST.md`
- AC: SETUP-CHECKLIST.md step order: (1) Paste `project-instructions-starter.txt` into Project Settings > Custom Instructions — before any conversation, (2) Create Cowork Project, (3) Assign project folder, (4) Start conversation — Cowork auto-runs dynamic wizard, (5) Complete remaining steps after onboarding [CONFLICT RESOLVED from retro — Step 1 = paste]
- AC: All v1.1 output package ACs retained (memory tip, "Try this now" prompts, "What if something goes wrong?" section, versioning note, plain text / markdown only)
- AC: `docs/OUTPUT-STRUCTURE.md` updated to document `writing-profile.md` and `curated-skills-registry.md`

### F8 — README and Community Onboarding [REVISED v1.2]

- AC: README updated to reflect dynamic wizard — "goal discovery" framing instead of "pick a preset"
- AC: README ASCII flow diagram updated: "Paste starter → Start conversation → Wizard asks your goal → Wizard proposes workspace → Confirm and build → Run /setup-wizard to redo"
- AC: README Quick Start Step 3 remains: "Type `/setup-wizard`"
- AC: README includes a "What can you build?" section showing 3 example workspaces: Study (preset), Career Manager (novel), Home Renovation (novel) — to show users that the wizard handles goals beyond the 6 presets
- AC: All v1.1 README ACs retained (shareable, no jargon, ≤8 steps, star CTA above fold, versions section)
- AC: CONTRIBUTING.md PR checklist updated: adds (8) `writing-profile.md` template section present, (9) curated-skills-registry entry follows format (name, description, source URL, vetting date, tier, goal tags)

### F9 — Preset Library (6 Presets) [REVISED v1.2]

- AC: Each preset folder contains: `project-instructions-starter.txt` (dynamic wizard, ≤350 words), ≥3 skills in `folder/SKILL.md` format, `global-instructions.md` (proactive trigger rules), 2 context files (incl. `writing-profile.md`), 1 folder structure doc, 1 connector checklist, `skills-as-prompts.md`
- AC: `writing-profile.md` ships as a context file template in all 6 presets — not blank, but populated with goal-appropriate defaults (user fills in personal details)
- AC: `global-instructions.md` for each preset adds a writing profile trigger: "When generating written content ≥100 words, reference `writing-profile.md` for voice and anti-AI guidance"
- AC: All v1.1 preset ACs retained (proactive trigger rules, session-start block, "never" block)

### F10 — CI Quality Gates [REVISED v1.2]

All 3 v1.1 CI jobs unchanged. One new job added:

- AC: `starter-file-check` job: unchanged
- AC: `starter-safety-rule-check` job: unchanged (.txt glob + count check)
- AC: `skill-format-check` job: unchanged
- AC: `writing-profile-template-check` job (NEW): verifies `templates/writing-profile-template.md` exists and contains required sections (`## Tone & Voice`, `## Anti-AI Guidance`, `## Workspace-Specific Rules`)

---

## Out of Scope (v1.2)

- Advanced GitHub skill scanning with automated permission analysis (deferred to v1.3 — v1.2 ships manual keyword scan only)
- Skills marketplace integration or live API calls to any external registry
- Automated Cowork connector authorization (unchanged from v1.1)
- Cloud sync or hosted version
- Multi-language support (English-only)
- Enterprise admin presets
- Personalization engine that learns over time (separate product)
- Deep writing style analysis from multiple documents (v1.2 = single sample; multi-doc analysis is v1.3)
- Automated vetting pipeline for community skill PRs (v1.3 — v1.2 uses human review in CONTRIBUTING.md)
- Writing detectability scoring or integration with Turnitin/GPTZero (the goal is voice authenticity, not detector bypass)

---

## Technical Constraints

- **Stack:** Static markdown repo. `project-instructions-starter.txt` is the primary wizard runtime surface. No application runtime.
- **Delivery:** Public GitHub repo. ZIP-downloadable. No package manager required.
- **Platform:** macOS primary, Windows secondary.
- **Word limit (revised):** `project-instructions-starter.txt` must be ≤350 words per preset (increased from 300 for dynamic branching). If A1 validation reveals Cowork's actual field limit is <300 words, revert to split architecture (state machine in instructions, branches in WIZARD.md via pointer).
- **Skill format:** All preset skills must use `folder/SKILL.md` with YAML frontmatter. No flat `.md` skill files.
- **Safety constraint:** Every `project-instructions-starter.txt` AND every `global-instructions.md` MUST contain the "confirm before delete" safety rule verbatim.
- **AskUserQuestion:** Best-effort heuristic. Numbered list format is the primary design target. No AC may require button rendering.
- **`/skill-creator` dependency:** After skill activation, wizard instructs Cowork to run `/skill-creator`. If unavailable, fallback is confirm file exists at `.claude/skills/<name>/SKILL.md`. Fallback must be present in all onboarding scripts.
- **Skill vetting:** Tier 2 skill keyword scanning is performed by the wizard LLM reviewing the SKILL.md body text — not a code execution step. This is a best-effort review, not a sandbox execution environment.
- **`curated-skills-registry.md`:** Ships as a static markdown file. No live network calls during wizard execution.
- **Model floor:** Designed for Claude Sonnet 4.6 or better. WIZARD.md surfaces a soft model warning.
- **Writing profile depth:** v1.2 = tone/voice questions + optional single writing sample. Multi-document analysis and style import from existing project files: deferred to v1.3.

---

## User Stories

- As a user who doesn't know what Cowork can do, I can describe my goal in plain language and have the wizard propose a workspace for me, so that I don't need to know product vocabulary to get value.
- As a user whose goal doesn't match any preset, I can have the wizard build a custom workspace from scratch, so that I'm not forced into a generic template.
- As any Cowork user (not just writers), I can answer 3–4 questions about my writing style and get a `writing-profile.md` that makes Cowork write in my voice, so that my outputs don't sound like generic AI.
- As a user who wants more skills than the curated list, I can opt into Tier 2 community discovery with clear safety warnings, so that I can expand my workspace without being blocked from advanced options.
- As a university student, I can paste `project-instructions-starter.txt` before my first conversation, so that the dynamic wizard automatically runs and guides me to a study workspace without me knowing what to ask for.
- As a knowledge worker, I can type `/setup-wizard` explicitly, so that I get the full dynamic wizard regardless of Cowork's intent classifier.
- As a community contributor, I can follow the CONTRIBUTING.md PR checklist, so that my skill submission to `curated-skills-registry.md` passes review and my preset includes all required files.
- As a beginner, I can stop at the fast-track pause (after requirements gathering), so that I get a working workspace without completing the full writing profile and skill discovery steps.

---

## Acceptance Criteria

- [ ] `project-instructions-starter.txt` exists for all 6 presets and is ≤350 words each
- [ ] Every `project-instructions-starter.txt` opens with open-ended goal discovery (not a preset menu)
- [ ] Every `project-instructions-starter.txt` contains a suggestion branch (responds to uncertainty with 3 concrete options)
- [ ] Every `project-instructions-starter.txt` contains the writing profile step (3–4 questions)
- [ ] Every `project-instructions-starter.txt` contains the safety rule verbatim
- [ ] Every `project-instructions-starter.txt` contains the AskUserQuestion nudge
- [ ] State machine check works: wizard auto-runs if `cowork-profile.md` absent, skips if present with real content
- [ ] Fast-track pause appears after requirements gathering (before writing profile + skill steps) for all 6 presets
- [ ] `writing-profile.md` is generated for every completed setup regardless of preset
- [ ] `templates/writing-profile-template.md` exists with all required sections
- [ ] `curated-skills-registry.md` exists at repo root with ≥18 entries (≥3 per preset category)
- [ ] Each `curated-skills-registry.md` entry has: name, description, source URL, vetting date, tier, goal tags
- [ ] Tier 2 skill discovery is behind an explicit opt-in step — not shown by default
- [ ] Tier 2 skill presentation includes safety warning and per-skill permission scan result
- [ ] All preset skill files remain in `folder/SKILL.md` format (no regression)
- [ ] `.claude/skills/setup-wizard/SKILL.md` updated to invoke dynamic wizard flow
- [ ] All 6 presets' `global-instructions.md` include writing profile trigger rule (≥100 words → reference writing-profile.md)
- [ ] SETUP-CHECKLIST.md Step 1 is: paste `project-instructions-starter.txt` before any conversation [retro conflict resolved]
- [ ] CI has 4 jobs: starter-file-check, starter-safety-rule-check, skill-format-check, writing-profile-template-check
- [ ] `cowork-profile.md` template includes `Upcoming deadlines:` field (unchanged from v1.1)
- [ ] All 6 presets pass: README opens, files parse as markdown, no broken relative links
- [ ] Smoke test documented as passing: paste starter file into fresh Cowork project, send any first message — verify (a) dynamic wizard auto-runs, (b) wizard offers a suggestion branch when user expresses uncertainty, (c) writing profile questions appear before skill discovery, (d) `cowork-profile.md` AND `writing-profile.md` both created after completion

---

## Edge Cases

**E1 — User provides an unrecognizable goal:** Wizard must not fail silently. If goal cannot be matched to any preset or category, wizard states: "I'm not sure what workspace fits [goal] best. Let me suggest a few approaches..." and offers 3 generic workspace directions (Focus/Productivity, Creative/Writing, Research/Learning).

**E2 — User skips writing sample but has very strong style preferences:** Writing profile should still generate with substantive rules from the tone/audience/pet peeves questions alone. The profile must never ship as empty or with only placeholder text.

**E3 — User opts into Tier 2 skill discovery, all skills fail keyword scan:** Wizard must not block the setup. It presents the WARNING for each skill and lets the user decide individually. If user declines all Tier 2 skills, wizard completes setup with Tier 1 skills only and confirms "Your workspace is ready — you can always add more skills later via /setup-wizard."

**E4 — Novel goal with no matching curated skills:** Wizard completes setup without skill discovery (no skills installed), notes "I don't have any verified skills for [goal] yet," and suggests the user build custom skills via `/skill-creator`.

**E5 — User reaches word limit mid-wizard (starter file truncated):** Wizard detects it's not getting expected interview answers and says "It looks like setup may have been interrupted. Type /setup-wizard to restart from where we left off."

**E6 — User pastes writing sample containing sensitive information:** Wizard uses the sample only for style analysis, does not store the raw sample text in `writing-profile.md`. Only extracted patterns are written to the profile.

---

## Success Metrics

- **Primary (North Star):** % of users who complete the dynamic wizard AND report the workspace matched their actual goal — target ≥70% of completers (raised from 60% — dynamic wizard should improve goal-fit)
- **Secondary:** % of completers who generate a `writing-profile.md` — target ≥80% (measures feature adoption; if low, writing profile step needs UX improvement)
- **Secondary:** % of completers who install ≥1 skill from the curated registry — target ≥60%
- **Secondary:** GitHub stars within 30 days of LinkedIn launch post — target ≥200 (unchanged)
- **Secondary:** `curated-skills-registry.md` community contributions within 60 days — target ≥10 entries added via PR (new metric for community health)
- **Proxy:** Time-to-complete-setup for test user — target ≤18 minutes from clone to first personalized session (revised from 15 min to account for writing profile step)

---

## Assumptions [confidence]

See `docs/assumptions.md` for full register. Key assumptions for v1.2:

- [UNTESTED] A1 (CRITICAL): Cowork's Project custom instructions field accepts ≤350 words without truncation
- [UNTESTED] A16: Users are willing to complete the writing profile step (3–4 questions) even in workspaces they don't associate with writing
- [UNTESTED] A17: The dynamic wizard's "suggestion branch" produces suggestions that users recognize as relevant to their goal (vs. generic noise)
- [UNTESTED] A18: `curated-skills-registry.md` approach is viable — skills remain installable via the methods documented in the registry entries without a live API
- [ESTIMATED] A14: `/skill-creator` is a stable built-in Cowork command (carries from v1.1; fallback path required)
- [ESTIMATED] A15: AskUserQuestion nudge causes Cowork to render clickable button UI (carries from v1.1; numbered list is primary target)
- [CONFIRMED] Cowork runs on macOS and Windows (GA April 2026)
- [CONFIRMED] v1.1 trigger architecture works: starter file as system context bypasses intent classifier
- [CONFIRMED] Skill community ecosystem exists (GitHub repos with 1,000+ SKILL.md files, Anthropic official skills registry, skills.sh marketplace)
- [CONFIRMED] Security risk is real: 13.4% of community skills contain critical security issues (Repello AI / Snyk ToxicSkills research 2026) — hybrid model with curated Tier 1 is required, not optional

---

## Proposed Changes (v1.2 additions to v1.1)

| Area | Change | Rationale |
|------|--------|-----------|
| F1 | Dynamic wizard replaces preset-first menu | Users don't know what they want; wizard must suggest before they can choose |
| F1 | Suggestion branch added | Handles "I'm not sure" responses without abandonment |
| F2 | Writing profile step added (universal) | Every user produces text; voice calibration is universal need, not writing-specific |
| F3 | Word budget raised to ≤350 | Dynamic branching requires ~30–50 additional words |
| F5 | Skill discovery replaces static 3-per-preset | Dynamic goal matching requires dynamic skill recommendations |
| F5 | Hybrid Tier 1/Tier 2 model | Security research confirms 13.4% community skill risk; curated default is non-negotiable |
| F5 | `curated-skills-registry.md` new artifact | Community-extensible allowlist shipped in repo; no live API calls |
| F6 | `writing-profile.md` new universal artifact | Addresses anti-AI voice problem for all user types, not just writers |
| F7 | Output package adds `writing-profile.md` | New universal artifact |
| F8 | README "What can you build?" section | Shows novel-goal examples to break "I have to pick a preset" mental model |
| F9 | Presets add `writing-profile.md` context file | Ships with goal-appropriate defaults; user fills in personal details |
| F9 | `global-instructions.md` writing trigger added | Connects writing profile to actual usage behavior |
| F10 | 4th CI job: `writing-profile-template-check` | Enforces new required artifact for community contributions |
| Retro | Step numbering conflict resolved | F1 AC and F7 AC now align: Step 1 = paste starter file |

---

## Architectural Modifications

_Written by @architect — Phase 1 v1.2. Read by @pm on /spec --revise to close feedback loop._

- AC: F1 fast-track placement — "offered after requirements gathering (before writing profile and skill steps)" → Changed to "offered after writing profile step (Step 6)" — Reason: F1 AC conflicts with F2 AC and the Proposed Changes table. F2 AC explicitly states "Fast-track pause moves to after Step 6 (post-writing-profile)." The Proposed Changes table confirms "Fast-track pause moves to after Step 6 (was Step 5)." Architecture follows F2 (fast-track after Step 6) because: (a) writing profile is a brief 3–4 question step users benefit from regardless of fast-track timing; (b) fast-tracking before writing profile would mean all fast-track users get a workspace with no voice calibration — directly contradicting F6's universal writing profile AC. Recommend @pm reconcile F1 AC in next spec revision.
