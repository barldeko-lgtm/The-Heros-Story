# The Hero’s Story — Personality & Decision System Design

**Status:** Draft  
**Document version:** 0.1 skeleton

## Purpose

This document defines how the autonomous hero develops a recognizable personality and how that personality affects decisions without removing common sense, creating self-reinforcing trait loops, or turning behaviour into random noise.

## This document covers

- personality dimensions and traits;
- gradual personality formation and change;
- personality-forming decisions;
- personality-expressive decisions;
- preferences and tendencies;
- decision weights;
- decision points;
- how primary attributes, circumstances, experience, and personality affect different kinds of choices;
- how the hero evaluates alternatives;
- the relationship between personal preference, rational evaluation, and divine influence.

## This document does not cover

- quest content itself — see `Quest_and_Activity_System_Design_v0.1.md`;
- combat progression and combat traits that primarily affect battle math — see `Combat_and_Progression_System_Design_v0.1.md`;
- exact player control over primary-attribute growth — see `Combat_and_Progression_System_Design_v0.1.md`;
- divine ability rules — see `God_Influence_System_Design_v0.1.md`;
- diary wording and storytelling — see `Narrative_and_Diary_System_Design_v0.1.md`.

## Personality Has Mechanical Meaning

The hero’s personality must not be merely a set of descriptive traits.

Personality has two distinct roles:

1. it is **formed and changed** by selected meaningful choices that do not use the same personality traits to decide the choice;
2. once formed, it **changes how the hero evaluates later personality-expressive choices**.

The core separation is:

> **attributes and circumstances → personality-forming choices → personality development → personality-expressive choices**

These two kinds of decisions may appear in different events or in different stages of the same authored event, but they must not be confused with each other.

This separation exists to prevent a self-reinforcing loop such as:

> `Brave → choose the Brave option → gain more Brave → choose Brave even more often`

Personality traits should make the hero’s behaviour recognizable without becoming the only source of that behaviour and without automatically strengthening themselves every time they are expressed.

## Personality Traits Are Not Good or Bad

Personality traits describe the hero’s tendencies and should primarily shape behaviour rather than act as a list of bonuses and penalties.

The current core personality model uses five opposing trait scales:

- **Brave / Храбрый ↔ Cautious / Осторожный**;
- **Noble / Благородный ↔ Devious / Коварный**;
- **Observant / Наблюдательный ↔ Inattentive / Невнимательный**;
- **Greedy / Жадный ↔ Generous / Щедрый**;
- **Curious / Любопытный ↔ Conservative / Консервативный**.

These five pairs are the current agreed core personality set for the broader game design. A particular prototype may implement only a subset initially, but the general personality model should not be reduced merely because one prototype does not yet use every axis.

The exact gameplay modifiers, thresholds, bonuses, penalties, and numerical effects are intentionally **not defined yet**.

Both ends of a scale should be treated as valid personality directions rather than automatically good or bad outcomes.

> **A personality trait should create a style of life, not simply provide a green bonus or a red penalty.**

## Two Types of Personality-Related Decisions

A decision point that interacts with general personality must be treated as one of two conceptual types:

1. **Personality-forming choice** — the decision may change personality, but current personality does not decide that choice;
2. **Personality-expressive choice** — current personality may influence the decision, but that decision does not award personality movement merely for expressing the same trait.

An authored event may contain both types at different stages. The separation belongs to the individual decision stage, not necessarily to the whole event.

This is a core rule of the personality system.

## Personality-Forming Choices

A personality-forming choice is a meaningful situation in which the hero’s action may contribute to who they become.

For this kind of choice, the personality axis that may be changed by the result is **not used as a modifier to select the option**.

Instead, the choice is based on factors independent of that personality axis, especially:

- relevant primary attributes;
- hard requirements and feasibility;
- the hero’s current condition and resources where appropriate;
- concrete circumstances of the event;
- event-specific objective factors.

Primary attributes are particularly important because they give the hero an independent mechanical basis for choosing one way to solve a situation over another. A strong hero may find a physical solution more viable, a dexterous hero may prefer a precise or evasive solution, an intelligent hero may recognize a technical solution, and a wise hero may find another practical approach when the authored event supports those options.

This does **not** mean that an attribute is equivalent to a personality trait. High Strength does not mean Brave. High Dexterity does not mean Cautious. The attribute affects how suitable or effective an action is; the authored meaning of the chosen action determines whether that action contributes to personality.

If two available formative options receive exactly equal final evaluation and no other deterministic event rule breaks the tie, the choice may use the shared seeded RNG as a deterministic tie-break. Randomness should resolve genuine uncertainty rather than replace the normal decision model.

### Formative Choice Creates Personality Movement

After the hero makes a personality-forming choice, the **meaning of the chosen action** may move one or more hidden personality axes.

For example, an authored action may be tagged conceptually as:

