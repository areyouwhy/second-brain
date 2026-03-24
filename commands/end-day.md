[{{USER_TAG}}] End-of-day wrap-up. Aggregates across all projects, writes the daily note, and flags anything left open. Global counterpart to `/end-session` (which is project-scoped).

Sessions may have already been closed with `/end-session` during the day — if so, their session notes are already in the project vault notes. This command reads those and aggregates. If sessions weren't explicitly closed, it does the gathering itself.

Today's date is $CURRENT_DATE.

## Step 1: Scan all projects for today's activity

First, determine the projects base directory. The vault is inside the projects folder — use its parent directory:

```bash
PROJECTS_DIR="$(dirname "$(obsidian vault="{{VAULT_NAME}}" info 2>/dev/null | grep -i path | awk '{print $NF}')" 2>/dev/null)"
# Fallback: check if vault is under a "projects" directory
if [ -z "$PROJECTS_DIR" ] || [ ! -d "$PROJECTS_DIR" ]; then
  PROJECTS_DIR="$(cd "$(obsidian vault="{{VAULT_NAME}}" path 2>/dev/null)/.." 2>/dev/null && pwd)"
fi
```

For each project directory under the projects base, check for commits today:

```bash
for dir in "$PROJECTS_DIR"/*/; do
  name=$(basename "$dir")
  commits=$(cd "$dir" && git log --oneline --after="$CURRENT_DATE 00:00" --before="$CURRENT_DATE 23:59" 2>/dev/null)
  if [ -n "$commits" ]; then
    echo "=== $name ==="
    echo "$commits"
    echo ""
  fi
done
```

Also check for uncommitted work across all projects:

```bash
for dir in "$PROJECTS_DIR"/*/; do
  name=$(basename "$dir")
  status=$(cd "$dir" && git status --short 2>/dev/null)
  if [ -n "$status" ]; then
    echo "=== $name (uncommitted) ==="
    echo "$status"
    echo ""
  fi
done
```

## Step 2: Read session notes already written today

For each project with activity, find its vault note:

```
obsidian vault="{{VAULT_NAME}}" search query="directory: {dir-name}" limit=3
```

Read the project note. Then check for session note files from today in the project's subfolder:

```
obsidian vault="{{VAULT_NAME}}" search query="date: {date}" path="Projects/{Project Name}" limit=5
```

If session files exist from today, the session was already logged by `/end-session` — read those files and pull from them instead of re-analyzing commits.

## Step 3: Fill gaps

For projects that had commits today but no session notes from today (i.e., `/end-session` wasn't run), do a lightweight wrap-up:

- Update `last-updated` in frontmatter to today's date
- Append a log entry to `## Log`: `- {date}: {1-line summary}`
- Create a lightweight session note file in `Projects/{Project Name}/` if none exists from today. Keep it brief — `/end-session` is the right tool for detailed session notes. Always capture the log line in the project note.

This keeps `/end-day` fast and non-redundant. It doesn't redo work that `/end-session` already did. But it always updates `last-updated` for any project that had activity.

## Step 4: Write the daily note

Check if a daily note exists:
```
obsidian vault="{{VAULT_NAME}}" read path="Daily/$CURRENT_DATE.md"
```

If it doesn't exist, create it. If it does, update it.

### Frontmatter

Ensure the daily note has these frontmatter fields. Fill them in based on the day's activity:

```yaml
---
title: $CURRENT_DATE
tags:
  - daily
date: $CURRENT_DATE
projects:
  - {project names that had activity today}
decisions:
  - {key decisions made, pulled from session notes or commits}
open-threads:
  - {things left uncommitted, unpushed, or unfinished}
  - {ideas that came up but weren't acted on}
---
```

### Intentions section

If `/start-day` already wrote an Intentions section, **leave it untouched**. If the note uses an older format with "Morning Plan", treat it the same — don't overwrite.

### Log section — write narrative prose

Write the `## Log` section as **2-4 paragraphs of journal-style prose**. This should read like a brief journal entry that describes how the day went — what you worked on, what mattered, and where things stand.

**Tone:** First-person, reflective but concise. Write as if summarizing the day to a future version of yourself. Conversational, not formal.

**What to include:**
- Which projects were touched and what the work involved
- Key decisions and why they were made
- Problems encountered and how they were resolved
- The current state of things — what's done, what's in progress

**What NOT to do:**
- Don't use bullet lists or sub-headers inside Log — write flowing paragraphs
- Don't include commit hashes or raw git output
- Don't write stats ("2 sessions across 3 projects") — describe what happened
- Don't repeat the frontmatter data verbatim — the prose should add context and narrative

**Example of good tone:**

> Spent most of the day on the Second Brain setup script, rewriting it from a basic installer into a proper interactive CLI. The big decision was keeping it pure bash instead of reaching for Node — it's a one-time setup tool, not a web app. Got the profile interview working with a TUI grid picker, which feels much better than the old text prompts. Also touched ruy.se to add the design system preview page and link to the public repo. The vault itself needed restructuring to match the new project folder convention — moved session notes into per-project subfolders. Setup script is ready for testing but hasn't been committed yet.

If there are no projects with activity today:

```markdown
## Log

Quiet day — no project work.
```

### Reflections section

If `## Reflections` is empty, leave it — that's for the user. Never fill it in.

## Step 5: Output

---

### Day Wrapped — $CURRENT_DATE

{2-3 sentence narrative summary of the day — same tone as the Log.}

**Uncommitted work:**
- {project: description of what's pending, or "All clean"}

**Daily note:** [[$CURRENT_DATE]]

**Tomorrow:**
- {natural next steps, open threads, anything time-sensitive}

---

Important:
- Don't duplicate what `/end-session` already wrote — read it and reference it
- The daily note should feel like a journal entry, not a database dump
- If no projects had activity, still create the daily note (the user might fill in reflections)
- Flag uncommitted work clearly — it's the most actionable thing for tomorrow morning
- Structured data belongs in frontmatter (projects, decisions, open-threads). The body is for humans.
