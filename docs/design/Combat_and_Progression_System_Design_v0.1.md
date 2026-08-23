# The Hero’s Story — Combat & Progression System Design

**Status:** Draft  
**Document version:** 0.1 skeleton

## Purpose

This document defines how the hero becomes stronger and how autonomous combat converts stats, equipment, skills, and experience into understandable outcomes.

## This document covers

- combat model and timing;
- combat stats;
- shared Power concept for hero and enemies;
- damage, attack speed, critical hits, defense, and related combat parameters;
- XP and level progression;
- attribute growth;
- skills and class progression;
- combat-related traits;
- death consequences that originate from combat;
- interfaces through which equipment and temporary effects modify final combat stats.

## This document does not cover

- hero biography and general identity — see `Hero_System_Design_v0.1.md`;
- personality-based choice logic — see `Personality_and_Decision_System_Design_v0.1.md`;
- item generation and equipment ownership — see `Economy_Equipment_and_Loot_System_Design_v0.1.md`;
- quest selection/content — see `Quest_and_Activity_System_Design_v0.1.md`.

## Core boundary

Hero and enemy strength must remain comparable through one shared combat-stat and Power model. Equipment and temporary effects feed combat through resolved stats rather than special-case combat logic.

## Overall Hero Level

The hero has one overall level that represents their long-term development as an adventurer.

By gaining experience, the hero increases this level and gradually becomes stronger. Level serves as one of the main axes of vertical character progression.

The exact sources of experience and the rewards granted by each level will be defined separately.

The game does not use a separate TES-like progression system for every weapon type simply through repeated use — for example, separate Sword, Axe, or Bow levels that rise only because the hero frequently uses that weapon.

> **Hero development should create meaningful differences rather than accumulate dozens of secondary progression tracks.**

## Attribute Growth on Level-Up

The player does not manually distribute all of the hero’s attributes after every level-up.

Attribute growth is shared between three influences:

1. **class** — guarantees part of the growth toward the class’s core attribute or attributes;
2. **deity guidance** — allows the player to softly encourage one development direction;
3. **the hero** — most growth is distributed autonomously according to the hero’s own tendencies and development logic.

A current illustrative working model is:

> **5 attribute points per level: 1 from class + 1 from deity guidance + 3 distributed by the hero.**

These numbers are provisional design values, not final balance. The amount of growth and the proportions assigned to each source may change during development.

The hero’s autonomous share should not be random. It may be influenced by biography, personality, preferences, lifestyle, and meaningful accumulated experience.

Divine guidance should influence development without becoming ordinary manual point allocation by the player.

> **The hero develops themselves; the player can only help shape the direction.**

The exact attributes, weighting rules, and strength of each influence will be defined separately.

## Hero Growth Must Be Understandable

Although attribute growth is allocated automatically, the result should not feel random to the player.

When the hero levels up, the player should be able to understand:

- which attributes increased;
- which part of the growth came from class;
- which direction was encouraged by deity guidance;
- which tendencies, preferences, or experiences influenced the hero’s autonomous share.

The exact way this information is presented will be defined separately.

> **The player does not directly control the hero’s development, but should understand why the hero is developing in that direction.**

## Base Attributes and Resources

At the current design stage, the hero has **five primary developable attributes**:

- **Strength (STR)**;
- **Dexterity (DEX)**;
- **Intelligence (INT)**;
- **Constitution (CON)**;
- **Wisdom (WIS)**.

Primary attributes are long-term characteristics of the hero. They contribute to secondary combat stats and may also be used by appropriate non-combat events, checks, and outcomes when the nature of the situation makes that attribute relevant.

### Provisional Primary Attribute Contributions

The current working contribution of **each single point** of a primary attribute is:

| Primary attribute | Current provisional contribution per point |
| --- | --- |
| **Strength (STR)** | +2 physical Damage; +5% Critical Damage |
| **Dexterity (DEX)** | +10 Accuracy; +5 Dodge; +3% Critical Chance |
| **Intelligence (INT)** | +2 magical Damage; +20 Mana |
| **Constitution (CON)** | +20 maximum Health; +2 Armor |
| **Wisdom (WIS)** | +1 Skill Level |

These values are **provisional balance values**, intended to establish the role of each primary attribute before final formulas and stat ranges are known. They may be adjusted substantially during balance work. Dodge in particular does not yet have a final conversion formula, so its current numerical contribution should not be treated as final.

