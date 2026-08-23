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
