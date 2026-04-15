# Contributing

Thank you for contributing to Claude Cowork Config. This guide explains how to add a new preset.

---

## Adding a new preset

All contributions start from the template. Do not create a preset folder from scratch.

1. Copy `templates/preset-template/` to `presets/<your-preset-name>/`
2. Use a lowercase, hyphenated slug for the folder name (e.g. `legal`, `data-science`, `teaching`)
3. Fill in every file — no placeholders left blank
4. Run the CI checks locally before opening a PR (see below)
5. Open a pull request with the title `feat: add <preset-name> preset`

---

## PR review checklist for maintainers

Before merging a new preset PR, verify all 5 items:

- [ ] **Safety rule present verbatim** in `global-instructions.md` — must contain the exact sentence from `templates/global-instructions-base.md`: "Always ask for explicit confirmation before deleting, moving, or overwriting any file or folder."
- [ ] **Minimum file count met** — at least 3 skill files in `.claude/skills/`, at least 2 context files in `context/`, at least 1 `folder-structure.md`, at least 1 `connector-checklist.md`
- [ ] **"Try this now" prompts present** — `skills-as-prompts.md` includes at least one file-based and one file-agnostic example prompt
- [ ] **CI passes** — all GitHub Actions jobs pass: markdown lint, link check, shellcheck, and the safety-rule grep
- [ ] **Skill files follow the format spec** — each skill file in `.claude/skills/` uses the exact format from `templates/preset-template/.claude/skills/example-skill.md` (Name, Description, When to use, Instructions, Example prompts)

---

## Skill content safety

Before submitting any skill content from external sources, scan it at [SkillRisk.org](https://skillrisk.org). Do not submit skill content that was not written by you or sourced from Anthropic's official materials.

---

## Running CI checks locally

```bash
# Markdown lint
npx markdownlint-cli2 "**/*.md"

# ShellCheck (requires shellcheck installed)
shellcheck scripts/setup-folders.sh

# Safety rule grep (runs on all presets including yours)
SAFETY_RULE="Always ask for explicit confirmation before deleting"
for f in presets/*/global-instructions.md; do
  if ! grep -q "$SAFETY_RULE" "$f"; then
    echo "MISSING safety rule: $f"
  fi
done
```

---

## Version management

Do not modify the `VERSION` file or `CHANGELOG.md`. Maintainers handle versioning at release time. Your PR should contain only files in `presets/<your-preset-name>/`.

---

## Developer Certificate of Origin

All contributions must be signed off with `git commit -s` (Developer Certificate of Origin). By signing off, you certify that you wrote the contribution or have the right to submit it.

By submitting a PR, you agree that your contribution is licensed under MIT.

---

## Questions?

Open an issue and tag it `question`. We're happy to help.
