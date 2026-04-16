# Setup Checklist

Use this checklist to complete your Cowork workspace configuration. Complete every step in order.

---

## Steps

**Step 1 — Create your Cowork Project**

Open Cowork. Click "New Project". Name it after your preset (for example: "My Study Space" or "Research Workspace").

**Step 2 — Assign your project folder**

In Project Settings, assign your project folder:

```
~/Documents/Claude/Projects/<preset-name>/
```

Replace `<preset-name>` with your preset (study, research, writing, project-management, creative, or business-admin). If the folder doesn't exist yet, run `scripts/setup-folders.sh` (macOS) or `scripts/setup-folders.ps1` (Windows), or create it manually.

**Step 3 — Paste `project-instructions-starter.txt` into Custom Instructions**

This step MUST happen before you start any conversation.

1. Open your preset folder: `presets/<preset-name>/`
2. Open `project-instructions-starter.txt` in any text editor
3. Copy the entire contents
4. In Cowork: open Project Settings > Custom Instructions
5. Paste the content and save

This file is your workspace bootstrap — it tells Cowork what to do on your first session and on every session after. Do not skip this step.

**Step 4 — Start a conversation — Cowork auto-runs onboarding**

Open your Cowork project and say anything — "hello", "let's get started", or just send a blank message. Cowork will automatically detect it's your first session and begin the onboarding interview.

Alternatively, type `/setup-wizard` to explicitly invoke the setup wizard at any time.

**Step 5 — Fill in your about-me file**

After onboarding, open `context/about-me.md` in any text editor. Fill in your name, role, and goals. Save the file. This file gives Cowork context about who you are without you having to explain it every session.

**Step 6 — Authorize connectors**

Open your `connector-checklist.md`. For each connector you want to use: open Cowork Settings > Connectors > find the connector > click Authorize.

Read the permission scope note for each connector before authorizing. Pay attention to:

- **Gmail:** Creates drafts only — cannot send emails without you clicking Send.
- **Google Workspace accounts (school or employer):** Your IT admin must authorize Claude in Google Workspace Admin Console before your personal authorization will work.

**Step 7 — Upload your skill ZIP**

To upload the preset skill files:

1. Zip the `.claude/skills/` folder from your preset: `presets/<preset-name>/.claude/skills/`
2. The ZIP must have `skill-name/SKILL.md` at the root — no double-nesting
3. Open Cowork Settings > Customize > Skills > click `+`
4. Select the ZIP file

Alternatively, use Cowork's built-in skill-creator to build personalized skills conversationally — ask Cowork "Help me create a skill for [your use case]."

Anthropic's official pre-built document skills (PDF, PPTX, XLSX, DOCX) are available in the same Skills menu — these require no configuration.

**Step 8 — Test your skills**

Ask Cowork: "What skills do you have active?"

Verify your preset skills appear in the response. If they don't appear, see "What if something goes wrong?" below.

**Step 9 — Try this now**

Pick one of the prompts below for your preset and try it right now:

**Study**

- File-based: "Read the PDFs in my Papers/ folder and give me a one-paragraph summary of each one."
- File-agnostic: "I'm studying [your subject]. Explain the concept of [any concept from your subject] as if I'm encountering it for the first time, then give me 3 practice questions I can answer to check my understanding."

**Research**

- File-based: "Look at my Literature/ folder. What sources do I have and what topics do they cover?"
- File-agnostic: "I'm starting a literature review on [your research topic]. What are the 5 most important questions I should be trying to answer, and what types of sources should I look for?"

**Writing**

- File-based: "Read my Voice-and-Style/ folder and write me a 150-word sample in my voice about [any topic]."
- File-agnostic: "I need to write [type of content] about [any topic]. Give me 3 different opening paragraphs with different tones — formal, conversational, and punchy — so I can see which feels most like my voice."

**Project Management**

- File-based: "What's in my Active-Projects/ folder? Summarize the status of each project in 2 sentences."
- File-agnostic: "I'm managing a project to [describe any project]. What are the top 5 risks I should be tracking, and draft a one-paragraph status update I could send to a stakeholder today."

**Creative**

- File-based: "Read my Inspiration/ folder and suggest 3 creative directions I could explore this week."
- File-agnostic: "I'm working on [describe any creative project]. Give me 5 unexpected directions I could take this — include at least one that surprises me."

**Business/Admin**

- File-based: "What files are in my Inbox/ folder? Draft a prioritized action list for today."
- File-agnostic: "Draft a professional email declining a meeting request politely, keeping the relationship warm, in under 100 words. Then draft a version that's 30% more direct."

**Step 10 — Memory tip**

Cowork remembers things you tell it within a Project. Ask Cowork: "Remember that I am [your role] and I prefer [output format] responses." Cowork will store this for future sessions.

Use the `/memory` command anytime to see, edit, or delete what Cowork has stored about you.

---

## What if something goes wrong?

**Onboarding didn't start automatically**

Type `/setup-wizard` to invoke the onboarding interview explicitly. Make sure you pasted `project-instructions-starter.txt` into Project Settings > Custom Instructions first (Step 3).

**Wizard interrupted mid-session**

Type `/setup-wizard` again. The wizard will detect your existing profile and ask if you want to reset and re-run. Your past sessions are unaffected.

**Skill test failed (skills not loading)**

Open `skills-as-prompts.md` in your preset folder. Copy the skill content you want and paste it at the start of your message: "Using this approach: [paste] — now help me with [task]."

**Connector auth failed**

- Google Workspace / school / work account: Your IT admin needs to authorize Claude in Google Workspace Admin Console first. For personal Google accounts, try disconnecting and re-authorizing.
- For other issues: [support.claude.com](https://support.claude.com)

---

## Keeping up to date

When a new version ships, check the [Releases tab on GitHub](https://github.com/JLCyb3r/cowork-starter-kit/releases). `CHANGELOG.md` lists which presets changed. To update a specific preset: download the new `presets/<name>/` folder and replace only the template files. Your `cowork-profile.md` and `project-instructions-starter.txt` are yours — they won't be overwritten.
