# The Hero’s Story — AGENTS.md

This file contains the working rules for AI agents operating on The Hero’s Story.
It is not a design document.

## Project

The Hero’s Story is a Godot 4.x autonomous single-player RPG/simulation about one self-directed hero.

The player acts as a god/patron and does not directly control the hero.

Core principle:

> **The hero lives. The world creates circumstances. The player guides.**

Preserve the simulation-first direction and real hero autonomy. Do not turn the project into a directly controlled RPG, RTS, or management game.

## Sources of truth and required reading

The Prototype 0.2 Scope is the design authority for intended behaviour. `current-state.md` and the current repository are authoritative for what is implemented now, including documented temporary deviations.

Before ordinary code work, read:

1. `docs/current-state.md` — what is implemented now and current temporary deviations;
2. `docs/project-map.md` — file locations and system ownership;
3. `docs/dependencies.md` — runtime flows, invariants, and fragile cross-system contracts;
4. the relevant section(s) of `docs/The_Heros_Story_Prototype_0.2_Scope_EN.md` — intended design.

Do not read the full Scope by default for a narrow task. Read it fully only for broad/prototype-wide work, architecture review, or when the required design cannot be determined safely from relevant sections.

Do not restore older decisions from chats, attachments, old documents, or legacy code when they conflict with the current sources of truth.

If code and documents disagree and the discrepancy is not a documented temporary deviation, report it before making a change that depends on resolving it.

## Working rules

- Prefer small, safe, targeted changes and modify the fewest files necessary.
- Preserve unrelated systems, data, scenes, settings, tests, and behaviour.
- Discussion or design exploration is not authorization to implement.
- Do not silently expand the task, refactor unrelated working code, or pre-build future systems.
- Do not introduce generic managers, service locators, universal event buses, factories, or abstraction layers without a concrete current need.
- Respect ownership and boundaries documented in `project-map.md` and `dependencies.md`.
- Keep gameplay logic out of UI and narrative; narrative describes simulation facts, UI presents state and sends approved requests.
- Keep final hero stats through `StatResolver` and keep one shared Hero/Mob `PowerCalculator`.
- Do not commit, push, create a PR/release, or make a delivery archive unless Sasha explicitly asks.

When a requirement is ambiguous, prefer the smallest interpretation that satisfies the approved task. If the ambiguity would require a design or architectural decision, report it instead of guessing.

## Delegation

The primary agent remains responsible for architecture, integration, and final verification.

Use subagents only when they provide clear value for substantial search/research, bounded implementation, or independent verification. Do not delegate trivial work; normally use no more than two subagents at once.

Give each subagent one narrow self-contained task with the goal, relevant project rules, allowed/expected file area, constraints, and expected result.

Distinguish the allowed write scope from the read scope. Narrow reading of related callers and contracts is allowed when needed; expanding the write scope requires parent approval within Sasha’s approved task.

A subagent must not repeat full project onboarding by default. The parent should provide the needed context; the subagent should read only the files and document/Scope sections genuinely required for its task. For read-only investigation, do not reread the full Scope or all project docs unless the task truly requires them.

If required design or architecture is missing, the subagent should report the blocker to the parent instead of guessing or broadening into a full-project review.

Prefer **one task → autonomous work → one concise result**. Avoid repeated parent/subagent back-and-forth unless a real blocker or wrong direction requires another pass.

Do not let two subagents modify the same files concurrently. Subagents must not commit/push or recursively delegate unless the primary agent explicitly requires it.

## Tests and documentation

Run only the narrow tests relevant to the change unless dependencies or risk justify wider validation. Preserve relevant tests and add/update targeted regression coverage when behaviour changes. Never claim a test passed unless it was actually run.

Update `current-state.md`, `project-map.md`, `dependencies.md`, or the Scope only when the truth owned by that document actually changes.

## Delivery to Sasha

Sasha is not a programmer.

After code work:

- explain the result in plain Russian;
- list every touched file with its exact project path and briefly say what changed;
- report which tests were actually run and their result;
- give simple manual test steps when useful;
- mention anything not tested, unresolved, or intentionally left unchanged.

Do not claim GitHub was updated unless commit/push was explicitly requested and actually completed.
