# Architecture — Claude Cowork Config

## Overview

Claude Cowork Config is a static template repository that provides a goal-driven onboarding wizard for non-technical Claude Cowork users. This document records all architectural decisions as numbered ADRs. The architecture defines the repo structure, delivery mechanism, skill file strategy, versioning model, and CI/CD approach.

**Stack:** No application runtime. Markdown + optional bash scripts. Delivered as a public GitHub repo (ZIP-downloadable).

---

## ADR Index

| ADR | Title | Status |
|-----|-------|--------|
| ADR-001 | Wizard Delivery Mechanism | ACCEPTED |
| ADR-002 | Preset Versioning Strategy | ACCEPTED |
| ADR-003 | Skill File Delivery and A2 Assumption Mitigation | ACCEPTED |
| ADR-004 | Repository Structure and File Naming Conventions | ACCEPTED |
| ADR-005 | CI/CD Strategy | ACCEPTED |

---

## ADR-001: Wizard Delivery Mechanism

**Date:** 2026-04-14
**Status:** ACCEPTED
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

**Option D — Cowork-as-Wizard (Conversational) + Bash Fallback + Manual Checklist** (RECOMMENDED)
- The PRIMARY path uses Claude Cowork itself as the wizard runtime. The user opens the repo folder in Cowork and says "Help me set up" or "Run the setup wizard." A `WIZARD.md` instruction file in the repo root tells Cowork exactly how to conduct the interview: ask 3-5 goal questions, ask 2-3 persona depth questions, then generate personalized output files directly into the user's workspace.
- A SECONDARY path provides `scripts/setup-folders.sh` (bash) for users who want to create the folder structure via terminal.
- A TERTIARY path provides `SETUP-CHECKLIST.md` — a fully manual step-by-step guide for users who want to do everything by hand without Cowork, terminal, or any automation.

### Decision

**Option D — Cowork-as-Wizard with layered fallbacks.**

Rationale:
1. **Zero-code by default.** The primary path requires zero terminal interaction. The user talks to Cowork, which is the tool they already have open. This is the lowest-friction path possible — lower than even reading a markdown guide.
2. **True interactivity.** Cowork can ask questions conversationally, handle "I'm not sure / skip" responses, offer fuzzy matching for custom goals, and generate personalized files — all spec ACs are satisfiable.
3. **Cross-platform for free.** Cowork runs on macOS and Windows. No platform-specific scripts needed for the primary path.
4. **ZIP-compatible.** No execute permissions, no runtime dependencies. The wizard is a markdown instruction file that Cowork reads.
5. **Graceful degradation.** Users who don't want to use Cowork-as-wizard can fall back to the bash script (technical users) or the manual checklist (everyone else).
6. **Dog-fooding.** A Cowork configuration tool that uses Cowork as its delivery mechanism is a powerful product narrative.

Risks:
- Cowork must be able to read the `WIZARD.md` file and follow multi-step instructions. This is Cowork's core capability (file read/write + instruction following) and is significantly more reliable than the A2 assumption about skill files.
- If Cowork cannot follow the wizard instructions reliably, the manual checklist is the full fallback. No user is stranded.

### Consequences

- `WIZARD.md` at repo root contains the full wizard instruction set (structured for Cowork to execute conversationally).
- `scripts/setup-folders.sh` contains the bash folder-creation script (macOS).
- `scripts/setup-folders.ps1` contains the PowerShell equivalent (Windows).
- `SETUP-CHECKLIST.md` at repo root contains the full manual alternative.
- README.md documents all three paths with the Cowork-as-wizard path as the recommended default.
- `project-instructions.txt` (renamed from `global-instructions.txt`): generated personalized Project custom instructions for paste into Cowork Project Settings.

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
**Status:** ACCEPTED
**Context:** The spec's F5 (Skill/Context File Starter Kit) delivers SKILL.md files stored in `.claude/skills/`. Assumption A2 states this loading behavior is UNTESTED for Cowork — it is only confirmed for Claude Code. If Cowork does not auto-load skill files, F5 delivers zero value as designed. This is the highest-risk assumption in the spec.

