# The Hero’s Story — Hero System Design

**Status:** Draft  
**Document version:** 0.1 skeleton

## Purpose

This document defines the hero as a persistent autonomous character and describes the systems that establish their identity, state, class framework, and long-term adventuring life.

## This document covers

- hero creation;
- name and background;
- class and archetype framework;
- primary hero attributes at a conceptual level;
- persistent hero state;
- life-cycle states such as active, wounded, dead, and resurrecting;
- the boundary between permanent hero identity and temporary effects;
- relationships between the Hero system and other systems.

## This document does not cover

- detailed personality decision logic — see `Personality_and_Decision_System_Design_v0.1.md`;
- combat formulas and level progression — see `Combat_and_Progression_System_Design_v0.1.md`;
- inventory and equipment rules — see `Economy_Equipment_and_Loot_System_Design_v0.1.md`;
- divine intervention — see `God_Influence_System_Design_v0.1.md`;
- narrative presentation of the hero’s history — see `Narrative_and_Diary_System_Design_v0.1.md`.

## Hero Creation and Background

At the beginning, the player gives the hero a name and makes roughly **4–5 sequential choices about their past**.

These choices do not grant simple bonuses such as “+2 Strength.” Instead, they establish the hero’s initial personality, tendencies, interests, and preferences, which later influence autonomous decisions and the direction of development.

The hero’s past may influence, for example, their attitude toward risk, types of activities, combat styles, or equipment.

> **The biography creates the hero’s initial inertia, but it does not define their fate.**

After the game begins, lived experiences and the hero’s own decisions can gradually change these initial tendencies.

## Migration note

Content will be reviewed and migrated from the current concept document rather than copied automatically.
