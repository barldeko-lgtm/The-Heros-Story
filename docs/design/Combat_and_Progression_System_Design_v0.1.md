# The Hero’s Story — Combat & Progression System Design

**Status:** Draft  
**Document version:** 0.1 skeleton

## Purpose

This document defines how the hero becomes stronger and how autonomous combat converts stats, equipment, skills, and experience into understandable outcomes.

## This document covers

- combat model and timing;
- combat stats;
- shared Power concept for hero and enemies;
- damage, attack speed, critical hits, defense, and related combat parameters;
- XP and level progression;
- attribute growth;
- skills and class progression;
- combat-related traits;
- death consequences that originate from combat;
- interfaces through which equipment and temporary effects modify final combat stats.

## This document does not cover

- hero biography and general identity — see `Hero_System_Design_v0.1.md`;
- personality-based choice logic — see `Personality_and_Decision_System_Design_v0.1.md`;
- item generation and equipment ownership — see `Economy_Equipment_and_Loot_System_Design_v0.1.md`;
- quest selection/content — see `Quest_and_Activity_System_Design_v0.1.md`.

## Core boundary

Hero and enemy strength must remain comparable through one shared combat-stat and Power model. Equipment and temporary effects feed combat through resolved stats rather than special-case combat logic.

## Overall Hero Level

The hero has one overall level that represents their long-term development as an adventurer.

By gaining experience, the hero increases this level and gradually becomes stronger. Level serves as one of the main axes of vertical character progression.

The exact sources of experience and the rewards granted by each level will be defined separately.

The game does not use a separate TES-like progression system for every weapon type simply through repeated use — for example, separate Sword, Axe, or Bow levels that rise only because the hero frequently uses that weapon.

> **Hero development should create meaningful differences rather than accumulate dozens of secondary progression tracks.**

## Attribute Growth on Level-Up

The player does not manually distribute all of the hero’s attributes after every level-up.

Before specialization, attribute growth is shared between three influences:

1. **class** — guarantees part of the growth toward the class’s core attribute or attributes;
2. **deity guidance** — allows the player to softly encourage one development direction;
3. **the hero** — most growth is distributed autonomously according to the hero’s own tendencies and development logic.

The current working baseline before the first specialization is:

> **5 attribute points per level: 1 from class + 1 from deity guidance + 3 distributed by the hero.**

After the hero actually gains the first specialization, unlocked from level 40 through the specialization-quest structure defined later in this document and in `Quest_and_Activity_System_Design_v0.1.md`, that specialization becomes an additional permanent influence on level-up growth. The first specialization contributes **+1 specialization-directed attribute point per hero level** associated with that tier.

After the hero actually gains the second specialization tier, unlocked from level 80 through the same progression structure, the final specialization adds **another +1 specialization-directed attribute point per hero level**.

The intended normal structure after the corresponding specializations have been obtained is therefore:

- before the first specialization: `1 class + 3 hero + 1 deity = 5`;
- after the first specialization: the same growth + `1 first-specialization point = 6`;
- after the second specialization: the same growth + `1 first-specialization point + 1 final-specialization point = 7`.

Specialization-directed points go toward the attribute or attributes that define that specialization. The exact distribution inside a specialization profile will be defined when the individual class branches are designed.

Receiving a specialization also provides an immediate stat increase so that completing that development milestone creates a noticeable jump rather than only changing future growth:

- **first specialization:** immediately gain **+5 profile attribute points** from the chosen specialization;
- **final specialization:** immediately gain **+10 profile attribute points** from the chosen final specialization.

These milestone points follow the specialization’s own stat profile. Whether all points go into one primary attribute or are divided among several profile attributes depends on the individual specialization design.

### Delayed Specialization Does Not Lose Its Intended Growth

Reaching level 40 or 80 only makes the relevant specialization path available. Until the hero completes the corresponding Specialization Quest, the specialization is not yet owned and its `+1` directed point is **not applied to the hero’s current stats**.

However, delayed completion does not permanently erase the specialization growth associated with the levels passed after the milestone.

Once the hero finally obtains the specialization, the system grants the accumulated specialization-directed points for the hero levels already gained beyond that specialization milestone, and future level-ups then continue granting the normal `+1` from that specialization tier.

For example, if the hero does not obtain the first specialization until level 45, the five hero levels gained after level 40 represent **five accumulated first-specialization points**. Those points are granted when the specialization becomes active, in addition to the specialization’s separate immediate `+5` profile-stat reward. Normal level-up growth remains separate.

The same principle applies to the second specialization tier after level 80.

The exact timing of the catch-up presentation — for example whether all accumulated points are displayed immediately on quest completion or bundled into the next level-up presentation — is an implementation/UI question. The conceptual rule is simply that the hero neither benefits from an unearned specialization early nor permanently loses its intended post-milestone growth by completing the quest late.

The current numbers are working design values and may be tuned during implementation, but the structural principle is that each specialization tier creates both an immediate stat step and a persistent directed component of long-term growth.

The hero’s autonomous share should not be random. It may be influenced by biography, personality, preferences, lifestyle, and meaningful accumulated experience.

Divine guidance should influence development without becoming ordinary manual point allocation by the player.

> **The hero develops themselves; class, specialization, and the deity shape the direction without replacing the hero’s own growth.**

## Hero Growth Must Be Understandable

Although attribute growth is allocated automatically, the result should not feel random to the player.

When the hero levels up, the player should be able to understand:

- which attributes increased;
- which part of the growth came from class;
- which part came from the hero’s current specialization path;
- which direction was encouraged by deity guidance;
- which tendencies, preferences, or experiences influenced the hero’s autonomous share.

