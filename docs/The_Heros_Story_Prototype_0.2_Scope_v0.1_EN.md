# The Hero’s Story — Prototype 0.2 Scope

**Status:** working specification for Prototype 0.2  
**Document version:** 0.1  
**Primary goal:** expand the original Proof of Fun into the first small but complete early-game vertical slice of the autonomous hero’s life.

---

## 0. Source-of-Truth Rule for Prototype 0.2

This document is intended to be the **primary working specification for building Prototype 0.2**.

A developer or AI working on Prototype 0.2 should normally need only:

1. this document;
2. the current repository and code state.

The modular documents in `docs/design/` are secondary references. They should be consulted only when this Scope explicitly leaves a question open, when additional design context is genuinely needed, or when a future-facing architectural decision must be checked.

The previous Prototype 0 / Prototype 0.1 Scope is **not required reading** for implementation of Prototype 0.2. All rules that remain relevant should be restated here.

If the current code contains an experimental implementation that conflicts with this Scope, the current code is **not automatically authoritative**. Experimental equipment, inventory, UI, tuning, or other systems may be replaced when they no longer match the current design.

For Prototype 0.2 the priority order is:

> **this Scope → current approved modular design when this Scope is silent → current repository implementation → older Prototype documents and historical discussion**

This Scope must therefore become increasingly self-contained as its systems are finalized.

**Before implementation of any concrete Prototype 0.2 system begins, that system’s behavior must be described in this Scope clearly enough that normal implementation should not require reading the modular design documents or older discussions.**

---

## 1. Main Question of Prototype 0.2

Prototype 0.2 asks:

> **Is it interesting to follow one autonomous hero through the first meaningful stage of their life, as lived experience gradually shapes their personality, combat style, development, equipment, and first specialization, creating a hero with recognizable behavior, history, and gameplay profile?**

A second important question is:

> **Can a small world of two connected cities, changing quests, travel events, dungeons, loot, and economy create enough changing circumstances for the hero’s autonomous life to remain interesting without requiring the full future world simulation?**

A third important test is:

> **Can the player return after being away from the game for a long period, look at the hero and the diary, and feel that a meaningful part of the hero’s life happened while they were away rather than merely seeing larger numbers?**

Prototype 0.2 remains focused on the project’s core fantasy:

> **The hero lives. The world creates circumstances. The player guides.**

The player does not directly control movement, quest choice, equipment choice, attacks, ability use, shopping decisions, or specialization. The player observes, understands, and softly influences the hero while retaining a limited set of direct divine interventions.

Prototype 0.2 is not intended to implement the full game. It is the first version where the early life of the hero should feel like a coherent small RPG simulation rather than a collection of isolated prototype systems.

---

## 2. What Prototype 0.2 Must Cover

Prototype 0.2 must include, at minimum:

- one autonomous hero;
- one starting class: **Warrior**;
- progression from approximately level 1 through **level 50–60**;
- five primary attributes;
- the agreed secondary combat-stat framework relevant to the Warrior and current enemies;
- two base Warrior abilities;
- two first-tier Warrior specializations: **Protector** and **Slayer**;
- one specialization ability for each first-tier specialization;
- autonomous first-specialization choice and a specialization quest;
- two cities: a starting city and a mid-level city;
- a small authored hex map covering both cities and their surrounding areas;
- travel between cities and to local activities;
- changing city quest offers;
- approximately **10–15 ordinary quest templates per city**;
- no more than approximately **5–6 simultaneously active ordinary quest offers per city**;
- quest offer expiration and replacement;
- approximately **15–20 handcrafted temporary events total** across the two-city world;
- a working personality system with several opposing trait axes and real trait development;
- two ordinary dungeons associated with each city / local region;
- dedicated authored Specialization Dungeon content for both **Protector** and **Slayer**, activated as part of the corresponding Specialization Quest and sharing one technical dungeon system;
- item level, item rarity, random modifiers, loot sources, and autonomous equipment evaluation;
- rarity through **Epic / Purple**;
- a complete early equipment loop including weapons, armor, jewelry/utility, Belt, and Off Hand;
- at least **5–6 visual armor families / sets**;
- no mechanical set bonuses in Prototype 0.2;
- QuestLoot / carried adventure loot;
- inventory / backpack support;
- equipment and stat recalculation;
- a minimal but working economy;
- buying and selling;
- limited changing shop stock;
- healing potions and dungeon preparation;
- paid Skill Level upgrades if the corresponding rank is available;
- a working player-facing hero diary / chronicle;
- a detailed explanatory log and a separate developer debug log;
- initial functional UI for all required screens;
- layered visual equipment on the hero paper doll for the supported visible armor slots;
- persistent save/load of the playthrough.

The exact balance values and content text may still be tuned during implementation, but the ownership and interaction of these systems should not remain ambiguous.

---

## 3. Explicitly Outside Prototype 0.2

Do **not** expand Prototype 0.2 into the complete future game.

The following are outside this Scope unless explicitly promoted later:

- starting classes other than Warrior;
- second-tier / final Warrior specializations at level 80+;
- Paladin, Guardian, Berserker, and Champion as playable specialization tiers;
- full faction simulation;
- faction reputation;
- faction wars;
- changing political borders;
- global threat simulation;
- NPC heroes / autonomous adventurers;
- parties, raids, or group content;
- more than two normal cities;
- full continent simulation;
- procedural world generation;
- crafting;
- repair systems;
- taxes, routine travel fees, or maintenance economy;
- equipment set bonuses;
- Legendary / Orange equipment;
- deity progression;
- full hero biography creation;
- long-term endgame goals;
- retirement / final biography / end-of-life systems;
- offline progression while the application is closed;
- final production art or final UI polish.

Architecture should avoid blocking these future systems, but Prototype 0.2 must not pre-implement them merely because they exist in the broader design.

---

## 4. Simulation and World Time

The game continues to use one shared simulation timeline while the application is running.

Working base pace remains:

> **1 world tick ≈ 10 real seconds at normal speed**

All long-running gameplay timers should primarily use world time rather than separate unrelated clocks.

Pause stops world simulation.

Developer builds must retain accelerated simulation controls sufficient for testing long progression runs. Exact public release speed options are not fixed by Prototype 0.2.

Combat may continue to use a finer internal time scale while the world-tick layer is temporarily frozen during a fight, provided the player can still understand what is happening and intervene when appropriate.

Multi-tick actions such as travel must be represented in a way that allows temporary events to interrupt them and later resume or redirect the hero.

If the application is closed, simulation stops. Prototype 0.2 is **not** an offline-idle game.

---

## 5. Small World Structure

Prototype 0.2 contains exactly two normal cities:

1. **Starting City** — supports early progression and safer ordinary opportunities;
2. **Mid-Level City** — supports stronger activities and becomes increasingly attractive as the hero develops.

The Mid-Level City is not unlocked by an arbitrary level gate. The world may be physically reachable earlier, but the hero should normally remain near the safer city until current strength, known opportunities, goals, personality, and expected value make travel worthwhile.

The two cities are connected by an authored world map using the current **hex-based spatial model**.

Working map principles:

- one authored map for Prototype 0.2;
- no procedural geography generation;
- each city occupies a known hex;
- ordinary quests, dungeons, and temporary events exist at real map locations / hexes rather than abstract distance-only values;
- roads connect the two cities and important local routes;
- all traversable hexes may initially use the same movement cost;
- terrain-dependent movement speed and complex pathfinding are not required unless they become necessary during implementation;
- hidden locations may exist without immediately being known to the hero.

Current scale reference:

> **1 hex ≈ 3 km**

Travel duration is derived from traversed hex steps. The exact number of world ticks per ordinary hex is a balance value to be finalized during implementation; the rule must be shared rather than separately tuned per quest.

The map is an observation and simulation system. The player does **not** click a destination to directly command the hero to walk there.

### Leaving the Current City

The hero normally treats the current city as their local base and chooses ordinary quests, shops, rumours, and other routine activities primarily from that city.

The hero does not constantly compare ordinary quest offers from every city in the world. Travelling to another city / region is a separate autonomous activity.

For Prototype 0.2, the main progression trigger for leaving the current city is:

> **when the current city no longer provides ordinary quests that are meaningfully appropriate for the hero’s current strength and progression, the hero begins looking for new opportunities in another known city / region.**

The exact lower suitability threshold — the point at which a quest becomes too weak or unrewarding for the hero — is not yet fixed and will be defined separately.

Reaching this condition does not instantly teleport the hero or force a move during another activity. The hero finishes the current activity, reaches a normal decision point, then evaluates travelling to another known city.

After arriving, the destination becomes the hero’s new current city context.

---

## 6. Hero and Primary Attributes

Prototype 0.2 uses five primary developable attributes:

- **Strength (STR)**;
- **Dexterity (DEX)**;
- **Intelligence (INT)**;
- **Constitution (CON)**;
- **Wisdom (WIS)**.

The current provisional contribution of one attribute point is:

| Attribute | Working contribution |
| --- | --- |
| STR | +2 physical Damage; +5 percentage points Critical Damage |
| DEX | +10 Accuracy; +2 Dodge; +3 percentage points Critical Chance |
| INT | +2 magical Damage; +20 Mana |
| CON | +20 maximum Health; +1 Armor |
| WIS | improves learned abilities through ability-specific scaling |

**These coefficients are placeholder balancing values only. They were chosen as initial working numbers and are not approved final coefficients. They must be rebalanced against the full level-1-to-60 progression, equipment scaling, enemy progression, and automated combat tests before Prototype 0.2 combat balance is considered final.**

The architectural relationship is fixed even when the numerical coefficients change:

> **Primary Attributes → StatResolver → resolved Secondary Combat Stats → Combat / Power**

Primary attributes themselves are not read directly by combat or added directly to Power when their effect is already represented through resolved secondary stats. The conversion from STR / DEX / INT / CON / WIS into combat-facing values must remain centralized so balancing a coefficient does not require rewriting combat, Power, equipment evaluation, or UI logic.

Prototype 0.2 contains only the Warrior, so magical Damage and Mana are not required to drive the Warrior’s ordinary attacks. INT may still be used by authored event requirements and should remain a real primary attribute rather than being removed from the model.

WIS must have real meaning once Warrior abilities exist. Each ability owns its own Wisdom scaling rather than receiving one universal WIS bonus.

Primary attributes belong to long-term hero development. Standard random equipment modifiers do **not** roll primary attributes; equipment primarily changes secondary combat stats.

---


### Base Critical Damage

Before STR and equipment modifiers are applied, the hero's base Critical Damage is:

> **150%**

STR adds its Critical Damage bonus on top of this base value.

### Starting Primary Attributes

At the beginning of a new Prototype 0.2 game, the Warrior starts with:

- **STR = 5**
- **DEX = 5**
- **INT = 5**
- **CON = 5**
- **WIS = 5**

These values are the hero's base starting primary attributes before later level-up growth, deity-guided points, personality-directed adaptive growth, specialization growth, or other permanent progression is applied.

The starting values are intentionally symmetrical for Prototype 0.2 so that later differences in the hero's profile come from actual development rather than a hidden starting bias.

## 7. Level Progression and Autonomous Attribute Growth

Prototype 0.2 should support meaningful progression through approximately level 50–60.

The player does not manually distribute every attribute point.

Before the first specialization is obtained, the Warrior gains:

> **5 primary-attribute points per level = 1 fixed Warrior point + 3 adaptive hero-development points + 1 deity-guided point**

### Fixed Warrior Growth

One point per level is the permanent class-directed Warrior contribution:

> **+1 STR per level**

This point remains fixed throughout the Prototype 0.2 progression and guarantees that the hero continues to develop the basic physical foundation of the Warrior class.

### Adaptive Hero-Development Growth

Three additional points per level belong to the hero's autonomous development.

While the hero's personality is still weakly formed, these three points use the default Warrior profile:

> **+1 STR +1 DEX +1 CON**

Therefore, early Warrior growth normally totals:

> **+2 STR +1 DEX +1 CON +1 deity-guided point per level**

As meaningful personality traits appear and become established, the three adaptive points gradually stop following the default `STR / DEX / CON` distribution and are redistributed according to the hero's developed traits.

There is no fixed level at which this system suddenly switches modes. The same adaptive-growth system is used from the beginning:

- if the hero has no sufficiently established trait influence, the default Warrior profile fills the adaptive points;
- established traits may redirect one or more adaptive points toward primary attributes that fit the hero's developed character;
- if trait influences do not clearly determine all three points, any unresolved adaptive points fall back to the default Warrior profile.

The exact mapping from individual personality traits to primary-attribute growth is not yet fixed. It must be defined together with the final Prototype 0.2 trait set. Personality-driven growth must not become a disguised manual talent tree, and one trait should not automatically map to one stat merely for symmetry.

### Deity-Guided Growth

One point per level is influenced by the player's current divine development direction.

This remains a distinct player-guidance channel rather than being folded into personality. The deity can softly encourage one primary-attribute direction without turning level-up into ordinary manual stat allocation.

### First-Specialization Growth

After the first specialization is actually obtained, it adds:

> **+1 specialization-directed primary-attribute point per later hero level**

Normal post-specialization growth therefore becomes:

> **1 fixed Warrior point + 3 adaptive hero points + 1 deity-guided point + 1 specialization-directed point = 6 points per level**

The specialization also grants its current working immediate profile reward when completed:

> **+5 specialization-profile attribute points**

The exact size of this immediate reward remains a provisional balance value.

If the hero completes the first specialization later than the normal level-40 milestone, delayed specialization-directed growth is not permanently lost. The missing post-40 specialization points are granted when the specialization becomes active.

Exact XP requirements, attribute coefficients, trait-to-stat mappings, and level pace are tuning values to be balanced so a normal Prototype 0.2 playthrough can meaningfully reach the level-50–60 range.

---

## 8. Secondary Combat Stats