- `+Brave`;
- `+Cautious`;
- `+Noble`;
- `+Devious`;
- `+Greedy`;
- `+Generous`;
- or another appropriate personality direction.

The exact magnitude belongs to the authored content and balance rules.

The important point is that the personality movement comes from **what the hero chose to do**, not from whether the world later rewarded or punished that action.

A hero who chooses to confront a dangerous opponent made a brave choice even if the fight later goes badly. A hero who chooses a careful route made a cautious choice even if that route later contains an unexpected danger.

> **The decision forms personality; success or failure does not retroactively redefine what kind of decision it was.**

### Outcomes Do Not Directly Rewrite General Personality

The outcome of a decision may still matter greatly to the hero’s future, but ordinary success or failure should not automatically move the broad personality axes.

Consequences may instead affect systems such as:

- combat-specific fear or confidence;
- preferences;
- relationships;
- reputation;
- knowledge;
- resources;
- goals;
- diary history;
- other event-specific persistent state.

This keeps general personality from becoming an indirect product of whichever lucky or unlucky sequence of events happened to occur.

A later design may introduce rare exceptional life-changing outcomes that explicitly alter general personality, but such cases should be treated as authored exceptions rather than the default personality-development rule.

## Personality-Expressive Choices

A personality-expressive choice exists to let the already developed hero behave differently because of who they have become.

For this kind of decision, current personality may modify the attractiveness of available options.

Examples include:

- Brave increasing interest in a risky but viable response;
- Cautious increasing interest in a safer response;
- Greedy increasing the attractiveness of personal material gain;
- Generous increasing the attractiveness of sacrificing personal value for someone else;
- Curious increasing interest in investigating something unknown;
- Conservative increasing preference for a known and proven option.

However, a personality-expressive choice does **not** give personality points merely because the hero acted according to the trait that already influenced the choice.

Therefore:

> **personality may cause a choice, or a choice may form personality, but the same decision stage should not do both for the same personality axis.**

This rule prevents personality from automatically escalating toward an extreme merely because it already exists.

## Personality Can Change Over Time

Personality is not required to remain fixed for the entire game.

Even an established trait may weaken or eventually move toward its opposite because later **personality-forming choices** continue to occur throughout the hero’s life.

Those later formative choices remain independent of the current value of the personality axis they may change. The hero may therefore repeatedly make choices that do not match an existing visible trait because their attributes, condition, available methods, and the concrete circumstances of those formative situations lead elsewhere.

A single opposite choice should not normally rewrite an established personality. Long-term change should emerge from accumulated formative choices.

This allows a hero’s character to evolve while avoiding both extremes:

- personality is not fixed permanently at character creation;
- personality is not randomly rewritten by whatever event outcome happens next.

## Hidden Personality Values and Visible Trait Thresholds

The opposing personality dimensions are treated as underlying continuous values that may move gradually as formative choices accumulate.

The visible personality trait does **not** have to change every time the hidden value moves. Instead, visible states are defined by thresholds on the underlying scale.

Conceptually:

> **personality-forming choice → hidden personality movement → threshold crossing → visible trait change**

This allows the hero to accumulate small changes without appearing to become a different person every few minutes.

The first meaningful movement away from a broadly neutral state may establish a recognizable trait comparatively quickly so that young heroes can begin differentiating during the early game. After a trait has become established, strengthening it further, losing it, or crossing into the opposite trait should require substantially more accumulated contrary formative choices.

Appearance and disappearance thresholds should not be identical. A trait that has just crossed its appearance threshold should not vanish again after one small opposite movement. This hysteresis keeps visible personality stable even while the hidden scale continues to move in both directions.

Exact numerical ranges, thresholds, rates of change, and whether visible traits have named strength tiers remain balance questions.

## Starting Personality

The general personality system does not require the hero to begin with a fully formed set of visible traits.

A new hero may begin broadly neutral on some or all personality axes and develop recognizable traits through early personality-forming choices.

Biography, background, class selection, or other creation systems may still influence the hero’s starting situation, available attributes, preferences, knowledge, or other state. Whether they should also provide direct starting personality movement is a separate character-creation decision and should not be assumed by this document.

The important rule is that the personality system must be able to produce a distinct hero through actual play rather than requiring personality to be completely predetermined before the first event occurs.

## Personality Traits and Combat Traits Remain Separate

The personality model above does not replace combat traits.

Combat traits such as fear or confidence toward a specific enemy category may still emerge from repeated or especially significant combat experience even when no explicit personality-forming choice occurred. Their detailed acquisition, strengthening, weakening, and disappearance rules belong to `Combat_and_Progression_System_Design_v0.1.md`.

> **General personality is shaped by meaningful formative choices; specific experience may separately teach the hero what to fear, trust, prefer, or avoid.**

## Personal Preferences

Personality and preferences are related, but they are not the same thing.