The exact way this information is presented will be defined separately.

> **The player does not directly control the hero’s development, but should understand why the hero is developing in that direction.**

## Base Attributes and Resources

At the current design stage, the hero has **five primary developable attributes**:

- **Strength (STR)**;
- **Dexterity (DEX)**;
- **Intelligence (INT)**;
- **Constitution (CON)**;
- **Wisdom (WIS)**.

Primary attributes are long-term characteristics of the hero. They contribute to secondary combat stats and may also be used by appropriate non-combat events, checks, and outcomes when the nature of the situation makes that attribute relevant.

### Provisional Primary Attribute Contributions

The current working contribution of **each single point** of a primary attribute is:

| Primary attribute | Current provisional contribution per point |
| --- | --- |
| **Strength (STR)** | +2 physical Damage; +5% Critical Damage |
| **Dexterity (DEX)** | +10 Accuracy; +5 Dodge; +3% Critical Chance |
| **Intelligence (INT)** | +2 magical Damage; +20 Mana |
| **Constitution (CON)** | +20 maximum Health; +2 Armor |
| **Wisdom (WIS)** | improves learned abilities through **ability-specific scaling** |

These values are **provisional balance values**, intended to establish the role of each primary attribute before final stat ranges are known. They may be adjusted substantially during balance work. The Accuracy/Dodge interaction now has a defined working formula, but the current +10 Accuracy and +5 Dodge gained from each point of Dexterity remain provisional balance values.

Wisdom no longer directly grants Skill Levels. Instead, each ability defines how Wisdom improves that particular ability. Depending on the ability, Wisdom may improve damage, healing, mitigation, effect strength or duration, reduce cooldown time, improve resource efficiency, or provide another effect that fits the ability’s actual purpose.

The exact Wisdom coefficient is therefore **skill-specific rather than universal**. A damaging skill and a defensive skill do not need to gain the same kind of benefit from Wisdom merely for symmetry.

Primary attributes may also influence appropriate event checks and outcomes independently of these combat contributions.

Separate from those attributes are hero resources:

- **HP / Health**;
- **Stamina** — currently considered as a resource for travel and other actions outside combat;
- **class resource** — for example Mana, Rage, or another class-specific mechanic.

These resources do not have to be distributed like normal attributes. Their values may depend on level, class, primary attributes, equipment, abilities, or other systems.

## Secondary Combat Stats

The current secondary combat-stat set is deliberately compact and is divided into defensive and offensive stats.

### Defensive stats

- **Health** — determines how much damage the combatant can survive before being defeated;
- **Armor** — reduces incoming physical damage;
- **Dodge** — allows an incoming attack to be avoided entirely;
- **Fire Resistance** — reduces incoming fire damage;
- **Cold Resistance** — reduces incoming cold damage;
- **Lightning Resistance** — reduces incoming lightning damage;
- **Block** — represents the combatant’s ability to block an incoming attack when the current equipment or combat setup allows blocking.

Health remains a hero combat resource, but bonuses to maximum Health are also treated as part of the defensive combat-stat layer when resolving equipment and other stat sources.

The three elemental resistances use the same diminishing-return model as Armor:

`Final Damage = Raw Damage × 100 / (100 + Resistance)`

Resistance values cannot be negative. Damage reduction from any single elemental resistance is capped at **75%**.

The exact Block formula and its interaction with different attack types will be defined separately.

### Offensive stats

- **Damage** — the base strength of attacks or damaging actions before relevant mitigation;
- **Accuracy** — reduces the target’s effective chance to avoid an eligible attack through Dodge;
- **Critical Chance** — determines the chance that an eligible hit becomes a critical hit;
- **Critical Damage** — determines how much additional damage a critical hit deals;
- **Attack Speed** — affects the speed or frequency of weapon attacks;
- **Cast Speed** — affects the speed of spell casting and other actions explicitly treated as casts.

These stats may be derived from primary attributes, class, equipment, abilities, temporary effects, and other valid sources.

The current list is the working base set. Additional secondary stats should be introduced only when they create a clear gameplay purpose rather than unnecessary complexity.

### Accuracy and Dodge

Accuracy and Dodge use **one shared hit-resolution check**. The game does not first roll a separate chance to miss and then make an additional independent Dodge roll for the same attack.

If the target has **0 Dodge**, an otherwise eligible ordinary attack has a **100% chance to hit**. Accuracy cannot increase hit chance above 100%; its purpose is to counter the target’s Dodge.

When the target has Dodge, the current working formula is:

`Dodge Chance = Dodge / (Dodge + Accuracy + 100)`

The corresponding chance to hit is:

`Hit Chance = 1 - Dodge Chance`

The same formula applies to the hero and to enemies.

Examples:

| Accuracy | Dodge | Dodge Chance | Hit Chance |
| ---: | ---: | ---: |
| 100 | 0 | 0% | 100% |
| 100 | 50 | 20% | 80% |
| 100 | 100 | 33.3% | 66.7% |
| 200 | 50 | 14.3% | 85.7% |
| 200 | 100 | 25% | 75% |

Dodge Chance is capped at **50%**. No amount of Dodge can make ordinary eligible attacks less than 50% likely to hit under this base rule.

This model intentionally gives both stats diminishing returns. Every positive amount of Dodge has some effect against an attacker, while Accuracy continuously reduces that effect instead of creating a hard threshold where Dodge provides no benefit until it exceeds Accuracy.

> **Dodge creates a chance to avoid attacks; Accuracy counters Dodge rather than creating hit chance above 100%.**

