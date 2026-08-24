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

At the current design stage, the hero has **12 equipment slots**.

Armor uses five slots:

- helmet;
- chest armor, with shoulders included as part of the same item rather than a separate equipment slot;
- gloves;
- pants;
- boots.

Jewelry and utility equipment use five slots:

- ring slot 1;
- ring slot 2;
- necklace;
- earrings;
- belt.

The remaining two slots are:

- **Main Hand**;
- **Off Hand**.

A one-handed weapon occupies Main Hand. Depending on class and equipment rules, Off Hand may contain a shield, a second weapon, a magical focus, or another class-appropriate item.

A **two-handed weapon occupies both Main Hand and Off Hand simultaneously**. While a two-handed weapon is equipped, no separate Off Hand item can be used.

Earrings are treated as one equipment slot representing a wearable pair rather than creating separate left-ear and right-ear slots.

The Belt is mechanically distinct from ordinary jewelry because it also controls the hero’s carried healing-potion capacity for dungeon expeditions.

> **The current structure is 5 armor + 5 jewelry/utility + 2 hand slots.**

## Base Stats by Equipment Group

Equipment is divided into several broad mechanical groups. Items within one group do not need completely different base-stat rules merely because they occupy different visual slots.

### Armor

Helmet, chest armor, gloves, pants, and boots share the same basic mechanical identity:

- their inherent base defensive stat is **Armor**.

Exact Armor values depend on item level and later balance rules. The current design does not require separate fundamental Armor formulas for each armor slot unless testing later shows that slot-specific weighting creates useful gameplay.

### Jewelry

Rings, necklaces, and earrings use elemental resistance as their current base defensive identity.

A standard jewelry item may inherently provide one of:

- **Fire Resistance**;
- **Cold Resistance**;
- **Lightning Resistance**.

Earrings follow the same base-stat and random-modifier rules as rings and necklaces unless a later design gives them a distinct purpose.

The exact selection rules, value ranges, and whether some jewelry types later receive different base properties remain tuning questions.

### Belt

The Belt is a special utility equipment type rather than ordinary jewelry.

At the current design stage its inherent combat stat is:

- **Health**, with the base Health amount determined by item level.

The Belt does **not** currently roll the ordinary jewelry modifier pool or other random combat affixes. Its rarity instead determines healing-potion capacity, while its item level determines both its base Health scale and the maximum potion item level its slots can accept.

Detailed Belt and potion rules are defined below.

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
- **rarity** — normally determines the fixed number of random modifiers and, together with item level, the range of the item’s total modifier budget.

For ordinary generated equipment of the same base type and item level, rarity does **not** automatically increase the inherent base stat merely because the item is a different color. The extra power of higher rarity normally comes primarily from additional modifiers and the larger budget available to those modifiers.

The **Belt is an explicit exception** to the ordinary rarity/modifier rule. At the current design stage, Belt rarity determines the number of potion slots rather than the number of random combat modifiers.

The item system does **not** use a mechanical prefix/suffix split. Random properties are simply **modifiers** selected from the valid modifier pool for that item type.

The current ordinary rarity structure is:

| Rarity | Color | Random modifiers on standard equipment |
| --- | --- | ---: |
| Normal | White | 0 |
| Uncommon | Green | 1 |
| Rare | Blue | 2 |
| Epic | Purple | 3 |
| Legendary | Orange | 4 |

Modifier slots on standard equipment are never empty. If a standard item has a given rarity, it always receives the complete number of random modifiers defined for that rarity.

> **For standard equipment, item level determines the strength scale and rarity determines modifier structure. Special-purpose item types such as the Belt may give rarity a different explicit mechanical role.**

## Modifier Power Budget

The item’s inherent base stats are determined separately from its modifier budget.

A **Normal / White** standard item has no random modifiers and therefore has:

> **Modifier Budget = 0**

It consists only of the base properties appropriate to its item type and item level.

For standard Uncommon, Rare, Epic, and Legendary items, **item level and rarity together define a range for the total Modifier Budget**. The final total budget is rolled somewhere inside that range.

The current provisional rarity multipliers for the modifier-budget scale are:

| Rarity | Working budget multiplier |
| --- | ---: |
| Uncommon | ×1.0 |
| Rare | ×1.5 |
| Epic | ×2.0 |
| Legendary | ×2.5 |