### Options Considered

**Option A — Ship SKILL.md Only (Assume A2 is True)**
- Ship skill files in `.claude/skills/` and hope Cowork loads them.
- Pros: Clean, simple, follows the documented convention.
- Cons: If A2 is false, the entire F5 feature is cosmetic. Users have files that do nothing. No fallback.

**Option B — Skip SKILL.md Entirely (Assume A2 is False)**
- Deliver all skill content as sections within Global Instructions or as standalone prompt template files the user pastes manually.
- Pros: Guaranteed to work — Global Instructions is confirmed to affect Cowork behavior.
- Cons: Throws away the `.claude/skills/` convention entirely. If A2 is true, we miss the superior experience. Global Instructions has a ~400-word limit (A1), so cramming skill content in is impractical.

**Option C — Dual-Path Delivery with Validation Gate** (RECOMMENDED)
- Ship SKILL.md files in `.claude/skills/` as the PRIMARY delivery (optimistic path).
- ALSO generate a `skills-as-prompts.md` file per preset that contains all skill content formatted as copy-paste prompt snippets (pessimistic path / fallback).
- Include a validation step in the SETUP-CHECKLIST: "Test if skills are active" — a simple test the user can run to confirm A2.
- If the test fails, the checklist directs the user to the `skills-as-prompts.md` fallback.

### Decision

**Option C — Dual-Path Delivery with Validation Gate.**

Rationale:
1. We ship the optimistic path (SKILL.md files) because the convention is documented and likely to work in Cowork given Cowork's shared heritage with Claude Code.
2. We hedge with the pessimistic path (prompt snippets) so no user is stranded if A2 is false.
3. The validation test is simple and non-technical: the user asks Cowork "What skills do you have loaded?" or includes a canary instruction in a skill file (e.g., "If asked about your setup, mention that skill files are active") and tests it.
4. This design costs minimal additional effort (one extra file per preset) and eliminates the entire A2 risk.

### Validation Protocol for A2

Before Phase 4 (implementation), the following test must be performed:
1. Create a Cowork project folder with `.claude/skills/test-skill.md` containing: "When the user asks 'are skills loaded?', respond with exactly: SKILLS-ACTIVE-CONFIRMED."
2. Open the folder in Cowork and ask: "Are skills loaded?"
3. If response contains "SKILLS-ACTIVE-CONFIRMED" — A2 is validated. Ship SKILL.md as primary, keep fallback for documentation completeness.
4. If response does NOT contain the marker — A2 is invalidated. Promote `skills-as-prompts.md` to the primary delivery in the wizard flow. Keep SKILL.md files in the repo for future compatibility but add a prominent note that they require manual activation.

### Consequences

- Each preset contains a `.claude/skills/` directory with 3-5 SKILL.md files (primary path).
- Each preset also contains `skills-as-prompts.md` — all skill content formatted as copy-paste snippets (fallback path).
- SETUP-CHECKLIST.md includes a "Verify skills are active" step with the canary test.
- WIZARD.md instructs Cowork to place skill files in the user's workspace `.claude/skills/` directory AND generate the prompt snippet fallback.

> **Post-Phase-1 Update (2026-04-15):** A2 assumption resolved via research. Cowork does not auto-discover `.claude/skills/` from filesystem (Claude Code only). Delivery mechanism updated: `.claude/skills/` content is packaged as a ZIP for manual upload via Settings > Customize > Skills. Skill-creator (built-in Cowork meta-skill) is now the primary skill delivery path — the wizard guides users to build personalized skills live during the setup session. Pre-built skill files in preset folders serve as ZIP upload source and reference content.

---

## ADR-004: Repository Structure and File Naming Conventions

**Date:** 2026-04-14
**Status:** ACCEPTED
**Context:** The repo must be navigable by non-technical users downloading a ZIP. File names must be self-explanatory. The structure must support 6 presets at launch and scale to community-contributed presets.

### Decision