## Sources of Permanent Hero Power

The hero’s permanent combat strength comes from several main sources:

1. **level and attributes**;
2. **class, abilities, and their development**;
3. **equipment**;
4. **specialization and acquired combat traits**.

The relative importance of these sources may change over the course of the hero’s development. Early on, level and basic attributes may matter more, while later equipment, abilities, specialization, and individual traits may become increasingly important.

Temporary effects, consumable items, and divine assistance may strongly influence a particular fight, but they are not considered part of the hero’s permanent power.

> **The hero’s strength should reflect more than a single level number; it should reflect the path of their development.**

The exact contribution of each source may change during development and balance work.

## Two Stages of Hero Development

Hero progression is provisionally divided into two broad stages. These are not two rigid game modes and there is no moment when the “real world” suddenly unlocks. The world exists from the beginning, while the transition between stages happens gradually as the hero develops.

### Stage 1 — Formation

Early in the game, level and basic attributes are among the hero’s main sources of power.

During this period, the hero:

- gains levels relatively quickly;
- noticeably increases primary attributes;
- gradually reveals personality and preferences;
- gains and changes traits;
- learns the core abilities of the class;
- reaches the first and then the final specialization tier;
- uses equipment, although equipment is not yet the primary source of progression.

From the beginning, the world contains areas that are naturally appropriate for a young hero: safer cities, surroundings, and available activities. These are not isolated “starting zones.”

The hero is formally able to travel anywhere, but when choosing a direction they consider their own strength, known threats, available activities, possible rewards, and whether the journey makes sense.

A weak hero therefore usually prefers places where they can reasonably survive and find suitable things to do.

Enemies should not automatically scale with the hero. As the hero becomes stronger, they should genuinely outgrow former threats.

### Stage 2 — Maturity

Once the hero is largely formed and approaches the soft cap of development, ordinary levels gradually become less significant.

Level and attributes may continue to grow, but more slowly and should no longer be the primary source of increasing power.

The world does not unlock again at this point — the hero simply becomes strong and experienced enough that opportunities that were previously too dangerous become practically relevant.

During maturity, greater importance may shift toward equipment, rare items, abilities, specialization, combat traits, preparation for specific threats, and the hero’s participation in more serious world events.

> **Early on, the hero is primarily becoming stronger. Later, what matters increasingly is who the hero has become, what they possess, and what kind of world they live in.**

The exact pace of progression beyond the current soft cap remains a balance question.

## Soft Cap

The current working soft cap is **level 100**.

Reaching level 100 does not end progression and does not create a hard maximum level. The hero may continue gaining levels afterward, but post-100 level progression should become **much slower** than progression during the formation stage.

The exact interaction between the level-100 soft cap and late skill-rank progression is **deliberately not fixed at the concept stage**. Level 100 should therefore not currently be interpreted as a hard rule that all existing skills immediately stop improving.

Later prototyping may decide that final-specialization skills gain upgrade opportunities at a different post-100 pace, that gold cost becomes the stronger limiting factor, that the soft-cap level itself changes, or that another simple rule works better. Those are balance decisions rather than requirements of the current concept.

The purpose of the soft cap is not to stop hero development. It is to shift the main source of interest away from ordinary level growth toward equipment, the completed specialization path, skill mastery, combat traits, preparation for specific threats, and the hero’s participation in the living world.

A possible later layer may further improve each final specialization without creating additional branches, but this is not part of the currently defined progression structure.

The early stage should not feel like a long tutorial before the “real game.” World events and larger processes exist from the beginning; a young hero simply has far less ability to affect them.

> **Level 100 is the current working formation soft cap, not a hard ceiling for every progression subsystem.**

## Enemies Do Not Automatically Scale to the Hero

The combat strength of ordinary enemies should **not increase simply because the hero’s level or Power has increased**.

If the hero becomes much stronger than wolves, bandits, or other early threats, they should genuinely outgrow them. An old enemy should not silently become a much stronger version merely to preserve the same relative difficulty.

More dangerous combat should instead come from things such as:

- more dangerous regions;
- different enemy types;
- elite enemies and bosses;
- more demanding mechanics;
- world events;
- wars and invasions;
- temporary changes in local danger.

A familiar region may still become more dangerous when the **world itself changes** — for example because of an invasion or major event. That is different from secretly adjusting enemy stats to match the hero.

This principle is important to the feeling of progression: an enemy that once posed a serious threat may later become easy because the hero has genuinely grown beyond it.

> **Hero growth should change the hero’s place in the world, not force the entire world to grow invisibly alongside them.**

The distribution of enemy strength across regions and changing world conditions belongs to the world-map and world-simulation systems.

## Shared Power for Hero and Enemies

The hero and enemies use **one shared Power system** for estimating combat strength.

Power is not an independent stat that directly makes a combatant stronger. It is a summary estimate calculated from that combatant’s **resolved real combat stats**.

Conceptually, the flow is:

> **stat sources → resolved Combat Stats → shared Power calculation → Power**

The hero and ordinary enemies should pass through the same principle of calculation so their strength remains comparable on one scale.

Power is primarily useful for quick relative danger assessment, such as determining whether:

- the hero is clearly stronger;
- the two sides are roughly comparable;
- the enemy is clearly stronger.

Power does **not guarantee the outcome of a fight** and does not replace combat simulation itself.

Two combatants with similar Power may perform differently against one another because of:

- specific abilities;
- class mechanics;
- enemy-specific mechanics;
- combat traits;
- current condition and remaining resources;
- other situational factors.

