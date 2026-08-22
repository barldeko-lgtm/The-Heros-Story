# The Hero’s Story — Hero System Design

**Status:** Draft  
**Document version:** 0.1 skeleton

## Purpose

This document defines the hero as a persistent autonomous character and describes the systems that establish their identity, state, class framework, and long-term adventuring life.

## This document covers

- hero creation;
- name and background;
- class and archetype framework;
- primary hero attributes at a conceptual level;
- persistent hero state;
- life-cycle states such as active, wounded, dead, and resurrecting;
- the boundary between permanent hero identity and temporary effects;
- relationships between the Hero system and other systems.

## This document does not cover

- detailed personality decision logic — see `Personality_and_Decision_System_Design_v0.1.md`;
- combat formulas and level progression — see `Combat_and_Progression_System_Design_v0.1.md`;
- inventory and equipment rules — see `Economy_Equipment_and_Loot_System_Design_v0.1.md`;
- divine intervention — see `God_Influence_System_Design_v0.1.md`;
- narrative presentation of the hero’s history — see `Narrative_and_Diary_System_Design_v0.1.md`.

## Hero Creation and Background

At the beginning, the player gives the hero a name and makes roughly **4–5 sequential choices about their past**.

These choices do not grant simple bonuses such as “+2 Strength.” Instead, they establish the hero’s initial personality, tendencies, interests, and preferences, which later influence autonomous decisions and the direction of development.

The hero’s past may influence, for example, their attitude toward risk, types of activities, combat styles, or equipment.

> **The biography creates the hero’s initial inertia, but it does not define their fate.**

After the game begins, lived experiences and the hero’s own decisions can gradually change these initial tendencies.

## Starting Class

After the biography is created, the player directly chooses one of the hero’s basic starting classes: **Warrior, Archer, Mage, or Rogue**.

The class defines the hero’s main combat archetype: available ways of fighting, characteristic skills, class resources, and suitable equipment.

The class does not define the hero’s personality. Two heroes of the same class may become noticeably different because of their background, personality, preferences, development, and equipment they find.

In the future, the biography may produce a **recommended starting class**. The player may accept that recommendation or manually choose any other class.

Choosing a class different from the biography recommendation should not by itself be treated as a mistake or impose a penalty on the hero.

## Age and Natural Aging

The hero’s age is not a separate gameplay attribute and should not limit the duration of a playthrough.

The game does not require a system of natural aging, age-related penalties, or death from old age.

Game time is used for travel, quests, and world processes, but it does not have to correspond literally to human years of life.

This allows the player to observe the same hero for as long as they wish without being forced to regularly replace the character because of age.

> **The hero’s story ends because of their fate and decisions, not because the in-game calendar counted far enough into old age.**

## Voluntary Conclusion of the Hero’s Story

The game should not automatically end because the hero reaches a particular level, defeats a particular enemy, or crosses another mandatory milestone.

The player may decide that this hero’s story has reached its conclusion and begin a **special final stage of their journey**.

Until that point, the hero may continue living and developing for as long as the player wishes.

The finale should summarize the hero’s **actually lived biography** rather than present the player with a ready-made choice between endings such as “A / B / C.” The outcome may reflect who the hero became, what they achieved, which relationships they formed, which major events they took part in, and what mark they left on the world.

The narrative presentation of that final biography belongs to `Narrative_and_Diary_System_Design_v0.1.md`.

> **The finale is a look back at the hero’s lived story, not a mandatory point where the game decides to stop on its own.**

## Migration note

Content will be reviewed and migrated from the current concept document rather than copied automatically.
