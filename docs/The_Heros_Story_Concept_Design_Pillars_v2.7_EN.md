# The Hero’s Story — Concept & Design Pillars

**Working project title:** The Hero’s Story  
**Status:** the overall concept is established; individual systems will be developed in separate design documents  
**Document version:** 2.7 (English translation)

This is a living document for the game’s overall concept. It records the principles that have already been agreed upon, clearly marks optional late-stage hypotheses, and does not attempt to pre-solve formulas, balance, or implementation details for individual systems.

This is not a complete GDD and not a promise to implement every late-stage or optional idea listed here.

---

## 0. Core Rule for Discussion and Design

The assistant must not automatically agree with the user’s proposals or look only for the positive side of every idea.

Every meaningful proposal concerning the concept, mechanics, world structure, progression, interface, or production must be **critically examined**.

The assistant should say so directly if an idea:

- weakens the core concept;
- contradicts principles that have already been accepted;
- makes the game more boring or harder to understand;
- creates the illusion of depth without a noticeable result for the player;
- requires too much development effort or unique content for the value it provides;
- turns indirect control into disguised direct control;
- makes the player’s influence so weak or meaningless that their decisions no longer have noticeable consequences;
- makes the hero so obedient that the sense of an independent personality disappears;
- adds unnecessary simulation complexity;
- would be solved better by a simpler system.

In such cases the idea should be challenged, alternatives should be proposed, and the idea should be discarded if necessary.

The same rule applies to ideas proposed by the assistant. A previously suggested solution is not automatically correct simply because it has already appeared in the discussion.

**The goal is not to reach agreement at any cost, but to find the strongest, most interesting, and most feasible version of the game.**

---

## The Game in One Paragraph

**A single-player autonomous high-fantasy RPG / life simulation centered on one hero.**

The hero independently travels through a living world, chooses quests, fights, develops, buys and replaces equipment, forms a personality, and takes part in world events.

The player acts as a deity: observing the hero’s story, gently influencing decisions, and occasionally providing direct help through limited divine power.

The game is designed to run for long periods in the background, with the player returning for short check-ins.

The central fantasy is:

> **to watch one autonomous hero live through their own adventuring life, gradually become a distinct person, and leave — or fail to leave — a mark on the world.**

### Setting

The base genre is **classic high fantasy**.

Humans, elves, dwarves, magic, monsters, kingdoms, adventurers, and familiar fantasy weapons and equipment are a natural foundation for the world.

The project does not attempt to distinguish itself through a radically unusual setting. Its main identity should come from the autonomous life of the hero, watching their fate unfold, and the player’s indirect influence as a deity.

The specific lore of the continent, kingdoms, cultures, religions, wars, and history will be developed separately.

When a new game is generated, parts of the political situation, territorial ownership, and some historical details may vary within predefined rules.

## 1. Core Concept

The game is built around **one autonomous hero** whom the player does not control directly.

The hero independently:

- travels;
- chooses activities and quests;
- fights;
- develops;
- buys and replaces equipment;
- interacts with NPCs and factions;
- makes decisions;
- forms a personality, personal tendencies, reputation, and attitudes toward individual characters;
- chooses the future direction of their life.

The player exists above this system as a kind of **deity / patron / external force**.

The player should not issue ordinary RPG commands such as:

- “go here”;
- “attack this enemy”;
- “take this exact quest”;
- “equip this exact sword.”

Instead, the player indirectly influences the hero’s decisions and occasionally helps during critical moments.

At the same time, **interest in the hero and their development is more important than the divine-control layer**.

The hero must be capable of living a complete life, developing, making mistakes, growing stronger, and changing their fate even without active player involvement. The player can make that path more directed, faster, safer, or more successful, but player presence must not be required for the game to function.

Core formulations:

> **The hero lives. The world creates circumstances. The player guides.**

> **The player does not control the hero — the player influences the probability of the hero’s fate.**

---

## 2. Player Fantasy

The central fantasy is **watching a weak beginning adventurer gradually become a strong, recognizable individual with a history of their own**.

The player should care not only about larger numbers, but also about:

- how much stronger the hero has become;
- what kind of personality they developed;
- which traits they gained and which ones they overcame;
- what development path they followed;
- what equipment they obtained;
- which enemies they once feared but can now defeat;
- what reputation they earned and toward whom they developed notable personal attitudes;
- which events became part of their biography.

The role of patron exists on top of that foundation.

Desired feeling:

> “This is my hero. They can live on their own, and I occasionally guide them and help their journey go a little better.”

The hero should feel like an independent person, not a game cursor with a health bar.

---

## 3. Main Design Principles

### 3.1. The Hero’s Development and Fate Are the Primary Source of Interest

First and foremost, the game should be interesting as **observation of the life and development of an autonomous hero**.

Combat, the living world, personality, equipment, quests, and events should primarily help create a clear and varied story of one specific character’s growth.

Divine influence is designed **on top of an already functioning hero life**, not used as the main way to make the game interesting.

When evaluating any new system, the first question should be:

> **Does this make the hero’s development and fate more interesting to observe?**

### 3.2. Not a Simulation of an Entire Life, but a Simulation of the Hero’s Journey

The game does not attempt to model a person’s everyday life in detail.

There is no need for mechanics such as:

- recurring hunger;
- mandatory meals several times a day;
- toilet needs;
- detailed daily household routines;
- other processes that do not create interesting decisions or consequences.

We deliberately use game abstractions.

Core principle:

> **We are not simulating life in its entirety. We are simulating the hero’s gameplay loop and the events capable of meaningfully changing their path.**

The base routine should be simple and understandable. Depth should come from the systems and content layered on top of it.

### 3.3. Autonomous Hero

The hero can function and develop fully without constant player involvement.

Without the player actively intervening, the hero should still:

- choose activities and quests;
- travel;
- fight;
- buy and replace equipment;
- gain levels;
- form personality and traits;
- change plans and cities;
- take part in events;
- experience success, mistakes, death, and resurrection.

The player can become distracted, minimize the game, or leave it unattended for a long time, while the hero continues to live and make decisions **as long as the application is running**.

If the application is fully closed, both the hero and world simulation are paused.

Without active patronage, the hero’s path may be slower, more dangerous, or less focused, but **it must not stop simply because the player is not paying attention while the game is running**.

Autonomy is not decorative: the hero genuinely makes their own decisions.

### 3.4. Indirect Control

The player primarily defines a **direction**, not a specific action.

For example, instead of directly ordering “go to the dwarven city,” the deity creates an inclination or sends a sign that the hero will take into account when they next genuinely decide where to travel.

The hero may follow the sign, choose another option, or change plans because of new circumstances.

### 3.5. Decisions Happen at the Appropriate Moment

Soft divine influence should not interrupt an action the hero is already carrying out.

If the hero is inside a dungeon or finishing a quest, a sign saying “go to the dwarves” should not make them abandon everything immediately.

The influence remains active until an appropriate **decision point** — for example, when the hero finishes their current business and chooses the next city.

If the player gives a sign precisely while the hero is already making the relevant decision, the influence may be slightly stronger. This rewards active observation without making constant presence mandatory.

### 3.6. A Living World

The world exists independently of the hero.

While the hero is busy with their own affairs:

- cities may develop or decline;
- factions may come into conflict;
- territory and political conditions may change;
- opportunities may appear and disappear;
- events may occur.

The hero can influence what happens, but **the world must not wait for the hero while the game is running**.

Factions, events, wars, and the global threat continue to develop regardless of whether the hero participates in them or whether the player is currently looking at the game window.

This world autonomy **does not mean offline progression**: when the application is fully closed, the entire simulation is paused.

### 3.7. The Hero Is Not the Center of the Universe

Most world processes can continue without the hero’s participation.

This is necessary for the world to feel like an independent system rather than scenery built around the protagonist.

### 3.8. Core Player Loop

The player’s main loop is different from the hero’s own life loop.

> **Observe → read what happened → assess the hero and the world → optionally provide direction or intervene with divine power → let the hero continue living independently.**

The player is not required to perform an action every time they return to the game.

A normal short session may consist only of the player:

- opening the game window;
- reading the journal;
- looking at how the hero has changed;
- noticing a new item, trait, city, or world event;
- changing nothing;
- leaving the simulation running again.

Divine intervention should be meaningful, but it should not be mandatory in every short session.

### 3.9. A Background Game, but Not an Offline Idle Game

The game should not require constant attention.

Expected usage pattern:

> the player starts the game → leaves the hero to live autonomously → minimizes the game or does something else → periodically returns for a few minutes to read the journal, check the hero’s development, and optionally intervene as a deity.

While the game is **running**, the hero can, without active player participation:

- travel;
- complete routine quests;
- fight;
- earn money;
- buy useful items;
- develop;
- make ordinary decisions.

However, the game is not a traditional offline idle game.

If the application is fully closed, the hero and world simulation **stop**.

The main reward for time spent away from the window is not only resources and numbers, but **the story that happened**.

When returning to the game, the player should quickly understand what the hero did, which important decisions were made, how the hero changed, and what happened around them.

### 3.10. The Hero’s Personality Has Mechanical Meaning

Personality is not decorative text.

The hero’s experiences and decisions shape tendencies, and those tendencies influence future choices.

Approximate principle:

**decisions → experience → personality and tendencies → new decisions.**

A personality trait must not completely disable common sense.

---

## 4. Game References

References are used to study specific solutions, not to copy entire games.

### Majesty

**Take:**

- indirect control;
- character autonomy;
- incentives instead of orders;
- the feeling that heroes have wills of their own.

**Do not automatically take:**

- RTS structure;
- kingdom construction as the main loop;
- control over a large number of heroes;
- constant settlement management.

### Space Rangers

**Take:**

- a world that develops independently of the player;
- competing powers;
- changes in the global situation;
- events that may resolve without the hero’s participation.

**Do not automatically take:**

- the space setting;
- an enormous economic simulation;
- mandatory trading;
- simulation on such a scale that the player can barely perceive its consequences.

### Godville

**Take:**

- the “deity ↔ one hero” relationship;
- hero autonomy;
- divine influence;
- the pleasure of watching an independent character;
- the idea of forgiving death and return.

**Do not take:**

- a fully comedic tone as the project’s foundation;
- excessive player passivity;
- a situation where interaction is reduced almost entirely to reading random lines.

### The Tale

**Take:**

- an autonomous hero;
- personality and preferences as parts of AI;
- gradual formation of personality;
- indirect influence over character development;
- the idea of a Guardian;
- a forgiving death-and-resurrection model.

**Do not automatically take:**

- MMO elements;
- collective player politics;
- systems that only become meaningful with a large community.

### TBH: Task Bar Hero

**Take:**

- the ability to play without constant attention;
- short check-in sessions;
- hero development while the player is busy;
- the sense that the character’s life continues.

**Do not automatically take:**

- an incremental numbers race;
- endless multipliers;
- progression purely for DPS;
- turning the hero into a resource generator.