Prototype 0.2 uses the following working secondary combat stats.

### Defensive

- Health;
- Armor;
- Dodge;
- Fire Resistance;
- Cold Resistance;
- Lightning Resistance;
- Block.

### Offensive

- physical Damage;
- Accuracy;
- Critical Chance;
- Critical Damage;
- Attack Speed.

**Cast Speed** remains part of the broader future combat-stat schema but does not need active Prototype 0.2 content because the only playable class is Warrior and no current Warrior action is defined as a cast. Do not generate useless Cast Speed modifiers merely to claim that the stat exists.

### Armor

The working physical mitigation model is diminishing returns:

`Physical Damage Taken = Raw Physical Damage × 100 / (100 + Armor)`

The final Armor cap, if one is required, is still a balance decision and should be centralized rather than hidden in item or combat code.

### Elemental Resistances

For each element:

`Final Elemental Damage = Raw Elemental Damage × 100 / (100 + Matching Resistance)`

Resistance values cannot be negative.

Damage reduction from one elemental resistance is capped at:

> **75%**

Prototype 0.2 content must contain real sources of Fire, Cold, and Lightning damage. A resistance that never matters in actual combat is not meaningfully implemented.

### Accuracy and Dodge

Accuracy counters Dodge through one shared hit-resolution check.

If target Dodge is zero, an otherwise eligible ordinary attack has 100% hit chance. Accuracy cannot raise hit chance above 100%.

Working formula:

`DodgeChance = Dodge / (Dodge + Accuracy + 100)`

`HitChance = 1 - DodgeChance`

Dodge Chance is capped at:

> **50%**

The same rule applies to hero and enemies.

### Block

Block is a shield-based defensive stat and must be implemented before Protector can be considered complete.

A successful Block reduces the incoming eligible hit by:

> **75%**

Therefore, before ordinary mitigation:

`DamageAfterBlock = RawDamage × 0.25`

Block applies to both physical and magical / elemental direct damage.

The mitigation order is:

> **incoming hit → Block check → if successful, reduce the hit to 25% → apply Armor or the matching elemental Resistance to the remaining damage**

For physical damage:

`FinalPhysicalDamageAfterBlock = (RawPhysicalDamage × 0.25) × 100 / (100 + Armor)`

For elemental damage:

`FinalElementalDamageAfterBlock = (RawElementalDamage × 0.25) × 100 / (100 + MatchingResistance)`

The exact conversion from the numeric **Block** stat into Block Chance is deliberately not fixed yet. That formula must be centralized and shared by hero and enemies once defined.

Block must ultimately contribute to the shared Power calculation and therefore to equipment evaluation and Item Power. Until the Block-Chance formula is defined, the current Power and Item Power formulas below are explicitly incomplete for Block-capable shield configurations.

---

## 9. Combat and Shared Power

Combat remains automatic and understandable. The player does not select attacks or abilities.

The default format remains one hero versus one current enemy. Dungeons are sequences of encounters rather than simultaneous party combat.

Normal weapon attacks, critical hits, hit resolution, mitigation, abilities, and class resources operate through resolved CombatStats.

The hero and enemies use one shared Power concept:

> **stat sources → resolved CombatStats → shared Power calculation → Power**

Primary attributes are never added directly to Power if their effect is already represented through resolved stats.

Prototype 0.2 uses the current shared Warrior Power model from the approved combat design as the working formula for both the hero and enemies.

### Offensive Power Term

Critical contribution is:

`CritModifier = 1 + CritChance × (CritDamage - 1)`

Base expected physical DPS is:

`RawDPS = PhysicalDamage × (AttackSpeed / 2) × CritModifier`

Accuracy is valued against a fixed reference target with **50 Dodge**:

`ReferenceHitChance = 1 - 50 / (50 + Accuracy + 100)`

At `Accuracy = 0`, this reference hit chance is approximately `0.6667`. Accuracy is normalized against that baseline:

`AccuracyFactor = ReferenceHitChance / 0.6667`

Equivalent form:

`AccuracyFactor = 1.5 × (Accuracy + 100) / (Accuracy + 150)`

The resulting offensive term is:

`EffectiveDPS = RawDPS × AccuracyFactor`

or in one line:

`EffectiveDPS = PhysicalDamage × (AttackSpeed / 2) × CritModifier × AccuracyFactor`

### Defensive Power Term

Dodge is valued against a fixed reference attacker with **100 Accuracy**:

`ReferenceDodgeChance = Dodge / (Dodge + 100 + 100)`

The normal **50% Dodge Chance cap** applies.

For each incoming damage type, calculate the fraction of damage remaining after mitigation:

`PhysicalTaken = 100 / (100 + Armor)`

`FireTaken = 100 / (100 + FireResistance)`

`ColdTaken = 100 / (100 + ColdResistance)`

`LightningTaken = 100 / (100 + LightningResistance)`

The current reference incoming-damage mix is:

- 70% physical;
- 10% fire;
- 10% cold;
- 10% lightning.

Therefore:

`AverageDamageTaken = 0.70 × PhysicalTaken + 0.10 × FireTaken + 0.10 × ColdTaken + 0.10 × LightningTaken`

Effective survivability is:

`BlockChance = min(Block / (Block + 200), 0.50)

BlockMultiplier = 1 - 0.75 × BlockChance

EffectiveHP = MaxHealth / (AverageDamageTaken × (1 - ReferenceDodgeChance) × BlockMultiplier)`

### Final Shared Power

The final current working formula is:

`Power = sqrt(EffectiveHP × EffectiveDPS)`

The exact same calculation must be used for hero and enemies. There must be one shared `PowerCalculator`; hero and enemy Power must not drift into separate formulas.

The reference values — target Dodge `50`, attacker Accuracy `100`, and the `70/10/10/10` incoming-damage mix — are working tuning parameters for the universal Power estimate. They do not describe every actual opponent and may be rebalanced after automated combat testing, but they must remain centralized.

Power is a universal estimate of general combat strength, not a guaranteed prediction of one specific matchup. Damage type, resistances, abilities, equipment requirements, and other matchup-specific mechanics can make two combatants with similar Power perform differently against one another.

### Block Extension Required

The formulas above currently represent the already-designed Power model **before Block is included**.

Block is mandatory for the completed Prototype 0.2 Power model because it is a real defensive stat and a core Protector / shield mechanic. Once the conversion from numeric Block to Block Chance is defined, expected Block mitigation must be incorporated into the defensive Power term using the approved rule that a successful Block removes 75% of the incoming direct hit before Armor or elemental Resistance.

Do not assign an arbitrary flat Power value to Block as a shortcut.

---

## 10. Warrior Class, Rage, and Base Abilities

Warrior is the only playable base class in Prototype 0.2.

Its class resource is:

> **Rage**

### Rage

The working Rage scale is:

> **0–100 Rage**

Every separate combat encounter begins with:

> **Rage = 0**

Rage is fully reset when that fight ends. It is not carried from one ordinary fight into the next and therefore cannot be deliberately banked on weak enemies before a later boss.

The current working Rage generation values are:

- successful normal Warrior hit: **+5 Rage**;
- successful critical Warrior hit: **+7 Rage instead of +5**;
- receiving an enemy hit: **+3 Rage**.

An avoided attack that deals no hit to the Warrior does not generate Rage from taking damage.

A successfully blocked incoming hit still counts as receiving a hit for Rage generation and grants **+3 Rage**, even though Block substantially reduces its damage.

Rage cannot exceed 100.

These generation values are working balance values and may be tuned after automated combat testing without changing the structural resource rules above.

The Warrior receives two base abilities:

### Level 10 — Power Strike

Power Strike is a strong weapon attack that deals meaningfully more damage than a normal attack.

Current working rules:

- Rage cost: **30**;
- cooldown: **10 seconds**;
- requires a living valid target;
- must work with ordinary Warrior weapon setups;
- is not tied to either first specialization.


Autonomous baseline:

> **when Power Strike is off cooldown and the Warrior has at least 30 Rage, the hero may use it at the next valid combat opportunity.**

Power Strike is therefore primarily gated by Rage generation rather than by a complex situational decision rule in the first Prototype 0.2 implementation.

### Level 20 — Battle Guard

Battle Guard is the Warrior's base defensive cooldown.

It does **not** spend Rage and does **not** require a shield, so it remains useful to both Protector and Slayer paths.

Current working rules:

- cooldown: **60 seconds**;
- duration: **10 seconds**;
- may be activated only while the Warrior is at **75% MaxHP or lower**;
- while active, reduces the remaining incoming damage according to Skill Level.

Battle Guard mitigation is applied **after** the normal defensive resolution of the incoming hit.

For physical damage:

```text
Raw Physical Damage
→ Block, if triggered
→ Armor
→ Battle Guard
→ final HP damage
```

For elemental / magical damage:

```text
Raw Elemental Damage
→ Block, if triggered
→ matching elemental Resistance
→ Battle Guard
→ final HP damage
```

Therefore Battle Guard multiplies the already-mitigated remaining damage by:

> **0.67**

It does not replace, bypass, or weaken Block, Armor, or elemental Resistances.

The exact WIS scaling, if any, remains to be defined separately.

Autonomous baseline:

> **if Battle Guard is off cooldown, its effect is not already active, and current HP is 75% MaxHP or lower, the hero uses it at the next valid combat opportunity.**

This deliberately keeps the first Warrior defensive behavior deterministic and understandable instead of attempting to predict future burst damage.

### Autonomous Ability Use

For Prototype 0.2, base Warrior ability use begins with simple deterministic rules:

- **Power Strike:** use when at least 30 Rage is available and the 10-second cooldown is ready;
- **Battle Guard:** use when HP is 75% MaxHP or lower and the 60-second cooldown is ready.

Later abilities or specialization abilities may require more situational combat evaluation, but these two base abilities do not need unnecessary decision complexity merely to appear autonomous.

---

## 11. First Warrior Specialization

The first Warrior specialization becomes available around:

> **Level 40**

Prototype 0.2 includes two first-specialization directions:

- **Protector**
- **Slayer**

The player does not directly select the specialization from a menu.

The hero forms a specialization preference from their actual development, then may receive one limited divine nudge before the decision becomes final.

The specialization is not granted immediately when the direction is chosen. Choosing the direction activates the corresponding **Specialization Quest**, and the specialization becomes owned only after that quest is completed.

### 11.1. Attribute-Based Specialization Preference

The hero's developed primary-attribute profile is the main influence on the first specialization decision.

Because Warrior receives one permanent class-directed Strength point per level, that mandatory class growth must not by itself bias every Warrior toward Slayer.

At the first-specialization milestone, subtract the Warrior's expected mandatory class Strength contribution from current Strength:

> **`PersonalSTR = max(0, STR - 40)`**

The current Prototype 0.2 first-specialization raw profiles are:

> **`SlayerRaw = PersonalSTR + DEX`**

> **`ProtectorRaw = CON + WIS`**

The two raw values are converted into normalized base shares:

> **`SlayerBase = SlayerRaw / (SlayerRaw + ProtectorRaw)`**

> **`ProtectorBase = ProtectorRaw / (SlayerRaw + ProtectorRaw)`**

Example:

```text
SlayerRaw = 70
ProtectorRaw = 37

SlayerBase ≈ 0.65
ProtectorBase ≈ 0.35
```

The purpose of normalization is to compare the hero's actual developed profile rather than rely on arbitrary absolute stat thresholds.

If future balance changes alter the exact mandatory Warrior Strength gained before the specialization milestone, the subtraction value must follow the real class-directed growth rather than remain hard-coded to an obsolete number.

### 11.2. Personality Influence

Personality does **not** add a separate direct specialization-score modifier in Prototype 0.2.

This is intentional because the three personality axes that influence adaptive attribute growth already shape the hero's STR / DEX / CON / WIS profile over time.

Therefore personality affects the first specialization **indirectly through the hero's developed attributes**, avoiding double-counting the same developmental cause twice.

Other personality traits also do not receive separate specialization-score bonuses merely because they exist.

### 11.3. One-Time Divine Direction

When the hero reaches level 40, the player gains one temporary divine opportunity to influence the first specialization direction.

The player may choose:

- **Guide toward Protector**
- **Guide toward Slayer**

Current working cost:

> **80 Divine Energy**

Effect:

> **+0.15 to the selected specialization score**

This intervention may be used **only once for the entire first-specialization decision**.

The player cannot pay separately to influence both directions.

Divine guidance does not directly choose the specialization. It only modifies the hero's current preference.

A hero who has developed very strongly toward one path may therefore ignore the practical effect of the divine nudge, while a hero who is genuinely near the middle may be pushed toward the other path.

This preserves the core principle:

> **the hero develops and chooses; the deity may influence but does not directly assign the specialization.**

### 11.4. Final Specialization Scores

The current first-specialization score is:

> **`SlayerScore = SlayerBase + SlayerDivineModifier`**

> **`ProtectorScore = ProtectorBase + ProtectorDivineModifier`**

The divine modifier is zero when no divine guidance has been used.

The scores do not need to sum to exactly `1.0` after modifiers are applied. They are comparison scores, not displayed probabilities.

### 11.5. Specialization Decision Window

Reaching level 40 begins a specialization-decision window of:

> **180 world ticks**

During this window, the specialization scores may be reevaluated at valid decision points if relevant hero state changes.

The player may use the one-time divine direction only while the specialization direction remains undecided.

The hero may decide before the full 180 ticks have elapsed if one specialization becomes clearly dominant.

Current working early-decision threshold:

> **one specialization leads the other by at least `0.20`**

Example:

```text
SlayerScore = 0.72
ProtectorScore = 0.35

Difference = 0.37
→ Slayer direction may be chosen immediately.
```

A close result does not force an immediate decision:

```text
SlayerScore = 0.58
ProtectorScore = 0.52

Difference = 0.06
→ the hero remains undecided while the decision window is still active.
```

