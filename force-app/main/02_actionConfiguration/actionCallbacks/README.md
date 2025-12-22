# ActionCallbacks

## Overview

Learn how to use **post-action execution** with the `run` keyword to chain actions and process results. This pattern is essential for multi-step workflows where one action's completion triggers additional actions.

## Agent Flow

```mermaid
%%{init: {'theme':'neutral'}}%%
graph TD
    A[Agent Starts] --> B[Initialize Payment Variables]
    B --> C[start_agent routes to payment_processing]
    C --> D[User Initiates Payment]
    D --> E[Call process_payment Action]
    E --> F[Capture Outputs: transaction_id, success]
    F --> G[Run Callback 1: send_receipt]
    G --> H[Capture receipt_sent Output]
    H --> I[Run Callback 2: award_points]
    I --> J[Capture points_awarded Output]
    J --> K[Run Callback 3: log_transaction]
    K --> L[All Variables Updated]
    L --> M[Display Payment Confirmation]
    M --> N{Another Payment?}
    N -->|Yes| D
    N -->|No| O[End]
```

## Key Concepts

- **`run` keyword**: Execute actions after primary action completes
- **Post-action processing**: Handle action results immediately
- **Action chaining**: Sequential action execution within callbacks
- **One-level depth**: Only one level of `run` nesting allowed
- **Result capture**: Store outputs from each chained action

## How It Works

### Basic Post-Action Execution

After a primary action completes, use `run` to execute follow-up actions:

```agentscript
actions:
   make_payment: @actions.process_payment
      with amount=...
      with method=...
      # Capture primary action outputs
      set @variables.transaction_id = @outputs.transaction_id
      set @variables.payment_successful = @outputs.success
      # Run callback action
      run @actions.send_receipt
         with transaction_id=@variables.transaction_id
         with amount=@variables.payment_amount
         set @variables.receipt_sent = @outputs.sent
```

The `run` block executes **after** the primary action succeeds.

### Multiple Callback Actions

Chain multiple actions sequentially:

```agentscript
make_payment: @actions.process_payment
   with amount=...
   with method=...
   set @variables.transaction_id = @outputs.transaction_id
   set @variables.payment_successful = @outputs.success
   # Callback 1: Send receipt
   run @actions.send_receipt
      with transaction_id=@variables.transaction_id
      with amount=@variables.payment_amount
      set @variables.receipt_sent = @outputs.sent
   # Callback 2: Award loyalty points
   run @actions.award_points
      with amount=@variables.payment_amount
      set @variables.points_awarded = @outputs.points
   # Callback 3: Log for audit
   run @actions.log_transaction
      with transaction_id=@variables.transaction_id
```

Multiple `run` statements execute in sequence after the primary action.

### Complete Recipe Example

```agentscript
topic payment_processing:
   description: "Processes payments with callbacks"

   actions:
      process_payment:
         description: "Processes a payment transaction"
         inputs:
            amount: number
               description: "The payment amount to be processed"
            method: string
               description: "The mode of the payment"
         outputs:
            transaction_id: string
               description: "Unique identifier for the completed transaction"
            success: boolean
               description: "Indicates whether the payment was processed successfully"
         target: "flow://ProcessPayment"

      send_receipt:
         description: "Sends payment receipt"
         inputs:
            transaction_id: string
               description: "The transaction ID to include in the receipt"
            amount: number
               description: "The payment amount to display on the receipt"
         outputs:
            sent: boolean
               description: "Indicates whether the receipt was sent successfully"
         target: "flow://SendReceipt"

      award_points:
         description: "Awards loyalty points"
         inputs:
            amount: number
               description: "The payment amount used to calculate loyalty points"
         outputs:
            points: number
               description: "The number of loyalty points awarded to the customer"
         target: "flow://AwardLoyaltyPoints"

      log_transaction:
         description: "Logs transaction for audit"
         inputs:
            transaction_id: string
               description: "The transaction ID to be logged for audit purposes"
         outputs:
            success: boolean
               description: "Indicates whether the transaction was logged successfully"
         target: "flow://LogTransaction"

   reasoning:
      instructions:->
         | Process payments and handle post-payment tasks.

           Status:
           - Amount: ${!@variables.payment_amount}
           - Method: {!@variables.payment_method}

         if @variables.transaction_id:
            | - Transaction: {!@variables.transaction_id}
         else:
            | - Transaction: None

         | - Success: {!@variables.payment_successful}
           - Receipt sent: {!@variables.receipt_sent}
           - Points: {!@variables.points_awarded}

           Guide the user through the payment process.

           Store the amount first, then process the payment.

      actions:
         set_amount: @utils.setVariables
            with payment_amount=...
         make_payment: @actions.process_payment
            with amount=...
            with method=...
            set @variables.transaction_id = @outputs.transaction_id
            set @variables.payment_successful = @outputs.success
            run @actions.send_receipt
               with transaction_id=@variables.transaction_id
               with amount=@variables.payment_amount
               set @variables.receipt_sent = @outputs.sent
            run @actions.award_points
               with amount=@variables.payment_amount
               set @variables.points_awarded = @outputs.points
            run @actions.log_transaction
               with transaction_id=@variables.transaction_id
```

