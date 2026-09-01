# The Hero’s Story — Quest & Activity System Design

**Status:** Draft  
**Document version:** 0.1 skeleton

## Purpose

This document defines the activities that structure the hero’s adventuring life and how the hero discovers, evaluates, chooses, executes, completes, abandons, or fails them.

## This document covers

- quest availability;
- quest types;
- quest evaluation;
- autonomous quest selection;
- quest execution structure;
- rewards and failure;
- farming and non-quest adventuring activities;
- dungeons and other activity formats at a conceptual level when they become relevant;
- activity-related decision points;
- interactions with personality, world state, travel, combat, and divine guidance.

## This document does not cover

- detailed personality algorithms — see `Personality_and_Decision_System_Design_v0.1.md`;
- combat resolution — see `Combat_and_Progression_System_Design_v0.1.md`;
- map topology and travel rules — see `World_Map_and_Travel_System_Design_v0.1.md`;
- item/economy rules — see `Economy_Equipment_and_Loot_System_Design_v0.1.md`;
- diary presentation — see `Narrative_and_Diary_System_Design_v0.1.md`.

## Core Adventure Loop

Most of the hero’s ordinary adventuring life follows one stable RPG loop.

The current working structure is:

1. while in the city, the hero reviews the currently known quests and ordinary activities available there;
2. evaluates suitable quests using their current real combat strength and circumstances;
3. autonomously chooses one;
4. prepares if necessary;
5. sets out to complete it;
6. travels, encounters enemies, and fulfills the objective;
7. equipment and trophies found during the active quest are collected into the hero’s backpack rather than being equipped immediately during the adventure;
8. after the quest objective is completed, but before returning to the city, the hero reviews the collected equipment, compares it with currently equipped items, equips worthwhile upgrades, and recalculates resolved CombatStats and Power;
9. the hero returns to the city;
10. turns in the quest and receives its completion reward;
11. goes to the market;
12. sells all trophies and all equipment that was not equipped during the post-quest loot review; at the current design stage, the hero does not retain spare or situational equipment for later use;
13. evaluates whether anything in the current shop stock is worth buying and, if a purchase changes equipment, recalculates CombatStats and Power again;
14. makes a routine visit to the tavern, where they may hear rumours or other useful information about currently unknown dungeons, events, or opportunities in the surrounding world;
15. with updated equipment, stats, real power, and any newly learned information, evaluates the currently known quests and activities again;
16. the loop repeats.

The tavern-information step is part of the hero’s ordinary city routine, but it does not guarantee that new information appears on every visit. Exact rumour probabilities, discovery ranges, and map-reveal rules belong to `World_Map_and_Travel_System_Design_v0.1.md`.

The player should not have to manually service every step of this process.

> **This is the hero’s basic rhythm of adventuring life, and the hero should be able to sustain it autonomously.**

The systems responsible for travel, combat, equipment, economy, personality, world state, and divine influence may modify individual stages of this loop without taking ownership of the loop itself.

### Equipment Is Reviewed at a Natural Adventure Break

Ordinary equipment drops do not cause the hero to stop in the middle of an active quest and repeatedly change gear after every enemy.

During the quest, dropped equipment is collected. Once the objective has been completed, the hero has a natural decision point before the return journey: they review the new items, equip any worthwhile improvements, and continue with the resulting updated combat state.

This means the hero may already benefit from newly found equipment during the journey back to the city or in any incidental encounter after the quest objective, while avoiding constant mid-combat or mid-objective gear switching.

At the current design stage there is no routine policy of keeping alternative equipment sets or situational spare items. If a dropped item is not chosen for equipment during this review, it remains in the backpack only until the hero reaches the market, where it is sold.

> **Loot is collected during the adventure, evaluated after the objective, and economically resolved in town.**

## The Base Loop Should Not Feel Routine

The hero needs a clear and repeatable adventuring structure, but the game should actively minimize the feeling that the same sequence is simply repeating.

The underlying pattern may remain familiar:

- take an activity or quest;
- prepare;
- set out;
- encounter danger;
- complete the objective;
- review collected loot and update equipment;
- return;
- receive the reward;
- sell trophies and unused equipment;
- inspect possible purchases;
- visit the tavern and possibly hear new rumours or information;
- decide what to do next using the hero’s updated strength and knowledge.

