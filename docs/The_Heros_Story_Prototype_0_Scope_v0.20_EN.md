# The Hero’s Story — Prototype 0 / Proof of Fun

**Status:** consolidated specification for the first prototype  
**Version:** 0.20  
**Goal:** validate the game’s core fantasy before developing full RPG systems.

**Document status as source of truth:** this version supersedes all previous Prototype 0 Scope versions. If older versions, old examples, or previous discussions contradict this file, **the current version** takes precedence.

Older documents may be used only as decision history and contextual reference. Outdated formulas, numbers, or mechanics must not be automatically restored from them.

### Document Maintenance Rule

Whenever Prototype 0 is changed further, the new version must be created **from the latest complete version**, rather than by restoring individual sections from older files.

After every major change, verify that:

- no approved principles have disappeared;
- no obsolete decisions have returned;
- no contradictions have appeared between earlier and later sections;
- no open questions remain that were already resolved in discussion.

For handoff to another AI, the current file must be self-contained and must not require reading older versions.

---

## 1. The Main Question of the Prototype

> **Is it interesting to observe an autonomous hero, read the story of their life, and occasionally alter the direction of their fate?**

Prototype 0 is not a miniature version of the full future game.

It must cheaply test four things:

- whether it is interesting to watch what the hero does next;
- whether the hero feels like they have a distinct personality;
- whether the player wants to return after a period of autonomous play and read what happened;
- whether divine intervention feels meaningful without turning into direct control.

The project’s core principle:

> **The hero lives. The world creates circumstances. The player guides.**

A critically important Proof of Fun constraint:

> **if the core fantasy does not work in a simple autonomous loop, adding equipment, factions, a large map, complex combat, and other content will not solve the problem by itself.**

---

## 2. World Time

The entire Prototype 0 simulation uses a single discrete **world tick**.

Base pace:

> **1 world tick = approximately 10 real seconds**

This is a starting test value.

All gameplay timers are stored primarily **in world ticks**. Real-time minute values shown below are equivalents at normal speed.

### 2.1. Travel

Prototype 0 has no full world map.

A quest has an abstract distance from the single city.

> **1 km of travel = 1 world tick**

For example, a quest 4 km from the city requires:

- 4 ticks to reach the objective;
- quest execution;
- 4 ticks to travel back.

### 2.2. Decision Points and Execution

The hero does not make a new global decision every tick.

There are:

- **decision points** — the hero chooses a new action;
- **execution ticks** — the hero continues an action that has already been chosen.

The primary Prototype 0 decision point is:

> **choosing the next quest**

### 2.3. Pause and Developer Speed-Up

Pause stops world ticks.

Development builds must provide speed-up controls:

- ×10;
- ×100;
- higher if necessary.

Developer speed-up accelerates the world ticks themselves, so the following accelerate together with the simulation:

- travel;
- recovery;
- resurrection;
- divine energy;
- ability cooldowns.

This does not automatically imply that the final player-facing game must offer manual speed controls.

### 2.4. One Time Scale for the Future World

The world tick is not only the hero’s timer.

Architecturally, the same time scale must later allow all of the following to exist on one timeline:

- the hero;
- NPCs;
- armies;
- movement;
- quest timers;
- recovery;
- world events;
- global threats and other long-running processes.

However, **not every system must recalculate on every world tick**.

A future system may update:

- every tick;
- every few ticks;
- every tens or hundreds of ticks,

while still using the same shared time scale.

This prevents the future game from accumulating several incompatible timing systems.

### 2.5. Interruptible Actions — Future Architectural Principle

A multi-tick action must conceptually be able to be interrupted by a meaningful event.

Example from the future full game:

> the hero travels for 12 ticks → on tick 5 a road event occurs → travel is temporarily interrupted → after the event the hero continues or makes a new decision.

Road events and such interruptions are **not implemented** in Prototype 0.

However, `WorldClock`, hero state, and the action executor must not be built on the assumption that every multi-tick action is permanently uninterruptible.

---

## 3. Prototype 0 Hero

The prototype has one hero and one class:

> **Warrior**

Starting values:

- `Level = 1`;
- `XP = 0 / 1000`;
- `Strength = 2`;
- `Agility = 2`;
- `Intelligence = 2`.

### 3.1. Base Parameters

Before applying primary attributes:

- `BaseHP = 100`;
- `BaseAttack = 5`;
- `BaseAttackSpeed = 1.10`;
- `BaseCritChance = 10%`;
- `BaseCritDamage = 150%`.

### 3.2. Strength

Each point of Strength provides:

- `+5 MaxHP`;
- `+1 Attack`.

Formulas:

> `MaxHP = BaseHP + LevelHPBonus + Strength × 5`

> `Attack = BaseAttack + Strength`

### 3.3. Agility

Each point of Agility provides:

- `+0.01 AttackSpeed`;
- `+1 percentage point CritChance`;
- `+3 percentage points CritDamage`.

Formulas:

> `AttackSpeed = BaseAttackSpeed + Agility × 0.01`

> `CritChance = BaseCritChance + Agility × 0.01`

> `CritDamage = BaseCritDamage + Agility × 0.03`

### 3.4. Intelligence

Prototype 0 has no class abilities.

`Intelligence = 2` is stored as a full primary attribute but currently **does not affect combat**.

Do not add an artificial temporary effect merely to make Intelligence do something.

### 3.5. Starting Warrior

After applying the starting attributes:

- `MaxHP = 110`;
- `Attack = 7`;
- `AttackSpeed = 1.12`;
- `CritChance = 12%`;
- `CritDamage = 156%`.

### 3.6. Level-Up

Each new level requires:

> **1000 XP**

Excess XP carries over toward the next level.

Each Warrior level provides:

- `+20 MaxHP` directly;
- `+4 Strength`;
- `+1 Agility`.

Because of the Strength bonus, the Warrior’s current effective MaxHP gain per level is:

> **+40 MaxHP**

Level does not directly add `HeroPower`. It changes real combat attributes, from which the hero’s strength is recalculated.

### 3.7. XP Source

XP is stored in the mob type’s own data card.

Example:

> `Goblin: HP 30, Attack 4, XP 50`

After defeating that mob, the hero immediately receives `50 XP`.

The quest itself gives no separate XP bonus in Prototype 0.

If the hero levels up in the middle of a quest, the new stats apply starting with the next fight.

---

## 4. Combat

Each quest enemy is handled as a separate fight.

Loop:

> **fight → victory → XP → full recovery → next fight**

After the final enemy:

> **fight → victory → XP → full recovery → return trip**

There is no escape mechanic in Prototype 0.

### 4.1. Internal Combat Time

Combat has its own fine-grained internal time.

`AttackSpeed = 1.0` means:

> **one attack every 2 seconds of internal combat time**

Formula:

> `AttackInterval = 2 / AttackSpeed`

The hero and the mob have independent next-attack timers.

For ordinary Prototype 0 quest fights, the hero is the initiator and their first attack occurs **0.5 seconds earlier than their normal first attack interval**. This makes initiative visible and prevents equal-speed opponents from repeatedly resolving every attack at the same timestamp. Future ambush mechanics may give initiative to the mob instead, but ambushes are outside Prototype 0.

Combat continues until:

> `HP <= 0`

### 4.2. Damage and Critical Hits

Normal attack:

> `Damage = Attack`

Each attack independently rolls `CritChance`.

Critical attack:

> `Damage = Attack × CritDamage`

For the starting Warrior:

- normal hit = `7`;
- critical hit = `7 × 1.56 = 10.92`.

Internal calculations may retain fractional values; display rounding must not change combat math.

### 4.3. Combat and World Ticks

Regardless of internal combat duration:

> **one individual fight = exactly 1 world tick**

This is a temporary Prototype 0 simplification.

### 4.4. Recovery

After victory, the hero recovers:

> **20% MaxHP per 1 world tick**

Formula:

> `RecoveryPerTick = MaxHP × 0.20`

The hero fully recovers before the next ordinary mob.

After the final mob, the hero also fully recovers first and only then travels back to the city.

---

## 5. Power

`HeroPower` and `MobPower` are not standalone attributes. They are calculated estimates of actual combat strength.

### 5.1. Effective HP

If incoming damage reduction is used:

> `EHP = HP / (1 - DamageReduction)`

The first Prototype 0 version does not require a separate armor system, so the base value is:

> `DamageReduction = 0`

and therefore:

> `EHP = MaxHP`

### 5.2. Expected DPS

Because `AttackSpeed = 1.0` means one attack every 2 seconds, attacks per second are:

> `AttacksPerSecond = AttackSpeed / 2`

Critical multiplier:

> `CritModifier = 1 + CritChance × (CritDamage - 1)`

Expected DPS:

> `DPS = Attack × (AttackSpeed / 2) × CritModifier`

For the starting Warrior:

> `CritModifier = 1.0672`

> `DPS ≈ 4.18`

### 5.3. Final Power

Current working formula:

> **`Power = sqrt(EHP × DPS)`**

For the starting Warrior without armor:

> `HeroPower ≈ 21.45`

Mobs use **exactly the same Power formula and the same principles for calculating it from real combat stats** as the hero.

There is no separate “monster strength” scale for comparing hero and mobs.

Power must be validated through large batches of automated fights. If equal Power does not correspond to roughly comparable actual combat strength, the formula must be revised.

### 5.4. Power for Quest Selection

For Prototype 0, quest selection uses only the hero’s **full calculated strength**.

> `HeroPower = Power(MaxHP, FinalCombatStats)`

Hard Filter always compares:

> **full hero strength ↔ full mob strength**

The hero’s current HP **does not reduce HeroPower for quest selection**.

This is intentional: the hero evaluates whether they are capable of defeating such an opponent in their normal full condition, rather than evaluating a temporary injury.

After resurrection the hero appears with `1 HP`, but they recover to full health before the next fight.

Prototype 0 uses the normal post-resurrection recovery rate:

> **20% MaxHP per world tick**

The hero recovers in the city to `100% MaxHP`, then returns to the normal quest loop.

Therefore a separate `EffectivePower` is **not used** for the Prototype 0 Hard Filter.

---

## 6. Mob Data Card

Each mob type must have at least:

- `id`;
- name;
- `Category`;
- `MaxHP`;
- `Attack`;
- `AttackSpeed`;
- `CritChance`;
- `CritDamage`;
- `XP`.

Prototype 0 category:

- `HUMANOID` — intelligent biped;
- `MONSTER` — monster.

`MobPower` is calculated from real combat stats using the same model as `HeroPower`.

A full mob armor system is not required for the first version; `DamageReduction = 0` unless explicitly changed later.

---

## 7. Quest Pool

Prototype 0 has one city / abstract tavern and approximately:

> **5–7 available quests**

at all times.

Quests exist in the world as already available offers.

> **The hero does not generate a quest for themselves at the moment of selection.**

Minimum quest data card:

- `id`;
- name;
- mob type;
- number of mobs;
- distance from the city;
- monetary reward.

More varied quests, faction quests, reputation quests, and temporary quests caused by world events are outside Prototype 0.

### 7.1. Pool Refresh

After successful quest turn-in:

1. the completed quest disappears;
2. its slot is immediately filled by a new quest;
3. the number of available offers remains approximately constant.

If the hero dies during a quest, that quest is considered canceled and also frees its slot; to keep the pool constant, the slot must be filled by a new quest.

