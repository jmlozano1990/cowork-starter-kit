# Folder Structure — Project Management Preset

Your Cowork Project folder for the Project Management preset. Create this at:

```
~/Documents/Claude/Projects/project-management/
```

## Folder tree

```
project-management/
|-- Active-Projects/   # One subfolder per active project
|-- Archive/           # Completed or paused projects
|-- Templates/         # Reusable templates for status updates, briefs, etc.
|-- Meeting-Notes/     # Captured notes from all project meetings
|-- Inbox/             # Incoming tasks, requests, or items to triage
```

## Folder descriptions

**Active-Projects/**
One subfolder per active project: `Active-Projects/website-relaunch/`, `Active-Projects/q2-roadmap/`. Each project folder should contain its status doc, risk register, and any working files.

**Archive/**
Projects that are complete, paused, or cancelled. Move projects here when they conclude to keep Active-Projects/ clean.

**Templates/**
Reusable templates: status update format, meeting note format, RACI, project brief. Customize the templates in your Templates/ folder to match your organization's standards.

**Meeting-Notes/**
A single folder for all meeting notes, named by date and project: `Meeting-Notes/2026-04-15-website-relaunch-kickoff.md`. Cowork can read these to help you track decisions and action items.

**Inbox/**
A holding area for new requests, tasks, or items that have not yet been assigned to a project. Review and triage this folder at the start of each work day.

## Creating this structure

**Option A — Run the script (macOS):**

```bash
bash scripts/setup-folders.sh project-management
```

**Option B — Run the script (Windows):**

```powershell
.\scripts\setup-folders.ps1 project-management
```

**Option C — Create manually:**

Open Finder or File Explorer and create the folders listed above inside `~/Documents/Claude/Projects/project-management/`.
