# The Hero’s Story — Current Project State

This document records **what is actually implemented now** in the current Prototype 0.2 build.

It is intentionally a runtime snapshot rather than a second design specification. Use it to understand the current playable systems, temporary development deviations, and major missing pieces. Exact ownership by file belongs in `project-map.md`; fragile cross-system contracts belong in `dependencies.md`; intended final behaviour belongs in the Prototype 0.2 Scope.

## Current development focus

The current build already contains a working autonomous early-game loop across quests, travel, events, economy, equipment, dungeons, personality, God influence, and a developer UI.

The most recent gameplay-content work expanded the Starting Region temporary-event population to **thirteen handcrafted events**. The pool now mixes combat and non-combat stories, stat-driven Formative branches, broad use of all eight established trait sides, partial-HP preparation fights, Gold and ilvl 5/10 equipment rewards, and branch-specific successful-event Diary passages. The **Hero Diary / Chronicle** first slice also remains live: ordinary quest selection/completion are recorded, and combat death now records the real killer plus the owning quest, dungeon, or temporary event. Further diary work is content/coverage expansion rather than a redesign of the simulation.

The larger Prototype 0.2 world is still incomplete: only the Starting City is a full gameplay context, thirteen handcrafted temporary events exist against the final two-region target of roughly 15–20, only the two Starting Region ordinary dungeons are authored, first specialization is not implemented, and save/load is still absent.

## Simulation and world time

Implemented:

- one autonomous Warrior hero; the player does not directly control movement, quest choice, combat actions, equipment choice, shopping, or dungeon attempts;
- one shared world clock;
- **1 world tick = 10 simulation seconds** at normal speed;
- developer speed controls: ×0, ×1, ×2, ×5, ×10, ×20, ×100;
- partial world-tick progress is preserved between updates;
- active combat freezes ordinary world-tick progression while combat runs on its finer internal timeline;
- one resolved fight still consumes exactly one world tick;
- seeded/reproducible randomness is used by the current gameplay systems, with derived streams where systems must not perturb one another;
- the same shared `PowerCalculator` is used for hero, mobs, ItemPower reference calculations, and virtual-equip comparisons.

There is **no offline simulation** while the application is closed.

## Hero progression and primary attributes

The Warrior currently starts with:

- STR = 5;
- DEX = 5;
- INT = 5;
- CON = 5;
- WIS = 5.

Current pre-specialization level-up growth is already the approved Prototype 0.2 model:

- +1 STR automatically from the Warrior class;
- +4 pending player-distributed primary-attribute points;
- pending points provide no benefit until the player spends them;
- unspent points accumulate across levels;
- the player may allocate them only through the Simulation command path, not directly through UI state mutation;
- allocation is blocked during an already active combat session.

The current generic primary-stat effects are centralized through `StatResolver`:

- each STR contributes +2 physical Damage and +1 percentage point Critical Damage;
- each DEX contributes +10 Accuracy, +2 Dodge, and +0.5 percentage points Critical Chance;
- each CON contributes +20 MaxHP and +0.5 Armor;
- INT currently has no generic Warrior combat conversion;
- WIS currently scales Warrior abilities through their own formulas rather than a universal combat-stat bonus.

XP progression is functional, excess XP carries over, and a mid-quest level-up refreshes the hero's resolved persistent combat stats before later fights.

The lightweight starting questionnaire is **not implemented yet**. New heroes therefore still use the temporary seeded starting-trait bootstrap described below.

## Personality and traits

The final four Prototype 0.2 personality axes are live in runtime state:

- **Cautious ↔ Brave** (`courage`);
- **Devious ↔ Noble** (`morality`);
- **Greedy ↔ Generous** (`greed`);
- **Conservative ↔ Curious** (`curiosity`).

Each hidden axis currently uses:

- range −100…+100;
- visible trait activation at ±40;
- return-to-neutral hysteresis at ±20.

Current temporary new-game bootstrap:

- 1–2 established starting traits are rolled from Cautious, Brave, Devious, Noble, and Greedy;
- each rolled trait initializes its matching hidden axis at exactly ±40;
- this seeded roll is transitional and will later be replaced by the approved starting questionnaire with smaller non-visible biases.

Personality is already used by real gameplay:

- ordinary quest Hard Filter risk windows are standard 55–95% MobPower/HeroPower, Brave 60–100%, and Cautious 50–90%;
- current QuestScore also uses established Courage, Morality, and Greed influences;
- Noble deals the existing +10% conditional damage to Monster-category enemies;
- Devious deals the existing +10% conditional damage to Humanoid-category enemies;
- temporary events can perform **Formative** decisions that move hidden axes without reading general personality;
- temporary events can perform **Expressive** decisions that read established personality without reinforcing that same general trait.

Exact hidden values are visible only in the current developer Hero screen; the intended player-facing design still treats them as hidden.

## Combat and Warrior abilities

Live combat is one hero versus one current enemy using resolved `CombatStats`.

Implemented combat features include:

- independent attack timers;
- Accuracy/Dodge hit resolution;
- Armor mitigation;
- Fire/Cold/Lightning Resistance formulas;
- Block chance and Block mitigation;
- critical hits;
- simultaneous-death handling;
- live CombatSession HP;
- per-fight Rage;
- current Noble/Devious conditional damage bonuses;
- temporary divine Physical Damage blessing.

Current ordinary mobs mostly use physical attacks; elemental mitigation exists, but the current content still lacks real elemental-damage encounters.

### Rage

- each fight starts at 0 Rage;
- successful normal hits generate Rage;
- critical normal hits generate more;
- receiving a hit generates Rage even when Block reduces it;
- avoided incoming attacks generate none;
- Rage is capped at 100 and is discarded when the fight ends.

### Power Strike

- learned automatically at compressed hero Level 5;
- currently Skill Level 1 only;
- autonomous use when its Rage/cooldown conditions are satisfied;
- replaces the next normal attack opportunity;
- cannot miss but may critically hit;
- scales with WIS through its ability-specific formula.

### Battle Guard

- learned automatically at compressed hero Level 10;
- currently Skill Level 1 only;
- autonomous defensive activation after HP falls to the current threshold;
- no Rage cost and no shield requirement;
- lasts 10 seconds with a 60-second cooldown;
- applies after ordinary Block/Armor/Resistance resolution;
- scales with WIS through its own ability-specific formula.

Purchasable Skill Levels 2–10 and Protector/Slayer specialization abilities are not implemented yet.

## Death and resurrection

Ordinary quest death is functional rather than a developer-error path.

On ordinary quest combat death:

- current HP becomes 0;
- the current quest is cancelled;
- no XP is granted for the killing mob;
- no quest-completion Gold is granted;
- XP/levels already earned earlier remain;
- the hero returns to the safe Starting City context;
- natural resurrection waits exactly **100 world ticks**;
- resurrection returns the hero at exactly **1 HP**;
- city recovery restores 20% MaxHP per world tick;
- the hero does not resume normal activity until fully recovered.

Dungeon and temporary-event deaths reuse the same broad death/resurrection contract through their current owning runner.

`QuestLoot` does not exist yet, so the intended unsafe-adventure-loot loss on death is not implemented. Current generated ordinary equipment becomes permanent immediately.

## World map and travel

The current authored world map is a **26 × 15 logical hex map = 390 gameplay cells**.

Implemented spatial rules:

- exactly two seven-hex city clusters exist geographically;
- Starting Region and Mid Region are derived from the two city centers;
- the two cities are connected by one authored road;
- current ordinary terrain is plains, forest, and hills, with road/city handled through semantic tags and presentation;
- current permanent tags are `city`, `city_center`, and `road`;
- active world activities reserve their map footprint so one hex cannot belong to two active activities at once;
- quests, dungeons, and temporary events use the shared placement/reservation foundation;
- hero position is real runtime state rather than an abstract distance counter.

Travel uses the approved current scale:

- **1 traversed hex = 1 world tick**;
- **1 hex = 3 km**;
- `TravelSystem` moves the hero one adjacent hex per completed travel tick.

Ordinary selected quests use real placed targets and real outbound/return routes. Temporary events can suspend a quest route or either leg of an ordinary-dungeon trip, resolve their own activity/detour, and then rebuild the interrupted route from the hero's new position.

City-to-city autonomous relocation is not implemented yet.

## Ordinary quests and quest board

The Starting City currently has:

- **22 ordinary mob definitions** on the current approximately 25→320 Power progression;
- **22 matching ordinary quest templates**;
- explicit 8 lower / 7 middle / 7 higher strength-band membership;
- authored real map-placement constraints for every current quest;
- runtime `QuestOffer` instances with concrete rolled enemy count, reward, target hex, and real route distance.

