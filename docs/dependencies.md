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
- `Simulation` applies the selected time scale before passing time to `WorldClock`;
- time scale `0` pauses the world clock without resetting its partial progress;
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

## Combat core

Main files:
- `scripts/combat/combat_simulator.gd`
- `scripts/combat/combat_session.gd`
- `scripts/combat/combat_action.gd`
- `scripts/combat/combat_result.gd`
- `scripts/model/runtime/combat_stats.gd`

Current chain:

```text
Hero CombatStats + Mob CombatStats
→ CombatSimulator
→ CombatSession
→ live CombatAction events
→ CombatResult
```

Contracts:
- `CombatSimulator` creates a live combat session and does not select quests, award XP, restore HP, write narrative text, or update UI;
- both combatants use the same `CombatStats` shape;
- the hero’s first attack occurs 0.5 seconds before their normal first interval;
- attacks scheduled for the same internal timestamp resolve together;
- any result where hero HP is `<= 0` is a hero defeat, including a simultaneous death.

`Simulation` owns the active session, freezes `WorldClock` while it runs, and sends each resolved action to narrative/debug logging. When it finishes, `QuestRunner` applies the result once for the current quest mob.

`Simulation.advance_time()` ignores insignificant floating-point time remainders so a frame cannot enter a zero-progress loop during combat.

## Quest execution

Main files:
- `scripts/quests/quest_runner.gd`
- `scripts/quests/quest_event.gd`
- `scripts/hero/hero_state.gd`

Current dependencies:
- `QuestRunner` reads and changes the hero loop state;
- loop-state ids are centralized in `HeroState`;
- `QuestRunner` owns the current travel countdown;
- `QuestRunner` applies a completed fight result, then counts defeated mobs and awards their XP;
- `QuestRunner` restores 20% of resolved MaxHP per subsequent recovery tick and waits for full HP before the next fight or return travel;
- turn-in modifies hero Gold and clears the active quest;
- each step returns a structured `QuestEvent`.

Arrival is separate from the first fight: the live fight begins immediately after arrival, freezes the world clock, then produces exactly one completed world tick when it ends. Hero death is currently guarded as an unimplemented developer error; no death state or teleport is simulated yet.

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
- `test_combat_simulator.gd` — hero opening advantage;
- `test_combat_critical_hit.gd` — critical-hit damage;
- `test_combat_simultaneous_death.gd` — simultaneous death resolves as hero defeat;
- `test_combat_session.gd` — actions resolve only when their internal timers elapse;
- `test_combat_frame_step_probe.gd` — 60 FPS combat path exits without a zero-time hang;
- `test_stat_resolver.gd` — starting resolved stats/Power;
- `test_goblin_definition.gd` — mob data;
- `test_goblin_quest_definition.gd` — quest data;
- `test_quest_loop.gd` — frozen world ticks, live hit logging, and first-fight XP;
- `test_quest_full_combat_loop.gd` — five fights, 250 XP, recovery, and return timing;
- `test_quest_event.gd` — structured quest-event output;
- `test_quest_narrator.gd` — live action, XP, and recovery narration.

## Future equipment hook

The current stat boundary must remain compatible with:

```text
Equipment
→ StatResolver
→ CombatStats
→ Combat / Power
```

No inventory/equipment implementation exists yet. The only current dependency is that future stat sources must be able to enter through `StatResolver` without replacing combat or Power logic.
