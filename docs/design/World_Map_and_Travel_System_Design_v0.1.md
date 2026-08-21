# The Hero’s Story — World Map & Travel System Design

**Status:** Draft  
**Document version:** 0.1 skeleton

## Purpose

This document defines the spatial structure of the game world and how an autonomous hero understands, chooses, and moves through that structure.

The map is treated as a gameplay system, not merely as a visual screen.

## This document covers

- world-map structure;
- regions and cities;
- roads and connections;
- points of interest;
- local areas around cities;
- travel distance and travel time;
- route choice;
- travel risk and interruptions;
- discovery and visibility of locations;
- how quests, events, threats, and rumours influence movement;
- autonomous decisions about where to go next.

## This document does not cover

- internal simulation of factions and cities — see `World_Simulation_System_Design_v0.1.md`;
- generic personality decision algorithms — see `Personality_and_Decision_System_Design_v0.1.md`;
- detailed quest mechanics — see `Quest_and_Activity_System_Design_v0.1.md`;
- narrative wording for journeys — see `Narrative_and_Diary_System_Design_v0.1.md`.

## Core boundary

The map must support the fantasy of following one hero’s journey through a living world without turning the game into an RTS or direct movement-control game.

## Migration note

Prototype 0’s abstract single-city distance model is not automatically the final world-map design.
