---
title: AI Setup
tags:
  - ai
  - setup
---

# AI Setup

How AI tools are configured for this vault. The goal is to use Claude as the primary interface for reading, writing, and reasoning over your second brain.

## Components

- [[Command Workflow]] — How to use the 10 slash commands throughout a typical day
- [[Context Manifest]] — The tiered context loading system and how projects declare dependencies

## How it works

This vault is designed to be read and written by Claude via:

- **Claude Code** with the obsidian-skills plugin — gives Claude knowledge of Obsidian-flavored Markdown, Bases, Canvas, and CLI access to the vault
- **Custom slash commands** — 10 commands for context loading, daily lifecycle, and vault maintenance (see [[Command Workflow]])

The vault serves as shared memory between you and Claude — structured so AI can navigate it, understand context, and make useful updates.

## Customizing

You can add your own slash commands beyond the 10 that come with the setup. Store them in `~/.claude/commands/` — see the [Claude Code docs](https://docs.anthropic.com/en/docs/claude-code) for the format.

Document any custom commands or MCP servers you add below so future sessions know what's available.

## Custom commands

<!-- Add your own commands here as you create them -->

## MCP servers

<!-- Document any MCP servers you connect here -->
