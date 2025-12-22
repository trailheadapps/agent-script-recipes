# Agent Script Rules & Guide

This document provides comprehensive rules and guidance for building valid Agent Script configurations (`.agent` files).

---

## Discovery Questions

Before writing Agent Script, work through these questions to understand requirements:

### 1. Agent Identity & Purpose

- **What is the agent's name?** (letters, numbers, underscores only; no spaces; max 80 chars)
- **What is the agent's primary purpose?** (This becomes the description)
- **What personality should the agent have?** (Friendly, professional, formal, casual?)
- **What should the welcome message say?**
- **What should the error message say?**

### 2. Topics & Conversation Flow

- **What distinct conversation areas (topics) does this agent need?**
- **What is the entry point topic?** (The first topic users interact with)
- **How should the agent transition between topics?**
- **Are there any topics that need to delegate to other topics and return?**

### 3. State Management

- **What information needs to be tracked across the conversation?**
    - User data (name, email, preferences)?
    - Process state (step completed, status)?
    - Collected inputs (selections, answers)?
- **What external context is needed?** (session ID, user record, etc.)

### 4. Actions & External Systems

- **What external systems does the agent need to call?**
    - Salesforce Flows
    - Apex classes
    - Prompt templates
    - External APIs
- **For each action:**
    - What inputs does it need?
    - What outputs does it return?
    - When should it be available?

### 5. Reasoning & Instructions

- **What should the agent do in each topic?**
- **Are there conditions that change the instructions?**
- **Should any actions run automatically before/after reasoning?**

---

## File Structure & Block Ordering

Top-level blocks MUST appear in this order:

```agentscript
# 1. CONFIG (required) - Agent metadata
config:
   agent_name: "DescriptiveName"
   ...

# 2. VARIABLES (optional) - State management
variables:
   ...

# 3. SYSTEM (required) - Global settings
system:
   messages:
      welcome: "..."
      error: "..."
   instructions: "..."

# 4. CONNECTIONS (optional) - Escalation routing
connections:
   ...

# 5. KNOWLEDGE (optional) - Knowledge base config
knowledge:
   ...

# 6. LANGUAGE (optional) - Locale settings
language:
   ...

# 7. START_AGENT (required) - Entry point
start_agent topic_selector:
   description: "..."
   reasoning:
      actions:
         ...

# 8. TOPICS (at least one required)
topic my_topic:
   description: "..."
   actions:
      ...
   reasoning:
      ...
```

---

## Block Internal Ordering

### Within `start_agent` and `topic` blocks:

1. `description` (required)
2. `system` (optional - for instruction overrides)
3. `actions` (optional - action definitions)
4. `reasoning` (required)
5. `after_reasoning` (optional)

### Within `reasoning` blocks:

1. `instructions` (required)
2. `actions` (optional)

---

## Required Elements

Every Agent Script MUST have:

- `config` block with `agent_name`
- `system` block with `messages.welcome`, `messages.error`, and `instructions`
- `start_agent` block with `description` and `reasoning.actions`
- At least one `topic` block with `description` and `reasoning`

---

## Naming Rules

All names (agent_name, topic names, variable names, action names):

- Can contain only letters, numbers, and underscores
- Must begin with a letter
- Cannot include spaces
- Cannot end with an underscore
- Cannot contain two consecutive underscores
- Maximum 80 characters

---

## Indentation & Comments

- Use spaces (not tabs)
- Recommended: 3 spaces per level
- Maintain consistent indentation throughout
- Use `#` for comments (Python-style)

```agentscript
# This is a comment
config:
   agent_name: "My_Agent"  # Inline comment
```

---

## Block Reference

### Config Block

```agentscript
config:
   # Required
   agent_name: "DescriptiveName"           # Unique identifier (letters, numbers, underscores)

   # Optional with defaults
   agent_label: "DescriptiveName"               # Display name (defaults to normalized agent_name)
   description: "Agent description"       # What the agent does
   agent_type: "AgentforceServiceAgent"  # or "AgentforceEmployeeAgent"
   default_agent_user: "user@example.com" # Required for AgentforceServiceAgent
```

### Variables Block

```agentscript
variables:
   # MUTABLE variables - agent can read AND write (MUST have default value)
   my_string: mutable string = ""
      description: "Description for slot-filling"

   my_number: mutable number = 0

   my_bool: mutable boolean = False

   my_list: mutable list[string] = []

   my_object: mutable object = {}

   # LINKED variables - read-only from external context (MUST have source, NO default)
   session_id: linked string
      description: "The session ID"
      source: @session.sessionID
```

