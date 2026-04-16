# Architecture — Claude Cowork Config

## Overview

Claude Cowork Config is a static template repository that provides a goal-driven onboarding wizard for non-technical Claude Cowork users. This document records all architectural decisions as numbered ADRs. The architecture defines the repo structure, delivery mechanism, skill file strategy, versioning model, and CI/CD approach.

**Stack:** No application runtime. Markdown + optional bash scripts. Delivered as a public GitHub repo (ZIP-downloadable).

---

## ADR Index

| ADR | Title | Status |
|-----|-------|--------|
| ADR-001 | Wizard Delivery Mechanism | SUPERSEDED by ADR-006 |
| ADR-002 | Preset Versioning Strategy | ACCEPTED |
| ADR-003 | Skill File Delivery and A2 Assumption Mitigation | SUPERSEDED by ADR-007 |
| ADR-004 | Repository Structure and File Naming Conventions | ACCEPTED |
| ADR-005 | CI/CD Strategy | ACCEPTED |
| ADR-006 | Wizard Delivery Mechanism v1.1 — Three-Layer Trigger Architecture | ACCEPTED |
| ADR-007 | Skill File Format v1.1 — folder/SKILL.md with YAML Frontmatter | ACCEPTED |
| ADR-008 | CI Expansion v1.1 — Starter File and Skill Format Enforcement | ACCEPTED |
| ADR-009 | Wizard UX Format Standard | ACCEPTED |

---

## ADR-001: Wizard Delivery Mechanism

**Date:** 2026-04-14
**Status:** SUPERSEDED by ADR-006 (2026-04-15)

*Retained for historical record. The Cowork-as-wizard primary path (WIZARD.md as runtime entry point) failed in real-world testing on 2026-04-15. See ADR-006 for the replacement architecture.*

**Context:** The wizard (F1 + F2) must guide a non-technical user from "just installed Cowork" to "personalized workspace" in under 15 minutes with zero code required. The delivery must work cross-platform (macOS primary, Windows secondary) and from a ZIP download (no git required).

### Options Considered

**Option A — Pure Markdown Guide (User Reads and Applies Manually)**
- User reads a structured `WIZARD.md` file, answers questions on paper/mentally, then manually selects and copies files from the appropriate preset folder.
- Pros: Maximum compatibility, zero friction, no runtime.
- Cons: No interactivity. User must do all the mapping themselves. Higher cognitive load. Does not feel like a "wizard" — feels like reading documentation. Violates the AC "wizard presents 6 goal cards" (there is no presentation, just text). High drop-off risk for beginners.

**Option B — Bash Interactive Script (`wizard.sh`)**
- Terminal-based interactive script that asks questions via `read -p`, maps answers to a preset, and copies/generates output files to a target directory.
- Pros: Genuine interactivity. Can generate personalized files (profile, global instructions). macOS-native. Scriptable.
- Cons: Requires opening a terminal — violates zero-code for users who fear the terminal. Needs a PowerShell equivalent for Windows (doubles maintenance). ZIP download may lose execute permissions (`chmod +x` required on macOS — another terminal step).

**Option C — Python CLI**
- Python script that runs the wizard via `python wizard.py`.
- Pros: Cross-platform (Python is pre-installed on macOS and available on Windows). Can be sophisticated (fuzzy matching, rich output).
- Cons: "Open terminal, run python" is intimidating for non-technical users. Python version issues on Windows. Dependency management risk. Overkill for what is fundamentally a branching questionnaire.

**Option D — Cowork-as-Wizard (Conversational) + Bash Fallback + Manual Checklist** (RECOMMENDED at time of writing)
- The PRIMARY path uses Claude Cowork itself as the wizard runtime. The user opens the repo folder in Cowork and says "Help me set up" or "Run the setup wizard." A `WIZARD.md` instruction file in the repo root tells Cowork exactly how to conduct the interview.
- A SECONDARY path provides `scripts/setup-folders.sh` (bash).
- A TERTIARY path provides `SETUP-CHECKLIST.md`.

### Decision (v1.0)

**Option D — Cowork-as-Wizard with layered fallbacks.**

### Failure (2026-04-15)

