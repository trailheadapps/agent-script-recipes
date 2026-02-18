# SystemInstructionOverrides

## Overview

Learn how to **override system instructions per topic** to change agent behavior and persona dynamically. This powerful pattern enables a single agent to adopt different personalities and behaviors in different contexts.

## Agent Flow

```mermaid
%%{init: {'theme':'neutral'}}%%
graph TD
    A[Start] --> B[start_agent: topic_selector]
    B --> C{User Requests Mode}
    C -->|General| D[Transition to general Topic]
    C -->|Professional| E[Transition to professional Topic]
    C -->|Technical| F[Transition to technical Topic]
    C -->|Creative| G[Transition to creative Topic]
    D --> H[Uses Global System Instructions]
    H --> I[Casual, Friendly Mode]
    E --> J[Apply Professional System Override]
    J --> K[Formal Language + Business Etiquette]
    F --> L[Apply Technical System Override]
    L --> M[Precise Terminology + Diagnostic Approach]
    G --> N[Apply Creative System Override]
    N --> O[Enthusiastic + Imaginative Language]
    I --> P{Return to Different Mode?}
    K --> P
    M --> P
    O --> P
    P -->|Yes| C
    P -->|No| Q[Continue in Current Mode]
```

## Key Concepts

- **Topic-level system overrides**: Override global system instructions within a topic
- **Persona switching**: Change agent personality per topic
- **Context-specific behavior**: Adapt tone and approach dynamically
- **Scoped instructions**: Overrides apply only to that specific topic
- **Global vs local**: Understand instruction hierarchy

## How It Works

### Global System Instructions

Define default behavior for all topics:

```agentscript
system:
   instructions: "You are a versatile assistant that adapts tone and behavior based on context. By default you are in general mode."

   messages:
       welcome: "Welcome! I adapt my behavior based on the conversation context."
       error: "I encountered an issue. Please try again."
```

All topics inherit these instructions by default.

### start_agent Entry Point

The `start_agent` block routes users to different modes:

```agentscript
start_agent topic_selector:
   description: "Welcome users and determine the appropriate topic based on user input"

   reasoning:
      instructions:|
         Select the tool that best matches the user's message and conversation history. If it's unclear, make your best guess.

      actions:
         general_mode: @utils.transition to @topic.general
            description: "Use general casual and friendly mode"

         professional_mode: @utils.transition to @topic.professional
            description: "Use professional business mode"

         technical_mode: @utils.transition to @topic.technical
            description: "Use technical support specialist mode"

         creative_mode: @utils.transition to @topic.creative
            description: "Use creative brainstorming mode"
```

### Topic Without Override (Uses Global)

```agentscript
topic general:
   description: "General friendly conversation"

   reasoning:
       instructions: ->
           | Display the below message
             "I'm in general mode - casual and friendly!"
             "I can switch to:"
             "- Professional mode (for business)"
             "- Technical mode (for tech support)"
             "- Creative mode (for brainstorming)"
             "What mode would you like to switch to?"

             Rules:
             If the user does not specify a mode, stay in general mode.
             Depending on the user's response, switch to the appropriate mode using {!@actions.go_professional}, {!@actions.go_technical}, or {!@actions.go_creative}.

       actions:
           go_professional: @utils.transition to @topic.professional
           go_technical: @utils.transition to @topic.technical
           go_creative: @utils.transition to @topic.creative
```

The `general` topic uses the global system instructions since it has no override.

### Topic-Level System Override

Override system instructions for a specific topic:

```agentscript
topic professional:
   description: "Professional business communication"

   system:
       instructions: "You are a formal business professional. Use professional language, avoid casual expressions, focus on efficiency and clarity. Address the user respectfully and maintain a professional tone at all times."

   reasoning:
       instructions: ->
           | Display the below message
             "[Professional Mode Engaged]"
             "I am now operating in professional mode with:"
             "- Formal language"
             "- Business-focused approach"
             "- Structured communication"
             "How may I assist you professionally?"

       actions:
           return_to_general: @utils.transition to @topic.general
```

When in this topic, the agent uses the overridden instructions instead of global ones.

## Key Code Snippets

### Professional Mode Override