When the 180-tick window expires, the hero chooses the specialization with the higher current final score even if the difference is smaller than `0.20`.

If both final scores are exactly equal when the window expires, the tie must be resolved deterministically through the shared seeded RNG or another single centralized deterministic tie-break rule. The decision must not depend on UI order or arbitrary dictionary iteration.

### 11.6. Specialization Quest Activation

Once the direction is chosen:

- that direction becomes the hero's fixed first-specialization target;
- the one-time divine direction opportunity closes;
- the corresponding authored **Specialization Quest** becomes available to the hero through the normal quest/progression flow;
- completing that quest activates the specialization.

The specialization direction itself does not grant specialization stats, abilities, or equipment rules before the Specialization Quest is completed.

The current specialization direction is permanent for Prototype 0.2 once chosen. Prototype 0.2 does not include respecialization.

### 11.7. Protector

Protector is the defensive first-specialization path.

Its current identity is:

- primary development emphasis: **Constitution**;
- secondary thematic support from **Wisdom**;
- intended combat setup: **one-handed weapon + shield**;
- defensive identity built around survivability, mitigation, Block, and shield-based tools.

The first Protector specialization ability is planned around level 50:

> **Shield Bash**

Detailed ability numbers are defined separately.

### 11.8. Slayer

Slayer is the offensive first-specialization path.

Its current identity is:

- primary development emphasis: **Strength**;
- secondary support from **Dexterity**;
- intended combat setup: **two-handed weapon or dual wielding**;
- no shield for Slayer-specific combat tools;
- offensive identity built around pressure and higher damage output.

The first Slayer specialization ability is planned around level 50:

> **Onslaught**

Detailed ability numbers are defined separately.

### 11.9. Tuning Status

The following are current working balance values and may be tuned through testing:

- `40` mandatory class Strength removed from the specialization comparison;
- divine modifier `+0.15`;
- divine cost `80 Energy`;
- decision window `180 ticks`;
- early-decision lead threshold `0.20`.

The structural rules are fixed unless explicitly redesigned:

- stats are the primary specialization influence;
- mandatory Warrior Strength must not create false Slayer bias;
- personality influences specialization indirectly through the developed attribute profile and is not counted again as a direct score bonus;
- divine guidance is one-time and secondary;
- the hero may decide before the deadline if the direction is clear;
- the hero chooses autonomously when the window closes;
- the specialization becomes active only through its Specialization Quest.

---

## 12. Personality and Trait Development

Prototype 0.2 must move beyond static starting traits.

Personality uses opposing hidden continuous axes. Visible traits appear when hidden values cross thresholds.

General structure:

> **meaningful outcome → hidden personality movement → threshold crossing → visible trait change**

The visible trait should not flip back and forth after small opposite changes. Appearance and disappearance thresholds should therefore use hysteresis.

Prototype 0.2 uses exactly four opposing personality axes:

- **Brave ↔ Cautious**
- **Noble ↔ Devious**
- **Greedy ↔ Generous**
- **Curious ↔ Conservative**

These four axes are part of the Prototype 0.2 personality target because each can affect real decisions present in this Scope.

### Brave ↔ Cautious

Represents the hero's willingness to accept danger and uncertainty.

It may influence:

- risky quest and dungeon evaluation;
- reactions to dangerous temporary events;
- first-specialization preference;
- other decisions where danger is a meaningful tradeoff.

`Cautious` replaces the older Prototype 0 label `Cowardly`.

This is intentional: preferring safer choices or developing toward Protector does not automatically mean the hero is a coward.

### Noble ↔ Devious

Represents the hero's tendency toward honorable, straightforward behavior versus opportunistic, deceptive, or underhanded behavior.

It may influence:

- authored quest/event options;
- treatment of other people;
- acceptance of morally different opportunities;
- narrative interpretation of meaningful choices.

It must not become a generic good-versus-evil meter.

### Greedy ↔ Generous

Represents how strongly the hero prioritizes personal material benefit versus giving up value for other people or broader outcomes.

It may influence:

- quest/reward evaluation;
- authored event choices;
- spending decisions where personal gain competes with another meaningful outcome.

Routine buying, selling, or earning Gold does not by itself move this axis.

### Curious ↔ Conservative

Represents the hero's tendency to seek unfamiliar experiences, investigate rumours, and explore uncertain opportunities versus preferring known and proven options.

It may influence:

- temporary-event investigation;
- hidden-location and rumour interest;
- dungeon interest;
- exploration-related activity choice.

It does not grant hidden information directly. Curiosity affects the desire to investigate, not the hero's ability to magically know undiscovered facts.

### Excluded Axis

`Observant ↔ Inattentive` is not implemented as a Prototype 0.2 personality axis.

The current Prototype 0.2 content does not provide enough meaningful perception-specific decisions to justify a dedicated personality axis. It may be reconsidered later if perception and discovery systems become deep enough to support it.

### Trait Development Rules

Routine repetition does not normally change general personality by itself.

Ordinary quest completion, routine combat, shopping, and repeatedly acting according to an existing trait should not automatically reinforce that trait forever.

Personality changes primarily through **meaningful authored outcomes**, especially:

- temporary events;
- dungeon situations;
- specialization-related decisions;
- unusual quest outcomes;
- other authored consequences explicitly designed to leave a mark.

The event/content definition owns the direction and magnitude of personality movement caused by its outcomes.

There is no universal rule such as:

> **success always increases bravery**

A successful reckless action may reinforce Bravery, while a traumatic success could instead make the hero more Cautious if that authored outcome explicitly says so.

### Hidden Values and Visible Traits

Each personality axis is stored as a continuous hidden value.

The exact numeric range, movement sizes, visible-trait thresholds, and hysteresis thresholds remain tuning values to be defined during implementation/testing.

The architecture must nevertheless support:

- neutral hidden states with no visible trait;
- gradual movement toward either side;
- visible trait appearance after a threshold;
- trait strengthening through further meaningful movement;
- trait weakening through opposing meaningful outcomes;
- removal of the visible trait before the opposite trait can appear.

The player should see the hero's established personality, not the exact hidden numerical meter unless a later UI decision explicitly changes this.

### Personality and Autonomous Decisions

Personality affects autonomous choices through decision modifiers but must not override obvious common sense or hard eligibility rules.

The normal order remains:

```text
Hard eligibility / feasibility
→ objective evaluation
→ personality and other soft modifiers
→ final autonomous choice
```

A personality trait therefore changes preference among viable options. It does not normally make an impossible activity possible.

### Personality and Attribute Growth

Established personality traits influence the three adaptive hero-development attribute points defined in Section 7.

The current Prototype 0.2 trait-to-attribute mapping is:

- **Brave → STR**
- **Cautious → CON**
- **Curious → DEX**
- **Conservative → WIS**
- **Devious → DEX**
- **Noble → CON**

`Greedy` and `Generous` do **not** directly redirect adaptive attribute growth in Prototype 0.2.

Their gameplay role remains primarily behavioral and economic rather than combat-stat driven.

The three adaptive hero-development points correspond directly to the three personality axes that influence attributes:

1. **Brave ↔ Cautious**
   - Brave → **+1 STR**
   - Cautious → **+1 CON**

2. **Noble ↔ Devious**
   - Noble → **+1 CON**
   - Devious → **+1 DEX**

3. **Curious ↔ Conservative**
   - Curious → **+1 DEX**
   - Conservative → **+1 WIS**

Therefore each of these three personality axes controls exactly one of the three adaptive attribute points per level.

If an axis has not yet developed a sufficiently established visible direction, that axis's adaptive point falls back to the corresponding default Warrior-profile point defined in Section 7.

`Greedy ↔ Generous` does not control an adaptive attribute point in Prototype 0.2.

This mapping must remain secondary to the personality system's actual behavioral meaning. Traits must not be designed merely as disguised stat talents.

Combat-specific fears/confidences remain a separate possible future layer and are not required merely to satisfy the Prototype 0.2 personality goal.

---

## 13. Context-Specific Autonomous Decisions

Prototype 0.2 does **not** use one universal score or one global activity-selection formula for every autonomous action.

Different activities become relevant for different reasons and are therefore owned by the system that understands that activity.

The hero remains autonomous, but autonomy does not require every decision to be reduced to the same mathematical pattern.

### 13.1. Ordinary Quest Selection

Ordinary quest choice keeps its dedicated two-stage model:

> **Hard Filter → QuestScore → highest valid quest**

`QuestEvaluator` owns this logic.

Personality, reward, travel time, risk, current city context, and divine guidance may modify ordinary quest attractiveness only where explicitly defined by the quest-selection rules.

This quest-selection model must **not** automatically be reused for dungeons, events, relocation, shopping, or other activity types.

### 13.2. Dungeon Attempts

A known dungeon is not treated as another ordinary quest competing through QuestScore.

For Prototype 0.2, dungeon attempts are primarily **readiness-triggered**.

The hero may attempt a known dungeon when the dungeon's required preparation conditions are satisfied, including the relevant potion preparation defined by the dungeon rules.

After a failed dungeon attempt, the hero does not repeatedly retry it merely because it remains available.

Instead, the hero waits until the approved post-failure strength / Power retry condition is reached before another attempt becomes valid.

The exact potion requirements and retry thresholds are defined in the dungeon section of this Scope.

### 13.3. Temporary Events

Temporary events are primarily circumstances created by the world.

The hero does not normally browse a pool of unrelated events and choose the one with the highest generic score.

When an event becomes relevant to the hero because of location, timing, travel interruption, or another authored trigger, the hero reacts to that event according to its available options and the personality/decision rules defined for that event.

An event may allow multiple reactions, including ignoring it when the authored event explicitly permits that outcome.

Event resolution remains deterministic and explainable, but it does not need to share the ordinary QuestScore formula.

### 13.4. Leaving a City / Region

Relocation follows the progression trigger defined in Section 5.

The hero begins looking for a new city / region when the current city no longer provides ordinary quests meaningfully appropriate for the hero's current strength and progression.

This is a progression condition, not a global score comparison between:

- staying in the city;
- taking a dungeon;
- investigating an event;
- travelling elsewhere.

Travel begins at an appropriate normal decision point after the relocation condition has been met.

### 13.5. Economy and City Activities

Shopping, Skill Level purchases, potion preparation, and other city activities are evaluated only when their own context makes them relevant.

Their owning systems may use their own deterministic value comparisons where needed.

They are not required to output a universal activity score comparable to QuestScore.

### 13.6. Decision Ownership Principle

Prototype 0.2 therefore uses:

> **context-specific triggers and evaluators rather than one universal activity selector**

Examples:

```text
ordinary quests
→ QuestEvaluator

known dungeon
→ dungeon readiness / retry rules

temporary event
→ EventSystem + authored event options

city relocation
→ city progression condition

shopping / training
→ economy-specific rules
```

This avoids forcing mechanically different activities into an artificial common scoring scale.

The player-facing explanatory log should still be able to state the important reason for a major autonomous action, for example:

- why one ordinary quest beat another;
- why the hero decided they were ready for a dungeon;
- why the hero reacted to an event in a particular way;
- why the hero decided it was time to leave the current city.

---

## 14. Quest System and Rotating Offers

Prototype 0.2 uses local city-based quest pools.

Each normal city has:

- **15 ordinary quest templates** in its local pool;
- up to **6 active quest offers** at the same time;
- rotating offers that expire and are replaced over time.

Quest templates are authored content definitions. Active offers are runtime instances generated from those templates.

The system must keep:

> **QuestDefinition ≠ QuestOffer**

A `QuestDefinition` defines reusable authored content and constraints.

A `QuestOffer` is one concrete currently available opportunity and may contain:

- selected quest definition;
- concrete location / hex;
- concrete enemies or encounter parameters;
- concrete reward values;
- offer creation time;
- expiry time;
- other runtime parameters required by that quest type.

### 14.1. Three Strength Bands

Each city's 15 ordinary quest templates are divided into three **approximate strength bands**:

- **5 lower-strength quests**
- **5 middle-strength quests**
- **5 higher-strength quests**

These labels are organizational and relative to that city's content.

They are not permanent player-facing difficulty tiers and do not imply level scaling.

A quest's band is primarily determined by the strength of the mobs and encounters used by that quest.

The purpose of the three bands is to make the active board naturally contain opportunities at different strength levels rather than allowing random rotation to fill the entire board with nearly identical weak or strong quests.

### 14.2. Active Quest Board Composition

The active quest board contains up to six ordinary quest offers:

- up to **2 lower-strength offers**;
- up to **2 middle-strength offers**;
- up to **2 higher-strength offers**.

Each band draws only from the five quest templates assigned to that band.

If a band temporarily cannot provide two valid offers, the board may contain fewer than six total offers.

The system does **not** fill the missing slot by taking an extra quest from another strength band merely to maintain six offers.

This preserves the intended 2 / 2 / 2 composition and makes temporary exhaustion of appropriate content meaningful.

### 14.3. Offer Lifetime and Rotation

A normal active quest offer remains available for:

> **100 world ticks**

If the hero does not take the offer before its lifetime expires, the offer disappears.

The corresponding slot then becomes eligible to receive another offer from the same strength band according to the quest rotation rules.

A quest currently being performed by the hero is no longer an active board offer and is not removed merely because its original offer lifetime would have expired.

The 100-tick value is a working Prototype 0.2 tuning value.

### 14.4. Temporary Template Availability

When a quest template has recently been used and is not yet eligible to generate another offer, that template is temporarily unavailable to its band.

Prototype 0.2 must support this temporary unavailability so the board does not instantly regenerate the exact same completed quest.

Therefore the number of currently available offers in a strength band can temporarily fall below two.

The exact restoration / reuse delay for completed quest templates may be tuned separately, but it must be long enough for temporary depletion of a band's suitable quests to be meaningful.

### 14.5. Hero Outgrowing a City's Current Opportunities

The hero evaluates the **currently active offers**, not hypothetical future rolls from the entire city pool.

