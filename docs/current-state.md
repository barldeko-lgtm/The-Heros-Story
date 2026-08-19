# The Hero’s Story — Current Project State

This document describes what is **actually implemented now**.

## Current development focus

The project is at the early Prototype 0 foundation stage.

Implemented:
- one autonomous hero;
- Warrior starting stats;
- world tick;
- developer speed controls;
- one shared Power calculation for hero and mobs;
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
- real one-on-one combat and progression.

Still missing from the current build:
- real combat;
- XP gain and level-up execution;
- post-fight recovery;
- quest pool and quest choice;
- traits;
- death/resurrection;
- diary episodes;
- god system;
- seeded reproducible RNG;
- pause and the required higher developer speed controls.

## World time

`scripts/core/world_clock.gd` owns the current world tick.

Current behaviour:
- 1 world tick = 10 simulation seconds;
- partial tick progress is retained;
- one update may complete multiple ticks;
- `Simulation` applies the selected time scale before advancing the clock.

Current UI exposes ×1, ×2, ×5, ×10, ×20.

Pause and ×100 acceleration are not implemented yet.

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
- `RETURNING_TO_CITY`
- `TURNING_IN_QUEST`

Current loop:

```text
choose current quest
→ travel
→ placeholder quest completion
→ return
→ turn in
→ receive Gold
→ repeat
```

`DOING_QUEST` is still a placeholder. It does not run combat, mob sequences, XP, recovery, death, or loot.

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
- hero name loading;
- starting stat resolution;
- goblin definition;
- quest definition;
- debug log;
- placeholder quest loop;
- structured quest events;
- quest narration.