**Personality** describes how the hero tends to act: cautiously, boldly, nobly, greedily, curiously, and so on.

**Preferences** describe what the hero likes or dislikes: types of activities, combat styles, equipment, places, factions, or individual characters.

Preferences should influence autonomous choices and may form or change through the hero’s background and lived experience.

A separate complex subsystem is not required at this stage. Preferences may use the same underlying decision-weight mechanisms as personality while remaining conceptually distinct.

## Observant and Inattentive

**Observant / Наблюдательный ↔ Inattentive / Невнимательный** remains one of the five core personality scales in the broader game design.

This scale is expected to be especially relevant to how easily the hero notices hidden locations, unusual signs, and nearby opportunities while travelling, but its exact mechanical effects are not yet defined.

The map and discovery systems may later use this personality scale as a modifier to their own base discovery chances, while the definition, ownership, and future development of the trait remain part of the personality system.

A prototype may postpone implementation of this axis if its current content does not yet provide enough meaningful perception-related decisions. That implementation choice does not remove the axis from the broader design.

> **The world defines what can be noticed; the hero’s personality may affect how likely they are to notice it.**

## General Decision-Making Model

The autonomous hero should make decisions logically enough that the player can understand the reasons behind their behaviour without requiring a complex general-purpose AI and without reducing every activity to one universal optimization formula.

The owning system or authored event defines the factors relevant to its decision.

For many recurring decisions, the general structure remains:

> **hard filtering → base evaluation → allowed modifiers → highest final score**

The important addition is that **the allowed modifiers depend on the type of decision**.

For a personality-forming decision, the personality axis being formed is excluded from the choice calculation.

For a personality-expressive decision, relevant existing personality traits may be used as modifiers, but that decision does not then award movement to the same trait merely for being expressed.

The exact factors and formulas belong to the system that owns the relevant type of decision and may be refined through development and testing.

## Hard Filtering of Unsuitable Options

Before choosing, the hero excludes options that are objectively unavailable, impossible, or clearly unreasonable in the current situation.

It is important to distinguish between:

- **hard constraint** — the option is removed completely;
- **soft preference** — the option remains available, but its attractiveness changes.

Hard filtering should be used only where genuinely necessary. It should not remove options in advance when they may still make sense because of the hero’s attributes, personality when allowed, circumstances, or divine influence.

> **Filtering removes the impossible and clearly pointless. Everything else should remain space for the hero’s decision.**

## Base Evaluation of Options

After hard filtering, each remaining option receives its own base evaluation from objective factors appropriate to that type of decision.

Depending on the decision, relevant factors may include:

- primary attributes;
- current Health or other resources;
- distance or time cost;
- danger;
- expected reward;
- known information;
- current goals;
- event-specific conditions.

A personality-forming decision may use these factors without allowing the personality axis being formed to influence the result.

A personality-expressive decision may then additionally apply relevant personality and preference modifiers.

The concrete factors and formulas may differ between types of decisions and are defined by the system responsible for that decision.

## Choice Modifiers

After the base evaluation, an option’s attractiveness may change under the influence of the specific hero and the current situation when that modifier is valid for that decision type.

Relevant modifiers may include:

- personality traits in personality-expressive decisions;
- preferences;
- combat traits and fears;
- faction attitude or reputation;
- personal attitude toward a specific character;
- world events;
- temporary opportunities;
- the hero’s current condition;
- divine influence;
- other genuinely meaningful circumstances.

For example, fear of the undead may reduce the attractiveness of a cemetery expedition, greed may increase the value of a profitable personality-expressive choice, good relations with someone may make their request more attractive, and a divine sign may strengthen the direction favored by the player.

> **Modifiers change the evaluation of a decision, but every modifier must respect the ownership rules of that decision.**

## Final Choice

After all allowed modifiers are applied, the hero compares the final evaluations of the available options and chooses the option with the **highest final score**.

The base decision model does not use a random roulette among otherwise valid options.

If two options are exactly tied and no authored deterministic priority resolves the tie, the shared seeded RNG may be used as a reproducible tie-break.

Behavioural variety should primarily come from differences in:

- primary attributes and development;
- personality and preferences where that decision allows them;
- current condition and lived experience;
- world circumstances;
- available options;
- consequences of previous decisions;
- divine influence.

Therefore, a deterministic final choice does not mean that different heroes will behave identically.

> **The hero does not need a complex AI to become distinct: different development and different circumstances can create different choices, and selected formative choices can gradually create different personalities.**

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

Reputation should **not determine the decision by itself** while an option remains available. The hero may also consider reward, risk, current goals, personality when relevant, current condition, personal attitudes toward specific characters, divine influence, and other relevant circumstances.

> **Reputation changes the evaluation of an option, but it does not replace the hero’s decision.**

## Migration note

Existing personality and autonomous-choice ideas will be reviewed individually before being moved here.
