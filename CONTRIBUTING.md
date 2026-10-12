# Contributing to Agent Script Recipes

Thank you for your interest in contributing to the Agent Script Recipes project! We welcome contributions from the community.

## Development Steps

1. **Familiarize yourself with the codebase.** Explore the existing recipes to understand the structure and patterns.
2. **Create a new issue.** Before starting your project, create an issue to track what you are trying to add or fix. This allows us to offer suggestions and avoid duplicate work. We will let you know when you're good to start.
3. **Fork this repository.**
4. **Set up your environment.** Refer to the [README](README.md) for details.
5. **Create a topic branch.** Create a branch in your fork based on the `main` branch. Use a descriptive name (e.g., `feature/my-new-recipe` or `fix/issue-number`).
    - If you are a committer, please prefix your branch with `<developer-name>/`.
6. **Edit the code.** Make your changes, following the [AI Rules & Guidelines](#ai-rules--guidelines) below.
7. **Sign the CLA.** External contributors must sign the [Contributor's License Agreement](#cla).
8. **Submit a Pull Request.** Send a PR when you are done. We will review your code, suggest changes if needed, and merge it.

## AI Rules & Guidelines

This project includes a set of rules and guidelines located in the `.airules` directory. These rules are designed to ensure consistency and quality across the codebase, particularly when using AI-assisted coding tools.

**If you are using an AI coding assistant (like Cursor, GitHub Copilot, etc.), please ensure it is aware of these rules.**

The `.airules` directory contains the following files:

### 1. Agent Script Rules (`.airules/AGENT_SCRIPT.md`)

Defines the standards for creating `.agent` files. Key requirements include:

- **File Structure**: specific ordering of blocks (`config`, `variables`, `system`, etc.).
- **Naming Conventions**: snake_case for most elements, specific rules for booleans (`True`/`False`).
- **Validation**: checklist for common errors like missing defaults or invalid transition syntax.

### 2. Apex Rules (`.airules/APEX_RULES.md`)

Guidelines for writing Apex code, especially for Invocable Actions used by agents:

- **Best Practices**: Bulkification, limits compliance, and security enforcement.
- **Patterns**: Use of `InvocableMethod`, proper error handling, and separation of concerns.
- **Testing**: Minimum 75% coverage and meaningful assertions.

### 3. Mermaid Diagram Rules (`.airules/MERMAID_DIAGRAMS.md`)

Standards for diagrams in documentation:

- **Style**: Always use `graph TD` and the `neutral` theme.
- **Structure**: Sequential node naming (A, B, C...) and specific shapes for processes `[]` and decisions `{}`.

### 4. README Structure Rules (`.airules/README_STRUCTURE.md`)

Standard structure and formatting for recipe README files:

- **Sections**: Mandatory order including Overview, Agent Flow, Key Concepts, How It Works, Key Code Snippets, Try It Out, and What's Next.
- **Formatting**: Use of `agentscript` for code blocks and `text` for conversation transcripts.
- **Visuals**: Requirement for Mermaid diagrams in the Agent Flow section.

Please refer to these files for detailed requirements before submitting your contribution.

## Branches

- **Production Branch**: `main`. This is our released branch.
- **Topic Branches**: Work happens in feature or bug-fix branches based on `main`.
    - Keep branches up-to-date using `rebase`.
    - We try to limit merge commits.

## Pull Requests

- Develop features and bug fixes in topic branches.
- Pull request merging is restricted to **squash & merge** only.

### CLA

External contributors will be required to sign a Contributor's License Agreement. You can do so by going to <https://cla.salesforce.com/sign-cla>.
