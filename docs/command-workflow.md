# Command Workflow

How to use the second brain commands throughout a typical day. Use the lightest context that fits the task.

## The Daily Loop

```mermaid
flowchart LR
    T["/today"] --> C["/context"] --> W["Work"] --> E["/end-session"]
    E -->|next project| C
    E --> D["/end-day"]
    style T fill:#1e293b,color:#f0b429,stroke:#f0b429
    style C fill:#1e293b,color:#f0b429,stroke:#f0b429
    style E fill:#1e293b,color:#f0b429,stroke:#f0b429
    style D fill:#1e293b,color:#f0b429,stroke:#f0b429
    style W fill:#1e293b,color:#e2e8f0,stroke:#475569
```

**`/today`** — morning orientation. Calendar, tasks, goals, daily plan.
**`/context`** — start of each project session. Auto-detects project, loads dependencies.
**Work** — just work. Claude has your context. Ask for extra vault notes as needed.
**`/end-session`** — captures what happened. Logs commits, decisions, knowledge.
**`/end-day`** — aggregates all projects, writes the daily note, flags uncommitted work.

## Pick the Right Command

```mermaid
flowchart LR
    Q{Doing what?} -->|Project| ctx["/context"]
    Q -->|Project after long break| ctxp["/context-project"]
    Q -->|Personal| cme["/context-me"]
    Q -->|Career| cw["/context-work"]
    Q -->|Big picture| ctxall["/context-all"]
    Q -->|Idea history| trace["/trace"]
    style ctx fill:#1e293b,color:#f0b429,stroke:#f0b429
    style ctxp fill:#1e293b,color:#f0b429,stroke:#f0b429
    style cme fill:#1e293b,color:#94a3b8,stroke:#475569
    style cw fill:#1e293b,color:#94a3b8,stroke:#475569
    style ctxall fill:#1e293b,color:#94a3b8,stroke:#475569
    style trace fill:#1e293b,color:#94a3b8,stroke:#475569
```

## Context Weight

Lighter = faster + cheaper. Use the minimum that fits.

| Command | Load | When |
|---------|------|------|
| `/context-me` | ~3 notes | Personal, casual, identity questions |
| `/context-work` | ~5-8 notes | Career, job prep, work planning |
| `/context` | varies | Project work (auto-detects) |
| `/context-project` | heavier | Deep project work after a break |
| `/context-all` | entire vault | Cross-project planning, vault maintenance |

## Other Commands

| Command | When |
|---------|------|
| `/trace <topic>` | See how an idea evolved across the vault |
| `/update-context-dependencies` | Audit project dependencies (run occasionally) |

## Building the Habit

The minimum daily loop is three commands: `/today` → `/context` → `/end-day`. Everything else is optional and compounds over time.
