# The Hero’s Story — Project Map

## Project root

- `project.godot` — Godot project configuration and main scene.
- `data/` — concrete game data.
- `scenes/` — Godot scenes.
- `scripts/` — runtime/gameplay/UI code.
- `tests/` — regression tests.

## Main scene

### `scenes/main/main.tscn`
Current only runtime scene.

Uses:
- `scripts/ui/main_ui.gd`

## Core

### `scripts/core/simulation.gd`
Current runtime coordinator.

Creates/owns:
- WorldClock;
- SeededRng;
- HeroState;
- HeroProgression;
- StatResolver;
- PowerCalculator;
- CombatSimulator/current CombatSession;
- QuestRunner;
- QuestNarrator;
- DebugLog;
- Diary.

Also coordinates combat XP, level-up stat refresh, world ticks, quest execution, and logging.

### `scripts/core/world_clock.gd`
Owns the shared world tick and tick progress.

### `scripts/core/seeded_rng.gd`
Owns one seeded `RandomNumberGenerator` for the current simulation.

### `scripts/core/hero_name_repository.gd`
Loads `data/hero_names_ru.txt` and chooses the hero name using the supplied RNG.

## Hero

### `scripts/hero/hero_state.gd`
Mutable hero runtime state and current quest-loop state constants.

### `scripts/hero/hero_progression.gd`
Owns Warrior base/progression constants, XP application, excess-XP carryover, and level-up attribute growth.

### `scripts/hero/stat_resolver.gd`
Builds final `CombatStats` from hero state/progression data.

## Models

### `scripts/model/runtime/combat_stats.gd`
Shared final combat-stat container.

### `scripts/model/definitions/mob_definition.gd`
Mob data schema and conversion to shared `CombatStats`.

### `scripts/model/definitions/quest_definition.gd`
Quest data schema.

## Combat

### `scripts/combat/power_calculator.gd`
Single shared Power calculation for hero and mobs.

### `scripts/combat/combat_simulator.gd`
Creates one live combat session.

### `scripts/combat/combat_session.gd`
Owns internal combat time, attack timers, mutable combat HP, seeded crit rolls, and resolved actions.

### `scripts/combat/combat_action.gd`
Stores one resolved attack.

### `scripts/combat/combat_result.gd`
Stores one duel result.

## Quests

### `scripts/quests/quest_runner.gd`
Executes the current single-quest loop.

Owns:
- travel;
- quest state transitions;
- defeated-mob count;
- post-fight recovery;
- turn-in Gold;
- structured quest-event output.

It exposes the current mob XP reward but no longer mutates hero XP or levels.

### `scripts/quests/quest_event.gd`
Structured quest-event data and ids.

## Narrative

### `scripts/narrative/quest_narrator.gd`
Turns current quest/combat events into Russian log text.

### `scripts/narrative/debug_log.gd`
Stores technical log entries.

### `scripts/narrative/diary.gd`
Current empty diary-entry store.

## UI

### `scripts/ui/main_ui.gd`
Current rough developer UI.

Creates a time-based simulation seed, displays it, and advances `Simulation`.

## Data

### `data/hero_names_ru.txt`
Current Russian hero-name list.

### `data/mobs/0001_goblin.tres`
Current only mob resource.

### `data/quests/0001_goblin_road_problem.tres`
Current only quest resource.

## Tests

New/updated coverage for this slice:
- `tests/test_seeded_rng.gd`
- `tests/test_hero_progression.gd`
- `tests/test_level_up_after_fight.gd`

Existing combat, quest, world-clock, stat, data, and narrative tests remain in place.

## Current ownership summary

```text
main_ui.gd
    ↓ seed
Simulation
    ├── SeededRng
    │     ├── HeroNameRepository
    │     └── CombatSession
    ├── WorldClock
    ├── HeroProgression → HeroState → StatResolver → CombatStats → PowerCalculator
    ├── CombatSimulator → CombatSession
    ├── QuestRunner → QuestEvent → QuestNarrator → DebugLog
    └── Diary
```