Real-world test: user opened repo in Cowork and said "set up my workspace." Cowork's native intent classifier intercepted the phrase, ran its own built-in setup skill, asked one generic question, and installed a generic productivity plugin. `WIZARD.md` was never read. Root cause: Cowork's intent classifier runs before any project files are read. Passive markdown cannot override intent routing at the system level. See ADR-006.

### Consequences (archived)

- `WIZARD.md` at repo root retained for documentation and contributor reference only — NOT a runtime entry point in v1.1+.

---

## ADR-002: Preset Versioning Strategy

**Date:** 2026-04-14
**Status:** ACCEPTED
**Context:** The repo ships 6 presets at launch. Community contributors will add more. The question is whether to version each preset independently or version the entire repo as a single unit.

### Options Considered

**Option A — Monorepo Single Semver** (RECOMMENDED)
- One `version` field in the repo root (e.g., in `VERSION` file or repo tags). All presets share the version. A change to any preset bumps the repo version.
- Pros: Simple. One version to communicate. GitHub releases are straightforward. Contributors submit PRs against the repo, not individual packages. Users download one ZIP at one version.
- Cons: A typo fix in one preset bumps the version for all presets. No way to express "only the Research preset changed."

**Option B — Per-Preset Semver**
- Each preset folder contains a `VERSION` file or version field in a metadata file. Presets can be updated independently.
- Pros: Granular. Users can track which presets changed. Enables independent release cadence.
- Cons: Overkill for a content repo at v1. Complicates the contribution model (contributors must understand per-preset versioning). ZIP download includes all presets regardless — independent versions have no delivery benefit. GitHub Releases doesn't natively support multi-package repos without tooling.

### Decision

**Option A — Monorepo Single Semver.**

Rationale:
1. This is a content repo, not a package ecosystem. The presets are not independently consumable — they share the wizard, the output format spec, and the safety rules.
2. At v1 with 6 presets, per-preset versioning is premature complexity. If the community grows to 20+ presets, this can be revisited.
3. Version is tracked via git tags (`v1.0.0`, `v1.1.0`) and a `VERSION` file at repo root. GitHub Releases map 1:1 to tags.
4. CHANGELOG.md notes which presets were affected in each release.

### Consequences

- `VERSION` file at repo root contains the current semver string.
- Git tags follow `vX.Y.Z` format.
- CHANGELOG.md uses per-release sections noting affected presets.
- CONTRIBUTING.md instructs contributors to not manage versions — maintainers handle versioning at release time.

---

## ADR-003: Skill File Delivery and A2 Assumption Mitigation

**Date:** 2026-04-14
**Status:** SUPERSEDED by ADR-007 (2026-04-15)

*Retained for historical record. The dual-path delivery decision (flat `.md` + `skills-as-prompts.md` fallback) was superseded after validating that flat `.md` files do not auto-discover as slash commands in Cowork. See ADR-007 for the replacement.*

**Context:** The spec's F5 (Skill/Context File Starter Kit) delivers SKILL.md files stored in `.claude/skills/`. Assumption A2 states this loading behavior is UNTESTED for Cowork — it is only confirmed for Claude Code.

### Decision (v1.0)

**Dual-Path Delivery:** Ship SKILL.md files as primary; include `skills-as-prompts.md` as fallback. Include a validation protocol for A2 before Phase 4.

### Finding (2026-04-15)

User validated A2 in a real Cowork session: flat `.md` files in `.claude/skills/` are readable as prompts but do NOT auto-discover as `/slash-commands`. Running `/skill-creator` on a flat file produces the correct `folder/SKILL.md` format with YAML frontmatter, and the resulting skill auto-discovers as `/skill-name`. The flat format is confirmed broken for the auto-discovery use case. See ADR-007.

### Consequences (archived)

- `skills-as-prompts.md` retained in all 6 presets as copy-paste fallback (last-resort path unchanged).

> **Post-Phase-1 Update (2026-04-15):** A2 assumption resolved via research. Cowork does not auto-discover `.claude/skills/` from filesystem (Claude Code only). Delivery mechanism updated: `.claude/skills/` content is packaged as a ZIP for manual upload via Settings > Customize > Skills. Skill-creator (built-in Cowork meta-skill) is now the primary skill delivery path — the wizard guides users to build personalized skills live during the setup session. Pre-built skill files in preset folders serve as ZIP upload source and reference content.

---

## ADR-004: Repository Structure and File Naming Conventions

