# Agent Script Recipes

A comprehensive collection of **26 recipes** for learning Agent Script - from basic concepts to production-ready patterns.

**✅ All 3 Phases Complete!** Every recipe includes working code, comprehensive documentation, and real-world examples.

## What are Agent Script Recipes?

Recipes are **standalone, working examples** that teach specific Agent Script concepts. Each recipe includes:

- **Working `.agent` file** with comprehensive inline documentation
- **Salesforce bundle metadata** (`.bundle-meta.xml`) for deployment
- **Detailed README** explaining concepts, patterns, and best practices
- **Try It Out examples** showing real conversations
- **Testing guidance** for validation

Think of these as cookbooks for building agents - each recipe focuses on one concept you can learn, adapt, and apply to your own agents.

## How to Use These Recipes

Recipes are organized into **4 progressive categories** that mirror your learning journey from basics to production-ready agents.

### 📁 01_languageEssentials

**Start here!** Master the core Agent Script syntax and fundamental building blocks.

- **HelloWorld** - Your first agent: understand `config`, `system`, and `topic` blocks
- **VariableManagement** - Working with state: mutable vs readonly(linked) variables, and variable types
- **TemplateExpressions** - Dynamic content with `{!}` syntax, conditionals and expressions
- **SystemInstructionOverrides** - Customize system prompts per topic for advanced control

**Recommended order:** HelloWorld → VariableManagement → TemplateExpressions → SystemInstructionOverrides

### 📁 02_actionConfiguration

**Connect to the world!** Learn how agents interact with external systems and Salesforce.

- **ActionDefinitions** - Define actions, inputs/outputs, and connect to Flows/Apex
- **ActionCallbacks** - Process action results and chain operations (one-level)
- **AdvancedInputBindings** - Master fixed, bound, and LLM-filled parameters (called slots)
- **ActionDescriptionOverrides** - Provide context-specific action descriptions
- **PromptTemplateActions** - Invoke Salesforce Prompt Templates as an action

**Recommended order:** ActionDefinitions → ActionCallbacks → AdvancedInputBindings → ActionDescriptionOverrides, then explore based on your needs

### 📁 03_reasoningMechanics

**Build intelligence!** Control how your agent thinks, decides, and processes information.

- **ReasoningInstructions** - Procedural instructions with `instructions:->` and `run` actions
- **ContextHandling** - Leverage context data and `readonly` linked variables effectively
- **AfterReasoning** - Use lifecycle hooks for pre/post-reasoning logic
- **AdvancedReasoningPatterns** - Complex multi-step reasoning and data aggregation

**Recommended order:** ReasoningInstructions → ContextHandling → AfterReasoning → AdvancedReasoningPatterns

### 📁 04_architecturalPatterns

**Build production systems!** Patterns for real-world applications.

- **SimpleQA** - Single-topic Q&A pattern
- **MultiTopicNavigation** - Orchestrate conversations across multiple topics
- **MultiTopicOrchestration** - Advanced topic coordination strategies
- **BidirectionalNavigation** - Implement supervision patterns with transitions
- **MultiStepWorkflows** - Chain actions and pass data between steps
- **ComplexStateManagement** - Handle complex objects, lists, and state patterns
- **DynamicActionRouting** - Filter actions based on context with `available when`
- **ErrorHandling** - Validation, guard clauses, and error handling patterns
- **SafetyAndGuardrails** - Safety with confirmation patterns
- **ExternalAPIIntegration** - External system integration
- **CustomerServiceAgent** - Complete customer service agent example

**Start with:** SimpleQA → MultiTopicNavigation → ErrorHandling, then explore based on your needs

## Recipe Catalog

### Phase 1: Foundational Concepts (Complete)

Core building blocks every Agent Script developer should know.

| Recipe                    | Concept                 | What You'll Learn                                                |
| ------------------------- | ----------------------- | ---------------------------------------------------------------- |
| **HelloWorld**            | Basic agent structure   | `config`, `system`, `topic` blocks and minimal agent anatomy     |
| **SimpleQA**              | Q&A with actions        | Single-topic pattern, multiline strings, action integration      |
| **VariableManagement**    | State management        | All variable types, `mutable` vs `readonly`, `@variables` syntax |
| **ActionDefinitions**     | External integrations   | Action structure, inputs/outputs, targets, binding patterns      |
| **TemplateExpressions**   | Dynamic content         | `{!}` syntax, conditionals, personalization, calculations        |
| **MultiTopicNavigation**  | Topic transitions       | Multiple topics, `@utils.transition`, workflow orchestration     |
| **ReasoningInstructions** | Procedural instructions | `instructions:->`, dynamic instruction building, `run` actions   |
| **ErrorHandling**         | Validation & safety     | Guard clauses, validation patterns, `available when`             |

### Phase 2: Intermediate Concepts (Complete)

Building on the foundation with more sophisticated patterns.

| Recipe                       | Concept                     | What You'll Learn                                         |
| ---------------------------- | --------------------------- | --------------------------------------------------------- |
| **MultiStepWorkflows**       | Action sequences            | Chaining actions, passing data between steps              |
| **ComplexStateManagement**   | Advanced state              | Object manipulation, list operations, state patterns      |
| **DynamicActionRouting**     | Action filtering            | `available when`, context-based selection                 |
| **ConditionalLogicPatterns** | Control flow                | `if`/`else`, comparisons, logical operators               |
| **ContextHandling**          | Session data                | `readonly` variables, context sources, session management |
| **ActionCallbacks**          | Post-action hooks           | Processing results, one-level chaining                    |
| **AdvancedInputBindings**    | Action inputs               | Fixed vs bound vs LLM-filled parameters                   |
| **PromptTemplateActions**    | Prompt Templates as actions | Invoke Prompt Templates via actions, bind inputs/outputs  |
| **SafetyAndGuardrails**      | Production safety           | Confirmation patterns, validation, safety checks          |