Our goal is **idle as convenience**, not idle as the entire point of the game.

### Dyna Genesis

Dyna is primarily a source of our own development experience.

**Take:**

- autonomous entities;
- systemic interaction;
- indirect influence;
- a simulation-first approach.

**Lessons from development:**

- monitor the required volume of visual content early;
- avoid systems that demand excessive amounts of unique animation;
- validate the core gameplay loop earlier;
- show a working version to other people earlier;
- clearly separate system responsibilities.

---

## 5. Visual Direction — Separate Task

The overall visual style has not yet been defined and **is not considered an unresolved question of the mechanical concept**.

It should be developed separately in an art-direction document after the main screens and the required content volume are established.

### 5.1. Equipment — Shop Heroes as a Reference

For weapons, armor, helmets, accessories, and other equipment, the visual language of **Shop Heroes** is a reference:

- large, readable silhouettes;
- stylized fantasy;
- moderately cartoon-like proportions;
- clean and expressive rendering;
- strong sense of volume without visual overload;
- clearly distinguishable materials;
- good readability at small sizes;
- a sense that items have value.

### 5.2. Limitation

Shop Heroes is a reference **specifically for equipment**, not automatically for:

- the world;
- the hero;
- the map;
- the interface;
- environments;
- the overall tone of the game.

The general art style will be defined separately.

---
## 6. Hero Creation

### 6.1. Name

At the beginning, the player gives the future hero a name.

This is the first action that emphasizes the player’s connection to one specific character.

### 6.2. The Hero’s Past

Hero creation includes roughly **4–5 sequential choices about the hero’s past**.

The reference is the approach used in Mount & Blade II: Bannerlord, but without simple bonus assignments such as:

> “lumberjack family = +2 Strength.”

Choices about the hero’s past should primarily establish:

- the starting position on the main personality scales;
- personal inclinations and interests;
- attitudes toward different kinds of activities;
- interest in particular combat styles or equipment;
- initial weights that may later influence autonomous decisions and the distribution of part of the hero’s attribute growth on level-up.

For example, a childhood connected to hunting might make the hero more inclined toward ranged combat, slightly more cautious about danger, and more likely over time to favor the development of attributes that fit that style.

The past creates **initial personality inertia**, but it does not define the entire life forever. Later actions and lived experiences can gradually change the hero.

---

## 7. Personality and Acquired Hero Traits

The hero’s personality should emerge from biography and later life rather than being a fixed set of bonuses chosen in advance.

At the current stage, there are two main layers:

1. **personality traits** — shape behavior and decisions;
2. **combat traits** — emerge from combat experience and directly affect encounters with specific types of enemies.

A Darkest Dungeon-style stress system is explicitly not being carried into this project.

### 7.1. Personality Traits Are Neither Positive nor Negative

Personality traits are not divided into good and bad.

They describe a tendency to make certain kinds of decisions and should have both advantages and drawbacks.

The preferred model is a set of bipolar scales.

Possible directions, not yet a final list:

- caution ↔ risk-taking;
- mercy ↔ cruelty;
- honesty ↔ cunning;
- altruism ↔ selfishness;
- curiosity ↔ conservatism.

For example, a cautious hero may:

- choose safer quests more often;
- prepare more thoroughly;
- retreat earlier;
- buy consumables more frequently.

This improves survivability but may lead to missed rewards and rare opportunities.

A risk-seeking hero may achieve exceptional results more often, but will also end up in dangerous situations more often.

> **A personality trait should create a style of life, not merely grant a green bonus or a red penalty.**

### 7.2. How Personality Forms

The initial position on the personality scales is determined by the hero’s biography.

After the game begins, personality gradually changes under the influence of the hero’s own actions.

General principle:

> **actions → experience → personality change → new decisions.**

If the hero regularly behaves in a certain direction, the corresponding trait gradually strengthens.

If the hero repeatedly acts against the current personality tendency, the value gradually shifts toward the opposite side.

A single random action should not rewrite the hero’s personality.

Personality should be stable enough that the player recognizes the hero, yet flexible enough that a long sequence of adventures can genuinely change them.

### 7.3. Personality and Decision-Making

Personality traits modify the **weights of options** rather than hard-locking actions.

For example, when facing an unknown cave:

- curiosity increases the appeal of exploring it;
- caution increases the appeal of going around it;
- the reward, the hero’s current condition, the current goal, and a divine sign also affect the choice.

This allows internal conflicts between different tendencies.

Divine influence is layered on top of personality rather than replacing it.

### 7.4. Combat Traits

Combat traits are separate from general personality.

They may be:

- **positive**;
- **negative**.

They arise from repeated or especially meaningful combat experiences and are primarily tied to specific enemy types, factions, or threats.

Examples:

**positive:**
- Undead Slayer;
- Beast Hunter;
- Goblin Bane.

**negative:**
- Afraid of the Undead;
- Fear of Dragons;
- Uncertain Against Mages.

Names and exact effects are not yet fixed.

### 7.5. How Combat Traits Appear

Combat traits should not appear randomly after every battle.

Each potential trait may have a hidden accumulating experience value.

For example, a series of severe defeats or deaths caused by undead gradually increases the likelihood of developing a fear of them.

Successful victories against the same threat move that accumulated experience in the opposite direction.

A normal single fight should have only a small effect.

A particularly strong event — a crushing defeat, death, an important victory, or defeating a powerful enemy — may have a larger impact.

When the hidden value crosses a certain threshold, the corresponding trait becomes visible to the player.

It is preferable to use different thresholds for appearance and disappearance so a trait does not constantly flicker on and off around one boundary.

### 7.6. How Negative Combat Traits Disappear

A negative combat trait is not a permanent debuff.

The main way to overcome it is through **opposite life experience**.

For example, a hero who fears undead may:

- encounter them again;
- win successfully;
- survive several good expeditions;
- achieve an especially meaningful victory.

The accumulated fear gradually decreases until the trait disappears.

In some cases, a long period without reinforcement of the fear, or an important authored event, may also accelerate change.

A negative trait can therefore become part of a small personal story:

> defeat → fear → avoidance → new encounters → overcoming → fear disappears.

After prolonged successful experience in the same direction, a positive combat trait may eventually appear instead.

### 7.7. Positive Combat Traits Do Not Have to Be Permanent Either

If the hero goes a long time without reinforcing a positive trait, or repeatedly has opposite experiences, that trait may also weaken and disappear.

The hero’s personality and experience should remain alive rather than becoming an endless list of accumulated modifiers.

### 7.8. Trait Persistence

A trait that has been reinforced for a very long time may eventually become more deeply rooted and require stronger opposite experience to change.

This is currently considered a possible later extension of the system, not a required feature of the first version.

### 7.9. Preferences as Part of Personality

At the current stage, there is no separate “preferences” system.

All persistent personal inclinations are temporarily treated as part of the broader **personality trait system**.

They may include:

- attitudes toward specific peoples and factions;
- favorite types of activities;
- favorite places;
- personal attitudes toward individual NPCs;
- equipment preferences;
- other personal tastes.

For now, an attitude toward an NPC means **a modifier to behavior and choice**, not a separate deep system of friendship, romance, or social simulation.

If the personality system becomes overloaded later, preferences may be split into a separate layer. Doing so now would be premature complexity.

---

## 8. Hero Progression and Classes

### 8.1. Starting Class

After the biography, **the player chooses the starting class**.

The class defines the hero’s basic archetype and should influence not only equipment or damage numbers, but also **how the hero behaves in combat and which tools they use to solve combat problems**.

Two heroes of the same class may differ significantly because of their past, personality, equipment, attributes, and later decisions.

### 8.2. Overall Hero Level

At the current stage, the game uses a classic **overall hero level** system.

The hero gains experience from completed adventures, quests, victories, and significant events.

When enough experience has been accumulated, the hero levels up.

Level is the main source of gradual vertical growth for the hero’s basic attributes.

A separate TES-style progression system for proficiency with every weapon type is **not used** at this stage.

Reason: automatic growth such as “Axes +1” or “Swords +1” without meaningful player or hero choice would create extra statistics and could unjustifiably lock the hero into one weapon type for the entire game.

### 8.3. Attribute Distribution on Level-Up

The player **does not manually allocate attribute points on every level-up**.

Instead, growth comes from three sources:

1. **hero class** — guarantees that part of the growth goes into a key attribute;
2. **deity preference** — a development direction chosen in advance by the player;
3. **the hero** — most of the growth is distributed automatically under the influence of personality, tendencies, and lived experience.

A purely illustrative example, not a final balance value:

> on level-up, the hero receives 5 attribute points.

Then:

- `+1` goes to the class’s primary attribute;
- `+1` goes to the attribute favored by the deity;
- the remaining `+3` are distributed by the hero.

For example, a Warrior whose deity has expressed a preference for Intelligence might receive:

- `+1 Strength` — from class;
- `+1 Intelligence` — from divine influence;
- the remaining points — according to the hero’s own internal logic.

The number of points and proportions may later change through balance work. At the concept level, what is fixed is the **principle of shared influence over growth**.

### 8.4. How the Hero Distributes Their Own Growth

The points belonging to the hero are not distributed purely at random.

Attribute weights may be influenced by:

- personality traits;
- tendencies formed by biography;
- current interests;
- overall lifestyle;
- recent meaningful experiences.

Life experience should influence growth softly rather than turning into a TES-like rule such as:

> “hit something with an axe one hundred times → gain +1 Axes.”

For example, an aggressive, strength-oriented life may slightly increase the weight of Strength; a mobile and cautious style may favor Dexterity; and a sustained interest in knowledge and magic may favor Intelligence.

Core principle:

> **Class determines who the hero started as. The deity softly indicates a desired direction. The hero themselves largely determines who they become.**

### 8.5. Growth Must Be Understandable to the Player

Although allocation happens automatically, the player should understand why the result occurred.

On level-up, the interface may show:

- which attributes increased;
- which part came from class;
- which part came from the deity’s preference;
- which hero tendencies influenced the rest.

The player does not need to see internal numerical weights, but the hero’s development must not feel like a random-stat generator.

### 8.6. Primary Attributes, Resources, and Secondary Parameters

At the current stage, the attribute system should remain simple.

#### Primary Developable Attributes

Points gained on level-up are distributed primarily among three basic attributes:

- **Strength**;
- **Dexterity**;
- **Intelligence**.

These are the attributes used by the shared growth system between class, deity preference, and the hero’s autonomous choice.

Additional primary attributes should not be introduced without a concrete need.

#### Main Hero Resources

Separate from those attributes are pools and resources used in combat and in world activity:

- **HP / Health**;
- **Stamina** — energy for travel and other actions outside combat;
- **class resource** — for example Mana, Rage, or another unique class mechanic.

These values should not automatically be merged into the three distributable primary attributes.

Exact formulas for HP, Stamina, and class-resource growth will be defined later. They may depend on level, class, primary attributes, equipment, or a combination of these.

#### Secondary Combat Stats

Parameters such as:

- attack power;
- armor;
- speed;
- critical hit chance and critical damage;
- luck;
- dodge;
- accuracy;
- other specialized combat values

are treated as **secondary stats**.

They are used directly in combat math and may be derived from:

- primary attributes;
- class;
- equipment;
- abilities;
- temporary effects;
- other sources.

The complete list of secondary stats and exact formulas are **not fixed** at the concept stage. They should be designed separately when combat math is developed.

### 8.7. Sources of Permanent Hero Power

The hero’s core permanent combat power comes from four layers:

1. **hero level and the attributes gained from it**;
2. **class abilities and their level of development**;
3. **equipment — base power, quality, rarity, and special properties**;
4. **combat traits**, which provide specialized advantages or disadvantages against particular threats.

The relative importance of these sources changes throughout the hero’s life:

- during the formation stage, level and basic attributes are especially important;
- near the soft cap, vertical growth slows down;
- during the mature stage, equipment, ability development, and the hero’s individual specializations matter more.

Temporary effects, consumables, and divine assistance may significantly change a particular fight, but they are not considered part of the hero’s primary permanent power.

### 8.8. Two Stages of Hero Development

Hero progression is provisionally divided into **two broad stages**.

These are not two rigid modes, nor a moment when the game suddenly “unlocks the map.” The world is available from the beginning; the transition between stages is primarily determined by the hero’s own development.

#### Stage 1 — Formation

At the beginning of the game, level is one of the hero’s main sources of power.

During this period:

- the hero gains levels quickly;
- basic attributes increase noticeably;
- personality becomes visible;
- traits form and change;
- the hero learns core class abilities;
- later, the hero may reach a specialization / subclass;
- equipment matters, but is not yet the primary source of progression.

The world map contains several naturally suitable starting areas — for example, two or three major cities with relatively safe surroundings and appropriate early quests.

However, these are not sealed-off “newbie zones.”

The hero is formally able to travel anywhere, but autonomously evaluates:

- available quests;
- known threats;
- personal strength;
- potential rewards;
- whether the journey makes sense.

A weak beginning hero therefore naturally prefers to remain near places offering suitable tasks and opponents rather than making a pointless trip into a region full of threats they obviously cannot handle.

Early enemies do not automatically scale with the hero. As the hero grows, they should genuinely outgrow former threats.

#### Stage 2 — Maturity

Once the hero is largely formed and approaches the **soft cap**, ordinary levels become less important.

Levels and attributes may continue to rise, but much more slowly and should no longer be the primary source of power.

The hero does not receive a newly “opened world” — they simply become strong and experienced enough that more of the world that always existed becomes practically relevant.

The focus shifts toward:

- finding and improving equipment;
- rare items;
- combat traits;
- specialization;
- preparation for specific threats;
- reputation and persistent personal attitudes toward individual characters;
- factions;
- authored events;
- changes on the global map;
- more dangerous adventures, dungeons, and bosses.

Core principle:

> **Early on, the hero is mainly becoming stronger. In maturity, what matters more is who the hero has become, what they carry, and what kind of world they live in.**

### 8.9. Soft Cap

The soft cap does not mean progression stops completely.

After it:

- level can still increase;
- attributes can still grow;
- class abilities and their development may continue;
- but each additional increase becomes less significant.

The purpose of the soft cap is to gradually shift focus away from pure vertical growth and toward equipment, the hero’s individual characteristics, and participation in the living world.

The first stage should not feel like a long tutorial before the “real game.”

Factions, events, and world changes should exist from the start; a young hero simply has far less ability to influence them.

### 8.10. Class Must Change the Rules of Combat

A class is not justified if the difference amounts to:

- Warrior carries a sword;
- Archer carries a bow;
- Mage carries a staff;
- everyone simply has slightly different damage.

Core principle:

> **Class defines not only the hero’s power, but the logic of how they fight.**

Ideally, the combat text log should make the hero’s class recognizable even if the class name itself is hidden.

### 8.11. Basic Class Kit

Provisional rule for a starting class:

- **one unique combat mechanic**;
- **2–3 basic abilities** available relatively early.

The unique mechanic does not have to be a separate resource bar.

Examples of direction, not finalized class designs:

- Mana for the Mage;
- Rage or combat momentum for the Warrior;
- distance / aiming for a ranged hero;
- advantage / stealth for a more cunning archetype.

Do not invent an artificial colored resource for every class merely for symmetry.

### 8.12. Automatic Ability Use

The player does not manually activate the hero’s combat abilities.

The hero decides when to use available abilities.

The decision may be influenced by:

- current combat state;
- health;
- available class resource;
- enemy strength and type;
- probability of victory;
- hero personality;
- willingness to take risks;
- the need to conserve resources for the rest of the journey.

Thus, **class defines the tools, while the hero’s personality affects how those tools are used**.

### 8.13. Specializations

Later in life, the hero gains an opportunity to develop the starting class through specialization.

A specialization:

- logically continues the base archetype;
- does not abruptly turn the hero into an opposite class;
- may grant roughly 1–2 new abilities;
- may modify or expand the core class mechanic;
- takes into account attributes, personality, tendencies, and adventures actually lived through.

**The player chooses the starting class. The hero chooses the specialization.**

The player should understand why the hero arrived at that path.

Example principle:

> an Archer may develop into different ranged or exploration-oriented archetypes, but does not suddenly become a heavy tank.

### 8.14. Base Starting Classes

Four basic classes are enough for the first conceptual version:

- **Warrior**;
- **Archer**;
- **Mage**;
- **Rogue**.

Subclasses, specializations, exact resources, and full ability kits are not priorities yet and will be designed later.

When each class is developed further, it should be tested against these questions:

1. How is its combat logic different?
2. What does it do at the beginning of a fight?
3. What changes as a fight drags on?
4. What resource, state, or condition causes it to change tactics?
5. Can its role be understood from the text combat log without seeing the class name?

### 8.15. Possible Group Content — Hypothesis Only

In the future, the game may consider difficult dungeons, raids, or other activities where the hero temporarily joins NPC heroes.

This could make class combat roles more meaningful and create relationships between characters.

**This is not part of the confirmed core game and is not a commitment for the first version.**

The single autonomous hero must work first.

### 8.16. Base Combat Model

Combat is an important part of the hero’s journeys, but **it is not the project’s primary gameplay core**.

The main focus is hero development, decisions, personality, fate, and the world’s influence on the hero’s life. Combat exists as a source of risk, progression, loss, victory, and significant events.

Therefore, the base combat system should be:

- automatic;
- understandable;
- varied enough to distinguish different classes and monsters;
- but not overloaded with complex rules and micromanagement.

#### Combat Format

The basic model is a **1v1 duel**.

The hero and opponent each have a speed value that determines how frequently they receive an opportunity to act.

This is not the classic sequence:

> hero attacks → monster attacks → hero attacks → monster attacks.

The faster participant acts more frequently.

Exact formulas, speed limits, and action-frequency balance will be determined later. At the concept level, the important point is that speed affects action tempo without allowing one participant to take a ridiculous number of consecutive actions.

#### Auto-Attack

When the hero’s action meter fills, the default action is an **auto-attack**.

Auto-attacks are the foundation of combat and require no player input.

#### Abilities

Sometimes the hero autonomously uses a class ability instead of auto-attacking.

At the beginning, each class is expected to have a small kit — around 2–3 abilities.

Abilities may be limited by:

- cooldowns;
- class resources;
- situational requirements;
- or a combination of several simple conditions.

There is no need for an elaborate decision system for every individual ability.

The hero should use abilities in a way that is reasonably logical and understandable, not perfectly optimized.

#### Class Resources and Mechanics

Different classes may have different central combat mechanics.

For example:

- the Mage uses Mana;
- the Warrior may build Rage;
- other classes may use their own states or combat rules.

Not every class needs a separate resource bar.

#### Item Use

The hero can autonomously use appropriate consumables such as healing potions.

An item is used when the situation genuinely calls for it.

Using an item normally counts as a separate action and should not be a free addition to an ordinary attack.

#### Player Role in Combat

The player does not directly control the hero’s attacks or abilities.

The deity can only provide **limited help from above**:

- heal the hero;
- temporarily empower the hero;
- later, use other rare forms of intervention.

The hero should win ordinary fights independently.

Player assistance exists primarily to:

- survive more fights without resting;
- recover from an especially unlucky situation;
- help against a stronger opponent;
- improve the chance of success in an important or risky adventure.

Divine assistance must not become mandatory in every fight.

> **The player does not win the fight instead of the hero — the player occasionally helps the hero exceed their ordinary limits.**

#### Complexity Limit

At the concept stage, do not dive into complicated combat formulas, large numbers of effects, dozens of abilities, or detailed tactical AI.

Combat should first prove that it is:

- easy to read;
- sufficient to differentiate classes;
- capable of creating risk;
- functional without player micromanagement;
- supportive of the larger game about the hero’s fate.

Additional depth should only be added if it genuinely improves the game experience.

---

## 9. Divine Influence and Player Progression

This section is a **secondary layer on top of the core hero simulation**.

The hero’s autonomous life, development, and fate must first be interesting on their own. Divine mechanics should guide, accelerate, or ease particular moments without becoming the main source of progression.

### 9.1. Soft Influence

The deity may nudge the hero toward certain decisions:

- a travel direction;
- a quest;
- a level of risk;
- interest in an NPC or faction;
- other major choices.

This is not an order, but an additional weight applied to the relevant option.

Internally, influence may be represented by numerical weights, but the player should perceive it as a sign, inclination, or divine suggestion rather than “+20% to a button.”

If the sign is given directly at the relevant decision point, its effect may be slightly stronger.

### 9.2. Direct Divine Intervention

There is also a rarer form of divine power.

It regenerates slowly enough that the player cannot intervene in every ordinary fight.

At the beginning, the main forms of assistance are expected to be:

- **healing**;
- **combat blessing / temporary empowerment**.

Later deity progression may unlock additional forms of intervention.

The hero should overcome ordinary difficulties on their own.

> **Divine power is especially valuable in exceptional and dangerous situations, but does not replace the hero during normal play.**

### 9.3. Deity Power Progression — Confirmed but Later Layer

**Growth of the deity’s power will definitely be part of the game**, but the concrete system is intentionally not being designed yet.

First, the game needs to define:

- hero progression;
- growth of the hero’s real combat power;
- equipment;
- the threat structure;
- progression pace.

Only after the hero system is established should deity progression be designed on top of it, so divine abilities do not break balance or compete with the hero for the role of primary progression source.

The overall direction remains:

- deity power grows more slowly than hero power;
- stronger and more varied forms of influence gradually become available;
- later, divine influence may extend beyond simple healing or hero buffs.

The exact structure, resources, branches, and progression pace will be determined later.

### 9.4. Passive Regeneration of Divine Power

At the overall concept level, the main resource for direct divine intervention **regenerates passively while the game is running**.

This supports the intended rhythm:

