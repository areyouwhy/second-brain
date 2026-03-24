# Second Brain

An Obsidian + Claude Code system that gives AI persistent context about who you are, what you're working on, and how you like to work.

## What is this?

A set of Claude Code commands and an Obsidian vault structure that together create a personal knowledge OS. Claude reads your vault to understand your identity, projects, preferences, and work context — so every conversation starts with the right background.

## How it works

- **Obsidian vault** stores your personal knowledge: identity, goals, projects, work, and more
- **10 slash commands** for Claude Code load different tiers of context depending on the task
- **Projects own their dependencies** — each project note declares which vault notes it needs via frontmatter
- **Session lifecycle commands** capture what you learned and decided, so knowledge compounds

## Prerequisites

- [Obsidian](https://obsidian.md) (free)
- [Claude Code](https://claude.ai/code) (requires Claude subscription)
- [obsidian-skills](https://github.com/anthropics/obsidian-skills) plugin for Claude Code

## Recommended plugins

These Obsidian community plugins work well with the vault structure:

| Plugin | What it adds |
|--------|-------------|
| [Dataview](https://github.com/blacksmithgu/obsidian-dataview) | Query notes as data — project dashboards, task views |
| [Templater](https://github.com/SilentVoid13/Templater) | Dynamic templates with dates, prompts, logic |
| [Calendar](https://github.com/liamcain/obsidian-calendar-plugin) | Calendar sidebar for navigating daily notes |

Install them from Obsidian's community plugin browser after setup.

## Quick start

```bash
git clone https://github.com/areyouwhy/second-brain.git
cd second-brain
./setup.sh
```

The setup script will:
1. Ask for your vault name and location
2. Create the vault folder structure with starter notes
3. Install all 10 Claude Code commands configured for your vault

Then open Obsidian, add the vault, and start filling in your notes.

## Commands

| Command | What it does |
|---------|-------------|
| `/context` | Smart loader — detects your project and loads relevant context |
| `/context-me` | Just your identity (lightest) |
| `/context-work` | Identity + career + current role |
| `/context-project` | Deep project context with all dependencies |
| `/context-all` | Everything in the vault (heaviest) |
| `/start-day` | Morning briefing — open threads, uncommitted work, priorities |
| `/end-session` | Wrap up a project work session |
| `/end-day` | End-of-day aggregation across all projects |
| `/update-context-dependencies` | Maintain project dependency declarations |
| `/trace <topic>` | Trace how an idea evolved across your vault |

## Vault structure

```
Your Vault/
├── Me/                    # Identity — who you are
│   ├── About Me.md
│   ├── Preferences.md
│   ├── Goals.md
│   ├── Work & Career.md
│   ├── Interests & Hobbies.md
│   └── People.md
├── Work/                  # Employment & roles
├── Projects/              # Project notes with context-dependencies
├── Computer/              # Hardware, software, setup logs
├── Design/                # Shared design patterns
├── AI Setup/              # AI tools and workflows
├── Templates/             # Note templates
├── Home.md                # Navigation hub
└── context-manifest.md    # Documents the context system
```

## Project notes

Each project note should have frontmatter like:

```yaml
---
title: My Project
tags:
  - project
directory: my-project-folder
context-dependencies:
  - Design/Design System.md
---
```

- `directory` matches against your project's folder name on disk
- `context-dependencies` lists vault notes that should load alongside the project
- Tag with `#project` so commands can discover it

## Work context

Tag your current employer/role note with `#work-current` so `/context-work` can find it dynamically.

## Docs

- [Command Workflow](docs/command-workflow.md) — daily loop, command picker, context weight
- [Vault Style Guide](docs/vault-style-guide.md) — frontmatter, tags, naming, writing conventions

## License

MIT
