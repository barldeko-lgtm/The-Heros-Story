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

## Cities and Factions

Major cities in the world belong to different **significant factions**.

As a current working foundation, the world may use:

- Humans;
- Elves;
- Dwarves.

This list is not considered final. Different factions also do not need to control the same number of cities.

Regardless of who owns a city, the hero should still have access to the core elements of the ordinary adventuring loop: finding activities, trading, recovering, and continuing their journey.

Faction ownership should add **differences and additional opportunities** rather than require the game to build an entirely separate basic gameplay loop for every people or faction.

As the hero’s reputation with a faction improves, additional content may become available, such as:

- special quests;
- distinctive merchants;
- faction equipment;
- additional events;
- special services or locations.

The basic gameplay loop should not be blocked by ordinary neutral or mildly negative reputation. Serious restrictions may appear only when relations have developed into genuine hostility.

> **Factions should make cities feel different and affect the hero’s life without splitting the core gameplay loop into several separate games.**

## Migration note

Post-Prototype systems listed here remain design territory, not implementation authorization.
