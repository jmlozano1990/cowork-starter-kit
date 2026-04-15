# User Personas — Claude Cowork Config

## How to Use This Document

These personas are the product's decision filter. Before adding a feature, removing an AC, or changing a preset, ask: does this serve Alex, Maria, or both? If it serves neither, it's out of scope.

Personas are derived from: Cowork community guides (2026), user feedback summaries (coworkhow.com), DataCamp tutorial audience analysis, and the brainstorm session with the project owner (2026-04-14).

---

## Primary Persona: Alex — The Student

**Name:** Alex Chen
**Age:** 20
**Role:** Junior, biochemistry major (could also be: philosophy, history, law — any research-heavy coursework)
**Institution:** Mid-size university, uses a MacBook
**Cowork plan:** Claude Pro ($20/month) — recently upgraded after seeing a LinkedIn post about Cowork for students

### Context

Alex has been using ChatGPT since high school. He switched to Claude Pro last semester because someone in his biochemistry Discord said it was better for scientific reasoning. He's heard Cowork can "read your PDFs and work in your files" but hasn't figured out how to set it up.

His study folder is a mess: PDFs of papers downloaded directly to Downloads, notes scattered across Notion and Apple Notes, half-finished summaries in Google Docs. He knows he should organize this. He just doesn't know how.

He spends 3–4 hours a week re-explaining context to AI tools because there's no persistent memory. Every new session starts from scratch.

### Goals (JTBD)

**Functional jobs:**
- Synthesize 15–20 research papers into a coherent literature summary for a class project
- Generate flashcards from his lecture notes for active recall studying
- Format citations in APA/Chicago without doing it manually
- Find connections between papers he's read that he might have missed
- Draft and revise lab reports with the right academic tone

**Social jobs:**
- Feel like a capable, effective student — not someone who's struggling
- Produce work that impresses professors and peers
- Feel like he's using tools at their full potential (not wasting his Pro subscription)

**Emotional jobs:**
- Reduce the anxiety of "I have 12 papers to read and a report due Friday"
- Feel in control of his study process, not overwhelmed by it
- Build confidence that he can tackle research-heavy assignments independently

### Pains

| Pain | Severity |
|------|----------|
| Doesn't know how to configure Cowork — starts sessions with no context | High |
| Re-explains role, assignment, and tone preferences every session | High |
| PDFs live in a disorganized Downloads folder — Cowork can't easily find them | Medium |
| Doesn't know what "skills" or "context files" are | Medium |
| Fears breaking something with the wrong Cowork command | Medium |
| Never set up Global Instructions — every output is too generic | High |

### Gains from Claude Cowork Config

- A `/Study` folder structure that makes sense (Papers/, Notes/, Summaries/, Flashcards/)
- A Global Instructions template that tells Cowork: "I'm a biochem student, academic tone, APA citations, always ask before moving files"
- 3–4 starter skill files: ResearchSynthesis.md, FlashcardGenerator.md, CitationFormatter.md, LitReview.md
- A `cowork-profile.md` that stores his degree, current courses, and study preferences so he doesn't re-explain every session
- The safety rule baked in — he will never accidentally delete his thesis notes

### Quote

> "I know Cowork is powerful. I just need someone to tell me exactly how to set it up for studying. Like, what folders do I make? What do I put in the instructions? I've been putting it off for three weeks."

### Usage Pattern

- Uses Cowork 3–5 times per week, primarily for paper synthesis and note organization
- Checks in with Cowork at the start of study sessions to plan the session
- Most valuable use case: "Read these 8 PDFs and give me a structured summary with key arguments and gaps"

---

## Secondary Persona: Maria — The Knowledge Worker

**Name:** Maria Santos
**Age:** 35
**Role:** Research analyst at a mid-size consultancy (also applies to: academic researcher, science journalist, content strategist, senior project manager)
**Cowork plan:** Claude Max ($100/month) — justified by billable hours saved
**Setup:** MacBook Pro, Google Drive as primary file store, Slack for team comms, DocuSign for client contracts

### Context

Maria has tried every AI tool in the last two years: ChatGPT, Gemini, Notion AI, Perplexity, and now Claude. She knows these tools are powerful. She's actually gotten value from them. But she's never fully cracked how to configure them to match her professional standard.

She's a meticulous researcher. Her deliverables need to be structured in a specific way: executive summary up front, detailed findings behind, all claims cited, no fluff. Every time she uses Cowork, she pastes 3–4 paragraphs of context before the first task because there's nowhere to store it permanently.