Primary attributes may also influence appropriate event checks and outcomes independently of these combat contributions.

Separate from those attributes are hero resources:

- **HP / Health**;
- **Stamina** — currently considered as a resource for travel and other actions outside combat;
- **class resource** — for example Mana, Rage, or another class-specific mechanic.

These resources do not have to be distributed like normal attributes. Their values may depend on level, class, primary attributes, equipment, abilities, or other systems.

## Secondary Combat Stats

The current secondary combat-stat set is deliberately compact and is divided into defensive and offensive stats.

### Defensive stats

- **Health** — determines how much damage the combatant can survive before being defeated;
- **Armor** — reduces incoming physical damage;
- **Dodge** — allows an incoming attack to be avoided entirely;
- **Fire Resistance** — reduces incoming fire damage;
- **Cold Resistance** — reduces incoming cold damage;
- **Lightning Resistance** — reduces incoming lightning damage;
- **Block** — represents the combatant’s ability to block an incoming attack when the current equipment or combat setup allows blocking.

Health remains a hero combat resource, but bonuses to maximum Health are also treated as part of the defensive combat-stat layer when resolving equipment and other stat sources.

The three elemental resistances use the same diminishing-return model as Armor:

`Final Damage = Raw Damage × 100 / (100 + Resistance)`

Resistance values cannot be negative. Damage reduction from any single elemental resistance is capped at **75%**.

The exact Block formula and its interaction with different attack types will be defined separately.

### Offensive stats

- **Damage** — the base strength of attacks or damaging actions before relevant mitigation;
- **Accuracy** — determines the ability to successfully hit a target;
- **Critical Chance** — determines the chance that an eligible hit becomes a critical hit;
- **Critical Damage** — determines how much additional damage a critical hit deals;
- **Attack Speed** — affects the speed or frequency of weapon attacks;
- **Cast Speed** — affects the speed of spell casting and other actions explicitly treated as casts.

These stats may be derived from primary attributes, class, equipment, abilities, temporary effects, and other valid sources.

The current list is the working base set. Additional secondary stats should be introduced only when they create a clear gameplay purpose rather than unnecessary complexity.

## Sources of Permanent Hero Power

The hero’s permanent combat strength comes from several main sources:

1. **level and attributes**;
2. **class, abilities, and their development**;
3. **equipment**;
4. **specialization and acquired combat traits**.

The relative importance of these sources may change over the course of the hero’s development. Early on, level and basic attributes may matter more, while later equipment, abilities, specialization, and individual traits may become increasingly important.

Temporary effects, consumable items, and divine assistance may strongly influence a particular fight, but they are not considered part of the hero’s permanent power.

> **The hero’s strength should reflect more than a single level number; it should reflect the path of their development.**

The exact contribution of each source may change during development and balance work.

## Two Stages of Hero Development

Hero progression is provisionally divided into two broad stages. These are not two rigid game modes and there is no moment when the “real world” suddenly unlocks. The world exists from the beginning, while the transition between stages happens gradually as the hero develops.

### Stage 1 — Formation

Early in the game, level and basic attributes are among the hero’s main sources of power.

During this period, the hero:

- gains levels relatively quickly;
- noticeably increases primary attributes;
- gradually reveals personality and preferences;
- gains and changes traits;
- learns the core abilities of the class;
- may later reach a specialization;
- uses equipment, although equipment is not yet the primary source of progression.

From the beginning, the world contains areas that are naturally appropriate for a young hero: safer cities, surroundings, and available activities. These are not isolated “starting zones.”

The hero is formally able to travel anywhere, but when choosing a direction they consider their own strength, known threats, available activities, possible rewards, and whether the journey makes sense.

A weak hero therefore usually prefers places where they can reasonably survive and find suitable things to do.

Enemies should not automatically scale with the hero. As the hero becomes stronger, they should genuinely outgrow former threats.

### Stage 2 — Maturity

Once the hero is largely formed and approaches the soft cap of development, ordinary levels gradually become less significant.

Level and attributes may continue to grow, but more slowly and should no longer be the primary source of increasing power.

The world does not unlock again at this point — the hero simply becomes strong and experienced enough that opportunities that were previously too dangerous become practically relevant.

During maturity, greater importance may shift toward equipment, rare items, abilities, specialization, combat traits, preparation for specific threats, and the hero’s participation in more serious world events.