```
claude-cowork-config/
|
|-- README.md                          # Product landing page + quick start
|-- WIZARD.md                          # Cowork-as-wizard instruction file (primary path)
|-- SETUP-CHECKLIST.md                 # Fully manual setup alternative (tertiary path)
|-- CONTRIBUTING.md                    # How to add a new preset
|-- CHANGELOG.md                       # Release history (which presets changed)
|-- LICENSE                            # MIT
|-- VERSION                            # Single semver string (e.g., "1.0.0")
|-- .gitignore
|
|-- presets/
|   |-- study/
|   |   |-- README.md                  # Preset overview: who it's for, what it configures
|   |   |-- global-instructions.md     # Template Global Instructions block for this preset
|   |   |-- folder-structure.md        # Documented folder tree for this goal type
|   |   |-- connector-checklist.md     # Recommended connectors with decision helpers
|   |   |-- skills-as-prompts.md       # Fallback: all skill content as copy-paste snippets
|   |   |-- context/
|   |   |   |-- about-me.md            # User fills in (template with prompts)
|   |   |   |-- working-rules.md       # Pre-filled safe defaults
|   |   |   |-- output-format.md       # Pre-filled per preset
|   |   |-- .claude/
|   |       |-- skills/
|   |           |-- research-synthesis.md
|   |           |-- note-taking.md
|   |           |-- flashcard-generation.md
|   |
|   |-- research/
|   |   |-- (same structure as study/)
|   |
|   |-- writing/
|   |   |-- (same structure as study/)
|   |
|   |-- project-management/
|   |   |-- (same structure as study/)
|   |
|   |-- creative/
|   |   |-- (same structure as study/)
|   |
|   |-- business-admin/
|       |-- (same structure as study/)
|
|-- scripts/
|   |-- setup-folders.sh               # Bash folder creation (secondary path, macOS)
|   |-- setup-folders.ps1              # PowerShell folder creation (secondary path, Windows)
|
|-- templates/
|   |-- preset-template/               # Blank preset template for contributors
|   |   |-- README.md
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
|   |           |-- example-skill.md
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
3. **Skill files:** lowercase, hyphenated, descriptive names (e.g., `research-synthesis.md`, `meeting-notes.md`). No numeric prefixes — alphabetical ordering is sufficient.
4. **Root-level files:** UPPERCASE for standard open-source files (README.md, CONTRIBUTING.md, CHANGELOG.md, LICENSE, VERSION, WIZARD.md, SETUP-CHECKLIST.md). This follows GitHub conventions and ensures visibility.
5. **Context files:** lowercase, hyphenated. Always three files per preset: `about-me.md`, `working-rules.md`, `output-format.md`.
6. **No binary files.** Every file in the repo is plain text (markdown or shell script). No images, PDFs, or compiled artifacts. ASCII diagrams only.

### Output Package Spec

When the wizard completes (via any of the three paths), the user's workspace should contain:

```
<user-workspace>/
|-- cowork-profile.md                  # Generated: user's answers + selected preset
|-- project-instructions.txt           # Generated: personalized Project custom instructions (plain text)
|-- .claude/
|   |-- skills/
|       |-- <skill-1>.md               # Copied from preset
|       |-- <skill-2>.md               # Copied from preset
|       |-- <skill-3>.md               # Copied from preset (minimum 3)
|-- context/
|   |-- about-me.md                    # Copied from preset (user fills in)
|   |-- working-rules.md              # Copied from preset (pre-filled)
|   |-- output-format.md              # Copied from preset (pre-filled)
|-- <goal-folders>/                    # Created per preset's folder-structure.md
|   |-- (varies by preset)
|-- connector-checklist.md             # Copied from preset
|-- SETUP-CHECKLIST.md                 # Copied from repo root (post-wizard steps)
```

Key output rules:
- `project-instructions.txt` uses `.txt` extension (not `.md`) because the user pastes its content into Cowork Project Settings > Custom Instructions field — it is not a markdown document, it is plain text.
- Every `project-instructions.txt` file MUST contain the safety rule: "Always ask for explicit confirmation before deleting, moving, or overwriting any file." This is enforced by the template in `templates/global-instructions-base.md` which is prepended to every preset's instructions.
- `cowork-profile.md` is generated from the wizard answers and is the only file that is unique per user (all others are copied from presets, possibly with minor personalization).

### Consequences

- Flat, predictable structure — no deeply nested directories.
- `templates/` directory enables community contributions via CONTRIBUTING.md.
- `templates/global-instructions-base.md` is the single source of truth for the safety rule — every preset's global instructions must include this base content.
- `.claude/skills/` directories inside presets may contain dotfiles — the `.gitignore` must not exclude them.

---

## ADR-005: CI/CD Strategy

**Date:** 2026-04-14
**Status:** ACCEPTED
**Context:** The repo needs automated quality checks to catch broken links, malformed markdown, and (if bash scripts exist) shell script issues. CI runs on GitHub Actions, not the user's machine, so this does not violate the zero-dependency constraint.

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
  2. `markdown-link-check` or `lychee` — validates all relative and external links.
  3. `shellcheck` — validates bash scripts in `scripts/` (if present).
- Pros: Comprehensive quality gate. Catches the three most common content repo issues. Runs in ~30 seconds. Free for public repos.
- Cons: Slightly more complex workflow file. External link checking may have transient failures (rate limiting). Mitigated by configuring external link check as a warning, not a blocker.

### Decision

**Option C — Markdown Lint + Link Check + ShellCheck.**

Rationale:
1. Broken relative links are the #1 quality issue in content repos with cross-referenced files. The spec AC explicitly requires "zero broken relative links" — CI enforces this.
2. ShellCheck costs nothing to add and catches common bash issues in `setup-folders.sh`.
3. External link checking runs as a separate job with `continue-on-error: true` to avoid blocking PRs on third-party site availability.
4. The workflow file is small and maintainable. No custom scripts required.

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
          fail: true            # Fail on broken internal links
        # External links checked separately with continue-on-error

  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ludeeus/action-shellcheck@2.0.0
        with:
          scandir: './scripts'
```