These multipliers are provisional balance values. Their purpose is to establish the relative strength of rarities before exact item-level ranges are known.

The current working progression target is:

> **A Legendary standard item from the current item tier should have approximately the same total modifier budget as a Rare item from the next item tier.**

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

> **Rarity creates both more modifiers and a larger total modifier budget on standard equipment, while controlled random distribution creates meaningful variation between items of the same level and rarity.**

### Modifier Stat Scope

Standard randomly generated item modifiers use **secondary combat stats only**.

Primary hero attributes such as Strength, Dexterity, Intelligence, Constitution, and Wisdom are **not rolled as ordinary equipment modifiers**.

This preserves a clean distinction between:

- the hero’s own long-term development through primary attributes;
- equipment’s effect on the hero’s resolved combat capabilities through secondary stats.

An item’s inherent base stat is allowed to appear again as one of its random modifiers where that item type supports ordinary modifiers. For example, armor has inherent Armor but may also roll an additional Armor modifier, and a weapon may roll additional Damage or its appropriate speed modifier.

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

Ring, necklace, and earrings random modifiers are selected from:

- **Fire Resistance**;
- **Cold Resistance**;
- **Lightning Resistance**;
- **Health**;
- **Dodge**;
- **Accuracy**;
- **Critical Chance**;
- **Critical Damage**.

Jewelry therefore has the broadest current modifier pool and can bridge offensive, defensive, and situational elemental needs.

#### Belt

The Belt does not currently use a random modifier pool.

Its current mechanical identity is fully defined by:

- base Health from item level;
- potion-slot count from rarity;
- maximum allowed potion item level from Belt item level.

Additional Belt affixes should not be introduced until this utility role has been tested and shown to need more complexity.

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

## Item Power as Approximate Hero-Power Contribution

Standard equipment items should expose a visible **Item Power / Item Strength** value in their information panel in addition to their actual stats.

This value is intended to answer a simple player-facing question:

> **Approximately how much Hero Power would this item add under ordinary reference conditions?**

Item Power is calculated with the same current Hero Power formula owned by `Combat_and_Progression_System_Design_v0.1.md`, but it is evaluated against one fixed reference combat-stat profile so that the value printed on an item does not change depending on who is currently holding it.

The current reference profile is:

- 1000 Health;
- 100 Armor;
- 50 Dodge;
- 100 Accuracy;
- 100 physical Damage;
- 1.0 Attack Speed;
- 25% Critical Chance;
- 200% Critical Damage;
- 100 Fire Resistance;
- 100 Cold Resistance;
- 100 Lightning Resistance.

Under the current Warrior Power formula, this reference profile has a baseline Power of approximately:

`Reference Power ≈ 433.0`

The item’s full resolved contribution — its inherent base properties plus all rolled modifiers — is then applied on top of that fixed reference profile and Power is recalculated.

The working formula is:

`Item Power = Power(Reference Stats + Item Stats) - Power(Reference Stats)`

or equivalently:

`Item Power = Power(Reference Stats + Item Stats) - 433.0`

The UI should display this direct result without an arbitrary cosmetic multiplier. Rounding and decimal display are presentation questions, but the underlying value should remain on the same scale as Hero Power so that, conceptually, an item showing `Item Power 18` means that it adds roughly eighteen points of Hero Power to the fixed reference build.

Item Power is **not a promise of the exact Power increase for the current hero**. The real gain from an item may be higher or lower because Armor, Dodge, Accuracy, Critical Chance, resistances, and other stats have nonlinear or context-dependent value and interact with the hero’s existing build.

Its purpose is to provide a stable, understandable, approximately comparable estimate of an item’s combat strength while preserving the real Hero Power formula as the underlying evaluator.

> **Item Power is a reference estimate of how much Hero Power the item contributes, not a personalized prediction for the current hero.**

### Belt Is Not Assigned Ordinary Item Power

The Belt is currently excluded from the ordinary displayed Item Power calculation because a major part of its value is **expedition healing capacity**, which does not translate cleanly into the single-fight Hero Power formula.

Its permanent base Health remains a normal resolved combat stat, but the Belt as a complete item should not receive a misleading combined Item Power number that pretends potion capacity is ordinary combat Power.

For comparing Belt utility, the current simple secondary measure is:

`Potion Healing Capacity = number of potion slots × healing of the strongest potion allowed by the Belt`

This assumes all slots are filled with the strongest legal healing potion and is meant as an understandable capacity measure, not a replacement for full dungeon decision logic.

The hero may therefore compare two Belts using both:

- their inherent base Health;
- their total potential potion-healing capacity.

> **A Belt can make the hero much better prepared for an expedition without pretending that this is the same thing as increasing single-fight Hero Power.**

## Hero Equipment Evaluation Uses Virtual Equip

When the autonomous hero decides whether a found or offered standard item is actually better for them, the displayed Item Power is not the final decision rule.

The hero evaluates standard equipment through a **virtual equip** operation:

1. temporarily place the candidate item into its legal equipment slot or slot combination;
2. resolve the hero’s complete resulting `CombatStats` through the normal `StatResolver` pipeline;
3. recalculate the hero’s real Hero Power using the shared Power formula;
4. compare that result with the Power of the current equipment configuration;
5. prefer the legal configuration with the higher resulting Hero Power, subject to any later approved non-Power decision rules.

The virtual equip does not physically change the hero’s equipment until the comparison has been completed and the hero has decided to use the item.

This method also handles interactions that a simple per-item score cannot represent exactly. A lower-Item-Power object may sometimes be the better upgrade for a particular hero because of the hero’s current stats, while a nominally stronger item may add less real Power to that specific build.

At the current design stage, the ordinary equipment decision can remain simple: **if the candidate legal configuration produces more Hero Power, it is the stronger standard equipment choice**. More situational equipment logic may be considered later only if it creates useful decisions.

The Belt is a special case because the hero must consider both the base-Health change from virtual equip and the practical change in potion capacity for dungeon preparation.

> **Item Power helps the player understand standard items; virtual equip determines what is actually stronger for this hero; Belt utility additionally depends on expedition capacity.**

## Belt and Healing Potions

The Belt provides the hero with a limited number of slots for healing potions used during dungeon expeditions and any later activities that explicitly support this resource.

### Belt Rarity Determines Potion Slots

The current Belt slot progression is:

| Belt rarity | Potion slots |
| --- | ---: |
| Normal / White | 1 |
| Uncommon / Green | 2 |
| Rare / Blue | 3 |
| Epic / Purple | 4 |
| Legendary | 5 |

This slot count is the Belt’s main rarity benefit. Belt rarity does not currently add ordinary random affixes.

### Belt Item Level Limits Potion Item Level

Every potion slot on a Belt uses the same item-level limit as the Belt itself.

A potion may be inserted only when:

`Potion ilvl ≤ Belt ilvl`

The slots do not have separate individual item levels.

For example:

- an `ilvl 10` Belt can hold healing potions up to `ilvl 10`;
- an `ilvl 20` Belt can hold healing potions up to `ilvl 20`.

Illustratively, an ilvl 10 healing potion might restore about **50 HP**, while an ilvl 20 potion might restore about **100 HP**. These values are provisional examples rather than final potion scaling.

Higher-ilvl healing potions restore more Health and also cost more gold. The exact healing curve and price curve will be tuned together so that stronger dungeon preparation carries a meaningful economic cost.

The hero does not receive free replacement potions merely because a dungeon attempt begins. Filling or refilling the Belt is an economic preparation step.

> **A better Belt allows more and stronger healing resources, but using that capacity costs real gold.**

## Random Modifier Generation

Generated standard equipment follows the general structure:

> **base item → item level → rarity → total Modifier Budget roll → modifier selection → budget distribution → rolled stat values**

The base item defines the item type, equipment slot, and its inherent base characteristics.

Item level establishes the strength of those base characteristics and the relevant modifier-budget scale. Rarity then determines the exact number of random modifiers and selects the corresponding total-budget range for item types that use the standard modifier system.

After the total budget is rolled, modifiers are selected from the pool available to that specific type of item. The rolled budget is distributed among those mandatory modifiers within the allowed distribution limits, and each modifier converts its assigned budget into its actual stat value according to that stat’s cost rule.

The random part of item generation therefore comes from:

- which eligible modifiers are selected;
- where inside the rarity-and-ilvl budget range the item’s total Modifier Budget lands;
- how that total budget is distributed among the mandatory modifiers within allowed limits;
- any later approved final-value rounding or small roll variation inside the stat conversion rules.