**Type Support Matrix:**

| Type        | Mutable | Linked | Actions |
| ----------- | ------- | ------ | ------- |
| `string`    | ✅      | ✅     | ✅      |
| `number`    | ✅      | ✅     | ✅      |
| `boolean`   | ✅      | ✅     | ✅      |
| `object`    | ✅      | ❌     | ✅      |
| `date`      | ✅      | ✅     | ✅      |
| `timestamp` | ✅      | ✅     | ✅      |
| `currency`  | ✅      | ✅     | ✅      |
| `id`        | ✅      | ✅     | ✅      |
| `list[T]`   | ✅      | ❌     | ✅      |
| `datetime`  | ❌      | ❌     | ✅      |
| `time`      | ❌      | ❌     | ✅      |
| `integer`   | ❌      | ❌     | ✅      |
| `long`      | ❌      | ❌     | ✅      |

**Boolean values MUST be capitalized:** `True` or `False` (never `true` or `false`)

### System Block

```agentscript
system:
   messages:
      welcome: "Welcome message shown when conversation starts"
      error: "Error message shown when something goes wrong"

   # Single-line or multi-line instructions
   instructions: "You are a helpful assistant."

   # OR multi-line with |
   instructions:|
      You are a helpful assistant.
      Always be polite and professional.
      Never share sensitive information.
```

### Topic Block Structure

```agentscript
topic my_topic:
   description: "What this topic handles"

   # Optional: Override system instructions for this topic
   system:
      instructions: "Topic-specific system instructions"

   # Action definitions (what the topic CAN call)
   actions:
      action_name:
         description: "What this action does"
         inputs:
            param1: string
               description: "Parameter description"
            param2: number
         outputs:
            result: string
         target: "flow://MyFlow"

   # Required: Reasoning configuration
   reasoning:
      instructions:->
         | Static instructions that always appear
         if @variables.some_condition:
            | Conditional instructions
         | More instructions with template: {!@variables.value}

      # Actions available to the LLM during reasoning
      actions:
         action_alias: @actions.action_name
            description: "Override description"
            available when @variables.condition == True
            with param1=...           # LLM slot-fills this
            with param2=@variables.x  # Bound to variable
            set @variables.y = @outputs.result

   # Optional: Runs after reasoning completes
   after_reasoning:
      if @variables.should_transition:
         transition to @topic.next_topic
```

---

## Action Definition

### Target Formats

| Short                     | Long                      | Use Case         |
| ------------------------- | ------------------------- | ---------------- |
| `flow`                    | `flow`                    | Salesforce Flow  |
| `apex`                    | `apex`                    | Apex Class       |
| `prompt`                  | `generatePromptResponse`  | Prompt Template  |
| `standardInvocableAction` | `standardInvocableAction` | Built-in Actions |
| `externalService`         | `externalService`         | External APIs    |
| `quickAction`             | `quickAction`             | Quick Actions    |
| `api`                     | `api`                     | REST API         |
| `apexRest`                | `apexRest`                | Apex REST        |

Additional types: `serviceCatalog`, `integrationProcedureAction`, `expressionSet`, `cdpMlPrediction`, `externalConnector`, `slack`, `namedQuery`, `auraEnabled`, `mcpTool`, `retriever`

### Full Action Syntax

```agentscript
actions:
   get_customer:
      description: "Fetches customer information"
      label: "Get Customer"
      require_user_confirmation: False
      include_in_progress_indicator: True
      progress_indicator_message: "Looking up customer..."
      inputs:
         customer_id: string
            description: "The customer's unique ID"
            label: "Customer ID"
            is_required: True
      outputs:
         name: string
            description: "Customer's name"
         email: string
            description: "Customer's email"
            filter_from_agent: False
            is_displayable: True
      target: "flow://GetCustomerInfo"
```

---

## Reasoning Actions

### Input Binding

```agentscript
reasoning:
   actions:
      # LLM slot-fills all parameters
      search: @actions.search_products
         with query=...
         with category=...

      # Mix of bound and slot-filled
      lookup: @actions.lookup_customer
         with customer_id=@variables.current_customer_id  # Bound
         with include_history=...                          # LLM decides
         with limit=10                                     # Fixed value
```

Use `...` to indicate LLM should extract value from conversation.

