# CustomerServiceAgent

## Overview

This recipe demonstrates how to build an **Agentforce Service Agent** — an external-facing agent that runs under a dedicated agent user rather than the logged-in user. The key differentiator from Employee Agents is the `agent_type: "AgentforceServiceAgent"` and `default_agent_user` configuration, which requires an org-specific deployment pipeline.

## Agent Flow

```mermaid
%%{init: {'theme':'neutral'}}%%
graph TD
    A[Start] --> B[start_agent: agent_router]
    B --> C[Transition to triage]
    C --> D[triage subagent]
    D --> E{Customer ID known?}
    E -->|Yes| F[fetch_customer]
    E -->|No| G[Ask for issue]
    F --> G
    G --> H[classify_issue]
    H --> I[search_knowledge_base]
    I --> J[Transition to resolution]
    J --> K[resolution subagent]
    K --> L{KB article found?}
    L -->|Yes| M[create_case]
    L -->|No| N[escalate_case]
```

## Key Concepts

- **Service Agent config**: `agent_type: "AgentforceServiceAgent"` and `default_agent_user` field
- **Placeholder-based deployment**: Source uses `__AGENT_USER_PLACEHOLDER__` replaced at deploy time
- **Subagent transitions**: Router → triage → resolution flow
- **Mixed action targets**: Flows (`flow://`) and Apex (`apex://`) in the same agent

## How It Works

### Service Agent Configuration

Unlike Employee Agents, Service Agents require a dedicated user to run as:

```agentscript
config:
   developer_name: "CustomerService_Agent"
   agent_label: "Customer Service Agent"
   agent_type: "AgentforceServiceAgent"
   default_agent_user: "__AGENT_USER_PLACEHOLDER__"
```

The placeholder is replaced by `npm run setup:service-agent` before deployment.

### Triage Subagent

Handles customer identification, issue classification, and knowledge base search:

```agentscript
subagent triage:
   actions:
      fetch_customer: ...
         target: "flow://FetchCustomer"

      classify_issue: ...
         target: "apex://IssueClassifier"

      search_knowledge_base: ...
         target: "flow://SearchKnowledgeBase"

   reasoning:
      actions:
         identify_customer: @actions.fetch_customer
            available when @variables.customer_id and not @variables.customer_name

         classify_customer_issue: @actions.classify_issue
            available when @variables.issue_description and not @variables.issue_type

         search_kb: @actions.search_knowledge_base
            available when @variables.issue_type and not @variables.kb_article_found
            transition to @subagent.resolution
```

### Resolution Subagent

Routes to case creation or escalation based on KB results:

```agentscript
subagent resolution:
   reasoning:
      actions:
         create_support_case: @actions.create_case
            available when @variables.kb_article_found

         escalate_to_specialist: @actions.escalate_case
            available when not @variables.kb_article_found
```

## Try It Out

### Example: Issue Resolved via Knowledge Base

```text
Agent: Hello! Welcome to Customer Service. How can I help you today?

User: My account is CUST-12345. I can't reset my password.

[fetch_customer → name="Customer", tier="Premium"]
[classify_issue → type="technical", priority="high"]
[search_knowledge_base → kb_article_found=True]
[transitions to resolution]

Agent: I found a knowledge base article that may help resolve your technical issue.
       Let me create a case to track this.

[create_case → case_id="500xx...", case_number="00001234"]

Agent: I've created case 00001234 for your password reset issue.
       Here's the solution from our knowledge base: ...
```

### Example: Issue Escalated

```text
Agent: Hello! Welcome to Customer Service. How can I help you today?

User: I'm being charged incorrectly on my enterprise contract.

[classify_issue → type="billing", priority="high"]
[search_knowledge_base → kb_article_found=False (no match)]
[transitions to resolution]

Agent: I couldn't find a matching solution. Let me escalate this to a specialist.

[escalate_case → escalated=True, specialist_assigned="Billing Support"]

Agent: I've escalated your billing issue to our specialist team.
       They will reach out to you shortly.
```

## Deployment

This recipe requires additional setup compared to Employee Agent recipes:

1. `npm run setup:service-agent` — creates the agent user and replaces the placeholder in all `.agent` files
2. `sf project deploy start --source-dir force-app-service` — deploys the metadata
3. `sf org assign permset -n Agent_Script_Recipes_Data --on-behalf-of <agent-username>` — grants data access

A pre-commit hook automatically restores the placeholder before commits.

## What's Next

- **MultiSubagentNavigation**: More complex multi-subagent routing patterns
- **OpenGateRouter**: Deterministic gate-based routing with authentication
- **ActionChaining**: Sequential action execution patterns

## Testing

### Stub Flow Behavior

The included flows return hardcoded values for testing:

| Flow                  | Always Returns                                                  |
| --------------------- | --------------------------------------------------------------- |
| `FetchCustomer`       | `name="Customer"`, `email="test@example.com"`, `tier="Premium"` |
| `SearchKnowledgeBase` | `articles=["..."]`, `top_article={...}`                         |
| `CreateCase`          | `case_id="500..."`, `case_number="00001234"`                    |
| `EscalateCase`        | `escalated=true`, `specialist_assigned="Technical Support"`     |

### Test 1: Happy Path — KB Resolution

```text
User: My account is CUST-12345. I can't log in.

Agent: [fetches customer, classifies issue, searches KB, creates case]
```

**Expected**: All three triage actions fire in sequence, then transitions to resolution and creates a case.

### Test 2: Escalation Path — No KB Match

```text
User: I need a custom enterprise pricing adjustment.

Agent: [classifies issue, searches KB (no match), escalates]
```

**Expected**: After KB search returns no relevant articles, the agent escalates instead of creating a standard case.

### Test 3: Unknown Customer

```text
User: I need help with my billing.

Agent: [classifies issue directly, skips fetch_customer since no customer_id]
```

**Expected**: `fetch_customer` is not called because `customer_id` is empty. Agent proceeds with classification.
