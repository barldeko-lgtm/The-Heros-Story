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

## Criterion for New Systems

Any new mechanic layered on top of the base adventure loop should do at least one of two things:

1. **noticeably diversify the hero’s life and adventures**;
2. **create consequences that affect the hero’s future fate**.

If a system does neither, its value to the project is questionable.

Complexity is not a virtue by itself. If the same meaningful result can be achieved through a simpler system, the simpler solution should be preferred.

> **A new mechanic should either make the hero’s life more interesting now or change what may happen to them later. Otherwise, we probably do not need it.**

## Systemic Generation of Ordinary Quests

Most ordinary quests should be created systemically from prepared game data and rules rather than existing only as individually authored one-off scenarios.

This allows the game to keep providing suitable adventures without requiring an impractical amount of hand-authored disposable content.

Systemic quests do not replace unique events or authored content. They provide the foundation of the hero’s adventuring life, while rarer special stories can be layered on top.

> **Ordinary adventures should scale through systems; unique content should be used where its uniqueness is genuinely noticeable.**

## Quests Depend on Location

The ordinary quest pool should be determined by the **city and surrounding region**, not by the current level of the specific hero.

Different places may offer different:

- quest types;
- enemies;
- danger levels;
- rewards;
- local opportunities.

Safer areas naturally tend to provide easier and moderate activities, while more dangerous regions may offer harder ones more often.

Quests should **not automatically scale to the hero’s current power**. The hero evaluates what the world currently offers and decides what is suitable, worthwhile, and interesting.

> **The world offers what exists in that place. The hero decides what is within reach and worth pursuing.**

## Different Quest Difficulties

New quests in the same location may have different levels of difficulty.

Most should fit the ordinary danger range of that region, but noticeably more dangerous opportunities may sometimes appear as well.

The exact distribution and frequency of different difficulty levels are balance parameters and should be determined through prototyping and testing.

> **The world does not have to offer the hero only safe or currently suitable quests. Some available opportunities may simply be beyond the hero’s present capabilities.**

## Quest Offer Lifetime

Available quests should not accumulate in a city forever.

If the hero does not choose a quest for a long time, that offer may disappear and later be replaced by a new opportunity.

An already accepted quest does not need a universal mandatory completion timer. Time limits may exist only where they make sense for the specific quest or event.

The exact lifetime of quest offers is a balance parameter to be defined later.

> **The available adventure pool should gradually change with the world rather than becoming a permanent archive of old quests.**

## Geographic Quest Anchoring

A quest should be tied to a specific place or area of the world whenever that matches its content.

Its objective may be a camp, lair, dungeon, part of a region, event location, or another understandable destination.

After the quest is completed, failed, or disappears, the related location may disappear, change state, or remain a permanent part of the world depending on its nature.

> **A quest should feel like something happening somewhere in the world, not like an isolated line in a list.**

The exact way this connection is presented on the map belongs to `World_Map_and_Travel_System_Design_v0.1.md`.

## Quests Respond to World State

The current state of the world may temporarily alter the available quest pool and create special opportunities on top of ordinary quests.

A war, invasion, dangerous event, regional crisis, or another meaningful change may create related quests that would not exist there under normal conditions.

When the underlying situation ends or changes, the quests created by it may also disappear, change, or be replaced by different opportunities.

> **World events should affect the hero’s adventures not only through text, but through the real actions that become available to them.**

The systems that create wars, invasions, regional states, and other world changes belong to `World_Simulation_System_Design_v0.1.md`; this document only defines how those changes may affect the hero’s available activities.

## Changing Opportunities Encourage Travel

The hero’s current location does not need to provide an endless supply of suitable activities.

Over time, the hero may find that:

- available quests are too easy;
- available quests are too dangerous;
- the remaining opportunities are unattractive to this particular hero;
- no suitable new opportunities have appeared yet;
- another location currently offers a more attractive quest, rumor, or event.

Such changes may naturally encourage the hero to wait, pursue another activity, or travel to another city or region.

The system should **not deliberately starve the hero of quests** merely to force movement.

> **The hero changes location because opportunities in the world change, not because the game artificially switches the old location off.**

## Unique Events Are Handcrafted

Rare and significant events should be authored by hand because context, consequences, and meaningful alternative developments matter most in these situations.

Such an event may take into account:

- the hero’s class and capabilities;
- personality and preferences;
- relationships with participants;
- current world state;
- previous events;
- possible divine influence.

There is no need to create a separate branch for every class or every trait. Alternatives should exist only where they genuinely make sense for the situation.

> **Systems create the hero’s everyday life. Handcrafted events create its special episodes.**

## Migration note

Prototype 0 quest rules remain implementation scope unless explicitly promoted into full-game design.