### Post-Action Directives

Only work with `@actions.*`, NOT with `@utils.*`:

```agentscript
reasoning:
   actions:
      process: @actions.process_order
         with order_id=@variables.order_id
         # Capture outputs
         set @variables.status = @outputs.status
         set @variables.total = @outputs.total
         # Chain another action
         run @actions.send_notification
            with message="Order processed"
            set @variables.notified = @outputs.sent
         # Conditional transition
         if @outputs.needs_review:
            transition to @topic.review
```

### Utility Actions (reasoning.actions only)

| Utility                | Purpose               | Syntax                                          |
| ---------------------- | --------------------- | ----------------------------------------------- |
| `@utils.escalate`      | Escalate to human     | `name: @utils.escalate`                         |
| `@utils.transition to` | Permanent handoff     | `name: @utils.transition to @topic.X`           |
| `@utils.setVariables`  | Set variables via LLM | `name: @utils.setVariables` with `with var=...` |
| `@topic.<name>`        | Delegate (can return) | `name: @topic.X`                                |

```agentscript
reasoning:
   actions:
      # Transition to another topic (permanent handoff)
      go_to_checkout: @utils.transition to @topic.checkout
         description: "Move to checkout when ready"
         available when @variables.cart_has_items == True

      # Escalate to human
      get_help: @utils.escalate
         description: "Connect with a human agent"
         available when @variables.needs_human == True

      # Delegate to topic (can return)
      consult_expert: @topic.expert_topic
         description: "Consult the expert topic"

      # Set variables via LLM
      collect_info: @utils.setVariables
         description: "Collect user preferences"
         with preferred_color=...
         with budget=...
```

---

## Transition Syntax Rules

**CRITICAL: Different syntax depending on context!**

### In `reasoning.actions` (LLM-selected):

```agentscript
go_next: @utils.transition to @topic.target_topic
   description: "Description for LLM"
```

### In Directive Blocks (`after_reasoning`):

```agentscript
transition to @topic.target_topic
```

- NEVER use `@utils.transition to` in directive blocks
- NEVER use bare `transition to` in `reasoning.actions`

---

## Control Flow

### If/Else in Instructions

```agentscript
instructions:->
   | Welcome to the assistant!

   if @variables.user_name:
      | Hello, {!@variables.user_name}!
   else:
      | What's your name?

   if @variables.is_premium:
      | As a premium member, you have access to exclusive features.
```

Note: `else if` is not currently supported.

### Transitions in Directive Blocks

```agentscript
after_reasoning:
   if @variables.completed:
      transition to @topic.summary
```

### Conditional Action Availability

```agentscript
reasoning:
   actions:
      admin_action: @actions.admin_function
         available when @variables.user_role == "admin"

      premium_feature: @actions.premium_function
         available when @variables.is_premium == True
```

---

## Templates & Expressions

### String Templates

Use `{!expression}` for string interpolation:

```agentscript
instructions:->
   | Your order total is: {!@variables.total}
   | Items in cart: {!@variables.cart_items}
   | Status: {!@variables.status if @variables.status else "pending"}
```

### Multiline Strings

Use `|` for multiline content:

```agentscript
instructions:|
   Line one
   Line two
   Line three
```

Or in procedures:

```agentscript
instructions:->
   | Line one
     continues here
   | Line two starts fresh
```

### Supported Operators

| Category    | Operators                                        |
| ----------- | ------------------------------------------------ |
| Comparison  | `==`, `!=`, `<`, `<=`, `>`, `>=`, `is`, `is not` |
| Logical     | `and`, `or`, `not`                               |
| Arithmetic  | `+`, `-` (no `*`, `/`, `%`)                      |
| Access      | `.` (property), `[]` (index)                     |
| Conditional | `x if condition else y`                          |

### Resource References

- `@actions.<name>` - Reference action defined in topic's `actions` block
- `@topic.<name>` - Reference a topic by name
- `@variables.<name>` - Reference a variable
- `@outputs.<name>` - Reference action output (in post-action context)
- `@inputs.<name>` - Reference action input (in procedure context)
- `@utils.<utility>` - Reference utility function (escalate, transition to, setVariables)

---

## Common Patterns

### Simple Q&A Agent

