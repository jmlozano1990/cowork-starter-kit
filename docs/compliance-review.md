# Compliance Review — Claude Cowork Config

## Phase: Pre-build (Phase 2 gate input)
## Date: 2026-04-15T07:00:00Z
## Status: PASS WITH WARNINGS

---

## Findings Summary

| ID | Severity | Area | Description |
|----|----------|------|-------------|
| L1 | WARNING | License | LICENSE file not yet created; MIT intent documented but not enforceable until file exists |
| L2 | WARNING | Trademark | Product name "Claude Cowork Config" embeds "Claude" — a registered Anthropic trademark — creating implied endorsement/affiliation risk |
| L3 | INFO | Trademark | Google, Gmail, Slack, DocuSign referenced by name in connector docs; nominative-use framing should be applied consistently |
| L4 | INFO | Liability | Safety claim ("you're safe here") may create false assurance and modest liability surface |
| L5 | INFO | Community IP | Open PR contributions without a CLA or DCO create ambiguous IP ownership over community-submitted presets |
| L6 | INFO | GDPR/Privacy | No privacy surface detected; local-only data storage confirmed; brief local-storage disclosure recommended for transparency |

---

### CRITICAL

None.

---

### WARNING

**L1 — LICENSE file absent.** The architecture (ADR-004) and spec both state the repo is MIT-licensed, but no `LICENSE` file exists at the project root. Without this file, the repo is technically "all rights reserved" under copyright law in most jurisdictions, regardless of stated intent. Any user who downloads or forks the repo before the file is added has no clear license grant. Recommend creating `LICENSE` (MIT, standard SPDX text) before any public release or community contribution period opens. This is a pre-launch blocker.

**L2 — "Claude" in the product name.** The product is named "Claude Cowork Config" and the repo is `claude-cowork-config`. "Claude" is an Anthropic registered trademark. Using a trademark in a product or repository name may require explicit permission and may imply Anthropic endorsement or official affiliation that does not exist. This is distinct from nominative fair use, which covers referring to the product by name in documentation — naming a repo after a trademark is a different use. Recommend review by counsel or direct inquiry to Anthropic's developer relations team before the LinkedIn launch. Mitigations to consider: rename to a descriptive term that avoids embedding the mark (e.g., `cowork-config`, `cowork-starter-kit`), or obtain explicit written permission from Anthropic.

---

### INFO

**L3 — Third-party trademark references in connector documentation.** The spec (F6) references Google Drive, Gmail, Slack, and DocuSign by name. This is nominative fair use (describing what the product works with) and is standard practice in integration documentation. No action required beyond consistent framing: descriptions should read as "works with Google Drive" not "powered by" or "partnered with." The spec's current framing appears appropriate. Final connector checklist language should avoid phrases that could be read as implying partnership or endorsement.

**L4 — Safety claim liability.** The wizard includes the statement: "this wizard only uses skills you build yourself and Anthropic's official pre-built skills — so you're safe here." This claim may create false assurance. "Safe" is a broad, unqualified assertion. Recommend narrowing to: "This wizard guides you to create skills yourself or use Anthropic's official pre-built skills. We do not reference external skill repositories in this step." Removing "you're safe here" eliminates the implied guarantee without losing the reassurance intent.

**L5 — Community IP / Contributor rights.** Without a Contributor License Agreement (CLA) or Developer Certificate of Origin (DCO) requirement, the IP status of contributed presets is ambiguous. Contributors retain copyright by default, meaning the maintainer cannot sublicense contributions without individual permission. Recommend a DCO requirement (`git commit -s` sign-off) plus a line in CONTRIBUTING.md stating contributions are submitted under the MIT license. A formal CLA is heavier machinery and likely unnecessary at this stage.

**L6 — GDPR/Privacy surface.** The wizard collects name, role, study subject, tools used, and output format preference. All data is stored in `cowork-profile.md` on the user's local machine — no data leaves the device. This architecture has no GDPR exposure under the household exemption (Article 2(2)(c)). No privacy notice is legally required. However, a brief disclosure in README or WIZARD.md that "your answers are saved locally in cowork-profile.md on your own machine and are never transmitted anywhere" is recommended for user trust, particularly for European users.

---

### Summary

Two findings require attention before public launch:

**L1 (WARNING)** is a pre-launch blocker. The MIT LICENSE file must exist at the repo root before the repo goes public. Intent documented in the spec does not constitute a license grant under copyright law.

**L2 (WARNING)** requires a judgment call before the LinkedIn launch. Using "Claude" in the repository name embeds an Anthropic trademark and may imply official affiliation. Options: obtain written permission from Anthropic, or rename the repository to avoid embedding the mark.

The remaining findings (L3–L6) are informational. L5 (community IP / DCO) should be resolved before community contributions open. L4 (safety claim language) should be narrowed before first public release.

No GDPR exposure exists. No Anthropic API ToS concerns exist (the product does not use the API directly).

---

*This review is compliance triage, not legal advice. Findings marked WARNING should be reviewed by someone with relevant legal expertise before public launch.*
