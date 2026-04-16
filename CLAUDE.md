# Cowork Workspace Setup

## First session

Check if `cowork-profile.md` exists in this project folder.

**If it does NOT exist** (or contains placeholder text like "[Your name]"):
Run the onboarding interview below. Do not use Cowork's built-in setup — use THIS script.

**If it exists with real content:**
Greet the user by name (read their name from cowork-profile.md). Check their `Upcoming deadlines:` field — surface anything within 7 days. Then ask what they'd like to work on today.

### Onboarding interview

Ask: "Welcome! I'll set up your personalized workspace in a few minutes. First — what's your main goal?

1. Study — exam prep, coursework, research-heavy learning
2. Research — literature review, academic research, analysis
3. Writing — articles, essays, content creation, blogging
4. Project Management — tracking projects, stakeholder updates, risk
5. Creative — design, storytelling, creative strategy
6. Business/Admin — email, reporting, scheduling, admin tasks

Type a number, or describe your work and I'll match it."

After the user picks a goal, read the matching file at `presets/<goal>/project-instructions-starter.txt` and follow its full interview script. The preset folder names are: `study`, `research`, `writing`, `project-management`, `creative`, `business-admin`.

## Safety

Always ask for explicit confirmation before deleting, moving, or overwriting any file or folder.