However, the player should not constantly experience:

> the same quest → the same journey → the same fight → the same return.

Even when the internal structure is similar, individual adventures should differ through circumstances, decisions, risk, consequences, and the way this particular hero responds to them.

> **The base loop should give the game structure without turning the hero’s life into a conveyor belt of identical actions.**

The game should not fight repetition by adding dozens of equally important minor everyday chores. Variety should come from within adventures and from meaningful systems layered on top of the base loop rather than from meaningless busywork.

## Variety Comes from Layers on Top of the Loop

The same base loop should continuously change in its concrete content through the influence of other game systems.

An individual adventure may be affected by:

- the hero’s personality, tendencies, and preferences;
- level, real power, and equipment;
- the presence or absence of suitable quests;
- rare random and authored events;
- rumors and temporary opportunities;
- personal relationships with individual characters;
- faction conflicts and wars, if those systems are implemented;
- changes in cities and regions;
- consequences of previous adventures;
- divine influence from the player.

For example, the hero may return from a quest and discover that no suitable tasks remain, the available ones are too weak or too dangerous, an interesting rumor has appeared in another city, or conditions in a nearby region have changed. The hero’s personality, current condition, and previous experience further affect how they respond.

As a result, the hero may naturally decide to travel to another city, change the type of activity they pursue, take a risk for an unusual opportunity, or temporarily deviate from their usual route.

> **Variety should come not from constantly replacing the base loop, but from the world, the hero, and changing circumstances altering how that loop unfolds.**

This section does not own wars, relationships, travel, world simulation, or other external systems. It defines how the results of those systems may alter the hero’s adventure loop when they are relevant.

## Events Should Disrupt the Usual Flow, Not Replace It

Major unusual events should not happen every minute.

If every adventure becomes a unique world-scale drama, unusual events quickly stop feeling special and the required amount of unique content becomes effectively endless.

Ordinary adventures should already gain variety through the hero, the world, quests, travel, and changing circumstances. Against that background, **more significant events** occasionally occur that may:

- change the hero’s current objective;
- create an unusual opportunity;
- force a change of route or plans;
- affect personality or preferences;
- create or change an attitude toward someone;
- leave a long-term consequence.

Such events should become noticeable episodes in the hero’s biography rather than merely another form of background routine.

> **Everyday adventures create the flow of the hero’s life. Significant events create its turning points.**

> **Decisions shape the hero. Events shape their history. The deity may change direction, but does not write the script for them.**

## Temporary Travel Events

Temporary travel events are short-lived situations that physically exist on the map and may interrupt or redirect the hero while they are already travelling.

Their purpose is to make the hero’s life less repetitive and to ensure that the ordinary quest loop remains a stable fallback rather than the only thing the player repeatedly watches. The hero should regularly return to routine, but changing circumstances should often make the route between two routine stages more interesting than a simple uninterrupted walk.

At the current design stage, this system concerns only events that the hero can physically encounter while travelling. Tavern rumours, dungeon discovery, remote map information, and other ways of learning about distant opportunities are separate systems.

### When Travel Events Can Activate

A temporary travel event can currently activate only while the hero is moving through the world in one of three ordinary travel contexts:

- **city → quest or activity target**;
- **quest or activity target → city**;
- **city → another city**.

These events do not activate merely because the hero is standing still, spending time inside a city, or resolving the main objective of an already active quest.

The event exists before the hero reaches it. It is not generated solely because the hero happened to enter a particular hex.

### Event Position and Activation Area

Each temporary travel event has a **central hex** and an **activation radius**.

The central hex does not have to be hardcoded into the event template. A handcrafted event may instead define geographic placement criteria and let the map choose a suitable central hex using the shared tag system from `World_Map_and_Travel_System_Design_v0.1.md`.

Such criteria may include a distance range from a city or other anchor plus required, forbidden, or preferred hex tags. For example, a damaged-wagon event may require or prefer `road`, while a wilderness encounter may prefer `forest` or `plains` and forbid `city` or `water`.

After a suitable central hex is selected, the event uses its normal activation radius.

The current basic possibilities are:

- **Radius 0** — only the central hex activates the event;
- **Radius 1** — the central hex and the six immediately adjacent hexes all belong to the same event activation area.

