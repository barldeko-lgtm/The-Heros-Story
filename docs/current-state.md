# The Hero’s Story — Current Project State

This document records **what is actually implemented now** in the current Prototype 0.2 build.

It is intentionally a runtime snapshot rather than a second design specification. Use it to understand the current playable systems, temporary development deviations, and major missing pieces. Exact ownership by file belongs in `project-map.md`; fragile cross-system contracts belong in `dependencies.md`; intended final behaviour belongs in the Prototype 0.2 Scope.

## Current development focus

The current build already contains a working autonomous early-game loop across quests, travel, events, economy, equipment, dungeons, personality, God influence, and a developer UI.

The most recent gameplay-content work expanded the Starting Region temporary-event population to **fifteen handcrafted events**. The pool now mixes combat and non-combat stories, stat-driven Formative branches, broad use of all eight established trait sides, partial-HP preparation fights, real event-owned secondary-map detours, Gold and ilvl 5/10 equipment rewards, and branch-specific successful-event Diary passages. The **Hero Diary / Chronicle** first slice also remains live: ordinary quest selection/completion are recorded, and combat death now records the real killer plus the owning quest, dungeon, or temporary event. Further diary work is content/coverage expansion rather than a redesign of the simulation.

The larger Prototype 0.2 world is still incomplete: only the Starting City is a full economy/dungeon/event gameplay context, its Starting Region now contains fifteen handcrafted temporary events while Mid Region event content is still absent, only the two Starting Region ordinary dungeons are authored, first specialization is not implemented, while two-slot save/load is now connected. Arden now has a live ordinary-quest slice: **26 ordinary Mid Region mob definitions numbered 0101–0126** on a deliberately non-linear approximately **300→900 Power** curve plus **26 matching local quest templates** on its own Mid Region 4/4/4 rotating board.

## Start menu and persistent saves

Startup offers New Game and Continue (enabled when a readable save candidate exists). New Game opens the questionnaire and class selection first; completing class selection asks before replacing an existing autosave. Cancellation stays on class selection without writing. The manual slot is preserved. No simulation exists before creation is accepted.

The running game menu exposes Save, Load and Return to Game and pauses simulation. Save writes one manual slot with overwrite confirmation. Load offers independent Manual/Autosave slots with hero, level and timestamp, then asks before discarding current progress. Continue tries newest candidates first. Loading binds a new MainUI to a detached restored simulation; invalid snapshots leave the running game intact. No offline time is applied.

Initial creation, ten real minutes, normal close and increased completed-dungeon count trigger autosaves. Specialization is not implemented, so its milestone is not connected yet. Normal-close write failure leaves the game open and paused with an error. Files have integrity checks, verified temporary writes and prior-copy backups; save timestamps increase across both slots. Tests use isolated project `.godot/` directories, never player slots. Focused tests: `test_save_store.gd`, `test_save_ui.gd`, `test_save_confirmations.gd`, `test_save_close_probe.gd`, `test_simulation_snapshot.gd`, `test_snapshot_validation.gd`, `test_snapshot_scenarios.gd`, `test_save_dungeon_milestone.gd`.

Snapshot restoration rejects missing/unknown serialized properties, malformed containers/references/RNG and incompatible property types. Typed arrays are reconstructed explicitly, preserving Diary/Log entries and questionnaire answers rather than silently retaining empty defaults. Event instances receive a valid construction resource before saved state is hydrated. Regression scenarios compare the complete captured graph immediately after load and after identical dungeon combat, event completion and death-to-recovery continuation. A real completed-dungeon fixture verifies one restorable milestone autosave. This is targeted persistence coverage, not full long-run Prototype 0.2 validation.

## Main-screen surface polish