Stats from equipment, class, permanent progression, temporary effects, and other sources must feed into the resolved Combat Stats before Power is calculated. They should **not then be added again as separate Power bonuses** if their effect is already represented in those final stats.

The exact Power formula may change as the combat system develops, but the principle remains stable:

> **The hero and enemies should be measured with the same ruler, based on their real combat capabilities.**

### Provisional Full-Game Warrior Power Model

The current working full-game baseline for the Warrior preserves the existing structural idea:

`Power = sqrt(EffectiveHP × EffectiveDPS)`

This is a **design model for future combat**, not a change to the currently implemented Prototype 0 calculator. Its purpose is to establish how the expanded combat-stat set can contribute to one comparable Power number.

Primary attributes are not added directly to Power. Strength, Dexterity, Constitution, equipment, and other sources first modify resolved combat stats; Power is then calculated from those resolved stats. This prevents the same source from being counted twice.

#### Offensive side

For a physical Warrior, the base expected damage output is:

`CritModifier = 1 + CritChance × (CritDamage - 1)`

`RawDPS = PhysicalDamage × (AttackSpeed / 2) × CritModifier`

Accuracy cannot be evaluated in isolation because its actual combat value depends on the target’s Dodge. For a universal Power estimate, the current working model therefore evaluates Accuracy against a **reference target with 50 Dodge**.

Reference hit chance is calculated using the normal Accuracy/Dodge formula:

`ReferenceHitChance = 1 - 50 / (50 + Accuracy + 100)`

At `Accuracy = 0`, that reference hit chance is `0.6667`. To ensure that zero Accuracy does not reduce the character below the baseline Power model, Accuracy is normalized against that value:

`AccuracyFactor = ReferenceHitChance / 0.6667`

Equivalent form:

`AccuracyFactor = 1.5 × (Accuracy + 100) / (Accuracy + 150)`

Examples:

| Accuracy | AccuracyFactor |
| ---: | ---: |
| 0 | 1.000 |
| 50 | 1.125 |
| 100 | 1.200 |
| 200 | 1.286 |

As Accuracy approaches extremely high values, this factor approaches `1.50`, giving Accuracy diminishing returns in the universal Power estimate.

The provisional offensive term is therefore:

`EffectiveDPS = RawDPS × AccuracyFactor`

#### Defensive side

Dodge also depends on an opponent’s Accuracy. For the universal Power estimate, the current working model evaluates Dodge against a **reference attacker with 100 Accuracy**.

`ReferenceDodgeChance = Dodge / (Dodge + 100 + 100)`

The normal `50%` Dodge cap still applies.

Dodge increases effective survivability through:

`DodgeEHPFactor = 1 / (1 - ReferenceDodgeChance)`

Examples:

| Dodge | Reference Dodge Chance | DodgeEHPFactor |
| ---: | ---: | ---: |
| 0 | 0% | 1.00 |
| 50 | 20% | 1.25 |
| 100 | 33.3% | 1.50 |
| 200 | 50% | 2.00 |

Armor and elemental resistances cannot be valued as if every enemy dealt the same damage type. For the universal Power estimate, the current working **reference incoming-damage mix** is:

- **70% physical**;
- **10% fire**;
- **10% cold**;
- **10% lightning**.

These percentages are tuning values, not permanent world rules. They exist only to give the universal Power calculation a stable reference environment and must later be tested against the actual distribution of enemies and damage types.

For each damage type, calculate the fraction of damage that remains after the relevant defense:

`PhysicalTaken = 100 / (100 + Armor)`

`FireTaken = 100 / (100 + FireResistance)`

`ColdTaken = 100 / (100 + ColdResistance)`

`LightningTaken = 100 / (100 + LightningResistance)`

Elemental-resistance caps defined elsewhere still apply. If the final Armor mitigation rule or cap changes later, `PhysicalTaken` must follow that final Armor rule rather than creating a separate Power-only Armor formula.

The weighted reference damage taken is:

`AverageDamageTaken = 0.70 × PhysicalTaken + 0.10 × FireTaken + 0.10 × ColdTaken + 0.10 × LightningTaken`

The provisional defensive term is:

`EffectiveHP = MaxHealth / (AverageDamageTaken × (1 - ReferenceDodgeChance))`

This makes Health, Armor, Dodge, and elemental resistances contribute through expected survivability instead of being converted into arbitrary flat Power points.

#### Final provisional Warrior Power

The current working formula is therefore:

`WarriorPower = sqrt(EffectiveHP × EffectiveDPS)`

where:

`EffectiveDPS = PhysicalDamage × (AttackSpeed / 2) × CritModifier × AccuracyFactor`

and:

`EffectiveHP = MaxHealth / (AverageDamageTaken × (1 - ReferenceDodgeChance))`

Block is **not yet included** because its exact combat formula and eligible attack types have not been defined. Warrior abilities and Wisdom-based ability scaling are also not given an arbitrary separate Power bonus at this stage; they should enter Power only after their real combat effects can be represented consistently.

#### Universal Power vs. specific matchup strength

This Power value represents the character’s **general combat strength**, not a prediction against one specific opponent.

A character with very high Fire Resistance may gain only a moderate amount of universal Power because fire is only part of the reference damage mix, while being dramatically stronger in practice against a fire-focused enemy. Likewise, Accuracy may be much more valuable against a particularly evasive target than the universal Power number suggests.

A future matchup or threat assessment may use the real opponent’s Accuracy, Dodge, damage types, resistances, abilities, and other relevant properties. That calculation should remain separate from the character’s universal Power value.

