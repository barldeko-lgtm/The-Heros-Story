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
| DEX | +10 Accuracy; +5 Dodge; +3 percentage points Critical Chance |
| INT | +2 magical Damage; +20 Mana |
| CON | +20 maximum Health; +2 Armor |
| WIS | improves learned abilities through ability-specific scaling |

**These coefficients are placeholder balancing values only. They were chosen as initial working numbers and are not approved final coefficients. They must be rebalanced against the full level-1-to-60 progression, equipment scaling, enemy progression, and automated combat tests before Prototype 0.2 combat balance is considered final.**

The architectural relationship is fixed even when the numerical coefficients change:

> **Primary Attributes → StatResolver → resolved Secondary Combat Stats → Combat / Power**

Primary attributes themselves are not read directly by combat or added directly to Power when their effect is already represented through resolved secondary stats. The conversion from STR / DEX / INT / CON / WIS into combat-facing values must remain centralized so balancing a coefficient does not require rewriting combat, Power, equipment evaluation, or UI logic.

Prototype 0.2 contains only the Warrior, so magical Damage and Mana are not required to drive the Warrior’s ordinary attacks. INT may still be used by authored event requirements and should remain a real primary attribute rather than being removed from the model.

WIS must have real meaning once Warrior abilities exist. Each ability owns its own Wisdom scaling rather than receiving one universal WIS bonus.

Primary attributes belong to long-term hero development. Standard random equipment modifiers do **not** roll primary attributes; equipment primarily changes secondary combat stats.

---

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

`EffectiveHP = MaxHealth / (AverageDamageTaken × (1 - ReferenceDodgeChance))`

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

Its working class resource is:

> **Rage**

Rage builds during combat through offensive action and taking damage. Exact maximum Rage, generation values, decay rules, and costs are tuning values to be finalized during implementation.

The Warrior receives two base abilities:

### Level 10 — Power Strike

A strong weapon attack that spends Rage to deal meaningfully more damage than a normal attack.

It must work with the ordinary Warrior weapon setups and is not tied to one first specialization.

Exact damage multiplier, Rage cost, cooldown, and WIS scaling are balance data.

### Level 20 — Battle Guard

A defensive Rage-spending ability that temporarily reduces incoming danger / damage.

It must not require a shield so the ability remains useful to both future Warrior branches.

Exact mitigation, duration, Rage cost, cooldown, and WIS scaling are balance data.

### Autonomous Ability Use

The hero decides when to use an ability.

Ability choice may consider:

- current HP;
- Rage;
- current enemy strength;
- expected remaining fight duration;
- available defensive resources;
- personality / risk tendency where relevant;
- conservation of resources when the current activity contains multiple encounters.

The hero should not simply fire every ability on cooldown with no situational logic.

---

## 11. First Warrior Specialization

At approximately level 40, the Warrior becomes eligible to move toward one of two first-tier specializations:

- **Protector**;
- **Slayer**.

The player does not directly select the specialization.

The hero evaluates which direction fits who they have become. The current conceptual inputs are:

- personality / character tendencies;
- actual primary-attribute profile;
- one optional soft divine direction.

The implementation must avoid blindly counting the same tendency twice merely because personality already influenced attribute growth.

After the hero settles on a direction, a dedicated **Specialization Quest** becomes a long-term active goal.

Reaching level 40 does not grant the specialization immediately.

### Protector

Working identity:

- defensive / protective path;
- primarily CON-oriented;
- one-handed weapon + shield;
- durability, protection, control, and active shield use.

At approximately level 50, after Protector is actually owned, the hero gains:

**Shield Bash** — a shield-based attack with a control / disruption component.

Exact damage, control behavior, cooldown, WIS scaling, and Block interaction are tuning / implementation details to finalize before coding the ability.

### Slayer

Working identity:

- offensive Warrior path;
- primarily STR-oriented;
- no shield for specialization abilities;
- compatible with a heavy two-handed weapon or dual wielding two one-handed weapons;
- sustained pressure and offensive momentum.

At approximately level 50, after Slayer is actually owned, the hero gains:

**Onslaught** — a strong weapon attack followed by a temporary increase in attack tempo / Attack Speed.

Exact damage, speed increase, duration, Rage interaction, cooldown, and WIS scaling are tuning values.

If the hero reaches level 50 without yet completing the Specialization Quest, the specialization ability remains locked until the specialization is actually obtained.

