# The Hero’s Story — Personality & Decision System Design

**Status:** Draft  
**Document version:** 0.1 skeleton

## Purpose

This document defines how the autonomous hero develops a recognizable personality and how that personality affects decisions without removing common sense or turning behaviour into random noise.

## This document covers

- personality dimensions and traits;
- initial personality inertia from the hero’s past;
- acquired personality changes;
- preferences and tendencies;
- decision weights;
- decision points;
- how experience changes future behaviour;
- how the hero evaluates alternatives;
- the relationship between personal preference, rational evaluation, and divine influence.

## This document does not cover

- quest content itself — see `Quest_and_Activity_System_Design_v0.1.md`;
- combat progression and combat traits that primarily affect battle math — see `Combat_and_Progression_System_Design_v0.1.md`;
- divine ability rules — see `God_Influence_System_Design_v0.1.md`;
- diary wording and storytelling — see `Narrative_and_Diary_System_Design_v0.1.md`.

## Personality Has Mechanical Meaning

The hero’s personality must not be merely a set of descriptive traits.

The hero’s decisions and experiences gradually change their tendencies, and those tendencies influence future decisions:

> **decisions → experience → personality and tendencies → new decisions**

Personality traits should bias the hero’s choices without dictating them completely. Even a strong trait should not make the hero ignore obvious danger or basic common sense.

The goal is for the hero’s behaviour to become recognizable and internally consistent over time without becoming fully predictable.

## Personality Traits Are Not Good or Bad

Personality traits describe the hero’s tendencies and should primarily shape behaviour rather than act as a list of bonuses and penalties.

The preferred model uses several opposing scales, for example:

- caution ↔ risk-taking;
- mercy ↔ cruelty;
- honesty ↔ cunning;
- altruism ↔ selfishness;
- curiosity ↔ conservatism.

Both ends of a scale should have advantages and drawbacks.

> **A personality trait should create a style of life, not simply provide a green bonus or a red penalty.**

The exact set of personality scales will be defined separately.

## Personality Changes Through Accumulated Experience

A single random action should not sharply rewrite the hero’s personality.

If the hero repeatedly acts in a certain direction, the corresponding tendency can gradually strengthen. If they consistently act against an existing tendency, personality can slowly shift in the opposite direction.

Strong or especially meaningful events may have a greater impact than ordinary experiences.

Personality should be stable enough for the hero to remain recognizable, but flexible enough for a long personal history to genuinely change them.

The exact experiences, events, and conditions that change personality will be defined separately.

## Personal Preferences

Personality and preferences are related, but they are not the same thing.

**Personality** describes how the hero tends to act: cautiously, boldly, honestly, selfishly, and so on.

**Preferences** describe what the hero likes or dislikes: types of activities, combat styles, equipment, places, factions, or individual characters.

Preferences should influence autonomous choices and may form or change through the hero’s background and lived experience.

A separate complex subsystem is not required at this stage. Preferences may use the same underlying decision-weight mechanisms as personality while remaining conceptually distinct.

## Discovery-Related Personality Traits

Two provisional personality traits are reserved for later development because they may affect how easily the hero notices hidden locations, unusual signs, and nearby opportunities while travelling:

- **Observant / Наблюдательный** — expected to improve the hero’s ability to notice hidden locations, unusual signs, or nearby opportunities;
- **Inattentive / Невнимательный** — expected to reduce that ability.

Their exact numerical effects, acquisition rules, interaction with other traits, and whether they form a strict opposing pair are **not yet defined**.

The map and discovery systems may use these traits as modifiers to their own base discovery chances, but the definition, ownership, and future development of the traits belong to the personality system.

> **The world defines what can be noticed; the hero’s personality may affect how likely they are to notice it.**

## General Decision-Making Model

The autonomous hero should make decisions logically enough that the player can understand the reasons behind their behaviour without reducing the hero to a single universal optimization formula.

For most recurring decisions, the current general structure is:

> **hard filtering → base evaluation → modifiers → highest final score**

First, the hero removes clearly unsuitable options. Each remaining option then receives its own base evaluation from objective factors relevant to that type of decision. Personality, preferences, current condition, world circumstances, divine influence, and other relevant factors may then modify that evaluation.

The hero chooses the option with the highest final evaluation.

> **The hero should make understandable decisions, while different traits, preferences, experiences, and circumstances make different heroes value the same options differently.**