This is intentional.

If the hero has become strong enough that lower and middle offers are no longer meaningfully appropriate, the hero may depend primarily on the city's higher-strength offers.

If those suitable higher-strength offers are completed and no other currently active suitable quest remains, the hero may conclude that the current city no longer offers worthwhile ordinary work and begin the relocation behavior defined in Section 5.

Example:

```text
The hero has outgrown lower and middle quest bands.

Two higher-strength offers are currently suitable.
→ Hero completes them.

Their quest templates are temporarily unavailable.
No other active offer is meaningfully appropriate.
→ Hero may decide that the city currently has no suitable ordinary work.
→ At the next valid decision point, relocation may begin.
```

The hero does **not** inspect unavailable or future quest templates and wait merely because the city might eventually regenerate a suitable quest.

This creates a natural reason for an autonomous hero to move onward after exhausting the best opportunities currently available to them.

### 14.6. No Hero-Level Scaling

Ordinary quests do not scale their enemies to the hero.

Quest difficulty comes from authored / source-driven content:

- city;
- region;
- quest template;
- mob definitions;
- encounter composition.

A stronger hero may therefore find older city quests trivial, while a weaker hero may find higher-strength offers unattractive or dangerous.

The second normal city contains stronger ordinary quest content than the starting city.

### 14.7. Locality and Map Placement

Ordinary quest offers are primarily local to the hero's current city.

The hero does not globally compare routine quest offers from every city in the world.

A quest offer may place its objective on one or more real hexes associated with that city's local region.

Quest travel therefore uses the actual map and travel system rather than abstract instant mission entry.

### 14.8. Quest Selection

Only currently active, known, and valid offers participate in ordinary quest selection.

Quest selection follows the dedicated quest-decision model defined in Section 13:

> **Hard Filter → QuestScore → highest valid quest**

The quest board and rotation system determine **what opportunities exist**.

`QuestEvaluator` determines **which of those current opportunities the hero prefers**.

These responsibilities must remain separate.

### 14.9. Reusable Quest Structure

Prototype 0.2 should not require a unique script for every individual quest.

Quest templates should reuse common quest-system behavior where practical, while authored data defines:

- objective structure;
- location constraints;
- enemy source;
- reward ranges;
- narrative text hooks;
- event/outcome data;
- other quest-specific parameters.

Unique authored behavior is allowed where a quest genuinely requires it, but the ordinary city quest pool should primarily remain data-driven.

---

## 15. Travel and Temporary Events

Travel occurs through map hexes.

Temporary travel events may activate while the hero travels:

- city → quest/activity;
- quest/activity → city;
- city → city.

A temporary event exists in the world before the hero encounters it. It is not created solely because the hero stepped into a random hex.

Each event has:

- a central hex or placement rule;
- activation radius, normally 0 or 1 hex;
- a finite lifetime;
- importance / urgency where relevant;
- one or more authored outcomes.

Prototype 0.2 content target:

> **approximately 15–20 handcrafted temporary events total across both city regions**

A normal event should generally contain one or two broadly available responses plus additional conditional options only where they make sense.

Conditional options may depend on:

- primary attributes;
- personality traits;
- class / specialization;
- HP or other resources;
- items;
- previous event state;
- other explicit event-specific conditions.

Availability, choice, and success are separate concepts. Unlocking a special option does not force the hero to choose it.

An event may create a temporary detour objective. The hero’s original objective is suspended rather than forgotten and may resume after the event resolves.

Events should be a major source of meaningful personality development in Prototype 0.2.

They should remain uncommon enough that ordinary adventuring still exists as the stable rhythm of life.

---

## 16. Dungeons

Prototype 0.2 must include:

> **2 ordinary dungeons associated with the Starting City region**  
> **2 ordinary dungeons associated with the Mid-Level City region**

A dungeon is a higher-risk expedition made from a sequence of encounters followed by one unique boss.

Working structure:

> **ordinary encounter → potion-based between-fight recovery → ordinary encounter → ... → boss preparation → unique boss → completion reward**

Dungeon ordinary enemies and boss continue granting normal combat XP.

Material reward is primarily tied to completing the dungeon. Ordinary dungeon enemies do not drop normal equipment/trophy loot during the run.

If the hero dies before the final boss is defeated:

- XP already earned from completed fights is kept;
- no dungeon completion Gold is awarded;
- no dungeon completion item is awarded.

### 16.1. Dungeon Preparation

A known ordinary dungeon is attempted through **readiness rules**, not through ordinary QuestScore competition.

Before leaving for a dungeon, the hero tries to fill all available Belt potion slots according to the potion and Belt rules in Section 26.

If the hero cannot prepare an adequate potion loadout, the dungeon attempt does not begin.

The hero instead continues normal progression and may reconsider the dungeon after returning to town later.

Potion preparation is therefore part of dungeon readiness, not merely an optional optimization.

### 16.2. Healing Between Encounters

There is no automatic free full heal between ordinary dungeon encounters.

Healing between ordinary fights is performed through carried healing potions.

For ordinary rooms:

- potions are used only between fights;
- the hero prefers a potion whose healing can be applied fully without wasting part of its effect through overheal;
- if no suitable potion should be used, the hero may continue below full HP.

Before the final boss:

- survival takes priority;
- the hero attempts to enter the boss fight at **full HP**;
- potion use may accept some overheal waste when necessary to reach that state as closely as possible.

This uses the same Belt/potion system defined in Section 26 and must not be implemented as a separate dungeon-only inventory.

### 16.3. Completion Reward

Full dungeon completion grants:

- normal XP from enemies and boss fights;
- a Gold completion reward;
- one dungeon equipment reward.

The dungeon equipment reward is drawn from the Prototype 0.2 high-quality rarity range:

- **Blue / Rare** as the normal dungeon reward;
- **Purple / Epic** as the rarer exceptional result.

Purple must remain meaningfully less common than Blue.

Exact Gold values, item-level ranges, and Blue/Purple probabilities are balance data owned by dungeon/loot definitions.

The reward still follows the normal item pipeline:

> **dungeon completion → LootGenerator → ItemGenerator → ItemInstance → Inventory → equipment evaluation**

### 16.4. First Attempt and Retry Readiness

The first attempt should contain uncertainty.

The hero does not receive a perfect numerical Dungeon Power value before experiencing the dungeon.

After failure, the hero remembers how far they progressed.

The current working retry-readiness gates are:

- died before killing one ordinary dungeon enemy → retry after approximately **+20% Hero Power** from the start of that attempt;
- killed at least one ordinary enemy but did not reach boss → retry after approximately **+15% Hero Power**;
- reached boss and died → retry after approximately **+10% Hero Power**.

The comparison is made against the Hero Power recorded at the start of the failed attempt.

These percentages are balance values and may be tuned.

A dungeon does not become immediately retry-valid merely because the hero can refill potions. After a failed attempt, both conditions must be satisfied:

- required post-failure Power growth;
- adequate potion preparation.

This prevents repeated autonomous suicide attempts against the same dungeon.

### 16.5. No Voluntary Retreat

A dungeon expedition has no voluntary retreat in the first Prototype 0.2 implementation unless testing proves that retreat adds useful behavior.

Once the hero begins the run, the current implementation resolves the expedition through progression, victory, or defeat.

### 16.6. Dungeon Discovery

Ordinary dungeons may exist while unknown to the hero.

They may become known through:

- tavern rumours / city information;
- nearby discovery while adventuring;
- divine Vision if that ability remains in the current 0.2 god kit.

Discovery should use map knowledge rather than omniscient UI.

---

## 17. Specialization Quest and Specialization Dungeon

After the Warrior selects the Protector or Slayer direction, a dedicated Specialization Quest becomes active.

The Specialization Quest creates a dedicated quest dungeon that did not need to exist beforehand.

This dungeon:

- is tied to the chosen specialization path;
- is known to the hero once the Specialization Quest is created;
- exists in addition to the ordinary local dungeon population;
- reuses the same dungeon execution, preparation, death, healing, and retry systems where possible;
- contains a required quest relic / specialization objective;
- grants no specialization merely for reaching the level threshold.

Core flow:

> **level milestone → hero chooses specialization direction → Specialization Quest → prepare → dedicated dungeon → defeat boss → obtain relic / objective → complete quest → specialization granted**

Protector and Slayer may use different specialization dungeon content / boss definitions even though they share one technical dungeon system.

---

## 18. Equipment Slots and Item Groups

Prototype 0.2 uses the current 12-slot equipment structure.

### Armor

- Helmet;
- Chest, including shoulders as part of the same item;
- Gloves;
- Pants;
- Boots.

### Jewelry / Utility

- Ring 1;
- Ring 2;
- Necklace;
- Earrings;
- Belt.

### Weapons

- Main Hand;
- Off Hand.

A two-handed weapon occupies both hand slots.

A shield occupies Off Hand and is primarily associated with Block.

Armor’s inherent base defensive stat is Armor.

Jewelry uses elemental resistances as its main base defensive identity and may roll broader offensive/defensive modifiers.

Main-Hand weapons primarily define Damage and Attack Speed.

The Belt is a special utility item that provides base Health and potion capacity.

---

## 19. Item Level, Rarity, and Random Modifiers

Every standard equipment item has:

- base item type;
- equipment slot / legal setup;
- item level;
- rarity;
- inherent base stats;
- random modifiers where allowed.

Prototype 0.2 rarity ends at:

| Rarity | Color | Random modifiers on standard equipment |
| --- | --- | ---: |
| Normal | White | 0 |
| Uncommon | Green | 1 |
| Rare | Blue | 2 |
| Epic | Purple | 3 |

Legendary / Orange is outside Prototype 0.2.

Item level determines the strength scale of inherent base stats and modifier budget.

Rarity determines the modifier structure and increases the available modifier budget.

Standard equipment modifiers use secondary combat stats only.

The same random modifier may not appear twice on one item. An inherent base property may still also appear once as a random modifier when that item group allows it.

Working modifier pools:

### Armor

- Health;
- Armor;
- Dodge;
- at Epic, optionally one elemental resistance.

### Warrior Weapons

- Damage;
- Accuracy;
- Critical Chance;
- Critical Damage;
- Attack Speed.

### Jewelry

- Fire Resistance;
- Cold Resistance;
- Lightning Resistance;
- Health;
- Dodge;
- Accuracy;
- Critical Chance;
- Critical Damage.

### Belt

No ordinary random modifier pool in Prototype 0.2. Its identity is base Health + potion capacity + potion ilvl limit.

### Shield / Dedicated Off Hand

- Accuracy;
- Critical Chance;
- Critical Damage;
- Block;
- Health.

Exact modifier-budget ranges and stat costs are balance data and should be stored centrally.

---

## 20. Loot Sources and QuestLoot

Loot is source-driven, not hero-scaled.

A weak early enemy does not start dropping mid-game equipment because the hero became stronger.

Ordinary mob equipment drops use the source’s defined item-level range and rarity rules.

Working ordinary equipment-drop rarity ceiling:

> **Rare / Blue**

Epic / Purple should primarily come from stronger or more exceptional sources such as dungeon completion, bosses, major events, or explicitly special quest rewards.

During an active adventure, newly found equipment and trophies enter temporary carried loot / **QuestLoot** rather than immediately becoming safe permanent wealth.

Working adventure flow:

> **loot found → QuestLoot / backpack → objective completed → hero reviews equipment → worthwhile upgrades may be equipped → return to city → market resolves remaining ordinary loot**

A normal hero does not stop after every ordinary enemy to repeatedly swap gear.

After the main quest objective is complete, the hero gets a natural equipment-review point before returning to the city.

If an item is equipped at that review point, it becomes normal equipped gear and may benefit the hero during the return journey. Ordinary unequipped equipment and trophies remain carried until market resolution.

Death during an unresolved adventure clears remaining unsafe QuestLoot. Equipped permanent gear is not removed by normal death.

---

## 21. Inventory / Backpack Policy

Prototype 0.2 needs a real inventory/backpack representation, but it should not become a warehouse simulator.

The hero does not normally hoard large collections of spare ordinary equipment for future manual loadouts.

The inventory may contain:

- current carried QuestLoot / adventure loot;
- healing potions;
- quest items;
- special items that explicitly need to persist;
- other future inventory categories when justified.

When the hero reaches the market after an ordinary adventure, unequipped ordinary equipment and sellable trophies are normally sold automatically unless a concrete system gives the hero a reason to retain them.

There is no separate storage warehouse in Prototype 0.2.

The player does not manually drag items onto the hero as normal gameplay. Equipment selection remains autonomous.

---

## 22. Autonomous Equipment Evaluation

The player may inspect items, but the hero decides what to equip.

### Displayed Item Power

Standard equipment exposes a visible **Item Power / Item Strength** estimate in addition to its actual stats.

Item Power uses the same shared Hero / Enemy Power formula, but evaluates the item against one fixed reference combat-stat profile so the value printed on the item does not change depending on who currently holds it.

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

Under the current Power formula, before Block is added, this reference profile has approximately:

`ReferencePower ≈ 433.0`

The item's complete resolved combat contribution — inherent base stats plus all rolled modifiers — is applied to that fixed reference profile and Power is recalculated.

The working formula is:

`ItemPower = Power(ReferenceStats + ItemStats) - Power(ReferenceStats)`

or with the current pre-Block reference baseline:

`ItemPower = Power(ReferenceStats + ItemStats) - 433.0`

No arbitrary cosmetic multiplier is added to this result. Item Power stays on the same conceptual scale as Hero Power.

Displayed Item Power is only a stable reference estimate. It is **not** the hero's personal upgrade decision and does not promise that the item adds the same amount of Power to the current hero.

Once Block Chance is formally defined and Block is added to the shared Power formula, Block-bearing items must be evaluated through that same Power model. Do not assign Block a separate arbitrary Item Power conversion.