Generation should not be completely unrestricted. Each item type has its own pool of allowed secondary combat stats so that items remain coherent with their function.

The same random modifier cannot be selected twice for one item. Higher-rarity standard items therefore draw multiple different properties from their valid pool rather than stacking duplicate modifier entries.

Special-purpose types such as the Belt follow their explicitly defined generation rules instead of being forced through the ordinary modifier pipeline.

The current secondary combat stats are defined in `Combat_and_Progression_System_Design_v0.1.md`. Exact final stat costs, final budget ranges, distribution bounds, item-level scale, and numerical roll rules remain balance questions.

> **Randomness should create item variety, not meaningless chaos.**

## Ordinary Mob Loot Generation

Ordinary enemies use a source-driven loot model. Their equipment drops are not scaled to the hero and are not filtered to guarantee that the hero can use them.

Each ordinary mob type is assigned a specific **equipment item level** for its normal equipment drops. For example, if a Wild Boar is defined as an `ilvl 10` loot source, any ordinary equipment item generated from that boar uses ilvl 10 regardless of the hero’s current level or equipment.

The current ordinary-mob equipment generation sequence is:

> **mob defeated → ordinary creature loot → 5% equipment-drop check → equipment slot / item type roll → rarity roll → standard modifier generation where applicable → final stats**

### Ordinary Creature Loot

A defeated ordinary mob may provide its normal creature-appropriate loot independently of the equipment-drop check.

- humanoid enemies may carry **gold** when this makes sense for that enemy;
- beasts and monsters normally provide an appropriate **trophy or other sellable creature loot** rather than direct currency;
- specific mob definitions may later refine their ordinary loot profile when there is a clear world reason.

This ordinary loot does not replace the separate chance to generate equipment.

### Equipment Drop Chance

Each ordinary mob currently has a working **5% chance** to generate one equipment item when defeated.

The 5% value is provisional and may be tuned later, but it is intentionally separate from rarity. First the game decides whether an equipment item exists at all. Only after a successful equipment-drop check does it determine what kind of item dropped and how rare it is.

### Equipment Slot and Item Type

After the equipment-drop check succeeds, the game rolls the equipment slot with an equal basic chance across the current equipment-slot structure unless a specific loot source later defines a different table.

If the selected slot can contain more than one concrete item family, a further item-type roll determines the actual dropped item. For example, a Main Hand or Off Hand result may later resolve into one of the item families valid for that slot.

The drop is **not filtered to the current hero’s class, specialization, weapon access, or immediate usefulness**. A Warrior may find a caster-oriented item, and a Mage may find a heavy weapon they cannot use. Such items can still be sold or otherwise handled through the normal inventory economy.

> **The world generates loot from the source, not a personalized reward list for the current hero.**

### Ordinary-Mob Rarity Roll

After the equipment slot / item type has been selected, rarity is rolled independently using the current working distribution:

| Rarity | Chance among successful ordinary equipment drops |
| --- | ---: |
| Normal / White | 70% |
| Uncommon / Green | 25% |
| Rare / Blue | 5% |

For ordinary mobs, **Rare / Blue is the maximum possible rarity**.

Ordinary mobs do not randomly generate Epic or Legendary equipment. Higher rarities require stronger or more exceptional loot sources such as elites, bosses, dungeons, major events, or special quest structures that explicitly support them.

### Final Item Generation After Rarity

A White result receives the base properties appropriate to the rolled item type and the mob’s assigned equipment ilvl, with no ordinary random modifiers.

If the selected item type uses the standard modifier system and rarity is Green or Blue, the item then continues through the existing modifier-generation system:

1. roll the total Modifier Budget inside the range defined by that item level and rarity;
2. select the required number of different modifiers from the valid pool for the rolled item type;
3. distribute the rolled budget among those modifiers within the current distribution rules;
4. convert each modifier’s assigned budget into its final visible stat value.

Special-purpose item types such as the Belt instead apply their own rarity-specific rules after slot and rarity are known.

> **Source determines ilvl; the drop check determines whether equipment appears; the slot roll determines what appeared; rarity determines its quality structure; the item-type rules determine the final item.**

## Initial Gold Economy

The first economy should connect adventuring, loot, gold, shops, equipment progression, and dungeon preparation without turning the game into a trading or maintenance simulator.

The basic economic loop is:

> **quest / combat → collect loot in backpack → complete the objective → review loot and equip worthwhile upgrades → return to town → turn in the quest and receive gold → go to the market → sell all trophies and all unequipped equipment → inspect shop stock → buy a worthwhile available upgrade when appropriate → refill or improve dungeon healing potions when relevant → recalculate the hero’s resulting strength and readiness → choose the next activity**

The hero should be able to perform this loop autonomously. At the current design stage, equipment that is not chosen during the post-quest review is not kept as a spare or situational set; it is sold when the hero reaches the market.

### Gold Sources

The current basic sources of gold are:

- **quest rewards** — a stable and important source of direct income;
- **direct currency loot from humanoid enemies**, when it is reasonable for that enemy to carry money;
- **selling unwanted equipment and trophies** obtained through adventures.

At the current design stage, **ordinary / simple quests give gold as their completion reward and do not directly award random equipment**. Equipment gained during a normal quest comes from the adventure itself, primarily through mob drops. Special or exceptional quests may later explicitly award items as a separate, authored reward type.

Beasts and ordinary monsters do **not** drop gold merely because they were defeated. They may instead provide equipment, trophies, or other sellable loot appropriate to the creature and activity.

> **Currency should come from sources that make sense in the world rather than appearing automatically from every defeated creature.**

### Current Gold Uses

At the current design stage, the hero spends gold on two meaningful progression uses:

- **equipment purchases**;
- **healing potions**, especially when preparing or refilling the Belt for dungeon expeditions.

There are currently no regular gold costs for repair, taverns, travel, taxes, or other maintenance systems. Additional gold sinks may be introduced later only if they create useful decisions rather than existing merely to remove currency from the economy.

Higher-ilvl healing potions cost more than weaker potions, so improved expedition capacity also increases the potential price of fully preparing for a dungeon attempt.

The hero does not need to preserve a mandatory abstract gold reserve. They may spend on worthwhile upgrades and preparation according to current goals, while still rejecting negligible improvements or unnecessarily expensive preparation.

> **Gold should support meaningful progression and risky expeditions, not routine chores.**

### Item Reference Value and Resale

Every equipment item has a reference shop value even if that rarity is not normally offered by ordinary shops.

The current provisional price scale is anchored by **item level and rarity**. For Normal / White equipment, the current working control points are:

| Item level | Approximate White reference shop value |
| ---: | ---: |
| 1 | ~100 gold |
| 10 | ~500 gold |
| 20 | ~1000 gold |

These are provisional economy control points, not a finalized pricing formula. The exact curve between these points, the curve above ilvl 20, and any later item-type price weighting remain tuning questions.

For Uncommon / Green equipment, the current working rule is:

> **Green reference value ≈ 3 × the White reference value at the same ilvl**

This gives the following illustrative values:

| Item level | White | Green |
| ---: | ---: | ---: |
| 1 | ~100 | ~300 |
| 10 | ~500 | ~1500 |
| 20 | ~1000 | ~3000 |

The exact reference-value rules for Rare, Epic, and Legendary items are not fixed yet. Those rarities still require a reference value even when ordinary shops do not sell them, because the value is used for resale and other future economy calculations.

The final pricing model may later account for the exact rolled Modifier Budget or item type if testing shows that doing so improves the economy. For now, the control points above define the starting scale without prematurely locking a detailed formula.

When the hero sells equipment to an ordinary shop, the current rule is:

> **Sell Price = 10% of the item’s reference shop value**

At the current control points this means, for example:

- ilvl 1 White: ~10 gold resale;
- ilvl 10 White: ~50 gold resale;
- ilvl 20 White: ~100 gold resale;
- ilvl 1 Green: ~30 gold resale;
- ilvl 10 Green: ~150 gold resale;
- ilvl 20 Green: ~300 gold resale.

This large buy/sell spread prevents found equipment from becoming almost equivalent to liquid gold and makes buying an item a meaningful expenditure rather than a nearly reversible exchange.

Healing-potion pricing uses its own progression curve rather than the equipment resale formula. The only current fixed principle is that **higher-ilvl potions heal more and cost more**.

### Ordinary Shops Are Not the Main Source of High-Rarity Gear

