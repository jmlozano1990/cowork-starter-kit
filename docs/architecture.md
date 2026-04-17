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
| ADR-004 | Repository Structure and File Naming Conventions | ACCEPTED (updated v1.2) |
| ADR-005 | CI/CD Strategy | ACCEPTED |
| ADR-006 | Wizard Delivery Mechanism v1.1 — Three-Layer Trigger Architecture | ACCEPTED (extended by ADR-010) |
| ADR-007 | Skill File Format v1.1 — folder/SKILL.md with YAML Frontmatter | ACCEPTED |
| ADR-008 | CI Expansion v1.1 — Starter File and Skill Format Enforcement | ACCEPTED |
| ADR-009 | Wizard UX Format Standard | ACCEPTED (extended by v1.2) |
| ADR-010 | CLAUDE.md as Universal Dynamic Wizard Entry Point (v1.2) | ACCEPTED |
| ADR-011 | Dynamic Wizard State Machine and Word Budget Architecture | ACCEPTED |
| ADR-012 | Skill Discovery Hybrid Architecture — Tier 1/Tier 2 Model | ACCEPTED |
| ADR-013 | Writing Profile Architecture — Universal Artifact for All Workspaces | ACCEPTED |
| ADR-014 | CI Expansion v1.2 — Writing Profile Template Enforcement | ACCEPTED |

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

v1.2 adds a fifth layer: the writing profile trigger rule in `global-instructions.md` for all 6 presets reinforces voice-consistency behavior whenever Cowork produces written output.

---

## ADR-010: CLAUDE.md as Universal Dynamic Wizard Entry Point (v1.2)

**Date:** 2026-04-17
**Status:** ACCEPTED
**Extends:** ADR-006 (Three-Layer Trigger Architecture — layers 2 and 3 unchanged)

### Context

**v1.1 trigger architecture:** The primary trigger path is `project-instructions-starter.txt` (pasted by the user into Project Settings > Custom Instructions before any conversation). CLAUDE.md at the repo root was introduced in v1.1.1 as an additional surface: when a user opens the repo folder as a Cowork Project, CLAUDE.md is auto-loaded as system context — without the user needing to paste anything. This is confirmed working behavior (plan validation, 2026-04-17).

**v1.2 driver:** The dynamic wizard is more complex than the v1.1 preset-selector. It now has: open-ended goal discovery, a suggestion branch for uncertain users, preset detection + accelerator offer, novel-goal handling, writing profile step, and skill discovery. All of this must be reachable for users who open the repo folder in Cowork without any prior configuration step — including users who have never used Cowork before and don't know to paste a starter file.

**The tension:** The spec requires per-preset `project-instructions-starter.txt` files to contain the full dynamic wizard flow (F1 AC, F3 AC). The plan establishes CLAUDE.md as the universal entry point. These are not mutually exclusive — they serve different user segments. The architecture must define which is primary and how they relate.

### Options Considered

