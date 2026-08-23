# The Hero’s Story — UI & Presentation System Design

**Status:** Draft  
**Document version:** 0.1 skeleton

## Main Screen

The main screen should let the player **understand within a few seconds what is currently happening with the hero** without opening many additional windows.

Four main groups of information should be permanently or almost permanently available:

- **Hero chronicle and current activity** — what the hero is doing now and what important events happened recently. This is the game’s primary information flow.
- **The hero and their equipment** — appearance, current gear, and noticeable changes to the hero should be visible without unnecessary navigation.
- **Map / mini-map** — where the hero is, where they are heading, and what is happening nearby.
- **Deity panel** — available divine energy, soft influence, and direct-intervention abilities.

At the same time, the main screen should not try to display **every stat and every system at once**. Detailed stats, full inventory, the large world map, reputation, and other secondary information may be opened separately.

The exact panel layout, dimensions, and visual style are not fixed yet.

> **When the player returns to the game after a break, they should be able to quickly see the hero, understand what is happening to them, read the important recent events, and decide whether they want to intervene.**

## Additional Screens

The main screen presents the **current state of the hero and the world**, while more detailed information is opened only when needed.

Separate detailed views may exist for:

- hero attributes, class, progression, and traits;
- equipment and inventory;
- the full world map;
- the expanded chronicle or diary;
- factions and reputation;
- other systems that genuinely need dedicated space.

The design does not yet require these to be literal separate windows. They may later be implemented as windows, tabs, panels, or another navigation structure that best fits the final interface.

> **The main screen is for observing the hero’s life; additional screens are for examining individual systems in detail.**

## Player Control of Simulation Speed

The player may be allowed to **pause and accelerate the simulation** so the pace of observation can be adjusted to the current situation.

This is useful because different periods of the hero’s life have very different information density. At times the hero may be making an important decision or facing a dangerous event; at others they may simply be traveling for a long time, recovering, or performing ordinary activity.

However:

- the game should still feel good at its normal base speed;
- the player should not be forced to use maximum acceleration merely to skip boring stretches;
- speed control should not become an optimization mechanic of its own;
- the final set of player-facing speed options should be determined through testing;
- very high multipliers used during development may remain developer tools rather than release-facing modes.

The existence of pause and time-speed control is therefore a valid design direction, while the exact speed multipliers are not fixed yet.

> **Acceleration should help the player choose a comfortable pace of observation, not compensate for an uninteresting pace in the game itself.**
