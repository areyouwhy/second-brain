End-of-day wrap-up. Aggregates across all projects, writes the daily note, and flags anything left open. Global counterpart to `/end-session` (which is project-scoped).

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

Read the project note. Check if `## Session Notes` has entries from today — if so, the session was already logged by `/end-session` and we can pull from there instead of re-analyzing commits.

## Step 3: Fill gaps

For projects that had commits today but no session notes from today (i.e., `/end-session` wasn't run), do a lightweight wrap-up:

- Update `last-updated` in frontmatter to today's date
- Append a log entry to `## Log`: `- {date}: {1-line summary}`
- If `## Session Notes` exists, add a brief entry. If not, skip — `/end-session` is the right tool for detailed session notes. Just capture the log line.

This keeps `/end-day` fast and non-redundant. It doesn't redo work that `/end-session` already did. But it always updates `last-updated` for any project that had activity.

## Step 4: Write the daily note

Check if a daily note exists:
```
obsidian vault="{{VAULT_NAME}}" read path="$CURRENT_DATE.md"
```

If it doesn't exist, create it. If it does, update it.

Fill in the `## Log` section:

```markdown
## Log

### Projects touched
- **{Project 1}** — {1-line summary of today's work}
- **{Project 2}** — {1-line summary}

### Sessions
- {count} sessions across {count} projects

### Key decisions
- {any decisions made today, pulled from session notes or commits}

### Open threads
- {things left uncommitted, unpushed, or unfinished}
- {ideas that came up but weren't acted on}
```

If there are no projects with activity today, note that:
```markdown
## Log

No project activity today.
```

If `## Reflections` is empty, leave it — don't fill it in. That's for the user.

## Step 5: Output

---

### Day Wrapped — $CURRENT_DATE

**Projects active today:**
- {Project}: {commit count} commits — {summary}

**Uncommitted work:**
- {project: description of what's pending, or "All clean"}

**Daily note:** [[$CURRENT_DATE]]

**Tomorrow:**
- {natural next steps, open threads, anything time-sensitive}

---

Important:
- Don't duplicate what `/end-session` already wrote — read it and reference it
- Keep daily note entries scannable — this is a journal, not a report
- If no projects had activity, still create the daily note (the user might fill in reflections or morning planning)
- Flag uncommitted work clearly — it's the most actionable thing for tomorrow morning
