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

## Role of Equipment in Hero Progression

Equipment is one of the hero’s main sources of permanent power.

Early in the game, level and basic attributes may provide most of the hero’s growth. As the hero approaches the soft cap, their relative importance gradually decreases and finding and replacing equipment becomes an increasingly important way to continue developing.

> **The more established the hero becomes, the more their further strength depends on what they have managed to obtain and what they carry.**

## Basic Equipment Slots

At the current design stage, the hero has **10 equipment slots**.

Armor uses five slots:

- helmet;
- chest armor, with shoulders included as part of the same item rather than a separate equipment slot;
- gloves;
- pants;
- boots.

Additional equipment slots are:

- two ring slots;
- one necklace slot;
- two weapon slots.

The current slot structure should remain compact. Additional slots such as a belt or earrings may be considered later if they provide a clear gameplay purpose, but they are not part of the current equipment structure.

## Item Level and Rarity

Each item has two main characteristics that describe its quality:

- **item level / base power** — determines the item’s general stat potential;
- **rarity** — determines how rich and unusual the item may become.

Higher rarity may provide:

- a larger total stat budget;
- more additional properties;
- stronger rolls for those properties;
- access to rarer or more unusual effects.

The exact rarity names, colors, and numerical bonuses are not fixed yet.

> **Item level defines the foundation of an item’s strength, while rarity defines how far that item may go beyond an ordinary piece of equipment.**

## Item Power Budget

Each item has a limited **stat budget** determined primarily by its level and rarity.

This budget is distributed among the item’s stats.

Two items of the same level and rarity may therefore have roughly comparable total power while distributing that power in very different ways.

For example, one chest piece may provide more defense, while another provides less defense but adds other useful stats.

> **Items of the same power tier do not have to be identical — their value may come from how that power is distributed.**

The exact formulas and relative cost of individual stats will be defined later.

## Migration note

This document describes the future full-game item loop. Its existence does not authorize premature implementation during Prototype 0.