> the hero lives independently for a while → the player returns → a limited amount of intervention is available again.

Later, regeneration speed or capacity may be affected by:

- deity level or progression;
- divine perks;
- the deity’s renown in the world;
- the hero’s renown or reputation;
- other suitable systems.

These accelerators are not required for the first version.

The accumulated resource should provide an **opportunity to intervene**, but it should not become the main reason to open the game.

The main reason for returning is:

> **interest in what happened to the hero and who they are gradually becoming.**

### 9.5. Deity Personality — Optional Later Layer

There is no plan for a simple initial toggle such as:

> “good deity / evil deity.”

If this later layer proves useful, the deity’s own direction should emerge from the player’s actions:

- mercy;
- cruelty;
- inclination toward war;
- protection;
- and other directions still to be defined.

### 9.6. Hero–Deity Relationship — Optional Later Layer

A separate mechanic for the hero’s trust in the deity **is not required for the core of the first version**.

If added later, the hero may:

- trust their patron;
- doubt divine signs;
- resist them;
- become more or less religious.

High trust may increase the weight of divine influence, but **must not turn the hero into a fully controllable unit**.

---
## 10. Core Adventure Loop

The hero has **one stable core RPG loop** that makes up most of ordinary life.

Provisionally, it works like this:

1. the hero arrives at a tavern or another place where jobs are available;
2. evaluates suitable quests;
3. chooses one;
4. prepares if necessary;
5. sets out to complete it;
6. travels, encounters enemies, and fulfills the objective;
7. returns;
8. turns in the quest and receives the reward;
9. goes to the market;
10. sells trophies and unwanted items;
11. evaluates what is worth buying or replacing;
12. returns to looking for the next job;
13. the loop repeats.

The player should not manually service every step.

### 10.1. Routine Is a Foundation, Not a Flaw

Repeated hero actions are necessary.

The game does not try to replace the base loop with dozens of equally important everyday activities. The hero primarily lives the familiar life of an adventurer:

- takes jobs;
- travels;
- fights;
- returns;
- earns rewards;
- trades;
- improves equipment;
- chooses the next task.

Against this stable routine, the player can clearly notice how much the hero has grown and how the path has changed.

### 10.2. Variety Comes from Layers on Top of the Loop

The same core loop gradually becomes more varied through other systems.

It may be influenced by:

- the hero’s personality and personal tendencies;
- level, power, and equipment;
- the presence or absence of suitable quests;
- rare random and authored events;
- rumors and temporary opportunities;
- personal attitudes toward individual NPCs;
- faction conflicts and wars;
- changes in cities and regions;
- consequences of past adventures;
- divine influence.

For example, the hero may return to the tavern and discover that:

- suitable quests have run out;
- the remaining quests are too weak or too dangerous;
- new quests replenish more slowly than the hero can complete them;
- a rumor has appeared about a temporary opportunity in another city;
- a world event has made a neighboring region more interesting;
- the hero’s personality pushes them to take a risk or, conversely, seek a safer path.

The hero may then naturally decide to travel to another city or temporarily deviate from the usual route.

### 10.3. Events Should Disrupt Routine, Not Destroy It

Unusual events should not happen every minute.

If every expedition contains unique drama, events stop feeling special and the required amount of handcrafted content becomes unmanageable.

Most of the time, the hero lives an ordinary adventurer’s life.

Occasionally, an event happens that:

- changes the current objective;
- creates a new opportunity;
- forces a route change;
- affects personality;
- creates or changes an attitude toward someone;
- leaves a long-term consequence.

Core principle:

> **Simple routine creates the foundation of the hero’s life. Personality, world state, and events gradually make every life path different.**

> **Routine creates life. Decisions create personality. Events create history. The deity changes direction, but does not write the script.**

### 10.4. Criterion for New Systems

A new mechanic layered on top of the base loop should do at least one of two things:

1. noticeably diversify the hero’s ordinary life;
2. create consequences for the hero’s future fate.

If a system does neither, its value to the project is questionable.

---

## 11. Hero Decision-Making Model

The autonomous hero should make decisions logically enough to be understandable, but not identically every time.

For most recurring choices, the game uses one simple general structure:

> **hard filtering → base weights → modifiers → weighted random choice**

### 11.1. Hard Filtering of Unsuitable Options

First, the hero excludes options that are objectively unsuitable for the current situation.

For example, when choosing a quest, its approximate difficulty may be compared with the hero’s current power.

A quest that is far too weak or obviously far too dangerous may be removed before further comparison.

The exact acceptable-difficulty boundary is not defined yet and should be tuned through balance work.

It is important to distinguish between:

- **hard constraints**, after which an option is not considered at all;
- **soft preferences**, which merely change the probability of selection.

### 11.2. Base Weights

After filtering, the remaining reasonable options begin with roughly equal base weights.

If three suitable quests remain, the starting point might be something like:

> 33% / 33% / 33%.

There is no need to build a complex universal formula that always calculates the “most profitable” option.

The hero should retain room for different choices even in similar circumstances.

Small objective adjustments — for example, a preference for the quest whose difficulty best matches the hero — may be added later if testing proves they are necessary.

### 11.3. Choice Modifiers

After assigning base weights, factors reflecting the hero’s specific personality and situation modify them.

Possible modifiers include:

- personality traits;
- combat traits and fears;
- faction attitude / reputation;
- personal attitude toward specific NPCs;
- world events;
- temporary opportunities;
- the hero’s current condition;
- divine influence;
- other genuinely meaningful circumstances.

For example:

- fear of undead reduces the chance of choosing a cemetery expedition;
- greed increases the appeal of the most profitable job;
- good relations with a faction increase interest in its request;
- a divine sign increases the weight of the corresponding option.

Personality and traits should not rigidly dictate behavior.

> **A trait changes the probability of a decision; it does not turn that decision into a mandatory command.**

### 11.4. Final Choice

After modifiers are applied, weights are normalized into probabilities and the hero makes a random choice according to the resulting distribution.

For example, initial weights of:

> 33 / 33 / 33

might become something like:

> 60 / 20 / 20

after several factors are applied.

Exact modifier values, minimum probabilities, and influence limits are determined later through balancing.

An ordinarily valid option should generally not be pushed too easily to absolute 0% or 100% unless there is a genuinely hard reason.

### 11.5. One Model for Different Types of Decisions

Whenever possible, this structure should be used not only for quest selection but also for other decisions:

- choosing the next city;
- deciding whether to continue a dangerous adventure or retreat;
- participating in an event;
- reacting to an NPC proposal;
- choosing between several suitable actions;
- other autonomous hero decisions.

The specific filters and modifiers change depending on the decision type, but the overall architecture remains the same.

This keeps hero behavior understandable and avoids building a separate complicated AI system for every game action.

### 11.6. Long-Term Hero Goals

The hero should have **several long-term goals** that influence decisions over extended periods.

At the directional level, the current assumption is roughly **3–4 simultaneously possible long-term goals**, though the exact number will be defined in the hero AI document.

One of these goals may be **chosen by the player** — during hero creation or later.

While the player-selected goal is active, the player does not replace it with another one. Once it is completed, the player gains the opportunity to choose the next long-term goal.

The remaining goals may emerge from the hero’s own life through:

- personality;
- lived events;
- faction relations;
- acquired desires;
- the global state of the world;
- other meaningful circumstances.

This does not mean direct control over every action. Any long-term goal creates a persistent additional weight in the general decision system, but never becomes an order.

Possible goals include:

- save enough money for a desired item;
- reach a particular city;
- earn recognition from a faction;
- take revenge;
- become stronger;
- dedicate oneself to fighting the global threat.

Thus the player has **one long thread of direct guidance over the hero’s fate**, while the rest of the hero’s long-term motivation mostly emerges from the hero’s own life.

The exact goal structure, appearance, replacement, and completion rules will be designed later in the hero AI document.

---

## 12. Systemic Quest Generation

Ordinary quests are part of the hero’s base routine and should mostly be generated systemically rather than authored individually as separate scenarios.

### 12.1. Quests Depend on the City

Each city has its own quest-generation table.

Starting cities are deliberately suited to a beginning hero:

- weak and moderate quests dominate;
- dangerous quests are rare;
- the hero naturally receives appropriate early-game content.

Other cities may have broader difficulty distributions.

Quests should not automatically scale to the current level of the specific hero.

### 12.2. Probabilistic Difficulty Generation

New quests appear at intervals and are selected from a probability table.

Illustrative example for a normal city:

- 40% — easy quest;
- 40% — harder / medium quest;
- 15% — very hard quest;
- 5% — rare especially dangerous quest.

This is only an example of the principle. Exact percentages and power ranges are determined through balancing.

The rare top category does not have to mean a raid. It may be any especially difficult content appropriate to the current version of the game.

### 12.3. Offer Lifetime

Quests should not accumulate in a city forever.

A quest offer exists for a limited amount of time.

If the hero does not take it, it disappears after some time and is later replaced by new opportunities.

The overall concept **does not require a universal hard timer** for completing an already accepted quest.

Specific quest types may have a logical deadline if their content calls for one. Exact rules belong in the future quest-system document.

### 12.4. Quests Appear on the Map

A quest should have a geographic expression.

When a quest appears, its associated target is shown schematically on the map as, for example:

- a point;
- an area;
- a camp;
- a dungeon;
- a lair;
- an event location;
- another clearly understandable objective.

After the quest is completed, cancelled, or expires, the related point may:

- disappear;
- change state;
- remain as a permanent part of the world if that makes sense.

The quest list and the map should therefore feel like parts of one system.

### 12.5. Quests and World State

Global events do not replace the ordinary city quest pool. They add a **special event-driven layer** on top of it.

For example, a faction war may generate quests involving:

- helping a particular side;
- destroying an enemy camp;
- participating in a battle;
- defending territory;
- other military tasks.

The advance of demons, undead, or another global threat likewise creates related quests and points of interest.

This allows world state to directly alter the hero’s ordinary life loop.

### 12.6. Quests Should Encourage Travel

One purpose of the quest system is to prevent the hero from living forever beside one tavern.

Suitable quests should, on average, **appear more slowly than an active hero can complete them**.

As a result, the hero periodically encounters situations where:

- almost no suitable quests remain;
- the remaining quests are too weak;
- the remaining quests are too dangerous;
- new quests have not appeared yet.

This creates a natural reason to:

- wait;
- consider another activity;
- travel to a neighboring city;
- become interested in a rumor or event elsewhere on the map.

The hero travels not because the game artificially closes the old area, but because the current city temporarily stops providing enough suitable opportunities.

### 12.7. What Is Not Fixed Yet

At the concept stage, the following are not defined:

- the exact number of quests available at once;
- the exact generation interval;
- offer lifetime;
- exact percentages for difficulty categories;
- the full list of ordinary quest types;
- reward formulas;
- mandatory quest chains.

These parameters should be determined later through prototyping and balance work.

---
## 13. Systemic Content and Handcrafted Events

### 13.1. Ordinary Content Is Systemic