The first code version does not need a fully designed quest generator in advance.

Implementation creates **5–7 test mob types** and **one simple quest per mob type**, so the test pool matches the accepted 5–7 quest range.

Test quests differ by mob parameters, distance, number of enemies, and reward. Exact numeric mob and quest cards are set while writing the first code version, then balanced from simulation results.

After a quest is completed or canceled, its slot is filled again with an appropriate test quest so the pool remains functional.

Any random variation, if used, must remain reproducible through the seed.

---

## 8. Quest Selection

Selection has two stages:

1. **Hard Filter** — which quests the hero considers possible at all;
2. **QuestScore** — which of the allowed options is most attractive.

### 8.1. Hard Filter

In ordinary quests, the hero fully recovers between mobs, so enemy count does not determine whether the quest is physically possible.

Hard Filter checks the strength of **one** ordinary mob.

Prototype 0 uses a simple upper bound:

> `MobPower <= HeroPower × 0.95`

That is:

> `HardFilterRatio = 0.95`

The hero considers only quests where one ordinary opponent does not exceed **95% of the hero’s current HeroPower**.

A quest against a stronger mob does not participate in `QuestScore` calculation.

### 8.2. Objective Attractiveness

Core idea:

> **reward per expected time spent**

Formula:

> `BaseAttractiveness = Reward / EstimatedQuestTicks`

Time structure:

> `EstimatedQuestTicks = DistanceToQuest + MobCount × EstimatedCostPerMob + DistanceBack + TurnInTicks`

Travel is known exactly:

> `DistanceToQuest = DistanceBack = DistanceKm`

Quest turn-in can be treated as one fixed tick in Prototype 0:

> `TurnInTicks = 1`

The old placeholder:

> `BaseCombatTicks × (MobPower / HeroPower)^2`

has been **removed from the current model**, because it contradicts the later rule:

> **real fight = 1 world tick + separate recovery ticks**

The method for approximately estimating `EstimatedCostPerMob` without simulating the future fight in advance still needs to be finalized.

### 8.3. QuestScore

For every quest that passes Hard Filter:

> `QuestScore = 0`

Then:

> `QuestScore = BaseAttractiveness + CourageModifier + MoralityModifier + GreedModifier + DivineModifier`

If the hero does not have the relevant trait or divine influence is absent, the corresponding modifier is `0`.

The hero chooses the highest `QuestScore`.

There is no general percentage roulette that allows a clearly inferior quest to randomly win.

### 8.4. Coward ↔ Brave

The modifier is calculated **only among quests that passed Hard Filter**.

Let:

- `MinPower` = weakest mob among eligible quests;
- `MaxPower` = strongest;
- `P` = MobPower of the current quest.

If `MaxPower == MinPower`:

> `CourageModifier = 0`

Otherwise:

> `PowerNorm = (P - MinPower) / (MaxPower - MinPower)`

For **Brave**:

> `CourageModifier = -0.15 + 0.30 × PowerNorm`

Meaning:

- weakest enemy → `-0.15`;
- strongest enemy → `+0.15`;
- all others scale proportionally between them.

For **Coward**:

> `CourageModifier = +0.15 - 0.30 × PowerNorm`

The scale is mirrored.

### 8.5. Dishonorable ↔ Noble

**Dishonorable:**

- `+5%` actual damage against `HUMANOID`;
- `+0.10` to `QuestScore` for quests against `HUMANOID`.

**Noble:**

- `+5%` actual damage against `MONSTER`;
- `+0.10` to `QuestScore` for quests against `MONSTER`.

There is no `QuestScore` penalty against the opposite category.

The combat bonus must be applied in actual combat.

### 8.6. Greedy

A Greedy hero values the **absolute monetary reward** more strongly, not only reward efficiency per unit of time.

The modifier is also normalized only among quests that passed Hard Filter.

If `MaxReward == MinReward`:

> `GreedModifier = 0`

Otherwise:

> `GreedModifier = 0.15 × (Reward - MinReward) / (MaxReward - MinReward)`

Range:

> `0 ... +0.15`

### 8.7. Limited Randomness

Main rule:

> **randomness must not make the hero choose an obviously inferior quest.**

Random selection is allowed only among practically equivalent top options.

The exact “near tie” threshold is not yet approved and is addressed in Section 20.

---

## 9. Starting Traits

The Prototype 0 hero starts with:

> **1–2 traits**

Available:

- Coward ↔ Brave;
- Dishonorable ↔ Noble;
- Greedy.

Opposing traits are mutually exclusive.

The hero cannot have both:

- Coward + Brave;
- Dishonorable + Noble.

Greedy is an independent trait and may combine with any otherwise valid trait.

Trait acquisition, removal, and development during the hero’s life are outside Prototype 0.

---

## 10. Quest Execution Loop

Minimum states:

1. `CHOOSING_QUEST`
2. `TRAVEL_TO_QUEST`
3. `DOING_QUEST`
4. `RETURNING_TO_CITY`
5. `TURNING_IN_QUEST`
6. `DEAD_RESPAWNING`
7. `RECOVERING_IN_CITY`

Complete successful loop:

> **choose → travel → fight/XP/recovery for each mob → return trip → turn in → choose again**

`CHOOSING_QUEST` itself occupies:

> **1 separate world tick**

During that tick, the hero evaluates available quests and commits to one.

Execution of the chosen action begins on the next world tick.

When the hero reaches the quest location, the first fight begins without a separate preparation tick.

A level gained in the middle of the quest affects the next fight.

After quest turn-in, the hero receives the monetary reward, and the completed quest slot is replaced with a new quest.

---

## 11. Death and Resurrection

If the hero dies:

