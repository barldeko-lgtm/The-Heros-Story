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

## Named Faction Characters

Major factions may have **important persistent characters in the world**: commanders, rulers, renowned warriors, mages, and other significant figures.

They do not need to be simulated with the same depth as the main hero. Their role is to be recognizable participants in the history of the world and, when appropriate, to contribute to the strength and resilience of their faction.

Such characters may:

- begin as very powerful figures;
- possess recognizable equipment of their own;
- remain in cities or move between locations important to their faction;
- participate in wars, sieges, and major events;
- influence the military strength or resilience of the region where they are present.

The hero should not be able to simply enter a peaceful city and repeatedly farm such a character as an ordinary enemy.

They become genuinely vulnerable mainly during **major events** such as sieges, decisive battles, the fall of a city, or comparable situations in which normal faction protection has broken down.

Defeat of a named character **does not have to mean death**. They may retreat, lose resources, or reappear in another city belonging to their faction.

Permanent death of an important character should be a rare historical event rather than an ordinary consequence of a random encounter.

The exact rules for retreat, death, succession, resource loss, and their contribution to faction strength will be defined later.

> **Named NPCs should be part of the history of the world, not merely unusually durable enemies.**

## NPC Adventurers — Optional Future Layer

In the future, the world may include a small number of **autonomous NPC adventurers** who live simplified adventuring lives of their own.

They may:

- travel between cities;
- take part in some activities;
- gradually become stronger;
- occasionally replace equipment;
- participate in world events;
- cross paths with the main hero;
- potentially join the hero in especially difficult group content later on.

They should **not be simulated with the same depth as the main hero**. The game remains centered on one hero whose life and story receive the full simulation focus.

This system is worth adding only if NPC adventurers create visible situations such as encounters, competition, shared events, consequences for the world, or meaningful intersections with the hero’s story.

If they merely exist somewhere in the background and the player rarely notices their effects, the simulation cost is not justified.

> **Other adventurers are useful only when their lives become part of the story of the main hero.**

This remains an **optional future layer**, not a commitment for the base game.

## Internal Spatial Representation of the World

For simulation purposes, the world may be internally divided into **hidden spatial areas**.

These may be cells, regions, or another convenient structure. The exact technical format is not fixed at the design level.

A spatial area may store information such as:

- faction ownership or influence;
- terrain type;
- current danger;
- active events;
- presence of a global threat;
- other parameters needed by the world simulation.

The player does not need to see this internal structure directly. They should see its **results** through border changes, appearing threats, events, dangerous territories, and other visible consequences in the world.

> **The internal map exists to create circumstances around the hero, not to turn the game into a hidden grand strategy.**

## Faction Borders and Wars

When the territories or spheres of influence of **hostile factions meet**, the surrounding area may become a conflict zone.

Such areas may generate more frequent:

- small skirmishes;
- major battles;
- military camps;
- patrols;
- temporary quests;
- other war-related events.

War may gradually change territorial control and the position of faction borders.

If the hero is nearby, they may gain an opportunity to become involved. Participation remains **the hero’s own decision** and may depend on:

- relations with the factions involved;
- personality and willingness to take risks;
- the hero’s current objective;
- current condition and power;
- potential reward;
- other circumstances and divine influence.

War should affect the hero’s ordinary life **through real changes in the world and the situations those changes create**, rather than existing only as a line in the chronicle.

> **War matters not because influence numbers change somewhere in the simulation, but because it changes the world through which the hero lives and travels.**

## Global Threat as a Long-Term World Process

The world may contain a **major hostile force** that is not one of the ordinary factions and can gradually become a threat to a significant part of the continent.

It should not begin a world-scale war immediately at the start of a new game. Its influence develops gradually. At a high level, several stages may exist:

- **quiet** — the threat exists but has little effect on the rest of the world;
- **first signs** — rumors, isolated enemies, local events, and unusual points of interest begin to appear;
- **spread** — the threat starts taking territory, creating persistent pressure, and affecting cities and roads;
- **major conflict** — it becomes one of the main forces noticeably reshaping the state of the wider world.

