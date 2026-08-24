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

## Hex-Based Spatial Structure

The continent is divided into a **hexagonal grid**. Hexes are the basic spatial unit used by travel, quests, points of interest, and later world events.

The geography is currently intended to be authored rather than continuously generated during play. The map may eventually gain a generator, but even in that case the terrain layout is created before a playthrough begins and then remains spatially stable during that playthrough.

The current working physical scale is:

> **1 hex = approximately 3 km**

Game systems may work internally in hex steps, while the UI, diary, and narrative may convert those steps into kilometres so that journeys remain understandable to the player.

For example, a quest located 5 hexes from its city is approximately 15 km away. If the hero returns to the same city after completing it, the ordinary round trip is approximately 10 hexes / 30 km before accounting for any future detours or interruptions.

### Quest Distance Uses Hex Position

A quest that occurs outside a city is assigned to a **specific target hex**.

Its distance from the city is no longer an independent abstract kilometre roll. Distance is derived from the number of hex steps between the city hex and the quest hex.

At the current design stage:

- all traversable hexes have the same movement cost;
- terrain does not yet make one hex slower than another;
- water, impassable mountains, and other route-blocking terrain are not yet part of the travel model;
- therefore the ordinary travel distance is simply the shortest number of hex steps between the origin and destination.

This may become more sophisticated later, but terrain-dependent movement cost or blocked routes should be added only when they create useful gameplay.

> **The map determines distance; kilometres are the human-readable presentation of that distance.**

## Hex Attributes

Each hex contains a small set of properties used by the world simulation. These properties are deliberately divided into **persistent map attributes** and **mutable world-state attributes**.

### Persistent Map Attributes

These describe what the hex fundamentally is and normally do not change during a playthrough.

Current confirmed attributes are:

- **Hex ID / coordinates** — the unique identity and position of the hex in the grid;
- **Terrain Type** — the authored physical terrain of the hex, such as plains, forest, mountains, swamp, or another later-defined terrain category;
- **Base Danger** — the normal local danger band, expressed primarily through the level range of ordinary enemies that may naturally appear in that hex.

A broader **region / city association** is likely to become another persistent attribute, but its exact meaning has not yet been finalized. It may describe which city the hex naturally belongs to geographically without necessarily being identical to current political control.

Terrain is not expected to change during normal play. Base Danger represents the underlying natural danger of the area; temporary events may later make the current situation more or less dangerous without rewriting the hex’s base value.

### Mutable World-State Attributes

These describe what is currently happening in the hex and may change during the simulation.

Current working examples include:

- **Faction / political control** — which faction currently controls or influences the hex. It is not yet decided whether this is always inherited from a controlling city or calculated independently for individual hexes during wars;
- **Point-of-Interest state** — whether a temporary, renewable, or otherwise active location currently exists in the hex;
- **Active events and temporary conditions** — later events, threats, battles, caravans, unusual creatures, invasions, and other situations may temporarily occupy or modify a hex.

Additional mutable properties should be added only when they are needed by concrete gameplay systems.

> **Persistent attributes define the place. Mutable attributes define what is happening there now.**

## The Map as a Visual Reflection of the Living World

The map should be one of the main ways the player **understands where the hero is and what is happening in the world**.

It should be primarily **schematic, readable, and functional** rather than trying to represent the continent with maximum geographical detail.

The map may display:

- cities;
- major regions and territories;
- points of interest;
- the hero’s current position;
- the current route or direction of travel;
- areas of faction influence;
- borders and territorial changes.

The map becomes especially important during major changes in the world, such as:

- wars;
- sieges;
- border changes;
- invasions;
- the appearance of major threats;
- other events that significantly alter the state of regions.

The player should be able to **see that the world has changed**, rather than learning about every major development only through text.

At the same time, the map remains a tool for observation and understanding. It must **not become an interface for directly controlling the hero or commanding armies**.

> **The map should show the life and changes of the world, not merely serve as a background for icons.**

## Important Named Characters on the Map

The location of especially important named characters may be shown on the map **when that location is known to the player**.

This allows the player to see that significant figures in the world actually move and participate in events: they may remain in a city, travel toward a front, take part in a siege, or retreat after a defeat.

The map does not have to give the player constant omniscient knowledge of every such character’s exact location.

## Points of Interest as Renewable World Content

A Point of Interest (POI) is a **location or temporary place of interest attached to a hex**, while an event is something that happens in the world. An event may create, modify, renew, or remove a POI.

The current direction is that **all or nearly all gameplay-relevant POIs should be temporary, renewable, reusable, or capable of returning in another form** rather than existing as a finite set of one-time locations that can all be permanently exhausted.

Examples may include:

- monster lairs;
- bandit camps;
- temporary caves or discovered ruins used by an activity;
- military camps;
- portals;
- battlefields;
- other quest- or event-related locations.

Some authored geographical landmarks may remain permanently visible as part of the map, but their **gameplay opportunities should not necessarily be permanently consumed after one visit**. A ruin can remain a ruin while different situations later occur there.

This prevents a long-running hero from gradually clearing every interesting place on the continent until the map becomes empty after many hours of play.

The exact lifecycle, respawn rules, cooldowns, and conditions for POI renewal are not yet defined.

> **The geography can persist while the opportunities attached to it change and return over time.**

## Partial World Variation Between Playthroughs

Different heroes may begin their lives in **somewhat different states of the same broader world**.

The geography of the continent does not need to be generated from scratch for every new game. The underlying structure should instead be authored in advance, including elements such as:

- the continent shape;
- major natural regions;
- the hex terrain layout;
- valid positions for cities;
- possible roads and connections;
- suitable areas or anchors for POIs and events.

When a new playthrough begins, some elements may be assembled differently within those prepared constraints, for example:

- which cities are used and which valid positions they occupy;
- which factions control those cities;
- initial spheres of influence;
- some initial POIs and threats;
- the initial political situation of the world.

Variation must still respect **the logic of the setting**. For example, a dwarven city should appear in a suitable mountainous region rather than being placed arbitrarily only for the sake of randomness.

The goal is not to generate an entirely new continent each time, but to allow a new hero to be born into **a somewhat different version of a familiar world**.

The technical cost and actual value of this system should be evaluated much later. It remains a desirable future direction rather than a requirement for the base game.

> **It is better to rearrange well-designed world elements within clear rules than to procedurally generate everything for its own sake.**

The detailed simulation of initial faction control and political state belongs to `World_Simulation_System_Design_v0.1.md`.

## Migration note

Prototype 0’s abstract single-city distance model is not automatically the final world-map design.
