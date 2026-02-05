# ConditionalLogicPatterns

## Overview

Master **if/else control flow** and complex conditional logic for building decision-making agents.

## Agent Flow

```mermaid
%%{init: {'theme':'neutral'}}%%
graph TD
    A[Start Loan Evaluation] --> B[Check Required Info]
    B -->|Missing| C[Ask for Missing Fields]
    B -->|Complete| D[Credit Score Check]
    D -->|< 580| E[Reject: Below Minimum]
    D -->|580-669| F{Fair Credit Path}
    F -->|Has Collateral + 2yr Employ| G[Approve: 8.5% Rate]
    F -->|Missing Requirements| H[Review Needed]
    D -->|670-739| I{Good Credit + Income Check}
    I -->|Income >= $40k| J[Approve: 6.5% Rate]
    D -->|>= 740| K[Approve: 4.5% Rate]
    D -->|Check Loan Amount| L{Large Loan?}
    L -->|> $100k| M{Strong Qualifications?}
    M -->|Yes| N[Approve Large Loan]
    M -->|No| O[Reject/Review]
    L -->|<= $100k| P[Standard Process]
```

## Key Concepts

- **if/else statements**: Basic conditionals
- **Comparison operators**: `==`, `!=`, `>`, `<`, `>=`, `<=`
- **Logical operators**: `and`, `or`, `not`
- **Nested conditions**: Complex decision trees
- **Multiple conditions**: Combining criteria

## How It Works

### Basic If

```agentscript
if @variables.credit_score < 580:
   set @variables.approval_status = "rejected"
```

### If-Else

```agentscript
if @variables.credit_score >= 700:
   set @variables.interest_rate = 4.5
else:
   set @variables.interest_rate = 8.5
```

### Multiple Conditions with `and`

```agentscript
if @variables.credit_score >= 700 and @variables.annual_income >= 50000:
   set @variables.approved = True
```

### Multiple Conditions with `or`

```agentscript
if @variables.credit_score >= 740 or @variables.has_collateral:
   set @variables.approved = True
```

### Nested Conditions

```agentscript
if @variables.loan_amount > 100000:
   if @variables.credit_score >= 720:
      if @variables.employment_years >= 3:
         set @variables.approved = True
```

### Not Operator

```agentscript
if not @variables.has_collateral and @variables.credit_score < 700:
   | Warning: Higher risk application
```

## Comparison Operators

```agentscript
== # Equal to
!= # Not equal to
>  # Greater than
<  # Less than
>= # Greater than or equal
<= # Less than or equal
```

## Best Practices

✅ **Simple first** - Check simple conditions before complex ones
✅ **Guard clauses** - Return early for edge cases
✅ **Readable logic** - Use clear variable names  
✅ **Avoid deep nesting** - Max 2-3 levels

## What's Next

- **DynamicActionRouting**: Use conditions with `available when`
- **ErrorHandling**: Validate with conditionals
- **ReasoningInstructions**: Build dynamic logic

## Testing

Test all branches:

- True path
- False path
- Edge cases (==, >, <)
- Combined conditions
