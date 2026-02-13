# Agent Script Recipes

A collection of recipe-style examples for building Agentforce agents using Agent Script (`.agent` files) and supporting Apex services.

## AI Rules Reference

Detailed rules and guidelines are in the `.airules/` directory. Read the relevant file **only when working on that topic**:

| File                                                               | Description                                                                            |
| ------------------------------------------------------------------ | -------------------------------------------------------------------------------------- |
| [`.airules/AGENT_SCRIPT.md`](.airules/AGENT_SCRIPT.md)             | Comprehensive rules for writing `.agent` files (syntax, topics, actions, instructions) |
| [`.airules/APEX_RULES.md`](.airules/APEX_RULES.md)                 | Apex coding standards (bulkification, security, testing, `@InvocableMethod` patterns)  |
| [`.airules/README_STRUCTURE.md`](.airules/README_STRUCTURE.md)     | Standard structure for recipe README files                                             |
| [`.airules/MERMAID_DIAGRAMS.md`](.airules/MERMAID_DIAGRAMS.md)     | Rules for Mermaid diagram formatting in docs                                           |
| [`.airules/GENERATE_CHANGELOG.md`](.airules/GENERATE_CHANGELOG.md) | Prompt and format for generating `CHANGELOG.md` from git commits                       |

## Project Layout

- **Agent scripts:** `force-app/**/aiAuthoringBundles/**/*.agent`
- **Apex services:** `force-app/**/classes/*.cls`
- **Recipes:** each subdirectory under `force-app/main/` is a self-contained recipe