She manages 4–5 active projects at once. Each has its own Drive folder. She's tried to use Cowork Projects but hasn't set up per-project instructions because it takes time she doesn't have.

### Goals (JTBD)

**Functional jobs:**
- Produce a structured literature review from 20+ source documents in 90 minutes, not 8 hours
- Draft client-ready reports with her firm's standard format (executive summary, methodology, findings, recommendations)
- Triage and prioritize her inbox to identify the 3 emails that need responses today
- Track deliverable status across multiple projects without maintaining a separate tracker
- Onboard to a new research topic quickly by synthesizing the key papers and debates

**Social jobs:**
- Maintain her reputation as a rigorous, fast researcher
- Deliver work that impresses senior partners and clients
- Be the person on the team who knows how to use AI tools most effectively

**Emotional jobs:**
- Reduce the "constant context tax" — the mental overhead of re-explaining who she is and how she works
- Feel like she has a reliable AI assistant, not a generic chatbot
- Trust that Cowork won't do something destructive to her client files

### Pains

| Pain | Severity |
|------|----------|
| Re-explains her professional context (role, output format, tone) every session | High |
| No per-project instructions — Generic output that doesn't match her firm's standard | High |
| Doesn't know which connectors to prioritize (all look equally relevant) | Medium |
| Has 3 half-configured Cowork setups from different experiments — wants a clean start | Medium |
| Worried about Cowork modifying client files without explicit approval | High |
| Hasn't found a way to store "how Maria works" persistently in Cowork | High |

### Gains from Claude Cowork Config

- A Research or Project Management preset that matches her workflow out of the box
- A Global Instructions template that includes: "I'm a research analyst. All outputs should include an executive summary. Format citations as footnotes. Never modify files without explicit confirmation."
- A connector checklist that says "For your role, prioritize Google Drive (primary file store) and Gmail (client email triage). Slack is optional if you don't use it for deliverables."
- A `cowork-profile.md` storing her professional context — she fills it in once, Cowork reads it every session
- Skill files for: LiteratureReview.md, ReportDrafting.md, ProjectStatus.md, EmailTriage.md
- The safety rule — non-negotiable given her client file exposure

### Quote

> "I've spent more time configuring AI tools than actually using them. I need someone to give me the right setup for a senior analyst — not a generic assistant. Just tell me what to put in the instructions and what folders to make."

### Usage Pattern

- Uses Cowork daily, 1–2 hours per day
- Most valuable use case: "Read all the documents in /Project-Alpha/Research/ and produce a structured synthesis in the format of [example report]"
- Second most valuable: "Go through my Gmail inbox and identify the 5 emails that require responses this week"

---

## Tertiary Persona: Sam — The Creator (Not in MVP, but inform presets)

**Name:** Sam Rivera
**Age:** 28
**Role:** Freelance writer / content strategist / newsletter author
**Note:** Sam is real but not the primary design target. The Writing and Creative presets serve Sam. Do not over-optimize wizard flow for Sam at the expense of Alex and Maria.

**Key needs:** Consistent voice/tone across all outputs, brand voice document that Cowork references, idea capture and outline generation, draft → edit → final workflow. Primary pain: every Cowork output sounds like generic AI, not like Sam.

**Key gain from Config:** A `voice-and-style.md` context file they fill in once, and a Writing preset that tells Cowork to reference it on every output.

---

## Persona Priority Matrix

| Decision | Alex | Maria | Sam |
|----------|------|-------|-----|
| Preset count at launch | 2 required (Study, Research) | 2 required (Research, PM) | 1 required (Writing) |
| Wizard question depth | Minimal (2–3 max) | Can tolerate 3–4 | 2–3 |
| Technical comfort | Low — must be zero-code | Medium — tolerates a checklist | Low-medium |
| Safety sensitivity | Medium — student files | Very high — client files | Low |
| Connector priority | Google Drive only | Drive + Gmail + Slack | Drive only |
| Primary success metric | Completed setup, used within 7 days | Hours saved per week | Voice consistency across outputs |

## Design Principles from Personas

1. **Lowest common denominator = Alex.** If Alex can do it, Maria can. Design every step for Alex's technical comfort level.
2. **Safety is Maria's hard requirement.** The "confirm before delete" rule exists because of users like Maria. Never make it optional.
3. **Context persistence is the #1 gain for both.** The `cowork-profile.md` and Global Instructions template are the product's core value. Everything else is supporting cast.
4. **Maria wants professional quality; Alex wants to feel capable.** Both want outputs that feel personal, not generic. This is why presets exist — "generic AI" is the problem we're solving.
