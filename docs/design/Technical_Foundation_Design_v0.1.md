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
