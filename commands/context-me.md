[{{USER_TAG}}] Lightweight identity-only context load. Use when Claude just needs to know who you are — no project or work context.

## Load Core Identity

```
obsidian vault="{{VAULT_NAME}}" read path="Me/About Me.md"
obsidian vault="{{VAULT_NAME}}" read path="Me/Preferences.md"
obsidian vault="{{VAULT_NAME}}" read path="Me/Goals.md"
```

## Output

---

### Context Loaded (Identity)

**Who you are:** 2-3 sentences from About Me

**Preferences:** Communication style, work style, tools, aesthetic taste

**Goals:** Current goals and priorities

**Notes loaded:** Me/About Me.md, Me/Preferences.md, Me/Goals.md

---

Keep it tight. This is the cheapest context tier (~3 notes).
