# The Hero’s Story — Dependencies and Invariants

This document records current cross-file dependencies and contracts that can be broken by refactoring.

## Runtime flow

```text
main_ui.gd
→ Simulation
→ WorldClock / CombatSession
→ QuestPool / QuestEvaluator
→ QuestRunner
→ QuestEvent
→ QuestNarrator
→ DebugLog
```

Live combat:

```text
CombatSession
→ CombatResult
→ Simulation
    ├── victory → HeroProgression XP / possible stat refresh
    └── result → QuestRunner
→ exactly one completed world tick
```

## World time

`WorldClock` remains the single world-tick source.

Contracts:
- active combat freezes ordinary world-tick progress;
- a resolved fight still counts as exactly one world tick;
- `DEAD_RESPAWNING` advances only through normal world ticks;
- pause therefore freezes the respawn timer;
- developer speed controls accelerate the respawn timer in the same way as travel/recovery.

## Combat / death boundary

`CombatSession` owns only one duel and reports victory or defeat through `CombatResult`.

It must not:
- cancel quests;
- award XP;
- run the resurrection timer;
- restore city HP;
- write UI or diary state.

Death handling begins only after the completed `CombatResult` reaches the quest/simulation layer.

## Primary attributes

`HeroState` stores the five Prototype 0.2 primary attributes. `StatResolver` is the only normal conversion path from those attributes to current combat-facing values.

Current contracts:
- a new Warrior starts with STR / DEX / INT / CON / WIS all equal to 5;
- STR grants +2 physical Damage and +5 percentage points Critical Damage per point;
- DEX grants +10 Accuracy, +2 Dodge, and +3 percentage points Critical Chance per point;
- CON grants +20 MaxHP and +1 Armor per point;
- INT and WIS currently remain stored without a resolved Warrior combat bonus;
- primary attributes do not change Attack Speed;
- until the deity-guided and personality-directed growth channels exist, level-up grants +2 STR / +1 DEX / +1 CON only; the missing divine point is neither assigned nor stored;
- current experimental equipment Strength uses the same centralized STR conversion and no longer grants MaxHP;
- Armor, Accuracy/Dodge, elemental Resistance, and Block are resolved through the shared `DamageResolver`; `CombatStats` does not store a parallel `damage_reduction` value.

## Autonomous quest selection

Owners:
- `scripts/quests/quest_pool.gd` — immutable templates and current quest offers;
- `scripts/quests/quest_evaluator.gd` — Hard Filter and QuestScore;
- `scripts/quests/quest_runner.gd` — execution only;
- `scripts/core/simulation.gd` — coordination between selection and execution.

Current decision flow:

```text
CHOOSING_QUEST
→ QuestPool current single-city offers
→ Hard Filter: MobPower <= base persistent HeroPower × 0.95
→ WeakestAllowedMobPower among allowed quests
→ RelativeRecoveryCost = MobPower / WeakestAllowedMobPower
→ EstimatedCostPerMob = 1 + RelativeRecoveryCost
→ EstimatedQuestTicks = Distance × 2 + MobCount × EstimatedCostPerMob + 1
→ BaseAttractiveness = GoldReward / EstimatedQuestTicks
→ current Courage / Morality / Greed modifiers
→ optional DivineModifier = +0.20 for the currently guided eligible offer, otherwise 0
→ strict highest QuestScore
→ selected QuestOffer assigned to QuestRunner
→ QuestRunner executes
```

Contracts:
- Hard Filter uses full-HP **base persistent HeroPower**, not current injured HP and not temporary combat-only bonuses;
- temporary finite effects such as the divine five-fight `+3 Attack` do not alter HeroPower or Hard Filter;
- conditional Noble/Dishonorable +10% category damage does not alter HeroPower or Hard Filter;
- mob count does not affect Hard Filter;
- filtered-out quests never participate in QuestScore;
- the weakest allowed mob is normalized to recovery cost `1`;
- one fight contributes exactly `1` estimated tick before recovery cost;
- fractional estimated ticks are allowed because this is pre-choice estimation only;
- current selection has no general roulette;
- starting traits use the shared seeded RNG and opposing traits are mutually exclusive;
- personality modifiers apply only after Hard Filter;
- Noble deals 10% more actual damage to MONSTER and Dishonorable to HUMANOID;
- quest guidance may add `+0.20` only to one current eligible offer for the next selection action and cannot bypass Hard Filter;
- QuestEvaluator must not execute quests;
- QuestRunner must not calculate Hard Filter or QuestScore;
- UI must not choose quests;
- changing `.tres` mob/quest tuning must not require changing selection code.

`QuestPool` loads immutable reusable quest templates from `data/quests` and uses the shared seeded RNG to create current `QuestOffer` objects. In the current one-city Prototype 0 build, every current initial-city template is exposed simultaneously; with the present content set this means 13 offers. Templates contain only inclusive ranges. Each offer owns rolled count, distance, and gold per mob; its total Gold is a derived value, always `MobCount × GoldPerMob`.

