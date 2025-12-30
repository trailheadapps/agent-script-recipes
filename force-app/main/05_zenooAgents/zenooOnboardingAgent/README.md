# Zenoo Onboarding Agent

An Agentforce agent that collects personal information from users during onboarding.

## Overview

The Zenoo Onboarding Agent guides users through a friendly, conversational onboarding process to collect their personal information:
- First Name
- Last Name
- Mobile Phone Number
- Email Address

## Key Concepts

- **Step-by-step data collection**: Asks for one piece of information at a time
- **Variable state management**: Uses mutable variables to track collected data
- **Flow integration**: Saves collected data to Salesforce Contact records
- **Multi-topic navigation**: Transitions from collection to completion

## How It Works

### Topics

1. **topic_selector**: Entry point that routes users to the collection topic
2. **collect_info**: Main topic that collects user information step by step
3. **completion**: Confirms successful onboarding and summarizes collected data

### Variables

| Variable | Type | Description |
|----------|------|-------------|
| first_name | string | User's first name |
| last_name | string | User's last name |
| mobile | string | User's mobile phone number |
| email | string | User's email address |
| onboarding_completed | boolean | Tracks completion status |
| contact_id | string | ID of created Contact record |

### Actions

- **save_contact**: Flow action that creates a Contact record with the collected information

## Files

```
zenooOnboardingAgent/
├── aiAuthoringBundles/
│   └── ZenooOnboardingAgent/
│       ├── ZenooOnboardingAgent.agent      # Agent definition
│       └── ZenooOnboardingAgent.bundle-meta.xml
├── flows/
│   └── ZenooSaveContact.flow-meta.xml      # Flow to save contact
└── README.md
```

## Try It Out

### Example Conversation

```
Agent: Welcome to Zenoo! I'm here to help you get started. Let's collect some basic information to set up your profile.

User: Hi!

Agent: Hello! Let's start with your first name. What should I call you?

User: John

Agent: Nice to meet you, John! What's your last name?

User: Smith

Agent: Thanks John Smith! Could you please share your mobile phone number?

User: +1 555-123-4567

Agent: Great! And finally, what's your email address?

User: john.smith@email.com

Agent: Perfect! Let me confirm the information:
- First Name: John
- Last Name: Smith
- Mobile: +1 555-123-4567
- Email: john.smith@email.com

Is this correct?

User: Yes

Agent: Excellent! Your profile has been created successfully. Welcome to Zenoo! Is there anything else I can help you with?
```

## Deployment

Deploy the agent using Salesforce CLI:

```bash
sf project deploy start -d force-app/main/05_zenooAgents/zenooOnboardingAgent
sf project deploy start -d force-app/main/default/bots/ZenooOnboardingAgent
sf project deploy start -d force-app/main/default/genAiPlannerBundles/ZenooOnboardingAgent_v1
```

## Best Practices

1. **One question at a time**: Don't overwhelm users with multiple questions
2. **Validate inputs**: Check format of mobile and email addresses
3. **Confirm before saving**: Always summarize and confirm collected data
4. **Friendly tone**: Keep the conversation welcoming and helpful
