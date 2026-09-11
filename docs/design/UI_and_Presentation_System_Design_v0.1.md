# The Hero’s Story — UI & Presentation System Design

**Status:** Draft  
**Document version:** 0.1 skeleton

## Core UI Structure

The interface is built around one **main observation screen** and several separate screens for more detailed information.

The currently established screen set is:

- **Main Screen** — observation of what is happening with the hero now;
- **Hero** — detailed information about the hero;
- **Inventory** — equipment, hero paper-doll, carried items, and item inspection;
- **Map** — the full known world map with the hero shown on it;
- **Menu** — system functions such as saving, loading, settings, and exit-related actions.

A separate **Diary / Chronicle** screen is not fixed yet. The main screen already contains the current log of the hero’s life, and whether the longer-term diary later deserves its own dedicated screen will be decided separately.

The exact navigation style, panel placement, dimensions, and visual composition of these screens are **not yet defined**.

> **The main screen is for observing the hero’s life. Detailed screens are for examining the hero, their possessions, and the world more closely.**

## Main Screen

The main screen should let the player **understand within a few seconds what is currently happening with the hero** and whether divine intervention is needed.

It should contain the following information and controls.

### Short Hero Summary

The main screen should show only the hero information that is useful to monitor constantly.

The current expected summary includes:

- hero name;
- level;
- class and, when available, specialization;
- current and maximum Health;
- current Power;
- gold;
- a class resource if that resource later proves important enough to monitor permanently.

Detailed attributes, the full trait list, skills, reputation, and detailed equipment information belong to the dedicated Hero or Inventory screens rather than the main screen.

### Current Quest

The current quest should have a separate compact presentation rather than relying only on the event log.

At minimum it should show:

- quest name;
- short quest progress when meaningful, for example enemies defeated, stages completed, or another clear progress measure.

If no quest is active, the interface may simply indicate that there is currently no active quest.

The event log remains responsible for describing what the hero is actually doing moment by moment.

### Hero Log / Chronicle

The hero log is one of the main information channels of the game.

It should describe the hero’s current activity and recent important events, including travel, decisions, encounters, fights, quest progress, discoveries, rewards, failures, and other meaningful developments.

The main screen does **not** need a separate permanent “current activity” panel if the log already communicates the activity clearly enough.

The log is therefore both a practical source of current information and the immediate narrative record of the hero’s life.

### Combat Opponent Information

While the hero is actively fighting, the main screen should additionally show concise information about the current opponent.

The current minimum is:

- opponent name;
- current and maximum Health;
- opponent Power.

Additional concise information may later be added if it proves useful, for example the opponent category such as Humanoid, Beast, Monster, or Undead.

The exact final list is not fixed yet. Detailed enemy statistics should not be shown merely because they exist internally.

Opponent information is relevant **during combat** and does not need to occupy permanent main-screen space outside combat.

### Mini-Map

The main screen should contain a small **local mini-map** showing the hero and a limited area around them.

Its purpose is to give immediate spatial context without requiring the player to open the full Map screen.

The mini-map should be able to show relevant known or currently visible local information such as:

- the hero’s current position;
- nearby roads;
- nearby known settlements;
- known dungeons or other discovered locations;
- active known temporary events;
- the hero’s current destination or quest-related target when useful.

Unknown hidden locations should not appear merely because they exist in the simulation.

The mini-map is conceptually connected to the full Map screen; opening the full map from the mini-map is an intended interaction direction.

### Divine Influence

The main screen should provide direct access to the player’s role as the hero’s patron.

It should show:

- current divine energy or equivalent resource;
- available divine abilities and interventions;
- relevant cooldowns, availability, or temporary state needed to understand whether an ability can currently be used.

The exact final set and visual presentation of divine controls belong to the God Influence system and later UI design.

### Time Controls

Pause and player-facing simulation-speed controls should be accessible from the main screen.

Their exact visual location and the final set of speed multipliers are not fixed yet.

### Main-Screen Navigation

The player should be able to move from the main screen to the detailed **Hero**, **Inventory**, **Map**, and **Menu** screens.

