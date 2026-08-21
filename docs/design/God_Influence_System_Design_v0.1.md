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

## Migration Note

Prototype 0 divine-ability values are test values unless explicitly promoted into long-term design.
