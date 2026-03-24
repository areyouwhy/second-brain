# CLAUDE.md

This is an Obsidian vault that serves as a personal knowledge base and AI-accessible context store. Claude is the primary interface for reading, writing, and reasoning over it.

## Vault Structure

- **Me/** — Identity, career, goals, preferences, people
- **Work/** — Employment and roles
- **Projects/** — Personal projects with context-dependencies
- **Computer/** — Hardware, software, setup logs
- **Design/** — Shared design patterns
- **AI Setup/** — AI tools, commands, workflows
- **Templates/** — Daily Note, New Project
- **Daily/** — Daily notes (YYYY-MM-DD.md)

Key notes: `Home.md` (navigation hub), `AI Setup/Context Manifest.md` (context loading system), `AI Setup/Command Workflow.md` (how to use the commands).

## Context System

This vault uses a tiered context loading system via custom slash commands:

- `/context` — Smart loader: auto-detects project from working directory, loads relevant notes
- `/context-me`, `/context-work`, `/context-project`, `/context-all` — Scoped loaders
- `/start-day` — Morning briefing: open threads, uncommitted work, priorities
- `/end-session`, `/end-day` — Session and day lifecycle wrap-up
- `/review` — Review and update Current Focus
- `/trace` — Track idea evolution across the vault
- `/update-context-dependencies` — Maintain project dependency declarations

## Conventions

- **Frontmatter**: YAML with `title`, `tags`, `date`, `last-updated`, `status`
- **Project notes** include `directory` (disk folder name) and `context-dependencies` (vault paths to load)
- **Wikilinks** (`[[Note Name]]`) for internal linking; markdown links for external URLs
- **Daily notes**: `YYYY-MM-DD.md` in `Daily/`, with Intentions/Log/Reflections sections
- **Callouts**: Obsidian-flavored (`> [!info]`, `> [!warning]`, `> [!tip]`)

## Working With This Vault

- Use the `obsidian` CLI for reading, writing, and searching vault notes
- Respect Obsidian markdown conventions (wikilinks, callouts, frontmatter properties)
- When editing notes, preserve existing frontmatter fields and tag patterns
- Use [[wikilinks]] in daily note prose — connect to projects, session notes, and people
- Project notes own their context dependencies — update `context-dependencies` frontmatter when adding cross-references
