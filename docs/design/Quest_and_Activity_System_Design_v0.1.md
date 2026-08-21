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

## The Base Loop Should Not Feel Routine

The hero needs a clear and repeatable adventuring structure, but the game should actively minimize the feeling that the same sequence is simply repeating.

The underlying pattern may remain familiar:

- take an activity or quest;
- prepare;
- set out;
- encounter danger;
- complete the objective;
- return;
- receive the reward;
- deal with loot and equipment;
- decide what to do next.

However, the player should not constantly experience:

> the same quest → the same journey → the same fight → the same return.

Even when the internal structure is similar, individual adventures should differ through circumstances, decisions, risk, consequences, and the way this particular hero responds to them.

> **The base loop should give the game structure without turning the hero’s life into a conveyor belt of identical actions.**

The game should not fight repetition by adding dozens of equally important minor everyday chores. Variety should come from within adventures and from meaningful systems layered on top of the base loop rather than from meaningless busywork.

## Variety Comes from Layers on Top of the Loop

The same base loop should continuously change in its concrete content through the influence of other game systems.

An individual adventure may be affected by:

- the hero’s personality, tendencies, and preferences;
- level, real power, and equipment;
- the presence or absence of suitable quests;
- rare random and authored events;
- rumors and temporary opportunities;
- personal relationships with individual characters;
- faction conflicts and wars, if those systems are implemented;
- changes in cities and regions;
- consequences of previous adventures;
- divine influence from the player.

For example, the hero may return from a quest and discover that no suitable tasks remain, the available ones are too weak or too dangerous, an interesting rumor has appeared in another city, or conditions in a nearby region have changed. The hero’s personality, current condition, and previous experience further affect how they respond.

As a result, the hero may naturally decide to travel to another city, change the type of activity they pursue, take a risk for an unusual opportunity, or temporarily deviate from their usual route.

> **Variety should come not from constantly replacing the base loop, but from the world, the hero, and changing circumstances altering how that loop unfolds.**

This section does not own wars, relationships, travel, world simulation, or other external systems. It defines how the results of those systems may alter the hero’s adventure loop when they are relevant.

## Events Should Disrupt the Usual Flow, Not Replace It

Major unusual events should not happen every minute.

If every adventure becomes a unique world-scale drama, unusual events quickly stop feeling special and the required amount of unique content becomes effectively endless.

Ordinary adventures should already gain variety through the hero, the world, quests, travel, and changing circumstances. Against that background, **more significant events** occasionally occur that may:

- change the hero’s current objective;
- create an unusual opportunity;
- force a change of route or plans;
- affect personality or preferences;
- create or change an attitude toward someone;
- leave a long-term consequence.

Such events should become noticeable episodes in the hero’s biography rather than merely another form of background routine.

> **Everyday adventures create the flow of the hero’s life. Significant events create its turning points.**

> **Decisions shape the hero. Events shape their history. The deity may change direction, but does not write the script for them.**

## Migration note

Prototype 0 quest rules remain implementation scope unless explicitly promoted into full-game design.