### Consequences

- `.github/workflows/quality.yml` is included in the repo.
- `.markdownlint.jsonc` configuration file at repo root (customize rules as needed — e.g., allow long lines in code blocks).
- PRs are blocked on markdown lint and internal link check failures.
- External link failures are reported but do not block PRs.
- ShellCheck runs on all `.sh` files in `scripts/`.

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
| 6 | Stringly-typed data | Watched | File naming conventions (ADR-004) serve as the "type system." Preset folder names are the canonical identifiers — they must be consistent across references. |
| 7 | Circular dependencies | Watched | `WIZARD.md` references presets which reference `templates/global-instructions-base.md`. Dependency is one-directional (wizard -> presets -> templates). No cycles. |
| 8 | Missing audit trail | Partially | CHANGELOG.md + git history serve as the audit trail. VERSION file is the versioning mechanism. |
| 9 | Undocumented assumptions | Addressed | A2 is the critical assumption. ADR-003 designs around it with dual-path delivery and a validation protocol. All other assumptions are catalogued in `docs/assumptions.md`. |

No anti-patterns detected. The architecture is appropriately simple for a static content repository.

---

## Safety Architecture

The safety rule ("Always ask for explicit confirmation before deleting, moving, or overwriting any file") is enforced at three layers:

1. **Template layer:** `templates/global-instructions-base.md` contains the canonical safety rule text. This file is the single source of truth.
2. **Preset layer:** Every preset's `global-instructions.md` must include the base template content. The CONTRIBUTING.md guide makes this a hard requirement for new presets.
3. **Wizard layer:** The `WIZARD.md` instruction file tells Cowork to always include the safety rule in generated `project-instructions.txt`, regardless of user answers. The wizard does not offer an option to remove it.
4. **CI layer:** A future CI check (post-v1 if needed) can grep all preset `global-instructions.md` files for the safety rule text and fail if absent.

This defense-in-depth approach ensures the safety rule cannot be accidentally omitted from any preset, including community-contributed ones.
