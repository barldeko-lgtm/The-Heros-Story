# The Hero’s Story — Economy, Equipment & Loot System Design

**Status:** Draft  
**Document version:** 0.1 skeleton

## Purpose

This document defines the complete item-value loop: how items enter the hero’s life, where they are stored, how the hero evaluates and equips them, and how money and markets support progression.

## This document covers

- loot sources and loot generation;
- QuestLoot;
- permanent inventory;
- equipment slots;
- item stats and item identity;
- hero evaluation of upgrades;
- equipping and replacing items;
- selling and buying;
- gold and basic economy;
- shops and market behaviour at the appropriate level of abstraction;
- the pipeline from equipment to resolved hero stats.

## Intended system chain

`loot → QuestLoot → Inventory → Equipment → StatResolver → CombatStats → Combat / Power`

## This document does not cover

- combat formulas themselves — see `Combat_and_Progression_System_Design_v0.1.md`;
- personality algorithms used to prefer particular item styles — see `Personality_and_Decision_System_Design_v0.1.md`;
- world-level economic simulation unless it materially affects hero gameplay — see `World_Simulation_System_Design_v0.1.md`.

## Migration note

This document describes the future full-game item loop. Its existence does not authorize premature implementation during Prototype 0.