**Date:** 2026-04-14
**Status:** ACCEPTED (updated v1.1: new files added to structure — see below)
**Context:** The repo must be navigable by non-technical users downloading a ZIP. File names must be self-explanatory. The structure must support 6 presets at launch and scale to community-contributed presets.

### Decision

```
claude-cowork-config/
|
|-- README.md                          # Product landing page + quick start
|-- WIZARD.md                          # Documentation + script source only (NOT runtime path in v1.1+)
|-- SETUP-CHECKLIST.md                 # Fully manual setup alternative (tertiary path)
|-- CONTRIBUTING.md                    # How to add a new preset
|-- CHANGELOG.md                       # Release history (which presets changed)
|-- LICENSE                            # MIT
|-- VERSION                            # Single semver string (e.g., "1.1.0")
|-- .gitignore
|
|-- .claude/
|   |-- skills/
|       |-- setup-wizard/
|           |-- SKILL.md               # /setup-wizard explicit invocation skill (ships with all downloads)
|
|-- presets/
|   |-- study/
|   |   |-- README.md                  # Preset overview: who it's for, what it configures
|   |   |-- project-instructions-starter.txt  # PRIMARY: paste into Custom Instructions before any conversation
|   |   |-- global-instructions.md     # Full proactive trigger rules (session behavior)
|   |   |-- folder-structure.md        # Documented folder tree for this goal type
|   |   |-- connector-checklist.md     # Recommended connectors with decision helpers
|   |   |-- skills-as-prompts.md       # Last-resort fallback: all skill content as copy-paste snippets
|   |   |-- context/
|   |   |   |-- about-me.md            # User fills in (template with prompts)
|   |   |   |-- working-rules.md       # Pre-filled safe defaults
|   |   |   |-- output-format.md       # Pre-filled per preset
|   |   |-- .claude/
|   |       |-- skills/
|   |           |-- flashcard-generation/
|   |           |   |-- SKILL.md       # name: flashcard-generation, description: ...
|   |           |-- note-taking/
|   |           |   |-- SKILL.md
|   |           |-- research-synthesis/
|   |               |-- SKILL.md
|   |
|   |-- research/   (same structure as study/)
|   |-- writing/    (same structure as study/)
|   |-- project-management/  (same structure as study/)
|   |-- creative/   (same structure as study/)
|   |-- business-admin/  (same structure as study/)
|
|-- scripts/
|   |-- setup-folders.sh               # Bash folder creation (secondary path, macOS)
|   |-- setup-folders.ps1              # PowerShell folder creation (secondary path, Windows)
|
|-- templates/
|   |-- preset-template/               # Blank preset template for contributors
|   |   |-- README.md
|   |   |-- project-instructions-starter.txt  # Template starter file
|   |   |-- global-instructions.md
|   |   |-- folder-structure.md
|   |   |-- connector-checklist.md
|   |   |-- skills-as-prompts.md
|   |   |-- context/
|   |   |   |-- about-me.md
|   |   |   |-- working-rules.md
|   |   |   |-- output-format.md
|   |   |-- .claude/
|   |       |-- skills/
|   |           |-- example-skill/
|   |               |-- SKILL.md       # Template skill with YAML frontmatter
|   |
|   |-- global-instructions-base.md    # Shared safety rules (always included)
|
|-- docs/
|   |-- spec.md                        # Product spec (Phase 0 output)
|   |-- assumptions.md                 # Assumptions register
|   |-- competitive.md                 # Competitive analysis
|   |-- personas.md                    # User personas
|   |-- architecture.md                # This file (ADRs)
|   |-- OUTPUT-STRUCTURE.md            # Documents what the wizard produces
```

### File Naming Conventions

1. **All user-facing files:** lowercase with hyphens, `.md` extension. No spaces, no underscores in file names.
2. **Preset folder names:** lowercase, hyphenated slugs matching the preset name (`study`, `research`, `writing`, `project-management`, `creative`, `business-admin`).
3. **Skill directories:** lowercase, hyphenated, descriptive names (e.g., `research-synthesis/`, `meeting-notes/`). Each skill is a folder containing `SKILL.md`.
4. **Root-level files:** UPPERCASE for standard open-source files (README.md, CONTRIBUTING.md, CHANGELOG.md, LICENSE, VERSION, WIZARD.md, SETUP-CHECKLIST.md). This follows GitHub conventions and ensures visibility.
5. **Context files:** lowercase, hyphenated. Always three files per preset: `about-me.md`, `working-rules.md`, `output-format.md`.
6. **No binary files.** Every file in the repo is plain text (markdown or shell script). No images, PDFs, or compiled artifacts. ASCII diagrams only.
7. **`project-instructions-starter.txt`:** `.txt` extension (not `.md`) because the user pastes its content into Cowork Project Settings > Custom Instructions field — it is not a markdown document, it is plain text.