The exact factors and formulas belong to the system that owns the relevant type of decision and may be refined through development and testing.

## Hard Filtering of Unsuitable Options

Before choosing, the hero excludes options that are objectively unavailable, impossible, or clearly unreasonable in the current situation.

It is important to distinguish between:

- **hard constraint** — the option is removed completely;
- **soft preference** — the option remains available, but its attractiveness changes.

Hard filtering should be used only where genuinely necessary. It should not remove options in advance when they may still make sense because of the hero’s personality, circumstances, or divine influence.

> **Filtering removes the impossible and clearly pointless. Everything else should remain space for the hero’s decision.**

## Base Evaluation of Options

After hard filtering, each remaining option receives its own base evaluation from objective factors appropriate to that type of decision.

That evaluation is then modified by the hero’s personality, preferences, circumstances, and divine influence.

The hero chooses the option with the highest final evaluation.

> **First, the option is evaluated for practical sense; then the hero’s individuality changes how attractive it becomes.**

The concrete factors and formulas may differ between types of decisions and are defined by the system responsible for that decision.

## Choice Modifiers

After the base evaluation, an option’s attractiveness may change under the influence of the specific hero and the current situation.

Relevant modifiers may include:

- the hero’s personality and preferences;
- combat traits and fears;
- faction attitude or reputation;
- personal attitude toward a specific character;
- world events;
- temporary opportunities;
- the hero’s current condition;
- divine influence;
- other genuinely meaningful circumstances.

For example, fear of the undead may reduce the attractiveness of a cemetery expedition, greed may increase the value of a profitable quest, good relations with someone may make their request more attractive, and a divine sign may strengthen the direction favored by the player.

> **Traits and circumstances change the evaluation of a decision, but they do not replace the hero’s decision-making process itself.**

## Final Choice

After all modifiers are applied, the hero compares the final evaluations of the available options and chooses the option with the **highest final score**.

The base decision model does not use a random roulette among otherwise valid options.

Behavioural variety should instead come from differences in:

- the hero’s personality and preferences;
- current condition and lived experience;
- world circumstances;
- available options;
- consequences of previous decisions;
- divine influence.

Therefore, a deterministic final choice does not mean that different heroes will behave identically.

> **The hero chooses what best matches the combination of current circumstances and their own individuality.**

The handling of exact ties between final scores may be defined later as a technical detail.

## Long-Term Hero Goals

In addition to immediate tasks, the hero may develop **long-term goals** that influence decisions over an extended period.

Such goals may emerge from:

- personality and preferences;
- lived events;
- relationships and conflicts;
- the hero’s own desires;
- the state of the world.

Possible examples include saving for a desired item, reaching a particular place, taking revenge, becoming stronger, or earning recognition.

The player may also establish **one active long-term direction for the hero**. This represents persistent divine guidance rather than a direct command. While it is active, related options become more attractive in the hero’s normal decision-making process, but the hero still decides how and when to pursue that direction according to their own personality, circumstances, and available opportunities.

The player-guided direction should remain active until it is completed or otherwise resolved rather than being freely replaced whenever a more convenient option appears. Once it is resolved, the player may choose another long-term direction.

This does not limit the hero to only one long-term goal. Other goals may emerge independently from the hero’s own life and coexist with the player-guided direction. The exact number of simultaneous hero-generated goals is not fixed yet.

A long-term goal is not an order. It makes related options more attractive and gradually gives direction to the hero’s life.

> **Immediate decisions determine what the hero does now. Long-term goals help define what they are striving toward. The player may guide one long thread of that journey without taking ownership of the hero’s choices.**

The exact creation, completion, conflict-resolution, and priority rules for long-term goals will be defined later.

## Reputation as a Decision Factor

Reputation affects **how attractive the hero considers options connected to a particular faction**.

For example:

- good relations may increase the attractiveness of a faction’s quest;
- the hero may be more willing to consider that faction’s city as a travel destination;
- poor relations may reduce the attractiveness of interaction;
- at extreme hostility, objectively unavailable options may be removed during hard filtering.

Reputation should **not determine the decision by itself** while an option remains available. The hero may also consider reward, risk, current goals, personality, current condition, personal attitudes toward specific characters, divine influence, and other relevant circumstances.

> **Reputation changes the evaluation of an option, but it does not replace the hero’s decision.**

## Migration note

Existing personality and autonomous-choice ideas will be reviewed individually before being moved here.