The main repeatable loop should not require a separately authored scenario for every class, city, and quest.

Ordinary:

- monster-hunting quests;
- travel;
- combat;
- purchases;
- rest;
- part of dungeon content;
- basic rewards

should be built from shared game systems and text templates.

This is necessary for a small indie team to build the game at a realistic scale.

### 13.2. Unique Events Are Handcrafted

Separately, the world contains rarer **authored events** written by hand.

These are the places where it makes sense to include:

- several possible developments;
- different ways to resolve the situation;
- class influence;
- personality influence;
- influence from reputation and the hero’s personal attitude toward participants;
- influence from world state;
- opportunities for divine intervention.

Not every event needs a unique branch for every class.

It is better to create several meaningful approaches when they genuinely fit the situation.

### 13.3. Event Frequency

Authored events should punctuate routine rather than completely replace it.

If an unusual event happens every two minutes, it stops feeling unusual and the required amount of handcrafted content becomes impossible to sustain.

---

## 14. Dungeons and Increased Risk — Preliminary

The dungeon concept **is not yet fully designed**.

At this stage, only the main distinction is fixed:

- ordinary farming allows the hero to recover relatively calmly between encounters;
- a dungeon is a riskier adventure with several fights in sequence;
- a boss and more valuable reward may wait at the end;
- inside a dungeon, the hero’s condition and limited resources matter more;
- the hero must decide independently when to continue and when to retreat;
- divine assistance may be especially valuable in such situations.

Exact rules for rest, recovery, number of fights, consumables, dungeon structure, loot, and bosses **are not yet approved**.

### 14.1. The “Continue or Retreat” Decision

The hero should evaluate risk in two stages.

First, objective state:

- health;
- available healing and resources;
- injuries;
- difficulty of previous fights;
- rate of resource depletion;
- expected danger ahead;
- value and proximity of the goal;
- ability to retreat safely.

Then the decision is adjusted by:

- caution;
- courage;
- greed;
- stubbornness;
- revenge;
- desire to help;
- personal importance of the goal;
- divine influence.

Personality changes the **acceptable-risk threshold**, but must not disable common sense.

A cautious hero does not flee from every scratch.

An aggressive hero or berserker-like personality may push farther than others, but should not systematically kill themselves in obviously hopeless situations.

### 14.2. Different Personalities — Different Types of Risk

Characters do not have to be equally safe.

A cautious hero may survive more often but miss opportunities.

A risk-seeking hero may achieve rare successes more often, but sometimes pay for them.

> **Different personalities do not need to be equally safe — they need to be equally interesting.**

### 14.3. AI Balancing

Later, the risk system should ideally be validated through large batches of automated simulations with different hero types.

Track:

- retreat frequency;
- mortality;
- hero condition at the moment of retreat;
- percentage of successful expeditions;
- influence of different traits;
- absurd recurring behavior patterns.

The goal is not to equalize everyone, but to make decisions feel logically consistent with the hero’s personality.

---

## 15. Death and Resurrection

### 15.1. Core Principle

Hero death is not permadeath and does not destroy long-term progression.

> **Death means losing the current adventure, time, and part of temporary loot — not losing the hero.**

### 15.2. What Is Preserved

After resurrection, the hero keeps:

- level;
- class abilities;
- class;
- specializations;
- personality;
- personal tendencies;
- reputation and persistent personal relationships / inclinations;
- hero history;
- permanent / equipped gear.

### 15.3. What May Be Lost

The hero may lose:

- part of the trophies from the current expedition;
- part of carried gold;
- the active adventure or opportunity.

Exact percentages are not yet defined.

Returning to the death location to retrieve a corpse is not planned.

### 15.4. Resurrection Location

The hero returns to life at a safe location — a city, temple, or another appropriate place.

The hero does not resurrect directly where they died.

### 15.5. Natural Resurrection

If the player does nothing, the hero resurrects automatically after a certain amount of time.

While the hero is dead, the world continues to live **as long as the game is running**.

### 15.6. Instant Resurrection by the Deity

The deity can resurrect the hero immediately by spending divine energy.

The cost depends on how much time remains before natural resurrection:

- the more time remains, the higher the cost;
- as natural resurrection approaches, the cost decreases;
- a small minimum cost may exist.

Illustrative principle only:

- 2 hours remaining → around 20 energy;
- 1 hour remaining → around 10 energy.

These numbers are not a balance decision.

Instant resurrection should compete with other uses of divine power.

### 15.7. Age and Natural Aging

**The hero’s age is not displayed and is not a gameplay attribute.**

There is no system of natural aging, age-related penalties, or finite natural lifespan.

The hero **does not die of old age**.

Game time exists to support simulation, travel, quests, and world events, but does not have to correspond literally to countable years of human life.

This allows the player to observe the same character for a long time and build a prolonged story without regularly replacing the hero because of age.

### 15.8. Voluntary End of the Journey — Retirement

A positive ending exists, but the game should not forcibly end when the hero reaches a particular level or defeats a particular enemy.

The player may decide that the hero’s story has reached its conclusion and begin a special **retirement quest chain**.

The finale should summarize the hero’s entire lived life in the form of a short **biography / life summary**:

- who the hero started as;
- how powerful they became;
- what personality they developed;
- which notable traits they acquired;
- what equipment and wealth they accumulated;
- what relationships they built with factions;
- which major victories and defeats they experienced;
- what role they played in wars and global events;
- how their journey ended;
- **how the world remembers them — or whether it remembers them at all**.

Several final outcomes or endings may exist, determined by the hero’s actual biography rather than by choosing a ready-made final button labeled “A / B / C.”

The hero may retire as a great defender, a famous adventurer, a wealthy treasure-seeker, a veteran of war, or simply as someone who lived a worthy life without leaving a major mark on history.

The exact set of outcomes will be defined later and should be based on events that genuinely occurred during the playthrough.

Core principle:

> **A positive ending is a voluntary conclusion to the hero’s story and a look back at the life that was lived, not a mandatory checkpoint where the game forcibly stops.**

Until such a final chain is started, the playthrough may continue.

---

## 16. Equipment and Items

Equipment is one of the main sources of the hero’s permanent power, especially after approaching the soft cap.

Early on, level and attributes matter more, but during maturity, finding stronger and better-generated items becomes one of the main ways the hero continues to improve.

### 16.1. Basic Equipment Slots

At this stage, a standard set of slots is sufficient:

- helmet;
- shoulders;
- chest;
- pants;
- boots;
- weapon;
- jewelry.

The exact number of jewelry slots will be defined later.

Additional slots such as gloves, belt, and other equipment pieces should not be introduced without a clear need.

### 16.2. Item Level and Rarity

Every item has:

- **item level / base item power**;
- **rarity**.

Item level determines its base power budget.

Rarity affects:

- total available stat budget;
- number of possible affixes;
- quality of rolls;
- potential complexity and uniqueness of properties.

Exact rarity names and colors are not fixed yet, but the intended structure is a standard ladder from ordinary items to legendary or mythic items.

### 16.3. Power Budget

Each item receives a limited **power budget** determined primarily by its level and rarity.

That budget is distributed among the item’s stats.

For example, two items of the same level and rarity may have comparable total power but completely different stat distributions.

This creates large equipment variety without manually designing every individual item.

### 16.4. Random Affixes

Item properties are partially generated randomly in a Diablo-like manner.

However, unrestricted random generation is not used.

Each item type should have its own allowed affix pool.

For example:

- heavy armor more often receives defensive properties;
- bows favor physical, speed, and related parameters;
- magical weapons favor Intelligence, Mana, and magical effects;
- jewelry may have a broader pool of specialized properties.

Rare unusual combinations are allowed, but an item should not receive a nonsensical set of stats that completely contradicts its nature.

### 16.5. Item Source Matters More Than Hero Level

The level and power of dropped items should not automatically scale to the hero’s current level.

Loot power depends primarily on:

- the source of the item;
- danger of the activity;
- region;
- dungeon;
- boss;
- rarity of the event;
- other game conditions.

Weak early enemies should not start dropping endgame items simply because the hero has become stronger.

This is necessary so the hero genuinely outgrows old threats and seeks more difficult sources of loot.

### 16.6. Legendary and Mythic Items

At the late stage, high rarity should do more than provide larger ordinary stats.

Legendary or mythic items may receive:

- a unique affix;
- an unusual interaction with a class mechanic;
- a modification to an existing ability;
- an item-granted skill;
- another rare rule that noticeably changes how the item is used.

Such an item should feel like an important chapter in the development of a particular hero rather than merely an item with bigger numbers.

The exact format of unique effects will be designed much later.

### 16.7. Sets — Possible Late System

Equipment sets may be added as a separate late-game system.

A set can provide additional effects when several pieces are equipped.

However, a full set should not automatically become the only correct equipment choice.

Sets should compete with individually powerful legendary items and other combinations rather than eliminating choice.

This system is currently considered a possible direction for the late game and is not required by the base concept.

---
## 17. Faction Reputation

The hero’s relationship with each major faction is represented by a simple scale:

> **Hostility ← Neutrality → Friendship**

Each faction has its own separate reputation value.

### 17.1. How Reputation Increases

Reputation rises when the hero:

- completes quests for the faction;
- helps its representatives;
- participates in events on its side;
- defends its territories;
- assists it during war;
- performs other actions that are clearly beneficial to it.

### 17.2. How Reputation Decreases

Reputation falls when the hero:

- completes quests against the faction;
- participates in war on the side of its enemies;
- attacks its representatives;
- helps its enemies during special events;
- performs other clearly hostile actions.

Ordinary assistance to one faction **should not automatically damage relations with another**.

Negative reputation with the opposing side appears only when the action is genuinely directed against that faction — primarily during wars and special conflict events.

### 17.3. Threshold Consequences

At certain reputation values, additional opportunities become available or are restricted.

Positive reputation may provide:

- market discounts;
- access to additional services;
- access to special buildings or restricted parts of a city;
- new merchants;
- faction equipment;
- unique quests;
- special events;
- other benefits.

Negative reputation may cause:

- higher prices;
- fewer available services;
- closure of certain buildings and opportunities;
- loss of access to ordinary quests;
- hostile NPC attitudes;
- at extreme hostility, denial of access to the faction’s cities.

Exact thresholds and effects will be determined later through balancing.

### 17.4. Drift Back Toward Neutrality

If the hero does not interact with a faction for a long time, reputation gradually drifts toward neutral.

Strong friendship or deep hostility may decay more slowly than small deviations from neutrality.

The purpose of this mechanic is to prevent one old incidental action from defining faction relations forever, while also avoiding the rapid erasure of genuinely significant consequences.

### 17.5. Reputation and Hero Decisions

Reputation is one modifier in the general decision-making system.

For example:

- good relations with the dwarves slightly increase the likelihood of taking their quest;
- the hero is more willing to consider a friendly faction’s city as the next travel destination;
- hostility reduces the probability of interaction;
- at extreme hostility, some options are removed entirely by hard filtering.