> **Early on, the hero is primarily becoming stronger. Later, what matters increasingly is who the hero has become, what they possess, and what kind of world they live in.**

The exact pace and boundary between these stages are provisional and may change during development.

## Soft Cap

The hero has a **soft cap** after which ordinary vertical progression gradually slows down without stopping completely.

After reaching this stage, the hero may still gain levels, increase attributes, and continue developing class abilities, but each additional increase becomes less significant.

The purpose of the soft cap is not to stop hero development. It is to gradually shift the main source of interest away from simple level and attribute growth toward equipment, abilities, specialization, the hero’s individual characteristics, and participation in the living world.

The early stage should not feel like a long tutorial before the “real game.” World events and larger processes exist from the beginning; a young hero simply has far less ability to affect them.

The exact level or conditions for reaching the soft cap, as well as the pace of progression beyond it, will be defined separately and may change during development.

> **After the soft cap, the hero does not stop developing — what changes is which sources matter most for further growth.**

## Enemies Do Not Automatically Scale to the Hero

The combat strength of ordinary enemies should **not increase simply because the hero’s level or Power has increased**.

If the hero becomes much stronger than wolves, bandits, or other early threats, they should genuinely outgrow them. An old enemy should not silently become a much stronger version merely to preserve the same relative difficulty.

More dangerous combat should instead come from things such as:

- more dangerous regions;
- different enemy types;
- elite enemies and bosses;
- more demanding mechanics;
- world events;
- wars and invasions;
- temporary changes in local danger.

A familiar region may still become more dangerous when the **world itself changes** — for example because of an invasion or major event. That is different from secretly adjusting enemy stats to match the hero.

This principle is important to the feeling of progression: an enemy that once posed a serious threat may later become easy because the hero has genuinely grown beyond it.

> **Hero growth should change the hero’s place in the world, not force the entire world to grow invisibly alongside them.**

The distribution of enemy strength across regions and changing world conditions belongs to the world-map and world-simulation systems.

## Shared Power for Hero and Enemies

The hero and enemies use **one shared Power system** for estimating combat strength.

Power is not an independent stat that directly makes a combatant stronger. It is a summary estimate calculated from that combatant’s **resolved real combat stats**.

Conceptually, the flow is:

> **stat sources → resolved Combat Stats → shared Power calculation → Power**

The hero and ordinary enemies should pass through the same principle of calculation so their strength remains comparable on one scale.

Power is primarily useful for quick relative danger assessment, such as determining whether:

- the hero is clearly stronger;
- the two sides are roughly comparable;
- the enemy is clearly stronger.

Power does **not guarantee the outcome of a fight** and does not replace combat simulation itself.

Two combatants with similar Power may perform differently against one another because of:

- specific abilities;
- class mechanics;
- enemy-specific mechanics;
- combat traits;
- current condition and remaining resources;
- other situational factors.

Stats from equipment, class, permanent progression, temporary effects, and other sources must feed into the resolved Combat Stats before Power is calculated. They should **not then be added again as separate Power bonuses** if their effect is already represented in those final stats.

The exact Power formula may change as the combat system develops, but the principle remains stable:

> **The hero and enemies should be measured with the same ruler, based on their real combat capabilities.**

## Class Must Change Combat Logic

Differences between classes should not be reduced only to weapons or slightly different damage numbers.

Warrior, Archer, Mage, and Rogue should fight differently and use different ways to solve combat situations.

A class should define:

- the hero’s primary tools in combat;
- characteristic abilities;
- a key combat mechanic;
- typical decisions and priorities during a fight.

Ideally, the combat log alone should make the hero’s class roughly recognizable even if the class name itself is hidden.

> **Class defines not only the hero’s power, but the logic of how they fight.**

The exact mechanics of each class will be designed separately.

## Basic Class Kit

Each base class should have its own distinctive combat mechanic and a small set of characteristic abilities.

The current working guideline is:

- **one primary unique class mechanic**;
- roughly **2–3 basic abilities** that the hero gains relatively early.

The unique mechanic does not have to be represented by a separate resource bar.

For example, a class mechanic may involve Mana for the Mage, Rage or combat momentum for the Warrior, distance and aiming for the Archer, or advantage and stealth for the Rogue.

A separate artificial resource should not be created for every class merely for the sake of symmetry.