Using a small activation area allows an event to represent a situation affecting a local part of the world rather than requiring the hero to cross one exact hex by chance.

At the current design stage, **one hex may belong to only one active temporary travel event at a time**. If an event with Radius 1 occupies seven hexes, those hexes are reserved by that event and should not simultaneously host another unrelated temporary travel event.

When the travelling hero enters any hex belonging to the event’s active area, the event begins.

### Event Lifetime

Temporary travel events exist for a limited amount of game time.

If the hero never enters their activation area before that time expires, the event may disappear or resolve without the hero. Exact expiration outcomes are defined by the individual event where useful.

Time continues to matter after the hero becomes involved. A detour, another event, a difficult fight, or another delay may cause an unresolved event to expire before the hero returns to it.

The exact lifetime ranges and world-generation frequency remain tuning questions for later testing.

### Handcrafted Decisions and Conditional Options

Temporary events are authored by hand. Their variety comes from the situation itself and from how different heroes can respond to it.

As a working rule, an event should normally contain:

- **one or two standard decisions** available to almost any hero;
- any number of additional decisions, improved outcomes, or alternative actions that are included only when they make sense for that specific event.

Conditional options may depend on factors such as:

- primary attributes;
- personality traits;
- class;
- current resources or condition;
- relationships or reputation where relevant;
- other explicit event-specific requirements.

An event does **not** need a special branch for every class, every primary attribute, or every personality trait. One event may reward physical strength, another wisdom or intelligence, another a particular personality tendency, and another may have no class-specific branch at all.

For example, an event in which a merchant is trapped under a damaged wagon could have a normal option to help at a cost of time and a healing resource, while sufficiently high Strength might allow the hero to lift or overturn part of the wagon and improve the outcome. A cunning hero might gain a separate dishonest opportunity while the merchant is distracted. These numbers and rewards are illustrative rather than final balance rules.

> **Events should react to who this hero has become without requiring every event to test every part of the character sheet.**

### Availability, Choice, and Success Are Separate

A requirement may make an option available without forcing the hero to choose it.

For example, high Strength may unlock an intimidation or lifting option, while the hero’s personality and circumstances still determine whether that option is attractive enough to use.

Likewise, selecting an option and succeeding at it are conceptually separate. Some special options may guarantee an improved result when their requirement is met; others may still involve risk or a success check if that better fits the authored event.

The hero’s event decision should use the normal decision philosophy from `Personality_and_Decision_System_Design_v0.1.md`: objective circumstances establish what makes sense, while personality, preferences, current goals, risk, reward, and other relevant factors affect which available response the hero actually chooses.

### Events Can Create Temporary Detours

Some events are resolved locally in the place where the hero encounters them. Others may create a **temporary detour objective** in another hex.

For example, the hero may meet a shepherd whose calf was taken by a wolf. If the hero decides to help, the event may direct them three hexes west to find the animal and defeat the wolf.

In this case the hero’s previous route is **suspended rather than forgotten**:

> **original destination → event encounter → temporary detour target → required return or resolution step → resume original destination**

The exact structure depends on the authored event. Some detours may require returning to the original event location for a reward or conclusion; others may resolve at the remote target and allow the hero to continue from there.

While following a detour, the hero is still travelling through the normal world. They may therefore discover locations, encounter another eligible temporary event, or experience other systems that normally operate during travel.

This is intentional: one event may create circumstances that naturally lead into another part of the hero’s story.

### Importance, Urgency, and Interrupting the Current Goal

Temporary events may have different **base importance** and **urgency**.

Importance represents how significant the situation is as a potential priority. Urgency represents how quickly the opportunity or danger may disappear or become impossible to resolve.

These values are not intended to replace personality or rational evaluation. The hero compares the new situation against the objective they are already pursuing.

For example:

- while searching for a missing pig, the hero may reasonably abandon or suspend that task to respond to a kidnapped child;
- while already trying to rescue a kidnapped child, the hero should normally not abandon that urgent objective merely because a shepherd has lost an animal.

The final priority may therefore depend on:

- the event’s base importance;
- remaining event lifetime / urgency;
- importance and urgency of the hero’s current goal;
- distance and expected additional travel time;
- danger and expected chance of success;
- reward or other consequences;
- personality and preferences;
- relationships or reputation;
- current condition and resources;
- divine influence where applicable.