The reference values currently used by the universal model — **50 reference Dodge, 100 reference Accuracy, and the 70/10/10/10 incoming-damage mix** — are provisional tuning parameters. They must be validated through large batches of automated fights. If equal or similar Power does not correspond to roughly comparable actual general combat strength, these reference values or the formula itself must be revised.

## Class Must Change Combat Logic

Differences between classes should not be reduced only to weapons or slightly different damage numbers.

Warrior, Archer, Mage, and Rogue should fight differently and use different ways to solve combat situations.

A class should define:

- the hero’s primary tools in combat;
- characteristic abilities;
- a key combat mechanic;
- typical decisions and priorities during a fight.

Ideally, the combat log alone should make the hero’s class roughly recognizable even if the class name itself is hidden.

> **Class defines not only the hero’s power, but the logic of how they fight.**

The exact mechanics of each class will be designed separately.

## Basic Class Kit

Each base class should have its own distinctive combat mechanic and a deliberately small set of characteristic abilities.

The current class-progression structure is:

- **one primary unique class mechanic**;
- **two base-class abilities**;
- the first base-class ability unlocks at **level 10**;
- the second base-class ability unlocks at **level 20**.

The unique mechanic does not have to be represented by a separate resource bar.

A separate artificial resource should not be created for every class merely for the sake of symmetry.

Later specialization tiers each add one additional ability along the hero’s chosen path, so a fully formed level-90 hero currently has four main class-path abilities in total: two from the base class, one from the first specialization, and one from the final specialization.

## Skill Levels and Paid Skill Upgrades

Every learned combat ability has its own **Skill Level**.

When an ability is first learned, it begins at:

> **Skill Level 1**

The current working maximum is:

> **Skill Level 10**

Hero level does not automatically raise a learned ability. Instead, hero progression periodically opens the **possibility** of purchasing another Skill Level.

The current working cadence is:

> **one additional skill-upgrade opportunity for each five hero levels of progression associated with that ability, until Skill Level 10 becomes reachable.**

Reaching the relevant hero-level milestone therefore raises the maximum rank the ability is currently allowed to reach; the actual upgrade still requires the hero to pay for it.

Skill upgrades cost **gold**. The price rises with each higher Skill Level so that skill mastery becomes an increasing economic investment rather than a free side effect of leveling.

Exact prices, price growth, whether different skill families use different prices, and the detailed post-100 cadence are balance questions for prototyping.

A specialization ability cannot exist before the hero actually owns the required specialization. Merely reaching level 50, level 90, or even a much higher hero level does not grant an ability from a subclass whose Specialization Quest has not been completed.

If a specialization is obtained later than its normal ability milestone, the corresponding specialization ability becomes available only after the specialization itself is granted. The exact handling of any skill-rank upgrade opportunities that might otherwise have occurred during the delay is deliberately left for implementation/balance rather than being fixed in the concept.

Wisdom and Skill Level are separate forms of improvement:

- **Skill Level** is the purchased rank of the ability, capped by progression milestones and paid for with gold;
- **Wisdom** continuously improves the ability through that ability’s own defined Wisdom scaling.

> **Level progression creates opportunities to master a skill; gold pays for mastery; Wisdom changes how effectively the hero performs the skill.**

### Current Working Warrior Base Kit

The Warrior is the first class for which the initial combat kit is defined at a conceptual level.

The Warrior’s core class resource is **Rage**. Rage represents combat momentum and is built during fighting through offensive action and through taking damage. The exact maximum Rage, generation amounts, decay rules, and ability costs are intentionally left for prototyping and balance.

The two current base abilities are:

- **Level 10 — Power Strike:** a strong weapon attack that spends Rage to deal meaningfully more damage than an ordinary attack. It is intended to work across the normal Warrior weapon setups rather than belonging to one later specialization.
- **Level 20 — Battle Guard:** a defensive Rage-spending ability that temporarily reduces incoming danger or damage. It does **not** require a shield, allowing every future Warrior path to retain a basic defensive tool.

This creates a simple autonomous resource decision even before specialization: the Warrior may spend accumulated Rage offensively through Power Strike or preserve/spend it defensively through Battle Guard when survival becomes more important.

No exact damage multiplier, Rage cost, mitigation amount, duration, cooldown, Wisdom scaling, or trigger threshold is fixed at the concept stage.

> **The basic Warrior should already choose between converting combat momentum into offense or using it to survive.**

## Automatic Ability Use

The player does not manually activate the hero’s combat abilities.

The hero decides autonomously when and which available ability to use.

The decision may be influenced by:

- the current combat situation;
- the hero’s health;
- available class resource;
- enemy strength and type;
- the hero’s own assessment of their chances of victory;
- personality and attitude toward risk;
- the need to conserve resources for the rest of the journey.

The hero should not use abilities merely in a mechanical rotation or immediately whenever a cooldown ends. Ability use should depend on the situation and the logic of that specific hero.

> **The class defines the tools available to the hero, while the hero’s state, experience, and personality influence how those tools are used.**

The exact ability-selection rules and weighting of these factors will be defined separately and may change during development.

## Hero Specialization

Each base class currently has a **two-tier branching specialization structure** during the hero’s formation stage.

Reaching a specialization level does **not** automatically transform the hero into a new subclass. The level milestone makes a new class path available; the hero first determines which branch fits them and then must complete a dedicated long-term **Specialization Quest**. The new specialization is granted only after that quest is completed. The quest and its special dungeon are defined in `Quest_and_Activity_System_Design_v0.1.md`.

