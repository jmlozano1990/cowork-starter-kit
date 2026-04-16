# Output Structure — Claude Cowork Config

This document describes the files the wizard produces and where they should be placed in the user's Cowork workspace.

## Primary Output Artifact

**`project-instructions-starter.txt`** is the primary output. It is pasted into Cowork Project Settings > Custom Instructions **before** any conversation. This file is the system context that triggers onboarding automatically on first session.

Each preset ships a pre-built `project-instructions-starter.txt` — the user pastes it before starting. After the onboarding interview completes, Cowork generates the remaining output files below.

## Generated Output

After completing the onboarding interview (via `/setup-wizard` or auto-triggered by `project-instructions-starter.txt`), the user's workspace should contain the following files:

```
<your-cowork-workspace>/
|
|-- cowork-profile.md                  # Your answers and selected goal preset (generated)
|-- project-instructions-starter.txt   # System context already pasted into Project Settings
|
|-- .claude/
|   |-- skills/
|       |-- <skill-name>/
|           |-- SKILL.md               # folder/SKILL.md format (auto-discovers as /<skill-name>)
|
|-- context/
|   |-- about-me.md                    # Fill in your details (template with prompts)
|   |-- working-rules.md               # Pre-filled rules for safe, consistent AI behavior
|   |-- output-format.md               # Pre-filled output preferences for your goal type
|
|-- <goal-specific-folders>/           # Folder structure for your preset
|   |-- (varies by preset — see your preset's folder-structure.md)
|
|-- connector-checklist.md             # Which Cowork connectors to enable and why
|-- SETUP-CHECKLIST.md                 # Steps to finish setup in Cowork's native UI
|-- skills-as-prompts.md               # Copy-paste fallback if skill upload unavailable
```

## File Descriptions

| File | Format | Source | User Action Required |
|------|--------|--------|---------------------|
| `project-instructions-starter.txt` | Plain text | Pre-built per preset | Paste into Project Settings > Custom Instructions BEFORE any conversation |
| `cowork-profile.md` | Markdown | Generated from wizard answers | Review (read-only) |
| `.claude/skills/<name>/SKILL.md` | Markdown | Pre-built per preset | Upload as ZIP via Settings > Customize > Skills |
| `context/about-me.md` | Markdown | Template from preset | Fill in your details |
| `context/working-rules.md` | Markdown | Pre-filled from preset | Review, edit if needed |
| `context/output-format.md` | Markdown | Pre-filled from preset | Review, edit if needed |
| `connector-checklist.md` | Markdown | Copied from preset | Work through checklist in Cowork UI |
| `skills-as-prompts.md` | Markdown | Copied from preset | Use as copy-paste fallback if skill ZIP upload fails |
| `SETUP-CHECKLIST.md` | Markdown | Copied from repo | Follow step by step |

## Important Notes

- `project-instructions-starter.txt` is plain text, not markdown. It is pasted into Cowork Project Settings > Custom Instructions — not opened as a project file.
- Every `project-instructions-starter.txt` includes the safety rule verbatim: "Always ask for explicit confirmation before deleting, moving, or overwriting any file or folder." Do not remove this line.
- Skill files use `folder/SKILL.md` format (not flat `.md`). This is the Cowork-native format that enables auto-discovery as `/slash-commands` after ZIP upload.
- If skill upload is unavailable, `skills-as-prompts.md` in your preset folder provides all skill content as copy-paste prompt snippets.
- The state machine check in `project-instructions-starter.txt` uses the presence and content of `cowork-profile.md` to detect first vs. returning sessions. Do not delete `cowork-profile.md` after setup.
