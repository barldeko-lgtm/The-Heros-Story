# The Hero’s Story — Core Concept

**Status:** Draft  
**Document version:** 1.0

## Purpose

This document defines the stable identity of **The Hero’s Story**: what the game fundamentally is, what fantasy it offers the player, and which principles must remain true across all systems.

It should stay compact enough to serve as the first design document read by a developer or AI before working on the project.

## This document covers

- the game in one paragraph;
- the central player fantasy;
- the autonomous-hero premise;
- the role of the player as deity/patron;
- the core gameplay philosophy;
- high-level design pillars;
- the intended relationship between hero, world, and player;
- high-level scope boundaries and things the game deliberately is not.

## This document does not cover

Detailed rules for:
- hero stats and classes;
- personality algorithms;
- combat formulas;
- quests;
- loot, inventory, equipment, and economy;
- divine abilities;
- world simulation;
- world map and travel;
- diary and narrative generation;
- Prototype 0 implementation scope.

Those belong in the corresponding system-design documents.

## Central Fantasy

The main idea of **The Hero’s Story** is to observe the life of one autonomous hero who gradually becomes a distinct person with a history of their own.

The hero should feel like someone who genuinely lives in the world, not like a game unit or an automated resource generator.

Desired player feeling:

> **“This is my hero. They live on their own, their path is not fully predictable, and I can sometimes guide or support them without making every decision for them.”**

## A Living, Autonomous Hero

The hero independently chooses activities, travels, fights, develops, finds and replaces equipment, reacts to circumstances, makes mistakes, succeeds, and gradually builds a personal history.

Their autonomy must be real: decisions depend on personality, preferences, current state, available opportunities, and circumstances.

## Simulating the Hero’s Journey, Not Their Entire Life

The game does not attempt to simulate every detail of ordinary daily life.

Hunger, routine meals, household needs, and similar processes are not valuable by themselves unless they create meaningful decisions, events, or consequences for the hero’s story.

> **We simulate not the hero’s entire life, but their adventuring life and the events that can change their development and fate.**

The basic gameplay loop should remain understandable. Depth should come from interacting systems, decisions, and events rather than from the number of everyday needs being tracked.

## Setting

The world is built on classic high fantasy: humans, elves, dwarves, magic, monsters, kingdoms, adventurers, and familiar fantasy weapons and equipment.

The game does not try to distinguish itself through an unusual setting. Its main identity comes from the hero’s autonomous life, their unique path, and the player’s limited influence as patron.

Specific nations, cultures, religions, history, and world structure are developed separately.

## Design References

**The Hero’s Story** uses other games as references for specific ideas rather than attempting to copy their overall structure.

- **Majesty** — autonomous heroes, indirect control, and incentives instead of direct orders. The project does not inherit its RTS structure, kingdom building, or control over many heroes.
- **Space Rangers** — a world that develops independently of the player, competing powers, and events that can resolve without the hero. The world simulation should not become so complex that the player can no longer understand its consequences.
- **Godville** — the relationship between one deity and one hero, hero autonomy, and the pleasure of observing an independent character. The project does not inherit excessive player passivity or a fully comedic foundation.
- **The Tale** — personality and preferences as part of autonomous behavior, gradual personality formation, and soft influence over development. MMO structure and collective player systems are not part of the project’s direction.
- **TBH: Task Bar Hero** — play that does not require constant attention, short check-ins, and the sense that the hero’s life continues while the player is busy. The project should not become a conventional idle clicker, a multiplier race, or a resource generator.

> **References help clarify individual solutions. They do not define the structure of the game as a whole and always remain subordinate to the core concept of The Hero’s Story.**

## Different Heroes, Different Stories

Different playthroughs should lead to noticeably different life paths.

These differences should primarily emerge from a chain of causes and consequences:

> **past → personality and tendencies → decisions → events and consequences → development and equipment → new possibilities → new decisions**

Randomness may influence the path, but it should not be the only source of difference.

## Hero Development Is the Main Source of Interest

Combat, quests, equipment, personality, travel, the world, events, and divine influence exist primarily to make the hero’s development and fate interesting to observe.

The player should notice not only larger numbers, but also changes in personality, habits, opportunities, equipment, successes, mistakes, and personal history.

## A Game That Does Not Require Constant Attention

The player should not need to watch the game constantly.

The intended rhythm is:

> **let the hero live → return → discover what happened → see how the hero changed → optionally influence what comes next → let the hero continue living**

One of the main reasons to return should be curiosity about the diary: what the hero did, what happened to them, what they found, lost, or changed about themselves.

The diary should not be a raw action log. Routine events should be summarized, while important decisions, consequences, discoveries, losses, and turning points should stand out.

## Background Play, Not Offline Idle

The hero and world continue to develop while the game is running, even when the player is not actively watching.

If the application is fully closed, the simulation stops. The game is not intended to be a traditional offline-idle game where the hero continues living for hours or days while the application is not running.

The main reward for time spent away from the game window is not accumulated resources, but the story that had time to happen.

## The Player Is a Patron, Not a Commander

The player influences the hero in limited and primarily indirect ways.

The player changes direction and the probability of decisions rather than choosing every action directly.

Influence must be limited enough to preserve the hero’s independence, but noticeable enough for the player’s choices to matter.

## Core Principle

> **The hero lives. The world creates circumstances. The player guides.**

> **The player does not control the hero — the player influences the probability of the hero’s fate.**

## Migration Note

Content is being reviewed and migrated from `docs/The_Heros_Story_Concept_Design_Pillars_v2.7_EN.md`. Ideas are transferred only after review rather than copied automatically.
