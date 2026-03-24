[{{USER_TAG}}] Load work and career context. Use when you're focused on professional tasks — job prep, work planning, career thinking.

## Load identity + work context

```
obsidian vault="{{VAULT_NAME}}" read path="Me/About Me.md"
obsidian vault="{{VAULT_NAME}}" read path="Me/Preferences.md"
obsidian vault="{{VAULT_NAME}}" read path="Me/Goals.md"
obsidian vault="{{VAULT_NAME}}" read path="Me/Work & Career.md"
```

## Load current work role

Search for the active work role note:
```
obsidian vault="{{VAULT_NAME}}" search query="tag:#work-current" limit=3
```

Read the top result — this is the current/upcoming employer note.

## Check for recent work notes

```
obsidian vault="{{VAULT_NAME}}" search query="tag:#work" limit=10
```

Read the top 3 most relevant results.

## Set terminal title

```bash
osascript -e 'tell application "iTerm2" to tell current session of current window to set name to "Work"' 2>/dev/null || printf '\033]0;Work\007'
```

## Output

---

### Context Loaded (Work)

**Who you are:** 1-2 sentences

**Current role:** Role, company, start date, what's known so far

**Career context:** Key career themes — skills, experience areas, what you bring

**Recent work activity:** Anything from recent notes tagged with work

**Memory cost:** ~5-8 notes loaded. Use `/context-me` for lighter load or `/context` for project-specific context.

---

Keep it concise and professional. Focus on what's actionable for work-related tasks.
