# The Hero’s Story — Narrative & Diary System Design

**Status:** Draft  
**Document version:** 0.1 skeleton

## Purpose

This document defines how raw simulation events become a readable personal story that makes the player care about what happened while they were not actively watching.

## This document covers

- diary structure;
- significant-event selection;
- aggregation of routine events into readable episodes;
- hero voice and point of view;
- summaries of time away from the game window;
- memorable milestones;
- personal biography and history presentation;
- presentation of world events relevant to the hero;
- separation between gameplay facts and narrative wording.

## This document does not cover

- gameplay rules that create events;
- hero decision algorithms;
- combat resolution;
- quest selection;
- world simulation logic.

Those systems report facts. This system decides how those facts are presented as a story.

## Core boundary

Narrative must explain and dramatize simulation results without secretly deciding gameplay outcomes.

## Text Is One of the Main Ways the Player Experiences the Game

A significant part of the hero’s life happens autonomously and is not observed by the player directly. Text is therefore not merely decorative material layered on top of the simulation, but **one of the primary ways the player experiences the hero’s story**.

The chronicle and other narrative presentations should turn real simulation events into a clear and interesting account of:

- what the hero did;
- which decisions they made;
- what happened to them;
- how they changed;
- which events became important to their later life.

Narrative must not invent gameplay outcomes in place of the systems that create them. A real simulation event happens first; only then does the narrative system decide **how to tell it and how strongly to emphasize it**.

The goal is not to list every action, but to help the player see **the life of one specific character** inside a chain of systemic events.

> **The simulation creates events. Narrative turns them into the hero’s story.**

## Third-Person External Narrator

The hero’s primary story is told **in the third person**.

The game does not pretend that the hero is constantly writing a detailed personal diary about everything that happens. Instead, the events of their life are presented by a consistent external narrator.

The narrator may:

- describe the hero’s actions;
- connect separate events into coherent episodes;
- emphasize causes and consequences;
- notice recurring habits and patterns of behavior;
- help turn a sequence of simulation events into a readable story.

The narrator is **not a separate character inside the world** and should not interfere with events.

The player therefore reads the hero’s story from the outside rather than reading a literal diary the hero is required to write themselves.

> **The player observes the hero’s life through a narrator, rather than through a mandatory first-person diary.**

## Narrative Tone

The primary narrative style is an **adventure chronicle with a lively authorial voice**.

The narrator may use:

- light dry irony;
- occasional sarcastic remarks;
- observational humor;
- emphasis on recurring habits, awkward choices, or the absurdity of a particular situation.

This should never turn the game into a comedy or parody.

The more serious an event is, the more restrained the narration should become. An ordinary wolf-hunting contract may support a touch of irony; the hero’s death, the fall of a city, a major defeat, or a decisive turning point in their life should be treated with appropriate weight.

Narrative should not drift into:

- constant jokes;
- memes;
- modern internet slang;
- fourth-wall breaking;
- mockery of the hero;
- a mandatory punchline in every entry.

> **Humor should make the chronicle feel alive without making the world or the hero’s fate feel trivial.**

## Narrative Tone Examples

These examples are **tone references rather than fixed templates**. Final text should still reflect the actual simulation facts and the specific hero involved.

**Ordinary situation — light irony is appropriate:**

> For the third time that week, Alric agreed to clear the same forest of wolves. The local guard appeared to have concluded that wolves were, quite specifically, Alric’s problem.

**Serious event — no joke is needed:**

> By evening, the gates of Dornholm had fallen. The remaining defenders withdrew to the inner walls, while General Torvin left the city with what remained of the garrison.

**Good dry humor:**

> The reward for the goblins looked modest. After some thought, Edgar decided that twenty silver coins were still preferable to another evening in the tavern without twenty silver coins.

**Tone to avoid:**

> Edgar epically wrecked the goblins and gained +20 awesomeness.

The purpose of such examples is to keep future narrative writing aligned with the intended balance of seriousness, observation, and restrained humor.

## The Hero’s Personality Should Be Visible in the Writing

The same systemic event does not have to be described identically for different heroes.

The hero’s real characteristics may influence the narration, including:

- personality and persistent traits;
- past experience;
- combat traits;
- recurring habits;
- attitude toward risk;
- reaction to rewards;
- attitude toward specific enemies and factions.

These may affect **which details are emphasized, the phrasing, and the emotional shade of the text**, while the narration still remains in the third person.

For example, a cautious hero approaching a bandit camp might be described as:

> He set out for the bandit camp only after checking his supplies and buying another potion. His previous experience had been more than enough to stop treating preparation as a form of cowardice.

A risk-seeking hero in a similar situation might instead be described as:

> He remembered the supplies only after passing through the city gates. Going back for something so trivial seemed far more dangerous to his reputation than the bandits themselves.

Narrative must not invent a personality the hero does not actually have. It should reflect characteristics, history, and behavioral patterns that genuinely exist in the simulation state.

> **The hero’s personality should be visible not only in decision formulas, but also in how the story of their life reads.**

## Detailed Action and Decision Log

In addition to the narrative chronicle, the game may provide a **more detailed informational log** whose purpose is to explain what happened inside the simulation.

When desired, the player should be able to understand:

- what the hero actually did;
- which important options were available;
- why the hero preferred the chosen option;
- what happened in combat;
- what the hero bought, sold, found, or lost;
- which key traits, circumstances, relationships, or other factors materially affected the decision.

