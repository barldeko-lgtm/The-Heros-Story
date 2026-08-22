# The Hero’s Story — God Influence System Design

**Status:** Draft  
**Document version:** 0.1

## Purpose

This document defines the player’s role as deity/patron and the rules for influencing an autonomous hero without converting indirect control into ordinary RPG commands.

## This document covers

- divine energy;
- soft influence and guidance;
- decision-point interaction;
- direct divine abilities;
- healing, resurrection, blessings, and comparable interventions;
- costs, cooldowns, limits, and opportunity cost;
- how divine influence interacts with the hero’s own preferences and rational choices;
- possible future progression of the deity when that becomes relevant.

## This document does not cover

- the hero’s normal autonomous decision model — see `Personality_and_Decision_System_Design_v0.1.md`;
- combat formulas affected by buffs — see `Combat_and_Progression_System_Design_v0.1.md`;
- quest generation — see `Quest_and_Activity_System_Design_v0.1.md`;
- world simulation rules — see `World_Simulation_System_Design_v0.1.md`.

## Core Boundary

The player guides and occasionally intervenes. The player must not become the hero’s hidden direct controller.

## Role of Divine Influence

Divine influence is an additional layer on top of the hero’s autonomous life.

The hero’s life, development, decisions, and fate should remain interesting on their own even if the player intervenes very little for a while.

Deity mechanics may:

- guide the hero;
- help in particular situations;
- accelerate or ease some processes;
- allow the player to influence especially important moments.

They should not become the hero’s main source of power and development or turn the player into a hidden commander.

> **The hero should first be interesting on their own. The deity helps influence the hero’s story rather than living that story in their place.**

## Soft Divine Influence

The player may softly nudge the hero toward certain decisions without issuing direct orders.

Such influence may apply, for example, to:

- choosing a travel direction;
- choosing a quest;
- attitudes toward risk;
- interest in a particular character or faction;
- other important hero decisions.

A divine sign adds **additional weight** to the chosen option, but does not guarantee that the hero will follow it.

The hero continues to consider their own personality, preferences, circumstances, and common sense, and may sometimes ignore the player’s wish.

Internally, the influence may be calculated numerically, but the player should perceive it as a **sign, suggestion, or direction**, not as an abstract “+20% to choice” button.

> **The deity may incline the hero toward a decision, but the decision still belongs to the hero.**

## Influence Acts at the Appropriate Decision Point

Soft divine influence should not interrupt an action the hero is already performing.

If the player guides the hero toward a particular choice, that influence remains pending until the next relevant decision point — for example, choosing a quest, city, or future direction.

At that moment, the hero considers divine influence together with personality, preferences, and current circumstances. The hero may follow the sign, but is not required to do so.

Influence applied directly during the relevant choice may be slightly stronger. This rewards active observation without making constant player presence necessary.

## Direct Divine Intervention

In addition to soft influence, the player has access to rarer forms of direct intervention.

These abilities consume a limited divine resource that regenerates slowly enough that direct assistance cannot be used in every ordinary fight.

At the base stage, the main forms of intervention are expected to be:

- **healing the hero**;
- **a temporary combat blessing or empowerment**.

Later deity progression may unlock additional forms of direct intervention.

The hero should overcome ordinary difficulties independently. Divine power becomes especially valuable when a situation is genuinely important or dangerous.

> **Direct intervention helps the hero in an exceptional moment, but does not replace the hero’s own strength during ordinary play.**

The exact abilities, their costs, and their limitations will be defined separately.

## Deity Power Progression — Confirmed but Later Layer

Progression of the deity’s capabilities is part of the overall game concept, but the concrete progression system should not be fixed yet.

The hero’s own development must be established and balanced first, including:

- growth of real combat power;
- levels and attributes;
- abilities;
- equipment;
- the structure of threats;
- the overall progression pace.

Only after that should deity progression be designed on top of an understood hero system, so divine abilities do not break balance or compete with the hero for the role of the primary progression source.

The current overall direction is:

- deity power and capabilities develop **more slowly than the hero**;
- stronger or more varied forms of influence gradually become available;
- later, divine influence may extend beyond simple healing and temporary empowerment.

The exact progression structure, resources, branches, and growth pace will be defined separately later.

> **The hero develops first. Deity progression should be built on top of the hero’s progression rather than overshadowing it.**

## Passive Regeneration of Divine Power

The main resource used for direct divine intervention **regenerates passively while the game is running and the simulation continues**.

This supports the intended rhythm:

> the hero lives independently for a while → the player returns to observe → some opportunity to intervene is available again.

Divine power should give the player occasional opportunities to affect an important moment, but it should not become the main reason to return to the game.

The main reason to check on the hero should remain:

> **interest in what happened to the hero and who they are gradually becoming.**

Later, regeneration speed or maximum capacity may be influenced by deity progression, deity traits, the deity’s or hero’s renown in the world, reputation, or other suitable systems.

Such additional regeneration modifiers are not required for an early version and may be designed later.

## Deity Personality — Optional Later Layer

A separate initial choice such as:

> “good deity / evil deity”

is not required at the start of the game.

If a deity-personality system later proves useful, the deity’s direction should gradually emerge from the player’s own actions.

Possible influences may include:

- mercy;
- cruelty;
- inclination toward war;
- protection and patronage;
- other directions to be defined later.

In that case, deity personality should reflect **how the player tends to act** rather than an alignment label chosen in advance.

This system is not required for the base game and may be designed later or never implemented.

## Hero–Deity Relationship — Optional Later Layer

A separate mechanic for the hero’s relationship with their deity is **not required for the base game**.

If such a system later proves useful, the hero may gradually form their own attitude toward their patron. The hero may:

- trust the deity;
- doubt divine signs;
- resist divine influence;
- become more or less religious.

High trust may potentially increase the weight of divine guidance, while low trust may reduce it.

Even a deeply devoted hero must not become a fully controllable unit.

> **Trust may strengthen divine influence, but it must not cancel the hero’s autonomy.**

The need for this system and its exact mechanics will be decided later. It may never be implemented.

## Instant Resurrection by the Deity

The player may choose not to wait for the hero’s natural return and instead **resurrect the hero immediately by spending divine energy**.

The cost should depend on the time remaining before natural resurrection:

- intervention is more expensive soon after death;
- the cost decreases as natural resurrection approaches;
- a small minimum cost may remain.

Exact values are not fixed yet.

Instant resurrection uses the same limited resource as other divine abilities, so the player must decide whether bringing the hero back immediately is worth giving up energy that could be used for another intervention.

> **The deity may reduce the time cost of defeat, but doing so should consume part of its limited power.**

## Migration Note

Prototype 0 divine-ability values are test values unless explicitly promoted into long-term design.
