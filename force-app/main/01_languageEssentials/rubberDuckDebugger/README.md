# RubberDuckDebugger

## Overview

This recipe demonstrates how a focused **persona**, expressed entirely through system and reasoning instructions, shapes an agent's whole behavior - no variables, actions, or flows required. The agent is a Socratic "rubber duck" debugging buddy: instead of handing developers a fix, it helps them find the bug themselves by asking one question at a time. The recipe ships in two bundles - a **text** bundle and a **voice-enabled, spoken-style** bundle - to show both how the agent's instructions are re-tuned for a spoken medium and how a voice connection and synthesized voice are declared directly in the script.

## Agent Flow

```mermaid
%%{init: {'theme':'neutral'}}%%
graph TD
    A[Agent Starts] --> B[Load Config Block]
    B --> C[Initialize System Block]
    C --> D[Display Welcome Message]
    D --> E[start_agent: agent_router]
    E --> F[Transition to debugging Subagent]
    F --> G[Apply Socratic Reasoning Instructions]
    G --> H[Developer describes the bug]
    H --> I[Ask ONE focused question]
    I --> J{Bug found?}
    J -->|No| H
    J -->|Yes| K[Encourage and confirm]
    K --> L[End]
```

## Key Concepts

- **Persona-driven behavior**: Behavior comes from instructions alone - the same building blocks as HelloWorld, no actions or state
- **System vs. reasoning instructions**: The global persona lives in `system.instructions`; the turn-by-turn behavior lives in the subagent's `reasoning.instructions`
- **Behavioral constraints**: Instructing the agent to _withhold_ the answer and ask questions instead - a genuine instruction-design discipline
- **Static procedural instructions**: Using `instructions:->` with `|` template lines that don't branch (the minimal shape)
- **Channel adaptation**: How the _same_ agent's instructions change when replies are spoken aloud vs. read in a chat window
- **ASR-noise repair**: Instructing the agent to expect and reinterpret speech-to-text mistranscriptions of technical vocabulary (spoken-style bundle only)
- **Voice configuration in script**: Declaring a `connection telephony` and `modality voice` block so the voice wiring and synthesized voice travel with the recipe (spoken-style bundle only)
- **Language block for voice**: Pinning `default_locale` so voice mode has a supported language (spoken-style bundle only)

## How It Works

### One Persona, Two Places

The rubber-duck personality is established in two complementary spots.

First, globally, in the `system` block - this applies to every subagent:

```agentscript
system:
   instructions: "You are a friendly rubber-duck debugging buddy for software developers. You help them find bugs themselves by asking thoughtful, Socratic questions rather than handing over fixes."
```

Then, specifically, in the `debugging` subagent's reasoning instructions - this governs what the agent does on each turn. The interesting part is that the instructions tell the agent what **not** to do (don't hand over the fix), which is what makes it a rubber duck rather than a generic Q&A bot.

### The Behavioral Constraint

Most "useful" agents are told to _answer_. This one is deliberately told to _hold back_ and lead with questions:

```agentscript
instructions:->
   | You are the developer's rubber duck. Your job is to help them
     discover the bug on their own, not to solve it for them.

   | Follow these principles:
     Ask ONE focused question at a time, then wait for the answer.
     ...
     Resist the urge to give the fix outright. If they are truly stuck
     after several exchanges, offer a small hint, not the full solution.
```

This is the whole lesson: **the value of the agent comes from the instructions, not from any code.**

### Adapting the Same Agent for Voice

The spoken-style bundle differs from the text bundle on **two** levels: _how it speaks_ (instructions) and _that it speaks at all_ (voice configuration in the script).

**1. Instructions tuned for the ear.** Replies that are read aloud follow different rules than replies in a chat window:

| Concern         | Text bundle             | Spoken-style bundle                  |
| --------------- | ----------------------- | ------------------------------------ |
| Response length | A few sentences is fine | Short - easy to follow by ear        |
| Formatting      | Prose is fine           | No code or markdown read aloud       |
| Symbols/IDs     | Can reference `i++`     | Say them in words: "index plus plus" |

