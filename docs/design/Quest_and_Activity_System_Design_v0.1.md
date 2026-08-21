# The Hero’s Story — Quest & Activity System Design

**Status:** Draft  
**Document version:** 0.1 skeleton

## Purpose

This document defines the activities that structure the hero’s adventuring life and how the hero discovers, evaluates, chooses, executes, completes, abandons, or fails them.

## This document covers

- quest availability;
- quest types;
- quest evaluation;
- autonomous quest selection;
- quest execution structure;
- rewards and failure;
- farming and non-quest adventuring activities;
- dungeons and other activity formats at a conceptual level when they become relevant;
- activity-related decision points;
- interactions with personality, world state, travel, combat, and divine guidance.

## This document does not cover

- detailed personality algorithms — see `Personality_and_Decision_System_Design_v0.1.md`;
- combat resolution — see `Combat_and_Progression_System_Design_v0.1.md`;
- map topology and travel rules — see `World_Map_and_Travel_System_Design_v0.1.md`;
- item/economy rules — see `Economy_Equipment_and_Loot_System_Design_v0.1.md`;
- diary presentation — see `Narrative_and_Diary_System_Design_v0.1.md`.

## Core Adventure Loop

Most of the hero’s ordinary adventuring life follows one stable RPG loop.

The current working structure is:

1. the hero arrives at a tavern or another place where jobs are available;
2. evaluates suitable quests;
3. autonomously chooses one;
4. prepares if necessary;
5. sets out to complete it;
6. travels, encounters enemies, and fulfills the objective;
7. returns;
8. turns in the quest and receives the reward;
9. goes to the market;
10. sells trophies and unwanted items;
11. evaluates whether anything is worth buying or replacing in their equipment;
12. returns to looking for a suitable activity;
13. the loop repeats.

The player should not have to manually service every step of this process.

> **This is the hero’s basic rhythm of adventuring life, and the hero should be able to sustain it autonomously.**

The systems responsible for travel, combat, equipment, economy, personality, world state, and divine influence may modify individual stages of this loop without taking ownership of the loop itself.

## Migration note

Prototype 0 quest rules remain implementation scope unless explicitly promoted into full-game design.
