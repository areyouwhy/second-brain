---
title: {{date}}
tags:
  - daily
date: {{date}}
projects: []
decisions: []
open-threads: []
---

# {{date}}

## Intentions

## Sessions

```dataview
TABLE WITHOUT ID
  link(file.path, title) AS "Session",
  parent AS "Project"
FROM ""
WHERE contains(tags, "session") AND date = this.date
SORT file.ctime ASC
```

## Log

## Reflections