### Output Package Spec

When the wizard completes, the user's workspace should contain:

```
<user-workspace>/
|-- cowork-profile.md                  # Generated: user's answers + selected preset
|-- project-instructions-starter.txt   # Source: copied from preset (user already pasted before wizard)
|-- .claude/
|   |-- skills/
|       |-- <skill-name>/
|           |-- SKILL.md               # folder/SKILL.md format (auto-discovers as /skill-name)
|-- context/
|   |-- about-me.md
|   |-- working-rules.md
|   |-- output-format.md
|-- <goal-folders>/
|-- connector-checklist.md
|-- SETUP-CHECKLIST.md
```

### Consequences

- Flat, predictable structure — no deeply nested directories beyond the skill folder convention.
- `templates/` directory enables community contributions via CONTRIBUTING.md.
- `templates/global-instructions-base.md` is the single source of truth for the safety rule.
- `.claude/skills/` directories inside presets contain dotfile paths — the `.gitignore` must not exclude them.
- Root-level `.claude/skills/setup-wizard/SKILL.md` ships with every download for universal `/setup-wizard` access.

---

## ADR-005: CI/CD Strategy

**Date:** 2026-04-14
**Status:** ACCEPTED (extended by ADR-008 in v1.1)
**Context:** The repo needs automated quality checks to catch broken links, malformed markdown, and shell script issues. CI runs on GitHub Actions, not the user's machine, so this does not violate the zero-dependency constraint.

### Options Considered

**Option A — No CI**
- Rely on manual review for markdown quality.
- Pros: Zero setup.
- Cons: Broken links and formatting errors will ship. Community contributions are harder to validate.

**Option B — Markdown Lint Only**
- `markdownlint-cli2` via GitHub Actions on push/PR.
- Pros: Catches formatting issues. Low complexity.
- Cons: Doesn't catch broken links — the most common content repo failure mode.

**Option C — Markdown Lint + Link Check + ShellCheck** (RECOMMENDED)
- Three checks in a single GitHub Actions workflow:
  1. `markdownlint-cli2` — validates markdown formatting.
  2. `lychee` — validates all relative and external links.
  3. `shellcheck` — validates bash scripts in `scripts/` (if present).

### Decision

**Option C — Markdown Lint + Link Check + ShellCheck.**

Rationale:
1. Broken relative links are the #1 quality issue in content repos with cross-referenced files.
2. ShellCheck costs nothing to add and catches common bash issues.
3. External link checking runs as a separate job with `continue-on-error: true`.

### Workflow Structure

```yaml
# .github/workflows/quality.yml
name: Quality Checks
on: [push, pull_request]
jobs:
  markdown-lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: DavidAnson/markdownlint-cli2-action@v19
        with:
          globs: '**/*.md'

  link-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: lycheeverse/lychee-action@v2
        with:
          args: --no-progress '**/*.md'
          fail: true

  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ludeeus/action-shellcheck@2.0.0
        with:
          scandir: './scripts'
```

*Note: v1.1 adds three additional jobs. See ADR-008.*

### Consequences

- `.github/workflows/quality.yml` is included in the repo.
- `.markdownlint.jsonc` configuration file at repo root.
- PRs are blocked on markdown lint and internal link check failures.
- External link failures are reported but do not block PRs.
- ShellCheck runs on all `.sh` files in `scripts/`.

---

## ADR-006: Wizard Delivery Mechanism v1.1 — Three-Layer Trigger Architecture

**Date:** 2026-04-15
**Status:** ACCEPTED
**Supersedes:** ADR-001

### Context

**Root cause failure (2026-04-15):** ADR-001 chose Cowork-as-wizard with `WIZARD.md` as the primary runtime path. This failed in the first real-world test. When the user said "set up my workspace," Cowork's native intent classifier intercepted the phrase before reading any project files, ran its own built-in setup skill, asked one generic question, and installed a generic productivity plugin. `WIZARD.md` was never read.

