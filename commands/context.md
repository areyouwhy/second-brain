[{{USER_TAG}}] Smart context loader. Detects where you are and loads only what's relevant from the Obsidian vault. Projects declare their own dependencies via frontmatter — this command just follows them.

## Step 1: Detect the current project

Check the current working directory. Extract the project folder name (e.g., `churri.se` from `~/Documents/projects/churri.se/src/`).

Search for a matching project note:

```
obsidian vault="{{VAULT_NAME}}" search query="directory: {folder-name}" limit=5
```

If a result is found in `Projects/`, read that project note. Look at its frontmatter for:
- `context-dependencies` — a list of vault note paths to load alongside it

## Step 2: Load Core Identity (always)

```
obsidian vault="{{VAULT_NAME}}" read path="Me/About Me.md"
obsidian vault="{{VAULT_NAME}}" read path="Me/Preferences.md"
obsidian vault="{{VAULT_NAME}}" read path="Me/Goals.md"
```

## Step 3: Load context based on detection

**If a project was detected:**

Read each note listed in the project's `context-dependencies` frontmatter. For example, if the project note has:
```yaml
context-dependencies:
  - Design/Design System.md
```
Then read:
```
obsidian vault="{{VAULT_NAME}}" read path="Design/Design System.md"
```

**If no project was detected**, fall back to Extended Identity:

```
obsidian vault="{{VAULT_NAME}}" read path="Me/Work & Career.md"
obsidian vault="{{VAULT_NAME}}" read path="Me/Interests & Hobbies.md"
obsidian vault="{{VAULT_NAME}}" read path="Me/People.md"
```

Plus check recently modified notes for current focus:
```
obsidian vault="{{VAULT_NAME}}" list sort=modified limit=5
```

## Step 4: Set terminal title

After detecting the project (or lack thereof), set the terminal tab title:

```bash
printf '\033]0;Project Name\033\\'
```

- If a project was detected: use the project name (e.g., `Second Brain`, `Churri.se`)
- If no project was detected: use `Claude Code`

## Step 5: Output a briefing

---

### Context Loaded

**Mode:** [Project: {name}] or [General — no project detected]

**Who you are:** 1-2 sentences from About Me

**Preferences:** Key preferences that shape this session

**Active context:**
- If project mode: project status, key decisions, what's next
- If general mode: recent activity, current focus

**Dependencies loaded:** List the `context-dependencies` that were read

**Notes loaded:** Full list of vault notes in this session's context

---

Important:
- Be concise — this is a briefing, not a novel
- Flag anything time-sensitive
- If vault areas are sparse, say so — don't fabricate
- Use wikilinks ([[Note Name]]) for navigation
- If in project mode, mention whether the repo has a CLAUDE.md (don't read it — Claude Code handles that)
