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

Jewelry uses three slots:

- two ring slots;
- one necklace slot.

The remaining two slots are:

- **Main Hand**;
- **Off Hand**.

These replace the earlier generic concept of two identical weapon slots.

A one-handed weapon occupies Main Hand. Depending on class and equipment rules, Off Hand may contain a shield, a second weapon, a magical focus, or another class-appropriate item.

A **two-handed weapon occupies both Main Hand and Off Hand simultaneously**. While a two-handed weapon is equipped, no separate Off Hand item can be used.

The current slot structure should remain compact. Additional slots such as a belt or earrings may be considered later if they provide a clear gameplay purpose, but they are not part of the current equipment structure.

## Base Stats by Equipment Group

Equipment is divided into several broad mechanical groups. Items within one group do not need completely different base-stat rules merely because they occupy different visual slots.

### Armor

Helmet, chest armor, gloves, pants, and boots share the same basic mechanical identity:

- their inherent base defensive stat is **Armor**.

Exact Armor values depend on item level and later balance rules. The current design does not require separate fundamental Armor formulas for each armor slot unless testing later shows that slot-specific weighting creates useful gameplay.

### Jewelry

Rings and necklaces use elemental resistance as their current base defensive identity.

A jewelry item may inherently provide one of:

- **Fire Resistance**;
- **Cold Resistance**;
- **Lightning Resistance**.

The exact selection rules, value ranges, and whether some jewelry types later receive different base properties remain tuning questions.

### Main-Hand Weapons

Weapons use two core base combat properties:

- **Damage**;
- **Attack Speed**.

These properties should be considered together rather than as unrelated bonuses. Different weapon families may trade higher per-hit Damage for lower Attack Speed, or lower per-hit Damage for higher Attack Speed.

The exact weapon families and their numerical profiles will be designed together with class combat mechanics.

### Off-Hand Items

Off Hand is a slot, not one universal item category.

Its mechanical identity depends on the item type and the class using it. Examples include:

- **Shield** — primarily associated with Block;
- second one-handed weapon — used when the class or specialization supports dual wielding;
- magical focus, tome, orb, or similar item — possible future caster-oriented Off Hand;
- other class-specific Off Hand types if they gain a clear mechanical purpose.

Only the shield’s association with **Block** is currently established. Exact rules for other Off Hand item types will be defined when the corresponding classes and specializations are designed.

## Weapon Access by Class and Specialization

Weapon access is tied to combat identity rather than being universally available to every hero.

The current principle is:

> **The base class defines which weapon families the hero can use. A later specialization primarily strengthens or favors particular weapon styles and may unlock additional options, but should not normally remove weapon families the hero already knew how to use.**

This allows a class to support meaningfully different equipment styles without turning most weapon drops into unusable items after specialization.

For example, a Warrior may eventually support several broad styles such as:

- one-handed weapon + shield;
- two-handed weapon;
- dual wielding, if that style is approved for an appropriate specialization.

These are examples of the structural rule, not a finalized Warrior weapon list.

Exact allowed weapon families, specialization bonuses, dual-wield rules, and caster/ranged Off Hand behaviour will be defined together with the detailed class designs.

## Item Level and Rarity

Each item has two main characteristics that describe its quality:

- **item level / base power** — determines the item’s general stat potential and which modifier value ranges may be available;
- **rarity** — determines the fixed number of prefixes and suffixes generated on the item.

The current rarity structure is:

| Rarity | Color | Prefixes | Suffixes |
| --- | --- | ---: | ---: |
| Normal | White | 0 | 0 |
| Uncommon | Green | 1 | 1 |
| Rare | Blue | 2 | 2 |
| Epic | Purple | 3 | 3 |

Modifier slots are never empty. If an item has a given rarity, it always receives the complete number of prefixes and suffixes defined for that rarity.

> **Item level defines the foundation of an item’s strength, while rarity defines how many additional modifiers are added to that foundation.**

## Item Power Budget

Each item has a limited **stat budget** determined primarily by its level and rarity.

This budget is distributed among the item’s stats.

Two items of the same level and rarity may therefore have roughly comparable total power while distributing that power in very different ways.

For example, one chest piece may provide more defense, while another provides less defense but adds other useful stats.

> **Items of the same power tier do not have to be identical — their value may come from how that power is distributed.**

The exact formulas and relative cost of individual stats will be defined later.

## Prefixes, Suffixes, and Random Generation

Generated equipment follows the general structure:

> **base item → item level → rarity → prefixes and suffixes → rolled modifier values**

The base item defines the item type, equipment slot, and its inherent base characteristics.