**Why WIZARD.md cannot be a reliable runtime path:** Cowork's intent classifier processes user messages before inspecting project files. A file that describes wizard behavior has no effect until Cowork decides to read it — and the classifier intercepts "set up"-type phrases before that decision is made. No amount of instruction text in WIZARD.md can override this routing.

**What does work:** Custom instructions (Project Settings > Custom Instructions) are injected as system context before Cowork's intent classifier runs. Content in this field cannot be intercepted — it is already in the model context before the first user message is evaluated.

**Word limit constraint (Assumption A1):** Cowork's custom instructions field accepts approximately 400 words without truncation. A ≤300 word target provides a safety margin. The full 11-step wizard script cannot fit in this field. The bootstrap content must be concise.

### Options Considered

**Option A — project-instructions-starter.txt as bootstrap (RECOMMENDED)**
- A short file (~200–300 words) the user pastes into Project Settings > Custom Instructions before any conversation. Contains: (1) a state machine check (does `cowork-profile.md` exist with real content?), (2) a pointer to run the onboarding interview if not, (3) Phase 2 ongoing behavior rules.
- Pros: Custom instructions are system context — cannot be intercepted by the intent classifier. State machine is evaluated on every session start with no user action required. Stays within the word limit.
- Cons: User must paste the file before starting. If they forget, the wizard does not auto-fire. Mitigation: SETUP-CHECKLIST.md Step 1 is now "paste starter file."

**Option B — Override WIZARD.md with stronger invocation text**
- Add "IMPORTANT: Before responding to anything else, read and follow WIZARD.md" to a project README or instructions file.
- Pros: No new file type.
- Cons: Root cause analysis established this cannot work. Cowork's intent classifier runs before project file inspection. Override text in a project file is logically equivalent to WIZARD.md itself — it would also be ignored. This option is ruled out.

**Option C — /setup-wizard skill only (no starter file)**
- Rely entirely on the user explicitly invoking `/setup-wizard`.
- Pros: Guaranteed path — direct skill invocation bypasses the intent classifier.
- Cons: Requires user awareness. Non-technical users may not know to type the command. Does not auto-fire on first session. Appropriate as a fallback, not a primary path.

### Decision

**Three-layer trigger architecture:**

**Layer 1 — Primary: `project-instructions-starter.txt`**
Each preset ships a `project-instructions-starter.txt` file (≤300 words). The user pastes it into Project Settings > Custom Instructions before starting any conversation. Contains a state machine: if `cowork-profile.md` does not exist or contains the placeholder `[Your name]`, auto-run the onboarding interview. If it exists with real content, greet by name and skip onboarding.

This is the primary surface because custom instructions are system context — injected before intent classification, not subject to interception.

**Layer 2 — Explicit fallback: `/setup-wizard` skill**
A proper Cowork skill at `.claude/skills/setup-wizard/SKILL.md` (repo root, ships with every download). Contains YAML frontmatter (`name: setup-wizard`, `description:` present). Self-contained interview script. Explicit `/setup-wizard` invocation routes directly to the skill — Cowork's intent classifier cannot intercept a direct skill call. Used when: starter file was not pasted, user wants to redo setup.

Reset guard: before rerunning the interview, the skill prompts "This will reset your profile and re-run onboarding. Your past sessions are unaffected. Confirm? (Yes / No)."

**Layer 3 — Documentation only: WIZARD.md**
Kept for repo-browser context and contributor reference. Contains the detailed per-preset question scripts (source of truth for interview content) and a top note: "Users: start with `/setup-wizard` or paste `project-instructions-starter.txt`. This file is the script source, not the entry point." WIZARD.md is NOT a runtime path in v1.1+.

### Consequences

- `presets/<name>/project-instructions-starter.txt` exists for all 6 presets at launch.
- Each starter file is ≤300 words to stay within Cowork's custom instructions field limit.
- Each starter file contains Phase 1 (onboarding state machine + interview trigger) and Phase 2 (session-start rules, proactive skill triggers summary, safety rule).
- `.claude/skills/setup-wizard/SKILL.md` ships at repo root with valid YAML frontmatter.
- `SETUP-CHECKLIST.md` Step 1 is: paste `project-instructions-starter.txt` into Project Settings > Custom Instructions — before any conversation.
- `WIZARD.md` receives a documentation-only header note; all "primary path" claims are removed.
- The state machine check (`cowork-profile.md` existence) is evaluated by Cowork on every session start via the custom instructions block.

