[{{USER_TAG}}] Trace how the idea "$ARGUMENTS" has evolved over time across the Obsidian vault. Use the `obsidian` CLI to search and read notes.

Follow these steps:

## 1. Search for all mentions

Run a broad search for the topic across the vault:

```
obsidian vault="{{VAULT_NAME}}" search query="<topic>" limit=50
```

Try alternate phrasings, abbreviations, and related terms too — cast a wide net.

## 2. Read each matching note

For every result, read the note to understand context:

```
obsidian vault="{{VAULT_NAME}}" read path="<path>"
```

Extract:
- The **date** (from frontmatter `date` field, filename, or daily note date)
- The **context** — how the topic is mentioned (first idea? a refinement? a reference?)
- Any **tags** or **links** that connect it to other concepts

## 3. Follow backlinks

For the most relevant notes, check what links back to them:

```
obsidian vault="{{VAULT_NAME}}" backlinks file="<name>"
```

This reveals connections the search might have missed. Read any promising backlinks too.

## 4. Build the timeline

Compile everything into a chronological trace with this format:

---

### Trace: <topic>

**First appeared:** <date and note>
**Total mentions:** <count> notes

#### Timeline

For each appearance, chronologically:

- **<date>** — [[Note Name]]
  <1-2 sentence summary of how the topic appears here>
  Connected to: [[Link1]], [[Link2]]

#### Evolution Summary

Write 2-4 sentences describing how the idea has changed — did it start as a vague thought and become a project? Did it branch into sub-topics? Did interest fade?

#### Connection Map

List the main clusters of related notes/tags this topic touches.

---

Important:
- If no results are found, say so clearly and suggest the user might be using a different term
- Dates matter — sort everything chronologically
- Distinguish between a note *about* the topic vs one that merely *mentions* it
- Use wikilinks ([[Note Name]]) in the output so the user can navigate from the result
