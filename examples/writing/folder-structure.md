# Folder Structure — Writing Preset

Your Cowork Project folder for the Writing preset. Create this at:

```
~/Documents/Claude/Projects/writing/
```

## Folder tree

```
writing/
|-- Drafts/            # Works in progress — one file per piece
|-- Published/         # Finished and published work
|-- Ideas/             # Idea notes, headlines, concepts to develop
|-- Research/          # Background research and reference material
|-- Voice-and-Style/   # Writing samples that define your voice
```

## Folder descriptions

**Drafts/**
Active works in progress. One file per piece. Use descriptive names: `Drafts/newsletter-issue-42.md`. Keep old versions with a version suffix if needed: `Drafts/essay-v1.md`, `Drafts/essay-v2.md`.

**Published/**
Finished and published pieces. Archive here once something goes live. Useful for voice-matching if you want Cowork to write in your established style.

**Ideas/**
Raw ideas — headlines, hooks, concepts you want to develop later. A single line per idea is fine. Review this folder at the start of each writing session.

**Research/**
Background research for pieces in progress. Link research files to their corresponding draft with a naming convention: `Research/newsletter-issue-42-sources.md`.

**Voice-and-Style/**
The most important folder. Store 2-5 pieces of your best existing writing here. Cowork uses these to match your voice when generating new content. Include a `voice-notes.md` file with notes about your style if you want to be explicit.

## Creating this structure

**Option A — Run the script (macOS):**

```bash
bash scripts/setup-folders.sh writing
```

**Option B — Run the script (Windows):**

```powershell
.\scripts\setup-folders.ps1 writing
```

**Option C — Create manually:**

Open Finder or File Explorer and create the folders listed above inside `~/Documents/Claude/Projects/writing/`.
