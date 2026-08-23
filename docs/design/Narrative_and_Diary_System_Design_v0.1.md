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

## Migration note

The current debug log and future player-facing diary are separate concepts and should not be conflated.