Once a specialization has actually been obtained, it is **permanent**. The current design does not allow respecialization, resetting the subclass choice, or switching to the sibling branch later. The specialization is part of the hero’s history and long-term identity.

### First Specialization Tier — Level 40

At **level 40**, the base class opens **two first-tier specialization paths**.

The hero autonomously determines which of the two paths they are moving toward. After that direction is selected, the corresponding Specialization Quest becomes the long-term requirement for actually gaining the subclass.

Once the quest is completed and the first specialization is received, the hero immediately gains the specialization’s **+5 profile attribute points**, receives any accumulated delayed specialization-growth points defined above, and then continues gaining the specialization’s `+1` directed point through later hero-level progression.

At **level 50**, the progression structure contains **one ability belonging to the chosen first-tier specialization**. This ability appears only if the hero actually owns that specialization. If the hero reaches level 50 or higher while the Specialization Quest is still unfinished, the ability remains unavailable until the specialization is finally obtained.

### Final Specialization Tier — Level 80

At **level 80**, the hero’s chosen first-tier path opens **two possible final specializations**.

The hero again determines which branch best fits who they have become, after which the corresponding long-term Specialization Quest must be completed before the final specialization is actually granted.

Because each of the two first-tier paths has two final branches, every base class currently has **four possible final specialization outcomes**.

Once the quest is completed and the final specialization is received, the hero immediately gains the specialization’s **+10 profile attribute points**, receives any accumulated delayed final-specialization growth defined above, and then continues gaining the additional final-specialization-directed point through later hero-level progression.

At **level 90**, the progression structure contains **one ability belonging to the chosen final specialization**. As with the first tier, the hero gains no final-specialization ability until the required specialization itself has actually been obtained, regardless of how high the hero’s level has become.

The current class-path structure is therefore:

```text
Base Class
├─ Specialization Path A [available from 40]
│  ├─ Final A1 [available from 80]
│  └─ Final A2 [available from 80]
└─ Specialization Path B [available from 40]
   ├─ Final B1 [available from 80]
   └─ Final B2 [available from 80]
```

and the current ability/progression milestones are:

- **level 10:** base-class ability 1;
- **level 20:** base-class ability 2;
- **level 40:** first specialization paths become available; the hero chooses a direction and receives its Specialization Quest;
- **after completing the first Specialization Quest:** first specialization is granted, with the immediate `+5` profile-stat bonus, any accumulated delayed specialization points, and its ongoing directed-growth component;
- **level 50:** first-specialization ability milestone, provided that specialization has actually been obtained;
- **level 80:** the chosen first path branches into two final paths; the hero chooses a direction and receives its next Specialization Quest;
- **after completing the final Specialization Quest:** final specialization is granted, with the immediate `+10` profile-stat bonus, any accumulated delayed final-specialization points, and its additional ongoing directed-growth component;
- **level 90:** final-specialization ability milestone, provided that specialization has actually been obtained;
- **level 100:** current working soft cap / main formation milestone, with post-100 skill progression still intentionally open for later tuning.

A specialization should continue the original archetype rather than abruptly turning the hero into a fundamentally different class. Each tier should make the chosen path increasingly recognizable through its stat direction, abilities, equipment tendencies, and possible changes to the class’s core mechanic.

### How the Hero Chooses a Specialization

The specialization choice should be **autonomous but understandable**. It should emerge from who the hero has become rather than from a random roll or direct player selection.

The current conceptual inputs are deliberately kept small:

- the hero’s **personality / character tendencies**;
- the hero’s **actual primary-attribute profile**;
- potentially a **soft divine direction** from the player.

Personality and attributes should not be treated as completely independent evidence and blindly added at full weight. The hero’s attributes are already partly the result of their autonomous development, which itself is influenced by personality and preferences. The final selection method should therefore avoid effectively counting the same underlying tendency twice.

For now, **lived combat experience is not a separate specialization-choice factor**. It may be reconsidered only if later design or testing shows that it adds meaningful information that is not already represented by character and development.

The deity may be allowed to nudge the hero toward one of the available paths, but this should remain a soft influence rather than a direct subclass-selection button.

The player should eventually receive enough information about possible future paths for divine guidance to be meaningful rather than a blind guess. The exact level at which potential specializations become visible, how strongly they are previewed, and how the UI presents the hero’s current inclination remain open design questions.

> **A specialization choice should feel inevitable in hindsight without being manually predetermined in advance.**

### Current Working Warrior Specialization Tree

The Warrior is the first class used to test the specialization structure.

The current working tree is:

```text
Warrior
├─ Protector [40]
│  ├─ Paladin [80]
│  └─ Guardian [80]
└─ Slayer [40]
   ├─ Berserker [80]
   └─ Champion [80]
```

#### Protector — First Defensive Specialization

**Protector** is the Warrior’s first-tier defensive/protective specialization.

Its current conceptual identity is:

- profile stat direction: primarily **CON**;
- combat equipment identity: **one-handed weapon + shield**;
- general combat direction: durability, protection, control, and making the shield an active part of combat rather than only a passive stat source.

Protector and its later branches are intended to use their specialization abilities only while the hero has the appropriate **one-handed weapon + shield** setup. The base Warrior may still understand other Warrior weapon families, but an incompatible setup does not provide access to Protector-specific combat tools and therefore should not normally be attractive to the autonomous equipment-selection logic of a Protector-path hero.

At **level 50**, Protector gains **Shield Bash**:

- requires a shield and an appropriate Protector weapon setup;
- combines a shield attack with a control effect;
- may disrupt, delay, stagger, or later interrupt an eligible enemy action depending on the final combat implementation;
- exact damage, control duration, cooldown, Wisdom scaling, and interaction rules are not fixed yet.

