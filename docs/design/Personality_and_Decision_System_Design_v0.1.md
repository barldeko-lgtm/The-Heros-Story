# The Hero’s Story — Personality & Decision System Design

**Status:** Draft  
**Document version:** 0.1 skeleton

## Purpose

This document defines how the autonomous hero develops a recognizable personality and how that personality affects decisions without removing common sense or turning behaviour into random noise.

## This document covers

- personality dimensions and traits;
- initial personality inertia from the hero’s past;
- acquired personality changes;
- preferences and tendencies;
- decision weights;
- decision points;
- how experience changes future behaviour;
- how the hero evaluates alternatives;
- the relationship between personal preference, rational evaluation, and divine influence.

## This document does not cover

- quest content itself — see `Quest_and_Activity_System_Design_v0.1.md`;
- combat progression and combat traits that primarily affect battle math — see `Combat_and_Progression_System_Design_v0.1.md`;
- divine ability rules — see `God_Influence_System_Design_v0.1.md`;
- diary wording and storytelling — see `Narrative_and_Diary_System_Design_v0.1.md`.

## Personality Has Mechanical Meaning

The hero’s personality must not be merely a set of descriptive traits.

The hero’s decisions and experiences gradually change their tendencies, and those tendencies influence future decisions:

> **decisions → experience → personality and tendencies → new decisions**

Personality traits should bias the hero’s choices without dictating them completely. Even a strong trait should not make the hero ignore obvious danger or basic common sense.

The goal is for the hero’s behaviour to become recognizable and internally consistent over time without becoming fully predictable.

## Migration note

Existing personality and autonomous-choice ideas will be reviewed individually before being moved here.
