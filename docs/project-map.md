# The Hero’s Story — Project Map

## Project root

- `project.godot` — Godot project configuration and main scene.
- `.github/workflows/tests.yml` — GitHub Actions regression-test workflow.
- `data/` — concrete game data.
- `scenes/` — Godot scenes.
- `scripts/` — runtime/gameplay/UI code.
- `tests/` — regression tests.

## Core

### `scripts/core/simulation.gd`
Runtime coordinator. Its constructor accepts an optional initial quest; the default remains the Goblin quest for regression compatibility.

Coordinates:
- WorldClock;
- SeededRng;
- HeroState / HeroProgression / StatResolver;
- PowerCalculator;
- live CombatSession;
- QuestRunner;
- QuestNarrator;
- DebugLog;
- Diary shell.

On combat completion it records cumulative per-mob win/loss statistics, applies XP only after victory, passes the result to `QuestRunner`, logs the resulting structured event, and completes exactly one world tick for the fight.

### `scripts/core/world_clock.gd`
Single world-time authority used by travel, recovery, and the natural resurrection timer.

### `scripts/core/seeded_rng.gd`
Owns the current seeded RNG.

## Hero

### `scripts/hero/hero_state.gd`
Mutable hero state and centralized loop-state ids, including:
- `DEAD_RESPAWNING`;
- `RECOVERING_IN_CITY`.

### `scripts/hero/hero_progression.gd`
Owns XP and Warrior level growth.

### `scripts/hero/stat_resolver.gd`
Builds final `CombatStats`.

## Combat

### `scripts/combat/combat_simulator.gd`
Creates one live duel.

### `scripts/combat/combat_session.gd`
Owns only one fight: internal combat time, HP, attacks, crits, and victory/defeat.

It does not own resurrection or quest cancellation.

### `scripts/combat/combat_action.gd`
One resolved attack.

### `scripts/combat/combat_result.gd`
One duel result.

### `scripts/combat/power_calculator.gd`
Shared hero/mob Power calculation.

## Quests

### `scripts/quests/quest_runner.gd`
Executes the current single quest.

Owns current execution-state transitions including:
- travel;
- defeated-mob count;
- post-fight recovery;
- return/turn-in;
- defeat and quest cancellation;
- 100-tick natural resurrection timer;
- city recovery after resurrection.

It does not award XP or implement combat itself.

### `scripts/quests/quest_event.gd`
Structured quest/runtime events, now including death, resurrection, and city recovery.

## Narrative

### `scripts/narrative/quest_narrator.gd`
Turns quest/combat/death events into current Russian debug-log text.

### `scripts/narrative/debug_log.gd`
Technical log store. Retains only the last 100 world ticks; multiple combat lines from one fight share the single world tick consumed by that fight.

### `scripts/narrative/diary.gd`
Empty diary store; diary generation is not implemented yet.

## UI

### `scripts/ui/main_ui.gd`
Current developer UI.

Displays:
- hero panel left;
- log/diary center;
- active opponent right;
- current death-respawn countdown through the hero state label;
- fixed bottom-right cumulative combat-statistics panel.


## Current calibration data

### `data/mobs/0002_wolf.tres`
95%-of-starting-HeroPower MONSTER used for combat/Power validation.

### `data/quests/0002_wolf_hunt.tres`
Eight-Wolf test quest: 4 km distance, 80 Gold reward.


### `data/mobs/0003_bear.tres`
Slow, high-HP MONSTER calibrated to approximately 95% of starting HeroPower.

### `data/quests/0003_bear_hunt.tres`
Four-Bear calibration quest: 3 km distance, 40 Gold reward.

## Tests


### `tests/test_wolf_definition.gd`
Protects the Wolf calibration card and Power ≈ 20.38.

### `tests/test_wolf_quest_definition.gd`
Protects the 8-Wolf / 4 km / 80 Gold quest data.

### `tests/test_combat_statistics.gd`
Protects cumulative fight/win/loss/winrate counting.


### `tests/test_bear_definition.gd`
Protects the slow/high-HP Bear calibration card and Power ≈ 20.38.

### `tests/test_bear_quest_definition.gd`
Protects the 4-Bear / 3 km / 40 Gold quest data.

### `tests/test_death_respawn.gd`
Integration coverage for:
- lethal combat defeat;
- quest cancellation;
- retained progression;
- no losing-mob XP / no quest Gold;
- 100 dead ticks;
- resurrection at 1 HP;
- city recovery to full HP.

Existing combat, quest, progression, clock, RNG, data, and narrative tests remain in place.