Protector later divides into:

- **Paladin** — the defensive path that combines shield-based durability with self-healing / holy-supportive tools;
- **Guardian** — the heavier pure-defense path focused on a large or tower-style shield, Block, Armor, Health, and maximum durability.

The final level-90 abilities of Paladin and Guardian are intentionally left for later design.

#### Slayer — First Offensive Specialization

**Slayer** is the Warrior’s first-tier offensive specialization.

Its current conceptual identity is:

- profile stat direction: primarily **STR**;
- combat equipment identity: **no shield**;
- supported weapon directions: a heavy two-handed weapon or two one-handed weapons;
- general combat direction: sustained offensive pressure and turning combat momentum into increasingly dangerous attacks.

Slayer and its later branches are intended to use their specialization abilities only with a compatible **two-handed or dual-wield** setup. A shield setup therefore does not enable Slayer-specific combat tools and should not normally be selected by the autonomous equipment logic of a Slayer-path hero.

At **level 50**, Slayer gains **Onslaught**:

- performs a powerful weapon attack;
- requires a compatible Slayer weapon setup;
- after the attack, temporarily increases the Warrior’s attack tempo / attack speed for following attacks;
- exact damage, speed increase, duration, cooldown, Rage interaction, Wisdom scaling, and number of affected attacks are intentionally left undefined for prototyping.

Slayer later divides into:

- **Berserker** — the more reckless, rage-driven and risk-tolerant offensive path;
- **Champion** — the more controlled weapon-mastery path emphasizing precision, critical performance and disciplined offense.

The final level-90 abilities of Berserker and Champion are intentionally left for later design.

The four final Warrior paths currently differ as follows:

| Final Warrior path | Primary stat tendency | Character tendency | Combat identity |
| --- | --- | --- | --- |
| **Paladin** | **WIS + CON**, with STR secondary | altruism, mercy, honesty, protective tendencies | one-handed weapon + shield; durable defense combined with self-healing / supportive holy-style tools |
| **Guardian** | **CON + STR** | caution, conservatism, steadiness, low appetite for unnecessary risk | one-handed weapon + large/tower shield; maximum physical durability, Block/Armor/Health focus |
| **Berserker** | **STR + CON** | high risk tolerance, directness, aggression in approach; cruelty is not required | no shield; heavy two-handed weapon or two one-handed weapons; overwhelming offense and rage-like pressure |
| **Champion** | **STR + DEX** | more controlled, calculated and disciplined than the Berserker; mastery over recklessness | offensive weapon specialist; two-handed or dual-wield setup, precision, critical performance and weapon mastery |

At the first specialization tier, the broad split should follow the same logic rather than a single hard stat check:

- **Protector** is naturally supported by stronger CON and protective/cautious character tendencies, with WIS or STR helping determine the later Paladin/Guardian direction;
- **Slayer** is naturally supported by stronger STR and greater willingness to take risks, with DEX, CON and character differences helping determine the later Champion/Berserker direction.

These are **conceptual affinities, not final formulas or thresholds**. A high CON value alone should not automatically force Guardian, and a high STR value alone should not automatically force Berserker. The final choice should reflect the combination of the hero’s character and the development that character has produced.

In particular, Berserker is not defined as an evil or cruel Warrior. A kind hero may still become a Berserker if their combat-development direction is highly aggressive and risk-tolerant. Moral traits should be used only where they genuinely distinguish the fantasy of one path from another.

A possible future progression layer may further improve each of the four final specializations without another branching choice. That possibility is deliberately left undefined for now.

> **The player chooses the starting class; the hero’s development progressively determines which of that class’s four final paths they become.**

## Base Starting Classes

The current set of starting classes consists of four archetypes:

- **Warrior**;
- **Archer**;
- **Mage**;
- **Rogue**.

This set is sufficient as the game’s current base class structure. The current design work intentionally defines only the Warrior’s initial base kit and first-tier specialization abilities. The final Warrior specialization abilities and the detailed abilities, resources, and specialization trees of Archer, Mage, and Rogue will be designed later rather than being invented prematurely.

When developing each class further, it should be checked against these questions:

1. How is its combat logic different?
2. What does it usually do at the beginning of a fight?
3. How does its behaviour change if the fight drags on?
4. What resource, state, or condition causes it to change tactics?
5. Can the class be recognized from the combat log without seeing its name?

> **Each class should feel like a distinct way of fighting, not a different set of numbers and a different weapon image.**

## Possible Group Content — Future Hypothesis

In the future, the game may consider difficult activities in which the main hero temporarily joins other autonomous NPC heroes.

These could include especially difficult dungeons, raids, or other events that are hard for one hero to handle alone.

Such content could potentially make class differences and combat roles more meaningful while also creating relationships, shared history, rivalry, or other connections between heroes.

However, a permanent party, control over other heroes, and group content are **not part of the confirmed core game** and must not be required for the basic gameplay loop.

> **The game must first work and remain interesting around one autonomous hero.**

This idea is not a commitment for early versions and may be revised or discarded entirely later.

## Base Combat Model

Combat is an important part of the hero’s journeys, but it is not the project’s primary gameplay core.

The main focus is hero development, decisions, personality, fate, and the world’s influence on the hero’s life. Combat creates risk, victories, defeats, progression, and events that can affect the hero’s later story.

Therefore, the base combat system should be:

- automatic;
- understandable;
- varied enough to distinguish classes and opponents;
- but not overloaded with micromanagement or excessive complexity.

