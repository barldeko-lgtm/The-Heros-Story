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

These background choices have two main mechanical purposes:

1. they determine a **small pool of additional primary-attribute points** that the player may then distribute among the hero’s available primary attributes;
2. they create **small initial shifts on one or more hidden personality scales**, representing early inclinations formed by the hero’s past.

The background questions do **not** directly grant a visible personality trait. Their personality shifts are intentionally smaller than the amount required to establish a visible trait, so the hero begins life with some personal inclination but still has room to develop in another direction through later personality-forming choices.

For example, if a future tuned personality scale requires a much larger accumulated value before `Brave` becomes visible, one background answer might provide only a modest partial movement toward Brave. Exact scale ranges, trait thresholds, per-answer movement, and any creation-time cap are balance values owned by the personality system.

The complete character-creation sequence must be tuned so that the biography by itself does not normally cross a visible personality threshold. A starting inclination is not the same thing as an established trait.

The additional primary-attribute points are under direct player control. The background determines how much additional development is available at creation, while the player decides how to distribute that pool among the hero’s primary attributes. The exact pool size and whether different answers can change its size remain tuning questions.

Primary attributes and personality remain different concepts. High Strength does not mean Brave, high Dexterity does not mean Devious, and no primary attribute automatically assigns a personality trait. Attributes describe what approaches the hero is capable of using effectively; personality describes the tendencies that gradually emerge from the hero’s life and later influence personality-expressive decisions.

After the game begins, the hero’s visible personality develops through the personality-forming choice rules defined in `Personality_and_Decision_System_Design_v0.1.md`. Starting background shifts may make one direction somewhat closer than another, but they do not determine the hero’s fate.

> **The biography gives the hero starting capabilities and a slight personal inclination; their lived choices determine who they actually become.**

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

## Faction Reputation

The hero has a separate relationship with each major faction in the world.

At a high level, a faction’s attitude toward the hero moves along a scale such as:

> **Hostility ← Neutrality → Friendship**

Reputation is tracked independently for each faction. Good relations with one faction do not automatically imply good relations with another.

The exact numerical scale and thresholds between reputation states are not fixed yet.

## How Reputation Increases

The hero’s reputation with a faction increases when their actions **clearly benefit that faction**.

For example, reputation may rise when the hero:

- completes quests for the faction;
- helps its representatives;
- participates in events on its side;
- defends its territory;
- assists it during war;
- performs other actions that directly benefit it.

Reputation should increase because of the hero’s **actual actions**, not merely because the hero is nearby or because time passes.

> **A faction comes to regard the hero more favorably because the hero has done something for it.**

## How Reputation Decreases

The hero’s reputation with a faction decreases when their actions are **clearly directed against that faction**.

For example, reputation may fall when the hero:

- completes quests against the faction;
- participates in war on the side of its enemies;
- attacks its representatives;
- helps its enemies during conflict events;
- performs other clearly hostile actions.

Ordinary assistance to one faction **should not automatically damage relations with another**.

Negative reputation appears only when the hero’s action genuinely harms that specific faction — especially during wars and conflict events.

> **Hostility should be a consequence of real conflict, not an automatic price for friendship with someone else.**

## Consequences of Reputation Levels

As reputation changes, a faction’s attitude toward the hero should produce **noticeable gameplay consequences**.

High reputation may unlock:

- discounts and better trading conditions;
- additional services;
- special merchants;
- faction equipment;
- special quests;
- unique events;
- other opportunities connected to that faction.

Low reputation may lead to:

- less favorable prices;
- restrictions on some faction services and opportunities;
- negative attitudes from faction representatives;
- loss of access to special quests and faction-specific content;
- at extreme hostility, inability to freely use the faction’s cities or territories.

A small amount of negative reputation **should not immediately break the hero’s basic gameplay loop**. Serious restrictions should appear only when relations have genuinely reached the level of open hostility.

Exact thresholds and effects will be defined later.

> **Reputation should change how the world treats the hero gradually: from small advantages and inconveniences to genuine friendship or hostility.**

## Reputation Drift Toward Neutrality

If the hero does not interact with a faction for a long time, **small deviations in reputation gradually weaken and move back toward neutrality**.

This represents minor favors, small conflicts, and unimportant actions gradually fading from memory.

In general:

- mild friendship or dislike may fade relatively easily;
- strong friendship and serious hostility should change much more slowly;
- especially significant actions by the hero should not be erased completely merely because time has passed.

If the hero once saved a city or, conversely, caused a faction major harm, the emotional intensity of that relationship may soften over time, but the world does not have to forget the event entirely.

The exact rates of reputation drift will be defined later.

> **The world may forget small things with time, but important deeds should leave a longer memory.**

## Migration note

Content will be reviewed and migrated from the current concept document rather than copied automatically.