The important question is not simply whether the new event is attractive. It is whether it is important enough to justify interrupting what the hero is already doing.

### No Hard Detour-Nesting Limit Yet

The current design does **not** impose a fixed maximum number of nested temporary detours.

Instead, importance, urgency, travel time, current objectives, and event expiration should naturally prevent the hero from following every distraction they encounter.

This intentionally remains a testable design choice. If later playtesting shows that heroes repeatedly become trapped in long chains of low-value interruptions and rarely return to meaningful goals, a hard or soft nesting limit may be added as a safety rule.

Until such a problem actually appears, the system should prefer believable autonomous prioritization over an arbitrary numerical cap.

> **The hero should be distractible because life creates circumstances, not because the game has forgotten what the hero was trying to do.**

## Criterion for New Systems

Any new mechanic layered on top of the base adventure loop should do at least one of two things:

1. **noticeably diversify the hero’s life and adventures**;
2. **create consequences that affect the hero’s future fate**.

If a system does neither, its value to the project is questionable.

Complexity is not a virtue by itself. If the same meaningful result can be achieved through a simpler system, the simpler solution should be preferred.

> **A new mechanic should either make the hero’s life more interesting now or change what may happen to them later. Otherwise, we probably do not need it.**

## Systemic Generation of Ordinary Quests

Most ordinary quests should be created systemically from prepared game data and rules rather than existing only as individually authored one-off scenarios.

This allows the game to keep providing suitable adventures without requiring an impractical amount of hand-authored disposable content.

Systemic quests do not replace unique events or authored content. They provide the foundation of the hero’s adventuring life, while rarer special stories can be layered on top.

> **Ordinary adventures should scale through systems; unique content should be used where its uniqueness is genuinely noticeable.**

## Quests Depend on Location

The ordinary quest pool should be determined by the **city and surrounding region**, not by the current level of the specific hero.

Different places may offer different:

- quest types;
- enemies;
- danger levels;
- rewards;
- local opportunities.

Safer areas naturally tend to provide easier and moderate activities, while more dangerous regions may offer harder ones more often.

Quests should **not automatically scale to the hero’s current power**. The hero evaluates what the world currently offers and decides what is suitable, worthwhile, and interesting.

> **The world offers what exists in that place. The hero decides what is within reach and worth pursuing.**

## Different Quest Difficulties

New quests in the same location may have different levels of difficulty.

Most should fit the ordinary danger range of that region, but noticeably more dangerous opportunities may sometimes appear as well.

The exact distribution and frequency of different difficulty levels are balance parameters and should be determined through prototyping and testing.

> **The world does not have to offer the hero only safe or currently suitable quests. Some available opportunities may simply be beyond the hero’s present capabilities.**

## Quest Offer Lifetime

Available quests should not accumulate in a city forever.

If the hero does not choose a quest for a long time, that offer may disappear and later be replaced by a new opportunity.

An already accepted quest does not need a universal mandatory completion timer. Time limits may exist only where they make sense for the specific quest or event.

The exact lifetime of quest offers is a balance parameter to be defined later.

> **The available adventure pool should gradually change with the world rather than becoming a permanent archive of old quests.**

## Geographic Quest Anchoring

A quest should be tied to a specific place or area of the world whenever that matches its content.

Its objective may be a camp, lair, dungeon, part of a region, event location, or another understandable destination.

After the quest is completed, failed, or disappears, the related location may disappear, change state, or remain a permanent part of the world depending on its nature.

> **A quest should feel like something happening somewhere in the world, not like an isolated line in a list.**

The exact way this connection is presented on the map belongs to `World_Map_and_Travel_System_Design_v0.1.md`.

### Rule-Based Quest Placement

A quest template does not need to hardcode the exact Hex ID where every generated instance must occur.

Instead, the template may define **placement criteria**, while the map provides candidate hexes through the shared tag system defined in `World_Map_and_Travel_System_Design_v0.1.md`.

Placement criteria may include:

- minimum and maximum distance from the quest’s city or another geographic anchor;
- required or otherwise allowed hex tags;
- forbidden hex tags;
- preferred hex tags used to rank otherwise valid candidates.

