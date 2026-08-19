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
Runtime coordinator.

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

On combat completion it applies XP only after victory, passes the result to `QuestRunner`, logs the resulting structured event, and completes exactly one world tick for the fight.

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
Technical log store.

### `scripts/narrative/diary.gd`
Empty diary store; diary generation is not implemented yet.

## UI

### `scripts/ui/main_ui.gd`
Current developer UI.

Displays:
- hero panel left;
- log/diary center;
- active opponent right;
- current death-respawn countdown through the hero state label.

## Tests

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