Ordinary quest selection is autonomous and uses the current dedicated flow:

> Hard Filter → QuestScore → highest valid quest → `QuestRunner` execution

`QuestRunner` executes only the already selected quest. Quest selection, scoring, combat resolution, item generation, diary prose, God rules, and UI remain outside it.

### Current temporary quest-board development mode

The intended Prototype 0.2 board target remains up to 9 offers with up to 3 per strength band, but that cap is **temporarily disabled for playtesting**.

Current runtime behaviour:

- every currently eligible Starting City quest template may appear simultaneously;
- accepted offers leave the board immediately;
- the accepted active quest keeps its real target reservation independently of later board refreshes;
- the whole available board refreshes every **50 world ticks**;
- successful completion starts a strict **50-world-tick template cooldown**;
- cancellation does not start that completion cooldown;
- an expired cooldown only restores eligibility; the quest returns only on a later shared board refresh.

This 50-tick completion cooldown is the current implemented rule. A stale duplicate 100-tick note still exists near the end of the large Scope and should not be used to revert the current runtime by accident.

Current ordinary quests reward Gold; they do not contain quest-specific equipment reward pools.

## Current ordinary quest loop

Successful ordinary life currently follows roughly:

```text
choose quest
→ real map travel to target
→ fight / XP / recovery until objective completes
→ real return travel
→ turn in for Gold
→ dedicated market/sale tick
→ autonomous equipment shopping, one purchase per shopping tick
→ evaluate known local dungeon readiness
→ prepare missing dungeon potions if needed
→ dungeon or next ordinary activity
```

Defeat follows:

```text
fight lost
→ quest cancelled
→ 100-tick respawn
→ resurrect at 1 HP
→ city recovery
→ normal autonomous activity resumes at full HP
```

## Temporary events

The generic temporary-event system is live and currently has **13 authored Starting Region events**:

1. `У старой вырубки`;
2. `Дым над старой башней`;
3. `Чужие силки`;
4. `Мёртвый гонец`;
5. `Огр у старого кургана`;
6. `Костёр без хозяина`;
7. `Волки на пастбище`;
8. `Чужая шкатулка`;
9. `Беглый наёмник`;
10. `Раненый разведчик`;
11. `Камни старого старателя`;
12. `Зверь в сломанной клетке`;
13. `Спор у межевого камня`.

The current event framework supports:

- authored SCENE / DECISION / TRAVEL / COMBAT / END style stages;
- Formative and Expressive personality interactions;
- stat-driven authored branch choice;
- Expressive checks for either one established trait or any established trait from an authored list;
- shared combat through the normal `CombatSession`;
- event combat may author a reduced **starting current HP ratio** for the referenced mob while preserving that mob's normal MaxHP and all other combat stats;
- authored Gold/equipment consequences through normal reward systems;
- multi-tick authored stages;
- real map detours to an event-owned secondary objective;
- interruption and later resumption of the previous travel destination;
- event-owned death/resurrection handling.

The fifth event, `Огр у старого кургана`, is placed on Starting Region plains 5–6 hexes from Starting City and always fights the existing `Опытный огр`. Its Formative opening compares DEX / STR / CON: DEX moves Courage `+5` and immediately attacks an Ogre starting at 75% current HP; STR spends two preparation ticks and reaches an 80% HP fight; CON spends three preparation ticks, moves Courage `−5` toward Cautious, and reaches an 85% HP fight. STR and CON then perform one shared Expressive **Devious OR Conservative** check: if either trait is established, two additional preparation ticks reduce the Ogre by another 15 percentage points, to 65% after STR or 70% after CON, without reinforcing either trait. The Ogre keeps its normal Attack, Armor, Attack Speed and other combat stats in every branch, grants its normal 195 XP on victory, and the event awards one guaranteed Green/Uncommon ilvl 10 equipment item through the normal authored reward pipeline with no extra Gold.