The exact abilities, resources, and mechanics of each class will be defined separately and may change during development.

> **Each class should have its own combat logic, but this does not require artificially giving every class the same amount or type of complexity.**

## Automatic Ability Use

The player does not manually activate the hero’s combat abilities.

The hero decides autonomously when and which available ability to use.

The decision may be influenced by:

- the current combat situation;
- the hero’s health;
- available class resource;
- enemy strength and type;
- the hero’s own assessment of their chances of victory;
- personality and attitude toward risk;
- the need to conserve resources for the rest of the journey.

The hero should not use abilities merely in a mechanical rotation or immediately whenever a cooldown ends. Ability use should depend on the situation and the logic of that specific hero.

> **The class defines the tools available to the hero, while the hero’s state, experience, and personality influence how those tools are used.**

The exact ability-selection rules and weighting of these factors will be defined separately and may change during development.

## Hero Specialization

Later in the hero’s development, they may gain the opportunity to advance their base class through a specialization.

A specialization should continue the original archetype rather than abruptly turning the hero into a fundamentally different class. It may:

- grant roughly **1–2 new abilities**;
- modify or expand the class’s core mechanic;
- emphasize the individual path of that specific hero.

Unlike the starting class, the specialization is chosen primarily by **the hero**. The choice may be influenced by attributes, personality, preferences, and lived experience.

The player should be able to understand why the hero arrived at that specialization.

> **The player chooses who the hero is at the beginning of the journey. The hero largely determines who they become.**

The exact specialization system and whether the deity can softly influence this choice will be defined separately.

## Base Starting Classes

The current set of starting classes consists of four archetypes:

- **Warrior**;
- **Archer**;
- **Mage**;
- **Rogue**.

This set is sufficient as the game’s current base class structure. Exact abilities, resources, specializations, and complete class mechanics will be designed separately and may change during development.

When developing each class further, it should be checked against these questions:

1. How is its combat logic different?
2. What does it usually do at the beginning of a fight?
3. How does its behaviour change if the fight drags on?
4. What resource, state, or condition causes it to change tactics?
5. Can the class be recognized from the combat log without seeing its name?

> **Each class should feel like a distinct way of fighting, not a different set of numbers and a different weapon image.**

## Possible Group Content — Future Hypothesis

In the future, the game may consider difficult activities in which the main hero temporarily joins other autonomous NPC heroes.

These could include especially difficult dungeons, raids, or other events that are hard for one hero to handle alone.

Such content could potentially make class differences and combat roles more meaningful while also creating relationships, shared history, rivalry, or other connections between heroes.

However, a permanent party, control over other heroes, and group content are **not part of the confirmed core game** and must not be required for the basic gameplay loop.

> **The game must first work and remain interesting around one autonomous hero.**

This idea is not a commitment for early versions and may be revised or discarded entirely later.

## Base Combat Model

Combat is an important part of the hero’s journeys, but it is not the project’s primary gameplay core.

The main focus is hero development, decisions, personality, fate, and the world’s influence on the hero’s life. Combat creates risk, victories, defeats, progression, and events that can affect the hero’s later story.

Therefore, the base combat system should be:

- automatic;
- understandable;
- varied enough to distinguish classes and opponents;
- but not overloaded with micromanagement or excessive complexity.

### Combat Format

The base format is a **1v1 fight**.

The hero and opponent each have a speed value that affects how frequently they can act.

Combat does not have to follow a strict alternating sequence:

> hero → opponent → hero → opponent.

A faster participant receives opportunities to act more frequently.

The exact speed and action-frequency formulas will be defined separately. Speed should not create absurd situations where one participant takes a huge number of actions in a row without allowing the other side to respond.

### Auto-Attack

The hero’s default action is an **automatic normal attack**.

If there is no reason to use another action, the hero attacks the opponent normally without player input.

### Abilities

When appropriate, the hero may autonomously use a class ability instead of a normal attack.

Abilities may be limited by:

- cooldowns;
- class resources;
- situational requirements;
- a combination of several simple conditions.

There is no need to create an elaborate separate AI system for every individual ability.

The hero should use abilities in a way that is **reasonably logical and understandable**, but does not need to play with mathematically perfect optimization.

### Class Resources and Mechanics

Different classes may build their combat logic around different mechanics.

