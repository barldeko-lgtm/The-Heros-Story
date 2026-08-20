---
name: the-heros-story-workflow
description: "Work safely on The Hero’s Story Godot project."
version: 0.1.0
author: Sasha, Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [godot, the-heros-story, workflow, scope, testing]
    related_skills: [godot-feature-workflow, godot-regression-probes]
---

# The Hero’s Story Workflow

Use this only for `The Hero’s Story`. It carries project-specific working discipline, not gameplay mechanics from Dyna. Pair it with a narrower generic Godot skill when the task needs one.

## When to Use

- Work on code, data, scenes, UI, tests, or technical design in this project.
- Resume analysis after a break and need the current project truth.
- Review a proposed feature, balance rule, or architecture change.

Do not use it for Dyna, generic Godot questions, or unrelated repositories.

## First Read

Before code work, read in this order:

1. `docs/The_Heros_Story_Prototype_0_Scope_v0.21_EN.md`;
2. `docs/new_project_concept_design_pillars_v2.7.md`;
3. `docs/current-state.md`;
4. `docs/project-map.md`;
5. `docs/dependencies.md`;
6. task-relevant scenes, scripts, data, and tests.

Treat the latest documents and live repository as authoritative. Do not restore superseded decisions from Dyna, chat history, attachments, or old scope documents.

## Design and Scope Gate

1. Read before proposing code. State the smallest coherent slice, preserved contracts, and what is deliberately outside it.
2. Critically test the proposal against the core fantasy: one autonomous hero lives; the world creates circumstances; the player guides. Reject a solution that becomes direct control, needless simulation, or complexity without a visible benefit.
3. Discussion, questions, and agreement on a design are not permission to edit. Wait for Sasha’s explicit command such as `делай`.
4. After approval, change the fewest files necessary. Preserve unrelated user edits, data, scenes, tests, settings, and established ownership boundaries.
5. Never add speculative managers, generic event buses, factories, services, or future systems merely to prepare for them.
6. Never commit, push, open a PR, or create a release without Sasha’s separate explicit instruction.

## Architecture Boundaries

Keep separate ownership for definitions/data, mutable runtime state, final-stat calculation, simulation/gameplay, narrative, and UI.

- `HeroState / stat sources → StatResolver → CombatStats` is the final-stat path.
- Hero and mobs use the same `CombatStats → PowerCalculator → Power` calculation.
- `QuestRunner` executes an assigned quest; it does not own pool selection, QuestScore, combat, diary text, god logic, or UI.
- Gameplay reports structured facts; narrative turns facts into text.
- UI sends commands and displays state; it does not own gameplay rules.
- The simulation must remain testable without player-facing UI.

Preserve Prototype 0 limits. Do not prematurely add inventory, equipment, market, crafting, map, cities, factions, reputation, dungeons, raids, parties, NPC heroes, wars, god progression, or full biography systems unless the current approved slice requires one.

## Verification

Match validation to the change; do not substitute a plausible claim for a real run.

1. For changed gameplay, rules, data contracts, or bug fixes, add or update a deterministic focused regression test when practical. Cover the normal path, an edge case, and exact meaningful boundaries (below / equal / above a threshold).
2. Run the relevant existing and changed tests first. For shared core paths such as simulation, world time, combat, stats, quest selection, or state transitions, then run the complete project test set.
3. For UI-only changes, run a focused UI/scene check and use a visual check when layout or interaction is part of the request. Do not pretend that a parser check proves visual correctness.
4. Use the project’s real Godot 4.7.1 test convention: every `tests/test_*.gd` is run headlessly and must print a `PASS:` marker with no `SCRIPT ERROR:` output. Check the current CI workflow before changing the runner.
5. Run `git diff --check`, inspect the final diff and working tree, and preserve unrelated changes. Report exactly what actually ran and any remaining unverified surface.

## Documentation and Delivery

Update only the live document whose truth changed:

- `docs/current-state.md` for implemented current behaviour;
- `docs/project-map.md` for responsibilities and locations;
- `docs/dependencies.md` for runtime flows and fragile cross-file contracts.

Do not churn documentation for routine balance-only tuning.

After direct project edits, report in plain Russian:

- every changed file with its project-relative path;
- the purpose of each change;
- validation actually run and its result;
- simple local test steps and any limitation not checked.

Do not create a delivery ZIP unless Sasha explicitly asks for one.

## Pitfalls

- A working feature is not approval to expand into adjacent systems.
- A passing test is not proof of an untested UI or simulation integration.
- Do not weaken or rewrite unrelated tests merely to pass a change.
- Do not let player influence replace hero autonomy.
- Do not copy Dyna code, paths, mechanics, or assumptions into this project.
