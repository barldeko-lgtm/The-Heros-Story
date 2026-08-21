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

## Combat Traits

Combat traits are separate from the hero’s general personality and emerge from combat experience.

They can reflect both positive and negative experience, such as growing confidence against certain threats or fear after severe defeats.

A combat trait should come from repeated or especially meaningful experience rather than appearing randomly after one ordinary fight.

Combat traits may strengthen, weaken, or disappear over time as the hero’s later experience changes.

> **Combat traits should become part of the hero’s story, not simply an ever-growing list of modifiers.**

The exact scale, categories, thresholds, and effects of combat traits will be defined separately.

## Migration note

Prototype formulas are not automatically treated as final full-game balance.
