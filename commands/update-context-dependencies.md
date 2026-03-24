Scan all project notes in the vault. For each project, analyze its content and cross-references to suggest updates to its `context-dependencies` frontmatter. Add relevant dependencies, remove stale ones.

## Step 1: Find all project notes

```
obsidian vault="{{VAULT_NAME}}" search query="tag:#project" limit=20
```

Read every project note found.

## Step 2: Build the full vault index

List all notes in the vault so you know what's available as potential dependencies:
```
obsidian vault="{{VAULT_NAME}}" list limit=100
```

## Step 3: Analyze each project

For each project note, also read its most recent session notes from the project's subfolder (e.g., `Projects/{Project Name}/2026-*.md`). Analyze:

### Dependencies

1. **Wikilinks** — Does it link to notes outside Projects/? Those are likely dependencies.
   - e.g., `[[Design System]]`, `[[Orchid ORC-1 Specs]]`, `[[Work & Career]]`
2. **Content overlap** — Does the project mention topics covered by other vault notes?
   - e.g., a web project mentioning design tokens → likely needs Design/Design System.md
   - e.g., an enterprise project mentioning PIM/ERP → likely needs Me/Work & Career.md
3. **Shared stack** — Do multiple projects share tech? If so, they might share dependencies.
   - e.g., Astro + Tailwind projects → Design/Design System.md
4. **Stale dependencies** — Does the current `context-dependencies` list include notes that no longer exist or are no longer relevant?

### Knowledge gaps

5. **Entities without vault notes** — Does the project reference hardware, instruments, APIs, or external services that have meaningful specs but no dedicated vault note?
   - e.g., a project note mentions "Arturia KeyLab 49" with MIDI details scattered in session notes → should be `Computer/Hardware/Arturia KeyLab 49 Specs.md`
   - e.g., session notes mention an API with rate limits, auth quirks, endpoint mappings → could be a `Computer/Software/` note
6. **Knowledge trapped in session notes** — Read through session note files in the project folder. Is there factual, reference-style knowledge (specs, configurations, API behaviors) that would be more useful as a standalone vault note than buried in a session entry?
   - The test: if a *different* project might need this knowledge, it belongs in its own note
   - If it's only useful for understanding what happened in *this* project, it's fine as a session note

## Step 4: Propose changes

For each project, output:

---

### {Project Title}

**Dependencies:**
- ADD: {note path} — reason
- REMOVE: {note path} — reason
- KEEP: {note path} — still relevant
- (or: "No changes needed")

**Knowledge to extract:**
- CREATE: {path} — {what it would contain and why it matters beyond this project}
- UPDATE: {path} — {what new info should be added}
- (or: "None — knowledge is where it belongs")

---

## Step 5: Apply changes (with confirmation)

After showing all proposals, ask: "Apply these changes? (all / pick individually / skip)"

**For dependency changes:** update the project note's frontmatter:
```
obsidian vault="{{VAULT_NAME}}" update path="Projects/{project}/{project}.md" properties='{"context-dependencies": ["path/one.md", "path/two.md"]}'
```
If the obsidian CLI doesn't support property updates, use file editing to update the YAML frontmatter directly.

**For knowledge extraction:** create or update vault notes as proposed. New notes should be factual and reference-style — specs, configuration, behavior docs. After creating a new note, add it to the relevant project's `context-dependencies` if appropriate.

## Step 6: Summary

Output a summary of all changes made:

---

### Vault Updated

**Dependencies:** {count} added, {count} removed across {count} projects
**Notes created:** {count} (list paths)
**Notes updated:** {count} (list paths)
**Projects unchanged:** {count}

---

Important:
- Never remove a dependency the user explicitly added without asking
- Prefer false positives (suggesting a dep that might not be needed) over false negatives (missing one that is)
- Core Identity notes (About Me, Preferences, Goals) are always loaded by the context commands — don't add them as project dependencies
- Keep dependency lists lean — only add notes that meaningfully help when working on that specific project
- Knowledge extraction should be selective: the test is "would a different project need this?" If the answer is no, it stays in session notes
- New vault notes should be reference-style docs (specs, configs, behaviors), not narratives