The Belt remains a special case because potion capacity is expedition utility rather than ordinary single-fight combat Power. Its permanent Health still enters resolved CombatStats, but Belt utility must additionally be evaluated through potion capacity rather than pretending potion slots are ordinary Item Power.

### Hero Equipment Decision Uses Virtual Equip

The hero's actual equipment decision uses **virtual equip**, not displayed Item Power.

Working process:

1. place the candidate into a legal temporary equipment configuration;
2. resolve the complete resulting CombatStats through StatResolver;
3. recalculate real Hero Power with the shared PowerCalculator;
4. compare against the current configuration;
5. reject illegal or specialization-incompatible setups;
6. prefer the legal configuration that creates the stronger useful result, subject to explicit non-Power rules such as Belt expedition capacity.

Protector-specific abilities require a one-handed weapon + shield setup.

Slayer-specific abilities require a compatible two-handed or dual-wield setup and no shield.

The hero should therefore normally avoid equipment configurations that disable the defining tools of their chosen specialization even if a narrow raw-stat comparison appears attractive.

The Belt is evaluated through both permanent Health and practical potion-healing capacity rather than ordinary single-fight Item Power alone.

---

### Legal Hand-Configuration Evaluation

Equipment evaluation must compare complete legal hand configurations rather than treating Main Hand and Off Hand as independent slots.

Examples:

```text
current 1H + Shield
vs
new 2H
```

and:

```text
current 2H
vs
new 1H + available legal Off Hand
```

A two-handed weapon occupies both hand slots during virtual evaluation.

A shield or other Off Hand may therefore only contribute while paired with a legal Main Hand configuration.

This prevents the evaluator from accidentally counting the stats of a shield together with a two-handed weapon or comparing only half of an actual hand setup.

### Block in ItemPower and HeroPower

`Block` is a real defensive combat stat and must participate in both:

- stable reference-based **ItemPower**;
- real virtual-equip **HeroPower** evaluation.

A successful Block reduces an eligible direct hit by **75%**, leaving **25%** of that hit before Armor / elemental Resistance are applied.

Therefore Block must be represented in Power through its **expected mitigation**, not as an arbitrary flat score.

Conceptually:

```text
expected blocked-hit multiplier
= (1 - BlockChance) × 1.00
  + BlockChance × 0.25
```

which is equivalent to:

```text
1 - (0.75 × BlockChance)
```

This expected Block mitigation is applied before the Armor / Resistance part of the defensive Power calculation, matching the combat damage order.

Prototype 0.2 uses the following shared Block conversion:

> **`BlockChance = min(Block / (Block + 200), 0.50)`**

A successful Block leaves 25% of the eligible hit, so expected mitigation is:

> **`BlockMultiplier = 1 - 0.75 × BlockChance`**

The same implementation must be used for:

- hero Power;
- mob Power where Block exists;
- ItemPower reference calculations;
- EquipmentEvaluator virtual equip comparisons.

There must not be a separate shield-only or UI-only Block value formula.


### Block Contribution to ItemPower

Block contributes to item strength through the same shared Power model used for the hero and mobs.

For an item that grants Block:

```text
BlockChance = min(Block / (Block + 200), 0.50)

BlockMultiplier = 1 - 0.75 × BlockChance
```

The resulting expected mitigation increases `EffectiveHP`, which then increases `Power`.

Therefore Block is automatically reflected in:

> **`ItemPower = Power(ReferenceStats + ItemStats) - Power(ReferenceStats)`**

No separate arbitrary "Block ItemPower coefficient" is allowed.

A shield's ItemPower therefore reflects all of its real stats together — including Block, Health, Accuracy, Crit Chance, Crit Damage, or other legal modifiers — through the same reference-Power calculation.

## 23. Visual Equipment Families

Prototype 0.2 should contain at least:

> **5–6 coherent visual armor families / sets**

For Prototype 0.2, “set” means a coherent visual family of related equipment pieces. It does **not** mean a mechanical set-bonus system.

Visible armor family pieces should include at least:

- Helmet;
- Chest / shoulders;
- Gloves;
- Pants;
- Boots.

The current visual equipment reference is **Shop Heroes** for item design language only.

The hero paper doll uses layered armor overlays. The base hero body, pose, scale, perspective, and screen placement remain stable; equipped armor is adapted to and drawn over the hero rather than regenerating the character for every item.

Prototype 0.2 must support visible equipment changes on the paper doll for the five armor slots above.

Jewelry does not need a visible body overlay.

Weapon and shield body overlays are desirable if practical, but are not required to block the basic armor-paper-doll milestone; their item icons and equipped state must still work mechanically.

Random modifier combinations do not require unique art. Visual identity belongs primarily to the base item / armor family while stats vary systemically.

---

## 24. Economy and Autonomous Spending

Prototype 0.2 needs a small but functional economy that supports the hero's autonomous development.

The core economic loop is:

> **adventure → loot / quest reward → equipment evaluation → return to city → sell unwanted loot → prepare / train / shop → next activity**

The economy exists to create meaningful tradeoffs between immediate equipment improvement, permanent skill development, and required preparation.

It must not become a separate management game.

### 24.1. Gold Sources

Prototype 0.2 Gold may come from:

- ordinary quest rewards;
- dungeon completion rewards;
- authored event rewards;
- Gold carried by humanoid enemies where fictionally appropriate;
- automatic sale of unwanted ordinary equipment;
- sale of trophies and other explicitly sellable loot.

Creatures should not drop coins merely because they are enemies.

Gold rewards remain source-driven rather than hero-level scaled.

### 24.2. Gold Sinks

Prototype 0.2 uses Gold primarily for:

- equipment purchases;
- healing potions;
- Skill Level upgrades.

Prototype 0.2 does **not** require:

- repair costs;
- taxes;
- routine inn fees;
- ordinary travel fees;
- crafting costs;
- artificial recurring Gold sinks added only to remove currency.

These systems may be reconsidered later if the economy actually needs them.

### 24.3. Selling Unwanted Loot

Ordinary equipment that the hero does not equip is normally sold automatically after returning safely to the city.

Working sale value:

> **approximately 10% of the corresponding shop value**

This percentage is a tuning value.

Quest items, specialization items, potions, and other explicitly persistent/special items are not automatically sold through this rule.

### 24.4. Spending Order

When the hero is in a city and has Gold available, spending is evaluated in context.

The broad order is:

1. preserve or obtain preparation required for an already relevant dungeon attempt;
2. evaluate available Skill Level upgrades and meaningful equipment upgrades;
3. spend remaining Gold only on purchases that satisfy their own value rules.

Required preparation takes priority over personality preference.

For example, if a dungeon retry is already valid except for potion preparation, the hero should not spend the potion budget on an optional equipment purchase and make the prepared activity impossible.

### 24.5. Curious vs Conservative Spending Preference

The **Curious ↔ Conservative** personality axis influences what kind of long-term development the hero prefers to buy first.

#### Curious

A hero with the established **Curious** trait prefers:

> **available Skill Level upgrade → then meaningful equipment upgrades**

If a valid Skill Level upgrade is currently available and affordable after required preparation is protected, the Curious hero buys it before optional equipment.

#### Conservative

A hero with the established **Conservative** trait prefers:

> **meaningful equipment upgrade → then available Skill Level upgrade**

The Conservative hero prefers a clear, concrete equipment improvement before spending the same available development budget on training.

#### Neutral Axis

If neither Curious nor Conservative is currently established, the default Warrior economic preference is:

> **Skill Level upgrade first**

This is a Prototype 0.2 default, not a universal rule for future classes.

The personality rule changes purchase priority. It does not forbid the lower-priority category.

A Curious hero may still buy equipment after training, and a Conservative hero may still buy a Skill Level after evaluating equipment.

### 24.6. Equipment Purchase Threshold

The hero does not buy every shop item that is technically better than the currently equipped item.

For Prototype 0.2, a shop item becomes a meaningful purchase candidate when it is at least:

> **20% stronger by ItemPower than the currently equipped comparison item**

Conceptually:

> **`CandidateItemPower >= CurrentItemPower × 1.20`**

The `20%` threshold is an initial tuning value and may be changed after playtesting.

This comparison deliberately uses the strength of the **item being replaced**, not a percentage of the hero's total HeroPower.

The reason is that different equipment slots may contribute very different fractions of total HeroPower, and Prototype 0.2 does not yet have enough balance data to use one whole-character percentage threshold fairly across all slots.

The shop threshold answers:

> **"Is this item itself a large enough upgrade to justify spending Gold?"**

Actual equipping still uses the real `EquipmentEvaluator` rules from Section 22.

Therefore a purchasable item must also be legal and useful for the hero's current equipment/spec configuration.

### 24.7. Hand-Slot Shop Comparisons

Main Hand and Off Hand purchases must respect complete legal hand configurations.

A two-handed weapon must not be evaluated as a simple 20% upgrade over only the current Main Hand while silently ignoring the equipped Off Hand.

For purchases that change hand layout, the comparison uses the relevant legal hand setup.

Examples:

```text
new 2H
vs
current 1H + Shield
```

or:

```text
new 1H + candidate/current legal Off Hand
vs
current 2H
```

The purchase system may use ItemPower for the shop threshold, but the resulting configuration must still pass the full virtual-equip evaluation before the hero actually equips it.

### 24.8. Skill Level Purchases

Skill Levels remain permanent progression purchased with Gold when the next rank has been unlocked by hero level.

A Skill Level purchase is valid when:

- the next rank is unlocked;
- the hero has enough Gold after required preparation is protected;
- the hero has not already purchased that rank.

The exact Gold cost progression remains balance data.

Skill Level priority is influenced by Curious / Conservative as defined above.

### 24.9. Greedy and Generous

`Greedy ↔ Generous` does not determine whether the hero prefers Skill Levels or equipment.

That axis instead represents the hero's attitude toward material gain and giving up personal value.

Its economic influence should appear primarily in authored situations such as:

- choosing between personal profit and helping someone;
- accepting or sacrificing a reward;
- event outcomes involving money or valuables.

Routine shopping must not turn Greedy into "buys gear" or Generous into "buys skills."

### 24.10. Economy Ownership

Economic decisions belong to economy systems, not UI.

The UI may display:

- current Gold;
- shop stock;
- prices;
- detected upgrade comparisons;
- recent purchases.

It does not decide what the autonomous hero buys.

Shop stock generation, purchase evaluation, Skill Level spending, potion preparation, and selling rules must remain deterministic and explainable through the simulation/debug logs.

---

## 25. City Shops

Prototype 0.2 uses local city shops with fixed progression bands.

Shop stock is source-driven by city progression and does **not** scale to the hero's current level or Power.

Each normal city offers three equipment families / progression bands.

### 25.1. Starting City Shop

The Starting City shop contains equipment from three approximate progression bands:

- **Level 1**
- **Level 10**
- **Level 20**

These level labels represent the intended equipment-strength band of the shop family.

They are not hard minimum hero-level requirements unless a specific item definition explicitly says otherwise.

### 25.2. Mid-Level City Shop

The second normal city shop contains equipment from three stronger progression bands:

- **Level 30**
- **Level 40**
- **Level 50**

This makes the second city economically stronger without dynamically scaling its inventory to the hero.

A hero who reaches it early may therefore see equipment that is expensive or only marginally useful, while a hero who remains in the Starting City too long may naturally outgrow that city's stock.

### 25.3. Stock Per Equipment Family

For each of the three progression bands in a city, the currently available equipment stock contains:

- **6 White / Normal equipment listings**
- **2 Green / Uncommon equipment listings**

Therefore a fully stocked city shop contains up to:

> **3 bands × 8 listings = 24 equipment listings**

The six White and two Green listings are individual equipment items drawn from the legal item slots / item definitions available to that progression band.

They do not mean that every equipment slot is guaranteed to be represented in every rotation.

The exact slot mix may change between rotations.

### 25.4. Prototype 0.2 Shop Rarity Limit

Normal city equipment shops in Prototype 0.2 sell:

- **White / Normal**
- **Green / Uncommon**

Blue / Rare and Purple / Epic equipment are **not part of the normal rotating city-shop stock** in Prototype 0.2.

Higher rarity equipment should primarily come from stronger gameplay sources such as:

- dungeon completion;
- exceptional quest rewards;
- important authored events;
- other explicitly exceptional loot sources.

This gives exploration and dangerous content a meaningful equipment advantage over routine shopping.

### 25.5. Stock Rotation

The full equipment assortment refreshes every:

> **200 world ticks**

At refresh time, each city's three progression bands reroll their current:

- six White listings;
- two Green listings.

Items purchased before the refresh leave their listing empty until the next normal stock refresh unless later testing shows that immediate replacement is needed.

The `200 ticks` refresh interval is an initial Prototype 0.2 tuning value.

### 25.6. Shop Item Generation

Shop items use the normal item-generation pipeline.

A shop listing must therefore be a real `ItemInstance` with:

- slot / item type;
- progression-band / Item Level source;
- rarity;
- inherent base stats;
- rarity-appropriate random modifiers;
- ItemPower;
- shop price.

The shop does not invent a separate simplified equipment-stat system.

### 25.7. Autonomous Purchase Evaluation

The hero evaluates shop equipment using the economic rules from Section 24.

A listing becomes a meaningful equipment purchase candidate only when it passes the current shop-upgrade threshold:

> **at least 20% stronger by ItemPower than the currently equipped comparison item / legal hand setup**

Purchase priority is then influenced by:

- required preparation;
- Curious ↔ Conservative;
- available Skill Level upgrades;
- available Gold;
- legal equipment / specialization rules.

The shop UI displays available opportunities.

It does not choose purchases for the hero.

### 25.8. Potions and Training

Equipment stock rotation is separate from potion and Skill Level availability.

Healing potions and unlocked Skill Level purchases follow their own economy rules and should not disappear merely because the equipment assortment refreshes.

---

## 26. Belt and Healing Potions

