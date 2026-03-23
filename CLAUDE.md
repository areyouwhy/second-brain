# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A public template for setting up an Obsidian + Claude Code second brain system. Contains command templates, a vault scaffold, and a setup script.

## Structure

- `commands/` — 10 Claude Code command templates with `{{VAULT_NAME}}` placeholders
- `vault-scaffold/` — Starter vault structure with template notes
- `setup.sh` — Install script that creates the vault and installs commands
- `README.md` — User-facing documentation

## Conventions

- Commands use `{{VAULT_NAME}}` as a placeholder — the setup script replaces it
- Vault structure conventions must stay consistent between commands and scaffold
- Commands discover content dynamically via tags and frontmatter, not hardcoded paths
- `#work-current` tag identifies the active work role
- `#project` tag identifies project notes
- `directory` frontmatter property links a vault note to a disk folder
- `context-dependencies` frontmatter lists vault notes a project needs
