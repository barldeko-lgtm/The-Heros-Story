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
- a live one-on-one combat session with timed strikes;
- per-mob XP and post-fight recovery;
- one goblin definition;
- one quest definition;
- a single autonomous quest loop;
- structured quest events;
- separate quest narration;
- debug log;
- empty diary shell;
- rough developer UI;
- narrow automated tests.

Current next major gameplay step:
- automated large-batch Power validation, then the quest pool and autonomous quest choice.

Still missing from the current build:
- large-batch Power validation;
- quest pool and quest choice;
- traits;
- death/resurrection;
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

`scripts/hero/hero_progression.gd` now owns XP application and Warrior level growth.

Each level:
- costs 1000 XP;
- carries excess XP forward;
- adds +20 direct MaxHP through the level bonus;
- adds +4 STR;
- adds +1 AGI.

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

After a mid-quest level-up, `Simulation` refreshes `CombatStats` before recovery and the next fight.

## Shared Power

`scripts/combat/power_calculator.gd` contains the single Power formula.

Both hero and mobs use it through the same `CombatStats` structure.

Current starting Hero Power is approximately 21.45.

## Seeded randomness

`scripts/core/seeded_rng.gd` owns the current seeded `RandomNumberGenerator`.

`Simulation` passes the same RNG to:
- hero-name selection;
- live combat critical-hit rolls.

The developer UI creates a time-based seed for each run and displays it in the hero panel.

Creating `Simulation` with the same explicit seed and advancing it the same way reproduces the current random sequence.

## Combat

`scripts/combat/combat_session.gd` resolves one live hero-versus-mob duel using final `CombatStats`.

Current behaviour:
- each side attacks on its own `2 / AttackSpeed` interval;
- the hero’s first attack has a 0.5-second opening advantage;
- same-timestamp attacks resolve together;
- a simultaneous death counts as hero defeat;
- critical hits retain fractional damage internally;
- each resolved strike enters the debug log immediately while the world clock is frozen.

Each ordinary quest mob uses a live combat session. Victory grants that mob's XP through `HeroProgression`; level-up applies immediately after the fight and the new stats start affecting recovery and the next fight.

Hero death is still outside the current slice.

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
→ XP / possible level-up
→ recover 20% MaxHP per world tick until full
→ return
→ turn in
→ receive Gold
→ repeat
```

Arrival is its own world tick. The first fight starts immediately after it, with the world clock frozen. Internal strikes run over real seconds scaled by the selected developer speed. When the fight ends, exactly one world tick is counted.

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

Level-up is also written to the current debug log.

`scripts/narrative/diary.gd` currently exists only as an empty storage shell.

The diary UI tab exists, but no gameplay system writes diary episodes yet.

## UI

Current runtime scene:
- `scenes/main/main.tscn`

Current UI:
- `scripts/ui/main_ui.gd`

The UI is currently arranged as:
- hero panel on the left;
- log/diary in the center;
- opponent panel on the right.

The hero panel displays current HP with one decimal place.

During an active fight, the opponent panel displays:
- mob name;
- current / MaxHP with one decimal place;
- Attack;
- AttackSpeed;
- CritChance;
- CritDamage;
- MobPower.

Outside combat the opponent panel shows that there is no current opponent.

The UI also displays the current simulation seed, tick progress, and speed controls.

The UI currently creates the `Simulation` instance itself.

## Tests

Current tests cover:
- world clock and simulation speed;
- seeded RNG reproducibility;
- hero name loading;
- XP, level-up, stat growth, and excess-XP carryover;
- level-up after a real fight;
- starting stat resolution;
- isolated/live combat and critical-hit behaviour;
- frame-step combat progression;
- goblin and quest definitions;
- debug log;
- quest fights, XP, and full recovery;
- structured quest events and narration.
