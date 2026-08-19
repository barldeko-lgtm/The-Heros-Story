# The Hero’s Story — AGENTS.md

This file contains **working rules for Hermes Agent**.

It is not a design document. Do not duplicate the full game design here.

## Project snapshot

The Hero’s Story is a Godot 4.x autonomous single-player RPG/simulation about one self-directed hero.

The player does not directly control the hero. The player acts as a god/patron: observes, softly influences decisions, and occasionally intervenes through limited divine abilities.

Core principle:

> **The hero lives. The world creates circumstances. The player guides.**

Preserve the simulation-first direction and real hero autonomy. Do not turn the project into a standard directly controlled RPG or RTS.

## Required reading before code work

Read in this order:

1. `docs/The_Heros_Story_Prototype_0_Scope_v0.20_EN.md`
2. `docs/new_project_concept_design_pillars_v2.7_EN.md`
3. `docs/current-state.md`
4. `docs/project-map.md`
5. `docs/dependencies.md`
6. task-relevant scenes, scripts, resources, and tests

The latest project documents and current repository are the source of truth.

Do not restore old decisions from chats, attachments, or previous document versions when they conflict with the current project.

## Working rules

- Prefer small, safe, targeted changes.
- Modify the fewest files necessary.
- Preserve unrelated code, scenes, settings, stats, data, and tests.
- Discussion is not implementation authorization.
- Do not silently expand the task into adjacent systems.
- Do not refactor working systems unless the current task requires it.
- Do not create generic managers, service locators, universal event buses, factories, or abstraction layers without a current concrete need.
- Do not import Dyna / Dyna Genesis architecture, scripts, mechanics, or assumptions unless Sasha explicitly asks for a comparison.
- Do not create a git commit, push, PR, or release without Sasha’s explicit separate command.

When a requirement is ambiguous, prefer the smallest interpretation that satisfies the task without blocking the next approved Prototype 0 step.

## Architecture rules

Keep these responsibilities separate:

- data/definitions;
- mutable runtime state;
- stat calculation;
- simulation/gameplay;
- narrative;
- UI.

Final hero combat stats must flow through:

```text
Hero state / stat sources
→ StatResolver
→ CombatStats
```

Hero and mobs must use one shared Power calculation:

```text
CombatStats
→ PowerCalculator
→ Power
```

Do not create separate HeroPower and MobPower formulas.

`QuestRunner` executes an already selected quest. Do not turn it into a container for quest pool logic, QuestScore, combat, diary text, loot, god logic, or UI.

Gameplay reports facts/state changes. Narrative describes them.

UI displays state and sends commands; it must not own gameplay rules.

The simulation must remain testable without player-facing UI.

## Scope discipline

The project is still Prototype 0.

Do not prematurely implement:

- full loot/inventory/equipment;
- market;
- crafting;
- world map;
- multiple cities;
- factions;
- reputation;
- dungeons;
- raids;
- parties;
- NPC heroes;
- wars;
- god progression;
- full biography/world chronicle systems.

Keep the architecture ready for the later path:

```text
loot
→ QuestLoot
→ Inventory
→ Equipment
→ StatResolver
→ CombatStats
→ Combat / Power
```

But do not build those systems before the current step requires them.

## Tests

Every gameplay/code change needs narrow validation appropriate to the changed behaviour.

- Preserve existing relevant tests.
- Add or update targeted regression coverage when behaviour changes.
- Prefer deterministic simulation tests where possible.
- Do not rely only on visual/manual testing.
- Do not rewrite unrelated tests just to make a broken change pass.
- Do not claim tests passed unless they were actually run.

## Documentation

Use the working docs for their intended purpose:

- `docs/current-state.md` — what is implemented now;
- `docs/project-map.md` — where files and responsibilities live;
- `docs/dependencies.md` — runtime flows, boundaries, and fragile contracts.

Update them only when their documented truth changes.

Do not update all three files for ordinary tuning-only edits.

## Delivery to Sasha

Sasha is not a programmer.

After code work:

- explain changes in plain Russian;
- list every touched file with its exact project path;
- briefly say what changed in each file;
- give simple test steps;
- mention anything not tested or any known limitation.

When delivering files, provide a ZIP containing **only changed and new files** and preserve the exact project folder structure inside it.

Do not claim GitHub was updated unless Sasha explicitly requested the commit/push and it was actually done.