---

## 12. Personality and Trait Development

Prototype 0.2 must move beyond static starting traits.

Personality uses opposing hidden continuous axes. Visible traits appear when hidden values cross thresholds.

General structure:

> **meaningful outcome → hidden personality movement → threshold crossing → visible trait change**

The visible trait should not flip back and forth after small opposite changes. Appearance and disappearance thresholds should therefore use hysteresis.

Prototype 0.2 should implement approximately **3–4 opposing personality axes** selected from the current core set:

- Brave ↔ Cowardly;
- Noble ↔ Devious;
- Observant ↔ Inattentive;
- Greedy ↔ Generous;
- Curious ↔ Conservative.

The final subset should be chosen based on whether each axis has enough real Prototype 0.2 decisions and events to matter. A trait must not be added only as descriptive text.

Routine repetition does not normally change general personality by itself. Ordinary quest completion, routine combat, shopping, and repeatedly acting according to an existing trait should not automatically reinforce that trait forever.

Personality changes primarily through **meaningful authored outcomes**, especially temporary events, dungeon situations, specialization-related decisions, and other consequences explicitly designed to leave a mark.

The event/content definition owns the direction and magnitude of personality movement caused by its outcomes. There is no universal rule such as “success always increases bravery.”

Personality affects autonomous choices through decision modifiers but must not override obvious common sense.

Combat-specific fears/confidences remain a separate possible future layer and are not required merely to satisfy the Prototype 0.2 personality goal.

---

## 13. General Autonomous Decision Model

Recurring autonomous decisions should follow one understandable pattern:

> **hard filtering → objective/base evaluation → hero/world modifiers → highest final score**

Hard filtering removes only options that are impossible, incompatible, or clearly unreasonable.

Soft factors should normally change attractiveness rather than remove the option entirely.

Possible modifiers include:

- personality;
- current condition;
- current equipment and resources;
- expected risk;
- current goal;
- known opportunity value;
- travel time;
- current city / region;
- divine influence.

The hero normally chooses the highest final evaluation. Do not use broad roulette that lets obviously inferior options win merely for variety.

If later testing needs variation between genuinely near-equivalent choices, small seeded tie variation may be introduced separately.

The player-facing explanatory log should be able to state the important reasons for major decisions without dumping raw internal coefficients.

---

## 14. Quest System and Rotating Offers

Each city owns a local ordinary quest template pool.

Content target:

> **10–15 ordinary quest templates per city**

Only approximately:

> **5–6 ordinary offers per city**

are simultaneously active.

An offer is a runtime object distinct from its immutable template.

A runtime offer may contain:

- quest template id;
- actual target location / hex;
- enemy / objective configuration;
- reward;
- lifetime / expiration;
- other rolled instance values required by that quest type.

Unaccepted offers do not remain forever. When an offer expires, it disappears and a replacement is generated from the city’s valid local templates.

Accepted quests use their normal completion/failure logic and are replaced after resolution according to the city’s offer-refresh rules.

Quest availability belongs to the place, not to the hero’s level. The Mid-Level City should naturally contain stronger ordinary opportunities, but those opportunities do not secretly scale to the current hero.

Quest targets are placed on the real hex map using authored or rule-based placement criteria. Templates may specify suitable distance bands and required / forbidden / preferred map tags rather than hard-coding one exact coordinate for every instance.

The hero evaluates only currently known and available offers.

Ordinary quests should be systemically reusable. Prototype 0.2 does not require 20–30 completely unique quest scripts; several reusable quest structures may support many authored templates, enemy sets, locations, and narrative variants.

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

> **ordinary encounter → between-fight healing decision → ordinary encounter → ... → unique boss → completion reward**

Dungeon ordinary enemies and boss continue granting normal combat XP.

Material reward is primarily tied to completing the dungeon. Ordinary dungeon enemies do not need to drop normal equipment/trophy loot during the run.

If the hero dies before the final boss is defeated, the hero keeps XP already earned from completed fights but receives no dungeon completion loot.

The first attempt should contain uncertainty. The hero does not receive a perfect numerical Dungeon Power value before experiencing it.

After failure, the hero remembers how far they progressed. The current working retry-readiness gates remain:

- died before killing one ordinary dungeon enemy → retry after approximately +20% Hero Power from the start of that attempt;
- killed at least one ordinary enemy but did not reach boss → approximately +15%;
- reached boss and died → approximately +10%.

These percentages are balance values and may be tuned.

A dungeon expedition has no voluntary retreat in the first Prototype 0.2 implementation unless testing proves that retreat adds useful behavior.

### Dungeon Discovery

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
- Block.

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

## 24. Economy

Prototype 0.2 needs a minimal working economy because Gold, loot, shops, Skill Levels, and dungeon preparation must form one connected loop.

Core economic loop:

> **adventure → loot → equipment review → return → quest reward → sell unwanted loot → inspect shop → buy worthwhile upgrade / skill rank / potions → continue adventuring**

Gold sources:

- quest completion rewards;
- direct currency from humanoids when appropriate;
- sale of unwanted equipment;
- sale of trophies / creature loot.

Beasts and ordinary monsters should not automatically drop coins without a world reason.

Gold uses:

- equipment purchases;
- healing potions;
- available Skill Level upgrades.

Prototype 0.2 does not require:

- repair costs;
- taxes;
- tavern fees;
- routine travel fees;
- crafting costs;
- other artificial sinks added only to remove currency.

Working ordinary equipment resale rule:

> **Sell Price ≈ 10% of reference shop value**

Exact shop-price curves remain tuning data.

---

## 25. City Shops

Each city has its own limited shop strength and stock.

Shop item level is determined by the city / shop tier, not by the current hero level.

The Starting City provides lower-ilvl ordinary equipment and potions.

The Mid-Level City provides stronger ordinary stock appropriate to its place in the world.

Ordinary equipment shop rarity in Prototype 0.2 is primarily:

- White;
- Green.

Blue should remain uncommon and should not become the routine default shop path without a later explicit rule.

Purple is not normal ordinary-shop progression.

Stock is limited and periodically refreshes.

The hero evaluates purchases autonomously based on:

- actual upgrade after virtual equip;
- specialization compatibility;
- current weak slots;
- gold cost;
- competing needs such as potions or skill upgrades.

A tiny positive Power increase should not automatically justify spending a large amount of gold.

---

## 26. Belt and Healing Potions

The Belt is the hero’s dungeon-preparation utility slot.

Working Belt rarity progression:

| Belt rarity | Potion slots |
| --- | ---: |
| White | 1 |
| Green | 2 |
| Blue | 3 |
| Purple | 4 |

The Belt also provides base Health from item level.

Belt item level limits the maximum potion item level that may be placed into its slots.

Higher-ilvl potions heal more and cost more.

For a dungeon attempt the hero tries to fill all available Belt potion slots before departure. If they cannot afford to prepare adequately, they continue ordinary progression and reconsider the dungeon after returning to town later.

Potions are used between dungeon fights rather than as a normal free combat action.

Working ordinary-room rule:

- use only potions whose healing can be applied fully without wasting part of the effect through overheal.

Before the boss:

- survival takes priority;
- the hero attempts to enter at full HP and may accept some overheal waste if necessary.

Exact potion values and prices are tuning data.

---

## 27. Skill Levels

Each learned combat ability begins at:

> **Skill Level 1**

Current working maximum:

> **Skill Level 10**

Hero level periodically raises the maximum rank currently available for purchase, with a working cadence of approximately one additional upgrade opportunity per five relevant hero levels after the ability is learned.

A Skill Level upgrade is not automatic. It costs Gold.

The price increases with higher Skill Level.

WIS scaling and Skill Level are separate:

- Skill Level is a purchased ability rank;
- WIS changes how effectively that particular ability scales according to its own rules.

Exact skill-rank costs and exact per-rank improvements are balance data to define per ability.

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

The player must not become the hero’s hidden commander.

The existing direct intervention categories remain valid working tools:

- divine healing;
- temporary combat empowerment;
- instant resurrection;
- soft guidance toward a decision.

Soft guidance changes decision weight but does not bypass impossible / hard-filtered options.

The exact Prototype 0.1 energy costs and cooldowns may be retained as initial tuning values but are not sacred if the larger 0.2 progression makes them clearly inappropriate.

Prototype 0.2 may also use an information ability such as **Vision** to reveal one unknown dungeon in the hero’s current region. If included, Vision reveals the location but does not command the hero to enter and does not reveal perfect combat information.

Deity progression is outside Prototype 0.2.

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
