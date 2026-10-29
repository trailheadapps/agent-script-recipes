# Agent Script Recipes

A collection of recipe-style examples for building Agentforce agents using Agent Script (`.agent` files) and supporting Apex services.

## AI Rules Reference

Detailed rules and guidelines are in the `.airules/` directory. Read the relevant file **only when working on that topic**:

| File                                                               | Description                                                                               |
| ------------------------------------------------------------------ | ----------------------------------------------------------------------------------------- |
| [`.airules/AGENT_SCRIPT.md`](.airules/AGENT_SCRIPT.md)             | Comprehensive rules for writing `.agent` files (syntax, subagents, actions, instructions) |
| [`.airules/APEX_RULES.md`](.airules/APEX_RULES.md)                 | Apex coding standards (bulkification, security, testing, `@InvocableMethod` patterns)     |
| [`.airules/README_STRUCTURE.md`](.airules/README_STRUCTURE.md)     | Standard structure for recipe README files                                                |
| [`.airules/MERMAID_DIAGRAMS.md`](.airules/MERMAID_DIAGRAMS.md)     | Rules for Mermaid diagram formatting in docs                                              |
| [`.airules/GENERATE_CHANGELOG.md`](.airules/GENERATE_CHANGELOG.md) | Prompt and format for generating `CHANGELOG.md` from git commits                          |

## Project Layout

- **Employee Agent scripts:** `force-app/**/aiAuthoringBundles/**/*.agent`
- **Service Agent scripts:** `force-app-service/**/aiAuthoringBundles/**/*.agent`
- **Apex services:** `force-app/**/classes/*.cls` and `force-app-service/**/classes/*.cls`
- **Recipes:** each subdirectory under `force-app/main/` is a self-contained recipe
- **Service Agent recipes:** `force-app-service/` contains service agent examples that require a `default_agent_user`

## Commands

- Format check: `npm run prettier:verify` (fix with `npm run prettier`)
- Lint: `npm run lint`
- Validate a bundle: `sf agent validate authoring-bundle --api-name <Bundle> -o <org>`
- Deploy one recipe: `sf project deploy start -d force-app/main/<group>/<recipe> -o <org>`
- Run an agent: `sf agent preview start --authoring-bundle <Bundle> --use-live-actions -o <org>`, then `preview send` and `preview end`. Traces are saved under `.sfdx/agents/<Bundle>/sessions/`.

## Working Rules

- Validation passing does not prove behavior. After changing a `.agent` file, run it in preview and check the trace (action ran, transition happened, expected subagent).
- Do not chain `transition to` after an action's `set` lines; it is silently dropped. Use `after_reasoning` (see `.airules/AGENT_SCRIPT.md`).
- Keep each recipe's README snippets identical to its `.agent` file, and follow `.airules/README_STRUCTURE.md`.
- Commits use conventional prefixes (`feat:`, `fix:`, `docs:`). The pre-commit hook runs lint-staged (Prettier).