The spoken-style instructions also add one thing the text version never needs: **repairing speech-to-text noise.** When a developer talks, their words reach the agent as an imperfect transcription, and technical vocabulary is the first thing to get mangled - "Agent Script" becomes "agent for script", "returns undefined" becomes "returns on the even", "async" becomes "a sink". The agent reasons over that garbled _text_, not your audio, so the instructions tell it to expect the noise and quietly repair obvious mishears in a debugging context:

```agentscript
| Their words reach you as speech-to-text, so technical vocabulary is
  often garbled - "agent for script" means "Agent Script", "returns on
  the even" means "returns undefined", "a sink" means "async". Read every
  message charitably in a software-debugging context and quietly repair
  obvious mishears.
```

**2. Voice configuration in the script.** The spoken-style bundle also carries three blocks the text bundle doesn't:

```agentscript
# Pin a voice-supported default language
language:
   default_locale: "en_US"

# Wire the agent to a telephony (voice) connection
connection telephony:
   adaptive_response_allowed: True

# Choose and tune the synthesized voice
modality voice:
   voice_id: "hpp4J3VqNfWAUOO0d1Us"
   outbound_speed: 1
   outbound_stability: 0.4
   outbound_similarity: 0.75
```

- **`language`** pins a voice-supported locale. Voice mode only supports certain languages; without this the agent inherits the org's default, and if that isn't supported Agent Builder warns and falls back to English (US). (For multi-locale config, see the **LanguageSettings** recipe.)
- **`connection telephony`** declares that the agent is wired to a voice connection - this is what makes it a voice agent, not just a text agent with terse instructions.
- **`modality voice`** selects the synthesized voice (`voice_id`) and tunes its delivery (speed, stability, similarity). These values are what Agent Builder's **Voice Settings** write back into the script when you pick a voice like "Bella".

> [!IMPORTANT]
> Because the spoken-style bundle declares a telephony connection, it must be deployed to a **voice-provisioned org** (one where that connection is available). A plain text org should use the `RubberDuckDebugger` bundle instead. See Notes.

## Key Code Snippets

### The Text Bundle's Reasoning (RubberDuckDebugger)

```agentscript
subagent debugging:
   description: "Guides the developer to find their own bug through Socratic questioning"

   reasoning:
      instructions:->
         | You are the developer's rubber duck. Your job is to help them
           discover the bug on their own, not to solve it for them.

         | Follow these principles:
           Ask ONE focused question at a time, then wait for the answer.
           Guide with questions like "What did you expect to happen?",
           "What actually happened?", "What changed most recently?", and
           "Which line do you think runs right before it breaks?".
           Reflect their explanation back to them so they hear their own logic.
           Resist the urge to give the fix outright. If they are truly stuck
           after several exchanges, offer a small hint, not the full solution.
           Stay warm, encouraging, and a little playful - an occasional "quack"
           is welcome.
```

### The Spoken-Style Bundle's Reasoning (RubberDuckDebuggerSpokenStyle)

```agentscript
subagent debugging:
   description: "Guides the developer to find their own bug through spoken Socratic questioning"

   reasoning:
      instructions:->
         | You are the developer's rubber duck, talking with them out loud.
           Help them discover the bug on their own instead of handing over the fix.

         | Their words reach you as speech-to-text, so technical vocabulary is
           often garbled - "agent for script" means "Agent Script", "returns on
           the even" means "returns undefined", "a sink" means "async". Read every
           message charitably in a software-debugging context and quietly repair
           obvious mishears.

         | Keep replies short and easy to follow by ear: speak in full sentences,
           never read code or markdown aloud, and say symbols in words (for example
           "index plus plus" for "i++"). Guide with simple questions like "What did
           you expect to happen?" or "What did you change last?", and stay warm and
           playful.
```

### The Spoken-Style Bundle's Voice Configuration

These top-level blocks (after `system`, before `start_agent`) are what make it an actual voice agent:

```agentscript
language:
   default_locale: "en_US"

connection telephony:
   adaptive_response_allowed: True

modality voice:
   voice_id: "hpp4J3VqNfWAUOO0d1Us"
   outbound_speed: 1
   outbound_stability: 0.4
   outbound_similarity: 0.75
```

## Try It Out

Deploy the recipe, then open **Agentforce Studio** and start a conversation. Describe a bug and notice that the agent asks you a question rather than solving it.

### Example Interaction (Text bundle)

```text
Agent: Quack! I'm your rubber duck. Tell me about the bug you're chasing, and I'll help you think it through.

User: My function returns undefined even though I'm returning a value.

Agent: Quack! Let's dig in. What did you expect the function to return, and what are you seeing instead?

User: I expect the user object, but I get undefined.

Agent: Got it. Walk me through the line right before the return - is the value already set at that point, or is it being fetched asynchronously?

User: ...oh. It's a fetch. I'm returning before the promise resolves.

Agent: Quack quack! Sounds like you just found it. What would you change so the return waits for that promise?
```

### Example Interaction (Spoken-style bundle)

The conversation is the same idea, but each turn is short enough to listen to, asks a single question, and speaks any symbols out loud.

```text
Agent: Quack! Tell me about the bug you're chasing.

User: My loop skips the last item in the array.

Agent: What condition are you using to stop the loop?

User: I go while index is less than length minus one.

Agent: Quack - say that comparison out loud again. Should the last valid index really be length minus one, or just less than length?

User: ...ah. It should be less than length. Off by one.
```

## What's Next

- **HelloWorld**: The minimal agent this recipe is modeled on - start there for the bare structure
- **SystemInstructionOverrides**: Customize the persona per subagent for finer control
- **ReasoningInstructions**: Make the duck _stateful_ - branch its questions based on what it has already asked, using procedural `instructions:->` logic
- **VariableManagement**: Track debugging state (e.g., which questions have been asked) across turns

## Notes

> [!WARNING]
> **The spoken-style bundle needs a voice-provisioned org.** Its `connection telephony` block references a telephony connection that only exists in an org where **Agentforce Voice** is provisioned. Deploy it to such an org (for example, a voice-enabled demo org). A plain free Developer Edition org has the underlying voice permission-set licenses but does not surface the full **Agentforce Voice Setup** experience, so deploy the plain `RubberDuckDebugger` bundle there instead. The text bundle deploys and runs anywhere.

- **The `voice_id` is org/platform-specific.** The `modality voice` block's `voice_id` (here `hpp4J3VqNfWAUOO0d1Us`, the "Bella" voice) is a value Agent Builder writes when you pick a voice in **Voice Settings**. If you deploy to a different org and the voice isn't available, set it via Voice Settings and let the script round-trip, or replace the `voice_id` with one valid in your org.
- **Voice mode needs a supported default locale.** The `language` block pins `default_locale: "en_US"`. Voice mode only supports certain locales, so if the agent's default language isn't one of them, Agent Builder shows a "default language isn't supported in voice mode" warning and falls back to English (US). Pinning the locale in the script avoids the manual **Language Settings** change. (See the **LanguageSettings** recipe for multi-locale config.)
- **Don't confuse dictation with the voice connection.** The microphone/waveform icon in the Live Test input box is speech-to-text _dictation_ (it types for you) and appears for every agent, voice-enabled or not. The `connection telephony` + `modality voice` blocks are what actually make the agent _speak its replies aloud_.
- **Full telephony setup is out of scope here.** The script declares the connection, but standing up the underlying voice channel (browser **voice preview**, or full **telephony** via Amazon Connect / a partner provider with a Contact Center and phone number) is org configuration. See Salesforce's [Agentforce Voice / Service Cloud Voice setup documentation](https://help.salesforce.com/s/articleView?id=service.voice_agentforce.htm) for the current, org-specific steps.
- **Naming rules**: Agent and subagent names use letters, numbers, and underscores only, must start with a letter, and cannot end with or contain consecutive underscores.
- **Indentation**: Agent Script uses 3 spaces per level.
