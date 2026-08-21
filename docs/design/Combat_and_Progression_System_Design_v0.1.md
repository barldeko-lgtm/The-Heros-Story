# The Hero’s Story — Combat & Progression System Design

**Status:** Draft  
**Document version:** 0.1 skeleton

## Purpose

This document defines how the hero becomes stronger and how autonomous combat converts stats, equipment, skills, and experience into understandable outcomes.

## This document covers

- combat model and timing;
- combat stats;
- shared Power concept for hero and enemies;
- damage, attack speed, critical hits, defense, and related combat parameters;
- XP and level progression;
- attribute growth;
- skills and class progression;
- combat-related traits;
- death consequences that originate from combat;
- interfaces through which equipment and temporary effects modify final combat stats.

## This document does not cover

- hero biography and general identity — see `Hero_System_Design_v0.1.md`;
- personality-based choice logic — see `Personality_and_Decision_System_Design_v0.1.md`;
- item generation and equipment ownership — see `Economy_Equipment_and_Loot_System_Design_v0.1.md`;
- quest selection/content — see `Quest_and_Activity_System_Design_v0.1.md`.

## Core boundary

Hero and enemy strength must remain comparable through one shared combat-stat and Power model. Equipment and temporary effects feed combat through resolved stats rather than special-case combat logic.

## Overall Hero Level

The hero has one overall level that represents their long-term development as an adventurer.

By gaining experience, the hero increases this level and gradually becomes stronger. Level serves as one of the main axes of vertical character progression.

The exact sources of experience and the rewards granted by each level will be defined separately.

The game does not use a separate TES-like progression system for every weapon type simply through repeated use — for example, separate Sword, Axe, or Bow levels that rise only because the hero frequently uses that weapon.

> **Hero development should create meaningful differences rather than accumulate dozens of secondary progression tracks.**

## Attribute Growth on Level-Up

The player does not manually distribute all of the hero’s attributes after every level-up.

Attribute growth is shared between three influences:

1. **class** — guarantees part of the growth toward the class’s core attribute or attributes;
2. **deity guidance** — allows the player to softly encourage one development direction;
3. **the hero** — most growth is distributed autonomously according to the hero’s own tendencies and development logic.

A current illustrative working model is:

> **5 attribute points per level: 1 from class + 1 from deity guidance + 3 distributed by the hero.**

These numbers are provisional design values, not final balance. The amount of growth and the proportions assigned to each source may change during development.

The hero’s autonomous share should not be random. It may be influenced by biography, personality, preferences, lifestyle, and meaningful accumulated experience.

Divine guidance should influence development without becoming ordinary manual point allocation by the player.

> **The hero develops themselves; the player can only help shape the direction.**

The exact attributes, weighting rules, and strength of each influence will be defined separately.

## Hero Growth Must Be Understandable

Although attribute growth is allocated automatically, the result should not feel random to the player.

When the hero levels up, the player should be able to understand:

- which attributes increased;
- which part of the growth came from class;
- which direction was encouraged by deity guidance;
- which tendencies, preferences, or experiences influenced the hero’s autonomous share.

The exact way this information is presented will be defined separately.

> **The player does not directly control the hero’s development, but should understand why the hero is developing in that direction.**

## Combat Traits

Combat traits are separate from the hero’s general personality and emerge from combat experience.

They can reflect both positive and negative experience, such as growing confidence against certain threats or fear after severe defeats.

A combat trait should come from repeated or especially meaningful experience rather than appearing randomly after one ordinary fight.

Combat traits may strengthen, weaken, or disappear over time as the hero’s later experience changes.

> **Combat traits should become part of the hero’s story, not simply an ever-growing list of modifiers.**

The exact scale, categories, thresholds, and effects of combat traits will be defined separately.

## Migration note

Prototype formulas are not automatically treated as final full-game balance.
