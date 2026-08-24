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

Each item has two main characteristics that describe its mechanical quality:

- **item level / ilvl** — determines the strength of the item’s inherent base stats and establishes the power scale used for its modifier budget;
- **rarity** — determines the fixed number of random modifiers and, together with item level, the range of the item’s total modifier budget.

For items of the same base type and item level, rarity does **not** automatically increase the inherent base stat merely because the item is a different color. The extra power of higher rarity comes primarily from additional modifiers and the larger budget available to those modifiers.

The item system does **not** use a mechanical prefix/suffix split. Random properties are simply **modifiers** selected from the valid modifier pool for that item type.

The current rarity structure is:

| Rarity | Color | Random modifiers |
| --- | --- | ---: |
| Normal | White | 0 |
| Uncommon | Green | 1 |
| Rare | Blue | 2 |
| Epic | Purple | 3 |
| Legendary | Orange | 4 |

Modifier slots are never empty. If an item has a given rarity, it always receives the complete number of random modifiers defined for that rarity.

> **Item level determines the strength scale of the item. Rarity determines how many modifiers it receives and how much total modifier power can be distributed among them.**

## Modifier Power Budget

The item’s inherent base stats are determined separately from its modifier budget.

A **Normal / White** item has no random modifiers and therefore has:

> **Modifier Budget = 0**

It consists only of the base properties appropriate to its item type and item level.

For Uncommon, Rare, Epic, and Legendary items, **item level and rarity together define a range for the total Modifier Budget**. The final total budget is rolled somewhere inside that range.

The current provisional rarity multipliers for the modifier-budget scale are:

| Rarity | Working budget multiplier |
| --- | ---: |
| Uncommon | ×1.0 |
| Rare | ×1.5 |
| Epic | ×2.0 |
| Legendary | ×2.5 |

These multipliers are provisional balance values. Their purpose is to establish the relative strength of rarities before exact item-level ranges are known.

The current working progression target is:

> **A Legendary item from the current item tier should have approximately the same total modifier budget as a Rare item from the next item tier.**

To produce that relationship with the working rarity multipliers, the base modifier-budget scale between adjacent item tiers grows by approximately **×1.67**:

`2.5 / 1.5 ≈ 1.67`

This is a design target, not a requirement that the final game expose discrete ten-level tiers or use exactly this multiplier after balance testing.

Purely illustrative control points for the current working scale are:

| Example ilvl | Uncommon | Rare | Epic | Legendary |
| ---: | ---: | ---: | ---: | ---: |
| 10 | 54–66 | 81–99 | 108–132 | 135–165 |
| 20 | 90–110 | 135–165 | 180–220 | 225–275 |
| 30 | 150–184 | 225–276 | 300–367 | 375–459 |

These numbers are **not final balance values** and do not yet define the final item-level range of the game. They exist only to anchor the intended growth relationship: modifier budget rises with ilvl, higher rarity raises the available budget, and a sufficiently higher-ilvl lower-rarity item can overtake an older high-rarity item.

The rolled total budget is then distributed among all mandatory modifiers on the item. It does not have to be divided equally.

For example, a Rare item with two modifiers may devote more of its budget to one modifier and less to the other. However, distribution must remain bounded so that generation cannot spend almost the entire budget on one modifier while leaving the remaining mandatory modifiers nearly worthless.

The exact minimum and maximum share an individual modifier may receive relative to the average share are tuning parameters and will be defined through testing.

> **Rarity creates both more modifiers and a larger total modifier budget, while controlled random distribution creates meaningful variation between items of the same level and rarity.**

### Modifier Stat Scope

Standard randomly generated item modifiers use **secondary combat stats only**.

Primary hero attributes such as Strength, Dexterity, Intelligence, Constitution, and Wisdom are **not rolled as ordinary equipment modifiers**.

This preserves a clean distinction between:

- the hero’s own long-term development through primary attributes;
- equipment’s effect on the hero’s resolved combat capabilities through secondary stats.

An item’s inherent base stat is allowed to appear again as one of its random modifiers. For example, armor has inherent Armor but may also roll an additional Armor modifier, and a weapon may roll additional Damage or its appropriate speed modifier.

However, **the same random modifier cannot appear more than once on the same item**. Base properties do not count as duplicates for this rule.

### Current Modifier Pools by Equipment Group

The following pools are the current working set. They are intentionally compact and may expand later if additional secondary combat stats gain a clear mechanical purpose.

#### Armor

Normal armor has only its inherent base Armor. Random armor modifiers are selected from:

- **Health**;
- **Armor**;
- **Dodge**.

Starting at **Epic** rarity, armor may additionally roll **one elemental resistance** chosen from:

- Fire Resistance;
- Cold Resistance;
- Lightning Resistance.

An armor item may never contain more than **one elemental-resistance random modifier**, even at Legendary rarity.

Under the current pool and no-duplicate rule, Legendary armor necessarily uses Health, Armor, Dodge, and exactly one elemental resistance. This consequence may change later if the armor modifier pool expands.

#### Weapons

Weapon random modifiers are selected from:

- **Damage**;
- **Accuracy**;
- **Critical Chance**;
- **Critical Damage**;
- **Attack Speed** or **Cast Speed**, depending on the weapon family and its combat role.

Attack Speed and Cast Speed are not interchangeable on every weapon. The appropriate speed stat is determined by the weapon’s intended combat logic.

#### Jewelry

Ring and necklace random modifiers are selected from:

- **Fire Resistance**;
- **Cold Resistance**;
- **Lightning Resistance**;
- **Health**;
- **Dodge**;
- **Accuracy**;
- **Critical Chance**;
- **Critical Damage**.

