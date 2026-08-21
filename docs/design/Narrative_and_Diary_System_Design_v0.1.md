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

## Migration note

The current debug log and future player-facing diary are separate concepts and should not be conflated.