```agentscript
config:
   agent_name: "Simple_QA"

system:
   messages:
      welcome: "Hello! How can I help you today?"
      error: "Sorry, something went wrong."
   instructions: "You are a helpful assistant. Answer questions clearly."

start_agent topic_selector:
   description: "Entry point"
   reasoning:
      actions:
         start: @utils.transition to @topic.main

topic main:
   description: "Answer user questions"
   reasoning:
      instructions:->
         | Help the user with their questions.
```

### Multi-Topic with Transitions

```agentscript
start_agent topic_selector:
   description: "Route to appropriate topic"
   reasoning:
      actions:
         go_sales: @utils.transition to @topic.sales
            description: "Handle sales inquiries"
         go_support: @utils.transition to @topic.support
            description: "Handle support issues"

topic sales:
   description: "Handle sales"
   reasoning:
      instructions:->
         | Help the customer with purchasing.
      actions:
         need_support: @utils.transition to @topic.support
            description: "Transfer to support"

topic support:
   description: "Handle support"
   reasoning:
      instructions:->
         | Help resolve the customer's issue.
      actions:
         need_sales: @utils.transition to @topic.sales
            description: "Transfer to sales"
```

### Action with State Management

```agentscript
variables:
   customer_id: mutable string = ""
   customer_name: mutable string = ""
   customer_loaded: mutable boolean = False

topic customer_service:
   description: "Customer service with data loading"

   actions:
      fetch_customer:
         description: "Get customer details"
         inputs:
            id: string
         outputs:
            name: string
            email: string
         target: "flow://FetchCustomer"

   reasoning:
      instructions:->
         if @variables.customer_id and not @variables.customer_loaded:
            run @actions.fetch_customer
               with id=@variables.customer_id
               set @variables.customer_name = @outputs.name
               set @variables.customer_loaded = True
         if @variables.customer_name:
            | Hello, {!@variables.customer_name}!
         else:
            | Please provide your customer ID.
```

---

## Validation Checklist

Before finalizing an Agent Script, verify:

- [ ] Block ordering is correct (config → variables → system → connections → knowledge → language → start_agent → topics)
- [ ] `config` block has `agent_name` (and `default_agent_user` for service agents)
- [ ] `system` block has `messages.welcome`, `messages.error`, and `instructions`
- [ ] `start_agent` block exists with at least one transition action
- [ ] Each `topic` has a `description` and `reasoning` block
- [ ] All `mutable` variables have default values
- [ ] All `linked` variables have `source` specified (and NO default value)
- [ ] Action `target` uses valid format (`flow://`, `apex://`, etc.)
- [ ] Boolean values use `True`/`False` (capitalized)
- [ ] `...` is used for LLM slot-filling (not as variable default values)
- [ ] `@utils.transition to` is used in `reasoning.actions`
- [ ] `transition to` (without `@utils`) is used in directive blocks
- [ ] Indentation is consistent (3 spaces recommended)
- [ ] Names follow naming rules (letters, numbers, underscores; no spaces; start with letter)

---

## Error Prevention

### Common Mistakes

1. **Wrong transition syntax:**

    ```agentscript
    # WRONG in reasoning.actions
    go_next: transition to @topic.next

    # CORRECT in reasoning.actions
    go_next: @utils.transition to @topic.next

    # CORRECT in directive blocks
    after_reasoning:
       transition to @topic.next
    ```

2. **Missing default for mutable:**

    ```agentscript
    # WRONG
    count: mutable number

    # CORRECT
    count: mutable number = 0
    ```

3. **Wrong boolean case:**

    ```agentscript
    # WRONG
    enabled: mutable boolean = true

    # CORRECT
    enabled: mutable boolean = True
    ```

4. **Using `...` as a variable default (it's for slot-filling only):**

    ```agentscript
    # WRONG - this is slot-filling syntax
    my_var: mutable string = ...

    # CORRECT
    my_var: mutable string = ""
    ```

5. **List type for linked variables:**

    ```agentscript
    # WRONG - linked cannot be list
    items: linked list[string]

    # CORRECT
    items: mutable list[string] = []
    ```

6. **Default value on linked variable:**

    ```agentscript
    # WRONG - linked variables get value from source
    session_id: linked string = ""
       source: @session.sessionID

    # CORRECT
    session_id: linked string
       source: @session.sessionID
    ```

7. **Post-action directives on utilities:**

    ```agentscript
    # WRONG - utilities don't support post-action directives
    go_next: @utils.transition to @topic.next
       set @variables.navigated = True

    # CORRECT - only @actions support post-action directives
    process: @actions.process_order
       set @variables.result = @outputs.result
    ```