Reputation should not dictate a decision by itself except when access to an option is objectively closed.

---

## 18. Map and World Structure

### 18.1. Overall Structure

The game takes place on **one continent**.

At the current stage, the concept assumes roughly **10 major cities**.

Small villages, farms, and other settlement types are not part of the base concept for now and should only be added later if a real gameplay need appears.

The world is **formally open from the beginning**.

Several cities are naturally better suited to a beginning hero because weaker threats and appropriate quests exist nearby.

There is no formal ban on traveling anywhere.

The main restriction comes from the hero’s own logic:

- are there suitable quests there;
- how dangerous are known threats;
- is there a meaningful reason to travel;
- is the hero strong enough;
- is there an event or another motive to go there.

A beginning hero therefore normally stays near starter cities not because the map is locked, but because traveling to fight threats that are obviously far stronger would make little sense.

### 18.2. Cities and Factions

Different cities belong to different major factions.

At the current concept level, the basic factions are:

- **Humans**;
- **Elves**;
- **Dwarves**.

The number of cities owned by each faction does not have to be equal.

For now, all cities are assumed to share the same basic set of functions.

For example, the hero should have access to the core elements of the adventure loop regardless of whether they arrive in a human, elven, or dwarven city.

As reputation with a faction increases, additional opportunities may later unlock:

- special quests;
- rare merchants;
- faction equipment;
- additional events;
- access to restricted places;
- deeper involvement in faction affairs.

Reputation should not block the base gameplay loop.

### 18.3. Named Faction Characters

Each major faction is expected to have roughly **2–4 persistent named NPCs**.

These are not fully simulated secondary heroes with the same depth of life simulation as the main character.

Their purpose is to act as visible world figures and as one source of a faction’s real strength.

Such NPCs:

- **begin as very powerful characters in the world**;
- have fixed or relatively stable combat power;
- possess recognizable equipment that is permanent or changes only rarely;
- do not need to level up alongside the main hero;
- belong to a specific faction;
- stay in cities or move between locations connected to their faction;
- are visible on the map;
- influence the military strength or resilience of the city where they are located;
- participate in wars, sieges, and special events.

The main hero should not be able to simply walk into a city during normal circumstances and “farm” such a character.

A named NPC becomes genuinely vulnerable primarily during **major special events** — for example, a city siege, decisive battle, or another situation where the faction’s normal protection has broken down.

Even then, defeat of a named NPC **does not have to mean death**.

Preferred direction:

> while the faction still has other stronghold cities, an important character may lose a battle, lose part of their resources or trophies, and retreat to another city.

Permanent death may be tied to a truly critical stage — such as the fall of the faction’s final stronghold — but this is not yet fixed as a hard rule.

Named NPCs should therefore be durable figures in the history of the world, with their deaths being rare historical events rather than ordinary results of random combat.

What trophies may be lost on defeat, when an NPC retreats, when they can die permanently, and whether successors are needed are questions for the future `world_simulation.md` document and later balancing.

### 18.4. NPC Adventurers — Possible Additional Layer

In the future, the game may add a small number — roughly a dozen as a working scale — of autonomous NPC adventurers that resemble the main hero.

They may:

- gain levels;
- gradually become stronger;
- occasionally replace equipment;
- travel;
- participate in some events;
- potentially join the hero for raids or difficult group content.

Their lives should be simulated **far more simply** than the main hero’s life.

This system belongs to **optional late-stage content**, at roughly the same priority level as raids and fully assembled groups. It is not part of the mandatory core of the first version.

It should only be added if:

- the core gameplay loop already works;
- these characters regularly create visible encounters, competition, shared events, or group content for the player;
- performance and simulation complexity allow them to exist without harming the main game.

If their lives barely intersect with the main hero’s story, the simulation cost is not justified.

### 18.5. The Map as One of the Main Visual Elements

The map is one of the few large graphical elements in a predominantly text-driven game.

It should be **schematic, readable, and functional** rather than trying to depict the continent with maximum geographic detail.

The map displays:

- the continent outline;
- cities;
- major territories;
- points of interest;
- the hero’s position;
- travel direction or route;
- faction influence;
- territorial borders.

The map becomes especially important during:

- faction wars;
- border changes;
- major invasions;
- the appearance of global threats such as demons or undead;
- other events that alter the world’s political or military situation.

The map should allow the player to **see the world changing**, not merely read about it in text.

### 18.6. Points of Interest

Gameplay points of interest exist around cities and across the continent.

They do not all need to remain on the map permanently.

Provisionally, points of interest are divided into three types.

#### Permanent

Locations that are stable parts of the world’s geography.

For example:

- major ruins;
- a known cave;
- a mountain pass;
- another significant permanent location.

#### Exhaustible

Locations that exist until a related task is completed or their state changes.

For example:

- a bandit camp;
- a monster lair;
- a specific quest location;
- a dungeon that can be cleared.

After its condition is fulfilled, such a location may:

- disappear;
- enter another state;
- later be replaced by a new threat or event.

#### Temporary

Locations created by world events and present for a limited time.

For example:

- a temporary camp;
- a rare monster;
- a caravan;
- an invasion;
- a military clash;
- a special opportunity;
- a temporary portal or another anomaly.

These locations help diversify the hero’s familiar loop without constantly rewriting the underlying geography.

### 18.7. Hidden World Grid

For internal simulation, the map may be divided into conceptual **cells / squares**.

The grid itself does not have to be shown to the player.

A cell may store information such as:

- controlling faction;
- influence of neighboring factions;
- terrain type;
- current danger;
- active events;
- global-threat presence.

This should serve as a technical foundation for world-event generation, not become a separate complex strategy game.

### 18.8. Faction Borders and Wars

When the influence of two hostile factions touches, the corresponding territory becomes a potential conflict zone.

Such cells may generate more frequent:

- skirmishes;
- major battles;
- military camps;
- patrols;
- temporary quests;
- other war-related events.

A nearby hero may have an opportunity to take part.

Personality, faction relations, current task, hero strength, and other circumstances determine whether that opportunity is attractive.

War therefore changes the hero’s ordinary life **through the map and the situations that appear on it**, rather than existing only as background text.

### 18.9. Global Threat and the Late World Stage

The world contains a major hostile power outside the ordinary factions — for example, demons, undead, or another form of global evil.

It should not begin an active offensive immediately after a new game starts.

Provisionally, its development passes through several stages:

1. **Dormant phase** — the threat exists in its own part of the map and barely interferes with the rest of the continent;
2. **Awakening** — first signs of activity appear: isolated enemies, rumors, temporary events, and local threats;
3. **Offensive** — the force begins expanding influence, taking territory, and threatening cities;
4. **Late war** — the global threat becomes one of the largest forces shaping life across the entire continent.

Transitions between phases depend primarily on game time and world state rather than the hero’s level.

Exact timing and awakening conditions are not fixed yet.

### 18.10. The Global Threat Is Not a Mandatory Main Quest

The hero does not automatically become the savior of the world.

They may:

- actively fight the global threat;
- defend a specific faction or city;
- participate only in selected related events;
- ignore the war and continue their own life;
- move to a safer part of the map;
- exploit the chaos for personal benefit;
- in rare cases, with the right life history, even side with the global evil.

The last option should not be a simple initial button saying “choose evil faction.”

Such a path should emerge from personality, reputation, events, and the hero’s lived biography.

Core principle:

> **The global threat is not a story waiting for the hero. It is the largest event in the world, and it may become the main story of the hero’s life.**

### 18.11. The World Resists Without the Hero

Ordinary factions should autonomously resist both the global threat and one another **while the simulation is running**.

The hero’s absence does not mean the world automatically loses.

At the same time, the global threat should be strong enough to gradually reshape the map and create real pressure.

Provisionally, it may be stronger than a single ordinary faction in a local confrontation, but it should not be guaranteed to destroy the entire world without hero intervention.

Cooperation between several factions, favorable borders, internal events, and other factors may slow or stop the advance.

The exact faction-conflict model is not defined yet.

The balance to preserve is:

> **the simulation should be deep enough to generate wars, fronts, and events on its own, but not so deep that it turns into a separate strategy game.**

### 18.12. How Global War Affects the Hero’s Life

A change in territorial control must do more than change a map color.

War can affect:

- available quests;
- enemy types;
- appearance and disappearance of points of interest;
- road safety;
- sieges;
- temporary camps and battles;
- trading opportunities;
- faction relations;
- city conditions;
- the hero’s usual routes.

The global simulation only has value if its consequences are visible in the hero’s everyday life.

### 18.13. Complete Defeat of the World

The global evil capturing part of the continent is not an automatic Game Over.

The hero continues living in a changed world as long as safe cities, factions, and resurrection opportunities still exist.

However, at a very late stage of a playthrough, the global threat may completely conquer the continent.

If:

- all safe cities are destroyed or captured;
- there is no longer any location where the hero can resurrect;
- the hero finally dies together with the remaining resistance,

this may become a **natural end of the playthrough**.

Such an outcome should be a rare late result of world development, not an ordinary punishment for the player temporarily paying no attention.

### 18.14. Partial World Generation for a New Game

Ideally, a new game should slightly vary the continent so different heroes are born not only with different biographies but also into somewhat different world conditions.

There is no need to generate geography entirely procedurally from scratch.

The preferred direction is **semi-procedural generation**.

The game can pre-author:

- the continent shape;
- valid city positions;
- major natural regions;
- possible roads and connections;
- allowed positions for permanent points of interest.

Then, when a new game begins, partially randomize:

- placement or selection of cities among valid positions;
- faction ownership of cities;
- initial influence borders;
- some permanent and exhaustible points of interest;
- starting threats;
- the initial political situation.

Generation must respect logical constraints.

For example, a dwarven city may require suitable mountainous terrain rather than appearing in a random location merely for variety.

Core principle:

> **Do not generate an entirely new world from nothing; assemble predefined elements differently within understandable rules.**

This direction is desirable, but its technical scope and final implementation will be evaluated later.

### 18.15. Enemies Do Not Directly Scale to the Hero

Ordinary enemies should not automatically gain stats merely because the hero became stronger.

The hero should be able to genuinely outgrow early enemies.

At the same time, the open world after the soft cap may be balanced around a broad overall range of power expected from a formed hero.

Different territories vary by:

- enemy types;
- their mechanics;
- threat composition;
- events;
- factions;
- density of powerful and elite enemies;
- local bosses.

World state may temporarily create more dangerous threats in any region.

### 18.16. Enemy Power Instead of Level

Enemies do not necessarily need a visible level.

Their danger is evaluated through a calculated **Power** value.

Power is not a separate stat that itself buffs an enemy. It is an assessment derived from the enemy’s real combat properties.

It may include:

- health;
- damage;
- speed;
- defense;
- abilities;
- healing;
- poison and other harmful effects;
- other significant combat properties.

For example, two enemies without any “level” may have different calculated Power simply because one is objectively more dangerous.

