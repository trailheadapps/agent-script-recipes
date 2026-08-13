# VoiceAgent

## Overview

This recipe demonstrates how to make an agent **voice-capable** directly in the script - both by writing its instructions for a spoken medium and by declaring the voice wiring (connection, synthesized voice, and language) in the `.agent` file itself. The agent is a Socratic "rubber duck" debugging buddy: instead of handing developers a fix, it helps them find the bug themselves by asking one question at a time, spoken aloud over a voice connection. The persona is expressed entirely through system and reasoning instructions - no variables, actions, or flows required - so the recipe stays focused on what changes when an agent _speaks_.

## Agent Flow

```mermaid
%%{init: {'theme':'neutral'}}%%
graph TD
    A[Agent Starts] --> B[Load Config Block]
    B --> C[Initialize System Block]
    C --> D[Apply Language + Voice Config]
    D --> E[Display Welcome Message]
    E --> F[start_agent: agent_router]
    F --> G[Transition to debugging Subagent]
    G --> H[Apply Socratic Reasoning Instructions]
    H --> I[Developer describes the bug]
    I --> J[Ask ONE focused question]
    J --> K{Bug found?}
    K -->|No| I
    K -->|Yes| L[Encourage and confirm]
    L --> M[End]
```

## Key Concepts

- **Persona-driven behavior**: Behavior comes from instructions alone - no actions or state
- **System vs. reasoning instructions**: The global persona lives in `system.instructions`; the turn-by-turn behavior lives in the subagent's `reasoning.instructions`
- **Behavioral constraints**: Instructing the agent to _withhold_ the answer and ask questions instead - a genuine instruction-design discipline
- **Channel adaptation**: How an agent's instructions change when replies are spoken aloud vs. read in a chat window
- **ASR-noise repair**: Instructing the agent to expect and reinterpret speech-to-text mistranscriptions of technical vocabulary
- **Voice configuration in script**: Declaring a `connection telephony` and `modality voice` block so the voice wiring and synthesized voice travel with the recipe
- **Language block for voice**: Pinning `default_locale` so voice mode has a supported language

## How It Works

### The Persona, in Two Places

The rubber-duck personality is established in two complementary spots.

First, globally, in the `system` block - this applies to every subagent:

```agentscript
system:
   instructions: "You are a friendly rubber-duck debugging buddy for software developers, speaking with them out loud over voice. You help them find bugs themselves by asking thoughtful, Socratic questions rather than handing over fixes."
```

Then, specifically, in the `debugging` subagent's reasoning instructions - this governs what the agent does on each turn. The interesting part is that the instructions tell the agent what **not** to do (don't hand over the fix), which is what makes it a rubber duck rather than a generic Q&A bot.

### The Behavioral Constraint

Most "useful" agents are told to _answer_. This one is deliberately told to _hold back_ and lead with questions - help the developer discover the bug on their own instead of handing over the fix. This is the whole lesson: **the value of the agent comes from the instructions, not from any code.**

### Making the Agent Speak

An agent that talks differs from a text agent on **two** levels: _how it speaks_ (instructions) and _that it speaks at all_ (voice configuration in the script).

**1. Instructions tuned for the ear.** Replies that are read aloud follow different rules than replies in a chat window:

| Concern         | Text                    | Spoken                               |
| --------------- | ----------------------- | ------------------------------------ |
| Response length | A few sentences is fine | Short - easy to follow by ear        |
| Formatting      | Prose is fine           | No code or markdown read aloud       |
| Symbols/IDs     | Can reference `i++`     | Say them in words: "index plus plus" |

The spoken instructions also add one thing a text agent never needs: **repairing speech-to-text noise.** When a developer talks, their words reach the agent as an imperfect transcription, and technical vocabulary is the first thing to get mangled - "Agent Script" becomes "agent for script", "returns undefined" becomes "returns on the even", "async" becomes "a sink". The agent reasons over that garbled _text_, not your audio, so the instructions tell it to expect the noise and quietly repair obvious mishears in a debugging context:

```agentscript
| Their words reach you as speech-to-text, so technical vocabulary is
  often garbled - "agent for script" means "Agent Script", "returns on
  the even" means "returns undefined", "a sink" means "async". Read every
  message charitably in a software-debugging context and quietly repair
  obvious mishears.
```

**2. Voice configuration in the script.** The recipe carries three blocks a text agent doesn't:

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
> Because this recipe declares a telephony connection, it must be deployed to a **voice-provisioned org** (one where that connection is available). See Notes.

## Key Code Snippets

### The Subagent's Reasoning

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

### The Voice Configuration

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

Deploy the recipe to a voice-provisioned org, then open **Agentforce Studio** and start a conversation. Describe a bug and notice that the agent asks you a question rather than solving it.

### Example Interaction

Each turn is short enough to listen to, asks a single question, and speaks any symbols out loud.

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
- **LanguageSettings**: Configure multiple locales for a multi-language voice or text agent
- **VariableManagement**: Track debugging state (e.g., which questions have been asked) across turns

## Notes

> [!WARNING]
> **This recipe needs a voice-provisioned org.** Its `connection telephony` block references a telephony connection that only exists in an org where **Agentforce Voice** is provisioned. Deploy it to such an org (for example, a voice-enabled demo org). A plain free Developer Edition org has the underlying voice permission-set licenses but does not surface the full **Agentforce Voice Setup** experience.

- **The `voice_id` is org/platform-specific.** The `modality voice` block's `voice_id` (here `hpp4J3VqNfWAUOO0d1Us`, the "Bella" voice) is a value Agent Builder writes when you pick a voice in **Voice Settings**. If you deploy to a different org and the voice isn't available, set it via Voice Settings and let the script round-trip, or replace the `voice_id` with one valid in your org.
- **Voice mode needs a supported default locale.** The `language` block pins `default_locale: "en_US"`. Voice mode only supports certain locales, so if the agent's default language isn't one of them, Agent Builder shows a "default language isn't supported in voice mode" warning and falls back to English (US). Pinning the locale in the script avoids the manual **Language Settings** change. (See the **LanguageSettings** recipe for multi-locale config.)
- **Don't confuse dictation with the voice connection.** The microphone/waveform icon in the Live Test input box is speech-to-text _dictation_ (it types for you) and appears for every agent, voice-enabled or not. The `connection telephony` + `modality voice` blocks are what actually make the agent _speak its replies aloud_.
- **Full telephony setup is out of scope here.** The script declares the connection, but standing up the underlying voice channel (browser **voice preview**, or full **telephony** via Amazon Connect / a partner provider with a Contact Center and phone number) is org configuration. See Salesforce's [Agentforce Voice / Service Cloud Voice setup documentation](https://help.salesforce.com/s/articleView?id=service.voice_agentforce.htm) for the current, org-specific steps.
- **Naming rules**: Agent and subagent names use letters, numbers, and underscores only, must start with a letter, and cannot end with or contain consecutive underscores.
- **Indentation**: Agent Script uses 3 spaces per level.
