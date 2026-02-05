# ComplexStateManagement

## Overview

This recipe demonstrates **advanced state management** with complex data structures including lists of objects, nested objects, and state operations. Learn how to manage rich application state beyond simple variables.

## Agent Flow

```mermaid
%%{init: {'theme':'neutral'}}%%
graph TD
    A[Agent Starts] --> B[Initialize Variables:<br/>tasks: list[object]<br/>user_stats: object<br/>next_task_id: 1]
    B --> C[start_agent routes to task_management]
    C --> D{User Request?}
    D -->|Add Task| E[Create Task Object]
    E --> F[Increment next_task_id]
    F --> G[Call save_tasks Action]
    D -->|Complete Task| H[Update Task in List]
    H --> I[Call calculate_stats]
    I --> J[Update user_stats]
    D -->|Delete Task| K[Remove from List]
    K --> G
    D -->|View Stats| L[Display user_stats]
    D -->|Filter| M[Apply priority_filter]
    G --> N[Display Confirmation]
    J --> N
    L --> N
    M --> N
    N --> D
```

## Key Concepts

- **List variables**: Working with `list[object]` for collections
- **Object variables**: Structured data with properties
- **Counter patterns**: Auto-incrementing IDs
- **Object property access**: Dot notation for nested data
- **Actions for state**: Using actions to manipulate complex state

## How It Works

### Complex Variable Types

#### List of Objects

```agentscript
variables:
   tasks: mutable object = {}
      description: "List of task objects with id, title, status, priority"
```

Each item is an object with properties like:

```json
{ "id": 1, "title": "Task 1", "status": "pending", "priority": "high" }
```

#### Nested Objects

```agentscript
variables:
   user_stats: mutable object = {}
      description: "User statistics object"
```

Objects can store multiple related values.

#### Counter Variable

```agentscript
variables:
   next_task_id: mutable number = 1
      description: "Auto-incrementing task ID"
```

### Checking List Existence

```agentscript
instructions:->
   | Task Manager Status:

   if @variables.tasks:
      | Tasks available
   else:
      | Total tasks: 0
```

### Accessing Object Properties

```agentscript
| Completed: {!@variables.user_stats.completed_tasks}
  Pending: {!@variables.user_stats.pending_tasks}
  Completion rate: {!@variables.user_stats.completion_rate}%
```

### Conceptual Task Operations

The recipe guides the LLM on how to work with tasks:

```agentscript
instructions:->
   | When adding a task, create an object with below properties like:
     "{"
        "id": {!@variables.next_task_id},
        "title": "task title from user",
        "status": "pending",
        "priority": "medium",
        "created": "timestamp"
     "}"

   | Operations you can guide user through:
     "Add task: [title]" → append to @variables.tasks list
     "Complete task [id]" → find and update in list
     "Delete task [id]" → remove from list
     "Show high priority" → filter list by priority
     "Calculate stats" → run {!@actions.calculate_stats}
     "Save changes" → run {!@actions.save_tasks}
```

## Key Code Snippets

### Complete Variables Block

```agentscript
variables:
   tasks: mutable object = {}
      description: "List of task objects with id, title, status, priority"

   user_stats: mutable object = { "sdfsd": 0 }
      description: "User statistics object"

   priority_filter: mutable object = {}
      description: "Active priority filters (high, medium, low)"

   current_task: mutable object = {}
      description: "Task currently being viewed or edited"

   next_task_id: mutable number = 1
      description: "Auto-incrementing task ID"
```

### Topic with State Operations