```agentscript
topic professional:
   description: "Professional business communication"

   system:
       instructions: "You are a formal business professional. Use professional language, avoid casual expressions, focus on efficiency and clarity. Address the user respectfully and maintain a professional tone at all times."

   reasoning:
       instructions: ->
           | Display the below message
             "[Professional Mode Engaged]"
             "I am now operating in professional mode with:"
             "- Formal language"
             "- Business-focused approach"
             "- Structured communication"
             "How may I assist you professionally?"

       actions:
           return_to_general: @utils.transition to @topic.general
```

### Technical Support Override

```agentscript
topic technical:
   description: "Technical support specialist"

   system:
       instructions: "You are a technical support specialist. Use precise technical terminology, provide step-by-step troubleshooting, ask diagnostic questions, and explain technical concepts clearly. Be patient and thorough."

   reasoning:
       instructions: ->
           | Display the below message
             "[Technical Support Mode]"
             "I am now operating in technical support mode with:"
             "- Precise technical language"
             "- Diagnostic approach"
             "- Step-by-step troubleshooting"
             "How can I assist you with technical issues?"

       actions:
           return_to_general: @utils.transition to @topic.general
```

### Creative Mode Override

```agentscript
topic creative:
   description: "Creative brainstorming assistant"

   system:
       instructions: "You are a creative brainstorming partner. Think outside the box, suggest unconventional ideas, use enthusiastic language, encourage wild ideas, and help explore possibilities without judgment. Be imaginative and supportive."

   reasoning:
       instructions: ->
           | Display the below message
             "[Creative Mode Activated] 🎨"
             "I'm now in creative brainstorming mode with:"
             "- Think big and bold"
             "- No idea too wild"
             "- Explore all possibilities"
             "What shall we dream up together?"

       actions:
           return_to_general: @utils.transition to @topic.general
```

## Try It Out

### Example: Mode Switching

```text
[start_agent routes to general topic]

Agent: Welcome! I adapt my behavior based on the conversation context.

User: Switch to professional mode

[Transitions to professional topic with system override]

Agent: [Professional Mode Engaged]
       I am now operating in professional mode with:
       - Formal language
       - Business-focused approach
       - Structured communication
       How may I assist you professionally?

User: Draft an email to a client

Agent: Certainly. I shall prepare a formal business communication.
       Please provide the following information:
       - Recipient name and title
       - Subject matter
       - Key points to address

       I will structure this with proper business etiquette.

---

User: Switch to creative mode

[Transitions to creative topic with different system override]

Agent: [Creative Mode Activated] 🎨
       I'm now in creative brainstorming mode with:
       - Think big and bold
       - No idea too wild
       - Explore all possibilities
       What shall we dream up together?

User: Come up with some ideas for a product launch

Agent: Ooh, exciting! Let's think BIG! Here are some wild ideas:
       💡 Flash mob in Times Square
       💡 Mystery box campaign with influencers
       💡 AR treasure hunt across cities

       Which direction sparks your imagination?
```

## When to Use Overrides

### Use overrides when

- Different topics need different tones
- Switching between casual and formal contexts
- Technical vs non-technical audiences
- Creative vs analytical tasks
- Role-playing different specialists

### Don't override when

- Consistency is more important
- Simple topic navigation is enough
- Personality stays the same throughout

## Best Practices

✅ **Clear persona definition** - Make behavior expectations explicit

✅ **Consistent within topic** - Keep behavior uniform per topic

✅ **Document overrides** - Explain why each topic has different instructions

✅ **Test transitions** - Verify behavior changes appropriately

❌ **Don't confuse users** - Make transitions clear

❌ **Don't over-complicate** - Only override when truly needed

❌ **Don't contradict** - Ensure overrides make sense together

## Instruction Hierarchy

1. **Topic-level system instructions** (highest priority)
2. **Global system instructions** (fallback)

```text
If topic has system.instructions: use topic's instructions
If topic has no override: use global system.instructions
```

## What's Next

- **MultiTopicOrchestration**: Combine with orchestration patterns
- **TopicDelegation**: Use different personas for specialists
- **ActionDescriptionOverrides**: Adapt action descriptions by context too

## Testing

Test persona switching:

### Test Case 1: Default Behavior

- Stay in general topic
- Verify global instructions apply
- Check casual tone

### Test Case 2: Professional Override

- Transition to professional topic
- Verify formal tone
- Check business language
- Transition back - verify returns to casual

### Test Case 3: Multiple Overrides

- Visit professional topic
- Visit technical topic
- Visit creative topic
- Verify each has distinct behavior

### Test Case 4: Consistency Check

- Stay in one overridden topic
- Complete multiple interactions
- Verify behavior stays consistent
