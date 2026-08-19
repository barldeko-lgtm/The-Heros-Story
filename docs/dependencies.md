# The Hero’s Story — Dependencies and Invariants

This document records current cross-file dependencies and contracts that can be broken by refactoring.

## Runtime flow

Current startup/runtime chain:

```text
project.godot
→ main.tscn
→ main_ui.gd
→ Simulation
```

Per frame:

```text
main_ui._process()
→ Simulation.advance_time()
→ WorldClock.advance_time()
```

Per completed world tick:

```text
WorldClock
→ Simulation
→ QuestRunner
→ QuestEvent
→ QuestNarrator
→ DebugLog
```

## World time

Owner:
- `scripts/core/world_clock.gd`

Current dependency:
- `Simulation` applies time scale before passing time to `WorldClock`;
- quest-loop advancement happens from `tick_completed`.

Systems later expressed in world ticks must use this same timeline rather than introducing a competing tick source.

## Hero state and final stats

Main files:
- `scripts/hero/hero_state.gd`
- `scripts/hero/hero_progression.gd`
- `scripts/hero/stat_resolver.gd`
- `scripts/model/runtime/combat_stats.gd`

Current chain:

```text
HeroState + HeroProgression
→ StatResolver
→ CombatStats
```

Contracts:
- mutable hero state lives in `HeroState`;
- final combat stats are produced by `StatResolver`;
- consumers read `CombatStats` instead of rebuilding final stats independently.

## Shared Power

Main files:
- `scripts/combat/power_calculator.gd`
- `scripts/model/runtime/combat_stats.gd`
- `scripts/hero/stat_resolver.gd`
- `scripts/model/definitions/mob_definition.gd`

Current chain:

```text
CombatStats
→ PowerCalculator
→ Power
```

Contracts:
- hero and mobs use the same `PowerCalculator`;
- Power is derived from combat stats;
- changes to stat sources must flow through combat stats before Power is recalculated.

## Definition vs runtime state

Main files:
- `scripts/model/definitions/mob_definition.gd`
- `scripts/model/definitions/quest_definition.gd`
- `data/mobs/`
- `data/quests/`

Contracts:
- definition resources describe content;
- mutable simulation state lives outside definition resources;
- mob definitions convert their combat data into the shared `CombatStats` shape;
- quest definitions contain quest data and do not execute quest state transitions.

## Quest execution

Main files:
- `scripts/quests/quest_runner.gd`
- `scripts/quests/quest_event.gd`
- `scripts/hero/hero_state.gd`

Current dependencies:
- `QuestRunner` reads and changes the hero loop state;
- loop-state ids are centralized in `HeroState`;
- `QuestRunner` owns the current travel countdown;
- turn-in modifies hero Gold and clears the active quest;
- each step returns a structured `QuestEvent`.

Current `DOING_QUEST` is a placeholder and immediately transitions toward return travel.

## Quest events and narrative

Main files:
- `scripts/quests/quest_runner.gd`
- `scripts/quests/quest_event.gd`
- `scripts/narrative/quest_narrator.gd`
- `scripts/narrative/debug_log.gd`
- `scripts/core/simulation.gd`

Current chain:

```text
QuestRunner
→ QuestEvent
→ QuestNarrator
→ DebugLog
```

Contracts:
- `QuestRunner` returns structured event data;
- `QuestNarrator` owns the current Russian wording;
- `Simulation` connects the event to narration/logging;
- `DebugLog` stores the resulting technical text.

`Diary` is currently separate and receives no quest events.

## Simulation responsibility

Owner:
- `scripts/core/simulation.gd`

Current dependencies:
- constructs the current runtime objects;
- owns current resolved hero combat stats;
- initializes current HP from resolved MaxHP;
- connects `WorldClock.tick_completed`;
- coordinates quest execution and logging;
- exposes hero Power to the UI.

As new systems appear, their internal rules should remain outside `Simulation`; it should coordinate them rather than absorb them.

## UI boundary

Main files:
- `scenes/main/main.tscn`
- `scripts/ui/main_ui.gd`
- `scripts/core/simulation.gd`

Current dependencies:
- `main_ui.gd` constructs one `Simulation`;
- `_process()` advances it;
- UI reads current hero/combat/quest state;
- speed buttons call `Simulation.set_time_scale()`.

The current programmatic UI layout is not part of simulation state.

## Random hero name

Main files:
- `scripts/core/hero_name_repository.gd`
- `data/hero_names_ru.txt`
- `scripts/core/simulation.gd`

Current dependency:
- `Simulation` creates `HeroNameRepository` during initialization;
- the repository loads `hero_names_ru.txt`;
- it currently uses its own randomized `RandomNumberGenerator`.

This RNG is independent from the future reproducible simulation seed.

## Tests protecting current contracts

- `test_world_clock.gd` — world-tick behaviour;
- `test_simulation_speed.gd` — time scaling;
- `test_stat_resolver.gd` — starting resolved stats/Power;
- `test_goblin_definition.gd` — mob data;
- `test_goblin_quest_definition.gd` — quest data;
- `test_quest_loop.gd` — current placeholder loop;
- `test_quest_event.gd` — structured quest-event output;
- `test_quest_narrator.gd` — current event narration.

## Future equipment hook

The current stat boundary must remain compatible with:

```text
Equipment
→ StatResolver
→ CombatStats
→ Combat / Power
```

No inventory/equipment implementation exists yet. The only current dependency is that future stat sources must be able to enter through `StatResolver` without replacing combat or Power logic.