This log should **not become a dump of internal formulas and coefficients**. Its purpose is to make cause and effect understandable in player-facing language.

For example, a useful explanation might be:

> Edgar rejected the dangerous contract because the enemy was significantly stronger, and his cautious nature reduced the appeal of taking that risk even further.

A technical presentation such as raw score calculations, internal multipliers, or evaluator traces belongs in developer and debug tools rather than in the ordinary player-facing log.

The detailed log is also **not the hero’s diary or chronicle**. The chronicle turns events into a readable story; this layer exists so the player can inspect the mechanics behind what happened when they want more detail.

> **The player does not need to see the internals of the simulation constantly, but should be able to understand why the hero acted the way they did.**

## Main Hero Chronicle

The **main hero chronicle** is the primary narrative layer the player reads regularly, especially when returning to the game after time away from the window.

It should not repeat the detailed informational log line by line. Instead, it gathers multiple actions and events into **coherent episodes of the hero’s life**, preserving the important chain of cause and effect: decision → preparation → journey → encounter → result → consequences.

The chronicle should:

- read like an adventure story;
- preserve meaningful causes and consequences;
- emphasize what matters;
- omit insignificant micro-actions;
- reveal the hero’s personality through choices, habits, and reactions;
- let the player understand a meaningful stretch of the hero’s life within a few minutes.

The exact size of one chronicle entry is not fixed. It may cover several connected events or a broader period of life. The important requirement is that the player understands **not merely what happened, but what piece of the hero’s story was lived**.

For example:

> Edgar briefly considered dealing with the troll and decided to leave that honor to someone more desperate. Instead, he accepted a contract on the wolves along the northern road. Before leaving, he did buy a potion after all — his previous trip through those parts had noticeably improved his respect for preparation.
>
> The pack turned out to be larger than promised, but by evening the job was finished. Edgar returned to the city tired, carrying several new scratches and a pair of boots that looked considerably better than the ones he had been wearing that morning.

The relationship between the two layers is simple:

> **The detailed log explains what happened and why. The main chronicle turns those events into a story.**

> **The player should not have to read the entire simulation. They should be able to read the hero’s life.**

## Milestones of the Hero’s Life

Alongside the current chronicle, the hero should accumulate a **long-term record of the most important events of their life**.

This layer should not collect ordinary routine. It preserves only events that genuinely matter to the hero’s biography, such as:

- significant stages of development;
- gaining or losing important traits;
- acquiring or losing especially rare or memorable items;
- the first victory over an enemy type that had previously represented a major danger;
- major defeats;
- deaths and returns;
- important changes in relationships with factions or significant characters;
- participation in major wars or world events;
- decisions that noticeably changed the hero’s later path;
- the fall or salvation of a city when the hero was meaningfully connected to the event;
- completion of a long-term goal;
- other genuinely unique achievements and turning points.

An ordinary completed quest does not belong here. A first victory over a troll the hero once feared, however, may become a genuine milestone.

Over time, this record becomes **the memory of the entire playthrough** and one of the main sources for the hero’s final biography when their story ends or they retire.

> **The main chronicle tells the hero’s life as it unfolds. Milestones preserve what that life is ultimately remembered for.**

## World Chronicle

Separate from the hero’s personal story, the game may provide a **chronicle of major world events** that helps show that the world continues to change independently of the hero.

This may include:

- the beginning and ending of wars and sieges;
- notable border changes;
- the capture or loss of cities;
- the death, defeat, or retreat of significant characters;
- major world events;
- development of a global threat;
- rare disasters and other serious changes to world state.

For example:

> The human army began the siege of Liaris.  
> The Eastern Pass came under elven control.  
> General Torvin retreated from Dornholm.  
> The first confirmed undead detachments were sighted in the north.

The hero does **not need to participate** in these events. Their purpose is to give the player a wider context for the personal story unfolding inside that world.

The world chronicle should not overwhelm the hero’s main chronicle with hundreds of low-value simulation messages. Only events significant enough to matter to the player’s understanding of the wider world should be surfaced here.

It is not yet fixed that the player automatically knows everything occurring across the entire world. The exact rules for which world information can become visible to the player should remain consistent with later map, discovery, and information-visibility rules.

> **The hero chronicle answers “what happened to them?” The world chronicle answers “what was happening around them and without them?”**

## Relationship Between the Narrative Layers

The same real simulation event may appear in **more than one textual layer** when it is important enough, but each layer presents it for a different purpose and at a different level of detail.

For example, the hero defeats a dangerous necromancer.

**Detailed action and decision log:**

> Healing potion used.  
> Class ability activated.  
> Necromancer defeated.  
> Rare staff obtained.

**Main hero chronicle:**

> The fight proved harder than Edgar expected. By the time the necromancer finally fell, almost nothing remained of his supplies except his confidence — and even that had been badly shaken.

**Milestone of the hero’s life:**

> Edgar defeated a necromancer significantly stronger than himself for the first time.

If that victory also changed a larger world event — for example, by disrupting an undead offensive or affecting the fate of a city — it may also appear in the **world chronicle**.

Not every event should appear in every layer. An ordinary potion purchase may remain only in the detailed log; an important victory may appear in the chronicle and milestones; a war unrelated to the hero may appear only in the world chronicle.

> **The fact is the same. Different layers answer different questions about its meaning.**

## Migration note

The current debug log and future player-facing diary are separate concepts and should not be conflated.
