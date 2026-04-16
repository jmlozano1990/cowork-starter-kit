# cowork-starter-kit

> Set up your Claude Cowork workspace in 15 minutes. No code. No configuration files. Paste one file — Cowork does the rest.

[![CI](https://github.com/JLCyb3r/cowork-starter-kit/actions/workflows/quality.yml/badge.svg)](https://github.com/JLCyb3r/cowork-starter-kit/actions/workflows/quality.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.1.0-green.svg)](CHANGELOG.md)

---

## The problem

Claude Cowork is powerful — but a blank project is intimidating. Most people never configure it properly, so they get generic answers instead of a workspace tuned for how they actually work.

This fixes that.

---

## How it works

Paste one file into Cowork Project Settings before your first conversation. Cowork auto-detects it's your first session and runs a personalized onboarding interview — goal selection, deep customization, skill activation. Takes about 15 minutes. No terminal required.

```
You                                Cowork
 |                                    |
 |  Paste project-instructions-       |
 |  starter.txt into Project          |
 |  Settings > Custom Instructions    |
 | ---------------------------------> |
 |                                    |  (injected as system context)
 |                                    |
 |  Start conversation                |
 | ---------------------------------> |
 |                                    |  Auto-detects first session
 |                                    |  Runs onboarding interview
 |                                    |  (up to 11 steps, fast-track at 5)
 |  [your answers]                    |
 | ---------------------------------> |
 |                                    |  Generates your workspace:
 |                                    |    cowork-profile.md
 |                                    |    context/ folder
 |                                    |    skill files
 |                                    |    connector-checklist.md
 |  "Your workspace is ready."        |
 | <--------------------------------- |
 |                                    |
 |  Type /setup-wizard                |
 | ---------------------------------> |  Explicit fallback — redo setup
```

---

## Quick start

1. **[Download ZIP](https://github.com/JLCyb3r/cowork-starter-kit/archive/refs/heads/main.zip)** — unzip anywhere on your computer
2. Open Claude Cowork → create a new Project → point it at the unzipped folder
3. Open your preset folder (`presets/<your-goal>/`), copy `project-instructions-starter.txt`, and paste it into Project Settings > Custom Instructions
4. Type: **`/setup-wizard`**

That's it. Cowork runs the onboarding interview and builds your personalized workspace.

> **No Cowork yet?** Use the manual path: open `SETUP-CHECKLIST.md` and follow every step by hand.

---

## Six goal presets

Pick the one that matches your work. The wizard auto-selects the right preset and personalizes it for you.

| Preset | Best for | What you get |
|--------|----------|--------------|
| **Study** | Students, exam prep, coursework | Research synthesis, note-taking, flashcard generation |
| **Research** | Academics, analysts, lit review | Literature review, source analysis, synthesis |
| **Writing** | Authors, bloggers, journalists | Voice matching, editing pass, outline generator |
| **Project Management** | PMs, team leads, ops | Status updates, meeting notes, risk assessment |
| **Creative** | Designers, storytellers, strategists | Ideation, creative brief, feedback synthesis |
| **Business/Admin** | Executives, assistants, owners | Email drafting, report summary, action items |

**Each preset includes:**

- `project-instructions-starter.txt` — paste into Project Settings > Custom Instructions BEFORE any conversation
- `global-instructions.md` — proactive skill trigger rules (session behavior)
- `context/about-me.md` — fill in your name, role, and goals
- `context/working-rules.md` — safe defaults (includes confirm-before-delete rule)
- `context/output-format.md` — pre-filled for your preset
- `connector-checklist.md` — which connectors to authorize and why
- `skills-as-prompts.md` — skill content as copy-paste prompts if skill upload is unavailable
- `folder-structure.md` — recommended folder layout for your workspace
- `.claude/skills/<skill-name>/SKILL.md` — 3 preset skills in Cowork-native format

---

## Safety first

Every preset includes a non-negotiable rule: **Cowork will always ask for your confirmation before deleting, moving, or overwriting any file or folder.** This rule is built into every workspace this wizard generates and is enforced by CI on every community contribution.

---

## Staying up to date

This repo uses [semantic versioning](https://github.com/JLCyb3r/cowork-starter-kit/releases). When a new version ships, check the [Releases](https://github.com/JLCyb3r/cowork-starter-kit/releases) tab. The CHANGELOG lists which presets changed. To update: download the new preset folder and replace only the template files. Your `cowork-profile.md` and `project-instructions.txt` are yours and are never overwritten.

---

## Contribute a preset

Want to add a preset for a use case not covered here? See CONTRIBUTING.md — the templates/preset-template/ folder gives you a ready-to-fill scaffold. All contributions require a DCO sign-off and pass CI automatically.

---

## Star this repo

If this saved you setup time, a star helps other Claude Cowork users find it.

---

## License

MIT — see LICENSE.