After rarity is determined, the item receives the exact number of prefixes and suffixes required by that rarity. Prefixes and suffixes are selected from modifier pools available to that specific type of item.

The random part of item generation comes from:

- which eligible prefixes are selected;
- which eligible suffixes are selected;
- the numerical value rolled for each selected modifier within its allowed range.

Generation should not be completely unrestricted. Each item type has its own pool of allowed properties so that items remain coherent with their function.

For example:

- heavy armor more often receives defensive stats;
- bows favor physical, speed, and shooting-related properties;
- magical weapons favor Intelligence, Mana, and magical effects;
- jewelry may use a broader pool of specialized bonuses.

Rare unusual combinations are allowed, but an item should not receive a nonsensical set of properties that completely contradicts its intended nature.

The current primary and secondary combat stats are defined in `Combat_and_Progression_System_Design_v0.1.md`. The exact modifier pools, which stats may appear on which item types, modifier tiers, and numerical roll ranges are not defined yet.

> **Randomness should create item variety, not meaningless chaos.**

## Equipment Does Not Modify Personality

Equipment may affect the hero’s combat capabilities, resources, stats, and other gameplay properties directly connected to what the item physically or mechanically provides.

Equipment does **not** modify the hero’s personality, morality, character traits, preferences, or decision-making tendencies merely because the item is equipped.

The hero’s personality develops through their background, lived experience, decisions, and meaningful events rather than through ordinary equipment bonuses.

> **Equipment can change what the hero is capable of, but it does not rewrite who the hero is.**

## Elemental Resistances

The current elemental resistance set contains three defensive stats:

- **Fire Resistance**;
- **Cold Resistance**;
- **Lightning Resistance**.

Each resistance reduces only damage of its matching elemental type.

Elemental resistance uses the same diminishing-return formula as Armor:

`Final Damage = Raw Damage × 100 / (100 + Resistance)`

Examples:

- 100 Resistance reduces matching elemental damage by 50%;
- 300 Resistance would mathematically reduce damage by 75%.

Damage reduction from any single elemental resistance is capped at **75%**. Additional resistance above the value required to reach the cap does not reduce incoming damage further.

Elemental resistance values cannot be negative.

Resistances are valid defensive item stats and may appear on equipment through appropriate prefixes, suffixes, base properties, or other item rules defined later.

At the current design stage there is no resistance penetration, resistance reduction below zero, or other advanced resistance interaction.

> **Elemental resistances use the same defensive logic as Armor: more resistance provides diminishing returns, with a hard maximum of 75% damage reduction.**

## Accuracy and Dodge on Equipment

**Accuracy** and **Dodge** are valid combat stats that may appear on equipment through appropriate modifiers or base properties.

Their exact combat interaction is owned by `Combat_and_Progression_System_Design_v0.1.md`. In the current model, Accuracy counters Dodge rather than increasing hit chance above 100%, and both stats use the same shared hit-resolution formula for the hero and enemies.

The item system should therefore evaluate Accuracy primarily as a way to improve performance against targets that possess Dodge, while Dodge provides a defensive chance to avoid eligible attacks.

The exact item-type pools, modifier tiers, and numerical ranges for Accuracy and Dodge will be defined together with the broader modifier system.

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

## Equipment Sets — Possible Late System

Equipment sets may be considered later as an additional layer of the item system.

Several related pieces may grant additional effects or unlock special properties when equipped together.

Sets are **not a required part of the base equipment system**. The game should first prove that individual item variety, generated upgrades, and unique items are interesting on their own.

> **Sets should be added only if they create genuinely new development choices rather than becoming another mandatory way to gain extra stats.**

The need for this system and its exact rules will be decided later and it may never be implemented.

## Item Visual Direction

The primary visual reference for equipment in **The Hero’s Story** is **Shop Heroes**.

This applies primarily to armor, while also informing weapons, helmets, accessories, and other wearable items.

The reference contributes:

- large, readable silhouettes;
- a stylized fantasy direction;
- moderately cartoon-like forms;
- clean and expressive rendering;
- clearly distinguishable materials;
- a strong sense of volume without excessive small-detail clutter;
- good readability at reduced display sizes;
- a sense of value and visible progression between items of different quality tiers.

**Shop Heroes is a reference for items specifically**, not automatically for:

- the hero;
- the world;
- the map;
- the interface;
- environments;
- the game’s overall visual tone.

> **Item art should feel coherent and recognizable without dictating the visual identity of the entire game.**

## Migration note

This document describes the future full-game item loop. Its existence does not authorize premature implementation during Prototype 0.