1. the current fight ends in defeat;
2. the current quest is canceled;
3. XP from mobs already defeated earlier and levels already gained are retained;
4. no XP is awarded for a mob that was not defeated;
5. all loot acquired during the current quest is lost;
6. the hero is abstractly returned / teleported to the city;
7. the natural resurrection timer starts.

Duration:

> **100 world ticks**

During the timer, the hero does not choose or perform quests.

After natural or divine resurrection:

> **HP = 1**

The hero then enters:

> `RECOVERING_IN_CITY`

and recovers according to the normal rule:

> **20% MaxHP per world tick**

until reaching `100% MaxHP`.

Only after full recovery does the hero return to `CHOOSING_QUEST`.

Therefore the hero never begins a new quest loop while injured and always reaches the first fight of a new quest at full HP.

### 11.1. Loot

A full loot system does not yet exist in the first Prototype 0 version.

The loot-loss rule is recorded in advance as a future hook and does not currently require designing:

- inventory;
- items;
- quality;
- market.

---

## 12. God System

The god uses one resource:

> **100 energy maximum**

### 12.1. Energy Recovery

Canonical rule:

> **+1 energy every 6 world ticks**

At normal speed this is approximately:

> **+1 energy per real minute**

Energy recovers while the simulation is running, including during the hero’s resurrection timer.

When paused, world ticks do not advance, so energy does not recover.

### 12.2. Instant Resurrection

Cost:

> `ResurrectionCost = RemainingRespawnTicks × 0.5`

Examples:

- 100 ticks remaining → `50 energy`;
- 60 → `30`;
- 20 → `10`.

After use, the hero immediately resurrects in the city with:

> **1 HP**

Normal city recovery to full HP then applies. Divine healing may be used if the player wants to accelerate recovery.

Instant Resurrection has no separate cooldown.

### 12.3. Divine Healing

Cost:

> **10 energy**

Effect:

> **+50% MaxHP**

HP cannot exceed MaxHP.

Cooldown:

> **30 world ticks**  
> *(approximately 5 minutes at normal speed)*

Because combat is calculated entirely within one world tick, healing cannot intervene in a fight that is already being internally resolved. It may be used between combat calculations and in other living hero states.

### 12.4. Combat Buff

Cost:

> **10 energy**

Effect:

> **+3 Attack for the next 5 individual fights**

Cooldown:

> **120 world ticks**  
> *(approximately 20 minutes at normal speed)*

The counter decreases after each fight regardless of victory or defeat.

The same buff cannot be applied again while it is already active.

### 12.5. Guide the Hero Toward a Quest

Cost:

> **5 energy**

The player selects one specific available quest.

Effect:

> **`DivineModifier = +0.20` to that quest’s QuestScore**

The modifier applies only to **one next quest-selection action** and then disappears regardless of which quest the hero ultimately selects.

Hard Filter runs before `QuestScore`, so divine guidance **cannot make an otherwise ineligible quest available**. It affects only the choice among quests the hero already considers feasible.

Cooldown:

> **360 world ticks**  
> *(approximately 60 minutes at normal speed)*

This is not a direct command.

The hero may still choose another quest if that quest ends with a higher final `QuestScore`.

---

## 13. Debug Log

The debug log is for development and must be detailed.

At minimum it shows:

- current world tick;
- hero state;
- HP, XP, level, and active effects;
- current quest;
- available quests;
- Hard Filter;
- `BaseAttractiveness`;
- every `QuestScore` modifier;
- final `QuestScore`;
- reason for the choice;
- travel;
- start and result of every fight;
- damage dealt and critical hits;
- XP;
- level-ups;
- recovery;
- death;
- resurrection timer;
- god ability usage;
- appearance of a new quest.

Example:

> `Tick 142 — Wolves: Base 1.84 + Brave 0.11 + Noble 0.10 + Divine 0.00 = Final 2.05`

The debug log may be long. Its purpose is to make the simulation explainable.

---

## 14. Hero Diary

The diary is a separate layer and does not duplicate the debug log.

Its purpose:

> **quickly show the player what important things happened to the hero.**

### 14.1. One Quest = One Episode

The main diary unit is:

> **one quest = one small episode**

An episode begins when the hero selects a quest.

It closes when:

- the quest is successfully turned in;
- or the hero dies and the quest is canceled.

### 14.2. Mandatory Entries

The diary always records:

- selection of a new quest;
- level-up;
- successful quest completion;
- death;
- resurrection.

### 14.3. Optional Significant Entries

Later in Prototype 0, if they genuinely improve readability, the diary may additionally record:

- an exceptionally difficult fight;
- a victory at critically low HP;
- divine intervention;
- other rare meaningful events.

Ordinary actions do not enter the diary:

- every tick;
- every kilometer;
- every ordinary mob;
- routine recovery;
- technical Score calculations.

### 14.4. Modular Entry

Base structure:

> **main event sentence + at most one optional personality comment**

Example:

> Alric accepted a contract to kill six goblins. Apparently, the promised reward settled the matter.

If several traits influenced the decision, the text uses the most significant modifier.

If no trait had a noticeable influence, no additional personality comment is required.

A few ready-made phrasings for each major entry type are enough. Prototype 0 does not require a full literary text generator.

### 14.5. Diary Tone

Even the simple Prototype 0 templates should move toward the intended tone of the full game:

- **third person**;
- adventure chronicle;
- lively authorial voice;
- dry irony;
- occasional sarcasm;
- the more serious the event, the less humor;
- no satire or parody;
- no memes, internet slang, or fourth-wall breaking.

Prototype 0 does not need broad literary variety. The more important test is whether this kind of text helps the player perceive a sequence of system events as **the life of a specific hero**.

### 14.6. Larger Narrative Layers — Later

The full game may eventually add larger layers on top of the current diary:

- major milestones in the hero’s life;
- a longer-term biography;
- a chronicle of important world events.

They are **outside Prototype 0** and must not complicate `Diary` now.

---

## 15. Minimum Interface

The interface may be rough, but it must allow every system to be tested without hiding important information.

Minimum requirements:

### Hero

- name;
- level and XP;
- HP / MaxHP;
- STR / AGI / INT;
- Attack;
- AttackSpeed;
- CritChance;
- CritDamage;
- HeroPower;
- 1–2 starting traits;
- current state;
- active quest;
- active buffs.

### Quests

- list of the current 5–7 quests;
- name;
- mob;
- count;
- distance;
- reward;
- MobPower;
- visible indication of whether the quest passed Hard Filter;
- in debug mode, full QuestScore breakdown.

### God

- current energy / 100;
- four abilities;
- cost;
- remaining cooldown;
- ability to select a quest for `+0.20`.

### Text

- diary;
- separate debug log.

### Development

- pause;
- ×10;
- ×100;
- seed display.

A polished UI, final portrait, equipment display, and animations are not required.

---

## 16. Seed and Reproducibility

All random processes in Prototype 0 must use a reproducible seed.

Where applicable, this includes:

- critical hits;
- starting trait selection;
- limited random choice among nearly tied quests;
- diary phrasing selection;
- generation / selection of a replacement quest from the test set.

The same seed and the same player actions should produce a repeatable run whenever possible.

---

## 17. What Is NOT Included in Prototype 0

Intentionally excluded:

- a full RPG combat system;
- class abilities;
- classes other than Warrior;
- a full armor system;
- equipment;
- full loot and inventory systems;
- market and economy;
- a full map;
- multiple cities;
- road events;
- factions;
- reputation;
- faction quests;
- temporary world-event quests;
- wars;
- global threat;
- NPC heroes;
- dungeons;
- raids;
- parties;
- world generation;
- full biography;
- long-term goals;
- god progression;
- final death system;
- retirement / end-of-life system;
- final art;
- animations;
- full lore;
- full literary diary generator;
- separate hero milestone system;
- full biographical chronicle;
- world chronicle.

---

## 18. Success Criteria

Prototype 0 is successful if testing creates the following feelings.

### 18.1. Curiosity

> **“I wonder what they’ll do next?”**

### 18.2. Desire to Return

After a period of autonomous play, the player wants to reopen the game and see what happened.

### 18.3. Recognizable Hero

Traits are genuinely visible in behavior:

> **“Of course they picked that again.”**

### 18.4. Sense of a Story

After some time, the hero’s life can be retold as a small story rather than merely a sequence of numbers.

### 18.5. Meaningful Divine Influence

After player intervention, it is noticeable that events could have unfolded differently, while the hero still feels autonomous.

---

## 19. Failure Signs

Prototype 0 requires reconsideration if:

- the hero’s decisions feel like random noise;
- personality is barely noticeable;
- the hero is too predictable and mechanical;
- the diary becomes boring quickly;
- after a period of autonomous play there is no desire to learn what happened;
- divine influence feels either useless or like direct control;
- the prototype feels enjoyable only after mentally adding dozens of future RPG systems.

Revisit the core first instead of adding more content.

---

## 20. Readiness for Coding

The core Prototype 0 rules are defined in enough detail to begin implementation.

Previously open questions are resolved as follows.

### 20.1. Hard Filter

Starting limit:

> `MobPower <= HeroPower × 0.95`

The hero therefore considers quests only against mobs whose strength does not exceed **95% of the hero’s current strength**.

### 20.2. Mob Power

Mob strength is calculated:

> **with the same formula and the same types of combat parameters as hero strength**

There is no separate monster strength scale.

### 20.3. Test Mobs and Quests

Exact numeric cards are created while writing the first code version.

The first run only needs:

- **5–7 test mob types**;
- both `HUMANOID / MONSTER` categories;
- one simple test quest for each mob type.

A full generator for varied quests is not required at this stage.

### 20.4. Quest Availability

The test set is deliberately designed so quests are not excessively strong relative to the starting hero.

As the hero grows, they should instead gradually outgrow the existing test mobs and quests.

Therefore Prototype 0 does not design a complex fallback for the case where “all quests are too strong.”

Test data only needs to guarantee that at least one quest passes Hard Filter at the start.

### 20.5. Estimated Cost per Mob

The only remaining formula that is convenient to finalize together with the first implementation and combat tests is:

> `EstimatedCostPerMob`

It is used only to estimate quest duration for `BaseAttractiveness`.

It should account for:

- 1 world tick for the fight itself;
- an approximate number of recovery ticks afterward;
- relative mob and hero strength;

but it must **not** run a complete future combat simulation every time the hero evaluates quests.

This **does not block implementation of the project structure, WorldClock, data, combat, Power, or the quest loop itself**. The formula can be tuned after the first automated combat batches.

### 20.6. Nearly Equal QuestScore

For the very first version, use:

> **strict selection of the maximum `QuestScore`**

Limited randomness between near-tied options is added later, after the base selection system has been validated.

### 20.7. Gold

Monetary reward already participates in quest attractiveness and the Greedy trait.

For the first implementation it is acceptable to add a simple numeric `Gold` counter to the hero, increasing after successful quest turn-in.

There is nothing to spend Gold on in Prototype 0 yet.

### 20.8. Power After Resurrection — RESOLVED

Hard Filter uses:

> **Full HeroPower based on MaxHP and final combat stats**

Current HP does not affect strength evaluation for quest selection.

After resurrection the hero has `1 HP`, then recovers in the city at `20% MaxHP` per world tick until fully healed, and only then returns to choosing a new quest.

### 20.9. Cost of the Decision Point — RESOLVED

