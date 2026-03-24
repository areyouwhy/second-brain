[{{USER_TAG}}] Start the day. Read yesterday's note and open threads, scan for uncommitted work, surface priorities from the vault. No calendar or mail needed — works with what's in the vault and on disk.

Today's date is $CURRENT_DATE.

## Step 1: Check for today's daily note

Read today's daily note if it exists:

```
obsidian vault="{{VAULT_NAME}}" read path="Daily/$CURRENT_DATE.md"
```

If it exists and the Intentions section already has content, note that — the day was already started. Still run the rest of the steps to surface fresh context, but don't overwrite Intentions.

## Step 2: Read yesterday's daily note

Calculate yesterday's date. Read it:

```
obsidian vault="{{VAULT_NAME}}" read path="Daily/{yesterday}.md"
```

Pull from it:
- `open-threads` from frontmatter — these are the most actionable items to carry forward
- The Log section — what happened, for continuity
- Any Reflections the user wrote

If yesterday's note doesn't exist, search for the most recent daily note:

```
obsidian vault="{{VAULT_NAME}}" search query="tag:#daily" limit=5
```

Read the most recent one found.

## Step 3: Read current focus and goals

```
obsidian vault="{{VAULT_NAME}}" read path="Me/Current Focus.md"
obsidian vault="{{VAULT_NAME}}" read path="Me/Goals.md"
```

[[Current Focus]] is the primary source for today's priorities — it has the active focus areas. [[Goals]] provides the broader context. Check the `last-reviewed` date in Current Focus — if it's more than 2 weeks old, mention that a `/review` might be due.

## Step 4: Scan for uncommitted work and recent project activity

Determine the projects base directory (the vault's parent directory):

```bash
PROJECTS_DIR="$(dirname "$(obsidian vault="{{VAULT_NAME}}" info 2>/dev/null | grep -i path | awk '{print $NF}')" 2>/dev/null)"
if [ -z "$PROJECTS_DIR" ] || [ ! -d "$PROJECTS_DIR" ]; then
  PROJECTS_DIR="$(cd "$(obsidian vault="{{VAULT_NAME}}" path 2>/dev/null)/.." 2>/dev/null && pwd)"
fi
```

Check for uncommitted work across all projects:

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

Check for recent commits (last 3 days) to identify active projects:

```bash
THREE_DAYS_AGO=$(date -v-3d +%Y-%m-%d 2>/dev/null || date -d "3 days ago" +%Y-%m-%d)
for dir in "$PROJECTS_DIR"/*/; do
  name=$(basename "$dir")
  commits=$(cd "$dir" && git log --oneline --after="$THREE_DAYS_AGO" 2>/dev/null | head -5)
  if [ -n "$commits" ]; then
    echo "=== $name ==="
    echo "$commits"
    echo ""
  fi
done
```

For active projects, find their vault notes and read them:

```
obsidian vault="{{VAULT_NAME}}" search query="tag:#project" limit=20
```

Read project notes with recent `last-updated` dates to understand current state.

## Step 5: Gather open tasks

```
obsidian vault="{{VAULT_NAME}}" search query="- [ ]" limit=30
```

Group results by project or vault section.

## Step 6: Create or update the daily note

If no daily note exists for today, create one:

```markdown
---
title: $CURRENT_DATE
tags:
  - daily
date: $CURRENT_DATE
projects: []
decisions: []
open-threads: []
---

# $CURRENT_DATE

## Intentions

{Write 2-4 sentences here based on what was found — priorities, open threads to address, goals for the day. First-person, intentional tone. Not a task list — describe what the day should be about. Use [[wikilinks]] for project names, goals, and vault notes referenced.}

## Log

## Reflections
```

If the daily note already exists but Intentions is empty, fill it in. If Intentions already has content, leave it untouched.

If the daily note uses an older format (e.g., "Morning Plan" instead of "Intentions"), work with whatever sections exist.

## Step 7: Output the briefing

---

### Good morning — $CURRENT_DATE

**Carrying forward:**
- {open threads from yesterday's note, with [[wikilinks]] to project notes}
- {uncommitted work that needs attention}

**Priorities today:**
- {2-3 things that matter most, drawn from goals + open threads + recent momentum}

**Active projects:**
- **{project}** — {current state from project note or last session summary}

**Open tasks:** ({count} across {count} projects)
- {top 5-8 tasks, grouped by project, using [[wikilinks]]}

**Daily note:** [[$CURRENT_DATE]]

---

Important:
- Be concise and warm — this is a morning briefing, not a report
- Prioritize carrying forward open threads and uncommitted work — those are the most actionable
- Use [[wikilinks]] so the user can navigate from the output to Obsidian
- If the vault is sparse, work with what's there. Don't apologize for missing data.
- Don't touch the Log or Reflections sections — Log is for `/end-day`, Reflections are for the user