### Phase 3: Advanced Concepts (Complete)

Production-ready patterns and real-world applications.

| Recipe                         | Concept             | What You'll Learn                             |
| ------------------------------ | ------------------- | --------------------------------------------- |
| **AfterReasoning**             | Lifecycle events    | `after_reasoning` hook                        |
| **MultiTopicOrchestration**    | Complex flows       | 3+ topic coordination, handoff strategies     |
| **BidirectionalNavigation**    | Supervision         | Transitions to specialist topics and return   |
| **AdvancedReasoningPatterns**  | Complex reasoning   | Multi-step flows, data aggregation            |
| **ExternalAPIIntegration**     | API patterns        | External system integration best practices    |
| **SystemInstructionOverrides** | Topic customization | Per-topic system prompts, namespace overrides |
| **ActionDescriptionOverrides** | Contextual actions  | Context-specific action descriptions          |
| **ProductionPatterns**         | Enterprise ready    | Comprehensive error handling, maintainability |
| **CustomerServiceAgent**       | Real-world example  | Complete customer service implementation      |

## Recipe Structure

Each recipe follows a consistent structure:

```
/RecipeName/
  RecipeName.agent              # Working Agent Script implementation
  RecipeName.bundle-meta.xml    # Salesforce deployment metadata
  README.md                     # Comprehensive documentation
```

### The `.agent` File

Contains the complete Agent Script with:

- **Inline comments** explaining the "why" behind each section
- **Abbreviated explanations** of key concepts
- **Working code** that can be deployed and tested
- **Real-world patterns** you can adapt

### The README

Structured for progressive learning:

- **Overview** - What this recipe teaches
- **Key Concepts** - Bullet point summary
- **How It Works** - Detailed explanations with code examples
- **Key Code Snippets** - Highlighted important patterns
- **Try It Out** - Example conversations showing the agent in action
- **Best Practices** - Do's and don'ts
- **What's Next** - Related recipes to explore
- **Testing** - How to validate the implementation

## Quick Reference

### Common Patterns

**Accessing Variables**

```agentscript
{!@variables.variable_name}              # In templates
@variables.variable_name                  # In expressions
set @variables.variable_name = value      # Setting values
```

**Calling Actions**

```agentscript
run @actions.action_name                  # In procedures
   with param=value
   set @variables.result = @outputs.field
```

**Topic Transitions**

```agentscript
transition to @topic.topic_name           # In procedures
@utils.transition with target=@topic.name # As action
```

**Conditionals**

```agentscript
if @variables.condition:                  # In procedures
   | Instructions for true case
else:
   | Instructions for false case

{!if @variables.condition}               # In templates
   Content for true case
{!else}
   Content for false case
{!endif}
```

### Key Syntax Elements

| Element         | Usage                 | Example                            |
| --------------- | --------------------- | ---------------------------------- |
| `config:`       | Agent metadata        | `agent_name: "MyAgent"`            |
| `system:`       | Global settings       | `instructions: "You are..."`       |
| `variables:`    | State declaration     | `name: mutable string = ""`        |
| `topic name:`   | Define topic          | `topic greeting:`                  |
| `actions:`      | Define external tools | `get_data: ...`                    |
| `reasoning:`    | Topic behavior        | `instructions: "Help user..."`     |
| `->`            | Procedure             | `instructions:->`                  |
| `\|`            | Multiline string      | `\| Line 1`                        |
| `{!}`           | Template expression   | `{!@variables.name}`               |
| `@`             | Resource access       | `@variables`, `@actions`, `@topic` |
| `run`           | Call action           | `run @actions.name`                |
| `set`           | Set variable          | `set @variables.x = 1`             |
| `with`          | Bind input            | `with param=value`                 |
| `...`           | LLM slot-fill         | `with param=...`                   |
| `if`/`else`     | Conditional           | `if @variables.x > 0:`             |
| `transition to` | Change topic          | `transition to @topic.next`        |

## Getting Help

### Documentation Resources

- **Agent Script v1.0.0 Syntax Docs**: `agentscript/docs/agentscript-docs/docs/agentgraph/v1-0-0-syntax/`
- **High-Level Syntax**: Block structure, property types, templates
- **System-Level Blocks**: `config`, `variables`, `system`
- **Topic Blocks**: Actions, reasoning, events
- **Managing State**: Variable types, mutability, slot-filling
- **Defining Actions**: Inputs, outputs, targets
- **Agent Handoff**: Transitions, delegation

### Recipe Development Plan

See `TODO.md` for the complete recipe development roadmap, implementation strategy, and progress tracking.

## Contributing

These recipes are designed to help developers learn Agent Script through practical examples. Each recipe:

- **Is standalone** - Can be understood without reading others
- **Is functional** - Includes working, deployable code
- **Teaches one concept** - Focused on a specific learning objective
- **Follows patterns** - Demonstrates idiomatic Agent Script
- **Is well-documented** - Explains the "why" not just the "what"

## Version

These recipes are based on **Agent Script v1.0.0 syntax**.

Note: The syntax may have small changes based on executive feedback but is largely locked down.

## Quick Start

1. **Clone this repository**
2. **Browse recipes** in order (Phase 1 → Phase 2 → Phase 3)
3. **Read the README** for each recipe to understand concepts
4. **Study the `.agent` file** to see patterns in action
5. **Adapt and experiment** - modify recipes for your use cases
6. **Deploy and test** using the included `.bundle-meta.xml` files

Ready to start? Begin with **HelloWorld** to understand the basics, then progress through the foundational recipes at your own pace!
