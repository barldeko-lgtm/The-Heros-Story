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