The exact form and position of this navigation are not fixed yet.

### Main-Screen Scope Rule

The main screen should not become a dashboard containing every available statistic and system.

In particular, the following belong primarily to detailed screens rather than permanent main-screen display:

- full primary and secondary statistics;
- complete personality and combat-trait lists;
- full skill information;
- detailed reputation information;
- complete inventory;
- individual equipment statistics;
- the full world map.

> **The main screen answers: “What is happening to my hero right now?” Detailed screens answer: “Who is this hero, what do they own, and what do they know about the world?”**

## Hero Screen

The Hero screen contains the detailed character information that does not need to remain permanently visible on the main screen.

The current expected content includes:

- name, level, class, and specialization;
- the hero’s complete current statistics;
- Power;
- personality traits;
- combat traits;
- learned skills and abilities;
- progression-related information that belongs to the hero;
- reputation, at least while the reputation system remains compact enough to fit naturally here.

Statistics shown here should be the hero’s **final resolved values from all currently active sources**, rather than forcing the player to manually combine base attributes, equipment, effects, and other modifiers.

The exact visual grouping and presentation are not fixed yet.

## Inventory Screen

The Inventory screen is the dedicated place for the hero’s possessions and equipment.

It should contain:

- a visual hero paper-doll / character representation;
- the hero’s equipment slots and currently equipped items;
- the hero’s inventory and the items stored in it.

The player should be able to inspect an item, for example by hovering over it, and see its relevant item information and statistics.

More advanced comparison presentation may be added later if useful, but the current requirement is simply that individual equipment statistics can be inspected clearly.

The Inventory screen is about **what the hero owns and wears**; the Hero screen remains the authoritative place for the hero’s final combined statistics.

## Map Screen

The Map screen shows the full world map available to the player.

It should show the hero’s current position and the world information the hero/player has legitimately discovered or currently knows.

Depending on the world state, this may include known settlements, roads, discovered dungeons, temporary events, destinations, and other relevant known map objects.

The exact map controls, filtering, zoom behavior, and visual language are not fixed yet.

## Menu Screen

The Menu screen contains system-level functions rather than hero simulation information.

Expected functions include:

- saving;
- loading;
- settings;
- return/continue;
- exit-related actions;
- other standard system options if needed.

The exact menu structure will be defined later.

## Player Control of Simulation Speed

The player may be allowed to **pause and accelerate the simulation** so the pace of observation can be adjusted to the current situation.

This is useful because different periods of the hero’s life have very different information density. At times the hero may be making an important decision or facing a dangerous event; at others they may simply be traveling for a long time, recovering, or performing ordinary activity.

However:

- the game should still feel good at its normal base speed;
- the player should not be forced to use maximum acceleration merely to skip boring stretches;
- speed control should not become an optimization mechanic of its own;
- the final set of player-facing speed options should be determined through testing;
- very high multipliers used during development may remain developer tools rather than release-facing modes.

The existence of pause and time-speed control is therefore a valid design direction, while the exact speed multipliers are not fixed yet.

> **Acceleration should help the player choose a comfortable pace of observation, not compensate for an uninteresting pace in the game itself.**

## Time During Combat

Combat should run at a pace that lets the player **understand what is happening**, notice a dangerous situation, and, if desired, have time to use divine intervention.

This does not require the entire game to automatically slow down during every encounter.

A more flexible principle is:

- an active fight may run in its own short time context;
- long-term world simulation does not need to advance in parallel during the few seconds of an active fight;
- the player’s selected simulation speed may also affect combat playback speed;
- at normal player-facing speeds, combat should remain readable;
- the behavior of very high speed multipliers during combat should be determined through testing.

The current prototype direction, where world ticks temporarily stop advancing while an active combat session resolves separately, is a valid working model, but this specific technical implementation is not treated as permanently fixed at the design level.

> **Combat should remain a moment in the hero’s life that the player can understand and, when necessary, still have time to influence, rather than flashing past inside an accelerated simulation.**
