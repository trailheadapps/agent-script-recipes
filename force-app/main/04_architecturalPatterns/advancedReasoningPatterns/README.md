# AdvancedReasoningPatterns

## Overview

Master **advanced reasoning techniques** that combine multiple data sources, `before_reasoning` data loading, dynamic instructions, and complex logic. Learn to build sophisticated agents that synthesize information from multiple sources and provide intelligent insights.

## Agent Flow

```mermaid
%%{init: {'theme':'neutral'}}%%
graph TD
    A[Agent Starts] --> B[User Provides user_id]
    B --> C[before_reasoning Triggered]
    C --> D{user_profile Loaded?}
    D -->|No| E[Sequential Data Fetch]
    E --> F[fetch_user_profile]
    F --> G[fetch_account_data]
    G --> H[fetch_order_history]
    H --> I[fetch_support_history]
    I --> J[Compute Insights]
    J --> K[calculate_customer_value → CLV, loyalty_tier]
    K --> L[assess_churn_risk → risk_score, risk_factors]
    L --> M[generate_recommendations]
    M --> N[Build Dynamic Instructions]
    D -->|Yes| N
    N --> O{Churn Risk Level?}
    O -->|Low < 0.3| P[Display: ✅ Low Risk]
    O -->|Moderate| Q[Display: ⚠️ Moderate Risk]
    O -->|High >= 0.7| R[Display: 🚨 High Risk]
    P --> S[Present Intelligence Dashboard]
    Q --> S
    R --> S
    S --> T[User Interaction]
```

## Key Concepts

- **Multi-source data loading**: Fetch from multiple systems in before_reasoning
- **Sequential action chains**: Load dependent data in order
- **Computed insights**: Derive intelligence from raw data
- **Dynamic instruction building**: Create instructions from loaded data
- **Conditional display**: Different UI based on data values
- **@utils.setVariables**: Set variables via LLM slot-filling

## How It Works

### Pre-Loading Multiple Data Sources

Use `before_reasoning` to load all data before building instructions:

```agentscript
before_reasoning:
   if @variables.user_id and not @variables.user_profile:
      # Load profile
      run @actions.fetch_user_profile
         with user_id=@variables.user_id
         set @variables.user_profile = @outputs.profile

      # Chain additional data fetches
      run @actions.fetch_account_data
         with user_id=@variables.user_id
         set @variables.account_data = @outputs.account

      run @actions.fetch_order_history
         with user_id=@variables.user_id
         with limit=10
         set @variables.recent_orders = @outputs.orders

      run @actions.fetch_support_history
         with user_id=@variables.user_id
         set @variables.support_history = @outputs.tickets
```

### Computing Insights from Data

Chain computed metrics after loading raw data:

```agentscript
before_reasoning:
   # ... data loading ...

   # Compute insights
   run @actions.calculate_customer_value
      with user_id=@variables.user_id
      with orders=@variables.recent_orders
      set @variables.customer_lifetime_value = @outputs.clv
      set @variables.loyalty_status = @outputs.loyalty_tier

   run @actions.assess_churn_risk
      with account=@variables.account_data
      with orders=@variables.recent_orders
      with support_tickets=@variables.support_history
      set @variables.churn_risk_score = @outputs.risk_score

   run @actions.generate_recommendations
      with profile=@variables.user_profile
      with clv=@variables.customer_lifetime_value
      with churn_risk=@variables.churn_risk_score
      set @variables.recommended_actions = @outputs.recommendations
```

### Building Dynamic Instructions

Create instructions based on loaded data:

```agentscript
reasoning:
   instructions:->
      | Customer Intelligence Dashboard

      if not @variables.user_id:
         | Please provide your customer ID to view personalized insights.

      if @variables.user_id and @variables.user_profile:
         | Customer Profile:
      if @variables.user_profile:
         | Name: {!@variables.user_profile.name}
           - Loyalty Status: {!@variables.loyalty_status}
           - Lifetime Value: ${!@variables.customer_lifetime_value}
      else:
         | Name: "N/A"

         | Account Health:
      if @variables.churn_risk_score < 0.3:
         | ✅ Low churn risk ({!@variables.churn_risk_score}%)
      if @variables.churn_risk_score >= 0.3 and @variables.churn_risk_score < 0.7:
         | ⚠️ Moderate churn risk ({!@variables.churn_risk_score}%)
      if @variables.churn_risk_score >= 0.7:
         | 🚨 High churn risk ({!@variables.churn_risk_score}%)
```

