# Folder Structure — Study Preset

Your Cowork Project folder for the Study preset. Create this at:

```
~/Documents/Claude/Projects/study/
```

## Folder tree

```
study/
|-- Papers/          # PDFs and documents you are reading or have read
|-- Notes/           # Processed study notes by topic or course
|-- Flashcards/      # Generated flashcard sets for exam prep
|-- Assignments/     # Active and completed assignments
|-- Resources/       # Reference materials, syllabi, reading lists
```

## Folder descriptions

**Papers/**
Store all PDFs, papers, and reading materials here. Give files descriptive names (e.g., `smith-2024-climate-feedback.pdf`). Cowork can read these and help you synthesize them.

**Notes/**
Processed notes from your reading and study sessions. Organize by course or topic. Example: `Notes/biochemistry-metabolism.md`.

**Flashcards/**
Flashcard sets generated from your study material. Use the flashcard-generation skill to populate this folder from your notes or papers.

**Assignments/**
Active assignments you are working on. Keep one file per assignment with a clear name (e.g., `Assignments/essay-protein-folding.md`).

**Resources/**
Syllabi, reading lists, reference sheets, and any other materials that are not primary sources but support your study.

## Creating this structure

**Option A — Run the script (macOS):**

```bash
bash scripts/setup-folders.sh study
```

**Option B — Run the script (Windows):**

```powershell
.\scripts\setup-folders.ps1 study
```

**Option C — Create manually:**

Open Finder or File Explorer and create the folders listed above inside `~/Documents/Claude/Projects/study/`.
