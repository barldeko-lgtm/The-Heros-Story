# The Hero’s Story — Current Project State

This document describes what is **actually implemented now**.

## Current development focus

The project is at the early Prototype 0 foundation stage.

Implemented:
- one autonomous hero;
- Warrior starting stats;
- world tick;
- pause and developer speed controls (×0, ×1, ×2, ×5, ×10, ×20, ×100);
- one shared Power calculation for hero and mobs;
- a live one-on-one combat session with timed strikes;
- one goblin definition;
- one quest definition;
- a placeholder autonomous quest loop;
- structured quest events;
- separate quest narration;
- debug log;
- empty diary shell;
- rough developer UI;
- narrow automated tests.

Current next major gameplay step:
- level-up execution.

Still missing from the current build:
- level-up execution;
- quest pool and quest choice;
- traits;
- death/resurrection;
- diary episodes;
- god system;
- seeded reproducible RNG.

## World time

`scripts/core/world_clock.gd` owns the current world tick.

Current behaviour:
- 1 world tick = 10 simulation seconds;
- partial tick progress is retained;
- one update may complete multiple ticks;
- `Simulation` applies the selected time scale before advancing the clock;
- time scale `0` pauses world-tick progress without resetting partial progress.
- an active combat session freezes world-tick progress; the selected time scale accelerates its internal seconds too.

Current UI exposes ×0, ×1, ×2, ×5, ×10, ×20, ×100.

## Hero and stats

`scripts/hero/hero_state.gd` stores:
- name;
- class;
- level and XP;
- STR / AGI / INT;
- current HP;
- Gold;
- traits;
- current loop state;
- active quest;
- active effects.

Final combat stats are resolved separately:

```text
HeroState
    +
HeroProgression
    ↓
StatResolver
    ↓
CombatStats
```

Starting Warrior resolves to:
- MaxHP 110;
- Attack 7;
- AttackSpeed 1.12;
- CritChance 12%;
- CritDamage 156%.

## Shared Power

`scripts/combat/power_calculator.gd` contains the single Power formula.

Both hero and mobs use it through the same `CombatStats` structure.

Current starting Hero Power is approximately 21.45.

## Combat

`scripts/combat/combat_session.gd` resolves one live hero-versus-mob duel using final `CombatStats`.

Current behaviour:
- each side attacks on its own `2 / AttackSpeed` interval;
- the hero’s first attack has a 0.5-second opening advantage;
- same-timestamp attacks resolve together;
- a simultaneous death counts as hero defeat;
- critical hits retain fractional damage internally.
- each resolved strike enters the debug log immediately while the world clock is frozen.

Each ordinary quest mob uses a live combat session. Victory immediately grants that mob's XP; level-up and hero death are still outside the current loop.

## Current content

Current mob:
- `data/mobs/0001_goblin.tres`

Current quest:
- `data/quests/0001_goblin_road_problem.tres`

Schemas:
- `scripts/model/definitions/mob_definition.gd`
- `scripts/model/definitions/quest_definition.gd`

Ordinary mobs and quests are data-driven.

## Current quest loop

`scripts/quests/quest_runner.gd` currently executes one configured quest.

Implemented states:
- `CHOOSING_QUEST`
- `TRAVEL_TO_QUEST`
- `DOING_QUEST`
- `RECOVERING_AFTER_FIGHT`
- `RETURNING_TO_CITY`
- `TURNING_IN_QUEST`

Current loop:

```text
choose current quest
→ travel
→ arrive
→ one fight per mob
→ recover 20% MaxHP per world tick until full after every fight
→ return
→ turn in
→ receive Gold
→ repeat
```

Arrival is its own world tick. The first fight starts immediately after it, with the world clock frozen. Internal strikes run over real seconds scaled by the selected developer speed. When the fight ends, exactly one world tick is counted. Only on the following world ticks does the hero recover 20% MaxHP per tick until fully healed. Then the next fight or return travel begins.

Hero death is deliberately not implemented in this slice. If the current test content ever produces a loss, the quest runner stops with a developer error instead of inventing death/teleport behaviour.

There is no quest pool and no choice among several quests yet.

## Quest events and narrative

Current chain:

```text
QuestRunner
→ QuestEvent
→ QuestNarrator
→ DebugLog
```

`scripts/quests/quest_event.gd` stores structured quest facts.

`scripts/narrative/quest_narrator.gd` converts them to Russian log text.

## Debug log and diary

`scripts/narrative/debug_log.gd` stores technical tick/event messages.

`scripts/narrative/diary.gd` currently exists only as an empty storage shell.

The diary UI tab exists, but no gameplay system writes diary episodes yet.

## UI

Current runtime scene:
- `scenes/main/main.tscn`

Current UI:
- `scripts/ui/main_ui.gd`

The UI displays:
- hero state;
- primary and combat stats;
- Hero Power;
- active quest;
- tick progress;
- speed controls;
- debug log;
- diary tab.

The UI currently creates the `Simulation` instance itself.

## Tests

Current tests cover:
- world clock;
- simulation speed;
- isolated combat, critical hits, and simultaneous hero death;
- timed live combat, frozen world ticks, and immediate combat logging;
- frame-step combat progression without zero-time hangs;
- hero name loading;
- starting stat resolution;
- goblin definition;
- quest definition;
- debug log;
- quest fights, XP, and full recovery;
- structured quest events;
- quest narration.