## Key Code Snippets

### Complete Topic with Multi-Source Loading

```agentscript
topic intelligent_insights:
   description: "Provides intelligent insights by synthesizing multiple data sources"

   actions:
      fetch_user_profile:
         description: "Fetch complete user profile"
         inputs:
            user_id: string
               description: "The unique identifier of the user"
         outputs:
            profile: object
               description: "User profile object with name, contact info, and details"
         target: "flow://FetchUserProfile"

      fetch_account_data:
         description: "Fetch account details"
         inputs:
            user_id: string
               description: "The unique identifier of the user"
         outputs:
            account: object
               description: "Account object with status, balance, and membership"
         target: "flow://FetchAccountData"

      fetch_order_history:
         description: "Fetch recent orders"
         inputs:
            user_id: string
               description: "The unique identifier of the user"
            limit: number
               description: "Maximum number of recent orders to return"
         outputs:
            orders: list[object]
               description: "List of order objects"
         target: "flow://FetchOrderHistory"

      fetch_support_history:
         description: "Fetch support ticket history"
         inputs:
            user_id: string
               description: "The unique identifier of the user"
         outputs:
            tickets: list[object]
               description: "List of support ticket objects"
         target: "flow://FetchSupportHistory"

      calculate_customer_value:
         description: "Calculate customer lifetime value"
         inputs:
            user_id: string
               description: "The unique identifier of the customer"
            orders: list[object]
               description: "List of customer's order history"
         outputs:
            clv: number
               description: "Calculated customer lifetime value"
            loyalty_tier: string
               description: "Customer's loyalty tier (Bronze, Silver, Gold, Platinum)"
         target: "flow://CalculateCustomerValue"

      assess_churn_risk:
         description: "Assess customer churn risk"
         inputs:
            account: object
               description: "Customer account object"
            orders: list[object]
               description: "List of customer orders"
            support_tickets: list[object]
               description: "List of support tickets"
         outputs:
            risk_score: number
               description: "Churn risk score (0.0 to 1.0)"
            risk_factors: list[string]
               description: "List of factors contributing to churn risk"
         target: "flow://AssessChurnRisk"

      generate_recommendations:
         description: "Generate personalized recommendations"
         inputs:
            profile: object
               description: "Customer profile object"
            clv: number
               description: "Customer lifetime value"
            churn_risk: number
               description: "Churn risk score"
         outputs:
            recommendations: list[string]
               description: "List of personalized recommendations"
         target: "flow://GenerateRecommendations"

   before_reasoning:
      if @variables.user_id and not @variables.user_profile:
         run @actions.fetch_user_profile
            with user_id=@variables.user_id
            set @variables.user_profile = @outputs.profile
         run @actions.fetch_account_data
            with user_id=@variables.user_id
            set @variables.account_data = @outputs.account
         run @actions.fetch_order_history
            with user_id=@variables.user_id
            with limit=10
            set @variables.recent_orders = @outputs.orders
         run @actions.fetch_support_history
            with user_id=@variables.user_id
            set @variables.support_history = @outputs.tickets
         run @actions.calculate_customer_value
            with user_id=@variables.user_id
            with orders=@variables.recent_orders
            set @variables.customer_lifetime_value = @outputs.clv
            set @variables.loyalty_status = @outputs.loyalty_tier
         run @actions.assess_churn_risk
            with account=@variables.account_data
            with orders=@variables.recent_orders
            with support_tickets=@variables.support_history
            set @variables.churn_risk_score = @outputs.risk_score
         run @actions.generate_recommendations
            with profile=@variables.user_profile
            with clv=@variables.customer_lifetime_value
            with churn_risk=@variables.churn_risk_score
            set @variables.recommended_actions = @outputs.recommendations

   reasoning:
      instructions:->
         | Customer Intelligence Dashboard

         if not @variables.user_id:
            | Please provide your customer ID to view personalized insights.

         if @variables.user_id and @variables.user_profile:
            | Customer Profile:
         if @variables.user_profile:
            | Name: {!@variables.user_profile.name}
              - Loyalty Status: {!@variables.loyalty_status}
              - Lifetime Value: ${!@variables.customer_lifetime_value}

            | Account Health:
         if @variables.churn_risk_score < 0.3:
            | ✅ Low churn risk ({!@variables.churn_risk_score}%)
         if @variables.churn_risk_score >= 0.3 and @variables.churn_risk_score < 0.7:
            | ⚠️ Moderate churn risk ({!@variables.churn_risk_score}%)
         if @variables.churn_risk_score >= 0.7:
            | 🚨 High churn risk ({!@variables.churn_risk_score}%)

         | Recent Activity:
         if @variables.recent_orders:
            | Orders (last 30 days):
              {!@variables.recent_orders}
         if @variables.support_history:
            | Support Tickets:
              {!@variables.support_history}

         if @variables.recommended_actions:
            | Recommended Actions:
              {!@variables.recommended_actions}

         | What would you like to know more about?

         | If the user provides a new customer ID, use {!@actions.set_user_id} to update the context and {!@actions.load_customer_data} to refresh the dashboard.

      actions:
         load_customer_data: @actions.fetch_user_profile
            with user_id=...

         set_user_id: @utils.setVariables
            description: "Set the user ID to load customer data"
            with user_id=...
```