> **`CHOOSING_QUEST` = 1 world tick**

During this tick, the hero evaluates available quests and selects one.

The next tick already belongs to execution of the chosen action.

---

## 21. Recommended Implementation Order

### Stage 1 — Simulation Foundation

- WorldClock;
- pause;
- developer speed-up;
- seeded RNG;
- hero, mob, and quest data.

### Stage 2 — Combat and Progression

- internal combat;
- critical hits;
- XP;
- Level Up;
- recovery;
- Power;
- automated large-batch Power tests.

### Stage 3 — Autonomous Quest Loop

- pool of 5–7 quests;
- Hard Filter;
- BaseAttractiveness;
- QuestScore;
- separate `CHOOSING_QUEST` tick;
- travel / combat / recovery / return / turn-in states;
- city recovery after resurrection;
- replacement of completed and canceled quests.

### Stage 4 — Personality

- Coward ↔ Brave;
- Dishonorable ↔ Noble;
- Greedy;
- Dishonorable / Noble combat bonus;
- detailed debug explanation of quest selection.

### Stage 5 — Death

- defeat;
- quest cancellation;
- 100 ticks;
- 1 HP after resurrection.

### Stage 6 — Diary

- events;
- episodes;
- several modular templates.

### Stage 7 — God System

- energy;
- instant resurrection;
- healing;
- buff;
- `+0.20` to the selected quest;
- cooldowns.

After this, Prototype 0 is ready for a real Proof of Fun test.

---

## 22. Godot Project Architectural Foundation

The project structure must remain small enough for Prototype 0 while already surviving the next planned stage:

> **mob drops → temporary quest loot → inventory → equipment → equipment affecting final stats and Power**

Core principle:

> **data separate, current state separate, final-stat calculation separate, simulation separate, UI separate**

There is no need to implement a full item system in advance, but the architecture must not require combat, hero, and Power to be rewritten after the first sword is introduced.

### 22.1. Recommended Structure

```text
res://
├── project.godot
│
├── scenes/
│   ├── main/
│   │   └── main.tscn
│   └── ui/
│       ├── main_ui.tscn
│       ├── hero_panel.tscn
│       ├── quest_panel.tscn
│       ├── god_panel.tscn
│       ├── diary_panel.tscn
│       ├── debug_panel.tscn
│       └── equipment_panel.tscn      # connected after Prototype 0
│
├── scripts/
│   ├── core/
│   │   ├── simulation.gd
│   │   ├── world_clock.gd
│   │   └── seeded_rng.gd
│   │
│   ├── model/
│   │   ├── definitions/
│   │   │   ├── mob_definition.gd
│   │   │   ├── quest_definition.gd
│   │   │   ├── item_definition.gd
│   │   │   └── loot_table_definition.gd
│   │   │
│   │   └── runtime/
│   │       ├── combat_stats.gd
│   │       ├── quest_instance.gd
│   │       └── item_instance.gd
│   │
│   ├── hero/
│   │   ├── hero_state.gd
│   │   ├── hero_progression.gd
│   │   ├── hero_traits.gd
│   │   ├── stat_resolver.gd
│   │   ├── inventory.gd             # connected after Prototype 0
│   │   └── equipment.gd             # connected after Prototype 0
│   │
│   ├── combat/
│   │   ├── combat_simulator.gd
│   │   └── power_calculator.gd
│   │
│   ├── quests/
│   │   ├── quest_pool.gd
│   │   ├── quest_evaluator.gd
│   │   └── quest_runner.gd
│   │
│   ├── loot/
│   │   └── loot_generator.gd        # connected after Prototype 0
│   │
│   ├── god/
│   │   └── god_system.gd
│   │
│   ├── narrative/
│   │   ├── diary.gd
│   │   └── debug_log.gd
│   │
│   ├── persistence/
│   │   ├── save_manager.gd          # later, when saving is needed
│   │   └── save_data.gd
│   │
│   └── ui/
│       └── main_ui.gd
│
├── data/
│   ├── mobs/
│   │   └── ...
│   ├── quests/
│   │   └── ...
│   ├── items/
│   │   └── ...
│   ├── loot_tables/
│   │   └── ...
│   └── narrative/
│       └── ...
│
└── tests/
    ├── combat_tests.gd
    ├── power_tests.gd
    ├── quest_choice_tests.gd
    └── stat_tests.gd
```

Folders and files marked as future work do not need to be implemented in the first build. The important requirement is that current code must not be built in a way that forces those systems to be inserted later by rewriting the core.

### 22.2. Definition and Instance

For entities that exist both as a type and as a specific object, separate:

> **Definition = immutable description of a type**

> **Instance = a specific instance currently existing in the simulation**

Examples:

#### MobDefinition

Stores:

- name;
- category;
- base combat stats;
- XP;
- later, a reference to a loot table.

A goblin and a wolf do not need separate behavior scripts if they differ only in data.

#### QuestDefinition

Describes a quest template.

#### QuestInstance

Represents a concrete quest currently present in the city pool.

This later allows multiple instances of the same quest type with different:

- mob counts;
- distances;
- rewards;
- sources;
- expiration times.

#### ItemDefinition

Describes an item type:

- name;
- slot;
- base bonuses;
- later, value, rarity, image, and other permanent properties.

#### ItemInstance

Represents one concrete dropped item.

In the first version an item may be little more than a wrapper around `ItemDefinition`, but this separation later allows adding without restructuring:

- random properties;
- item level;
- quality;
- upgrades;
- unique ID;
- other per-item parameters.

### 22.3. Stat Sources and StatResolver

Final hero combat stats must not be calculated directly inside `hero_state.gd`.

A separate layer is required:

> **`stat_resolver.gd`**

It combines all stat sources:

```text
Hero base parameters
        +
Level growth
        +
Primary attributes
        +
Equipment
        +
Temporary buffs
        +
Future effects
        ↓
    StatResolver
        ↓
    CombatStats
```

`CombatStats` contains the final values used by combat:

- MaxHP;
- Attack;
- AttackSpeed;
- CritChance;
- CritDamage;
- DamageReduction;
- other future combat parameters.

Then:

> `CombatStats → PowerCalculator → Power`

Main consequence:

> **adding equipment must not require changes to CombatSimulator or PowerCalculator**

For example, a sword with `+5 Attack` simply becomes another stat source for `StatResolver`.

### 22.4. HeroState

`hero_state.gd` stores the hero’s current state, but does not need to contain formulas for every system.

At minimum it stores:

- level;
- XP;
- base primary attributes;
- current HP;
- Gold;
- traits;
- current loop state;
- current quest;
- death timer;
- active temporary effects;
- later, references to Inventory, Equipment, and QuestLoot.

Progression formulas live separately in `hero_progression.gd`.

### 22.5. CombatSimulator

`combat_simulator.gd` is responsible only for **one individual fight**.

It receives ready-made hero and mob combat stats and calculates:

- attack intervals;
- normal damage;
- critical hits;
- HP changes;
- victory / defeat.

It must not:

- choose a quest;
- issue a new quest;
- write UI;
- independently place items into inventory;
- generate literary diary text.

### 22.6. PowerCalculator

`power_calculator.gd` contains **one shared Power implementation**.

Hero and mobs use the same function:

> `CombatStats → Power`

A separate `HeroPower` formula and separate `MobPower` formula are not allowed.

### 22.7. Quest Systems

Quest logic is split into three parts.

#### `quest_pool.gd`

Responsible for:

- current 5–7 quests;
- adding;
- removing;
- replacing completed / canceled quests.

#### `quest_evaluator.gd`

Responsible only for selection:

- Hard Filter;
- EstimatedQuestTicks;
- BaseAttractiveness;
- CourageModifier;
- MoralityModifier;
- GreedModifier;
- DivineModifier;
- final QuestScore;
- selection of the best eligible quest.

#### `quest_runner.gd`

Executes an already selected quest:

- travel;
- mob sequence;
- recovery;
- return;
- turn-in;
- defeat and cancellation.

This keeps quest selection and quest execution out of the same large file.

### 22.8. Loot After Prototype 0

The next major stage after completing the current Prototype 0 list is:

> **mob loot and hero equipment**

The architecture therefore already anticipates:

- `ItemDefinition`;
- `ItemInstance`;
- `LootTableDefinition`;
- `LootGenerator`;
- `Inventory`;
- `Equipment`;
- `QuestLoot`.

Full implementation of these systems is not required before Prototype 0 is complete.

### 22.9. QuestLoot

Because of the already approved death rule, loot from the current quest must be separate from permanent inventory.

Intended structure:

```text
Hero
├── Inventory
│   └── saved items
│
├── Equipment
│   └── equipped items
│
└── QuestLoot
    └── everything found during the current quest
```

Future logic:

#### Victory Over a Mob

> `MobDefinition → LootTable → LootGenerator → ItemInstance → QuestLoot`

#### Successful Quest Turn-In

> `QuestLoot → Inventory`

After transfer:

> `QuestLoot.clear()`

#### Hero Death

> `QuestLoot.clear()`

This means the rule:

> **the hero loses all loot acquired during the current quest**

does not require searching the main inventory for recently acquired items and removing them individually.

### 22.10. Equipment

Equipment must not directly modify combat.

Correct chain:

> `Equipment → StatResolver → CombatStats → CombatSimulator / PowerCalculator`

This allows items to be changed without special-case logic inside combat code.

### 22.11. MobDefinition and Future Loot

A future mob card may conceptually look like:

```text
Goblin
Category = HUMANOID

MaxHP = ...
Attack = ...
AttackSpeed = ...
CritChance = ...
CritDamage = ...

XP = 50

LootTable = goblin_loot
```

The mob itself does not decide which concrete item drops.

It only points to a table of possible loot.

`LootGenerator` selects the actual result.

### 22.12. Events and Loose Coupling

Systems must not directly know about every consumer of an event.

For example, after a mob dies, CombatSimulator must not manually:

- update UI;
- write the diary;
- add XP;
- grant loot;
- update the quest;
- modify statistics.

It reports the event as a fact.

Other systems react independently.

Conceptually:

```text
CombatSimulator
      ↓
 mob_defeated
      ↓
 ┌───────────────┬───────────────┬───────────────┐
 HeroProgression QuestRunner     LootGenerator
      ↓                ↓               ↓
     XP          quest progress      QuestLoot
```

UI and Narrative receive already-processed state changes / significant events.

For communication between gameplay objects, prefer signals and explicit interfaces over direct calls from one file into every other system.

### 22.13. Simulation as Coordinator

The main runtime scene may look approximately like:

```text
Main
├── Simulation
│   ├── WorldClock
│   ├── QuestPool
│   ├── QuestRunner
│   ├── GodSystem
│   ├── Diary
│   └── DebugLog
└── UI
```

`simulation.gd` coordinates systems, but must not become a file containing all game logic.

### 22.14. Minimal Global State

Do not create a separate global singleton for every system.

Prototype 0 does not need global:

- GameManager;
- QuestManager;
- CombatManager;
- InventoryManager;
- GodManager.

Most systems belong to the current Simulation.

Use Autoload only for genuinely global functionality when a real need appears.

A future candidate may be SaveManager if saves must serve multiple independent scenes.

### 22.15. UI Is Not Game Logic

UI only:

- sends a player command;
- displays simulation state.

Correct chain:

> **UI → command to gameplay system → state changes → UI displays the result**

Incorrect:

> **a UI button directly changes HP, energy, QuestScore, or cooldown**

This is critical because Prototype 0 must be runnable in automated tests without any UI.

### 22.16. Data Separate from Code

Concrete mobs, items, loot tables, and quest templates must be stored as data.

For example:

```text
data/
├── mobs/
│   ├── goblin.tres
│   ├── wolf.tres
│   └── ...
├── quests/
│   └── ...
├── items/
│   └── ...
└── loot_tables/
    └── ...
```

Adding a new ordinary mob or item must not require creating a new gameplay script.

### 22.17. Tests as Part of the Architecture

Automated tests are especially important for this game because much of its value is in the simulation.

Minimum tests:

#### `combat_tests.gd`

Large batches of fights.

#### `power_tests.gd`

Compare calculated Power against actual win rates.

#### `quest_choice_tests.gd`

Verify:

- Hard Filter;
- traits;
- Greedy;
- DivineModifier;
- selection of the best quest.

#### `stat_tests.gd`

After equipment is introduced:

- correct combination of stat sources;
- correct CombatStats recalculation;
- Power changing correctly when an item is equipped / unequipped.

### 22.18. What Not to Build Yet

Even with future equipment in mind, do not build full systems for:

- factions;
- world map;
- multiple cities;
- market;
- crafting;
- dungeons;
- NPC heroes;
- world generation;
- complex item effects;
- set bonuses;
- rarity and affixes;
- item upgrading.

The architecture must allow them to be added later, but Prototype 0 must not pre-implement systems that do not yet test the core idea.

### 22.19. Main Architectural Test

After Prototype 0 is complete, it must be possible to add:

> **the first dropped sword with `+5 Attack`**

without rewriting:

- CombatSimulator;
- PowerCalculator;
- QuestEvaluator;
- WorldClock;
- death system;
- god system;
- diary.

If adding the first item requires changing the core of combat or quest selection, the architecture is wrong.

This is the main practical criterion for whether the foundation is sound.

---

## 23. Main Constraint

> **Prototype 0 must be small enough that throwing it away entirely would not be painful.**

Its job is not to become the permanent foundation at any cost.

Its job is to cheaply answer:

> **is this idea worth building a full game around?**

---

## 24. Obsolete Decisions from Previous Versions — DO NOT RESTORE AUTOMATICALLY

This section exists specifically for handing the project to another AI or developer.

Previous Prototype 0 Scope versions contain historical variants of mechanics. Some are useful as an explanation of the project’s evolution, but they **are not the current design**.

If an older document conflicts with this version, this version wins.

### 24.1. Old Hard Filter `±5`

Historical example:

> `HeroPower = 25`, eligible range approximately `20–30`

is obsolete.

Current rule:

> **`MobPower <= HeroPower × 0.95`**

There is no lower bound.

### 24.2. Old Quadratic Combat-Cost Estimate

Historical formula:

> `BaseCombatTicks × (MobPower / HeroPower)^2`

is no longer considered current.

Reason: actual internal combat and the rule:

> **1 individual fight = 1 world tick + separate recovery ticks**

were introduced later.

The current `EstimatedCostPerMob` should be tuned from this actual model.

### 24.3. Old DPS Without Correct AttackSpeed Semantics

Older versions contained:

> `DPS = Attack × AttackSpeed × CritModifier`

This is incompatible with the later approved rule:

> `AttackSpeed = 1.0` means one attack every 2 seconds.

Current formula:

> **`DPS = Attack × (AttackSpeed / 2) × CritModifier`**

Critical chance and critical damage are already included in DPS.

### 24.4. General Percentage / Weight Roulette for Quest Selection

Older rough sections may describe quest selection through weights and a random roll.

That decision has been replaced.

Current rule:

> **Hard Filter → QuestScore → highest QuestScore**

Randomness may only be added later among near-equivalent best options.

An obviously inferior quest must not win because of a small random probability.

### 24.5. Abstract Outcome Roll Instead of Real Combat

Older rough Prototype 0 sections allowed quest success to be calculated by a simple formula / roll without actual combat.

That is obsolete.

Current Prototype 0 already uses:

- one mob as one separate fight;
- internal AttackSpeed intervals;
- actual damage;
- CritChance;
- CritDamage;
- HP;
- death;
- recovery between mobs.

### 24.6. Old 3–5 Mixed Quest Types

Older examples included ruins, errands, and other different activity types.

For the first code version, this has intentionally been simplified.

Current decision:

- approximately **5–7 available quests** at all times;
- several test mob types;
- one simple combat quest per mob type;
- more varied quest types are added later.

### 24.7. The Hero Does Not Generate Their Own Quest

Quests exist as offers in the abstract city / tavern.

The hero only evaluates the current pool.

After a quest is completed or canceled, the freed slot is filled by a new quest.

Future factions, reputation, and world events may add special quests, but that is outside Prototype 0.

### 24.8. Old Minimal God System

Historically Prototype 0 expected one soft influence ability.

The current version uses four interventions:

1. instant resurrection;
2. healing;
3. combat buff;
4. guidance toward a specific quest through `+0.20 QuestScore`.

### 24.9. Old Trait Examples

Early drafts used generic examples such as:

- caution ↔ risk;
- greed ↔ selflessness.

The current Prototype 0 trait set is:

- Coward ↔ Brave;
- Dishonorable ↔ Noble;
- Greedy.

The hero starts with 1–2 compatible traits.

### 24.10. Old Examples Are Not Hidden Requirements

Numbers, quest names, distances, durations, and step-by-step examples from old documents are illustrations unless they are repeated as an approved rule in the current version.

Another AI **must not restore an old decision merely because it was described in detail in a previous file**.