---

## ADR-007: Skill File Format v1.1 — folder/SKILL.md with YAML Frontmatter

**Date:** 2026-04-15
**Status:** ACCEPTED
**Supersedes:** ADR-003

### Context

**Finding from ADR-003 validation:** User tested A2 (whether Cowork auto-discovers `.claude/skills/` files) in a live Cowork session. Flat `.md` files (e.g., `flashcard-generation.md`) are readable as prompts but do NOT auto-discover as `/slash-commands` in Cowork. This is a Claude Code-only behavior.

**What does work:** Running `/skill-creator` on flat content produces the correct `folder/SKILL.md` format with YAML frontmatter (`name:`, `description:` fields). The resulting skill auto-discovers as `/flashcard-generation`, `/note-taking`, etc. The required format is:

```
.claude/skills/<skill-name>/SKILL.md
```

Where `SKILL.md` contains:
```yaml
---
name: skill-name
description: One-sentence description of what this skill does.
---
[Skill body: instructions + example, ≤250 words]
```

### Options Considered

**Option A — Retain flat .md files, update SETUP-CHECKLIST to instruct /skill-creator**
- Keep `flashcard-generation.md` etc. in the repo; wizard tells users to run `/skill-creator` on each.
- Pros: No file restructuring.
- Cons: Users start from broken flat files and must know to fix them. CI cannot validate skill format. Flat files in the repo set the wrong expectation for community contributors.

**Option B — Ship folder/SKILL.md format directly** (RECOMMENDED)
- Convert all preset skill files to the correct format. Ship pre-built skills that already work. Wizard's `/skill-creator` validation step confirms/improves rather than bootstraps from scratch.
- Pros: Skills auto-discover immediately after upload. Community contributors see the correct format as the canonical example. CI can enforce the format. Better first-run experience.
- Cons: File restructuring required for all 6 presets.

### Decision

**Option B — folder/SKILL.md format for all preset skills.**

Rationale:
1. Auto-discovery on first use is the product promise. Shipping pre-built broken files violates that promise.
2. The `folder/SKILL.md` format is the Cowork canonical format — it should be the source of truth in the repo.
3. CI enforcement (skill-format-check job, see ADR-008) is only possible if the repo itself uses the correct format.
4. `/skill-creator` validation during onboarding becomes a confirm/improve step rather than a repair step.

### Skill Activation Flow During Onboarding

When a user says "Yes" to a skill in the wizard:
1. `project-instructions-starter.txt` instructs Cowork: "Run `/skill-creator` to validate the skill is properly installed."
2. Fallback (if `/skill-creator` is unavailable or deprecated): confirm the skill file exists at `.claude/skills/<skill-name>/SKILL.md`.
3. This fallback must be present in all 6 onboarding scripts. The `/skill-creator` dependency is explicitly logged as UNTESTED in `docs/assumptions.md`.

### Consequences

- All flat `.md` skill files in `presets/*/.claude/skills/` are deleted and replaced with `<skill-name>/SKILL.md` folders.
- Each `SKILL.md` contains: `name:` (slug), `description:` (one sentence), skill body (instructions + examples, ≤250 words).
- `templates/preset-template/.claude/skills/example-skill/SKILL.md` uses this format; the flat `example-skill.md` is removed.
- `skills-as-prompts.md` is RETAINED in all 6 presets as the copy-paste last-resort fallback (unchanged from v1.0).
- SETUP-CHECKLIST.md includes a step-by-step ZIP upload walkthrough for skills (Settings > Customize > Skills > '+', with folder structure requirement).
- CONTRIBUTING.md PR checklist requires all skills in `folder/SKILL.md` format (no flat `.md` files).

---

## ADR-008: CI Expansion v1.1 — Starter File and Skill Format Enforcement

**Date:** 2026-04-15
**Status:** ACCEPTED

### Context

v1.1 introduces two new file types that are required in every preset:
1. `project-instructions-starter.txt` — if absent, the primary trigger path does not exist.
2. `folder/SKILL.md` skill format — if flat `.md` files slip through, skills do not auto-discover.

