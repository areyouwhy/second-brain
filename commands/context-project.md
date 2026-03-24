[{{USER_TAG}}] Deep project context load. Use when you're doing focused work inside a project and want maximum relevant context. Projects declare their own dependencies via frontmatter.

## Step 1: Detect the current project

Check the current working directory. Extract the project folder name.

Search for a matching project note:

```
obsidian vault="{{VAULT_NAME}}" search query="directory: {folder-name}" limit=5
```

If no match is found, list all project notes and ask which one to load:
```
obsidian vault="{{VAULT_NAME}}" search query="tag:#project" limit=20
```

## Step 2: Load Core Identity

```
obsidian vault="{{VAULT_NAME}}" read path="Me/About Me.md"
obsidian vault="{{VAULT_NAME}}" read path="Me/Preferences.md"
obsidian vault="{{VAULT_NAME}}" read path="Me/Goals.md"
```

## Step 3: Read the project note and its dependencies

Read the matched project note. Look at its `context-dependencies` frontmatter and read each listed note.

## Step 4: Gather activity and tasks

Search for recent mentions of the project:
```
obsidian vault="{{VAULT_NAME}}" search query="{project title}" limit=10
```
Read any results that add useful context (daily notes, decisions, etc.)

Search for open tasks related to this project:
```
obsidian vault="{{VAULT_NAME}}" search query="- [ ]" limit=20
```
Filter to tasks in the project note or referencing the project.

## Step 5: Output

---

### Context Loaded (Project: {name})

**Who you are:** 1 sentence

**Project:** Name, status, goal

**Key decisions:** Major choices already made

**Open tasks:** Incomplete items from the vault

**Recent activity:** What's happened lately

**Dependencies loaded:** Which `context-dependencies` were read and why they matter

**Design context:** If Design/Design System.md was a dependency, summarize the relevant design language

**Notes loaded:** Full list of vault notes read

**Tip:** The repo's CLAUDE.md has technical details (architecture, commands, stack). Claude Code reads it automatically.

---

Be thorough but organized. This is the deepest context tier — the user is about to do focused project work.
