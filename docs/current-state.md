# The Hero’s Story — Current Project State

This document describes what is **actually implemented now**.

## Current development focus

The project is at the early Prototype 0 foundation stage.

Implemented:
- one autonomous hero;
- Warrior starting stats and level-up progression;
- world tick;
- pause and developer speed controls (×0, ×1, ×2, ×5, ×10, ×20, ×100);
- one shared seeded RNG for current simulation randomness;
- one shared Power calculation for hero and mobs;
- live one-on-one combat with timed strikes;
- per-mob XP and post-fight recovery;
- death, 100-tick natural resurrection, and city recovery;
- three mob definitions: Goblin, Wolf, and Bear;
- three quest definitions: Goblin road problem, Wolf hunt, and Bear hunt;
- a single autonomous quest loop;
- structured quest/death events;
- separate quest narration;
- debug log;
- empty diary shell;
- rough developer UI;
- automated regression tests and GitHub CI.

Current next major gameplay step:
- automated large-batch Power validation, then the quest pool and autonomous quest choice.

Still missing from the current build:
- large-batch Power validation;
- quest pool and quest choice;
- traits;
- diary episodes;
- god system.

## World time

`scripts/core/world_clock.gd` owns the current world tick.

Current behaviour:
- 1 world tick = 10 simulation seconds;
- partial tick progress is retained;
- one update may complete multiple ticks;
- `Simulation` applies the selected time scale before advancing the clock;
- time scale `0` pauses world-tick progress without resetting partial progress;
- an active combat session freezes world-tick progress; the selected time scale accelerates its internal seconds too;
- natural resurrection uses the same world-tick timeline and therefore respects pause and developer speed controls.

Current UI exposes ×0, ×1, ×2, ×5, ×10, ×20, ×100.

## Hero and stats

`scripts/hero/hero_state.gd` stores mutable hero state, including the current loop state.

Current loop states include:
- `CHOOSING_QUEST`;
- `TRAVEL_TO_QUEST`;
- `DOING_QUEST`;
- `RECOVERING_AFTER_FIGHT`;
- `RETURNING_TO_CITY`;
- `TURNING_IN_QUEST`;
- `DEAD_RESPAWNING`;
- `RECOVERING_IN_CITY`.

`scripts/hero/hero_progression.gd` owns XP application and Warrior level growth.

Each level:
- costs 1000 XP;
- carries excess XP forward;
- adds +20 direct MaxHP through the level bonus;
- adds +4 STR;
- adds +1 AGI.

Final combat stats remain:

```text
HeroState + HeroProgression
→ StatResolver
→ CombatStats
```

After a mid-quest level-up, `Simulation` refreshes `CombatStats` before recovery and the next fight.

## Combat

`scripts/combat/combat_session.gd` resolves one live hero-versus-mob duel using final `CombatStats`.

Current behaviour:
- each side attacks on its own `2 / AttackSpeed` interval;
- the hero’s first attack has a 0.5-second opening advantage;
- same-timestamp attacks resolve together;
- a simultaneous death counts as hero defeat;
- critical hits retain fractional damage internally;
- each resolved strike enters the debug log immediately while the world clock is frozen.

Victory grants the defeated mob's XP through `HeroProgression`, then starts normal post-fight recovery.

## Death and resurrection

A combat defeat now closes the current quest instead of producing a developer error.

On death:
- current HP is clamped to `0`;
- the current quest is canceled immediately;
- no XP is granted for the mob that defeated the hero;
- no quest turn-in Gold is granted;
- XP and levels earned before the defeat are retained;
- the hero enters `DEAD_RESPAWNING` in the city;
- natural resurrection takes exactly 100 world ticks;
- the debug log reports the remaining resurrection ticks.

After the 100th respawn tick:
- the hero resurrects with exactly **1 HP**;
- enters `RECOVERING_IN_CITY`;
- recovers 20% MaxHP per world tick;
- only after reaching full HP returns to `CHOOSING_QUEST`.

Full loot loss is still only a future hook because QuestLoot/inventory do not exist yet.


## Current Power calibration content

`data/mobs/0002_wolf.tres` is the current near-equal-Power calibration mob:
- category: MONSTER;
- MaxHP 72.55;
- Attack 8;
- AttackSpeed 1.35;
- CritChance 12%;
- CritDamage 150%;
- Power ≈ 20.38, intentionally ≈95% of starting HeroPower ≈21.45;
- XP is temporarily 0 so repeated Power testing does not level the hero and invalidate the comparison.

`data/quests/0002_wolf_hunt.tres` contains:
- 8 wolves;
- distance 4 km;
- reward 80 Gold.

The developer UI currently starts this Wolf quest so repeated manual ×100 testing is immediately available. `Simulation.new()` without a supplied quest still defaults to the Goblin quest for existing regression tests.

After every completed fight, `Simulation` updates cumulative per-mob combat statistics. These statistics are shown in a fixed developer UI panel and are no longer written into the debug log.

## Current quest loop

Current successful loop:

```text
choose quest
→ travel
→ fight
→ XP / possible level-up
→ full post-fight recovery
→ next mob or return
→ turn in
→ Gold
→ repeat
```

Current defeat loop:

```text
fight lost
→ quest canceled
→ DEAD_RESPAWNING for 100 ticks
→ resurrect at 1 HP
→ RECOVERING_IN_CITY
→ full HP
→ CHOOSING_QUEST
```

There is still no quest pool and no choice among several quests.

## Quest events and narrative

Current chain remains:

```text
QuestRunner
→ QuestEvent
→ QuestNarrator
→ DebugLog
```

Death, natural resurrection, and city recovery use structured events rather than hard-coded UI text.

The diary remains unimplemented and receives no gameplay events yet.



### Bear calibration mob

`data/mobs/0003_bear.tres` is the second 95%-Power calibration profile:
- category: MONSTER;
- MaxHP 180;
- Attack 5;
- AttackSpeed 0.90;
- CritChance 5%;
- CritDamage 150%;
- Power ≈ 20.37, or ≈94.98% of starting HeroPower;
- XP remains 0 during calibration.

`data/quests/0003_bear_hunt.tres` contains:
- 4 bears;
- distance 3 km;
- reward 40 Gold.

The developer UI currently starts the Bear hunt for manual ×100 Power validation.

## Debug log window

The debug log retains only the last 100 world ticks.

Retention is tick-based rather than line-based:
- ordinary tick messages belong to their world tick;
- all start/action/result lines from one fight belong to the single world tick consumed by that fight;
- therefore a verbose fight still counts as exactly one tick for log retention.

## UI

Current layout:
- hero panel on the left;
- log/diary in the center;
- opponent panel on the right.

The hero panel displays HP with one decimal place and now shows:
- dead state with remaining resurrection ticks;
- city-recovery state after resurrection.

The opponent panel is populated only during active combat.

A separate panel in the bottom-right corner continuously shows cumulative combat count, wins, losses, and winrate for the current quest mob.

## Tests

Current coverage includes:
- world time and speed controls;
- seeded RNG;
- hero progression;
- combat timing, crits, and simultaneous death;
- quest combat/XP/recovery;
- death and quest cancellation;
- exact 100-tick natural resurrection;
- resurrection at 1 HP;
- city recovery to full HP;
- retention of earlier XP/levels and no Gold for a failed quest.


UI note: during active combat, the hero panel displays live CombatSession HP rather than only the last committed HeroState HP.