**Option A — CLAUDE.md primary, starter files preset-specific summary only**
- CLAUDE.md contains the full dynamic wizard flow (up to word budget). Starter files contain a shorter preset-specific setup block that assumes CLAUDE.md has already run. Users who forgot to set up CLAUDE.md-based project still get a functional but simpler path.
- Pros: CLAUDE.md does the heavy lifting automatically. Starter files remain short (within v1.1's ≤300 word budget). No duplication of dynamic wizard logic.
- Cons: Users who use only a starter file (downloaded ZIP, new Cowork project, not using the repo folder) get a less dynamic experience. The two surfaces diverge architecturally.

**Option B — Both surfaces contain the full dynamic wizard (RECOMMENDED)**
- CLAUDE.md at repo root contains the full dynamic wizard (≤350 words — same budget as starter files). Per-preset `project-instructions-starter.txt` files also contain the full dynamic wizard. Both surfaces are functionally equivalent. The user gets the dynamic wizard regardless of which path they take.
- Pros: No degraded path. A user who downloads the ZIP, creates a Cowork project, and pastes any starter file gets the same dynamic wizard as a user who opens the repo folder directly. Consistent behavior = easier testing, easier documentation, easier community contributions.
- Cons: Duplication of wizard logic across 7 files (1 CLAUDE.md + 6 starter files). Any change to the wizard must propagate to all 7 files. Mitigated by: WIZARD.md as the authoritative script source; CI enforcement of required sections.

**Option C — CLAUDE.md only, deprecate per-preset starter files**
- Remove per-preset `project-instructions-starter.txt` files. CLAUDE.md is the single wizard surface. Presets are accessed entirely through the dynamic wizard (preset detection path).
- Pros: Single source of truth. No synchronization problem.
- Cons: Breaks the use case where a user wants a preset-specific setup without using the repo folder. Removes the ability to distribute individual presets. Violates F1/F3 ACs which require starter files for all 6 presets.

### Decision

**Option B — Both surfaces contain the full dynamic wizard.**

Rationale:
1. The spec's F1 AC explicitly requires `project-instructions-starter.txt` to exist for all 6 presets AND contain the dynamic wizard flow. Option C is ruled out by spec.
2. The duplication problem (Option B con) is manageable: WIZARD.md remains the authoritative script source. Starter files and CLAUDE.md are runtime projections of the same script. CONTRIBUTING.md PR checklist enforces both surfaces are updated together.
3. Consistent behavior across paths reduces QA burden. One smoke-test procedure covers both entry points.
4. Option A creates a two-tier user experience where a ZIP-download user gets a lesser wizard. For a product targeting non-technical users who may not know how to open a folder in Cowork, this is a critical failure mode.

### Layer Architecture Update (v1.2)

The three-layer architecture from ADR-006 remains intact. Layer 1 now has two parallel surfaces:

**Layer 1a — Auto-load: `CLAUDE.md` at repo root**
Cowork auto-loads `CLAUDE.md` as system context when the user opens the repo folder as a Cowork Project. No user action required. Contains the full dynamic wizard (≤350 words). This is the zero-friction path for users who open the repo directly.

**Layer 1b — Manual paste: `project-instructions-starter.txt` (per preset)**
User pastes content into Project Settings > Custom Instructions before any conversation. Contains the full dynamic wizard (≤350 words). Functionally identical to Layer 1a. This is the path for users who create a fresh Cowork project and want a preset-flavored starting point.

**Layer 2 — Explicit fallback: `/setup-wizard` skill (unchanged from v1.1)**
Direct `/setup-wizard` invocation routes to the skill. Used when neither Layer 1 path was configured, or when user wants to redo setup.

**Layer 3 — Documentation only: `WIZARD.md` (unchanged from v1.1)**
Contains the authoritative interview script for all presets. Not a runtime path.

### Content Relationship

Both Layer 1a and Layer 1b files contain:
1. State machine check (cowork-profile.md existence test)
2. Open-ended goal discovery opener
3. Suggestion branch logic (response to uncertainty)
4. Preset detection + accelerator offer
5. Writing profile step (3–4 questions)
6. Pointer to /setup-wizard for full interview continuation
7. Safety rule verbatim
8. AskUserQuestion nudge

CLAUDE.md is universal (no preset-specific interview content — that lives in WIZARD.md and is invoked via /setup-wizard).
Per-preset starter files add preset-specific context hints (e.g., "This is the Study starter — I'll suggest study-specific tools") but the wizard flow is otherwise identical.

### Consequences

- `CLAUDE.md` at repo root is updated to the dynamic wizard format (≤350 words). It replaces the current v1.1.1 preset-selector content.
- All 6 `presets/*/project-instructions-starter.txt` files are updated with the dynamic wizard flow (≤350 words each).
- Both surfaces must contain the safety rule verbatim. Existing CI jobs `claude-md-safety-rule-check` and `starter-safety-rule-check` enforce this.
- WIZARD.md remains the authoritative script source. Layer 1 surfaces are concise bootstrap; WIZARD.md contains the full per-preset interview scripts.
- The word budget for both surfaces is ≤350 words (increased from ≤300 in v1.1). This was validated as the right budget for dynamic branching in the spec (F3). A1 assumption (Cowork field limit) remains UNTESTED at 350 words — fallback to split architecture applies if actual limit is proven <300 words.

---

## ADR-011: Dynamic Wizard State Machine and Word Budget Architecture

**Date:** 2026-04-17
**Status:** ACCEPTED

### Context

The v1.2 dynamic wizard adds three new behaviors that must fit within the 350-word budget for CLAUDE.md and each starter file:

1. **Open-ended goal discovery** (replaces preset menu): First question is "What would you like to use this workspace for?" — free text, not numbered menu.
2. **Suggestion branch**: If the user responds with uncertainty ("not sure", "maybe", "something like"), the wizard must offer 3 concrete direction options before proceeding.
3. **Preset detection**: If the user's goal matches one of the 6 presets, the wizard offers the preset as a scaffold before proceeding with the customization interview.
4. **Novel goal handling**: If the goal matches no preset, the wizard acknowledges this and proposes a custom build.
5. **Writing profile step**: Universal 3–4 question step for all goals (not just Writing preset).

Fitting all of this, plus the state machine check, safety rule, and AskUserQuestion nudge, into 350 words requires explicit word budget allocation.

### Word Budget Analysis

The v1.1 starter file (≤300 words) contains:
- State machine check + onboarding trigger: ~60 words
- Preset menu + interview dispatch: ~100 words
- Ongoing behavior summary: ~80 words
- Safety rule: ~15 words
- AskUserQuestion nudge: ~20 words
- Total: ~275 words

The v1.2 additions requiring budget:
- Suggestion branch logic: ~40 words
- Preset detection + accelerator offer phrasing: ~30 words
- Novel goal handling: ~20 words
- Writing profile step (3–4 questions): ~60 words
- Total additions: ~150 words

The preset-specific interview steps are REMOVED from the starter file (they move to WIZARD.md, invoked via /setup-wizard). This recovers ~80 words. Net budget change: +70 words. 300 + 70 = 370 words — slightly over the 350 target.

### Options Considered

**Option A — Compress interview dispatch, keep all branches inline**
Compress the interview dispatch to a pointer ("For the full interview, I'll use the preset scripts — starting now…") rather than embedding step content. Move all per-preset interview steps to WIZARD.md. Inline the suggestion branch and preset detection but not the step-by-step interview.
- Pros: Fits in 350 words. Starter file is a bootstrap + branch controller, not an interview runner.
- Cons: Requires /setup-wizard or WIZARD.md content to be accessible during the first session. This works because /setup-wizard skill is universally available.

**Option B — Increase word budget to 400 words**
Accept that dynamic wizard content requires 400 words and raise the budget.
- Pros: All content inline. No indirection.
- Cons: Assumption A1 (field limit) is untested at 400 words. The A1 validation path calls for testing at 300, 350, and 400 — but until tested, 400 words is a risk. The 350 target exists specifically to maintain a safety margin below the ~400-word estimated limit. Raising to 400 eliminates the margin.

**Option C — Split architecture (state machine + pointer only, full script in WIZARD.md)** (FALLBACK)
Keep CLAUDE.md and starter files at ≤150 words (state machine check + pointer only). Full wizard script (goal discovery, suggestion branch, preset detection, writing profile, interview) lives in WIZARD.md and is invoked by pointer reference.
- Pros: Fits any field limit, even very short ones.
- Cons: Requires CLAUDE.md to reference WIZARD.md — but ADR-001's root cause failure showed that project files may not be accessible in all contexts. Pointer approach reintroduces the v1.0 failure risk. Only valid as an escalation fallback when A1 validates limit <300 words.

### Decision

**Option A — Compressed inline bootstrap (≤350 words) with full interview in WIZARD.md.**

Rationale:
1. 350 words is the validated target (spec F3, assumption A1 safety margin). Option B eliminates the safety margin without new evidence.
2. Option A is architecturally cleaner: the starter file is a state controller, not an interview runner. The interview content belongs in WIZARD.md (the authoritative source per ADR-006 Layer 3).
3. /setup-wizard skill is universally available (confirmed in v1.1) — the pointer-to-skill pattern is proven. The v1.0 failure was pointer-to-passive-file (WIZARD.md not always read); pointer-to-skill-invocation is different and reliable.
4. Option C is preserved as the escalation path if A1 validation fails.

### State Machine Design

The CLAUDE.md / starter file state machine follows this logic, encoded in ≤350 words:

```
PHASE 1 — SESSION START CHECK
  IF cowork-profile.md absent OR contains "[Your name]":
    → Run onboarding (go to PHASE 2)
  ELSE:
    → Greet by name, surface deadlines <7 days, ask what to work on today

PHASE 2 — GOAL DISCOVERY
  Ask: "What would you like to use this workspace for?"
  
  IF response is uncertain ("not sure", "maybe", "I think", "something like"):
    → SUGGESTION BRANCH: offer 3 directions
      1. [Study / Learning] — e.g., exam prep, reading comprehension, research
      2. [Work / Projects] — e.g., project tracking, reports, stakeholder updates
      3. [Writing / Creating] — e.g., articles, content, storytelling
      Say: "Which fits closest? Or describe your actual goal and I'll match it."
  
  IF response matches a preset (study, research, writing, PM, creative, business-admin):
    → PRESET ACCELERATOR: "That sounds like [Preset]. I have a great starting point —
       want me to customize it for you?  1) Yes — use [Preset] as a starting point  
       2) No — build from scratch"
    IF yes: load preset scaffold, proceed to PHASE 3
    IF no: proceed to PHASE 3 with novel flow
  
  IF response is a novel goal (no preset match):
    → "Interesting — I'll build a workspace for [goal] from scratch."
    → Proceed to PHASE 3 with novel flow

PHASE 3 — PROFILE + WRITING PROFILE (3–4 questions each)
  → Name, role/context
  → Writing tone, audience, preferences, optional sample
  → Fast-track offer: "Basic workspace ready. 1) Continue  2) Get started now"

PHASE 4 — FULL INTERVIEW (via /setup-wizard or WIZARD.md)
  → Workspace design, skills, folder structure
```

### Consequences

- CLAUDE.md and starter files contain the state machine + PHASE 2 branch logic + PHASE 3 questions inline (fits ≤350 words).
- PHASE 4 content (workspace design, skills, folder structure) is in WIZARD.md and accessible via `/setup-wizard` invocation.
- The suggestion branch uses the exact 3 directions shown above — not dynamically generated, because dynamic generation would require prose instructions that exceed the word budget.
- Preset detection uses keyword matching: if the user's goal contains "study", "exam", "course", "research", "literature", "writing", "article", "blog", "project", "PM", "creative", "design", "business", "admin", "email" — map to the closest preset and offer it.
- Novel goals receive an explicit acknowledgment and proceed to /setup-wizard for the custom build flow.
- Fallback escalation: if A1 validation proves Cowork field limit is <300 words, revert to Option C (state machine only, pointer to /setup-wizard).

---

## ADR-012: Skill Discovery Hybrid Architecture — Tier 1/Tier 2 Model

**Date:** 2026-04-17
**Status:** ACCEPTED

### Context

v1.1 shipped 3 static skills per preset (18 total). They are correct-format, curated, and safe. v1.2 must evolve skill discovery to: (1) dynamically recommend skills based on detected goal, (2) surface community skills with safety vetting, and (3) support novel goals that have no pre-bundled skills.

**Security constraint (non-negotiable, confirmed by D3):** Repello AI and Snyk ToxicSkills research (2026) confirms 13.4% critical security issue rate in community skills, 36% prompt injection rate. A default-open community skill discovery mode is unacceptable. The architecture must enforce curated-first with opt-in for broader discovery.

**Static file constraint:** No runtime network calls are permitted during wizard execution. The repo is a static markdown collection. Any skill discovery that requires a live API call to GitHub, skills.sh, or any external registry must be deferred to explicit user opt-in with documented manual steps — the wizard itself cannot execute HTTP requests.

### Options Considered

**Option A — Curated only (expand registry, no Tier 2)**
Ship only curated skills with an expanded registry. No community skill discovery at all.
- Pros: Zero security surface from unvetted skills. Simple to reason about.
- Cons: Novel goals get no skill recommendations (E4 edge case). Power users are blocked from the broader ecosystem. Community contribution path is limited to preset PRs (high-friction). D2 assumption shows the broader skill ecosystem exists and is valuable.

**Option B — Live GitHub scan (no curation layer)**
Wizard searches GitHub live at wizard runtime for matching skills.
- Pros: Always fresh. Can find skills for any goal.
- Cons: Requires network calls during wizard execution — impossible in static markdown context. Security research confirms this approach exposes users to 13.4% critical risk without vetting. Not feasible for this stack.

**Option C — Hybrid: curated registry (Tier 1) + opt-in community scan (Tier 2)** (RECOMMENDED)
Two-tier model: Tier 1 is a static curated registry shipped in the repo. Tier 2 is an explicit opt-in where the wizard instructs the user to search specified GitHub repos and presents a keyword-scan vetting procedure.
- Pros: Default path is fully safe (curated). Power users can access broader ecosystem with informed consent. No live network calls in the wizard path. Community can contribute to the registry via PRs (lower friction than full preset PRs).
- Cons: Registry requires manual maintenance. Tier 2 "scan" is LLM-assisted review, not automated sandbox execution — it is a best-effort safety check, not a guarantee.

### Decision

**Option C — Hybrid Tier 1/Tier 2 model.**

### Tier 1 Architecture — Curated Skills Registry

**File:** `curated-skills-registry.md` at repo root

**Schema per entry:**
```
| name | description | source_url | vetting_date | tier | goal_tags |
```

- `name`: slug matching the `name:` frontmatter of the SKILL.md (e.g., `flashcard-generation`)
- `description`: one sentence — what this skill does for the user
- `source_url`: canonical URL (GitHub repo URL for community skills; `builtin` for Anthropic official)
- `vetting_date`: ISO 8601 date of last manual vetting review (e.g., `2026-04-17`)
- `tier`: `1` (curated/official) or `2` (community)
- `goal_tags`: comma-separated list of preset slugs this skill is appropriate for (e.g., `study,research`)

**Tier 1 population at v1.2 launch:**
- Minimum 18 entries (≥3 per preset category, as required by F5 AC)
- Sources: Anthropic official pre-built skills (pptx, xlsx, docx, pdf processing), existing 18 preset skills migrated from preset folders, EAIconsulting/cowork-skills-library candidates
- All entries manually vetted by repo maintainer before merge

**Wizard skill recommendation flow (Tier 1):**
1. Wizard detects goal (Step 2 output)
2. Filters `curated-skills-registry.md` by `goal_tags` matching the detected goal
3. Presents top 3–5 matching skills with name, description, and a personalized example
4. User selects (Yes / No / Show me more)
5. On "Yes": wizard instructs installation via `/skill-creator` (primary) or ZIP upload (fallback)
6. `/skill-creator` fallback: confirm file exists at `.claude/skills/<name>/SKILL.md`

**Novel goal skill flow:**
If no Tier 1 entries match the user's goal tags (E4 edge case), wizard states: "I don't have verified skills for [goal] yet. You can build custom skills via `/skill-creator`." Setup completes without skill installation.

### Tier 2 Architecture — Community Opt-In Discovery

**Activation:** Explicit opt-in only. Wizard presents: "Want me to search for more skills? These aren't verified by us — review before installing. 1) Yes, show me more  2) No, stick with verified skills"

**Search sources (hardcoded list in WIZARD.md):**
- `anthropics/skills` (Anthropic official, auto-trusted)
- `travisvn/awesome-claude-skills`
- `VoltAgent/awesome-agent-skills`
- `EAIconsulting/cowork-skills-library`

**Vetting procedure (LLM-assisted, manual):**
The wizard instructs the user to navigate to the skill's SKILL.md and paste the body into the chat. The wizard then:
1. Scans for flagged keywords: `exec`, `subprocess`, `curl`, `wget`, `$HOME`, `$PATH`, `rm`, `delete`, `os.system`, `eval`
2. If any keyword found: surface as WARNING with the line containing the keyword. Require user to type "I understand" before proceeding.
3. Checks source repo indicators: stars >50 OR from recognized organization (Anthropic, EAIconsulting), last commit within 12 months. Surface as INFO if below threshold.
4. User must confirm each Tier 2 skill individually before install instructions are provided.

**Important limitation (to be stated in wizard):** The keyword scan is a heuristic performed by reviewing SKILL.md text. It is NOT sandbox execution. A skill that passes the scan may still have unexpected behavior. Users should review the full SKILL.md before installing.

### Skill Presentation Format (both tiers)

For each recommended skill:
```
[Skill name] — [one-line description]
"For your [detected goal]: [personalized example using earlier answers]"
Source: [Tier 1 Curated / Tier 2 Community — [source repo]]
1. Yes — install  2. No — skip  3. Show me more
```

The personalized example is generated by the wizard using the user's stated goal and any role/context gathered in the profile step. It is not a template — it is constructed at wizard runtime from the interview answers.

### Repository Structure Addition (v1.2)

```
claude-cowork-config/
|-- curated-skills-registry.md     # NEW: Tier 1 curated skills registry
```

The registry lives at repo root (not inside a preset folder) because it serves all goals, including novel goals that don't map to any preset.

### Consequences

- `curated-skills-registry.md` is a new required repo artifact. CI does not validate its content beyond its existence (markdown lint covers format). Manual vetting is the quality gate.
- Tier 2 discovery requires no code changes — it is wizard conversation instructions in WIZARD.md, not a CI-enforced surface.
- Existing 18 preset skills (18 SKILL.md files in preset folders) are NOT migrated into the registry — they remain as preset-bundled skills for users who download and use individual presets. The registry provides goal-matching for the dynamic wizard path.
- Community PR process for registry additions: documented in CONTRIBUTING.md with the required schema fields. PRs must include vetting evidence (date tested, source repo health indicators). Automated vetting pipeline deferred to v1.3.
- The `/skill-creator` fallback path (confirm file exists at `.claude/skills/<name>/SKILL.md`) is carried forward unchanged from v1.1.

---

## ADR-013: Writing Profile Architecture — Universal Artifact for All Workspaces

**Date:** 2026-04-17
**Status:** ACCEPTED

### Context

v1.1 shipped `context/` directories with `about-me.md`, `working-rules.md`, and `output-format.md` per preset. None of these addressed writing voice. v1.2 adds `writing-profile.md` as a universal fourth context file, generated for every completed setup regardless of preset.

**User need:** Every Cowork user produces text. Study users write lab reports. Career Manager users write cover letters. Research users write literature reviews. A voice calibration that makes Cowork outputs sound like the specific user — not generic AI — is universally valuable, not writing-preset-specific.

**Anti-AI framing:** The goal is voice authenticity (Cowork outputs sound like the user), not "AI detection bypass." This distinction is architectural: the writing profile contains voice markers and preference rules derived from the user's actual writing patterns, not adversarial instructions designed to fool detectors. This framing is reflected in wizard language and the profile template.

### Options Considered

**Option A — Writing preset only**
Keep `writing-profile.md` scoped to the Writing preset. Other presets get it only if user explicitly requests.
- Pros: Simpler. Users who don't care about writing voice don't see questions.
- Cons: The anti-AI voice problem is documented as universal (spec F6 rationale). Career Manager, Research, and Study users all produce text. This option requires non-Writing users to know enough to ask for voice calibration — violating the zero-product-knowledge design principle.

**Option B — Universal, mandatory step (RECOMMENDED)**
Writing profile step appears in all 6 preset interview sequences AND in novel-goal flows. `writing-profile.md` is generated for every completed setup. Questions are 3–4 max, with explicit framing: "Even in a [goal] workspace, I'll be writing summaries and explanations for you — this helps me match your style."
- Pros: Every user gets voice calibration regardless of whether they associate themselves with "writing." Addresses the anti-AI voice problem universally. Writing-profile.md in every setup is a consistent output that CI can enforce.
- Cons: Adds 1 interview step for all users. Alex persona has documented low tolerance — mitigated by fast-track pause after Step 6 (post-writing-profile). Users can generate a substantive profile from the questions alone without providing a writing sample.

**Option C — Universal, opt-in step**
Writing profile questions appear in all flows but are explicitly optional: "Want to set up your writing voice? (Y/N)." If N, skip entirely.
- Pros: Respects user time. Alex can opt out.
- Cons: Users who opt out get no voice calibration — they will experience the AI-sounding-like-AI problem but won't know why. The wizard's job is to suggest before they can choose. Making this opt-in is premature — it assumes users understand what they're opting out of, which violates the zero-product-knowledge principle.

### Decision

**Option B — Universal mandatory step with fast-track mitigation.**

Rationale:
1. Voice calibration is universally valuable. The wizard's design principle is "suggest what users need before they know to ask." An opt-in model requires product knowledge to engage with.
2. The fast-track pause at Step 6 (after writing profile) provides the tolerance mitigation. Alex can get a working workspace AND a writing profile before fast-tracking.
3. Assumption A16 (users willing to complete writing profile in non-writing workspaces) is UNTESTED. The fallback is explicit: even if a user skips or provides minimal answers, the profile generates with substantive defaults. An empty or placeholder-only profile must never ship.

### Writing Profile Template Architecture

**File:** `templates/writing-profile-template.md`

**Required sections** (CI-enforced by ADR-014):
1. `## Tone & Voice` — register (casual/professional/academic/mixed), audience, characteristic patterns
2. `## Style Preferences` — sentence length, vocabulary, structure
3. `## Anti-AI Guidance` — avoid list, prefer list, voice markers
4. `## Workspace-Specific Rules` — goal-adapted writing conventions
5. `## Pet Peeves` — user-specified habits to avoid or preserve

**Anti-AI Guidance section design:**
The section populates with patterns from two sources:
- **Default rules** (populated from tone/audience answers): e.g., if user selects "Casual" tone, defaults include "Avoid formal transition phrases like 'Furthermore' and 'In conclusion'." If "Professional," defaults include "Avoid conversational filler like 'basically' and 'you know'."
- **Sample-derived rules** (populated only if user provides a writing sample): e.g., "Short declarative sentences (avg 12 words)" extracted from sample analysis.

**Writing sample handling:**
If user pastes a sample, the wizard extracts ≥2 observable patterns (sentence rhythm, vocabulary register, characteristic phrases) and states them explicitly for user confirmation before including in the profile. The raw sample text is NOT stored in writing-profile.md — only extracted patterns are written. This addresses E6 (user pastes content with sensitive information).

**Default generation rule:**
The writing profile must NEVER ship as empty or placeholder-only. Minimum substantive content: at minimum, the Tone & Voice and Anti-AI Guidance sections must contain non-placeholder content derived from the 3–4 interview questions, even if the user skips the optional writing sample. Spec E2 explicitly requires this.

### File Location Architecture

**In generated workspace output:**
```
<user-workspace>/
|-- writing-profile.md      # Generated by wizard, unique per user
```

**In preset folders:**
```
presets/<preset>/context/
|-- writing-profile.md      # NEW: pre-filled template with goal-appropriate defaults
```

Preset-bundled `writing-profile.md` files ship with goal-appropriate defaults populated (not blank). A Study preset writing profile pre-fills academic writing defaults; a Business/Admin preset pre-fills professional communication defaults. Users fill in personal details (name, specific preferences) during or after the wizard.

**In templates directory:**
```
templates/
|-- writing-profile-template.md    # NEW: blank template with all required sections
```

This is the canonical template used by CONTRIBUTING.md for community contributors creating new presets. CI enforces it exists and contains required sections.

### global-instructions.md Writing Profile Trigger

Every preset's `global-instructions.md` adds a writing profile trigger rule (v1.2):

> "When generating written content ≥100 words, reference `writing-profile.md` for voice and anti-AI guidance if the file exists in the project folder."

This rule connects the writing profile to actual usage behavior. Without it, the writing profile exists as a file but never gets consulted.

**Word threshold rationale:** 100 words is the threshold below which strict voice matching would be pedantic (e.g., a one-line yes/no answer). Above 100 words, voice consistency is perceptible and valuable. This threshold is a judgment call — it may need tuning post-launch.

### Repo Structure Addition (v1.2)

```
templates/
|-- writing-profile-template.md    # NEW

presets/*/context/
|-- writing-profile.md             # NEW (goal-appropriate defaults per preset)
```

### Consequences

- `templates/writing-profile-template.md` is a new required repo artifact. CI enforces existence and section headers (ADR-014).
- 6 new `presets/*/context/writing-profile.md` files ship with each preset — populated with goal-appropriate defaults, not blank.
- All 6 `global-instructions.md` files receive the writing profile trigger rule.
- `docs/OUTPUT-STRUCTURE.md` must be updated to include `writing-profile.md` in the output package.
- CONTRIBUTING.md PR checklist gains a new requirement: `writing-profile.md` context file present in preset with non-placeholder content.
- The anti-AI framing is "voice calibration" throughout — the word "bypass" does not appear in any wizard instruction, template, or documentation.

---

## ADR-014: CI Expansion v1.2 — Writing Profile Template Enforcement

**Date:** 2026-04-17
**Status:** ACCEPTED

### Context

v1.2 introduces `templates/writing-profile-template.md` as a new required repo artifact. If this file is absent or missing required sections, community contributors creating new presets have no canonical template to follow, and the CI `writing-profile-template-check` job (F10 AC) will fail. This ADR documents the job specification.

The existing 4 v1.1 CI jobs (starter-file-check, starter-safety-rule-check, skill-format-check, plus the pre-existing claude-md-safety-rule-check) remain unchanged. One new job is added.

### Decision

**New CI job: `writing-profile-template-check`**

```yaml
writing-profile-template-check:
  name: Writing Profile Template Check
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@<sha>
    - name: Verify writing profile template exists with required sections
      run: |
        if [ ! -f "templates/writing-profile-template.md" ]; then
          echo "MISSING: templates/writing-profile-template.md"
          exit 1
        fi
        FAIL=0
        for section in "## Tone & Voice" "## Anti-AI Guidance" "## Workspace-Specific Rules"; do
          if ! grep -qF "$section" "templates/writing-profile-template.md"; then
            echo "MISSING section: $section"
            FAIL=1
          fi
        done
        if [ "$FAIL" -eq 1 ]; then
          exit 1
        fi
        echo "Writing profile template present with all required sections."
```

**Required sections checked:**
- `## Tone & Voice`
- `## Anti-AI Guidance`
- `## Workspace-Specific Rules`

These three are the minimum that make a writing profile functionally useful:
- Tone & Voice defines the register
- Anti-AI Guidance prevents generic AI patterns
- Workspace-Specific Rules connects the profile to the actual workspace goal

`## Style Preferences` and `## Pet Peeves` are not CI-checked — they are useful but not required for a functional profile. This follows the principle of enforcing the minimum necessary, not the maximum possible.

**Job behavior:**
- Blocks PRs on failure (no `continue-on-error`)
- Checks file existence AND section presence in one step
- Uses `grep -qF` (fixed string, not regex) to avoid false matches from heading variations

### Updated CI Job Count

After v1.2, `.github/workflows/quality.yml` contains:

| Job | Purpose | Blocks PR? |
|-----|---------|-----------|
| markdown-lint | Markdown formatting | Yes |
| link-check (internal) | Internal link integrity | Yes |
| link-check-external | External link integrity | No (continue-on-error) |
| shellcheck | Shell script safety | Yes |
| safety-rule-check | Safety rule in global-instructions.md | Yes |
| starter-file-check | Starter files exist for all presets | Yes |
| starter-safety-rule-check | Safety rule in starter files | Yes |
| skill-format-check | folder/SKILL.md format enforced | Yes |
| claude-md-safety-rule-check | Safety rule in CLAUDE.md | Yes |
| writing-profile-template-check | Writing profile template exists + sections | Yes |

Total: 10 jobs (4 original + 5 v1.1 + 1 v1.2 = 10).

### Consequences

- `.github/workflows/quality.yml` gains one new job.
- The writing-profile-template-check job is the first CI job that enforces a content template (as opposed to a file-existence or format check). This sets a precedent for CI-enforcing template structure in future cycles.
- No changes to existing jobs.
- `claude-md-safety-rule-check` is already present from v1.1.1 — it is not a v1.2 addition, but is counted in the full job count for clarity.

---

## v1.2 Anti-Pattern Scan

Anti-pattern scan applied to v1.2 additions (ADR-010 through ADR-014):

| # | Anti-Pattern | Applies to v1.2? | Notes |
|---|-------------|-----------------|-------|
| 1 | God Class/Module | No | No code modules. CLAUDE.md/starter files are content with a single responsibility each. |
| 2 | Circular Dependencies | Watched | Dependency chain: CLAUDE.md → /setup-wizard → WIZARD.md → preset scripts → templates. One-directional, no cycles. curated-skills-registry.md has no dependencies. |
| 3 | Leaky Abstraction | No | No abstraction layers. Static content. |
| 4 | Premature Optimization | No | No runtime. curated-skills-registry.md is a static file, not a database. Decision to add CI job for template check is proportionate. |
| 5 | Over-Engineering | Watched | Tier 2 skill discovery adds complexity. Mitigated by keeping it as WIZARD.md content (no new files/jobs). Tier 2 is wizard conversation instructions, not infrastructure. |
| 6 | Tight Coupling | Watched | CLAUDE.md and starter files both contain wizard bootstrap logic — duplication, not coupling. Content duplication is an accepted trade-off per ADR-010. |
| 7 | Missing Separation of Concerns | No | Concerns are properly separated: state machine (CLAUDE.md/starter), interview scripts (WIZARD.md), skill registry (curated-skills-registry.md), templates (templates/), CI (quality.yml). |
| 8 | N+1 Query Pattern | No | No database. No queries. |
| 9 | Destructive Migration | No | No migrations. v1.2 is purely additive. Existing preset files are updated, not deleted. |

**Content duplication flag (ADR-010 trade-off):** CLAUDE.md and all 6 starter files contain equivalent wizard bootstrap logic. This is intentional (Option B decision) but creates a synchronization maintenance burden. Mitigated by: WIZARD.md as authoritative source, CONTRIBUTING.md enforcement, CI safety checks on both surfaces. If synchronization becomes a recurring issue, revisit with Option A (CLAUDE.md primary, starter files as preset-specific addendum only).

No blocking anti-patterns detected for v1.2.

---

## v1.2 Safety Architecture Update

The v1.1 four-layer safety architecture extends with one new layer:

1. **Template layer:** `templates/global-instructions-base.md` — canonical safety rule text (unchanged)
2. **Preset layer:** Every preset's `global-instructions.md` — carries safety rule + writing profile trigger (updated v1.2)
3. **Starter file layer:** Every `project-instructions-starter.txt` — safety rule verbatim (updated v1.2: dynamic wizard content)
4. **CLAUDE.md layer:** `CLAUDE.md` at repo root — safety rule verbatim (updated v1.2: dynamic wizard content)
5. **CI layer:** claude-md-safety-rule-check + starter-safety-rule-check + safety-rule-check — three independent enforcement points (v1.1.1 + v1.1; unchanged)

The writing profile trigger in `global-instructions.md` is not a safety rule but a behavioral consistency rule. It is not CI-enforced at this time — it is a CONTRIBUTING.md checklist requirement for community presets.
