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

Live combat flow:

```text
Simulation
→ CombatSession
→ CombatResult
→ HeroProgression + QuestRunner
→ exactly one completed world tick
```

## World time

Owner:
- `scripts/core/world_clock.gd`

Current dependency:
- `Simulation` applies time scale before advancing `WorldClock`;
- time scale `0` pauses without resetting partial progress;
- quest advancement happens from `tick_completed`;
- active combat consumes scaled internal seconds while world-tick progress is frozen.

## Hero progression and final stats

Main files:
- `scripts/hero/hero_state.gd`
- `scripts/hero/hero_progression.gd`
- `scripts/hero/stat_resolver.gd`
- `scripts/core/simulation.gd`

Current chain:

```text
XP reward
→ HeroProgression
→ HeroState
→ StatResolver
→ CombatStats
```

Contracts:
- XP application and Warrior level growth live in `HeroProgression`;
- `QuestRunner` does not mutate hero XP or levels;
- excess XP carries over;
- one reward may grant multiple levels;
- each level adds +4 STR, +1 AGI, and +20 direct MaxHP through the level bonus;
- `Simulation` refreshes `CombatStats` after a mid-quest level-up before recovery and the next fight;
- level-up itself does not directly heal current HP.

## Shared Power

```text
CombatStats
→ PowerCalculator
→ Power
```

Hero and mobs use the same calculator. Stat changes must flow through `CombatStats` before Power is recalculated.

## Seeded randomness

Main files:
- `scripts/core/seeded_rng.gd`
- `scripts/core/simulation.gd`
- `scripts/core/hero_name_repository.gd`
- `scripts/combat/combat_session.gd`
- `scripts/ui/main_ui.gd`

Current runtime chain:

```text
visible simulation seed
→ SeededRng
→ shared RNG
    ├── HeroNameRepository
    └── CombatSession crit rolls
```

Contracts:
- `Simulation` owns the runtime seeded RNG;
- equal seeds plus equal simulation steps reproduce the current random sequence;
- changing random-call order changes later results for the same seed;
- the developer UI chooses and displays the run seed;
- `Simulation.new()` without an explicit seed stays deterministic for tests;
- standalone name/combat fallbacks are deterministic instead of calling `randomize()`.

Future random systems should receive controlled RNG from the simulation.

## Combat core

```text
Hero CombatStats + Mob CombatStats
→ CombatSimulator
→ CombatSession
→ CombatAction
→ CombatResult
```

Contracts:
- Combat does not choose quests, award XP, restore HP, or update UI;
- runtime combat receives the simulation RNG;
- hero opening advantage remains 0.5 seconds;
- same-timestamp attacks resolve together;
- simultaneous death counts as hero defeat.

## Quest execution

Current dependencies:
- `QuestRunner` owns quest execution state, travel, defeated-mob count, recovery, and Gold turn-in;
- mob XP remains data on `MobDefinition`;
- `QuestRunner` exposes that reward but does not apply it;
- `Simulation` applies the reward through `HeroProgression`;
- recovery uses the currently resolved MaxHP, including level-up changes.

Hero death is still an unimplemented developer error.

## Simulation responsibility

`Simulation` currently coordinates:
- seeded RNG;
- resolved hero stats;
- combat;
- XP handoff to `HeroProgression`;
- stat refresh after level-up;
- quest execution;
- logging.

Subsystem rules remain in their owning files.

## UI boundary

`main_ui.gd` creates a time-based seed, constructs `Simulation` with it, displays current state/seed, and sends speed changes.

Gameplay rules remain outside UI.

## Tests protecting this slice

- `test_seeded_rng.gd` — same-seed RNG/simulation reproducibility;
- `test_hero_progression.gd` — XP ownership, level growth, carryover, level-2 stats;
- `test_level_up_after_fight.gd` — real combat XP triggers level-up and refreshed stats;
- existing combat/quest/stat/world-clock tests protect the surrounding loop.

## Future equipment hook

```text
Equipment
→ StatResolver
→ CombatStats
→ Combat / Power
```

Future stat sources must enter through `StatResolver` without replacing combat or Power logic.