The Belt is a dedicated utility equipment slot.

It uses the same progression-level structure as the rest of Prototype 0.2 equipment.

Belt progression bands therefore follow the same working equipment levels:

- Level 1
- Level 10
- Level 20
- Level 30
- Level 40
- Level 50

A Belt has:

- inherent **Health**;
- rarity;
- Item Level / progression band;
- potion-slot capacity;
- a maximum potion level it can support.

The Belt does not use the normal random-modifier pool defined for ordinary armor/jewelry.

### 26.1. Potion Slot Capacity by Belt Rarity

Current Prototype 0.2 Belt capacities are:

- **White / Normal → 1 potion slot**
- **Green / Uncommon → 2 potion slots**
- **Blue / Rare → 3 potion slots**
- **Purple / Epic → 4 potion slots**

This makes Belt rarity directly affect dungeon preparation capacity.

Potion-slot capacity is utility and is not converted into an arbitrary flat combat-stat value.

### 26.2. Belt Level and Potion Eligibility

A Belt may only carry healing potions whose level is no higher than the Belt's own progression level.

Conceptually:

> **`PotionLevel <= BeltLevel`**

Examples:

- Level 1 Belt → Level 1 potion only;
- Level 10 Belt → Level 1 or Level 10 potion;
- Level 20 Belt → Level 1 / 10 / 20 potion;
- and so on.

A higher-level Belt therefore improves both its normal item stats and the strength of healing consumables the hero can prepare.

### 26.3. Healing Potion Progression

Prototype 0.2 uses a simple starting potion progression aligned with the main equipment level bands.

Current working healing values:

| Potion Level | HP Restored |
|---:|---:|
| 1 | 50 HP |
| 10 | 100 HP |
| 20 | 150 HP |
| 30 | 200 HP |
| 40 | 250 HP |
| 50 | 300 HP |

The initial rule is:

> **each next potion progression tier adds +50 HP restored**

These are intentionally simple Prototype 0.2 tuning values.

They must be reviewed against the hero's actual Max Health progression during playtesting.

If hero HP growth makes potions too weak or too strong at later levels, the healing values may be rebalanced without changing the Belt/potion architecture.

### 26.4. Potion Purchase and Storage

Healing potions are ordinary consumables purchased with Gold.

They physically belong to the hero's inventory.

The Belt determines how many potions are currently prepared and available for dungeon use.

The Belt is therefore not a separate storage inventory.

Before a relevant dungeon attempt, the hero tries to fill all available Belt potion slots with the strongest useful legal healing potions they can reasonably afford, subject to:

- Belt level;
- available Gold;
- current shop potion availability;
- required dungeon preparation rules.

Potion purchasing remains part of the economy system, not UI logic.

### 26.5. Potion Use Between Dungeon Fights

Healing potions are not used during ordinary combat in Prototype 0.2.

Between normal dungeon encounters, the hero may consume a prepared healing potion.

For ordinary between-fight healing:

- prefer a potion whose full healing value can be used without overheal;
- do not waste a stronger potion if a weaker legal potion restores the required amount cleanly;
- if no potion can be used efficiently, the hero may continue below full HP.

Before the final boss:

- survival takes priority over efficiency;
- the hero attempts to reach full HP;
- some overheal waste is acceptable when needed.

Consumed potions permanently leave inventory/Belt preparation.

### 26.6. ItemPower and Belt Evaluation

The Belt's inherent Health contributes normally to ItemPower and HeroPower.

Potion-slot capacity is evaluated separately as dungeon-preparation utility.

A Belt with more potion slots may therefore be strategically preferable even when its direct combat-stat ItemPower increase is modest.

The equipment/economy systems must not invent a fake flat Power value for potion capacity merely to force it into the shared Power formula.

---

## 27. Skill Levels

Each learned combat ability begins at:

> **Skill Level 1**

Current working maximum:

> **Skill Level 10**

Hero level periodically raises the maximum Skill Level currently available for purchase.

The Prototype 0.2 working cadence is approximately one additional purchasable rank per five relevant hero levels after the ability is learned.

A Skill Level upgrade is not automatic.

The hero must buy the newly available rank with Gold according to the autonomous economy rules in Section 24.

WIS scaling and Skill Level remain separate systems:

- **Skill Level** is a purchased ability rank;
- **WIS** changes how effectively an ability scales only where that ability explicitly uses WIS.

### 27.1. Power Strike Skill Levels

Power Strike is learned at hero level 10.

Its fixed combat rules remain:

- costs **30 Rage**;
- cooldown **10 sec**;
- uses an ordinary legal Warrior weapon attack;
- is not specialization-specific;
- once activated, the Power Strike attack **cannot miss**;
- the attack can still critically hit through the normal Crit Chance rules.

Skill Level changes the damage multiplier applied to the resolved hit.

Working endpoints:

> **Skill Level 1 → ×1.50 damage**

> **Skill Level 10 → ×2.00 damage**

Normal and critical Power Strike hits use the same Skill Level multiplier.

Conceptually:

```text
normal Power Strike
= normal resolved weapon hit × SkillMultiplier

critical Power Strike
= normal critical resolved weapon hit × SkillMultiplier
```

Intermediate ranks scale evenly between `×1.50` and `×2.00`.

Because ten Skill Levels contain nine upgrade intervals from Level 1 to Level 10, preserving both exact endpoints produces an average increase of approximately:

> **+0.0556 multiplier per purchased rank after Level 1**

This is preferred over forcing `+0.05` and ending at `×1.95`.

The exact intermediate displayed values may be rounded for UI readability while the simulation keeps one deterministic underlying value.

### 27.2. Battle Guard Skill Levels

Battle Guard is learned at hero level 20.

Its fixed combat rules remain:

- no Rage cost;
- cooldown **60 sec**;
- duration **10 sec**;
- may activate only at **75% MaxHP or lower**;
- no shield requirement;
- mitigation is applied after Block and Armor / elemental Resistance.

Skill Level changes only the percentage of remaining incoming damage reduced.

Working endpoints:

> **Skill Level 1 → 25% damage reduction**

> **Skill Level 10 → 35% damage reduction**

Intermediate ranks scale evenly between those endpoints.

Conceptually:

```text
Skill Level 1:
remaining damage × 0.75

Skill Level 10:
remaining damage × 0.65
```

Cooldown, duration, activation threshold, and Rage cost do not improve with Skill Level in Prototype 0.2.

### 27.3. Specialization Abilities

`Shield Bash` and `Onslaught` are not numerically defined in this section yet.

Their base effects and Skill Level scaling remain intentionally open until those two specialization abilities are designed.

The Skill Level framework must support them later without requiring a second rank system.

### 27.4. Skill Rank Costs

Higher Skill Levels cost progressively more Gold.

The exact Gold price curve remains balance data to define after early economy testing.

The rank system itself is fixed:

> **unlock by hero progression → autonomous purchase with Gold → permanent Skill Level increase**

---

## 28. Death and Resurrection

Death remains a meaningful defeat, not permanent loss of the hero.

The hero keeps:

- level and permanent primary attributes;
- class and obtained specialization;
- learned abilities and purchased Skill Levels;
- personality state and permanent visible traits;
- equipped permanent equipment;
- discovered world knowledge that should logically remain known;
- diary/history.

Death ends the current adventure and may remove:

- current quest / expedition progress;
- unsafe QuestLoot and trophies;
- temporary opportunity associated with the failed adventure.

Equipped permanent gear is not lost through ordinary death.

Natural resurrection returns the hero to a safe city after a delay. The exact delay may retain the current 100-world-tick working value unless later testing changes it.

The deity may still spend limited divine power for instant resurrection where the current God system supports it.

---

## 29. God Influence

Prototype 0.2 retains the core principle that divine influence sits on top of a functioning autonomous life.

The player must not become the hero's hidden commander.

Divine influence may:

- help the hero in exceptional moments;
- reveal information;
- softly influence important decisions;
- reduce the consequences of failure;
- temporarily strengthen the hero.

It must not replace the hero's normal development, equipment, abilities, or autonomous decision-making.

### 29.1. Divine Energy

The God system uses one shared resource:

> **Maximum Divine Energy = 100**

A new game starts with:

> **100 Divine Energy**

Passive recovery:

> **+1 Divine Energy every 6 world ticks**

At the normal Prototype 0.2 world pace this is approximately one Energy per real minute.

Energy regenerates only while simulation time advances.

Pause therefore also pauses Divine Energy regeneration.

The same Energy pool is used by healing, combat empowerment, instant resurrection, Vision, quest guidance, and the one-time specialization guidance defined in Section 11.

Deity progression is outside Prototype 0.2.

### 29.2. Divine Healing

Cost:

> **10 Divine Energy**

Effect:

> **restore 50% of MaxHP**

HP cannot exceed MaxHP.

Cooldown:

> **30 world ticks**

Divine Healing may be used during live combat.

It remains unavailable while the hero is dead or already at full HP.

Divine Healing is an exceptional intervention and does not replace the hero's normal potion/recovery systems.

### 29.3. Temporary Combat Empowerment

Cost:

> **10 Divine Energy**

Cooldown:

> **120 world ticks**

Effect:

> **+15% to the hero's resolved Physical Damage for the next 5 individual fights**

Conceptually:

> **`BlessedPhysicalDamage = NormalResolvedPhysicalDamage × 1.15`**

The bonus is applied to the hero's resolved Physical Damage used by attacks during those fights.

It does **not** create a separate `Attack Power` stat.

It does not permanently modify:

- STR;
- equipment;
- ItemPower;
- base Physical Damage;
- permanent HeroPower.

The remaining-fight counter decreases after each completed individual fight regardless of victory or defeat.

One fight consumes one charge regardless of how many attacks occur during that fight.

The same Combat Empowerment buff cannot be applied again while it is already active.

After the fifth affected fight, the buff expires automatically.

Because this is a temporary finite divine buff, it does not increase the hero's persistent HeroPower used for normal capability / eligibility checks.

### 29.4. Guide the Hero Toward an Ordinary Quest

Cost:

> **5 Divine Energy**

The player selects one currently available ordinary quest.

Effect:

> **`DivineModifier = +0.20` to that quest's QuestScore**

The modifier applies only to the next ordinary quest-selection action and then disappears regardless of which quest the hero ultimately chooses.

Hard Filter runs first.

Therefore divine guidance cannot make an otherwise ineligible quest available.

Cooldown:

> **360 world ticks**

This remains soft influence, not a direct order.

### 29.5. First-Specialization Divine Guidance

The first-specialization guidance defined in Section 11 uses the same Divine Energy resource.

Current working values:

- cost **80 Divine Energy**;
- usable only once for the entire first-specialization decision;
- adds **+0.15** to Protector or Slayer according to the player's chosen direction;
- available only while the specialization direction remains undecided.

This guidance influences preference but does not directly grant a specialization.

### 29.6. Vision — Reveal an Unknown Dungeon

**Vision** is a direct divine information ability.

Current working values:

- **Cost: 80 Divine Energy**
- **Cooldown: 1500 world ticks**

When activated, Vision selects:

> **one random existing dungeon that is currently unknown to the hero in the hero's current region**

The selected dungeon's location becomes known to the hero.

Vision does **not** reveal:

- exact dungeon Power / combat strength;
- ordinary enemy composition;
- the unique boss;
- the completion reward.

Vision does not create a dungeon.

It may reveal only an already-existing unknown dungeon in the current region.

If there is no valid unknown dungeon in the current region, Vision has no valid target.

Revealing the dungeon does not force the hero to travel there.

The dungeon simply becomes known and then follows the normal dungeon readiness, preparation, potion, attempt, and retry logic defined elsewhere in this Scope.

> **Vision gives the hero knowledge, not an order.**

### 29.7. Instant Resurrection

The player may skip the remaining natural resurrection delay by spending Divine Energy.

Cost:

> **`ResurrectionCost = RemainingRespawnTicks × 0.5`**

Examples:

- 100 ticks remaining → 50 Energy;
- 60 ticks remaining → 30 Energy;
- 20 ticks remaining → 10 Energy.

Instant Resurrection has:

> **no separate cooldown**

After use, the hero immediately resurrects in the safe city with:

> **1 HP**

Normal recovery then applies.

The player may additionally spend Divine Energy on Divine Healing if they want to accelerate that recovery.

### 29.8. Soft-Influence Boundary

Soft divine influence must:

- operate only on valid choices;
- wait for the appropriate decision point when necessary;
- never interrupt an activity already being executed merely to replace it with a command;
- never guarantee obedience unless the mechanic is explicitly a direct intervention rather than guidance.

The player may help, reveal, encourage, or occasionally rescue.

The player does not directly control movement, equipment, combat actions, quest execution, or specialization as ordinary commands.

The governing principle remains:

> **The hero lives. The world creates circumstances. The player guides.**

---

## 30. Working Hero Diary / Chronicle

A functional player-facing diary is **mandatory** in Prototype 0.2.

The diary is not the developer debug log.

Narrative pipeline:

> **simulation creates facts → narrative system selects / groups significant facts → diary presents a readable episode**

The diary uses:

- third-person narration;
- adventure-chronicle tone;
- light dry irony where appropriate;
- personality-aware phrasing only when supported by real hero state;
- restrained tone for death, major failure, specialization, and other serious events.

It must not become constant comedy, internet slang, or a raw line-by-line combat dump.

Prototype 0.2 should record meaningful episodes including at least:

- important quest selection and completion/failure;
- travel to a new city;
- significant temporary events and their consequences;
- level-ups;
- important equipment upgrades;
- visible personality-trait changes;
- dungeon discovery;
- dungeon attempts, failures, and clears;
- specialization direction;
- Specialization Quest progression;
- specialization gained;
- death and resurrection;
- major divine intervention when narratively meaningful.

Routine details such as every normal attack, every recovery tick, every kilometre, every shop sell line, and every ordinary mob kill should normally be omitted or summarized.