A similar rating may be calculated for the hero’s current state.

This allows AI to make a first-pass risk assessment:

> hero is clearly stronger than the enemy;  
> powers are roughly equal;  
> enemy is significantly more dangerous than the hero.

Power should not guarantee the outcome of a fight.

On top of it, the system also considers:

- class;
- equipment;
- combat traits;
- specific enemy mechanics;
- current health and consumables;
- the hero’s previous experience;
- personality and willingness to take risks.

Thus Power helps estimate danger without turning combat into a simple comparison of two numbers.

The hero and the world should constantly affect one another.

At the same time, one important restriction applies:

> **Do not simulate what the player cannot see or feel.**

Simulation complexity has no value by itself.

---
## 19. Main Screen, Time, and Usage Pattern

### 19.1. Main Screen

The main screen should continuously show four core parts of the game.

#### 1. Journal and Quest Log — Primary Element

This is the central and most important area of the interface.

Through it, the player reads the hero’s life:

- what the hero has been doing;
- which quest is being carried out;
- where the hero traveled;
- who they fought;
- what they found;
- which decisions they made;
- how their personality changed;
- what important events happened in the world.

The journal should allow the player to quickly recover context after not looking at the game for a while.

Especially important events — a new level, a new trait, a rare item, death, changing cities, a major victory, an unusual event — should be visually distinguished from ordinary routine.

#### 2. Hero Portrait and Equipment

The main screen always shows the hero and their current equipment.

This is one of the primary ways to visually feel character development in a predominantly text-driven game.

The player should notice the hero changing weapons, armor, and overall appearance over time.

#### 3. Mini-Map

The main screen shows a reduced version of the full map.

The mini-map should quickly answer:

- where the hero is now;
- where they are heading;
- what is nearby;
- which city or region the current situation belongs to.

The full map opens in a separate window.

#### 4. Deity Panel

A separate persistent area shows the player’s available divine abilities and the deity’s primary resource.

The player uses it for occasional intervention:

- gently guiding the hero;
- healing;
- empowerment;
- other abilities to be defined later.

### 19.2. Additional Windows

The main screen also provides navigation to more detailed parts of the game.

Separate windows may open for:

- detailed hero screen;
- attributes and traits;
- equipment;
- full map;
- expanded journal;
- factions and reputation;
- other systems as needed.

The main screen should not attempt to display the full depth of the game at once.

### 19.3. Game Time

The world runs in **continuous accelerated game time**.

The internal simulation advances noticeably faster than real time.

A rough prototype-oriented scale might be:

> roughly one conceptual in-game day over several real-world minutes.

This **does not mean** the game must show the player a calendar, day number, day/night cycle, or countable years.

How time is represented visibly will be determined during prototyping. The player may not need to know how many literal “years” have passed in the world at all.

The correct pace cannot be reliably determined on paper because it must simultaneously:

- allow the hero to noticeably live and develop in the background;
- avoid producing too many events in too little time;
- give the player enough time to understand what is happening;
- make periodic check-ins interesting.

### 19.4. The Player Does Not Control Time Speed

Manual modes such as:

- ×2;
- ×4;
- ×10

are **not planned** at the current concept level.

The player should not constantly optimize simulation speed.

The pace of world life is set by the game itself.

### 19.5. Slowdown During Combat

During battles, the overall flow of the game may automatically slow down.

This is needed so that:

- combat remains readable;
- the player has time to notice important events;
- when actively watching, the player has time for occasional divine intervention.

The exact relationship between normal-life speed and combat speed will be determined through prototyping.

### 19.6. The Game Runs Only While the Application Is Running

Hero and world autonomy operate **only while the application itself is running**.

While the game is running, the world does not wait for the hero or for active player attention: factions fight wars, events happen, the global threat develops, and the hero continues living regardless of whether the game window is currently open or minimized.

If the application is fully closed:

> **the hero and the world are paused.**

When the game is launched again, no missed offline life is simulated.

There is no hidden:

- completion of dozens of quests;
- level growth;
- equipment replacement;
- movement of wars;
- advance of the global threat.

This is a deliberate decision.

The core appeal is observing the hero’s story rather than receiving a finished numerical result for time spent away from the application.

### 19.7. Background Operation

The game is designed to run for long periods in the background or while minimized.

Typical pattern:

> the player starts the game at the beginning of the day → the hero lives independently → the player periodically opens the window for a few minutes → reads what happened → checks the hero and world → optionally spends divine resources or gently influences a decision → leaves the hero to continue independently.

The simulation should therefore remain fully functional even when the player has not interacted with the interface for a long time.

At the same time, the hero should not require checking every few minutes in order to survive and progress normally.

---

## 20. What We Deliberately Do Not Want to Make

At the current stage, the concept should not turn into:

- an ordinary RPG with disguised direct control;
- an RTS;
- a standard idle clicker;
- offline progression that fast-forwards a significant part of the hero’s fate after the game has been fully closed;
- a requirement to manually speed up time just so ordinary hero life does not feel too slow;
- a detailed everyday-life simulator where the hero must eat, sleep, and service mundane needs for the sake of simulation itself;
- mandatory natural death from old age as a routine way to end the hero’s story;
- a game whose entire meaning is DPS and multiplier growth;
- a stat manager where the hero exists only to support numbers;
- a huge world simulation whose consequences the player cannot understand;
- global auto-scaling of every enemy to the hero’s level;
- an endless ladder of cities where each next city exists only to provide higher-level monsters;
- artificial travel restrictions simply because the hero has not “reached the required level”;
- global war as a separate complex strategy game requiring the player to manage armies, economy, and fronts;
- an MMO;
- a game that requires constant presence;
- a class system where classes differ only by weapon type and attack numbers;
- manual allocation of every attribute point by the player at every level-up;
- separate automatic progression for every weapon type merely to create extra numerical stats;
- loot-quality auto-scaling based on hero level regardless of the item source;
- legendary items that differ from common items only through bigger numbers;
- a system where every routine quest must be manually rewritten for every class;
- endless accumulation of old quests in a city;
- ordinary quest generation that constantly scales difficulty strictly to the current hero;
- personality as a set of unambiguously good and bad bonuses;
- a system where one personality trait rigidly dictates a specific choice instead of modifying probability;
- permanent negative combat traits that the hero cannot naturally overcome;
- a Darkest Dungeon-style stress mechanic as a mandatory layer of the hero’s personality.

---

## 21. Balance Between Autonomy and Player Influence

Complete hero autonomy **is not a problem by itself**. On the contrary, the hero must be able to live and develop without the player.

A problem appears only in two cases.

### If Influence Turns into Direct Control

The player effectively begins issuing ordinary RPG commands through an extra interface, and the hero’s independence disappears.

### If Influence Has No Noticeable Consequences

The player may feel that their presence changes nothing at all.

The desired balance is therefore not a “half-autonomous” hero, but this relationship:

> **the hero is fully viable on their own; the player can meaningfully, but not obligatorily, change the direction and success of particular parts of the hero’s journey.**

The player should be a useful patron, not the hero’s operator and not mandatory maintenance staff.

---
## Narrative Style and Text Presentation

Text is one of the game’s core components.

Because a large part of the hero’s life is experienced through the journal, chronicle, and logs, narrative should not be a decorative addition to the simulation. It should be one of the primary ways systemic events are transformed into an **interesting story**.

### General Principle

All primary narrative presentation is written **in the third person**.

The game does not pretend that the hero is constantly writing a personal diary.

Instead, it uses one consistent external narrator who:

- describes the hero’s actions;
- connects separate events into coherent episodes;
- notices characteristic habits and recurring situations;
- may use dry irony or an occasional sarcastic remark;
- while still treating the world, danger, and the hero’s fate seriously.

Primary tonal guideline:

> **an adventure chronicle with a lively authorial voice, dry irony, and occasional sarcasm, without turning the world into parody or satire.**

### What the Style Must Not Become

The narrative should not turn into:

- constant comedy;
- satire of RPGs and fantasy;
- a stream of memes;
- fourth-wall breaking;
- modern internet slang unless it belongs naturally to the interface;
- deliberately absurd humor for its own sake;
- a joke in every other line;
- mockery of the hero;
- trivialization of serious events.

Irony exists to make the writing livelier, not to make everything that happens feel unserious.

### Seriousness Depends on the Event

The more significant and tragic an event is, the less humor should be used.

Everyday adventuring situations allow more irony:

> For the third time that week, Alric agreed to clear the same forest of wolves. The local guard had apparently concluded that wolves were exclusively Alric’s problem.

Major events should be described much more soberly:

> By evening, the gates of Dornholm had been lost. The remaining defenders withdrew to the inner walls, while General Torvin left the city with what remained of the garrison.

The fall of a city, the death of an important character, a major defeat, a rare victory, or the ending of the hero’s life should not be accompanied by a mandatory joke.

### The Narrator Is Not a Separate Character

The narrator may have a recognizable voice, but should not:

- address the player directly;
- talk about themselves;
- argue with the hero;
- know that they exist inside a video game;
- turn into a commentator or show host.

The narrator’s presence should be felt through phrasing, rhythm, and choice of detail.

### Humor

Preferred humor is:

- observational;
- situational;
- dry;
- occasionally a little biting;
- based on repeated hero behavior, the oddity of a situation, or a mismatch between expectation and result.

Good example:

> The reward for clearing out the goblins looked modest. After a brief consideration, Edgar decided that twenty silver coins were still better than another evening in the tavern without twenty silver coins.

Undesirable example:

> Edgar totally wrecked the goblins and gained +20 awesomeness.

The second version turns the world into parody and contradicts the intended tone.

### The Hero’s Personality Should Be Visible in the Writing

The same systemic event does not have to be described identically every time.

The hero’s personality, past experience, combat traits, and persistent habits may affect:

- which details are emphasized;
- phrasing;
- degree of confidence;
- attitude toward risk;
- reaction to rewards;
- attitude toward specific enemies and factions.

The text still remains in the third person.

For example, a cautious hero:

> He set out for the bandit camp only after checking his supplies and buying another potion. His previous experience had been more than enough to stop treating preparation as a form of cowardice.

A risk-seeking hero in a similar situation:

> He remembered the supplies only after passing through the city gates. Going back for something so trivial seemed far more dangerous to his reputation than the bandits themselves.

This allows personality to become visible to the player through more than numerical decision modifiers.

---

### Four Layers of Text Presentation

The game uses several distinct textual layers. They serve different purposes and should not collapse into one endless stream.

#### 1. Detailed Action and Decision Log

The most granular layer.

Its primary purpose is **simulation transparency**.

If desired, the player should be able to understand:

- exactly what the hero did;
- which options were considered;
- why a particular option was chosen;
- what happened in combat;
- what was bought or sold;
- which attributes, traits, and circumstances affected the decision.

This layer may be drier and more systemic.

Example:

> 14:32 — The hero considered three available quests.  
> Troll hunt excluded: enemy Power is significantly above the acceptable risk threshold.  
> Wolf contract received increased weight: nearby objective, moderate danger, hero tendency toward caution.  
> Quest selected: “Pack on the Northern Road.”  
> Small healing potion purchased before departure.

The detailed log does not need to be beautiful literary prose. Its job is to expose the autonomous hero’s internal logic and allow the player to trust the simulation.

#### 2. Main Journal / Current Hero Chronicle

This is the **primary narrative layer** that the player regularly reads after returning to the game.

It gathers many individual actions over a period of time and turns them into a coherent, literary account.

A single entry may, for example, cover several hours of in-game life, though the exact period will be determined later.

Example:

> After a short deliberation, Edgar left the troll to someone more desperate and accepted a contract on the wolves along the northern road. Before leaving, he did buy a potion after all — his previous trip through those parts had noticeably improved his respect for preparation.  
>
> The pack turned out to be larger than promised, but by evening the job was finished. Edgar returned to the city tired, carrying several new scratches and a pair of boots that looked considerably better than the ones he had been wearing that morning.

This layer should:

- read like an adventure story;
- preserve cause and effect;
- emphasize what matters;
- avoid listing every micro-action;
- reveal the hero’s personality;
- allow the player to understand several meaningful hours of the hero’s life within a few minutes.

#### 3. Milestones of the Hero’s Life

A separate long-term chronicle.

Only events that genuinely matter to the biography belong here:

- significant levels and stages of development;
- acquisition or loss of important traits;
- rare items;
- the first victory over an especially dangerous kind of enemy;
- major defeats;
- deaths;
- important faction relationships;
- participation in major wars;
- fate-changing decisions;
- the fall or salvation of cities when the hero was connected to the event;
- completion of long-term goals;
- other unique achievements.

This chronicle serves as the memory of the entire playthrough.

It also becomes one of the main sources for the hero’s final biography when they retire.

Example:

> **Stage 42 of the Journey — The Fall of Dornholm**  
> Edgar took part in the defense of the city and survived the garrison’s defeat. After these events, his attitude toward the undead changed noticeably.

The exact form of numbering and time display will be defined later; the example demonstrates structure rather than requiring a literal calendar.

#### 4. World Chronicle

A separate stream of major events occurring independently of the hero.

It demonstrates that the world lives on its own.

This may include:

- wars;
- beginning and ending of sieges;
- border changes;
- loss or capture of cities;
- death or retreat of named NPCs;
- major world events;
- development of the global threat;
- rare disasters;
- other significant changes to world state.

Example:

> The human army began the siege of Liaris.  
> The Eastern Pass came under elven control.  
> General Torvin retreated from Dornholm.  
> The first confirmed undead detachments were sighted in the north.

The hero does not need to participate personally or even be nearby.

The world chronicle exists primarily for the player and helps show the wider context in which the hero’s life unfolds.

---

### Relationship Between the Layers

The same systemic fact may appear at different levels with different depth.

For example, the hero defeats a powerful necromancer:

**Detailed log:**

> Healing potion used.  
> Class ability activated.  
> Necromancer killed.  
> Rare staff obtained.

**Main journal:**

> The fight proved harder than Edgar expected. By the time the necromancer finally fell, almost nothing remained of his supplies except his confidence — and even that had been badly shaken.

**Life milestone:**

> Edgar defeated a necromancer significantly stronger than himself for the first time.

If this victory affected a larger event, it may also appear in the world chronicle.

The game therefore does not generate four independent stories.

It takes **the same real simulation events** and presents them at different levels of detail for different purposes.

### Primary Goal of the Narrative

The text should transform:

> `quest selected → battle → +1 level → new item`

into:

> **a piece of one specific hero’s biography.**

The player should remember not only numbers, but situations:

- where the hero went when they should not have;
- what they were afraid of;
- whom they unexpectedly defeated;
- which city they lost;
- when they first became genuinely powerful;
- which strange habit kept getting them into trouble;
- what, in the end, defined their life.

If the writing does not strengthen this feeling, it is not fulfilling its primary purpose.

---
## Example of a Typical Period of Autonomous Life

This is not a mandatory scenario, but an example of how several systems may work together.

> The player starts the game and leaves a Warrior hero to act independently.
>
> In the city, the hero reviews available jobs and chooses a contract against bandits. Before leaving, the hero independently buys an appropriate potion.
>
> On the way to the bandit camp, the hero encounters a small random fight, takes some damage, but continues the journey.
>
> The main quest ends in victory. The hero receives a reward and loot.
>
> On the return trip, a temporary event begins nearby as two factions go to war. Because of personality and current condition, the hero decides not to intervene.
>
> Back in the city, the hero turns in the quest, gains a level, and replaces one piece of equipment.
>
> Some real time later, the player returns to the game window.
>
> In the journal, the player can quickly see the main events: the completed quest, the new level, the equipment change, and the war event the hero chose not to join.
>
> The player assesses the situation, notices that some divine power has regenerated, and decides to gently nudge the hero toward dwarven territory.
>
> Then the player once again leaves the hero to live independently.

The main goal of this loop is:

> **the player returns not because the game demands a button press, but because they want to know what the hero has gotten up to and who the hero is gradually becoming.**

## Technical Foundation

### Target Platform and Format

The project’s primary target platform is **PC**.

The base format is a **standalone desktop application** that can be launched and left running in the background for long periods.

This matches the intended usage pattern:

> start the game → go about your day → periodically return to the window and read what happened to the hero.

A web version may be added later as an additional way to run the game, provided it does not require serious compromises in:

- background simulation;
- performance;
- save systems;
- interface;
- stability of long-running sessions.

The web version is not the primary platform and should not dictate key architectural decisions.

### Engine

The project’s primary engine is **Godot 4.x**.

A specific stable patch version will be chosen when development begins and may be updated later if necessary.

Reasons for the choice:

- the game is primarily 2D;
- much of the interface consists of text, panels, windows, lists, and a map;
- Godot is well suited to UI-heavy 2D projects;
- the project needs a continuously running simulation that can be separated cleanly from the visual layer;
- the project does not require the heavy 3D feature set of large commercial engines;
- the engine is free and does not create licensing constraints for the project;
- there is already practical experience with Godot from Dyna, which reduces development cost and new technical risk.

Choosing Godot does not mean the architecture of this project should copy Dyna.

The new game has a different load profile and a different architectural center.

### Main Architectural Principle

The simulation of the hero’s life and the world should be **logically separated from the visual interface**.

The interface displays the state of the simulation, but should not be the source of the simulation itself.

This is especially important because the game is designed for:

- long-running sessions;
- a minimized window;
- a relatively small number of visually active elements;
- continuous world progression without the need to constantly redraw a complex scene.

In the future, this separation should make it possible to:

- reduce background load;
- test the simulation separately from graphics;
- run large batches of simulated playthroughs for balancing;
- reproduce and analyze hero decisions;
- save and load world state independently of the interface.

The exact architecture, data structures, and technical approach to background operation will be defined in the technical design document and prototype.

---

## 22. Overall Concept Status

At the current stage, **there are no critical unanswered questions in the overall mechanical concept**.

The project’s main risk is no longer completeness of the concept, but **whether the actual player experience is interesting**.

The first prototype should primarily answer three questions:

1. After some time has passed, does the player want to open the game again and find out what happened to the hero?
2. Does hero progression feel like the story of a life rather than merely numbers increasing?
3. Does occasional player intervention create the feeling that the player genuinely changed the hero’s fate, even if only slightly?

If the hero is interesting on their own and player influence feels meaningful, the central idea works.

If the simulation functions correctly but the player still does not want to return to the hero, this cannot be fixed through number balancing alone — the presentation of the story, the event structure, or the role of the deity will need to be reconsidered.

The document still contains intentionally undefined details and late hypotheses, but none of them prevent moving on to separate design documents and prototyping.

The following are defined:

- the game’s central fantasy;
- hero autonomy;
- the role of the player and deity;
- the player’s base loop;
- the hero’s base life loop;
- the decision-making model;
- overall progression;
- classes at the basic conceptual level;
- personality and combat traits;
- automatic combat;
- quest system;
- equipment and loot;
- death and resurrection;
- absence of age mechanics and death from old age;
- a voluntary positive ending through retirement and a final biography;
- factions and reputation;
- the map;
- the global threat;
- very powerful named faction NPCs and the principle that they become vulnerable mainly during major events;
- NPC adventurers as an optional late layer;
- accelerated internal game time without a mandatory visible calendar;
- passive regeneration of the divine-intervention resource;
- the main screen;
- four-layer text presentation: detailed log, main journal, hero milestones, and world chronicle;
- third-person literary narration with dry irony but without satire;
- long-running background operation;
- no offline progression after the application is fully closed;
- long-term hero goals, including one active direction slot controlled by the player;
- classic high fantasy as the genre-level world direction;
- Godot 4.x as the primary engine and the principle of separating simulation from interface;
- PC standalone as the main target platform, with a possible additional web version.

The following are **not** considered unanswered questions of the overall concept:

- exact formulas and coefficients;
- specific class abilities;
- the complete set of personality scales and combat traits;
- exact quest templates and timers;
- time-speed balance;
- exact rules for death, retreat, and succession of named NPCs;
- exact faction-war mathematics;
- affixes, prices, and item-evaluation logic;
- exact deity abilities and deity progression;
- optional late systems such as sets, parties, raids, and NPC adventurers;
- final art style.

Further questions now belong to **individual systems**, not the overall concept.

The next stage of design should use separate thematic documents, for example:

- `hero_progression.md` — attributes, levels, class abilities, soft cap;
- `character_ai.md` — personality, traits, goals, and decision-making;
- `combat.md` — secondary stats, formulas, and abilities;
- `quests.md` — generation, types, difficulty, and rewards;
- `items.md` — affixes, rarities, market logic, and item evaluation;
- `world_simulation.md` — factions, wars, cities, the global threat, and named NPCs;
- `ui_flow.md` — main screen, map, and detailed windows;
- `narrative_design.md` — text templates, tone, journal, logs, milestones, and world chronicle;
- `divine_system.md` — deity progression and concrete methods of influence;
- `technical_design.md` — simulation architecture, saves, background modes, and Godot integration.

These documents do not need to be created all at once.

They should be developed as the corresponding systems move into prototyping.

---

## 23. Rule for Evaluating New Ideas

When discussing any new mechanic, check:

- does it make the hero’s development or fate more interesting to observe;
- does it diversify the hero’s base loop or create noticeable consequences for the future path;
- does it help the player feel how much the hero has changed and grown stronger;
- does it strengthen the central fantasy;
- if the mechanic involves the player, does it create meaningful influence rather than mandatory micromanagement;
- does it preserve hero autonomy;
- will the player actually notice it;
- how much does it cost to develop;
- how much unique content does it require;
- can the same result be achieved with a simpler system;
- does it create a need for constant micromanagement;
- does it force a small indie team to manually produce a volume of content closer to a large studio.

Weak ideas should be removed regardless of who proposed them.
