[{{USER_TAG}}] Pull calendar, tasks, and daily note into a prioritized plan for the day. Use the `obsidian` CLI and macOS calendar tools.

## Step 1: Get today's date and daily note

Today's date is $CURRENT_DATE.

Check if a daily note exists for today and read it:

```
obsidian vault="{{VAULT_NAME}}" read path="Daily/$CURRENT_DATE.md"
```

If no daily note exists yet, that's fine — note it and move on.

Also read my weekly goals and current priorities:

```
obsidian vault="{{VAULT_NAME}}" read path="Me/Goals.md"
```

Search for anything tagged as a weekly focus or priority:

```
obsidian vault="{{VAULT_NAME}}" search query="tag:#weekly OR tag:#this-week OR tag:#priority" limit=10
```

## Step 2: Get today's calendar

Pull today's calendar events. Try using macOS `icalBuddy` if available, otherwise use AppleScript:

```bash
# Try icalBuddy first
if command -v icalBuddy &>/dev/null; then
  icalBuddy -f eventsToday
else
  # Fallback: AppleScript via osascript
  osascript -e '
    set today to current date
    set time of today to 0
    set tomorrow to today + (1 * days)
    set output to ""
    tell application "Calendar"
      repeat with cal in calendars
        set evts to (every event of cal whose start date ≥ today and start date < tomorrow)
        repeat with e in evts
          set output to output & (start date of e) & " — " & (summary of e) & linefeed
        end repeat
      end repeat
    end tell
    return output
  '
fi
```

If no calendar tool works, skip and note that calendar couldn't be read.

## Step 3: Get open tasks

Search for incomplete tasks across the vault:

```
obsidian vault="{{VAULT_NAME}}" tasks status=incomplete limit=30
```

Also search for tasks or to-dos mentioned in recent notes:

```
obsidian vault="{{VAULT_NAME}}" search query="- [ ]" limit=20
```

Read any results to understand the full task context.

## Step 4: Check recently modified notes for context

Search for notes modified recently to understand what I've been working on:

```
obsidian vault="{{VAULT_NAME}}" search query="tag:#project OR tag:#active" limit=10
```

Read any that seem relevant to today's plan.

## Step 5: Build the daily plan

Synthesize everything into a prioritized plan using this format:

---

### Today — $CURRENT_DATE

**Calendar:**
- List each event with time and name. If no events, say "No events today."

**Top priorities:**
- 2-3 things that matter most today, based on weekly goals, deadlines, or urgency
- Pull these from goals, tasks, and recent notes — not just the calendar

**Tasks:**
- [ ] List actionable tasks for today, ordered by priority
- Group by project or context if there are many
- Include any overdue tasks that need attention

**Notes:**
- Anything worth flagging — conflicts, blockers, things to prep for tomorrow

---

Important:
- Be concise and actionable — this is a morning briefing, not a report
- If I've written about what matters this week (in goals, daily notes, or tagged notes), use that to rank priorities
- If the vault is sparse, work with what's there and say what's missing
- Use wikilinks ([[Note Name]]) so I can navigate to sources
- If a daily note doesn't exist yet, suggest I create one after reviewing the plan
