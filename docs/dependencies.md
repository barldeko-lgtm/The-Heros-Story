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

## Autonomous quest selection

Owners:
- `scripts/quests/quest_pool.gd` — immutable templates and current quest offers;
- `scripts/quests/quest_evaluator.gd` — Hard Filter and QuestScore;
- `scripts/quests/quest_runner.gd` — execution only;
- `scripts/core/simulation.gd` — coordination between selection and execution.

Current decision flow:

```text
CHOOSING_QUEST
→ QuestPool available quests
→ Hard Filter: MobPower <= HeroPower × 0.95
→ WeakestAllowedMobPower among allowed quests
→ RelativeRecoveryCost = MobPower / WeakestAllowedMobPower
→ EstimatedCostPerMob = 1 + RelativeRecoveryCost
→ EstimatedQuestTicks = Distance × 2 + MobCount × EstimatedCostPerMob + 1
→ BaseAttractiveness = GoldReward / EstimatedQuestTicks
→ current Courage / Morality / Greed modifiers
→ current DivineModifier = 0
→ strict highest QuestScore
→ selected QuestOffer assigned to QuestRunner
→ QuestRunner executes
```

Contracts:
- Hard Filter compares full HeroPower, not current injured HP;
- mob count does not affect Hard Filter;
- filtered-out quests never participate in QuestScore;
- the weakest allowed mob is normalized to recovery cost `1`;
- one fight contributes exactly `1` estimated tick before recovery cost;
- fractional estimated ticks are allowed because this is pre-choice estimation only;
- current selection has no general roulette;
- starting traits use the shared seeded RNG and opposing traits are mutually exclusive;
- personality modifiers apply only after Hard Filter;
- Noble deals 10% more actual damage to MONSTER and Dishonorable to HUMANOID;
- QuestEvaluator must not execute quests;
- QuestRunner must not calculate Hard Filter or QuestScore;
- UI must not choose quests;
- changing `.tres` mob/quest tuning must not require changing selection code.

`QuestPool` loads immutable reusable quest templates from `data/quests` and uses the shared seeded RNG to create current `QuestOffer` objects. Templates contain only inclusive ranges. Each offer owns rolled count, distance, and gold per mob; its total Gold is a derived value, always `MobCount × GoldPerMob`. After a successful turn-in, only that accepted offer is regenerated in the same slot. After fatal cancellation, its replacement waits until city recovery returns the hero to `CHOOSING_QUEST`. Unaccepted offers must retain their exact runtime values and identities.


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

`main_ui.gd` only displays simulation state.

It may read `QuestRunner.respawn_ticks_remaining` for the current developer-state label, but it does not decrement the timer or change HP/state.

## Future god-resurrection hook

The current natural resurrection path establishes the shared post-resurrection contract:

```text
resurrection
→ 1 HP
→ RECOVERING_IN_CITY
```

The future god system may bypass the remaining natural timer, but must not move resurrection logic into combat or UI.

## Future loot hook

QuestLoot is not implemented yet.

When it exists, death must clear only current-quest loot before entering the existing respawn path. Permanent inventory/equipment must remain separate.

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