Events 6–13 deliberately reuse the same framework rather than adding more event-only systems. They cover forest/plains/hill/road placements and combine STR/DEX/CON/WIS Formative openings with Curious, Conservative, Noble, Devious, Greedy, Generous, Brave and Cautious Expressive behaviour. Some outcomes are entirely social or exploratory, some make combat optional, and some always lead to shared `CombatSession` fights against existing ordinary mobs. Their authored material rewards range from 25–120 Gold and guaranteed Common/Uncommon ilvl 5/10 items; successful END stages contain their own branch-specific Diary text. Several branches intentionally prove same-event personality activation: a Formative `±5` movement can establish Greedy, Conservative, Cautious, Noble or Curious at the `±40` threshold and the later Expressive stage sees it immediately.

Current shared population rules:

- no temporary event is placed before world tick 100;
- first population becomes eligible at tick 100;
- unengaged population rerolls every 200 ticks afterward: 300 / 500 / 700 / ...;
- current cap is 5 simultaneous temporary events;
- activating an event starts a 500-tick cooldown for that event definition;
- an already engaged event survives a population rotation until it finishes;
- selected events that currently cannot fit may remain pending for that population cycle rather than displacing the hero's active objective.

Event interception currently works during:

- ordinary quest outbound travel;
- ordinary quest return travel;
- outbound ordinary-dungeon travel;
- completed ordinary-dungeon return travel.

It does **not** activate during dungeon combat or dungeon between-fight preparation.

If an event kills the hero while travelling toward a dungeon, that trip is cancelled without recording a failed dungeon attempt or dungeon retry-Power penalty because the hero never entered the dungeon.

If an event kills the hero while returning from an already completed dungeon, the dungeon remains completed and its granted completion rewards remain permanent; the interrupted return runtime is cleared and no new dungeon failed-attempt memory or retry-Power penalty is created.

The final Prototype 0.2 target of roughly 15–20 handcrafted events across both regions remains incomplete; the current Starting Region pool provides 13 of that target.

## Ordinary dungeons

The current ordinary-dungeon system loads ordinary dungeon definitions from the Starting/Mid region content folders and keeps specialization dungeon content separate.

Both required **Starting Region ordinary dungeons** are live:

- **Заброшенные железные шахты** — 3 Mine Troglodytes at approximately 140 Power, then Deep Devourer at approximately 180 Power; completion grants 700 Gold + one compressed ilvl 5 Rare/Epic item;
- **Городище Черноклыков** — 3 Blackfang Guards at approximately 230 Power, then Goblin King at approximately 300 Power; completion grants 2000 Gold + one compressed ilvl 10 Rare/Epic item.

Both current completion item rolls use **75% Rare / 25% Epic** and may select from all twelve current equipment slots.

Current dungeon flow includes:

- deterministic real map placement and reservation;
- hidden/known state;
- discovery by physically reaching the dungeon hex or by Divine Vision;
- dungeon discovery does not interrupt an activity already in progress;
- post-quest market/shopping resolves before a known dungeon is considered;
- real map travel to the dungeon;
- the same shared live combat system used by quests/events;
- current HP carried between dungeon encounters;
- exactly one world tick of between-fight preparation after each ordinary victory, including before the boss;
- no free automatic healing between encounters;
- dungeon-only healing through prepared Belt potions;
- ordinary dungeon mobs and bosses grant XP but no ordinary equipment drops or per-mob Gold;
- normal death/resurrection handling;
- successful completion reward routing through the normal item-generation/equipment-evaluation systems;
- completed dungeon removal from the active map;
- real return travel to Starting City after success.

### Dungeon readiness and retries

Every current dungeon attempt requires all currently available Belt potion slots to be filled with legal potions.

After a failed attempt, the next attempt is additionally blocked until current base HeroPower reaches the remembered retry threshold from the failed attempt:

- +30% after dying before killing any ordinary dungeon enemy;
- +20% after making ordinary progress without reaching the boss;
- +10% after reaching the boss.

The failed attempt's starting HeroPower is the comparison baseline. A later failed retry replaces that baseline with the retry's own starting HeroPower.

The two Mid Region ordinary dungeons are not authored yet.

## Items, equipment and inventory

The current equipment model uses all **12 Prototype 0.2 slots**:

- Helmet;
- Chest;
- Gloves;
- Pants;
- Boots;
- Main Hand;
- Off Hand;
- Necklace;
- Earrings;
- Ring 1;
- Ring 2;
- Belt.

The current build has three live core visual/progression families:

- ilvl 1 `Посвящённый Ржавой Цепи` / Rustchain Initiate;
- compressed ilvl 5 `Страж Железного Следа` / Ironwake Sentinel;
- compressed ilvl 10 `Авангард Железного Оплота` / Ironward Vanguard.