Jewelry therefore has the broadest current modifier pool and can bridge offensive, defensive, and situational elemental needs.

#### Off-Hand Items

Dedicated Off Hand items use the current general pool:

- **Accuracy**;
- **Critical Chance**;
- **Critical Damage**;
- one **item-type-specific Off Hand stat**, where such a stat has been defined.

For a shield, the currently defined item-type-specific stat is **Block**.

Other dedicated Off Hand types may receive their own specific stat later when their class mechanics are defined. A second one-handed weapon used in the Off Hand remains a weapon and follows the modifier rules of its weapon family rather than the dedicated Off Hand-item pool.

These pools are working design rules, not a claim that the final game will never gain additional secondary stats.

### Stat Cost

Modifier Budget is an abstract measure of power, not a direct number of visible stat points.

Different secondary stats have different costs. Therefore equal numerical values of different stats are not assumed to have equal combat value.

The current **provisional modifier-cost scale** is derived from the working Warrior Power model in `Combat_and_Progression_System_Design_v0.1.md`. The comparison uses an illustrative reference Warrior around:

- 1000 Health;
- 100 Armor;
- 100 Fire, Cold, and Lightning Resistance;
- 50 Dodge;
- 100 Accuracy;
- 100 physical Damage;
- 25% Critical Chance;
- 200% Critical Damage.

The scale is normalized so that approximately **+1 Armor = 10 Modifier Budget** near that reference build.

| Modifier gain | Provisional budget cost |
| --- | ---: |
| +1 Health | ~3 |
| +1 Armor | ~10 |
| +1 Dodge | ~12 |
| +1 Accuracy | ~3 |
| +1 Damage | ~30 |
| +1 percentage point Critical Chance | ~25 |
| +1 percentage point Critical Damage | ~6 |
| +1% Attack Speed | ~30 |
| +1% Cast Speed | ~30, provisional |
| +1 elemental Resistance | ~5, provisional |
| Block | TBD |

As a rough readability example, **100 Modifier Budget** would currently correspond to approximately one of the following single-stat amounts near the reference build:

- +33 Health;
- +10 Armor;
- +8 Dodge;
- +33 Accuracy;
- +3.3 Damage;
- +4 percentage points Critical Chance;
- +16–17 percentage points Critical Damage;
- +3.3% Attack Speed;
- +20 of one elemental Resistance.

These prices are **working local weights, not permanent universal exchange rates**. Armor, Dodge, Accuracy, resistances, Critical Chance, and Critical Damage have nonlinear or context-dependent value. Their marginal value changes with the hero’s existing stats, and some stats depend on the opponent or damage type.

Elemental Resistance is intentionally priced more conservatively than a literal derivative of the universal Power formula would suggest. The universal Warrior Power reference environment weights each individual element at only 10% of incoming damage, which would otherwise make a single resistance artificially cheap in the item generator even though it can be very strong in the matching real encounter.

Cast Speed is provisionally valued near Attack Speed until caster damage and casting mechanics are defined. Block remains unpriced until its actual combat formula is established.

> **Modifier costs should keep different stats in roughly comparable power territory without pretending that every build and every matchup gives those stats identical value.**

## Random Modifier Generation

Generated equipment follows the general structure:

> **base item → item level → rarity → total Modifier Budget roll → modifier selection → budget distribution → rolled stat values**

The base item defines the item type, equipment slot, and its inherent base characteristics.

Item level establishes the strength of those base characteristics and the relevant modifier-budget scale. Rarity then determines the exact number of random modifiers and selects the corresponding total-budget range.

After the total budget is rolled, modifiers are selected from the pool available to that specific type of item. The rolled budget is distributed among those mandatory modifiers within the allowed distribution limits, and each modifier converts its assigned budget into its actual stat value according to that stat’s cost rule.

The random part of item generation therefore comes from:

- which eligible modifiers are selected;
- where inside the rarity-and-ilvl budget range the item’s total Modifier Budget lands;
- how that total budget is distributed among the mandatory modifiers within allowed limits;
- any later approved final-value rounding or small roll variation inside the stat conversion rules.

Generation should not be completely unrestricted. Each item type has its own pool of allowed secondary combat stats so that items remain coherent with their function.

The same random modifier cannot be selected twice for one item. Higher-rarity items therefore draw multiple different properties from their valid pool rather than stacking duplicate modifier entries.

The current secondary combat stats are defined in `Combat_and_Progression_System_Design_v0.1.md`. Exact final stat costs, final budget ranges, distribution bounds, item-level scale, and numerical roll rules remain balance questions.

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

Resistances are valid defensive item stats and may appear as base properties or appropriate random modifiers under the item-generation rules.

At the current design stage there is no resistance penetration, resistance reduction below zero, or other advanced resistance interaction.

> **Elemental resistances use the same defensive logic as Armor: more resistance provides diminishing returns, with a hard maximum of 75% damage reduction.**

## Accuracy and Dodge on Equipment

**Accuracy** and **Dodge** are valid secondary combat stats that may appear on equipment through appropriate random modifiers or base properties where explicitly defined.

Their exact combat interaction is owned by `Combat_and_Progression_System_Design_v0.1.md`. In the current model, Accuracy counters Dodge rather than increasing hit chance above 100%, and both stats use the same shared hit-resolution formula for the hero and enemies.

The item system should therefore evaluate Accuracy primarily as a way to improve performance against targets that possess Dodge, while Dodge provides a defensive chance to avoid eligible attacks.

The exact modifier tiers and numerical ranges for Accuracy and Dodge will be defined together with the broader modifier balance.

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
