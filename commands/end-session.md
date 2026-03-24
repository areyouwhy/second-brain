Wrap up the current working session. Project-scoped — it only cares about the project you've been working in. Context should already be loaded from this session.

## Step 1: Check for uncommitted work

Run in the current project directory:

```bash
git status --short
```

If there are uncommitted changes (staged, unstaged, or untracked files that look intentional):
- Show the user what's pending
- Ask: "Want to commit these before closing the session, or leave them for next time?"
- If yes, help stage and commit with a clear message
- If no, note the uncommitted state in the session log

Also check for unpushed commits:
```bash
git log --oneline @{u}..HEAD 2>/dev/null
```

If there are unpushed commits, mention it — don't push automatically, just flag it.

## Step 2: Gather session activity

Get all commits since the last session note (or all recent commits if this is the first session):

```bash
git log --oneline --since="YYYY-MM-DD" --format="%h %s (%ai)"
```

Use your knowledge of the session to determine the right timeframe. If you've been working for a few hours, that's the window. If the session spans days, go back to when it started.

Also gather from the conversation:
- Decisions made during this session
- Problems encountered and how they were solved
- Ideas that came up but weren't acted on
- Anything the user said they want to do next

## Step 3: Find the project's vault note

Detect the project directory name and find the matching vault note:

```
obsidian vault="{{VAULT_NAME}}" search query="directory: {dir-name}" limit=3
```

Read the project note.

## Step 4: Update the project note

### Update `last-updated` in frontmatter

Set the `last-updated` property to today's date:
```yaml
last-updated: {date}
```

### Append to `## Log`

Add a concise entry:
```
- {date}: {1-line summary of what was accomplished}
```

### Create a session note file

Session notes live in their own files under `Projects/{Project Name}/`. Each project is a folder — the project note is the index file (`Projects/{Project Name}/{Project Name}.md`) and session notes sit alongside it.

If the project note hasn't been moved into a folder yet (legacy structure), move it first:
1. Create the folder `Projects/{Project Name}/`
2. Move `Projects/{Project Name}.md` → `Projects/{Project Name}/{Project Name}.md`

Create a new file:

```
Projects/{Project Name}/{date} — {session title}.md
```

The session title should be a short phrase describing the session's focus (e.g., "Email routing setup", "MIDI debugging", "Camera roll scroll effect").

Use this template:

```markdown
---
title: {session title}
date: {date}
tags:
  - session
parent: "[[{Project Name}]]"
---

# {date} — {session title}

**Changes:**
- {grouped commit summaries — not raw hashes, describe what changed}

**Insights:**
- {things learned, gotchas, patterns discovered, architecture decisions}
- {anything a future session should know}

**Ideas:**
- {features, improvements, or questions that came up}

**Status:**
- {what state is the project in now? what's the natural next step?}
- {any uncommitted work or unpushed commits}
```

If the project note doesn't have a `## Session Notes` section yet, add one above `## Log`:

```markdown
## Session Notes

Notes from work sessions — stored in their own folder.

\```dataview
TABLE date AS "Date", title AS "Summary"
FROM "Projects/{Project Name}"
WHERE contains(tags, "session")
SORT date DESC
\```
```

## Step 5: Extract vault-worthy knowledge

Before closing, ask yourself three questions about what happened in this session. The filter: "Would a future session — possibly on a *different* project — benefit from having this knowledge in the vault?" If yes, it belongs in the vault as a proper note, not buried in session notes.

### 5a: New entities

Did this session introduce new hardware, instruments, external services, or tools with non-trivial specs or configuration?

Examples of vault-worthy:
- Connected a new MIDI keyboard → create `Computer/Hardware/{Name} Specs.md` with MIDI channels, connection type, quirks discovered
- Set up a new API with keys, rate limits, endpoints → create a note or update an existing one in `Computer/Software/` or the relevant section
- New hardware peripheral with specs, firmware, or driver details

Examples of NOT vault-worthy:
- Installed a standard npm package (stays in session notes / package.json)
- Used a well-known library in an obvious way (no special knowledge gained)
- Routine config changes (stays in commits)

The bar is: does this thing have *specs, quirks, or configuration* that you'd need to look up again?

### 5b: Existing notes that need updating

Did the session reveal new knowledge about something already documented in the vault?

Examples:
- Discovered a new MIDI behavior of the Orchid → update `Computer/Hardware/Orchid ORC-1 Specs.md`
- Found that a documented API has changed its rate limits → update the relevant note
- Learned a new routing pattern for Astro i18n → update the Design System or project note

Check the project's `context-dependencies` and any vault notes that were read during the session — would any of them be more useful with what you now know?

### 5c: Propose changes

If either 5a or 5b surfaced something, propose it to the user:

```
**Knowledge to extract:**
- CREATE: Computer/Hardware/Arturia KeyLab 49 Specs.md — new MIDI controller with CH1/CH3 routing, velocity curves, DAW mode quirks
- UPDATE: Computer/Hardware/Orchid ORC-1 Specs.md — add multi-device MIDI section (routing when both instruments connected)

Create these notes? (all / pick / skip)
```

If the user approves, create or update the notes. Keep them factual and reference-style — these are specs and configuration docs, not narratives.

## Step 6: Update context-dependencies

After any new vault notes are created (Step 5), update the project's `context-dependencies`:

- Add any new vault notes created in Step 5 that are relevant to this project
- Add any existing vault notes that were referenced or needed during the session but weren't in `context-dependencies`
- Don't remove dependencies based on a single session — one session not needing a dep doesn't mean it's stale

## Step 7: Output

---

### Session Closed — {project name}

**Duration:** {approximate — hours or days}

**Summary:** {2-3 sentences on what was accomplished}

**Commits:** {count} ({pushed/unpushed status})

**Uncommitted work:** {none, or describe what's pending}

**Knowledge extracted:**
- {notes created or updated, or "None — nothing vault-worthy this session"}

**Vault updated:**
- {project note path} — session log added
- {any dependency changes}
- {any new notes created}

**Next time:** {what to pick up — the natural continuation}

---

Important:
- Write session notes for a future Claude that has zero memory of this conversation. Include enough context to be useful cold.
- Don't be verbose — insights should be crisp, not essay-length
- If the user worked on things that aren't captured in commits (design decisions, research, planning), capture those too
- If there's uncommitted work, make it clear what state things are in so the next session can pick up cleanly
- Knowledge extraction should be selective, not generous. If in doubt, leave it in session notes — the user can always promote it to a vault note later.
