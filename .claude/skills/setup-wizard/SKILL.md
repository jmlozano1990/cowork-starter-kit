---
name: setup-wizard
description: Run the Cowork workspace onboarding wizard — personalized setup for your goal (study, research, writing, PM, creative, business)
---

## Setup Wizard

This skill runs your personalized Cowork workspace onboarding interview.

**Reset guard:** If `cowork-profile.md` already exists with real content, say: "This will reset your profile and re-run onboarding. Your past sessions are unaffected. Confirm? (Yes / No)" — only proceed on Yes.

---

## Interview

For each question, use AskUserQuestion to present the options as clickable buttons if available. If not available, use the numbered list format below. Ask one question at a time. Wait for the user's answer before proceeding.

**Your answer:** appears on its own line after every question. Options use numbered format (1, 2, 3). "S) Suggest" appears on knowledge-gap questions only.

---

### Step 1 — Name

"What's your name, or what should I call you?" (free text)

---

### Step 2 — Goal preset

"What's your main goal for this workspace?

1. Study — exam prep, coursework, research-heavy learning
2. Research — literature review, academic research, analysis
3. Writing — articles, essays, content creation, blogging
4. Project Management — tracking projects, stakeholder updates, risk
5. Creative — design, storytelling, creative strategy
6. Business/Admin — email, reporting, scheduling, admin tasks
S) Suggest — describe your work and I'll match it

**Your answer:**"

If user describes custom goal: match to closest preset, confirm. Record selected preset.

---

### Steps 3–11 (per preset)

After recording the preset, run the full 11-step interview for that preset. The complete step sequences are in WIZARD.md (the script source). Key rules:

- Show "Step N" (not "Step N of 11") until after the fast-track decision
- After Step 5, pause: "Your basic workspace is ready. 1) Yes, continue — deeper customization  2) Get started now — run `/setup-wizard` later"
- Skill steps show 3 options: `1. Yes — activate  2. No — skip it  3. Show me more`
- Each skill step shows a personalized example using the user's actual answers from earlier steps
- CTA is `**Your answer:**` on its own line

---

## After interview

Generate `cowork-profile.md` from all answers. Include: Name, Goal preset, Role/context, Tools, Output format, Setup date, Upcoming deadlines.

Then say: "Setup complete — your workspace is ready. What would you like to work on?"

**First-session completion prompt (personalized per preset):**
- Study: "Your [Subject] study space is ready. Want to start with a concept breakdown, a flashcard set, or share something you're reading?"
- Research: "Your [Domain] research workspace is ready. Want to start a literature search, organize sources, or discuss your research question?"
- Writing: "Your writing space is ready. Want to draft something, outline a new piece, or import a draft to work on?"
- Project Management: "Your [Role] workspace is ready. Want to draft a status update, review a project, or set up your tracking system?"
- Creative: "Your creative workspace is ready. Want to explore ideas, develop a concept, or get feedback on something you're working on?"
- Business/Admin: "Your workspace is ready. Want to draft an email, summarize a document, or work through your inbox?"

**Skill validation:** After each activated skill, tell the user: "Run `/skill-creator` to confirm this skill is properly installed. If `/skill-creator` is not available, confirm the file exists at `.claude/skills/<skill-name>/SKILL.md`."

Always ask for explicit confirmation before deleting, moving, or overwriting any file or folder.
