---
title: Context Manifest
tags:
  - system
  - context
---

# Context Manifest

This vault uses a tiered context system with Claude Code. Commands load different amounts of context depending on the task.

## Tiers

### Core Identity (always loaded)
- Me/About Me.md
- Me/Preferences.md
- Me/Goals.md

### Extended Identity (fallback when no project detected)
- Me/Work & Career.md
- Me/Interests & Hobbies.md
- Me/People.md

### Work Context (on-demand via /context-work)
- Me/Work & Career.md
- Notes tagged #work-current (your active employer/role)
- Notes tagged #work

### Project Context (per-project via /context or /context-project)
- Declared in each project note's `context-dependencies` frontmatter
- Projects are matched by `directory` frontmatter property

## How projects declare dependencies

Each project note in Projects/ should have frontmatter like:

```yaml
---
title: My Project
tags:
  - project
directory: my-project
context-dependencies:
  - Design/Design System.md
  - Computer/Hardware/Some Device.md
---
```

The `directory` field matches against the folder name on disk. The `context-dependencies` list tells context commands which vault notes to load alongside the project.

## See also

- [[Command Workflow]] — How to use all 10 commands throughout a typical day
- [[AI Setup]] — Overview of AI tooling for this vault