## Key Code Snippets

### Basic Callback Pattern

```agentscript
actions:
   primary_action: @actions.do_something
      with input=...
      set @variables.result = @outputs.data
      # Callback executes after primary action
      run @actions.handle_result
         with result_data=@variables.result
```

### Multi-Step Chain

```agentscript
create_order: @actions.create_order
   with customer_id=@variables.customer_id
   with items=...
   set @variables.order_id = @outputs.order_id
   # Step 1: Send confirmation
   run @actions.send_confirmation
      with order_id=@variables.order_id
      with email=@variables.customer_email
   # Step 2: Update inventory
   run @actions.update_inventory
      with order_id=@variables.order_id
   # Step 3: Log order
   run @actions.log_order
      with order_id=@variables.order_id
```

### Capturing Callback Outputs

```agentscript
process_payment: @actions.charge_card
   with amount=@variables.total
   set @variables.payment_id = @outputs.payment_id
   run @actions.send_receipt
      with payment_id=@variables.payment_id
      set @variables.receipt_sent = @outputs.sent
   run @actions.award_points
      with amount=@variables.total
      set @variables.points_earned = @outputs.points
```

Each `run` can capture its own outputs into variables.

## Try It Out

### Example: Payment Processing

```text
Agent: I'll help you process your payment securely.

User: Process a payment of $150 using credit card

[Agent calls process_payment action]
  → process_payment(amount=150, method="credit card")
  → Returns: transaction_id="TXN-456", success=true

  [Callback 1: send_receipt]
  → send_receipt(transaction_id="TXN-456", amount=150)
  → Returns: sent=true

  [Callback 2: award_points]
  → award_points(amount=150)
  → Returns: points=150

  [Callback 3: log_transaction]
  → log_transaction(transaction_id="TXN-456")

Agent: Payment processed successfully!
       - Transaction ID: TXN-456
       - Receipt sent: Yes
       - Loyalty points awarded: 150
```

### Behind the Scenes

1. Primary action `process_payment` executes first
2. Outputs captured: `transaction_id`, `success`
3. Callback 1 `send_receipt` runs with transaction data
4. Callback 2 `award_points` runs with amount
5. Callback 3 `log_transaction` runs for audit
6. All variables updated for agent to use in response

## Best Practices

✅ **Capture outputs immediately** - Save action results before chaining

✅ **One level only** - Don't nest run inside run

✅ **Clear dependencies** - Document what each callback expects

✅ **Use variables for data passing** - Store outputs in variables for callbacks

❌ **Don't nest deeply**

```agentscript
# NOT SUPPORTED:
run @actions.a
   run @actions.b  # Only one level allowed for now
```

✅ **Use sequential runs instead**

```agentscript
# Correct approach:
run @actions.step_a
   set @variables.result_a = @outputs.data
run @actions.step_b
   with input=@variables.result_a
run @actions.step_c
```

## When to Use Callbacks

### Use callbacks when:

- Need to perform follow-up actions after primary action
- Want to chain related operations (payment → receipt → points)
- Need to capture and pass data between actions
- Building audit trails or logs

### Don't use callbacks when:

- Actions are independent (use separate reasoning actions)
- Need deep nesting (refactor into separate actions)

## What's Next

- **MultiStepWorkflows**: Build complex workflows with callbacks
- **ErrorHandling**: Add validation between actions
- **AfterReasoning**: Run actions outside of reasoning block
- **ActionDefinitions**: Learn how to define the actions being called

## Testing

Test callback execution:

### Test Case 1: Happy Path

- Process payment with valid inputs
- Verify all callbacks execute in sequence
- Check all variables populated

### Test Case 2: Primary Action Failure

- Simulate payment failure
- Verify callbacks don't execute
- Check error handling

### Test Case 3: Data Flow

- Verify outputs from primary action
- Check data passed to callbacks correctly
- Validate final variable state