For example, a quest may specify:

- distance: **5–8 hexes from the city**;
- suitable terrain: `forest` or `plains`;
- forbidden: `road`, `mountain`, `water`, `city`.

The generator first finds hexes in the correct distance band, removes those that violate the forbidden conditions, keeps those that satisfy the template’s eligibility rules, and then selects a target among the remaining candidates. Preferred tags may make some valid candidates more likely without being mandatory.

This keeps quest content independent from one exact authored coordinate while preserving geographic logic. Moving a road, changing terrain layout, or later using a different prepared map does not require rewriting every quest template as long as suitable tagged locations still exist.

The same underlying map-tag mechanism may be reused by temporary events and other location-based content; each content type owns its own placement criteria while the map owns the tags themselves.

> **The quest defines what kind of place it needs; the map finds where that place exists.**

## Quests Respond to World State

The current state of the world may temporarily alter the available quest pool and create special opportunities on top of ordinary quests.

A war, invasion, dangerous event, regional crisis, or another meaningful change may create related quests that would not exist there under normal conditions.

When the underlying situation ends or changes, the quests created by it may also disappear, change, or be replaced by different opportunities.

> **World events should affect the hero’s adventures not only through text, but through the real actions that become available to them.**

The systems that create wars, invasions, regional states, and other world changes belong to `World_Simulation_System_Design_v0.1.md`; this document only defines how those changes may affect the hero’s available activities.

## Changing Opportunities Encourage Travel

The hero’s current location does not need to provide an endless supply of suitable activities.

Over time, the hero may find that:

- available quests are too easy;
- available quests are too dangerous;
- the remaining opportunities are unattractive to this particular hero;
- no suitable new opportunities have appeared yet;
- another location currently offers a more attractive quest, rumor, or event.

Such changes may naturally encourage the hero to wait, pursue another activity, or travel to another city or region.

The system should **not deliberately starve the hero of quests** merely to force movement.

> **The hero changes location because opportunities in the world change, not because the game artificially switches the old location off.**

## Unique Events Are Handcrafted

Rare and significant events should be authored by hand because context, consequences, and meaningful alternative developments matter most in these situations.

Such an event may take into account:

- the hero’s class and capabilities;
- personality and preferences;
- relationships with participants;
- current world state;
- previous events;
- possible divine influence.

There is no need to create a separate branch for every class or every trait. Alternatives should exist only where they genuinely make sense for the situation.

> **Systems create the hero’s everyday life. Handcrafted events create its special episodes.**

## Dungeons as Higher-Risk Adventures

A dungeon is a separate, higher-risk adventure format built around a sequence of encounters rather than one ordinary quest fight.

A dungeon definition currently contains:

- the ordinary enemy type or enemy set used by its regular encounters;
- the number of ordinary encounters / rooms;
- how many ordinary enemies appear in each encounter;
- one **unique boss** at the end;
- one **final dungeon-completion reward**.

For the first implementation, ordinary rooms may deliberately use the same enemy composition repeatedly. More varied room compositions can be added later if testing shows that repetition inside the dungeon itself becomes a problem.

The basic structure is:

> **ordinary encounter → recovery decision → ordinary encounter → recovery decision → ... → unique boss → final dungeon reward**

### Dungeon Loot Is All-or-Nothing

Ordinary dungeon enemies and the dungeon boss do **not** provide normal gold, equipment drops, or sellable trophy loot during the run.

They still award their normal **combat experience**.

The material reward belongs to the dungeon as a whole and is received only after the hero defeats the final boss and completes the dungeon.

At the current concept level, a successful ordinary dungeon should provide a **meaningful material reward built around gold plus Blue/Purple-quality equipment**. Exact gold amounts, item counts, item levels, rarity probabilities, and reward-generation formulas are deliberately left for prototype implementation and balance testing.

If the hero dies or otherwise fails before completion, the hero keeps the experience already earned from completed fights but receives **no dungeon completion loot**.

This makes the dungeon an expedition with a real finish line rather than a place where the hero can collect most of the material value from a partial clear and leave.

> **Experience is earned fight by fight; dungeon loot is earned only by completing the dungeon.**

Repeated failed attempts may need an experience-farming safeguard if testing shows that repeatedly earning experience from early dungeon rooms becomes more efficient than ordinary progression. No special anti-farming rule is fixed yet.

