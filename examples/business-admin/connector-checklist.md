# Connector Checklist — Business/Admin Preset

Review each connector below. For each one you want to use: open Cowork Settings > Connectors > Authorize.

---

## Gmail

- **What it enables:** Lets Cowork read your emails and create draft replies — the highest-value connector for this preset.
- **Do you need this?** Strongly recommended if email is a significant part of your work day.
- **Permission scope:** Cowork requests access to read messages and create drafts.
- **Data boundary:** Note: Claude creates email drafts only — it cannot send emails, even though the authorization screen mentions email permissions. Your emails are never sent without you clicking Send manually.

---

## Google Drive

- **What it enables:** Lets Cowork read and create documents in your Drive — useful for reports, templates, and working documents.
- **Do you need this?** Recommended if your reports and working documents live in Google Drive.
- **Permission scope:** Cowork requests read/write access. Scope is limited to files you explicitly share or folders you grant access to — not your entire Drive by default.
- **Data boundary:** Cowork can only access files and folders you have explicitly shared or granted access to.

---

## Slack

- **What it enables:** Lets Cowork read and post to Slack channels — useful for internal team communication and quick status updates.
- **Do you need this?** Only if your team uses Slack for internal communication and you want Cowork to help draft messages.
- **Permission scope:** Cowork requests access to read and post in channels you select.
- **Data boundary:** Cowork only accesses channels you explicitly authorize.

---

## Google Workspace note

If your Google account is managed by an organization (employer), your IT admin must authorize Claude in Google Workspace Admin Console before your personal authorization will work. Contact your IT department if you encounter authorization errors.