There is no current 5–7-offer cap. Stronger offers remain in the single-city pool and are excluded from actual consideration by Hard Filter until the hero is strong enough.

After a successful turn-in, only that accepted offer is regenerated from the same immutable template in the same slot. After fatal cancellation, its regeneration waits until city recovery returns the hero to `CHOOSING_QUEST`. Unaccepted offers must retain their exact runtime values and identities.

## Quest execution and death

`scripts/quests/quest_runner.gd` owns the current quest-execution states.

On defeat it must:
- clamp hero current HP to 0;
- cancel `active_quest`;
- clear current quest execution counters;
- enter `DEAD_RESPAWNING` with exactly 100 ticks remaining;
- not grant Gold.

XP remains outside `QuestRunner`. `Simulation` applies mob XP through `HeroProgression` only when `combat_result.hero_won` is true.

Therefore a mob that kills the hero cannot grant XP, while previously earned XP and levels remain untouched.

## Natural resurrection

Current contract:

```text
DEAD_RESPAWNING (100 world ticks)
→ current HP = 1
→ RECOVERING_IN_CITY
→ +20% MaxHP per world tick
→ full MaxHP
→ CHOOSING_QUEST
```

The resurrection tick changes the state to `RECOVERING_IN_CITY` but does not also perform the first recovery tick. Recovery begins on the following world tick.

The hero cannot start a new quest while injured.

## Structured events and narrative

Death-related gameplay reports structured facts through `QuestEvent`:
- `HERO_DIED`;
- `HERO_WAITING_FOR_RESURRECTION`;
- `HERO_RESURRECTED`;
- `HERO_RECOVERING_IN_CITY`.

`QuestNarrator` owns their current Russian wording.

The diary remains separate and is not implemented as part of the death slice.

## UI boundary

`main_ui.gd` coordinates top-level screens and the remaining main developer panels. It instantiates `InventoryScreen`, `GodPanel`, and `NarrativePanel`, supplies the same live `Simulation` to each, and owns Inventory Back/close navigation.

It may read `QuestRunner.respawn_ticks_remaining` for the current developer-state label, but it does not decrement the timer or change HP/state.

`scripts/ui/screens/inventory_screen.gd` reads equipped and retained-item state to display icons, quality outlines, tooltips, and portrait overlays. Its equipment layout is fixed to five armor slots left of the portrait, main-hand/off-hand below it, and necklace/earrings/two-rings/belt on the right. It does not grant, equip, drop, or modify items.

`scripts/ui/components/god_panel.gd` reads God/hero state and sends healing, blessing, and resurrection requests only through `Simulation`. It does not mutate `GodState`, HP, effects, cooldowns, or respawn state directly.

`scripts/ui/components/narrative_panel.gd` reads `Diary` and subscribes to `DebugLog`/world-time signals to display text and maintain autoscroll. It does not create or rewrite gameplay facts.

## God-system core

`scripts/god/god_state.gd` owns god energy, cooldowns, and pending quest guidance. `HeroState.active_effects` owns the active blessing and remaining fights. `Simulation` owns command validation and coordination with hero, quest, stats, and combat systems.

Contracts:
- energy starts/maxes at 100 and recovers +1 every 6 completed world ticks, including fight and resurrection ticks;
- pause freezes recovery and cooldowns because no world ticks complete;
- instant resurrection spends `RemainingRespawnTicks × 0.5`, bypasses the timer, and uses the shared post-resurrection contract:

```text
resurrection
→ 1 HP
→ RECOVERING_IN_CITY
```

- healing cannot be used while dead or at full HP; during active combat it modifies live CombatSession HP rather than stale HeroState HP;
- combat blessing creates a generic `+3 Attack` active effect; `StatResolver` includes it in effective CombatStats, while base CombatStats/HeroPower remain unchanged;
- CombatSession receives ready-made effective CombatStats and must not accept a separate flat Attack bonus;
- the active blessing consumes one HeroState effect charge after every finished fight and refreshes resolved stats when changed or removed;
- Noble/Dishonorable conditional damage and temporary blessings are displayed separately in UI and intentionally excluded from HeroPower/Hard Filter;
- guidance can target only a current tavern offer, never bypasses Hard Filter, and is consumed by the next quest-selection action even if it does not win;
- the guided eligible offer receives `DivineModifier = +0.20` for that one selection action; all other offers receive `0`;
- UI must call Simulation commands rather than mutate GodState, HP, quest scores, combat stats, or respawn state directly.

## Current equipment reward slice and future loot hook

Current seven-piece Ironward Vanguard equipment flow:

```text
one of seven reward-bearing QuestDefinitions
→ slot-specific equal-third Common / Uncommon / Rare ItemDefinition pool
→ every successful turn-in event
→ Simulation rolls through shared seeded RNG and creates ItemInstance
→ quality comparison against the matching HeroState.Equipment slot
→ equip/replace or HeroState.Inventory
→ StatResolver refreshes BaseCombatStats / CombatStats
→ UI displays equipment/inventory icons, quality outlines, tooltip, and hero overlay
```

Contracts:
- `ItemDefinition` is immutable data; `ItemInstance` is the acquired object;
- one reward is granted after every successful turn-in of the seven configured quests, never on defeat;
- the three definitions are selected with exact equal thirds (`randi_range(0, 2)`), not rounded independent 33% checks;
- `QuestRunner` does not equip the item or calculate its stats;
- `Simulation` coordinates reward rolling, quality comparison, automatic equip/replacement, inventory routing, stat refresh, HP adjustment, and logging;
- the first item in each configured equipment slot equips automatically; only strictly higher quality replaces it; equal or worse quality enters Inventory;
- replaced equipment enters Inventory before the new item becomes the active stat source;
- Inventory keeps at most 36 item instances in FIFO order; adding item 37 drops the oldest regardless of quality;
- persistent equipment affects base HeroPower/Hard Filter and effective combat stats;
- Armor uses `PhysicalTaken = 100 / (100 + Armor)` through `DamageResolver`;
- Common/Uncommon/Rare armor bonuses are `20/10/1`, `25/15/2`, and `35/20/3` MaxHP/Armor/Strength;
- Common/Uncommon/Rare sword bonuses are `3/5%/10%`, `4/7%/15%`, and `5/10%/20%` Attack/CritChance/CritDamage;
- Common/Uncommon/Rare shield bonuses are `10/20`, `15/25`, and `20/30` MaxHP/Armor;
- increasing MaxHP at turn-in increases current HP by the same delta, preserving full-health state;
- Common has no outline; Uncommon uses a soft green 1.0/0.55/0.25 three-band outline; Rare uses the same blue outline;
- static ItemPower must use `PowerCalculator`, not a parallel scoring formula: calculate the approved fixed `1000 HP / 100 Armor / 50 Dodge / 100 Accuracy / 100 Damage / 1.0 AttackSpeed / 25% CritChance / 200% CritDamage / 100 each elemental Resistance / 0 Block` profile with and without the item's resolved stats, then subtract its reference Power of approximately `433.013`;
- temporary Strength on the current experimental items contributes +2 physical Damage and +5 percentage points Critical Damage per point before ItemPower is calculated, with no Strength-derived MaxHP;
- ItemPower is a stable item-comparison rating and is not directly added to the hero's runtime Power.
- helmet, chest, gloves, pants, and boots each use a dedicated aligned paper-doll overlay from their `ItemDefinition`; sword and shield still have no hero portrait overlay, and UI must not synthesize worn art from equipment icons;
- no set-completion bonus exists in the current slice.

General item interactions and QuestLoot are still not implemented. When QuestLoot exists, death must clear only current-quest loot before entering the existing respawn path. Permanent equipment and retained Inventory must remain separate.

## Tests protecting this contract

`tests/test_death_respawn.gd` verifies:
- one lost fight still consumes one world tick;
- active quest cancellation;
- no XP from the losing mob;
- no Gold from the failed quest;
- retention of prior level/XP;
- exactly 100 respawn ticks;
- resurrection at exactly 1 HP;
- 20% MaxHP city recovery;
- full recovery before `CHOOSING_QUEST`.

`tests/test_quest_offer_refresh_lifecycle.gd` protects replacement of only the accepted offer without assuming a fixed number of tavern slots.

`tests/test_god_abilities_integration.gd` protects the one-selection `DivineModifier = +0.20` contract and the separation between base HeroPower and temporary combat effects.

## Combat validation telemetry

`Simulation` owns lightweight development-only cumulative combat-result counters keyed by mob id.

Contracts:
- recording statistics must not alter combat, XP, recovery, death, or quest outcomes;
- one finished fight increments exactly one result;
- counters track total fights, hero wins, hero losses, and derived winrate;
- cumulative combat statistics remain in `Simulation` and are displayed by UI; they are not written into the debug log;
- the same mechanism works for any mob definition and is not Wolf-specific.

`Simulation` may receive an explicit fixed quest for regression/development tests. Its default remains the existing Goblin quest. Passing `null` enables autonomous QuestPool selection; the developer UI now uses this autonomous mode.

## Debug-log retention

Owner:
- `scripts/narrative/debug_log.gd`

Contracts:
- visible history is limited to the latest 100 world ticks;
- retention is based on world-tick ids, not entry count;
- every line from one individual fight is tagged with the same upcoming world tick because one fight consumes exactly one world tick;
- trimming log history must not affect simulation state or cumulative combat statistics.