```agentscript
topic task_management:
   description: "Manages complex task list with state operations"

   actions:
      save_tasks:
         description: "Persists task list to storage"
         inputs:
            tasks: list[object]
               description: "List of task objects to persist"
         outputs:
            success: boolean
               description: "Indicates whether tasks were saved"
            task_count: number
               description: "Total number of tasks saved"
         target: "flow://SaveTasks"

      calculate_stats:
         description: "Calculates task statistics"
         inputs:
            tasks: list[object]
               description: "List of task objects to calculate stats from"
         outputs:
            stats: object
               description: "Statistics object with completed, pending, rate"
         target: "flow://CalculateTaskStats"

   reasoning:
      instructions:->
         | Task Manager Status:

         if @variables.tasks:
            | Tasks: {!@variables.tasks}
         else:
            | Total tasks: 0

         | Completed: {!@variables.user_stats.completed_tasks}
           Pending: {!@variables.user_stats.pending_tasks}
           Completion rate: {!@variables.user_stats.completion_rate}%

         if @variables.priority_filter:
            | Active filters: {!@variables.priority_filter}

               List operations:
               - Adding items to list
               - Removing items from list
               - Updating items in list
               - Filtering lists
               - Searching lists

         | Help the user manage their tasks:
           1. Add new tasks (creates object, adds to list, increments ID)
           2. Mark tasks complete (finds in list, updates status)
           3. Delete tasks (removes from list)
           4. Filter by priority (updates filter list)
           5. View task details (sets current_task object)
           6. Calculate statistics (calls action, updates stats object)

      actions:
         save_tasks: @actions.save_tasks
            with tasks=@variables.tasks

         calculate_stats: @actions.calculate_stats
            with tasks=@variables.tasks
            set @variables.user_stats = @outputs.stats
```

## Try It Out

### Example: Task Management

```text
Agent: Hi! I'm your task manager. I can help you create, organize, and track your tasks.

User: Add a task: Finish project report

[Conceptually creates task object with id=1]

Agent: ✓ Added task #1: "Finish project report"

       Task Manager Status:
       - Total tasks: 1
       - Completed: 0
       - Pending: 1

User: Add another: Review team feedback, high priority

[Creates task with id=2, priority="high"]

Agent: ✓ Added task #2: "Review team feedback" (High priority)

       Task Manager Status:
       - Total tasks: 2
       - Completed: 0
       - Pending: 2

User: Mark task 1 as complete

[Updates task 1 status to "complete"]
[Calls calculate_stats]

Agent: ✓ Marked task #1 as complete!

       Task Manager Status:
       - Total tasks: 2
       - Completed: 1
       - Pending: 1
       - Completion rate: 50%

User: Show high priority tasks

[Filters tasks where priority="high"]

Agent: High priority tasks:
       - Task #2: "Review team feedback" (Pending)
```

## State Management Patterns

### Counter Pattern

Track IDs for new items:

```agentscript
variables:
   next_task_id: mutable number = 1

# After creating task:
# set @variables.next_task_id = @variables.next_task_id + 1
```

### Aggregation Pattern

Compute statistics via action:

```agentscript
calculate_stats: @actions.calculate_stats
   with tasks=@variables.tasks
   set @variables.user_stats = @outputs.stats
```

### Filter Pattern

Track active filters:

```agentscript
variables:
   priority_filter: mutable list[string] = []

instructions:->
   if @variables.priority_filter:
      | Showing only: {!@variables.priority_filter}
```

## Best Practices

### Initialize Complex Types

```agentscript
tasks: mutable object = {}
user_stats: mutable object = {}
```

Always provide defaults.

### Use Actions for Complex Operations

Don't manipulate lists directly - use Flows or Apex:

```agentscript
calculate_stats: @actions.calculate_stats
   with tasks=@variables.tasks
   set @variables.user_stats = @outputs.stats
```

### Check for Empty Lists

```agentscript
   if @variables.tasks:
      | Tasks: {!@variables.tasks}
   else:
      | Total tasks: 0
```

## What's Next

- **MultiStepWorkflows**: Process complex data through workflows
- **ActionCallbacks**: Update state after each action
- **DynamicActionRouting**: Show actions based on state

## Testing

### Test Case 1: Empty State

- tasks = []
- Verify length shows 0
- Test adding first task

### Test Case 2: Multiple Items

- Create 5 tasks
- Verify list length = 5
- Test filtering, updating

### Test Case 3: Object Updates

- Update user_stats
- Verify properties update
- Test nested access
