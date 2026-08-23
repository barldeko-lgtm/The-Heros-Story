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

## Overall World Structure

The main game world is located on **one continent**.

For the full game, a working scale is roughly **around 10 major cities** connected by roads, regions, and different points of interest. The exact number is not fixed in advance and should depend on how many genuinely distinct and useful gameplay areas the game needs.

Small villages, farms, and other settlements are **not required by default**. They should be added only when they serve a distinct gameplay function or create meaningful situations for the hero.

The world is conceptually **open from the beginning**. The game does not prohibit the hero from traveling to a distant region simply because their level is too low.

Instead, the autonomous hero evaluates factors such as:

- whether suitable opportunities exist there;
- how dangerous the journey and known threats are;
- whether the hero is strong enough;
- whether traveling there makes practical sense;
- whether a quest, event, long-term goal, or another motive provides a reason to go.

A young hero therefore normally remains near safer areas **not because the rest of the world is locked, but because traveling into much more dangerous regions is not yet a sensible choice**.

> **The world is open in advance; the hero’s own development makes more of it practically relevant over time.**

## Migration note

Prototype 0’s abstract single-city distance model is not automatically the final world-map design.