The diary should group connected facts into readable episodes rather than simply presenting one sentence per engine event.

The player should be able to return after leaving the game running and understand within a few minutes:

- what the hero did;
- what changed;
- what important choices were made;
- what new equipment, trait, dungeon, city, or specialization development mattered.

---

## 31. Explanatory Log and Developer Debug Log

Prototype 0.2 should distinguish three text layers:

1. **Hero Diary / Chronicle** — readable story;
2. **Player-facing explanatory log** — optional detail about what happened and why;
3. **Developer debug log** — raw simulation diagnostics, scores, rolls, state changes, and formulas.

The explanatory log should use player language such as:

> “The hero rejected the dungeon because the previous attempt ended before the boss and they have not yet become strong enough to justify another attempt.”

It should not normally display raw evaluator traces.

The developer log may display all internal values necessary to reproduce and debug autonomous decisions.

---

## 32. UI Requirements

Prototype 0.2 needs functional first-pass screens rather than one oversized developer dashboard.

Required screen structure:

- **Main Screen**;
- **Hero Screen**;
- **Inventory Screen**;
- **Map Screen**;
- **Menu Screen**.

The working diary must be easily accessible from the Main Screen and may use a dedicated screen / expanded view if that proves clearer. The exact navigation presentation is a UI decision, but the diary functionality is mandatory.

### Main Screen

Must quickly answer:

> **What is happening to my hero right now?**

Expected information:

- hero identity / level / class / specialization;
- HP and Power;
- current activity / quest;
- current location / local spatial context;
- recent diary / chronicle information;
- current opponent during combat;
- divine energy and abilities;
- time controls.

### Hero Screen

Must show final resolved values, including:

- primary attributes;
- secondary combat stats;
- class / specialization;
- abilities and Skill Levels;
- personality traits;
- Power;
- progression information.

### Inventory Screen

Must show:

- hero paper doll;
- all current equipment slots;
- equipped item icons / stats;
- current carried inventory/backpack contents;
- item tooltips;
- visual armor overlays on the hero for supported armor slots.

The player may inspect but does not normally manually equip items.

### Map Screen

Must show:

- both cities;
- hero position;
- roads;
- known quest targets where appropriate;
- known dungeons;
- known temporary events when they should legitimately be visible;
- current travel route / destination.

Unknown hidden locations must not appear merely because they exist internally.

### Menu Screen

Must provide at minimum:

- continue / return;
- save status / load current playthrough;
- settings placeholder or basic settings where implemented;
- exit-related functions.

UI must remain separate from gameplay logic.

---

## 33. Save and Load

Prototype 0.2 requires persistent progress.

The normal player-facing model is one continuing hero history rather than save-scumming through multiple manual branches.

Working direction:

- one rolling main save;
- regular autosave while the game is running;
- approximately 10 real minutes as a starting autosave interval;
- additional safe autosave moments may be used where appropriate;
- debug/test builds may expose extra save tools if needed for development.

The save must preserve enough state to continue the same life, including at least:

- hero level / XP / attributes;
- personality hidden values and visible traits;
- class / specialization state;
- abilities and Skill Levels;
- HP and persistent resources where needed;
- Gold;
- equipment;
- inventory / carried persistent items;
- current activity / quest state where safe to serialize;
- current quest-offer pools and expiration state;
- map knowledge;
- known dungeons and failed-attempt readiness data;
- current city / position / travel state;
- relevant temporary events;
- god state and cooldowns;
- diary/history;
- RNG state or equivalent deterministic state required for reproducible continuation.

Saving must belong to simulation state, not UI widgets.

---

## 34. Seed and Reproducibility

All simulation randomness that affects gameplay must use the shared seeded RNG or an explicitly reproducible derived stream.

This includes where applicable:

- combat crits / hit checks;
- item drops;
- rarity and modifier generation;
- quest-offer generation;
- shop stock;
- temporary event placement / outcomes where random;
- dungeon generation choices where random;
- narrative phrasing variation.

The same saved state and same player interventions should reproduce the same continuation whenever technically practical.

Do not scatter independent non-seeded random calls through gameplay scripts.

---

## 35. Required Content Volume

Current Prototype 0.2 content target:

| Content | Minimum working target |
| --- | ---: |
| Normal cities | 2 |
| Ordinary quest templates | 10–15 per city |
| Simultaneous ordinary quest offers | 5–6 per city |
| Handcrafted temporary events | 15–20 total |
| Ordinary dungeon content | 2 per city / region |
| First specialization paths | 2 |
| Specialization dungeon variants | 1 per first specialization path, sharing one system |
| Base Warrior abilities | 2 |
| First-specialization abilities | 1 Protector + 1 Slayer |
| Personality axes | approximately 3–4 meaningful pairs |
| Visual armor families | at least 5–6 |
| Item rarity | White, Green, Blue, Purple |
| Main playable progression | approximately level 1–60 |

These are production targets for the vertical slice, not requirements to create a unique engine subsystem for every individual content entry.

Data-driven reuse is preferred wherever the player still experiences meaningful variation.

---

## 36. Architecture Requirements

Prototype 0.2 should keep the existing simulation-first separation:

> **data separate → runtime state separate → stat resolution separate → simulation systems separate → narrative/UI observe results**

The required item/stat chain is:

> **loot → QuestLoot / backpack → equipment decision → Equipment → StatResolver → CombatStats → Combat / Power**

Economy and shops provide item candidates but do not calculate combat themselves.

UI displays and sends player commands; it does not own gameplay rules.

Narrative receives structured facts; it does not invent gameplay outcomes.

Quest selection and quest execution remain separate responsibilities.

Combat resolves one fight; it does not grant unrelated rewards, update UI, write diary prose, or choose the next activity directly.

Power remains one shared implementation for hero and enemies.

Concrete mobs, items, quests, dungeons, shops, and event definitions should be data-driven whenever practical.

Current experimental code may be refactored or replaced where necessary to satisfy these boundaries.

---

### 36.1. Prototype 0.2 Project Structure and System Ownership

Prototype 0.2 should preserve the architectural foundation established for Prototype 0.1:

> **data separate, runtime state separate, final-stat calculation separate, simulation separate, UI separate**

The current repository remains an implementation reference, but the temporary equipment experiments and the current monolithic UI implementation are **not authoritative architectural examples** for Prototype 0.2. Their useful underlying boundaries may be preserved, but their current file placement or internal structure must not be copied blindly when it conflicts with the structure below.

The target Prototype 0.2 structure is:

```text
res://
├── project.godot
│
├── scenes/
│   ├── main/
│   │   └── main.tscn
│   │
│   └── ui/
│       ├── main_ui.tscn
│       │
│       ├── screens/
│       │   ├── main_screen.tscn
│       │   ├── hero_screen.tscn
│       │   ├── inventory_screen.tscn
│       │   ├── map_screen.tscn
│       │   └── menu_screen.tscn
│       │
│       └── components/
│           ├── hero_paper_doll.tscn
│           ├── activity_panel.tscn
│           ├── opponent_panel.tscn
│           ├── quest_offers_panel.tscn
│           ├── god_panel.tscn
│           ├── diary_panel.tscn
│           ├── explanatory_log_panel.tscn
│           ├── debug_panel.tscn
│           └── shop_panel.tscn
│
├── scripts/
│   ├── core/
│   │   ├── simulation.gd
│   │   ├── world_clock.gd
│   │   ├── seeded_rng.gd
│   │   └── hero_name_repository.gd
│   │
│   ├── model/
│   │   ├── definitions/
│   │   │   ├── mob_definition.gd
│   │   │   ├── quest_definition.gd
│   │   │   ├── city_definition.gd
│   │   │   ├── hex_definition.gd
│   │   │   ├── event_definition.gd
│   │   │   ├── dungeon_definition.gd
│   │   │   ├── item_definition.gd
│   │   │   ├── loot_table_definition.gd
│   │   │   ├── shop_definition.gd
│   │   │   ├── ability_definition.gd
│   │   │   └── specialization_definition.gd
│   │   │
│   │   └── runtime/
│   │       ├── combat_stats.gd
│   │       ├── quest_offer.gd
│   │       ├── quest_loot.gd
│   │       ├── item_instance.gd
│   │       ├── active_event.gd
│   │       ├── dungeon_run_state.gd
│   │       └── game_event.gd
│   │
│   ├── hero/
│   │   ├── hero_state.gd
│   │   ├── hero_progression.gd
│   │   ├── hero_traits.gd
│   │   ├── trait_development.gd
│   │   ├── attribute_growth.gd
│   │   ├── hero_abilities.gd
│   │   ├── hero_specialization.gd
│   │   ├── stat_resolver.gd
│   │   ├── inventory.gd
│   │   ├── equipment.gd
│   │   └── equipment_evaluator.gd
│   │
│   ├── combat/
│   │   ├── combat_simulator.gd
│   │   ├── combat_session.gd
│   │   ├── combat_action.gd
│   │   ├── combat_result.gd
│   │   ├── damage_resolver.gd
│   │   ├── combat_decision.gd
│   │   ├── ability_system.gd
│   │   └── power_calculator.gd
│   │
│   ├── quests/
│   │   ├── quest_pool.gd
│   │   ├── quest_evaluator.gd
│   │   ├── quest_runner.gd
│   │   └── quest_event.gd
│   │
│   ├── world/
│   │   ├── world_state.gd
│   │   ├── hex_map.gd
│   │   ├── city_system.gd
│   │   ├── travel_system.gd
│   │   └── event_system.gd
│   │
│   ├── dungeons/
│   │   ├── dungeon_evaluator.gd
│   │   └── dungeon_runner.gd
│   │
│   ├── items/
│   │   ├── item_generator.gd
│   │   └── item_power_calculator.gd
│   │
│   ├── loot/
│   │   └── loot_generator.gd
│   │
│   ├── economy/
│   │   ├── shop_system.gd
│   │   ├── spending_evaluator.gd
│   │   └── skill_training_system.gd
│   │
│   ├── god/
│   │   ├── god_state.gd
│   │   └── god_system.gd
│   │
│   ├── narrative/
│   │   ├── diary.gd
│   │   ├── diary_narrator.gd
│   │   ├── explanatory_log.gd
│   │   └── debug_log.gd
│   │
│   ├── persistence/
│   │   ├── save_manager.gd
│   │   └── save_data.gd
│   │
│   └── ui/
│       ├── main_ui.gd
│       ├── screens/
│       │   ├── main_screen.gd
│       │   ├── hero_screen.gd
│       │   ├── inventory_screen.gd
│       │   ├── map_screen.gd
│       │   └── menu_screen.gd
│       │
│       └── components/
│           ├── hero_paper_doll.gd
│           ├── activity_panel.gd
│           ├── opponent_panel.gd
│           ├── quest_offers_panel.gd
│           ├── god_panel.gd
│           ├── diary_panel.gd
│           ├── explanatory_log_panel.gd
│           ├── debug_panel.gd
│           └── shop_panel.gd
│
├── data/
│   ├── hero_names_ru.txt
│   ├── mobs/
│   │   ├── starting_region/
│   │   └── mid_region/
│   ├── quests/
│   │   ├── starting_city/
│   │   ├── mid_city/
│   │   └── specialization/
│   ├── cities/
│   │   ├── starting_city.tres
│   │   └── mid_city.tres
│   ├── map/
│   │   └── prototype_02_map.tres
│   ├── events/
│   │   └── ...
│   ├── dungeons/
│   │   ├── starting_region/
│   │   ├── mid_region/
│   │   └── specialization/
│   ├── abilities/
│   │   └── warrior/
│   ├── specializations/
│   │   ├── protector.tres
│   │   └── slayer.tres
│   ├── items/
│   │   ├── bases/
│   │   ├── modifiers/
│   │   ├── consumables/
│   │   └── visual_families/
│   ├── loot_tables/
│   │   └── ...
│   ├── shops/
│   │   └── ...
│   └── narrative/
│       └── ...
│
├── assets/
│   ├── hero/
│   ├── items/
│   │   ├── icons/
│   │   └── overlays/
│   └── ui/
│
├── tests/
│   ├── core/
│   ├── hero/
│   ├── combat/
│   ├── quests/
│   ├── world/
│   ├── dungeons/
│   ├── items/
│   ├── economy/
│   ├── god/
│   ├── narrative/
│   ├── persistence/
│   └── integration/
│
└── docs/
```

This tree is a **target ownership structure**, not a requirement that every empty folder or placeholder file must be created before the corresponding system is implemented. New files should be added only when their system is actually introduced.

### 36.2. Ownership Rules

The following ownership rules are mandatory for Prototype 0.2.

#### Core

- `simulation.gd` coordinates systems but must not become the permanent owner of their internal rules.
- `world_clock.gd` remains the single authority for shared world time.
- `seeded_rng.gd` remains the shared reproducible RNG source.

#### Definitions and Runtime Instances

Immutable authored data belongs in `scripts/model/definitions/` and concrete `.tres` content belongs under `data/`.

Mutable simulation objects belong in `scripts/model/runtime/` or in the system that clearly owns their runtime lifecycle.

The Definition / Instance boundary from Prototype 0.1 remains mandatory.

Examples:

- `MobDefinition` describes a mob type.
- `QuestDefinition` describes a quest template.
- `QuestOffer` is one current offer.
- `ItemDefinition` describes the item/base rules that do not change for one generated item type.
- `ItemInstance` is one concrete generated item with its own ilvl, rarity and rolled modifiers.
- `DungeonDefinition` describes authored dungeon content.
- `DungeonRunState` stores one active expedition.

#### Hero

`hero_state.gd` owns the hero's current mutable state, but must not calculate final combat stats, item generation, quest scores, dungeon logic, or UI presentation.

`hero_progression.gd` owns XP and level progression.

