# Connector Checklist — [Preset Name]

Review each connector below. For each one you want to use: open Cowork Settings > Connectors > Authorize.

---

## Connectors for this preset

### Google Drive

- **What it enables:** Lets Cowork read and create documents in your Google Drive folders.
- **Do you need this?** [Decision helper — e.g., "Only if you store working files in Drive."]
- **Permission scope:** Cowork requests read/write access. Scope is limited to files you explicitly share or folders you grant access to — not your entire Drive by default.
- **Data boundary:** Cowork can only access files and folders you have explicitly shared or granted access to.

### Gmail

- **What it enables:** Lets Cowork read your emails and create draft replies.
- **Do you need this?** [Decision helper — e.g., "Only if you want Cowork to help draft email responses."]
- **Permission scope:** Cowork requests access to read messages and create drafts.
- **Data boundary:** Note: Claude creates email drafts only — it cannot send emails, even though the authorization screen mentions email permissions. Your emails are never sent without you clicking Send manually.

### Slack

- **What it enables:** Lets Cowork read messages and post to channels you specify.
- **Do you need this?** [Decision helper — e.g., "Only if your team uses Slack and you want Cowork to help draft messages."]
- **Permission scope:** Cowork requests access to read and post in channels you select.
- **Data boundary:** Cowork only accesses channels you explicitly authorize.

---

## Google Workspace note

If your Google account is managed by an organization (school or employer), your IT admin must authorize Claude in Google Workspace Admin Console before your personal authorization will work.
