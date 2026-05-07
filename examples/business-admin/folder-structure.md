# Folder Structure — Business/Admin Preset

Your Cowork Project folder for the Business/Admin preset. Create this at:

```
~/Documents/Claude/Projects/business-admin/
```

## Folder tree

```
business-admin/
|-- Inbox/        # Items to triage, review, or act on
|-- Reports/      # Reports, analyses, and summaries
|-- Emails/       # Drafted emails and important correspondence
|-- Meetings/     # Meeting notes, agendas, and follow-ups
|-- Templates/    # Reusable templates for common communication types
```

## Folder descriptions

**Inbox/**
Your daily triage zone. Drop anything that needs attention here — incoming documents, items to review, tasks without a home. Review at the start of each day. Cowork can read this folder and help you prioritize.

**Reports/**
Reports, performance analyses, and summaries. Store incoming reports you need to read and outgoing reports you are producing. Name files clearly: `Reports/q1-revenue-summary.md`.

**Emails/**
Drafts of important emails or email templates you use regularly. Store approved email formats here for reuse.

**Meetings/**
Meeting agendas, notes, and follow-ups. Name by date and topic: `Meetings/2026-04-15-board-prep.md`.

**Templates/**
Reusable communication templates: email formats, report structures, meeting agendas. Customize to match your professional standards and organization's style.

## Creating this structure

**Option A — Run the script (macOS):**

```bash
bash scripts/setup-folders.sh business-admin
```

**Option B — Run the script (Windows):**

```powershell
.\scripts\setup-folders.ps1 business-admin
```

**Option C — Create manually:**

Open Finder or File Explorer and create the folders listed above inside `~/Documents/Claude/Projects/business-admin/`.
