# The Hero’s Story — World Simulation System Design

**Status:** Draft  
**Document version:** 0.1 skeleton

## Purpose

This document defines the world as an autonomous system that continues to create circumstances independently of the hero while the game simulation is running.

## This document covers

- world time at the conceptual level;
- autonomous world processes;
- cities and regional state;
- factions, political change, conflicts, and threats when those systems enter scope;
- world events;
- opportunities appearing and disappearing;
- how the hero can affect the world without becoming its only active agent;
- simulation granularity and what should or should not be simulated.

## This document does not cover

- spatial topology, locations, routes, and travel — see `World_Map_and_Travel_System_Design_v0.1.md`;
- hero decision logic — see `Personality_and_Decision_System_Design_v0.1.md`;
- quest execution details — see `Quest_and_Activity_System_Design_v0.1.md`;
- narrative presentation of world events — see `Narrative_and_Diary_System_Design_v0.1.md`.

## Core boundary

The world should generate meaningful circumstances, not simulate complexity merely for its own sake.

## The World Exists Independently of the Hero

The world should not be scenery that waits for the hero to act.

While the hero is occupied with their own life, cities, factions, conflicts, events, and other world processes may develop independently. Opportunities may appear and disappear, and some events may resolve without the hero’s participation.

The hero can influence the world, but is not the center of all its processes.

Only changes capable of creating noticeable circumstances, opportunities, or consequences for the hero’s story should be simulated. World complexity is not a goal by itself.

## Migration note

Post-Prototype systems listed here remain design territory, not implementation authorization.