The main gameplay screen uses a muted dark blue-gray background (#191e26), retaining opaque #232830 panel fills. Hero summary, God panel, opponent and combat-statistics cards have one-pixel #495462 borders and reduced shadows; the narrative outer border matches, with its old content inset preserved. Tick text is lightened for contrast. Positions, sizes, content, controls and gameplay remain unchanged. Secondary screens retain their previous light background and styling; startup and mini-window appearance are unchanged. Focused coverage: `tests/test_main_screen_surface_style.gd`.

## Compact opponent card

The opponent panel is now 320×280 at (1014, 80), with a wrapping name, live numeric HP bar and the same five combat indicators. Outside combat only the no-combat caption remains. Combat statistics at (1014, 380), 320×220 show overall totals summed from the existing per-mob counters, followed by the selected enemy results. Both include fights, wins, losses and win percentage (zero-safe). Opponent HP reuses the hero resource-bar and numeric-label builders for identical borderless styling. No combat rules or statistics collection changed. Coverage: `tests/test_opponent_card.gd`.

## Narrative reading area

Log and Diary body text now uses 15px instead of 16px; tab-title size is unchanged. Their shared panel is expanded to (371, 368), 624×326, using the free center-column margins while keeping at least 20px above the speed controls. The other panels and tick strip stay in place. Wrapping, read-only behavior, tab switching and automatic scrolling to new entries are unchanged.

## Divine-panel presentation

Within the unchanged (423, 80), 544×235 God panel, title and numeric energy share a header, followed by a slimmer energy bar, an actions heading and the existing four buttons. Button titles remain primary; each button has a smaller mouse-ignoring ActionDetail label for the same cost/cooldown/fights/no-target text. Idle help is muted, while active blessing status uses a warm accent. Disabled conditions, costs and callbacks are unchanged.

## Unified main-screen buttons and tabs

Top navigation, the mini-mode entry button, divine-action buttons, speed controls and Log/Diary tabs share muted blue-gray fills, one-pixel borders, six-pixel corners and no drop shadows. Selected speed/tab/navigation entries use the same blue accent; hover-pressed and transparent keyboard-focus overlays preserve selection visibility. Disabled text is more legible while gameplay availability rules remain unchanged. Existing button margins/font sizes and screen geometry are retained. Mini-window Expand, setup screens and secondary-screen local controls keep their previous styles.

## Structured main-screen hero card

The left card now groups the same live data rather than displaying one flat text block: prominent name, class/traits, level with the pending-point plus, gold, numeric HP/XP progress bars, separate activity and quest lines, then aligned attribute/combat values, resistances, conditional bonuses and Seed. Its position (32, 80) and width 320 are retained; height is fixed at 640. Only the lower detail area scrolls when long states or bonuses reduce available space. No prior hero information was removed. Other panels, navigation and simulation rules are unchanged.

## Mini-window mode (approved out-of-scope slice)

The in-game **МИНИ-ОКНО** button switches the application to a fixed 240×40, borderless, always-on-top native window. Its client area contains one 16px status label with a black outline and a 28×28 expand-icon button on the right (tooltip: **Развернуть**). A small red, black-outlined + immediately left of Expand appears while pending_primary_attribute_points > 0 and disappears when none remain; it is only an indicator, not an allocation button. The 240×40 size is unchanged. The same Simulation continues at the selected speed; no HP, alerts or gameplay controls are shown. Status groups are Делает квест / В городе / Восстанавливается / Переезжает / Возвращается (normal dark text), Идёт в данж / В событии (yellow), В данже / В бою / Данж: бой / Событие: бой (orange), and Мёртв (red). Death takes priority; combat labels require a live CombatSession and its actual owner. At ×0 the activity stays visible, with no Pause label. Expand restores the previous UI screen and window geometry/mode/constraints/stretch/topmost state. Drag the blank background to move the mini window using native OS dragging. Its last position is remembered independently of the normal window for this MainUI lifetime (not saved across application restarts). Expand restores the original OS frame; ordinary OS minimization remains separate from mini mode. Available after character creation, not on setup screens.

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

The Warrior also has an inherent **10% Fire / 10% Cold / 10% Lightning Resistance** baseline before equipment. Equipment Resistance adds on top of these base values and the normal 75% per-element combat cap still applies.

XP progression is functional, excess XP carries over, and a mid-quest level-up refreshes the hero's resolved persistent combat stats before later fights. The current progression curve starts at **500 XP for Level 1 → 2**; the next requirement increases are **+500 / +600 / +700**, then **+800 per level through the Level-13 requirement**, and **+1000 per level after Level 13**. Current control points are 500 XP at Level 1, 3100 at Level 5, 9500 at Level 13, 10500 at Level 14, and 24500 at Level 28.

The lightweight starting questionnaire is live in the normal new-game entry flow. All four questions are shown together in a compact debug screen with visible bonuses; one answer per question is required. The first Next opens the childhood-friend loss/training story and four class options: Warrior is selectable; Archer, Mage and Assassin are visibly unavailable. The second Next creates the Warrior simulation and opens the existing game UI. No simulation/world time exists before that point.

Family grants one point in STR / DEX / CON / INT / WIS without a personality shift. Childhood grants 20 toward Brave / Noble / Greedy / Curious. Youth and departure each grant one point in STR / DEX / CON / INT and 10 toward one of the opposite sides (Cautious / Devious / Generous / Conservative). Every path therefore grants exactly three assigned attribute points, not a free allocation pool. Opposing shifts cancel; no starting axis exceeds 20 in magnitude. Answers are applied once, recorded on HeroState, and current HP starts at the resolved full MaxHP. Separate question pages and non-Warrior class mechanics remain unimplemented. The friend in the childhood/departure text is named Илья. The Starting City is now named **Дорнвальд**. For normal background-created games, creation at tick 0 immediately records arrival in Дорнвальд in Diary/Debug Log and enters VISITING_GUILD; tick 1 resumes real autonomous quest selection. No world time is advanced to display the introduction. There is no separate intra-city hex route or simulated training period.

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

Normal new games use questionnaire-driven hidden biases without any established starting trait. The previous seeded roll of 1–2 established traits at ±40 remains only for direct legacy/headless Simulation construction without background answers; the normal startup flow never uses that fallback.

Personality is already used by real gameplay:

- ordinary quest Hard Filter risk windows are standard 55–95% MobPower/HeroPower, Brave 60–100%, and Cautious 50–90%;
- current QuestScore also uses established Courage, Morality, and Greed influences;
- Noble deals the existing +10% conditional damage to Monster-category enemies;
- Devious deals the existing +10% conditional damage to Humanoid-category enemies;
- established Curious makes the hero prefer affordable Skill Level training before meaningful equipment, while established Conservative reverses that order; a neutral Curiosity axis keeps the Warrior default of Skill Level first;
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

Current ordinary mobs mostly use physical attacks. Arden now contains eight ordinary elemental attackers: Fire Salamander, Storm Shaman, Ice Monitor Lizard, Battle Mage Mercenary, Orc Shaman, Fire Elemental, Storm Lizard, and Ice Elemental. Their real raw Attack is temporarily tuned 20% below the previously approved physical-profile value, while the shared Power estimate values elemental offense at ×1.20 inside its EffectiveDPS term. This Power weight does not increase actual combat damage. Fire/Cold/Lightning ignore Armor, retain normal Accuracy/Dodge/Crit/Block interaction, and are reduced by the matching direct-percentage Resistance up to the 75% cap.

### Rage

- each fight starts at 0 Rage;
- successful normal hits generate Rage;
- critical normal hits generate more;
- receiving a hit generates Rage even when Block reduces it;
- avoided incoming attacks generate none;
- Rage is capped at 100 and is discarded when the fight ends.

### Power Strike

- learned automatically at compressed hero Level 5;
- learned at Skill Level 1; combat supports Skill Levels 1–10 and unlocked higher ranks can now be bought in the post-market city routine;
- autonomous use when its Rage/cooldown conditions are satisfied;
- replaces the next normal attack opportunity;
- cannot miss but may critically hit;
- Skill Level scales the base multiplier evenly from ×1.50 at Skill Level 1 to ×2.50 at Skill Level 10;
- scales with WIS separately through its ability-specific formula.

### Battle Guard

- learned automatically at compressed hero Level 10;
- learned at Skill Level 1; combat supports Skill Levels 1–10 and unlocked higher ranks can now be bought in the post-market city routine;
- autonomous defensive activation after HP falls to the current threshold;
- no Rage cost and no shield requirement;
- lasts 10 seconds with a 60-second cooldown;
- applies after ordinary Block/Armor/Resistance resolution;
- Skill Level scales base remaining-damage reduction evenly from 25% at Skill Level 1 to 45% at Skill Level 10;
- scales with WIS separately through its own ability-specific formula.

The approved working Skill Level cost curve starts at 500 Gold for Skill Level 2 and increases by 30% per next rank, rounded to the nearest 50 Gold: 500 / 650 / 850 / 1100 / 1450 / 1900 / 2450 / 3200 / 4150 Gold for Skill Levels 2–10. Autonomous city training is live after the market-sale step and shares one optional-development budget with meaningful equipment after required dungeon preparation is protected. Established Curious buys an affordable unlocked Skill Level before optional equipment; established Conservative buys meaningful affordable equipment first; neutral uses the Warrior default of Skill Level first. The lower-priority category is still allowed on a later tick, and if the preferred category has no valid affordable purchase the same tick falls through to the other category without adding an empty delay. Every successful rank or equipment purchase still consumes its own shopping world tick. Protector/Slayer specialization abilities are not implemented yet.

Current runtime rank availability uses the working five-level cadence exactly: Power Strike unlocks SL2 / SL3 / SL4 at hero levels 10 / 15 / 20, while Battle Guard unlocks SL2 / SL3 / SL4 at hero levels 15 / 20 / 25, continuing by the same interval up to Skill Level 10.

## Death and resurrection

Ordinary quest death is functional rather than a developer-error path.

On ordinary quest combat death:

- current HP becomes 0;
- the current quest is cancelled;
- no XP is granted for the killing mob;
- no quest-completion Gold is granted;
- XP/levels already earned earlier remain;
- the hero returns to the safe center of the authoritative current city (Дорнвальд or Арден);
- natural resurrection waits exactly **100 world ticks**;
- resurrection returns the hero at exactly **1 HP**;
- city recovery restores 20% MaxHP per world tick;
- the hero does not resume normal activity until fully recovered.

Dungeon and temporary-event deaths use the same `HeroRecovery` rules as ordinary quests through their current owning runner; timers, activity context and result reporting remain runner-owned. Gameplay timing and recovery values are unchanged.

The full generalized `QuestLoot` / unsafe-adventure-loot model is not implemented yet. Ordinary quest equipment now has the narrow post-objective review buffer described below: unreviewed equipment is not permanent and is discarded on quest combat death, while the broader trophy/backpack and post-review unsafe-carried-loot rules remain future work.

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

City-to-city autonomous relocation now has its first Prototype 0.2 implementation. The two authored city names are **Дорнвальд** (Starting City) and **Арден** (Mid-Level City). The current temporary trigger is deliberately simple: once the autonomous hero has reached **Level 13**, the next safe Дорнвальд decision point after the current activity/city shopping starts a real `TravelSystem` route to Арден's center. The move does not interrupt an active quest, dungeon, event, return trip, market sale, or successful shopping purchase. Дорнвальд remains the authoritative current city until physical arrival. On the arrival tick `HeroState.current_city_id` changes to Арден, the active ordinary `QuestPool` switches to the Mid Region local content/placement context, and a single one-time Diary entry describes the larger regional center and the pressure on its garrison. On the following world tick the hero enters `VISITING_GUILD`; the next normal tick may select an Arden quest from the local board. This fixed Level-13 rule is a Prototype 0.2 simplification; a richer long-term-goal-driven relocation model is deferred.

## Ordinary quests and quest board

The Starting City currently has:

- **22 ordinary mob definitions** on the current approximately 25→320 Power progression;
- **22 matching ordinary quest templates**;
- explicit 8 lower / 7 middle / 7 higher strength-band membership;
- authored real map-placement constraints for every current quest;
- runtime `QuestOffer` instances with concrete rolled enemy count, reward, target hex, and real route distance.

Arden currently has:

- **26 ordinary Mid Region mob definitions** numbered `0101`–`0126`, approximately 300→900 Power;
- **26 matching ordinary quest templates**, split 9 lower / 8 middle / 9 higher;
- ordinary target placement constrained to **3–7 hexes** from Arden across plains, forest, hills, and selected road-tagged locations;
- the same up-to-12 **4 / 4 / 4** rotating-board lifecycle as Дорнвальд, but with its own deterministic board/placement RNG streams and Mid Region reservations;
- ordinary quest return/death routing through Arden's real city center, including natural resurrection/recovery and subsequent local quest selection;
- first five transition mobs retaining the existing ilvl 10 ordinary equipment source; later Arden equipment-drop tiers remain pending the actual ilvl 15/20/25 item/drop content.

The Arden mobs currently grant authored XP from **240 to 720** across the roster. Eight ordinary Arden mobs now use authored Fire / Cold / Lightning basic attacks; those attacks use the normal hit/crit/block path, ignore Armor, and are reduced by the matching direct-percent Resistance capped at 75%. Their raw Attack is temporarily 20% lower than the original physical baseline, while elemental offense is valued at ×1.20 inside the shared Power estimate only.

Ordinary quest selection is autonomous and uses the current dedicated flow:

> Hard Filter → QuestScore → highest valid quest → `QuestRunner` execution

`QuestRunner` executes only the already selected quest. Quest selection, scoring, combat resolution, item generation, diary prose, God rules, and UI remain outside it.

### Current quest-board tuning

The current working Prototype 0.2 board cap is **up to 12 offers total, with up to 4 offers per strength band**. This 4 / 4 / 4 composition is an explicit tuning step before Mid-Level City relocation testing and may be adjusted again after playtesting.

Current runtime behaviour:

- each shared board roll selects up to 4 different currently eligible templates from each strength band;
- missing slots in one band are not filled from another band;
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
→ if at least one equipment item dropped: one world tick to review all found equipment
→ real return travel
→ turn in for Gold
→ dedicated market/sale tick
→ Curious/neutral: Skill Level first; Conservative: meaningful equipment first
→ fall through to the other category when the preferred category has no valid affordable purchase
	→ one successful Skill Level or equipment purchase per shopping tick
	→ if Level 13 has been reached: begin real relocation to Mid-Level City
	→ otherwise evaluate known local dungeon readiness
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

The generic temporary-event system is live and currently has **15 authored Starting Region events**:

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
13. `Спор у межевого камня`;
14. `Лекарство до заката`;
15. `Сигнал из старого карьера`.

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

Events 14–15 were added specifically to balance underused event inputs. Before them, CON appeared in 8 of 13 event Formative openings and STR in 9, while DEX/WIS each appeared in 11; Cautious and Generous each had only one event that read them Expressively. Both new events therefore use a two-way **CON / STR** Formative comparison. `Лекарство до заката` moves to a real off-road secondary camp and gives Generous a costly selfless outcome; its CON action can move Greed `+5` and establish Generous for that same destination check. `Сигнал из старого карьера` travels to a real farther hill objective and then returns to the encounter point; its CON action moves Courage `−5`, and established Cautious spends extra time to rescue the trapped worker without fighting the Cave Lizard, while a non-Cautious hero fights the normal shared enemy instead. After these additions, event-level Formative participation is CON 10 / STR 11 / DEX 11 / WIS 11, while Cautious and Generous each appear in two event concepts.

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

Jewelry/Belt content exists for compressed ilvl 5 and ilvl 10. Jewelry starts at ilvl 5 rather than ilvl 1. Current jewelry base Resistance tuning is 10 / 12 / 15 / 18 / 22 / 26% for ilvl 5 / 10 / 15 / 20 / 25 / 30, with future balancing targets of 30% at ilvl 35 and 35% at ilvl 40. The current first three equipment progression control points are therefore live at ilvl 1 / 5 / 10; later 15 / 20 / 25 / 30 content is not yet built out.

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

During an ordinary quest, a successful equipment-drop roll now creates the concrete generated `ItemInstance` at the defeated mob, but does **not** immediately evaluate/equip it. Found quest equipment waits in the current adventure buffer until the main mob objective is complete. Before return travel, if at least one equipment item was found, the hero spends exactly **one world tick** reviewing the entire accumulated equipment batch through the existing `EquipmentEvaluator` / Equipment / Inventory routing. The review costs one tick regardless of item count; if no equipment dropped, the extra phase is skipped completely. A quest combat death clears still-unreviewed equipment rather than allowing it to leak into a later quest.

The current Inventory keeps up to **36 unequipped equipment items** in FIFO order. Healing potions are stored separately from that equipment capacity.

This is the first **equipment-only** slice of the intended `QuestLoot` flow, not the complete future backpack system. General trophies, broader carried-adventure-loot representation/UI and the rest of the final QuestLoot model are still not implemented.

## Economy, shop, Belt and potions

The two normal cities now have separate functional equipment shops. Дорнвальд keeps three progression bands:

- ilvl 1;
- compressed ilvl 5;
- compressed ilvl 10.

Each Дорнвальд band currently rolls 6 White + 2 Green distinct-slot equipment listings, for up to **24 equipment listings** when fully stocked.

Physical arrival in Арден replaces the active shop with its city-local ilvl 15/20/25 stock. The ilvl 15 Azure Dawnplate band uses the ten currently supplied armor/accessory slots and rolls 6 White + 2 Green listings. The ilvl 20 Crimson Thornplate and ilvl 25 Gilded Wyrm bands currently have only the five supplied armor slots and each rolls all 5 White + 2 Green listings, for **22 Arden equipment listings** in total. No missing weapons, shields, accessories, overlays or mob-drop sources are synthesized: Azure ilvl 15 armor has the supplied paper-doll overlays, while jewelry and ilvl 20/25 armor are icon-only until their own assets exist.

Current White / Green reference prices are:

- ilvl 10: 900 / 2700 Gold;
- ilvl 15: 1350 / 4050 Gold;
- ilvl 20: 2300 / 6900 Gold;
- ilvl 25: 3600 / 10800 Gold.

The earlier ilvl 1 and compressed ilvl 5 prices remain 100 / 300 and 500 / 1500 Gold. Green remains exactly three times White, and ordinary resale remains 10% of the reference value.

Current shop behaviour:

- stock refreshes deterministically every **200 world ticks**;
- purchased positions remain empty until the next refresh;
- successful ordinary quest turn-in schedules a separate market/sale tick;
- unequipped priced ordinary equipment is automatically sold on that market tick;
- `SHOPPING` uses established Curious/Conservative personality to choose whether Skill Level training or meaningful equipment is evaluated first; neutral defaults to Skill Level first;
- the lower-priority category remains valid and is checked on the same tick when the preferred category has no affordable valid purchase;
- one successful rank or equipment purchase consumes one full shopping world tick; another purchase must wait for the next tick;
- Gold required for a feasible Power-ready dungeon potion loadout is protected from both Skill Level training and optional equipment spending;
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

Both current city shops expose the same two live potion tiers:

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
- a compact Skills panel showing the current Power Strike and Battle Guard Skill Levels (or that the ability is not learned yet);
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

- both current city-local ordinary quest boards use the working 4/4/4 cap (up to 12 offers total per active local board); this remains a balance value to validate in playtesting;
- the current ordinary quest completion cooldown is 50 world ticks;
- direct legacy/headless Simulation construction without background answers retains 1–2 seeded established traits; normal new games use the questionnaire;
- `Simulation.new()` retains a fixed-Goblin compatibility path for older tests, while the real developer UI passes `null` to enable autonomous quest selection;
- abstract legacy quest-distance fields still exist for old fixed tests/offers, but current real gameplay uses map targets and route length;
- ordinary quest equipment now waits safely outside permanent Equipment/Inventory until the post-objective review tick, but the broader final `QuestLoot` / trophy/backpack model is still incomplete;
- current normal attacks/content are effectively physical even though elemental mitigation exists; the new Arden mob roster is also intentionally physical-only for now, with selected enemies intended to receive Fire / Cold / Lightning attacks in a later targeted pass;
- Arden's ordinary quest context is live, but its dedicated equipment shop / later item tiers, potions, local events and ordinary dungeons are not; after an Arden quest the current interim city routine allows normal sale and unlocked Skill Level training but deliberately does not buy from Дорнвальд's equipment stock;
- unknown dungeons are intentionally partially visible in the current developer Map view for testing; this is not the final hidden-information presentation;
- the UI is a developer build and may expose hidden values that the eventual player UI must not expose.

## Major Prototype 0.2 pieces still missing

The most important incomplete areas are:

- separate question pages and playable non-Warrior classes (the debug questionnaire and four-option class screen are live);
- Mid-Level City as a complete economy/dungeon/event gameplay context beyond its now-live ordinary quest loop;
- Arden equipment-shop / ilvl 15/20/25 item and potion progression;
- the remaining temporary-event population toward the 15–20 target;
- two Mid Region ordinary dungeons;
- first Warrior specialization: Protector / Slayer direction, specialization quest, specialization dungeon, specialization rewards and abilities;
- later equipment/potion progression content beyond the currently live Starting City tiers;
- two-handed / complete legal hand-configuration content breadth;
- full QuestLoot / unsafe carried-adventure-loot model beyond the current equipment-only review slice;
- player-facing ordinary quest-guidance selection UI;
- full Hero Diary coverage and episode grouping;
- player-facing Explanatory Log;
- finished player-facing screens/presentation;
- long-run Prototype 0.2 balance/soak validation through the intended approximately level-25–30 progression.

When this document conflicts with current code or a more recently approved design change, verify the repository and the Prototype 0.2 Scope rather than restoring older behaviour from historical chats.