Progress between these stages should depend primarily on **time and the state of the world itself**, not on the hero’s level.

The hero may accelerate, slow, or alter particular developments, but the global threat should not wait for the hero to reach an appropriate level before it is allowed to progress.

The exact nature of this force, its pace of development, transition conditions, and scale of influence will be defined later.

> **A major threat develops as part of the world’s history, not as a story boss that activates when the hero reaches the required level.**

## The Global Threat Is Not a Mandatory Main Quest

The appearance of a major threat does **not automatically turn the hero into the chosen savior of the world**.

Depending on personality, goals, relationships, and the history that has developed around them, the hero may:

- actively fight the threat;
- defend a particular city or friendly faction;
- participate only in selected related events;
- try to stay away from the war;
- move to a safer region;
- exploit the resulting chaos for personal goals.

In exceptional cases, it may also be possible for the hero to **end up on the side of the threat itself**, but only if that path emerges naturally from the hero’s lived history. This must not be a simple starting choice such as “play as the evil faction.”

The global threat may become **the defining story of one particular hero**, while for another hero it may remain a huge world event that unfolded alongside a largely different personal life.

> **The world may be living through the greatest war of its age without the game appointing our hero as its main character.**

## The World Resists Without the Hero

Ordinary factions should autonomously **respond to wars, invasions, and the global threat** even when the hero does not participate in those events.

They may:

- defend their territories;
- wage wars;
- hold cities;
- lose and regain regions;
- temporarily cooperate against a common threat;
- use their own powerful characters and resources.

The hero’s absence should **not automatically mean the world loses**.

At the same time, the global threat should remain strong enough to genuinely reshape the map and create pressure. The world should not be guaranteed to defeat it on its own in every playthrough.

Different playthroughs may develop differently: in some, factions successfully contain the threat; in others, they lose territory; and the hero’s involvement may noticeably change the outcome of particular events.

The exact mathematics of faction strength, warfare, and territorial pressure will be defined later.

> **The hero can change the fate of the world, but the world should not be helpless without them.**

## Consequences of War Must Reach the Hero’s Life

A change in territorial control should not amount only to **a color changing on the map**.

War and other major changes in the world should pass consequences into other game systems and genuinely alter the circumstances around the hero.

They may affect:

- available quests and events;
- enemies and the danger level of a region;
- the appearance and disappearance of points of interest;
- road and route safety;
- the condition of cities;
- trading opportunities;
- faction relations;
- the appearance of sieges, camps, battles, and other temporary situations.

The hero does not have to participate in the war itself. Even when avoiding it, the changed world may force the hero to choose another route, look for work elsewhere, or encounter new dangers and opportunities.

The concrete rules for quests, trade, and travel remain the responsibility of their respective system documents.

> **Global simulation has value only when its consequences become a noticeable part of the hero’s ordinary life.**

## Complete World Defeat as a Rare Natural Ending

The global threat capturing part of the continent does **not mean Game Over**.

The hero continues living in a changed world:

- cities may be lost;
- territories may become more dangerous;
- familiar routes may disappear;
- surviving factions may retreat;
- the hero may continue their own life amid the wider crisis.

However, at a very late stage of a playthrough, the global threat may theoretically achieve **the near-complete destruction or subjugation of the world**.

If no genuinely safe place remains that can support the hero’s continued life and organized resistance has effectively collapsed, the hero’s death under those circumstances may become **a natural ending of that playthrough**.

This should be a rare result of long-term world development, not a punishment for the player failing to watch the game for a while.

Such an ending should feel less like an ordinary defeat screen and more like part of the hero’s biography: **they lived a life in a world that eventually fell**.

> **The world may lose its own story, but that should be an event of an age, not an accidental Game Over.**

## Migration note

Post-Prototype systems listed here remain design territory, not implementation authorization.
