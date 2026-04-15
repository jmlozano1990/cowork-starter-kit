# Output Structure — Claude Cowork Config

This document describes the files the wizard produces and where they should be placed in the user's Cowork workspace.

## Generated Output

After completing the wizard (via any of the three paths: Cowork-as-wizard, bash script, or manual checklist), the user's workspace should contain the following files:

```
<your-cowork-workspace>/
|
|-- cowork-profile.md                  # Your answers and selected goal preset
|-- project-instructions.txt           # Personalized instructions to paste into Cowork Project Settings
|
|-- .claude/
|   |-- skills/
|       |-- <skill-1>.md               # 3-5 skill files from your preset
|       |-- <skill-2>.md
|       |-- <skill-3>.md
|
|-- context/
|   |-- about-me.md                    # Fill in your details (template with prompts)
|   |-- working-rules.md              # Pre-filled rules for safe, consistent AI behavior
|   |-- output-format.md              # Pre-filled output preferences for your goal type
|
|-- <goal-specific-folders>/           # Folder structure for your preset
|   |-- (varies by preset — see your preset's folder-structure.md)
|
|-- connector-checklist.md             # Which Cowork connectors to enable and why
|-- SETUP-CHECKLIST.md                 # Steps to finish setup in Cowork's native UI
```

## File Descriptions

| File | Format | Source | User Action Required |
|------|--------|--------|---------------------|
| `cowork-profile.md` | Markdown | Generated from wizard answers | Review (read-only) |
| `project-instructions.txt` | Plain text | Generated from preset + answers | Copy-paste into Cowork Project Settings > Custom Instructions |
| `.claude/skills/*.md` | Markdown | Copied from preset | None (auto-loaded if supported) |
| `context/about-me.md` | Markdown | Template from preset | Fill in your details |
| `context/working-rules.md` | Markdown | Pre-filled from preset | Review, edit if needed |
| `context/output-format.md` | Markdown | Pre-filled from preset | Review, edit if needed |
| `connector-checklist.md` | Markdown | Copied from preset | Work through checklist in Cowork UI |
| `SETUP-CHECKLIST.md` | Markdown | Copied from repo | Follow step by step |

## Important Notes

- `project-instructions.txt` is plain text, not markdown. Copy its entire content into Cowork Project Settings > Custom Instructions field.
- Every `project-instructions.txt` file includes the safety rule: "Always ask for explicit confirmation before deleting, moving, or overwriting any file." Do not remove this line.
- If skill files are not automatically loaded by Cowork, see `skills-as-prompts.md` in your preset folder for a copy-paste alternative.