Jewelry/Belt content exists for compressed ilvl 5 and ilvl 10. The current first three equipment progression control points are therefore live at ilvl 1 / 5 / 10; later 15 / 20 / 25 / 30 content is not yet built out.

Every new hero also begins with three fixed Common ilvl 1 starting-clothes items:

- `Поношенная рубаха`;
- `Поношенные штаны`;
- `Поношенные сапоги`.

Each grants exactly +1 Armor, has no random affixes, and sells for 1 Gold after being replaced.

Current generated-item behaviour includes:

- inherent stats by item type/item level;
- Common / Uncommon / Rare ordinary item generation;
- Epic generation through current dungeon completion rewards;
- seeded modifier-budget variation and affix generation;
- ItemPower calculated from the shared Power model;
- virtual-equip evaluation using real resulting HeroPower rather than displayed ItemPower as the final ordinary equip decision;
- both ring positions evaluated for a new ring so the weaker current ring may be replaced regardless of authored ring-slot label;
- Belt evaluated by potion-healing capacity first and inherent Health as tie-breaker rather than normal HeroPower alone.

Ordinary mob equipment drops currently use:

- 5% drop chance;
- 70% Common / 25% Uncommon / 5% Rare;
- lower Starting City band → ilvl 1 source;
- middle band → compressed ilvl 5 source;
- higher band → compressed ilvl 10 source.

The current Inventory keeps up to **36 unequipped equipment items** in FIFO order. Healing potions are stored separately from that equipment capacity.

`QuestLoot` / temporary unsafe adventure loot is not implemented yet.

## Economy, shop, Belt and potions

Starting City has one functional equipment shop with three progression bands:

- ilvl 1;
- compressed ilvl 5;
- compressed ilvl 10.

Each band currently rolls 6 White + 2 Green distinct-slot equipment listings, for up to **24 equipment listings** when fully stocked.

Current shop behaviour:

- stock refreshes deterministically every **200 world ticks**;
- purchased positions remain empty until the next refresh;
- successful ordinary quest turn-in schedules a separate market/sale tick;
- unequipped priced ordinary equipment is automatically sold on that market tick;
- equipment buying happens only afterward in `SHOPPING`;
- at most one equipment item may be bought per shopping world tick;
- ordinary equipment must meet the current meaningful-upgrade threshold and still improve the real virtual-equip build;
- replaced equipped gear is sold immediately during a shop purchase rather than routed back through Inventory;
- Gold required for a Power-ready dungeon's mandatory potion loadout is protected from optional equipment spending.

### Belt

The Belt is a real equipment slot with:

- inherent Health;
- potion capacity from rarity: Common/Uncommon/Rare/Epic = 1/2/3/4 slots;
- maximum legal potion level from Belt Item Level.

### Healing potions

Current live Starting City potion tiers are:

- compressed Level 5: 100 HP for 100 Gold;
- compressed Level 10: 150 HP for 200 Gold.

Potions are currently used only for dungeon preparation/healing, not ordinary quests.

Before a current dungeon attempt:

- every Belt slot must be filled;
- the preparation system chooses a complete affordable legal loadout;
- already owned potions are reused;
- if missing bottles must be bought, one dedicated `PREPARING_DUNGEON` world tick purchases the missing set before travel;
- if the complete loadout is already owned, no artificial purchase tick is added.

Inside the dungeon, multiple prepared potions may be consumed inside one between-fight preparation window. Ordinary-room healing avoids overheal; pre-boss preparation may accept overheal to reach full HP.

Later potion tiers and prepared-Belt-slot visualization are still missing.

## God influence

The current God system starts/maxes at **100 Divine Energy** and restores +1 Energy every 6 world ticks while simulation time advances.

Implemented abilities:

- **Divine Healing** — 10 Energy, restores 50% MaxHP, 30-tick cooldown, usable during live combat;
- **Combat Empowerment** — 10 Energy, +15% resolved Physical Damage for the next 5 fights, 120-tick cooldown;
- **Instant Resurrection** — dynamic cost `RemainingRespawnTicks × 0.5`, no separate cooldown;
- **ordinary quest guidance** — 5 Energy, +0.20 DivineModifier to one valid current offer for the next selection, 360-tick cooldown;
- **Divine Vision** — 80 Energy, 1500-tick cooldown, reveals one random existing unknown dungeon in the hero's current region.