Community contributions can easily omit these files or use the wrong format without automated enforcement. The v1.0 CI (ADR-005) catches markdown lint and broken links, but has no awareness of these new file surfaces. Three new CI jobs are needed.

### Decision

Add three jobs to `.github/workflows/quality.yml`:

**Job 1 — `starter-file-check`**
Verifies `presets/*/project-instructions-starter.txt` exists for all 6 presets. Blocks PR if absent. This ensures no preset ships without the primary trigger path.

**Job 2 — `starter-safety-rule-check`**
Greps all 6 starter files for the canonical safety rule text ("Always ask for explicit confirmation before deleting, moving, or overwriting any file or folder"). Blocks PR if absent. Parallel to the existing `global-instructions.md` safety-rule check, extended to cover the new starter file surface.

**Job 3 — `skill-format-check`**
Verifies all files under `presets/*/.claude/skills/` follow the `folder/SKILL.md` convention. Specifically: fails if any `.md` file exists directly at the skills directory root (i.e., `presets/*/.claude/skills/*.md` matches — flat file detected). This prevents regression to the v1.0 flat file format.

### Rationale

1. Every new required file surface must have CI enforcement. Manual review cannot reliably catch missing files across 6 presets in community PRs.
2. The safety rule is a non-negotiable product requirement. Extending the safety-rule grep to cover starter files closes a gap — the v1.0 CI only checked `global-instructions.md`.
3. Skill format enforcement prevents the known v1.0 failure mode (flat files that look correct but do not auto-discover) from reappearing in community presets.

### Consequences

- `.github/workflows/quality.yml` gains three new jobs.
- All three jobs block PRs on failure (no `continue-on-error`).
- The starter-safety-rule-check job runs against both `global-instructions.md` AND `project-instructions-starter.txt` for all 6 presets.
- CI now enforces: (1) markdown format, (2) link integrity, (3) shell script safety, (4) safety rule in global-instructions, (5) starter file existence, (6) safety rule in starter files, (7) skill format convention.

---

## ADR-009: Wizard UX Format Standard

**Date:** 2026-04-15
**Status:** ACCEPTED

### Context

The v1.0 wizard used lettered options (A/B/C), a `→ Type a number.` CTA, and a 4-option skill presentation format. The @ux review (Phase 0b) identified specific UX failure points: inconsistent option formats create cognitive overhead; the step counter revealing the full interview length before fast-track causes drop-off; skill presentation with 4 options is too wide for quick scanning. These are not aesthetic preferences — they affect completion rate for the North Star metric.

This ADR establishes the canonical UX format for all presets and all future community contributions.

### Decision

The following format rules are mandatory for all preset wizard questions:

**1. Numbered options universally**
All options use numbered format (1, 2, 3...). No lettered options (A, B, C). The sole exception is "S) Suggest" which is kept as a letter to visually distinguish it from numbered choices. This convention applies to single-select, multi-select, and skill presentation steps.

Rationale: Lettered options conflict with the skill presentation format (which also uses numbers); numbered options are consistent and require no mental mode-switching.

**2. `**Your answer:**` CTA on its own line**
Every question ends with the CTA `**Your answer:**` on its own line. Replaces `→ Type a number.` This is bolder, clearer, and more inviting for non-technical users.

**3. Step counter hides denominator until after fast-track**
Progress display shows "Step N" (not "Step N of 11") until the user passes the fast-track decision point (Step 5). After the user explicitly chooses to continue past fast-track, the denominator is revealed. Rationale: showing "Step 3 of 11" before the user commits to the full interview increases drop-off risk.

**4. Fast-track at Step 5 for all presets**
After Step 5, all 6 presets pause with: "Your basic workspace is ready. 1) Yes, continue — deeper customization  2) Get started now — run `/setup-wizard` later." This addresses the documented tension between Alex persona's tolerance (2–3 questions) and the full 11-step interview.

**5. Skill presentation: 3 options**
Skill offer format: `1. Yes — activate  2. No — skip it  3. Show me more`. Not 4 options. The "Show me a full example" option from the plan is collapsed into "Show me more." Rationale: 4 options creates unnecessary hesitation; "Show me more" covers both discovery needs.

