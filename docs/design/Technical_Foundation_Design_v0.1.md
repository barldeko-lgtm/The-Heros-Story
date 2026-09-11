# The Hero’s Story — Technical Foundation Design

**Status:** Draft  
**Document version:** 0.1 skeleton

## Target Platform and Format

The primary target platform for **The Hero’s Story** is **PC**.

The base format is a **standalone desktop application** that the player can launch, leave running for long periods, and return to periodically.

This matches the intended usage pattern:

> start the game → leave the hero to live → go about your day → return from time to time to see what happened.

A web version may be added later as an additional option, but only if it does not require serious compromises in:

- background simulation;
- performance;
- save systems;
- interface;
- stability of long-running sessions.

**The web version is not the primary platform and should not determine key architectural decisions for the project.**

## Engine

The project’s primary engine is **Godot 4.x**.

The exact patch version is determined by the current state of development and may be updated later when necessary.

Godot is a good fit for the project because:

- the game is primarily 2D;
- much of the interface is built around text, panels, windows, lists, and a map;
- the simulation can be kept cleanly separated from the visual layer;
- the project does not require the heavy 3D feature set of larger engines;
- the engine does not introduce licensing constraints for the project.

Choosing Godot does **not** define the game’s architecture by itself. The architecture should be built around the needs of The Hero’s Story: an autonomous hero and world simulation separated from UI and presentation.

> **Godot is the implementation tool, not the source of the project’s architecture.**

## Main Architectural Principle

The simulation of the hero’s life and the world should be **logically separated from the visual interface**.

The interface displays the state of the simulation and lets the player interact with it, but it should **not be the source of gameplay rules or world state**.

Conceptually:

> simulation determines what happened → game state changes → UI displays the result.

Not:

> a UI button or window calculates what happened in the world by itself.

This separation is especially important because the game is designed for:

- long-running sessions;
- a minimized window;
- a relatively small amount of constantly active graphics;
- simulation that should continue independently of which screen is currently open.

In the future, this separation should make it possible to:

- test the simulation separately from graphics;
- run large batches of automated playthroughs for balancing;
- reproduce and analyze hero decisions;
- save and load world state independently of the interface;
- reduce unnecessary load when the visual layer is not needed.

The exact classes, data structures, and technical implementation may change as development continues.

> **UI shows the game. It should not be where the game itself lives.**

## Save and Load Philosophy

The normal player-facing game should treat the hero’s life as **one continuous history**, rather than a sequence of states that the player is expected to retry until they get the preferred result.

The current direction is therefore:

- a normal game uses **one rolling save slot**;
- the player does not maintain several parallel manual save slots for the same playthrough;
- loading returns to that same current save rather than offering a list of earlier checkpoints;
- the save is overwritten by regular autosaving;
- the current working autosave interval is approximately **every 10 minutes of real play time**;
- the exact interval and any additional safe autosave moments may be adjusted later through testing.

The purpose of this restriction is to preserve the consequences of the hero’s life. The player should not be encouraged to save immediately before a dungeon, event branch, risky decision, or other uncertain outcome and repeatedly reload until a preferred result occurs.

This rule is part of the intended release experience, not merely a limitation of the interface.

During development, debug or test builds may temporarily expose **multiple save slots, checkpoints, or other developer-only save tools** when they make testing specific systems and situations easier. These tools do not define the final player-facing save model.

> **The hero lives through consequences; the player observes and guides that history rather than repeatedly rewriting it through save slots.**