The current developer God panel exposes Healing, Combat Empowerment, Instant Resurrection, and Divine Vision.

Ordinary quest guidance is currently **headless-only** because the player-facing quest-guidance selection UI has not been implemented.

First-specialization divine guidance is not implemented because specialization itself is still absent.

## Narrative, debug log and diary

Gameplay systems already emit structured facts for current quest/death behaviour rather than relying on UI text as game state.

### Developer Debug Log

The developer log:

- retains the latest **100 world ticks** rather than a fixed line count;
- keeps all lines produced by one combat under the single world tick consumed by that fight;
- autoscrolls to the newest wrapped text;
- prints detailed quest/combat/runtime information;
- currently prints the top three Hard-Filter-eligible ordinary quest candidates and the chosen quest's existing QuestScore component breakdown without recalculating the decision in the narrative layer.

The future player-facing **Explanatory Log** is not implemented yet.

### Hero Diary / Chronicle

The first real diary slice is live.

Current diary sources are only:

- ordinary quest selection as a temporary "current activity" entry while that quest remains active;
- ordinary quest successfully turned in, replacing/removing its earlier temporary selection entry so a completed quest occupies only one lasting Diary entry;
- hero died in combat during an ordinary quest, ordinary dungeon, or temporary event; the entry names the killer and the specific activity.
- natural resurrection after the normal respawn delay;
- instant resurrection caused by player divine intervention, with distinct wording from natural resurrection.
- acquisition of Rare/Blue or Epic/Purple reward/drop equipment; Common/White and Uncommon/Green equipment do not create Diary entries.
- ordinary dungeon discovery;
- the hero committing to a dungeon attempt;
- the number of healing potions actually bought for that dungeon preparation;
- successful dungeon completion with the real Gold and Rare/Epic equipment reward in one combined entry.
- successful temporary events using the authored `diary_text` from the exact END branch that resolved; event equipment rewards stay folded into that event passage instead of creating a second significant-equipment Diary entry.

Current behaviour:

- Simulation supplies structured quest/death/resurrection/equipment-acquisition/dungeon facts and authored successful-event endings to `DiaryRecorder`, which manages recording and temporary quest-entry lifecycle through the existing `DiaryNarrator` and `Diary`;
- `Diary` stores the ready player-facing entries;
- `Diary` retains at most the newest **100 entries**; adding another entry discards the oldest one;
- a selected ordinary quest uses a removable temporary Diary entry; successful turn-in removes it before adding the final completion entry, while quest cancellation/death removes it without leaving a separate cancelled-quest line;
- every entry is prefixed with the real world tick;
- the Diary tab updates live and automatically stays scrolled to the newest wrapped entry;
- routine travel, individual attacks/fights, recovery ticks, market noise, and QuestScore diagnostics do not create diary entries;
- ordinary quest selection/completion phrases live in an external shared narrative resource;
- generic combat-death wording lives in a separate shared narrative resource;
- generic resurrection wording has separate natural/divine variant groups in its own shared narrative resource;
- Rare/Epic equipment acquisition wording has separate quality-specific variant groups in its own shared narrative resource;
- dungeon discovery / attempt / potion-purchase / completion wording lives in its own shared narrative resource;
- successful temporary-event outcome wording stays with the owning END stage in the event data rather than being duplicated into a shared phrase bank;
- current implemented Diary event types still contain only **one authored phrase each**;
- an individual quest may later override the shared phrase resource with quest-specific wording;
- phrase selection uses a dedicated narrative RNG stream so adding wording variants cannot perturb gameplay randomness.

Still missing from the Diary:

- episode grouping;
- persistent save/load history;
- additional phrase variants;
- level-up / trait-change / remaining dungeon detail / specialization / other important divine-intervention coverage;
- the rest of the required Prototype 0.2 diary sources.

## Current developer UI

The present interface is a functional **developer-oriented UI**, not the finished Prototype 0.2 player-facing presentation.

Current major pieces:

- persistent top navigation;
- main hero/opponent/debug panels; the hero summary and pending-attribute plus are owned by the dedicated `HeroSummaryPanel` component, with existing presentation and refresh timing preserved;
- Hero development screen;
- Inventory screen;
- Map screen;
- God panel;
- Log / Diary tabs;
- developer simulation-speed controls.

