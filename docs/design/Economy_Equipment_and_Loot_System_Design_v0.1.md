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

## Random Item Properties

Additional item stats and properties are partially generated randomly so that items of the same type can differ meaningfully from one another.

However, generation should not be completely unrestricted. Each item type has its own pool of allowed properties.

For example:

- heavy armor more often receives defensive stats;
- bows favor physical, speed, and shooting-related properties;
- magical weapons favor Intelligence, Mana, and magical effects;
- jewelry may use a broader pool of specialized bonuses.

Rare unusual combinations are allowed, but an item should not receive a nonsensical set of properties that completely contradicts its intended nature.

> **Randomness should create item variety, not meaningless chaos.**

## Item Power Depends on Its Source, Not the Hero’s Level

The power of dropped items should **not automatically scale to the hero’s current level**.

Loot quality and potential power depend primarily on its source, including:

- the strength and type of enemy;
- the difficulty of the activity;
- the region;
- the dungeon;
- the boss;
- the rarity of the event;
- other relevant world conditions.

Weak enemies from early areas should not begin dropping high-level equipment simply because the hero has become stronger.

As the hero develops, they should genuinely **outgrow old loot sources** and gain a reason to seek more dangerous places and more serious adventures.

> **To find stronger equipment, the hero must seek stronger sources of loot rather than wait for the old world to automatically scale to their level.**

## Legendary and Mythic Items

Items of the highest rarity should differ from ordinary equipment by **more than just larger stat numbers**.

Legendary and mythic items may have:

- a unique property;
- an unusual interaction with a class mechanic;
- a modification to an existing ability;
- their own active or passive ability;
- another rare rule that noticeably changes how the item is used.

Such an item should feel like a **significant discovery in the story of a particular hero**, rather than simply another piece of equipment with stats that are 15% higher.

The exact format of unique effects and the rules for generating them will be defined later.

> **The highest rarity should give an item individuality, not merely larger numbers.**

## Equipment Sets — Possible Late System

Equipment sets may be considered later as an additional layer of the item system.

Several related pieces may grant additional effects or unlock special properties when equipped together.

Sets are **not a required part of the base equipment system**. The game should first prove that individual item variety, generated upgrades, and unique items are interesting on their own.

> **Sets should be added only if they create genuinely new development choices rather than becoming another mandatory way to gain extra stats.**

The need for this system and its exact rules will be decided later and it may never be implemented.

## Migration note

This document describes the future full-game item loop. Its existence does not authorize premature implementation during Prototype 0.
