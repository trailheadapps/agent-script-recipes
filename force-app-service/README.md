# Service Agent Recipes

This directory contains Agentforce **Service Agent** examples. Service Agents are external-facing agents (customer support, self-service portals) that run under a dedicated agent user rather than the logged-in user.

## Key Difference from Employee Agents

Service Agents require a `default_agent_user` field in the agent config. This value is org-specific (it contains the org ID), so it cannot be committed to source control. Instead, a placeholder token (`__AGENT_USER_PLACEHOLDER__`) is used in the `.agent` files and replaced at deploy time.

## Deployment

See the root [README](../README.md#installing-the-app-using-a-developer-edition-org) for full deployment steps. The key additional steps for service agents are:

1. `npm run setup:service-agent` — creates the agent user and replaces the placeholder
2. `sf project deploy start --source-dir force-app-service` — deploys the service agent metadata

A pre-commit hook automatically restores the placeholder before any commit so org-specific values are never pushed to the repository.

## Recipes

| Recipe                                                                                     | Description                                                                                                                                           |
| ------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| [CustomerServiceAgent](aiAuthoringBundles/CustomerServiceAgent/CustomerServiceAgent.agent) | Complete customer service agent with issue classification, knowledge base resolution, case management, escalation workflows, and satisfaction surveys |