Ordinary shops exist primarily to provide baseline equipment, fill weak slots, and offer practical incremental upgrades. Their main systemic role is **bad-luck protection**: if random drops leave one equipment slot significantly behind the rest of the hero's gear, the hero can use accumulated gold to replace that weak slot with an available baseline White or Green item.

Shops therefore **supplement loot progression rather than replace it**. A hero who is lucky with drops may need merchants much less, while a hero who repeatedly misses a useful item for one slot still has a controlled way to repair that weakness. Ordinary shops should not become the most efficient or reliable route to strong equipment.

They should not allow the hero to convert enough repetitive quest gold directly into the best equipment in the game.

The default ordinary-shop equipment rarity pool is:

- **Normal / White**;
- **Uncommon / Green**.

**Rare / Blue** shop access may be unlocked through sufficiently high reputation with relevant factions or organizations. The exact reputation thresholds and which factions provide such access will be defined with the reputation and faction systems.

**Epic / Purple** shop access may be considered later as an exceptional high-reputation or special-market reward, but is not part of the normal shop baseline.

**Legendary** equipment is not part of ordinary shop progression.

High-quality equipment should primarily come from gameplay sources such as:

- enemy and activity drops;
- dungeons;
- bosses;
- special events;
- exceptional or special quests;
- other rare world opportunities.

Healing potions are a separate consumable shop category and are not governed by the equipment rarity-access rule above. Their availability may depend on the city/shop progression tier and their own potion ilvl.

> **Gold buys what the world’s merchants can actually offer; accumulating enough gold alone should not unlock the best equipment.**

### Shop Strength Depends on the City, Not the Hero

A shop’s potential item level is determined by the city or settlement and its economic / progression tier rather than scaling automatically to the current hero.

The current illustrative structure, assuming a future overall item-level cap around **150**, is:

| City / shop tier | Illustrative ordinary-shop ilvl ceiling |
| --- | ---: |
| Starting / low-tier city | up to ~30 |
| Mid-tier city | up to ~60 |
| Advanced / high-tier city | up to ~100 |

These values are provisional control points rather than final world-map assignments.

Under this model, ordinary shops do not provide the highest item levels at all. Equipment above the normal high-tier shop ceiling must come from adventuring sources rather than simply waiting for a merchant to stock it.

A developed hero may therefore completely outgrow the commercial equipment available in weaker cities.

Potion availability should follow the same world-facing principle: a weak city should not secretly sell top-tier healing potions merely because the current hero owns a high-ilvl Belt.

> **Merchants belong to places in the world; their inventory does not secretly level up because the hero did.**

### Limited and Changing Shop Stock

Shops have a **limited assortment** rather than offering every legal item type and every possible stat combination on demand.

Their equipment stock is generated within the rules of that shop, including:

- city / shop item-level range;
- allowed rarities;
- relevant item families;
- any reputation-gated access;
- other future local restrictions where they have a clear purpose.

The assortment changes periodically. The hero may therefore find a useful upgrade on one visit and nothing worthwhile on another.

Healing potions may use a simpler consumable stock rule if testing shows that fully random potion absence makes dungeon preparation frustrating rather than interesting. The exact potion availability model is not fixed yet.

The exact stock size and refresh interval are balance parameters to be defined later.

### Hero Purchase Evaluation

The hero evaluates shop equipment autonomously by comparing the offered item with their current equipment, the practical improvement it provides, and the gold cost.

For the equipment-strength part of this decision, a standard offered item is tested through the same **virtual equip** process used for found loot: the candidate is temporarily substituted into the legal equipment configuration, complete `CombatStats` are resolved, and the hero’s resulting real Hero Power is recalculated before any purchase is made.

A technically positive but negligible increase should not automatically trigger a purchase. For example, an improvement from approximately `500 Power` to `501 Power` should normally be treated as too small to justify meaningful expenditure.

Belt purchases additionally consider the change in base Health and potion-healing capacity rather than relying on ordinary Item Power alone.

Potion purchases are evaluated as preparation resources. The hero considers how many Belt slots need filling, the strongest potion level the Belt allows, potion availability, current gold, and whether a dungeon expedition or another supported activity makes the expenditure worthwhile.

There is currently no mandatory gold-reserve rule. If other strategically important gold sinks are introduced later, purchase behaviour can be revised to account for competing uses of currency.

> **The hero should value a real upgrade or useful preparation, but should not waste accumulated resources on changes that barely matter.**

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