`attribute_growth.gd` owns autonomous allocation of level-up primary-attribute points, including the class-fixed, trait-directed, deity-guided and specialization-directed channels defined by this Scope.

`hero_traits.gd` stores the hero's current personality/combat traits and their state.

`trait_development.gd` owns how meaningful outcomes move hidden trait values and how visible traits appear, strengthen, weaken or disappear.

`hero_specialization.gd` owns specialization state and specialization milestones.

`hero_abilities.gd` owns learned abilities and Skill Levels.

`inventory.gd` owns permanent carried items.

`equipment.gd` owns the currently equipped legal item configuration.

`equipment_evaluator.gd` performs virtual-equip comparisons and autonomous equipment decisions. It must use resolved real Hero Power rather than displayed Item Power as the final ordinary equipment-comparison rule.

#### Stat Resolution

`stat_resolver.gd` is the only normal path that converts hero sources into final `CombatStats`.

The intended chain is:

```text
Hero base/profile
+ level and primary attributes
+ specialization
+ equipment
+ persistent effects
+ temporary effects when appropriate
        ↓
    StatResolver
        ↓
    CombatStats
        ↓
Combat / Power
```

Combat, UI, quest evaluation and equipment evaluation must not independently recreate stat formulas.

#### Combat

`damage_resolver.gd` owns shared hit/mitigation rules such as Accuracy/Dodge, Block, Armor and elemental Resistances.

`combat_session.gd` owns only one active fight.

`combat_decision.gd` owns the hero's autonomous combat-action choice inside a fight.

`ability_system.gd` resolves ability costs and effects from already-defined ability data and current combat state.

`power_calculator.gd` owns the one shared Hero/Mob Power formula and must use resolved combat stats.

There must not be separate hero and mob combat-strength formulas.

#### Autonomous Decision Ownership

Prototype 0.2 does **not** use a global `activity_selector.gd` or a universal cross-category activity score.

Different autonomous actions are triggered and evaluated by the system that owns their context:

- `quest_evaluator.gd` compares ordinary quest offers;
- dungeon logic checks preparation and post-failure retry readiness;
- `event_system.gd` presents and resolves temporary events when their authored trigger makes them relevant;
- city / travel logic applies the approved progression trigger for leaving the current city;
- economy systems evaluate purchases, training and preparation only in their relevant context.

These systems must not be forced to translate their decisions into one shared score merely so unrelated activities can compete numerically.


#### Quests

`quest_pool.gd` owns the current rotating offers for each city.

`quest_evaluator.gd` owns ordinary quest suitability and QuestScore.

`quest_runner.gd` executes one already-selected ordinary quest.

Quest files/data do not own global decision logic.

#### World, Cities and Travel

`world_state.gd` owns mutable Prototype 0.2 world state: current temporary events, discovered/known locations, and other world-level runtime information explicitly required by this Scope.

`hex_map.gd` owns authored map topology and path/distance queries.

`city_system.gd` owns city-local context and access to local activities.

`travel_system.gd` owns multi-tick movement between map locations and interruption/resumption of travel.

`event_system.gd` owns spawning, lifetime and resolution of the limited Prototype 0.2 temporary-event set.

The map does not directly choose hero destinations. A destination becomes relevant through the owning gameplay rule — for example the approved city-relocation trigger or an already selected quest/dungeon destination — and the map/travel systems execute the spatial consequences.

#### Dungeons

`dungeon_evaluator.gd` owns dungeon readiness checks, including preparation requirements and post-failure retry conditions. It does not produce a universal score intended to compete against ordinary quests or unrelated activities.

`dungeon_runner.gd` owns one dungeon expedition:

```text
enter
→ fight
→ optional between-fight potion use
→ next fight
→ boss
→ success or death/failure
```

Ordinary `quest_runner.gd` must not be expanded into a giant generic script containing dungeon-only rules.

The same combat system remains shared between quest fights and dungeon fights.

#### Items, Loot and Equipment

The intended mandatory chain is:

```text
loot source
→ LootGenerator
→ QuestLoot / dungeon reward
→ ItemGenerator
→ ItemInstance
→ Inventory
→ EquipmentEvaluator
→ Equipment
→ StatResolver
→ CombatStats
→ Combat / Power
```

`loot_generator.gd` decides **what kind of reward/drop opportunity exists** from the source.

`item_generator.gd` creates the concrete `ItemInstance`: item level, rarity, base properties and valid random modifiers.

`item_power_calculator.gd` calculates the stable player-facing reference Item Power using the shared Power model.

Displayed Item Power must not replace virtual-equip evaluation for the autonomous hero.

The temporary Prototype 0 equipment-quality logic in the current repository is not a design authority for Prototype 0.2.

#### Economy

`shop_system.gd` owns shop stock, refresh and buy/sell transactions.

`spending_evaluator.gd` compares meaningful uses of Gold such as equipment purchases and expedition preparation.

`skill_training_system.gd` owns paid Skill Level upgrade availability and purchase execution.

Economy logic must not be placed inside UI controls.

#### God Influence

`god_state.gd` owns deity resource/cooldown state.

`god_system.gd` validates and applies divine interventions through the systems that actually own the affected state.

Divine influence may modify decisions or combat, but must not bypass the hero's autonomy unless the ability is explicitly defined as a direct intervention.

#### Narrative

Simulation produces structured facts/events first.

`diary_narrator.gd` converts important structured facts into player-facing diary prose.

`diary.gd` stores diary episodes/entries.

`explanatory_log.gd` stores concise player-facing explanations for important autonomous decisions.

`debug_log.gd` stores detailed technical information for development.

Narrative code must not decide gameplay outcomes.

#### Persistence

`save_manager.gd` owns save/load operations.

`save_data.gd` defines the serialized persistent state boundary.

Gameplay systems should expose serializable state rather than writing files themselves.

#### UI

Prototype 0.2 must not continue growing a single monolithic `main_ui.gd`.

`main_ui.gd` should be limited primarily to:

- screen navigation;
- top-level UI coordination;
- connection of UI screens to the existing Simulation instance.

Individual screens and reusable components own their own presentation code.

UI may:

- read simulation state;
- display it;
- send explicit player/deity requests.

UI must not:

- calculate Hero Power;
- resolve stats;
- evaluate quests;
- generate loot;
- choose equipment;
- advance progression;
- decide hero activities;
- apply combat rules.

### 36.3. Systems Deliberately Not Pre-Created

Prototype 0.2 architecture should not pre-create empty production systems for content outside this Scope.

Do not add dedicated runtime layers for:

- factions;
- faction wars;
- political borders;
- crafting;
- world economy simulation;
- NPC heroes;
- parties;
- raids;
- multiple-continent simulation;
- deity progression.

The current architecture should avoid blocking such systems later, but Prototype 0.2 must not implement their foundations merely because they may exist in the future.

## 37. Success Criteria

Prototype 0.2 succeeds if testing creates all of the following feelings.

### Hero Development Is Visible

> **“This hero is clearly not the same person or fighter they were twenty levels ago.”**

Progression should be visible through stats, abilities, equipment, appearance, personality, choices, and specialization — not only a level number.

### Autonomous Decisions Remain Understandable

The player should often be able to think:

> **“I understand why they chose that.”**

without decisions becoming completely predictable.

### The Small World Creates Circumstances

Two cities, changing offers, events, dungeons, shops, and travel should create enough variation that the hero’s routine does not feel like an endless identical quest conveyor belt.

### Personality Actually Develops

The player should be able to notice that meaningful experiences changed the hero and later decisions reflect those changes.

### Equipment Progression Is Interesting

Finding, comparing, equipping, buying, and visually seeing better gear should create meaningful development without requiring player micromanagement.

### Dungeons Feel Like Real Expeditions

Preparation, uncertainty, failure, learning, and eventual success should make a dungeon feel different from an ordinary quest.

### Specialization Feels Earned

Protector or Slayer should feel like the result of the hero’s development and a completed adventure rather than a menu choice granted at level 40.

### The Diary Makes Background Play Worth Returning To

After the game has run unattended for a while, the player should want to read what happened and be able to reconstruct the important part of the hero’s recent life.

---

## 38. Failure Signs

Prototype 0.2 needs reconsideration if:

- the player only watches numbers rise and does not care about the hero;
- equipment becomes the entire game and personality/autonomy fade into the background;
- the hero constantly makes irrational equipment or activity choices;
- rotating quests feel different only in text but play identically;
- events happen so often that ordinary life disappears;
- events are too rare or too weak to affect the hero’s story;
- traits change constantly and the hero has no stable personality;
- traits never meaningfully change at all;
- the Mid-Level City exists only as a stronger copy of the Starting City with no reason to travel there beyond bigger numbers;
- dungeons are merely longer normal quests;
- the economy becomes routine maintenance rather than meaningful progression;
- the diary becomes a verbose debug feed;
- divine influence becomes either irrelevant or equivalent to direct commands;
- the systems are only enjoyable because the player imagines future factions, wars, other classes, or other content that is not actually present.

When this happens, improve the core interactions before expanding scope.

---

## 39. Recommended Implementation Stages

A safe implementation order is:

### Stage 1 — Stabilize the Existing Prototype Foundation

- keep current autonomous loop, combat, Power, death, God system, seeded simulation, and tests working;
- identify experimental item/inventory code that must be replaced rather than preserved.

### Stage 2 — Expanded Stats and Warrior Combat

- five primary attributes;
- secondary stats;
- updated StatResolver / Power;
- Damage types, Accuracy/Dodge, Armor/resistances;
- Rage;
- Power Strike;
- Battle Guard.

- The attack **cannot miss** once Power Strike is successfully used.
- Power Strike still uses the normal critical-hit roll; both normal and critical results are multiplied by the Skill Level damage coefficient.
- **Skill Level 1 damage coefficient: ×1.50**
- **Skill Level 10 damage coefficient: ×2.00**
- intermediate Skill Levels scale evenly between those endpoints.

- **Skill Level 1 damage reduction: 25%**
- **Skill Level 10 damage reduction: 35%**
- intermediate Skill Levels scale evenly between those endpoints.
- cooldown remains **60 sec** at all Skill Levels.
- duration remains **10 sec** at all Skill Levels.
- activation threshold remains **75% MaxHP or lower** at all Skill Levels.

### Stage 3 — Real Itemization

- 12 slots;
- ilvl;
- White/Green/Blue/Purple;
- modifier generation;
- source-driven loot;
- QuestLoot;
- autonomous virtual-equip logic;
- Belt/potions;
- initial armor visual families.

### Stage 4 — Economy

- city shop tiers;
- changing stock;
- selling;
- buying;
- potion purchase;
- Skill Level purchase.

### Stage 5 — Map and Two Cities

- authored hex map;
- two city locations;
- road travel;
- local quest placement;
- map knowledge.

### Stage 6 — Rotating Quest Pools

- city-specific templates;
- 5–6 active offers;
- offer lifetime;
- replacement;
- autonomous evaluation across current opportunities.

### Stage 7 — Events and Personality Development

- final 3–4 personality axes;
- hidden values / thresholds / hysteresis;
- 15–20 temporary events;
- meaningful outcome-driven personality changes;
- event detours and travel interruption.

### Stage 8 — Dungeons

- ordinary dungeon runner;
- discovery;
- preparation;
- potion use;
- retry readiness;
- four ordinary dungeon content sets.

### Stage 9 — First Specialization

- Protector / Slayer autonomous direction;
- Specialization Quest;
- specialization dungeon variants;
- Shield Bash / Onslaught;
- specialization-directed growth.

### Stage 10 — Working Diary

- structured narrative events;
- episode aggregation;
- personality-aware third-person templates;
- meaningful equipment / trait / dungeon / specialization entries;
- player explanatory log.

Narrative event structures should be introduced earlier where needed, but the complete player-facing diary may be assembled once the major event-producing systems exist.

### Stage 11 — UI and Visual Integration

- Main;
- Hero;
- Inventory;
- Map;
- Menu;
- paper doll overlays;
- current activity and opponent presentation;
- final first-pass navigation.

### Stage 12 — Save / Load and Long-Run Testing

- rolling save;
- autosave;
- restoration of full simulation state;
- long autonomous runs to level 50–60;
- economy and progression balance;
- Power validation;
- regression tests;
- diary readability testing.

The order may shift when dependencies demand it, but systems should be added in complete vertical chains rather than as disconnected placeholders.

---

## 40. Remaining Design Decisions Before Individual Systems Are Finalized

This Scope deliberately leaves only a small set of mechanics as explicit design/tuning decisions rather than silently inventing them during coding.

Current important remaining decisions include:

- exact starting values and Warrior growth profile for the five primary attributes;
- exact final set of 3–4 personality axes used in Prototype 0.2;
- Block formula and eligible attack types;
- exact Rage generation / costs / decay;
- numerical formulas for the four Warrior abilities and their Skill Levels / WIS scaling;
- exact ordinary quest scoring coefficients once the broader 0.2 opportunity set exists;
- exact world ticks per travelled hex;
- quest-offer lifetime and refresh cadence;
- event frequency and lifetime ranges;
- final item-budget / stat-cost tables;
- city shop ilvl ranges and stock refresh cadence;
- potion healing / pricing curves;
- dungeon encounter counts and combat tuning;
- specialization-dungeon tuning;
- final autosave timing and safe save points.

These questions are primarily **numbers, tuning, and content detail**. They should not require redesigning who owns each system or how the major systems connect.

---

## 41. Main Constraint

Prototype 0.2 is larger than the original Proof of Fun, but it is still a prototype / vertical slice.

Every added system should satisfy at least one of two requirements:

1. **noticeably diversify the hero’s life now**;
2. **create consequences that affect the hero’s future development or fate**.

If a proposed system does neither, it should not be added merely because similar RPGs contain it.

The goal is not to build every planned feature.

The goal is to prove that one autonomous Warrior can live through a small but genuinely varied early career and emerge as a recognizable Protector or Slayer with a personal history worth following.