### No Free Healing Between Dungeon Fights

The earlier working idea of automatic one-tick / 20% Max Health recovery between dungeon fights is **removed**.

The hero does not receive free dungeon-specific HP restoration between encounters.

Instead, healing comes from **healing potions carried in the hero’s Belt slots** as defined in `Economy_Equipment_and_Loot_System_Design_v0.1.md`.

Potions may be used **only between fights**, never during combat, and the hero may drink more than one potion during the same break.

Between ordinary encounters, the hero uses only potions whose healing can be applied at full value. The hero does not spend a potion if doing so would waste part of its healing through overheal.

For one potion type with a fixed healing amount, the working rule is:

`Potions used = floor(Missing Health / Potion Healing)`, limited by the number of potions still available.

For example, at `750 / 1000 HP` with potions that restore `100 HP`, the hero drinks two potions and continues at `950 / 1000 HP`. A third potion is kept because only half of its healing would be effective.

Immediately before the boss, the rule changes: the hero tries to enter the boss fight at **100% Health**. The hero may therefore use a final potion even when part of its healing is wasted by overheal. If there are not enough potions to restore full Health, the hero uses all remaining potions and still proceeds to the boss.

Running out of potions does not create a retreat option in the current dungeon version. The expedition continues without further potion healing until the dungeon is completed or the hero dies.

> **Ordinary rooms favor efficient potion use; before the boss, survival takes priority over avoiding overheal.**

### Dungeon Preparation Happens in Town

Discovering a dungeon does **not** make the hero immediately interrupt the current trip and enter it.

The hero records the dungeon as a known opportunity, finishes or resolves the current activity, returns to a city, and prepares for a dedicated dungeon expedition.

For a dungeon attempt that the hero currently considers eligible, the Belt must be **fully stocked** before departure. The hero tries to purchase healing potions until every available Belt potion slot is filled.

If the hero does not have enough gold to fill all available Belt slots, they do **not** leave for the dungeon with a partially filled Belt. Instead, they return to ordinary progression — such as available quests and other normal activities — to earn more gold. After later returning to town, they check preparation again.

Once every available Belt potion slot is filled, the preparation requirement is satisfied and the hero may set out specifically for the dungeon.

This full-Belt requirement does not erase knowledge gained from a previous failed dungeon attempt. If the hero already learned that the dungeon is beyond their current readiness, they must also satisfy the normal retry-readiness rule before another expedition becomes eligible.

A dungeon attempt is therefore not a free side trip. Preparation consumes gold, and stronger potion levels or a Belt with more slots can increase the cost of a fully prepared expedition.

The current preparation loop is:

> **known eligible dungeon → return to city → try to fill every Belt potion slot → insufficient gold: continue ordinary adventures → enough gold: fill all slots → dedicated dungeon expedition**

> **A dungeon is something the hero prepares for and sets out to attempt, not something they casually enter while passing by.**

### First Attempt Has Uncertain Difficulty

The hero should not know a dungeon’s exact effective combat strength before the first real attempt.

The first expedition is intentionally uncertain. The hero may know the dungeon’s identity, location, visible theme, or other authored information, but should not receive a precise number equivalent to "Dungeon Power 600" that makes the decision identical to waiting until Hero Power reaches the same value.

Dungeons are expected to kill the hero sometimes. Failure is part of learning the dungeon rather than automatically evidence that the balance is broken.

After a failed attempt, the hero gains practical knowledge from how far they progressed and what defeated them. The retry threshold is based on the hero’s **Hero Power at the moment that failed attempt began**:

- if the hero dies before killing even one ordinary dungeon enemy, the dungeon becomes eligible for another attempt only after Hero Power has increased by at least **20%**;
- if the hero kills at least one ordinary dungeon enemy but dies before reaching the boss, the dungeon becomes eligible again after at least **15%** more Hero Power;
- if the hero reaches the boss and dies during the boss fight, the dungeon becomes eligible again after at least **10%** more Hero Power.

For example, if the failed attempt began at `500 Hero Power`, the corresponding retry thresholds are `600`, `575`, or `550 Hero Power` depending on how far the hero progressed.

