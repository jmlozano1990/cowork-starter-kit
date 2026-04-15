# Folder Structure — Creative Preset

Your Cowork Project folder for the Creative preset. Create this at:

```
~/Documents/Claude/Projects/creative/
```

## Folder tree

```
creative/
|-- Projects/      # One subfolder per active creative project
|-- Inspiration/   # References, mood boards, screenshots, notes on what inspires you
|-- Drafts/        # Working drafts and iterations
|-- Assets/        # Source files, images, documents, and other production assets
|-- Archive/       # Completed or paused projects
```

## Folder descriptions

**Projects/**
One subfolder per active creative project: `Projects/brand-identity-client-a/`, `Projects/short-film-2026/`. Each project folder should contain a brief, working notes, and in-progress files.

**Inspiration/**
A collection of references, screenshots, notes, and links that inspire your current work. Cowork can read text files here and help you identify patterns or generate directions from your collected references.

**Drafts/**
Iterations and working drafts across projects. Version as needed: `Drafts/logo-v3.md` or `Drafts/concept-note-v2.md`.

**Assets/**
Source documents, images, production files, and other assets for active projects. Cowork can read text-based files here (PDFs, markdown, text).

**Archive/**
Completed or paused projects. Move here when a project wraps to keep Projects/ focused on active work.

## Creating this structure

**Option A — Run the script (macOS):**

```bash
bash scripts/setup-folders.sh creative
```

**Option B — Run the script (Windows):**

```powershell
.\scripts\setup-folders.ps1 creative
```

**Option C — Create manually:**

Open Finder or File Explorer and create the folders listed above inside `~/Documents/Claude/Projects/creative/`.