### Using @utils.setVariables

Allow LLM to set variables via slot-filling:

```agentscript
actions:
   set_user_id: @utils.setVariables
      description: "Set the user ID to load customer data"
      with user_id=...
```

This lets the LLM extract the user_id from conversation and store it.

## Try It Out

### Example: Customer Intelligence

```text
User: Show insights for my customer USER-12345

[LLM calls set_user_id with user_id="USER-12345"]

[before_reasoning triggers data loading:]
  - fetch_user_profile → profile data
  - fetch_account_data → account info
  - fetch_order_history → 10 recent orders
  - fetch_support_history → support tickets
  - calculate_customer_value → CLV = $5,200, tier = Silver
  - assess_churn_risk → risk = 0.65
  - generate_recommendations → 3 actions

Agent: Customer Intelligence Dashboard

       Customer Profile:
       - Name: Jane Smith
       - Loyalty Status: Silver
       - Lifetime Value: $5,200

       Account Health:
       ⚠️ Moderate churn risk (65%)

       Recent Activity:
       - Orders (last 30 days): 8
       - Support Tickets: 2

       Recommended Actions:
       1. Offer loyalty upgrade incentive
       2. Follow up on recent support tickets
       3. Send personalized product recommendations

       What would you like to know more about?
```

## Best Practices

✅ **Load data in before_reasoning** - Don't delay instruction building

✅ **Chain related fetches** - Load dependent data in sequence

✅ **Compute insights** - Derive intelligence from raw data

✅ **Build rich instructions** - Use all available data

✅ **Conditional display** - Adapt based on data values

❌ **Don't load in instructions** - Use before_reasoning instead

❌ **Don't show raw data dumps** - Present meaningful insights

❌ **Don't ignore data quality** - Validate before using

## What's Next

- **BeforeAfterReasoning**: Master lifecycle events
- **ComplexStateManagement**: Handle rich data structures
- **MultiStepWorkflows**: Chain complex data operations
- **CustomerServiceAgent**: See a complete real-world example

## Testing

Test data synthesis:

### Test Case 1: Complete Data

- Provide user_id
- Verify all data sources loaded
- Check insights computed
- Confirm instructions built correctly

### Test Case 2: Missing Data

- Provide user_id with no orders
- Verify graceful handling
- Check default values used

### Test Case 3: High-Value Customer

- CLV > $10,000
- Verify premium treatment indicators
- Check appropriate recommendations

### Test Case 4: High Churn Risk

- Risk score > 0.7
- Verify high risk alert shown
- Check retention actions recommended