### Combat Format

The base format is a **1v1 fight**.

The hero and opponent each have a speed value that affects how frequently they can act.

Combat does not have to follow a strict alternating sequence:

> hero → opponent → hero → opponent.

A faster participant receives opportunities to act more frequently.

The exact speed and action-frequency formulas will be defined separately. Speed should not create absurd situations where one participant takes a huge number of actions in a row without allowing the other side to respond.

### Auto-Attack

The hero’s default action is an **automatic normal attack**.

If there is no reason to use another action, the hero attacks the opponent normally without player input.

### Abilities

When appropriate, the hero may autonomously use a class ability instead of a normal attack.

Abilities may be limited by:

- cooldowns;
- class resources;
- situational requirements;
- compatible weapon/equipment requirements for specialization-specific abilities;
- a combination of several simple conditions.

There is no need to create an elaborate separate AI system for every individual ability.

The hero should use abilities in a way that is **reasonably logical and understandable**, but does not need to play with mathematically perfect optimization.

### Class Resources and Mechanics

Different classes may build their combat logic around different mechanics.

The current Warrior uses **Rage** as its working class resource, building combat momentum during fighting and spending it on class abilities. Other classes may use different resources, states, or combat rules; for example, the Mage may use Mana.

A separate resource bar is not required for every class.

### Item Use

The hero may autonomously use appropriate consumable items, such as healing potions.

An item should be used when the situation genuinely calls for it.

As a rule, using an item counts as a separate action and should not be added for free to a normal attack.

### Player Role in Combat

The player does not directly control the hero’s attacks or abilities.

The deity may provide only limited assistance, such as:

- healing the hero;
- temporarily empowering the hero;
- later, using other rare forms of intervention.

The hero should be capable of winning ordinary fights independently.

Player assistance primarily allows the player to:

- help the hero survive more fights without prolonged recovery;
- rescue the hero from an especially unlucky situation;
- help against a stronger opponent;
- improve the chance of success in an important or risky adventure.

Divine assistance should not be mandatory in every fight.

> **The player does not win the fight instead of the hero — they only occasionally help the hero exceed their ordinary limits.**

### Complexity Limit

At the base level, combat should not be overloaded with complicated formulas, dozens of effects, huge ability sets, or excessively detailed tactical AI.

The combat system should first prove that it is:

- easy to read;
- capable of genuinely differentiating classes;
- capable of creating risk;
- functional without player micromanagement;
- supportive of the larger game about the hero’s life and fate.

Additional depth should be added only when it genuinely makes the game more interesting.

## Combat Traits

Combat traits are separate from the hero’s general personality and emerge from combat experience.

They can reflect both positive and negative experience, such as growing confidence against certain threats or fear after severe defeats.

A combat trait should come from repeated or especially meaningful experience rather than appearing randomly after one ordinary fight.

Combat traits may strengthen, weaken, or disappear over time as the hero’s later experience changes.

> **Combat traits should become part of the hero’s story, not simply an ever-growing list of modifiers.**

The exact scale, categories, thresholds, and effects of combat traits will be defined separately.

## Combat Trait Persistence — Possible Later Extension

A combat trait reinforced for a long time may become more deeply rooted and require stronger opposite experience to weaken or remove.

This is a possible later extension, not a required part of the base system.

## Death Is a Defeat, Not the Loss of the Hero

Hero death is not permanent and does not erase long-term development.

After death, the hero may lose the current expedition, time, and part of temporarily acquired resources, but the hero themselves and their main story continue.

> **Death should be a meaningful defeat, but it should not erase a character the player may have been following for dozens of hours.**

## What Is Preserved After Death

Death should not roll back the hero who has already been formed.

After resurrection, the hero keeps:

- overall level and permanent progression;
- class, abilities, specialization, and purchased Skill Levels;
- personality, preferences, and permanent traits;
- reputation and persistent relationships;
- hero history and biography;
- equipped gear and other permanent equipment.

Death interrupts the **current adventure**, but does not erase who the hero has become.

> **The hero’s long-term story survives their defeats.**

## What May Be Lost After Death

Death should primarily punish the failure of the **current adventure** rather than take away accumulated long-term progress.

The hero may lose:

- loot and trophies that have not yet been safely delivered;
- the current quest or expedition;
- a temporary opportunity associated with that adventure;
- potentially part of carried gold, if later testing shows that this meaningfully improves risk and balance.

Equipped gear and other permanent equipment are not lost on death.

The hero is not expected to return to the death location to recover a corpse or retrieve lost items.

Exact loss amounts and rules will be determined later.

> **Death puts the current loot and adventure at risk, not the life the hero has already built.**

## Resurrection Location

After natural resurrection, the hero returns to life in a **safe location** rather than directly at the place where they died.

This may be:

- the nearest appropriate city;
- a temple;
- another logical safe location.

The exact return location may depend on where the death occurred and which safe points are available to the hero.

The design does not currently require a universal rule such as “always the nearest city” or “always a temple”; this should be defined together with the world map and travel systems.

> **Death ends the failed expedition and returns the hero to a safe part of their life.**

## Natural Resurrection

If the player does not intervene, the hero **returns to life automatically after a period of time**.

While the hero is dead:

- the hero’s own activity is paused;
- the world continues to live and change while the game is running;
- events and opportunities may pass without the hero’s participation.

The exact resurrection delay is a balance parameter and is not fixed at this stage.

> **Death temporarily removes the hero from the world, but does not pause the world itself.**

## Migration note

Prototype formulas are not automatically treated as final full-game balance.