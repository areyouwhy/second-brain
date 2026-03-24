[{{USER_TAG}}] Review and update current focus. Look back since last review, compare against priorities, propose changes. Use whenever priorities feel stale — no fixed cadence required.

Today's date is $CURRENT_DATE.

## Step 1: Read current focus and goals

```
obsidian vault="{{VAULT_NAME}}" read path="Me/Current Focus.md"
obsidian vault="{{VAULT_NAME}}" read path="Me/Goals.md"
```

Note the `last-reviewed` date — this tells you how far back to look.

## Step 2: Read activity since last review

Read daily notes from `last-reviewed` to today:

```
obsidian vault="{{VAULT_NAME}}" list path="Daily" sort=modified limit=20
```

Read the daily notes that fall within the review period. Pull out:
- What was worked on (Log sections)
- Decisions made
- Open threads that carried forward repeatedly
- Reflections the user wrote

## Step 3: Check project activity

Scan for session notes written since last review:

```
obsidian vault="{{VAULT_NAME}}" search query="tag:#session" limit=20
```

Read recent session notes to understand what actually happened across projects.

Also check git activity across all project repos:

```bash
REVIEW_SINCE="{last-reviewed date}"
for dir in ~/Documents/projects/*/; do
  name=$(basename "$dir")
  commits=$(cd "$dir" && git log --oneline --after="$REVIEW_SINCE" 2>/dev/null | head -10)
  if [ -n "$commits" ]; then
    echo "=== $name ==="
    echo "$commits"
    echo ""
  fi
done
```

## Step 4: Gather open tasks

```
obsidian vault="{{VAULT_NAME}}" search query="- [ ]" limit=30
```

Group by project. Note which tasks have been sitting untouched since before the last review.

## Step 5: Analyze and propose

Compare what actually happened against what [[Current Focus]] said the priorities were. Consider:

- **Priorities that got attention** — are they done? Still in progress? Still relevant?
- **Priorities that were ignored** — were they deprioritized implicitly? Should they be dropped or kept?
- **Work that happened outside priorities** — should it be reflected in the focus? Was it a distraction or a legitimate shift?
- **New things that emerged** — new projects, new goals, new blockers?
- **Stale tasks** — anything that's been open for multiple reviews without progress?

## Step 6: Output the review

---

### Review — $CURRENT_DATE

**Period:** {last-reviewed} → {today} ({X days})

**What happened:**
- {3-5 bullet summary of actual work done, with [[wikilinks]]}

**Focus alignment:**
- {For each priority in Current Focus: did it get attention? What's the status?}

**Emerged outside focus:**
- {Work that happened but wasn't in the priorities}

**Proposed Current Focus update:**

Show the proposed new version of the Priorities and On the Radar sections. Explain what changed and why.

**Stale items:**
- {Tasks or threads that haven't moved — suggest keep, drop, or defer}

---

## Step 7: Apply changes (with confirmation)

Ask the user: "Want me to update [[Current Focus]] with these changes?"

If yes:
1. Update `Me/Current Focus.md` with the new priorities and on-the-radar items
2. Update the `last-reviewed` date to today's date
3. Confirm the update

Do NOT auto-apply. Always ask first.

Important:
- This is a conversation, not a report. If something is unclear, ask.
- Be honest about misalignment — if priorities were ignored, say so without judgment.
- Keep the proposed focus to 3-5 priorities max. If there are more, force a prioritization conversation.
- Use [[wikilinks]] throughout for navigation.
