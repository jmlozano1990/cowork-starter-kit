# Folder Structure — Research Preset

Your Cowork Project folder for the Research preset. Create this at:

```
~/Documents/Claude/Projects/research/
```

## Folder tree

```
research/
|-- Literature/      # All source PDFs, papers, and articles
|-- Notes/           # Processed notes and annotations by topic
|-- Drafts/          # Working drafts of papers, reviews, or reports
|-- Data/            # Datasets, raw data, or data exports
|-- References/      # Bibliography files, citation exports, reading lists
```

## Folder descriptions

**Literature/**
Store all primary source PDFs and documents here. Name files descriptively: `smith-2024-climate-feedback.pdf`. Cowork can read these directly to synthesize or analyze them.

**Notes/**
Processed notes from your reading sessions. Organize by topic or research thread. Example: `Notes/literature-review-climate-feedback.md`.

**Drafts/**
Working drafts of papers, literature reviews, or reports. Use versioned names if you want to track revisions: `Drafts/review-v1.md`, `Drafts/review-v2.md`.

**Data/**
Datasets, exported data, or raw quantitative material. Cowork can help you describe, analyze, or summarize data stored here.

**References/**
Bibliography files (e.g., `.bib` files), reading lists, and citation exports from Zotero or other reference managers.

## Creating this structure

**Option A — Run the script (macOS):**

```bash
bash scripts/setup-folders.sh research
```

**Option B — Run the script (Windows):**

```powershell
.\scripts\setup-folders.ps1 research
```

**Option C — Create manually:**

Open Finder or File Explorer and create the folders listed above inside `~/Documents/Claude/Projects/research/`.