The percentage threshold is a minimum readiness gate, not a replacement for normal preparation. Before the next attempt, the hero must still return to town and fully refill all available Belt potion slots.

> **The farther the hero proved they could progress, the less additional strength they need before trying that same dungeon again.**

### Cleared Dungeons Are Replaced Over Time

A successfully completed dungeon is exhausted as that specific adventure and does not immediately reset in the same location.

After some game time has passed, a **new dungeon appears in another suitable location near the same city / within the same local region**. The exact replacement delay is a tuning value to be determined later.

The replacement dungeon is a newly generated adventure rather than a copy of the cleared one. Its defining combat and reward parameters are selected again, and the new dungeon should differ from the cleared dungeon in meaningful ways, including:

- combat strength / danger;
- ordinary enemy type or composition;
- unique boss;
- final dungeon-completion reward.

The new dungeon’s strength is determined by the dungeon / regional generation rules rather than scaling automatically to the hero’s current Power. A replacement may therefore be easier or harder than the dungeon that was just completed.

The new dungeon begins **unknown to the hero** and must be discovered through the normal dungeon-discovery systems, including exploration, rumors, or an applicable divine information ability.

> **Clearing a dungeon removes one known adventure; after a delay the region creates a different unknown dungeon rather than simply resetting the old one.**

## No Retreat During the Current Dungeon Version

The current dungeon design has **no voluntary retreat behaviour once the hero has entered the dungeon**.

The hero continues through the encounter chain until either:

- the final boss is defeated and the dungeon is completed; or
- the hero dies.

Low Health or having no healing potions remaining does not create a retreat decision. The hero simply continues with the resources still available.

This is intentionally simple for the first implementation. Retreat logic may be reconsidered later only if testing shows that it adds useful behaviour rather than unnecessary complexity.

> **For now, entering a dungeon means committing to the attempt: victory or death.**

## Specialization Quests as Long-Term Goals

Gaining a new class specialization is not an automatic reward for reaching the relevant level. The level milestone unlocks a **Specialization Quest** tied to the development path chosen autonomously by the hero, as defined in `Combat_and_Progression_System_Design_v0.1.md`.

A Specialization Quest is a **long-term goal layered on top of the hero’s ordinary life** rather than a replacement for the normal quest/activity loop. The hero may continue completing ordinary quests, earning gold, improving equipment, visiting shops, and otherwise developing while the specialization goal remains active.

The core objective is:

> **obtain Specialization Quest → dedicated dungeon appears → prepare and attempt dungeon → defeat boss → obtain quest relic → complete the quest → receive the new specialization**

### Dedicated Specialization Dungeon

The quest requires a specific **quest item / relic** located inside a dedicated specialization dungeon.

That dungeon does **not exist on the map before the Specialization Quest is created**. It is generated when the hero receives the quest, specifically so the hero cannot discover, clear, or loot the required dungeon before the specialization goal exists.

When generated, the dungeon appears on the map as part of the active quest and its location is known to the hero.

The specialization dungeon exists **in addition to the region’s ordinary dungeon population**. Under the current working density of roughly two ordinary dungeons around a major city/region, the active specialization dungeon is effectively an additional **third dungeon** rather than replacing one of the normal two.

It is a quest-specific dungeon, not an ordinary renewable regional dungeon. Its purpose is to gate the specialization milestone through a concrete adventure and relic rather than through a menu choice.

Where applicable, the specialization dungeon should reuse the ordinary dungeon rules for preparation, potion use, death, learned retry thresholds, and encounter progression instead of creating a second unrelated dungeon system. Exact combat strength, room count, boss design, and other balance values belong to implementation/testing.

### Completing the Specialization Goal

Defeating the dedicated dungeon’s boss allows the hero to obtain the required relic. The relic is a **quest objective**, not an ordinary random equipment drop.

The hero receives the new specialization only after the relic objective is resolved and the Specialization Quest itself is completed.

This means reaching level 40 or 80 represents **readiness to pursue the next development path**, while actually becoming that specialization requires the hero to accomplish something meaningful in the world.

> **A specialization is not selected in a menu and granted instantly; the hero earns it by completing a long-term adventure tied to the path they have chosen.**

## Migration note

Prototype 0 quest rules remain implementation scope unless explicitly promoted into full-game design.