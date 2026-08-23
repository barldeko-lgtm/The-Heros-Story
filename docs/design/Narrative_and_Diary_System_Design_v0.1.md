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

## Migration note

The current debug log and future player-facing diary are separate concepts and should not be conflated.