For example, the Mage may use Mana, the Warrior may build Rage or combat momentum, while other classes may use their own states or combat rules.

A separate resource bar is not required for every class.

### Item Use

The hero may autonomously use appropriate consumable items, such as healing potions.

An item should be used when the situation genuinely calls for it.

As a rule, using an item counts as a separate action and should not be added for free to a normal attack.

### Player Role in Combat

The player does not directly control the hero’s attacks or abilities.

The deity may provide only limited assistance, such as:

- healing the hero;
- temporarily empowering the hero;
- later, using other rare forms of intervention.

The hero should be capable of winning ordinary fights independently.

Player assistance primarily allows the player to:

- help the hero survive more fights without prolonged recovery;
- rescue the hero from an especially unlucky situation;
- help against a stronger opponent;
- improve the chance of success in an important or risky adventure.

Divine assistance should not be mandatory in every fight.

> **The player does not win the fight instead of the hero — they only occasionally help the hero exceed their ordinary limits.**

### Complexity Limit

At the base level, combat should not be overloaded with complicated formulas, dozens of effects, huge ability sets, or excessively detailed tactical AI.

The combat system should first prove that it is:

- easy to read;
- capable of genuinely differentiating classes;
- capable of creating risk;
- functional without player micromanagement;
- supportive of the larger game about the hero’s life and fate.

Additional depth should be added only when it genuinely makes the game more interesting.

## Combat Traits

Combat traits are separate from the hero’s general personality and emerge from combat experience.

They can reflect both positive and negative experience, such as growing confidence against certain threats or fear after severe defeats.

A combat trait should come from repeated or especially meaningful experience rather than appearing randomly after one ordinary fight.

Combat traits may strengthen, weaken, or disappear over time as the hero’s later experience changes.

> **Combat traits should become part of the hero’s story, not simply an ever-growing list of modifiers.**

The exact scale, categories, thresholds, and effects of combat traits will be defined separately.

## Combat Trait Persistence — Possible Later Extension

A combat trait reinforced for a long time may become more deeply rooted and require stronger opposite experience to weaken or remove.

This is a possible later extension, not a required part of the base system.

## Death Is a Defeat, Not the Loss of the Hero

Hero death is not permanent and does not erase long-term development.

After death, the hero may lose the current expedition, time, and part of temporarily acquired resources, but the hero themselves and their main story continue.

> **Death should be a meaningful defeat, but it should not erase a character the player may have been following for dozens of hours.**

## What Is Preserved After Death

Death should not roll back the hero who has already been formed.

After resurrection, the hero keeps:

- overall level and permanent progression;
- class, abilities, and specialization;
- personality, preferences, and permanent traits;
- reputation and persistent relationships;
- hero history and biography;
- equipped gear and other permanent equipment.

Death interrupts the **current adventure**, but does not erase who the hero has become.

> **The hero’s long-term story survives their defeats.**

## What May Be Lost After Death

Death should primarily punish the failure of the **current adventure** rather than take away accumulated long-term progress.

The hero may lose:

- loot and trophies that have not yet been safely delivered;
- the current quest or expedition;
- a temporary opportunity associated with that adventure;
- potentially part of carried gold, if later testing shows that this meaningfully improves risk and balance.

Equipped gear and other permanent equipment are not lost on death.

The hero is not expected to return to the death location to recover a corpse or retrieve lost items.

Exact loss amounts and rules will be determined later.

> **Death puts the current loot and adventure at risk, not the life the hero has already built.**

## Resurrection Location

After natural resurrection, the hero returns to life in a **safe location** rather than directly at the place where they died.

This may be:

- the nearest appropriate city;
- a temple;
- another logical safe location.

The exact return location may depend on where the death occurred and which safe points are available to the hero.

The design does not currently require a universal rule such as “always the nearest city” or “always a temple”; this should be defined together with the world map and travel systems.

> **Death ends the failed expedition and returns the hero to a safe part of their life.**

## Natural Resurrection

If the player does not intervene, the hero **returns to life automatically after a period of time**.

While the hero is dead:

- the hero’s own activity is paused;
- the world continues to live and change while the game is running;
- events and opportunities may pass without the hero’s participation.

The exact resurrection delay is a balance parameter and is not fixed at this stage.

> **Death temporarily removes the hero from the world, but does not pause the world itself.**

## Migration note

Prototype formulas are not automatically treated as final full-game balance.