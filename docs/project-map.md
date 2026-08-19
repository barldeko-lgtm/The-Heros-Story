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
- HeroState;
- StatResolver;
- PowerCalculator;
- QuestRunner;
- QuestNarrator;
- DebugLog;
- Diary.

Also:
- creates the hero;
- resolves starting stats;
- advances world time;
- connects world ticks to quest execution;
- passes quest events into narration/logging.

### `scripts/core/world_clock.gd`
Owns:
- 10-second world tick;
- accumulated time;
- world tick counter;
- tick progress;
- `tick_completed`.

### `scripts/core/hero_name_repository.gd`
Loads:
- `data/hero_names_ru.txt`

Chooses the current random hero name.

## Hero

### `scripts/hero/hero_state.gd`
Mutable hero runtime state.

Also owns the current quest-loop state constants.

### `scripts/hero/hero_progression.gd`
Current Warrior base/progression constants and level HP bonus helper.

### `scripts/hero/stat_resolver.gd`
Builds final `CombatStats` from hero state/progression data.

## Models

### `scripts/model/runtime/combat_stats.gd`
Shared final combat-stat container:
- MaxHP;
- Attack;
- AttackSpeed;
- CritChance;
- CritDamage;
- DamageReduction.

### `scripts/model/definitions/mob_definition.gd`
Mob data schema.

Converts mob data into shared `CombatStats` and uses the shared Power calculator.

### `scripts/model/definitions/quest_definition.gd`
Quest data schema:
- id/name;
- mob reference;
- mob count;
- distance;
- Gold reward.

## Combat

### `scripts/combat/power_calculator.gd`
Single shared Power calculation for hero and mobs.

### `scripts/combat/combat_simulator.gd`
Creates a live hero-versus-mob combat session from final `CombatStats`.

### `scripts/combat/combat_session.gd`
Owns internal combat time, next attack timers, mutable combat HP, and resolved action events for one active duel.

### `scripts/combat/combat_action.gd`
Stores one resolved attack for a combat result.

### `scripts/combat/combat_result.gd`
Stores the duel winner, final HP values, duration, and resolved attacks.

## Quests

### `scripts/quests/quest_runner.gd`
Executes the current single-quest loop with one fight per quest mob and full post-fight recovery.

Owns:
- travel tick countdown;
- quest execution state transitions;
- defeated-mob count;
- 20%-of-MaxHP recovery ticks;
- active quest assignment;
- turn-in Gold reward;
- structured quest-event output.

### `scripts/quests/quest_event.gd`
Structured quest-event data and current quest-event ids.

## Narrative

### `scripts/narrative/quest_narrator.gd`
Turns `QuestEvent` objects into current Russian log text.

### `scripts/narrative/debug_log.gd`
Stores technical tick/event log entries.

### `scripts/narrative/diary.gd`
Current empty diary-entry store.

## UI

### `scripts/ui/main_ui.gd`
Current rough developer UI.

Displays simulation state and advances the current `Simulation` from `_process()`.

## Data

### `data/hero_names_ru.txt`
Current Russian hero-name list.

### `data/mobs/0001_goblin.tres`
Current only mob resource.

### `data/quests/0001_goblin_road_problem.tres`
Current only quest resource.

## Tests

- `tests/test_world_clock.gd`
- `tests/test_simulation_speed.gd`
- `tests/test_hero_name_repository.gd`
- `tests/test_stat_resolver.gd`
- `tests/test_combat_simulator.gd`
- `tests/test_combat_critical_hit.gd`
- `tests/test_combat_simultaneous_death.gd`
- `tests/test_combat_session.gd`
- `tests/test_combat_frame_step_probe.gd`
- `tests/test_goblin_definition.gd`
- `tests/test_goblin_quest_definition.gd`
- `tests/test_debug_log.gd`
- `tests/test_quest_loop.gd`
- `tests/test_quest_full_combat_loop.gd`
- `tests/test_quest_event.gd`
- `tests/test_quest_narrator.gd`

## Current ownership summary

```text
main_ui.gd
    ↓
Simulation
    ├── WorldClock
    ├── HeroState
    │     ↓
    │   StatResolver
    │     ↓
    │   CombatStats
    │     ↓
    │   PowerCalculator
    ├── QuestRunner
    │     ↓
    │   QuestEvent
    │     ↓
    │   QuestNarrator
    │     ↓
    │   DebugLog
    └── Diary

data/mobs/*.tres
    ↓
MobDefinition
    ↓
CombatStats
    ↓
PowerCalculator

data/quests/*.tres
    ↓
QuestDefinition
```
