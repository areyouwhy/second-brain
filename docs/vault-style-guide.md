# Vault Style Guide

Rules for how notes are written in this vault. Follow these when creating or editing any note — both manually and via Claude.

## Frontmatter

Every note has YAML frontmatter. Required fields depend on note type:

**All notes:**
- `title` — note title
- `tags` — array of tags

**Project notes** (in `Projects/`):
- `date` — creation date (YYYY-MM-DD)
- `status` — `in-progress`, `paused`, `done`
- `last-updated` — date of last meaningful change (YYYY-MM-DD)
- `directory` — disk folder name (for `/context` auto-detection)
- `context-dependencies` — array of vault paths this project needs

**Daily notes:**
- `date` — the day (YYYY-MM-DD)

**Work notes** (active role):
- Add `work-current` tag to identify the current employer/role

## Tags

Lowercase, hyphenated. Use existing tags before inventing new ones.

Core tags: `me`, `identity`, `work`, `work-current`, `project`, `active`, `system`, `context`, `ai`, `design`, `computer`, `daily`, `templates`

Domain tags on project notes: `web`, `coding`, `music`

## File and Folder Naming

- **Notes:** Title case with spaces (`About Me.md`, `Design System.md`)
- **Folders:** Title case (`AI Setup/`, `Setup Log/`)
- **Daily notes:** `YYYY-MM-DD.md`
- **Project notes:** Match the project's public name (`Churri.se.md`, `ruy.se.md`)

## Note Structure

### Opening

```markdown
# Title

One-line description of what this note is.
```

The `#` heading matches the `title` frontmatter. The description line is short — one sentence, no period needed.

### Sections

Use `##` for main sections. Use `###` sparingly and only within a `##` section.

Keep a consistent section order per note type:

**Identity notes** (Me/):
`## Basics` → `## Bio` / content → `## See Also`

**Project notes** (Projects/):
`## Goal` → `## Decisions Made` → `## Design Direction` → `## Links` → `## Session Notes` → `## Log`

Not every project needs every section — use what's relevant. But `## Goal`, `## Links`, and `## Log` should always be present.

**System notes** (AI Setup/):
`## Overview/description` → `## Details` → `## See Also`

### Closing

End with `## See Also` (wikilinks to related notes) or `## Log` (for project notes). No trailing blank sections.

## Writing Style

- **Concise.** Bullet points over paragraphs. Short sentences.
- **Factual.** State what is, not what might be. No hedging.
- **Key-value for structured data.** Use `**Label:** value` for specs, settings, details.
- **Bold for labels** in lists: `- **Stack:** Astro 6 + Tailwind CSS 4`
- **Checkboxes** for action items: `- [ ] Do the thing`
- **HTML comments** for prompts to fill in later: `<!-- Document AI workflows -->`
- **No emojis.** Anywhere.

## Links

- **Internal:** Always wikilinks — `[[Note Name]]` or `[[Note Name#Section]]`
- **External:** Markdown links — `[label](https://...)`
- **Section links:** `[[Note Name#Section|Display Text]]` when linking to a specific part
- Use `## See Also` for related-note links at the bottom of identity and system notes
- Use `## Links` for external URLs in project notes
- Use `## References` for technical reference links

## Log Entries

Project notes have a `## Log` section. One line per event.

Format:
```
- YYYY-MM-DD: What happened in one line
```

Bold important events:
```
- 2026-03-20: **Corrected MIDI understanding** — Orchid follows standard MIDI
```

## Session Notes

Added by `/end-session` under `## Session Notes` (above `## Log`). Most recent first.

Format:
```markdown
### YYYY-MM-DD — Short session title

**Changes:**
- What changed (grouped, not raw commit hashes)

**Insights:**
- Things learned, gotchas, architecture decisions

**Ideas:**
- Features or improvements that came up

**Status:**
- Current state and natural next step
```

## Callouts

Use Obsidian callouts sparingly and only when the note type warrants it:

```markdown
> [!warning] Title
> Content

> [!tip] Title
> Content

> [!info] Title
> Content
```

## Tables

Use for structured comparisons, specs, or command references. Keep them readable — don't overstuff cells.

## What Doesn't Belong in the Vault

- Secrets, API keys, passwords — keep in environment variables or secure storage
- Raw code — stays in repos. Vault notes describe decisions and architecture, not implementation
- Transient task lists — use project checkboxes or daily notes, not standalone task notes
