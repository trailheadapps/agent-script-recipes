# AfterReasoning

## Overview

Learn how to use **reasoning lifecycle events** with `after_reasoning`. This hook let you execute code after every reasoning step, enabling logging, cleanup, and state management patterns.

## Agent Flow

```mermaid
%%{init: {'theme':'neutral'}}%%
graph TD
    A[User Sends Message] --> B[Increment turn_count]
    B --> C{First Turn?}
    C -->|Yes| D[Run get_timestamp]
    D --> E[Set session_start_time]
    C -->|No| F[Run log_event: reasoning_started]
    E --> F
    F --> G[Main reasoning.instructions Execute]
    G --> H[Build Response with Turn Count]
    H --> I[after_reasoning Executes]
    I --> J[Run log_event: reasoning_completed]
    J --> K[Response Delivered to User]
    K --> L{Another Message?}
    L -->|Yes| A
    L -->|No| M[End Session]
```

## Key Concepts

- **`after_reasoning`**: Executes after every reasoning step
- **Lifecycle hooks**: Automatic execution on every turn
- **Initialization patterns**: Setup state on first turn
- **Logging patterns**: Track every interaction
- **State updates**: Modify variables at lifecycle points

## How It Works

### after_reasoning Block

Runs **after** the agent completes reasoning:

```agentscript
topic conversation:
   after_reasoning:
      # Log the reasoning completion
      run @actions.log_event
         with event_type="reasoning_completed"
         with event_data="Turn {!@variables.turn_count} completed"
```

**Use for:**

- Logging completion
- Cleanup operations
- Analytics tracking

### Complete Topic Structure

```agentscript
topic conversation:
   description: "Provides a conversation with lifecycle event tracking. Your job is to run the after reasoning event as applicable on every request."

   actions:
      get_timestamp:
         description: "Get current timestamp"
         outputs:
            current_timestamp: string
               description: "Current timestamp in ISO 8601 format (YYYY-MM-DDTHH:mm:ss.sssZ)"
         target: "flow://GetCurrentTimestamp"

      log_event:
         description: "Log an event to the system"
         inputs:
            event_type: string
               description: "Type of event being logged (e.g., reasoning_started, reasoning_completed, user_greeted)"
            event_data: string
               description: "Additional data or context about the event being logged"
         outputs:
            logged: boolean
               description: "Indicates whether the event was successfully logged to the system"
         target: "flow://LogEvent"

   # Main reasoning block
   reasoning:
      instructions:->
         # Increment turn counter
         set @variables.turn_count = @variables.turn_count + 1
         # Initialize session start time on first turn
         if @variables.turn_count == 1:
            run @actions.get_timestamp
               set @variables.session_start_time = @outputs.current_timestamp
         # Log the reasoning start
         run @actions.log_event
            with event_type="reasoning_started"
            with event_data="Turn: {!@variables.turn_count}"

         | Every time you interact with the user, respond to their message showing this information and nothing else:

           - Session Start Time: {!@variables.session_start_time}
           - Current Turn Count: {!@variables.turn_count}


   # AFTER_REASONING: Runs after every reasoning step
   # Use for: Cleanup, final logging, state updates, analytics
   after_reasoning:
      # Log the reasoning completion
      run @actions.log_event
         with event_type="reasoning_completed"
         with event_data="Turn {!@variables.turn_count} completed"
```

## Key Code Snippets

### Turn Counter Pattern

```agentscript
variables:
   turn_count: mutable number = 0
      description: "Number of conversation turns"

reasoning:
   instructions:->
      # Increment turn counter
      set @variables.turn_count = @variables.turn_count + 1
```

### Session Initialization Pattern

```agentscript
reasoning:
   instructions:->
      # [Turn counter initialization omitted for brevity]
      # Initialize session start time on first turn
      if @variables.turn_count == 1:
         run @actions.get_timestamp
            set @variables.session_start_time = @outputs.current_timestamp
```

### Logging Pattern

```agentscript
reasoning:
   instructions:->
      # [Session Initialization omitted for brevity]
      # Log the reasoning start
      run @actions.log_event
         with event_type="reasoning_started"
         with event_data="Turn: {!@variables.turn_count}"

after_reasoning:
   run @actions.log_event
      with event_type="reasoning_completed"
      with event_data="Turn {!@variables.turn_count} completed"
```

## Try It Out

### Example: Turn Counter and Logging

```text
[Turn 1]
User: Hello

[reasoning executes:]
  - turn_count = 1
  - get_timestamp → session_start_time set
  - log_event("reasoning_started", "Turn: 1")
  - Instructions built with turn count

Agent: Hello! Welcome to the conversation. Current Turn Count: 1

[after_reasoning executes:]
  - log_event("reasoning_completed", "Turn 1 completed")

---

[Turn 2]
User: How are you?

[reasoning executes:]
  - turn_count = 2
  - log_event("reasoning_started", "Turn: 2")
  - Instructions built with turn count

Agent: I'm great! Current Turn Count: 2

[after_reasoning executes:]
  - log_event("reasoning_completed", "Turn 2 completed")
```

## Common Use Cases

### Session Initialization

```agentscript
reasoning:
   instructions:->
      if @variables.turn_count == 1:
         run @actions.init_session
            with session_id=@variables.session_id
```

### Pre-loading Data

```agentscript
reasoning:
   instructions:->
      if @variables.user_id and not @variables.user_profile:
         run @actions.fetch_user_profile
            with user_id=@variables.user_id
            set @variables.user_profile = @outputs.profile
```

### Activity Tracking

```agentscript
after_reasoning:
   run @actions.update_last_activity
      with session_id=@variables.session_id
```

### Comprehensive Logging

```agentscript
reasoning:
   instructions:->
      run @actions.log_event
         with event_type="turn_started"
         with event_data="Turn {!@variables.turn_count}"

after_reasoning:
   run @actions.log_event
      with event_type="turn_completed"
      with event_data="Turn {!@variables.turn_count}"
```

## Best Practices

✅ **Keep reasoning fast** - Avoid slow operations that delay responses

✅ **Use after_reasoning for logging** - Don't block the response

✅ **Initialize once** - Check flags to avoid re-initialization

✅ **Handle errors gracefully** - Don't let lifecycle events break reasoning

❌ **Don't overload lifecycle events** - Keep them focused and efficient

❌ **Don't use for main logic** - Use reasoning instructions instead

## Lifecycle vs Instructions

| Aspect               | instructions:->                 | after_reasoning |
| -------------------- | ------------------------------- | --------------- |
| **When**             | During reasoning                | After reasoning |
| **Purpose**          | Setup, init, build instructions | Cleanup, log    |
| **Actions**          | Yes                             | Yes             |
| **Templates**        | Yes                             | No              |
| **Affects response** | Directly                        | No              |

## What's Next

- **AdvancedReasoningPatterns**: Combine lifecycle with complex logic
- **ReasoningInstructions**: Master procedural instructions

## Testing

Test lifecycle execution:

### Test Case 1: First Turn

- Check turn counter starts at 1
- Confirm session_start_time is set
- Verify after_reasoning executes

### Test Case 2: Multiple Turns

- Run 5 consecutive turns
- Verify turn counter increments correctly
- Check timestamps update each turn
- Verify all log events recorded

### Test Case 3: Logging Sequence

- Verify log events in correct order:
    1. reasoning_started (in reasoning)
    2. reasoning_completed (in after_reasoning)