### Hero screen

The development controls and personality axes are owned by `scripts/ui/screens/hero_screen.gd` and its dedicated scene. MainUI retains navigation, simulation advancement and main-screen summary coordination; allocation rules remain in Simulation.

Currently shows:

- pending primary-attribute points with five +1 allocation controls;
- live hero combat/progression information;
- all four personality axes;
- developer-only exact signed hidden personality values and threshold markers.

### Inventory screen

Currently shows:

- all 12 equipment slots;
- hero paper doll with the five armor overlays;
- 36-slot retained-equipment inventory;
- separate visual potion column with one physical bottle per displayed slot;
- item/potion tooltips and rarity outlines.

Manual equipping/dragging/selling is intentionally not normal player gameplay and is not implemented.

### Map screen

Currently shows:

- authored terrain and both city clusters;
- road;
- live hero position;
- current quest targets;
- current selected quest highlight;
- ordinary dungeon markers with current developer hidden-location presentation;
- active temporary-event footprints as translucent dark-blue map areas;
- hover/debug information;
- zoom and right-mouse panning.

The final required current-route/destination presentation is still missing.

Opening Inventory/Map changes UI visibility only; the same Simulation continues running.

## Test status

The repository has automated regression tests and GitHub CI.

Current targeted coverage includes the major implemented slices:

- world clock / speed / seeded randomness;
- hero progression and stat allocation;
- combat, Rage, Power Strike, Battle Guard, death and resurrection;
- personality activation/hysteresis and event-driven formative/expressive behaviour;
- quest generation/selection/refresh/travel/completion;
- map placement/reservations/travel;
- temporary-event population and runtime branches;
- dungeon placement/discovery/readiness/combat/retries/rewards;
- item generation/equipment evaluation/inventory;
- shop/economy/Belt/potion integration;
- God abilities;
- current UI components;
- developer-log and Diary behaviour.

For ordinary changes, narrow deterministic tests are preferred over running the entire historical suite. Several old fixed-quest/timing tests still contain legacy expectations, so a broad suite result must be interpreted against those known stale tests rather than treated as proof that current systems are wrong.

## Important current deviations / compatibility state

These are intentional or transitional and should not be silently "fixed" back to older behaviour:

- the Starting City quest board currently exposes all eligible templates instead of enforcing the intended 3/3/3 maximum while the no-suitable-quest problem is being evaluated;
- the current ordinary quest completion cooldown is 50 world ticks;
- new heroes still receive 1–2 seeded established traits instead of the future questionnaire's mild hidden biases;
- `Simulation.new()` retains a fixed-Goblin compatibility path for older tests, while the real developer UI passes `null` to enable autonomous quest selection;
- abstract legacy quest-distance fields still exist for old fixed tests/offers, but current real gameplay uses map targets and route length;
- `QuestLoot` is not implemented, so ordinary generated equipment is currently permanent immediately;
- current normal attacks/content are effectively physical even though elemental mitigation exists;
- unknown dungeons are intentionally partially visible in the current developer Map view for testing; this is not the final hidden-information presentation;
- the UI is a developer build and may expose hidden values that the eventual player UI must not expose.

## Major Prototype 0.2 pieces still missing

The most important incomplete areas are:

- starting questionnaire and removal of the temporary seeded established-trait bootstrap;
- Mid-Level City as a complete quest/economy gameplay context;
- autonomous city relocation;
- Mid-Level City ordinary quests/content;
- the remaining temporary-event population toward the 15–20 target;
- two Mid Region ordinary dungeons;
- first Warrior specialization: Protector / Slayer direction, specialization quest, specialization dungeon, specialization rewards and abilities;
- later equipment/potion progression content beyond the currently live Starting City tiers;
- two-handed / complete legal hand-configuration content breadth;
- QuestLoot / unsafe carried adventure loot;
- purchasable higher Skill Levels and training economy;
- Curious/Conservative spending priority;
- player-facing ordinary quest-guidance selection UI;
- full Hero Diary coverage and episode grouping;
- player-facing Explanatory Log;
- finished player-facing screens/presentation;
- save/load and persistent diary/history;
- long-run Prototype 0.2 balance/soak validation through the intended approximately level-25–30 progression.

When this document conflicts with current code or a more recently approved design change, verify the repository and the Prototype 0.2 Scope rather than restoring older behaviour from historical chats.
