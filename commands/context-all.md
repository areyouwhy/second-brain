[{{USER_TAG}}] Full context load. Reads everything in the vault — identity, work, all projects, all dependencies. Use for holistic sessions: planning, optimization, cross-project analysis, vault maintenance.

## Step 1: Load all identity notes

```
obsidian vault="{{VAULT_NAME}}" read path="Me/About Me.md"
obsidian vault="{{VAULT_NAME}}" read path="Me/Preferences.md"
obsidian vault="{{VAULT_NAME}}" read path="Me/Goals.md"
obsidian vault="{{VAULT_NAME}}" read path="Me/Work & Career.md"
obsidian vault="{{VAULT_NAME}}" read path="Me/Interests & Hobbies.md"
obsidian vault="{{VAULT_NAME}}" read path="Me/People.md"
```

## Step 2: Load work context

Search for the current work role and read it:
```
obsidian vault="{{VAULT_NAME}}" search query="tag:#work-current" limit=3
```

Also read:
```
obsidian vault="{{VAULT_NAME}}" search query="tag:#work" limit=10
```

Read any work notes not already loaded.

## Step 3: Load all project notes

Search for all project notes:
```
obsidian vault="{{VAULT_NAME}}" search query="tag:#project" limit=20
```

Read every result. For each project note, also read all notes listed in its `context-dependencies` frontmatter (skip duplicates — don't read the same note twice).

## Step 4: Load system notes

```
obsidian vault="{{VAULT_NAME}}" read path="AI Setup/Context Manifest.md"
obsidian vault="{{VAULT_NAME}}" read path="Design/Design System.md"
obsidian vault="{{VAULT_NAME}}" read path="AI Setup/AI Workflows.md"
```

## Step 5: Check recent activity

```
obsidian vault="{{VAULT_NAME}}" list sort=modified limit=10
```

Read any recently modified notes not already loaded.

## Step 6: Set terminal title

```bash
printf '\033]0;All Context\033\\'
```

## Step 7: Output

---

### Context Loaded (Full)

**Who you are:** 2-3 sentences

**Work:** Current role and status

**All projects:** For each project, 1-2 lines: name, status, what's next

**Cross-project observations:**
- Shared patterns, dependencies, or conflicts between projects
- Things that could benefit from coordination

**Design system status:** Summary of shared visual language

**Recent activity:** What's been happening in the vault

**Open tasks:** All incomplete tasks across all projects

**Notes loaded:** Full list (grouped by section)

---

This is the most expensive context tier. Use it when you need the big picture — not for daily project work.