**6. Personalized skill example, no description block**
Each skill step shows a concrete personalized example (using the user's actual subject/role from earlier steps) instead of a generic description block. The example alone conveys value; a description block adds length without insight.

**7. AskUserQuestion heuristic nudge with numbered-list fallback**
Every `project-instructions-starter.txt` must include: "For each wizard question, use AskUserQuestion to present the options as clickable buttons if available. If not available, use the numbered list format below." This is a best-effort heuristic — no AC may require button rendering. Numbered list format is the guaranteed delivery target; buttons are a stretch enhancement.

**8. "S) Suggest" on knowledge-gap questions only**
The "S) Suggest" escape hatch appears only on questions where there is an objectively better answer based on context (study method, output format, tools, skill selection). It does NOT appear on personal preference questions (name, creative constraints, tone preferences).

**9. Free-text tolerance**
If the user answers with words instead of a number, the wizard matches intent, states the interpretation in one sentence, and proceeds. Does not re-ask. Example: "Got it — I'm treating that as [X]. Moving on."

**10. "You choose" response format**
When user says "you choose" / "suggest" / "not sure": one concrete recommendation + one-sentence reason, then "Sound right?" Does not re-list options.

**11. "Show me more" latency acknowledgment**
When user selects option 3 on a skill step, wizard immediately says "Generating an example — just a moment..." before producing the longer content.

**12. Time estimate at fast-track**
Fast-track pause uses "a few more minutes" not an exact number.

### Applicability

These rules are the canonical UX standard for:
- All 6 v1.1 presets
- WIZARD.md question scripts
- Future community-contributed presets (enforced via CONTRIBUTING.md PR checklist)
- Any future preset template updates

### Consequences

- All 6 presets' `project-instructions-starter.txt` and WIZARD.md question scripts are written to this spec.
- CONTRIBUTING.md PR checklist gains a UX format compliance check item.
- The spec format rules in this ADR supersede any conflicting question format guidance in the plan document.
- Numbered list is always designed as primary; AskUserQuestion buttons are designed as a bonus layer only.

---

## Anti-Pattern Scan

For a static template repository, most architect anti-patterns are inapplicable. Brief assessment:

| # | Anti-Pattern | Applies? | Notes |
|---|-------------|----------|-------|
| 1 | Over-engineering schema | No | No database. No schema. |
| 2 | Missing RLS policies | No | No database. No row-level security needed. |
| 3 | God table | No | No tables. |
| 4 | Premature optimization | No | No runtime performance concerns. Checked: preset versioning kept simple (ADR-002). |
| 5 | Missing indexes | No | No database. |
| 6 | Stringly-typed data | Watched | File naming conventions (ADR-004) serve as the "type system." Preset folder names are canonical identifiers — CI enforces consistency. Skill folder names must match their `name:` frontmatter value. |
| 7 | Circular dependencies | Watched | `WIZARD.md` references presets which reference `templates/global-instructions-base.md`. Dependency is one-directional (wizard -> presets -> templates). No cycles. |
| 8 | Missing audit trail | Partially | CHANGELOG.md + git history serve as the audit trail. VERSION file is the versioning mechanism. |
| 9 | Undocumented assumptions | Addressed | A1 (word limit) and `/skill-creator` stability are the critical v1.1 assumptions. Both are logged in `docs/assumptions.md` with fallback paths. |

No anti-patterns detected. The architecture is appropriately simple for a static content repository.

---

## Safety Architecture

The safety rule ("Always ask for explicit confirmation before deleting, moving, or overwriting any file or folder") is enforced at four layers:

1. **Template layer:** `templates/global-instructions-base.md` contains the canonical safety rule text. This file is the single source of truth.
2. **Preset layer:** Every preset's `global-instructions.md` must include the base template content. The CONTRIBUTING.md guide makes this a hard requirement for new presets.
3. **Starter file layer (NEW in v1.1):** Every `project-instructions-starter.txt` must contain the safety rule verbatim in the Phase 2 ongoing behavior block. This is the primary runtime surface — having the safety rule here means it is active from the first session.
4. **CI layer:** Two CI jobs enforce the safety rule — the existing `safety-rule-check` (global-instructions.md) and the new `starter-safety-rule-check` (project-instructions-starter.txt). PRs are blocked if either check fails.

v1.1 strengthens the safety architecture by extending enforcement to the primary runtime surface. The v1.0 layer (wizard layer referencing WIZARD.md) is deprecated since WIZARD.md is no longer a runtime path.
