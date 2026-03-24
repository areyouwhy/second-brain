---
title: CLAUDE.md Best Practices
tags:
  - ai
  - system
---

# CLAUDE.md Best Practices

How to organize context between CLAUDE.md files and this vault. They serve different purposes — understanding the split prevents duplication and ensures Claude always has the right context.

## The two systems

**CLAUDE.md files** tell Claude *how to work here*. They contain coding conventions, file structure, tooling, and project-specific rules. Claude Code reads them automatically — no command needed.

**The vault** tells Claude *who you are and what's happening*. It contains identity, goals, decisions, project state, and session history. Loaded on demand via `/context` commands.

The test: **if someone else cloned your repo, should they get this information?**
- Yes → CLAUDE.md
- No → vault note

## The hierarchy

Claude Code reads CLAUDE.md files at multiple levels and merges them top-down:

```
~/.claude/CLAUDE.md                    ← global (all projects)
~/Documents/projects/CLAUDE.md         ← workspace (all projects in this folder)
~/Documents/projects/my-app/CLAUDE.md  ← project (this repo only)
```

### Global (`~/.claude/CLAUDE.md`)

Installed by setup. A thin pointer to the vault — tells Claude the vault exists, where it is, and how to load context. Also holds universal preferences (coding style, response tone).

This is private to your machine and never shared.

**Put here:**
- Vault name and location
- "Run `/context` commands to load context"
- Universal coding preferences ("be concise", "don't over-engineer")
- Tool preferences ("use the obsidian CLI for vault operations")

**Don't put here:**
- Project-specific conventions (use project CLAUDE.md)
- Personal information (use the vault)
- Anything that changes frequently (use the vault)

### Project (`{repo}/CLAUDE.md`)

Checked into git. Tells Claude how to work in this specific codebase. Anyone who clones the repo — collaborator, CI, or a different machine — gets these instructions.

**Put here:**
- Project structure and file layout
- Coding conventions (naming, patterns, frameworks)
- Build and test commands
- What not to touch (generated files, vendor code)
- How to use project-specific tools

**Don't put here:**
- Your identity or preferences (those are in the vault or global CLAUDE.md)
- Session history or project state (those are in vault project notes)
- Anything personal to you — this file is shared

### Vault (`{vault}/CLAUDE.md`)

A special case of project CLAUDE.md. Tells Claude how to work with the vault itself — Obsidian conventions, frontmatter rules, CLI usage. Created by setup alongside the vault scaffold.

## What goes where — quick reference

| Information | Where | Why |
|-------------|-------|-----|
| "This project uses Astro with i18n" | Project CLAUDE.md | Anyone working here needs this |
| "I'm transitioning jobs in May" | Vault (Me/) | Personal, not project-specific |
| "Be concise, don't add docstrings" | Global CLAUDE.md | Universal preference, always active |
| "Use wikilinks for internal links" | Vault CLAUDE.md | Vault-specific convention |
| "Don't modify /generated files" | Project CLAUDE.md | Project convention |
| "The setup script decision: pure bash" | Vault (session note) | Decision history, temporal |
| "Run `/context` to load my context" | Global CLAUDE.md | Always-on pointer to the vault |
| "My current priorities" | Vault (Current Focus) | Changes often, loaded by commands |

## Setting up a new project

When you create a new project:

1. Add a `CLAUDE.md` to the repo root with structure, conventions, and tooling
2. Create a project note in `Projects/` with `directory` and `context-dependencies` frontmatter
3. Run `/update-context-dependencies` to populate dependencies

The CLAUDE.md handles "how to code here." The vault note handles "what's the status, what did I decide, what's next."

## See also

- [[AI Setup]] — Overview of AI tooling
- [[Command Workflow]] — How to use the slash commands
- [[Context Manifest]] — The tiered context loading system
