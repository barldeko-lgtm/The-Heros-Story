# The Hero’s Story — Current Project State

This document describes what is **actually implemented now**.

## Current development focus

The project is building the first authored Prototype 0.2 world-map slice. Ordinary quest-board placement/travel and the first dungeon placement/discovery/travel/combat/retry-readiness slice are now map-backed; potion preparation, dungeon completion rewards, temporary travel events, and city relocation remain unintegrated.

Implemented:
- one autonomous hero;
- Prototype 0.2 Warrior primary attributes and current pre-specialization level-up growth;
- world tick;
- pause and developer speed controls (×0, ×1, ×2, ×5, ×10, ×20, ×100);
- one shared seeded RNG for current simulation randomness;
- one shared Power calculation for hero and mobs;
- live one-on-one combat with timed strikes;
- fight-local Warrior Rage plus the autonomous Level 10 Power Strike and Level 20 Battle Guard at Skill Level 1;
- per-mob XP and post-fight recovery;
- death, 100-tick natural resurrection, and city recovery;
- fifteen initial-city mob definitions, from Goblin through Forest Troll, Cave Lizard, Mountain Beast, and Orc Raider;
- fifteen matching initial-city quest templates;
- two seven-piece visual equipment families, each with five armor pieces plus sword and shield and Common/Uncommon/Rare definitions: `Авангард Железного Оплота` (`Ironward Vanguard`) and `Страж Железного Следа` (`Ironwake Sentinel`);
- two source-driven equipment-drop tables with the same 5% drop chance, equal seven-slot roll, and Common/Uncommon/Rare distribution of 70%/25%/5%: the six weakest current mobs use Ironwake Sentinel at ilvl 1, while the other nine use Ironward Vanguard at ilvl 10;
- virtual-equip comparison by real base HeroPower plus a 36-slot FIFO inventory for unequipped drops before city sale;
- a Starting City equipment shop with a dedicated ilvl 1 Ironwake Sentinel band and ilvl 10 Ironward Vanguard band, each containing 6 White unique-slot listings and 2 Green unique-slot listings, deterministic 200-world-tick stock refresh, and autonomous one-purchase-per-tick upgrade buying;
- all fifteen current quest templates exposed simultaneously as offers in the single Prototype 0 city;
- autonomous choice among the current quest offers;
- seeded assignment of 1–2 starting personality traits from Coward, Brave, Dishonorable, Noble, and Greedy;
- current personality modifiers in QuestScore (Courage up to ±0.30, Greed up to +0.30, Morality +0.20) and 10% category damage for Noble/Dishonorable;
- headless god-system core with 100 starting energy, world-tick recovery, cooldowns, instant resurrection, divine healing, five-fight Attack buff, one-selection quest guidance, and Divine Vision for revealing an unknown dungeon in the current region;
- a quest execution loop after the selected quest is assigned;
- structured quest/death events;
- separate quest narration;
- debug log;
- empty diary shell;
- rough developer UI;
- one Starting Region dungeon, `Заброшенные железные шахты`, spawned on one deterministic reserved hill hex 4–7 steps from the Starting City center; it begins unknown, is discovered either by Divine Vision or when the hero physically enters its hex, and uses the supplied 440×400 dungeon map sprite at 65 px draw height; the current developer map intentionally renders an unknown dungeon at 40% opacity while keeping its name hidden until discovery;
- the first dungeon definition authors exactly three ordinary encounters using the same `Шахтный троглодит` (~200 Power, 150 XP) followed by the unique boss `Глубинный пожиратель` (~300 Power, 185 XP); discovery does not interrupt the hero's current activity, and after the current quest is turned in and the normal market/shopping routine finishes a known local dungeon is considered before another ordinary quest only if its current readiness check passes; `DungeonRunner` sends the hero along the real `TravelSystem` route and then executes the authored 3+boss sequence through the same live `CombatSession` used by quests; current HP carries between encounters, each ordinary victory creates exactly one world tick of between-fight preparation with no healing in the current no-potion slice, the boss follows after the third such preparation tick, ordinary/boss combat grants XP but no ordinary equipment drop or per-mob Gold, boss victory marks the runtime dungeon completed, and dungeon death returns the hero to the city with the normal 100-tick resurrection/city-recovery flow; every failed attempt now remembers the HeroPower recorded when that attempt began and the reached progress, and later post-shopping dungeon decisions are blocked until Power reaches the current retry gate: +25% if no ordinary enemy was killed, +15% after ordinary progress before the boss, or +10% after reaching the boss; a new failed retry replaces the baseline with that retry's own starting HeroPower; potion readiness and completion Gold/item rewards are not implemented yet;
- a 20 × 15 exact-color PNG-driven hex world foundation where all 300 cells become `HexDefinition` objects with logical coordinates, terrain, city-region ownership, and permanent semantic tags; current tags are `city` on all 14 city hexes, `city_center` on the two city centers, and `road` on the authored ordered road path, with ordinary untagged cells allowed; each city region extends up to seven hex steps from its city center, overlapping candidates belong to the nearer city, four equal-distance boundary hexes are split left/right 2/2, and the resulting current map contains 124 Starting Region hexes, 124 Mid Region hexes, and 52 peripheral hexes with no region; `HexMap` can return complete radius areas around a center, `WorldState` can atomically reserve/release map hexes for active activities with a strict one-activity-per-hex rule, `ActivityPlacementFinder` can filter valid activity centers, and `TravelSystem` now owns deterministic multi-tick hero movement along `HexMap` routes at exactly one adjacent hex per world tick; ordinary selected quests travel from the Starting City center to their real `QuestOffer.target_hex` and return to the city center after completion; plains/forest/hill cells render from three authored 158 × 140 RGBA sprite variants per biome, road cells temporarily reuse plains sprites under the existing road line, both seven-hex city clusters use the same authored 418 × 440 RGBA `town1.png` overlay at native size, and the current hero map visual uses the supplied high-resolution sprite scaled only at draw time to 120 px tall while following the live `WorldState.hero_position`; the map also has one-pixel black hex outlines on non-city cells, runtime route/distance queries, an interactive debug tooltip that shows coordinates, terrain, region, and tags, mouse-wheel zoom, and right-button drag panning;
- automated regression tests and GitHub CI.

Current next major gameplay step:
- continue the first ordinary-dungeon vertical slice from its working sequential combat + Power retry-readiness loop into Belt/potion preparation/use and completion rewards.

Still missing from the current build:
- diary episodes;
- player-facing quest-guidance selection UI;
- Belt/potion preparation/use, the remaining potion side of dungeon readiness, and completion Gold/item rewards beyond the current first-dungeon placement/discovery/post-quest-priority/travel/3+boss combat/+25%/+15%/+10% Power retry slice;
- travel interruption/resumption, temporary events, and city-to-city relocation on the new map.

## God-system core

`scripts/god/god_state.gd` owns 100 maximum/starting energy, +1 energy per 6 world ticks, ability cooldowns, and one pending guided quest id. `scripts/god/god_system.gd` validates and applies the current divine commands through the state owners they affect. The active five-fight blessing itself lives in `HeroState.active_effects` as a real stat source.

`Simulation` retains compatible public wrappers for the currently implemented divine commands so UI does not depend directly on God-system internals:
- instant resurrection at `RemainingRespawnTicks × 0.5` energy;
- divine healing for 10 energy, +50% MaxHP, 30-tick cooldown;
- combat buff for 10 energy, +15% resolved Physical Damage for the next 5 fights, 120-tick cooldown;
- quest guidance for 5 energy, +0.20 DivineModifier for one next selection, 360-tick cooldown;
- Divine Vision for 80 energy and a 1500-world-tick cooldown, revealing one random existing unknown dungeon in the hero's current region.

The center-top god panel now displays energy and provides working buttons for healing, combat blessing, instant resurrection, and Divine Vision. Healing can modify live CombatSession HP during a fight. Quest guidance remains headless-only until its selection UI is approved.

## World time

`scripts/core/world_clock.gd` owns the current world tick.

Current behaviour:
- 1 world tick = 10 simulation seconds;
- partial tick progress is retained;
- one update may complete multiple ticks;
- `Simulation` applies the selected time scale before advancing the clock;
- time scale `0` pauses world-tick progress without resetting partial progress;
- an active combat session freezes world-tick progress; the selected time scale accelerates its internal seconds too;
- natural resurrection uses the same world-tick timeline and therefore respects pause and developer speed controls.

Current UI exposes ×0, ×1, ×2, ×5, ×10, ×20, ×100.

## Hero and stats

`scripts/hero/hero_state.gd` stores mutable hero state, including the current loop state.

Current loop states include:
- `CHOOSING_QUEST`;
- `TRAVEL_TO_QUEST`;
- `DOING_QUEST`;
- `RECOVERING_AFTER_FIGHT`;
- `RETURNING_TO_CITY`;
- `TURNING_IN_QUEST`;
- `VISITING_MARKET`;
- `SHOPPING`;
- `TRAVEL_TO_DUNGEON`;
- `AT_DUNGEON_ENTRANCE`;
- `DOING_DUNGEON`;
- `DUNGEON_BETWEEN_FIGHTS`;
- `DUNGEON_COMPLETED`;
- `DEAD_RESPAWNING`;
- `RECOVERING_IN_CITY`.

`scripts/hero/hero_progression.gd` owns XP application and Warrior level growth.

The Warrior now starts with five symmetrical primary attributes:
- STR = 5;
- DEX = 5;
- INT = 5;
- CON = 5;
- WIS = 5.

Current primary-attribute contributions are centralized in `StatResolver`:
- 1 STR = +2 physical Damage and +5 percentage points Critical Damage;
- 1 DEX = +10 Accuracy, +2 Dodge, and +3 percentage points Critical Chance;
- 1 CON = +20 MaxHP and +1 Armor;
- INT and WIS are stored as real primary attributes and still provide no generic resolved CombatStats bonus; WIS now scales Power Strike and Battle Guard through their ability-specific formulas.

Until deity-guided attribute direction and personality-directed adaptive growth are implemented, each level currently grants only the agreed non-divine default growth:
- +2 STR;
- +1 DEX;
- +1 CON.

The not-yet-implemented fifth deity-guided point is neither assigned nor stored.

The unchanged XP rules remain:
- the next-level requirement starts at 1000 XP and increases by 500 per current level (`1000, 1500, 2000, ...`);
- carries excess XP forward;

Final combat stats remain:

```text
HeroState + HeroProgression + Equipment
→ StatResolver
→ CombatStats
```

`StatResolver` now produces:
- stable `BaseCombatStats` for primary UI values, HeroPower, and Hard Filter;
- effective `CombatStats` including active temporary effects for actual combat.

Persistent equipment contributes to both views. Ironwake Sentinel drops are generated as ilvl 1 `ItemInstance` objects: armor receives 5 inherent Armor, the sword receives 10 inherent Damage and +0.10 Attack Speed, and the shield receives 10 inherent Block. Ironward Vanguard remains ilvl 10 with 7 Armor, 13 sword Damage/+0.10 Attack Speed, and 13 shield Block. These base stats remain the same across Common, Uncommon, and Rare. Serialized fixed stat fields on older visual definitions are not runtime stat sources.

Common items have no random affix, Uncommon items have one, and Rare items have two unique affixes. The ilvl 1/10 Green affix budgets are 60/78. Rare affixes each use 85% of the matching Green budget. One seeded item-wide roll varies total modifier budget from 95% to 105%, after which the result is split equally between all affixes. Affix values use the current centralized stat-cost table from Scope 19.5, including Block at 13 budget per point. Generated equipment uses secondary stats only.

`ItemInstance` now owns Item Level, rarity, inherent stats, rolled total budget, affixes, resolved item stats, tooltip text, and dynamic ItemPower. ItemPower applies the complete generated contribution to the approved fixed reference profile and uses the shared `PowerCalculator`. `Equipment` and `StatResolver` consume the generated instance values for Health, Armor, Dodge, Accuracy, Damage, Attack Speed, Critical stats, Resistances, and Block.

Every generated candidate is now evaluated through virtual equip before routing. `EquipmentEvaluator` compares the hero's full base persistent HeroPower with the current loadout against a copied loadout containing the candidate. Any rarity, including the same rarity as the equipped item, replaces it only when candidate HeroPower is strictly higher. Equal or weaker candidates enter Inventory. Temporary divine effects are excluded, displayed ItemPower is not used as the decision rule, and evaluation does not mutate live equipment.

Current equipment reference prices are centralized for ilvl 1/10/20. White uses 100/500/1000 Gold, Green uses ×3, and the currently approved Rare reference uses ×9; sale value is 10% of reference price. Current ilvl 1 White/Green/Rare items sell for 10/30/90 Gold, while ilvl 10 equivalents sell for 50/150/450 Gold. Successful quest turn-in enters `VISITING_MARKET`. On the following dedicated world tick, every unequipped ordinary item in Inventory is sold, removed, and converted into Gold, then the hero enters `SHOPPING`. Each later shopping world tick can buy at most one equipment item. A candidate must be affordable, meet the current +20% ItemPower threshold against the equipped comparison item, and improve the hero through the real virtual-equip HeroPower evaluation. Among valid candidates the hero chooses the largest real HeroPower gain. Purchased stock positions remain empty until refresh; replaced equipped gear is sold immediately for its normal resale value instead of entering Inventory. When no further valid purchase exists, the hero normally returns to `CHOOSING_QUEST`; if a local dungeon is known, `DungeonEvaluator` first checks its current retry readiness. A first attempt may start immediately, while a dungeon with failed-attempt memory starts only when current HeroPower reaches the remembered +25% / +15% / +10% threshold; otherwise the hero returns to ordinary quest progression. Dungeon discovery still never interrupts an activity already in progress. Death and other events do not trigger sale. Item tooltips show both reference shop value and sell price.

The Starting City shop uses two authored stock-band resources: ilvl 1 Ironwake Sentinel and ilvl 10 Ironward Vanguard. Each band samples six distinct White slots and two distinct Green slots from the seven current armor/weapon/shield slots, for 16 listings when fully stocked. Concrete stats, affix budgets, rarity behavior, ItemPower, and prices still come from shared item-generation/economy data. Green listings use the normal generated-affix pipeline. The shop uses a deterministic RNG stream derived from the simulation seed so shop rotation remains reproducible without perturbing the existing main simulation RNG sequence. Full stock refresh occurs at world ticks 200, 400, 600, and so on regardless of where the hero is. Before each shopping decision tick, the developer debug log prints one compact assortment summary by rarity and readable slot name without dumping item stats.

The divine `+15% resolved Physical Damage` is displayed separately and does not alter base HeroPower. Noble/Dishonorable conditional +10% damage is also displayed separately and remains excluded from HeroPower because quest preference already has its own MoralityModifier.

After a mid-quest level-up, `Simulation` refreshes `CombatStats` before recovery and the next fight.

## Combat

`scripts/combat/combat_session.gd` resolves one live hero-versus-mob duel using final `CombatStats`.

Current behaviour:
- each side attacks on its own `2 / AttackSpeed` interval;
- the hero’s first attack has a 0.5-second opening advantage;
- same-timestamp attacks resolve together;
- a simultaneous death counts as hero defeat;
- critical hits retain fractional damage internally;
- Accuracy and Dodge use `Dodge / (Dodge + Accuracy + 100)` with a 50% DodgeChance cap;
- a missed attack deals no damage and cannot crit or trigger Block;
- BlockChance uses `min(Block / (Block + 200), 0.50)` and a successful Block leaves 25% of the hit before mitigation;
- physical damage uses `100 / (100 + Armor)`;
- Fire, Cold, and Lightning use the same resistance curve with non-negative Resistance and a 75% reduction cap;
- current normal attacks are physical; elemental formulas are implemented but no current content deals elemental damage yet;
- every fight starts at 0 Rage and discards it on completion; successful normal hero hits grant 5 Rage, critical normal hits grant 7 instead, received hits grant 3 even when blocked, avoided hits grant none, and Rage is capped at 100;
- reaching hero level 10 learns Power Strike at Skill Level 1; when its 10-second cooldown is ready and at least 30 Rage is available, it automatically replaces the next normal attack opportunity, spends 30 Rage, cannot miss, can still crit, and uses the Scope-approved `1.50 + 2.0 × WisdomFactor` damage multiplier;
- Power Strike actions carry their own structured action id and are named separately in the combat log;
- reaching hero level 20 learns Battle Guard at Skill Level 1; after an incoming hit first leaves the hero at 75% MaxHP or lower, it activates without retroactively reducing that threshold-crossing hit, lasts 10 seconds, has a 60-second cooldown, costs no Rage, requires no shield, and multiplies subsequent already-mitigated incoming damage by `1 - (0.25 + 0.15 × WisdomFactor)`;
- Battle Guard activation carries its own structured action id and is named separately in the combat log;
- all current mob definitions use Dodge = 0; Accuracy remains 100 for the established roster, while the newly approved Orc Raider uses Accuracy = 105;
- each resolved strike enters the debug log immediately while the world clock is frozen.

`PowerCalculator` now uses the one complete Prototype 0.2 formula for both hero and mobs: expected physical DPS with the reference Accuracy factor, effective survivability from the 70/10/10/10 physical/fire/cold/lightning mix, reference Dodge, expected Block mitigation, and `Power = sqrt(EffectiveHP × EffectiveDPS)`.

Victory grants the defeated mob's XP through `HeroProgression`, then starts normal post-fight recovery.

## Death and resurrection

A combat defeat now closes the current quest instead of producing a developer error.

On death:
- current HP is clamped to `0`;
- the current quest is canceled immediately;
- no XP is granted for the mob that defeated the hero;
- no quest turn-in Gold is granted;
- XP and levels earned before the defeat are retained;
- the hero enters `DEAD_RESPAWNING` in the city;
- natural resurrection takes exactly 100 world ticks;
- the debug log reports the remaining resurrection ticks.

After the 100th respawn tick:
- the hero resurrects with exactly **1 HP**;
- enters `RECOVERING_IN_CITY`;
- recovers 20% MaxHP per world tick;
- only after reaching full HP returns to `CHOOSING_QUEST`.

Full unsafe-loot loss is still only a future hook because QuestLoot does not exist yet; current generated equipment drops become permanent immediately.

## Current quest content and selection

Concrete mob values and immutable quest templates live in `data/mobs/` and `data/quests/` and are intentionally treated as tuning data rather than duplicated here. A quest template contains inclusive mob-count and gold-per-mob ranges plus authored map-placement rules: `placement_distance_hex_min/max`, optional allowed terrain ids, optional allowed semantic tags, and forbidden semantic tags. All fifteen current Starting City templates have a 1–7-hex placement band, one terrain-or-tag placement constraint, and `city` forbidden. The old `distance_km_min/max` fields remain only as a temporary compatibility path for fixed legacy tests/offers that do not receive map targets; live autonomous quest selection and travel no longer use that abstract distance as their spatial authority. Templates do not store rolled values, a total Gold reward, concrete target hexes, or equipment rewards. Current ordinary quests reward Gold only.

The developer build loads all `.tres` quest templates from `res://data/quests` into `QuestPool`. With the current single-city content set this means all fifteen templates are present simultaneously. Each runtime `QuestOffer` owns its rolled mob count, compatibility-only legacy abstract distance, gold per mob, concrete `target_hex`, and `map_distance_steps` equal to the actual shortest route length from the Starting City center. `QuestPool` uses a separate deterministic placement RNG stream plus `ActivityPlacementFinder` to choose a valid free target inside Starting Region and reserves that hex through `WorldState`, so all current board offers occupy unique real map cells without perturbing the established quest-roll RNG sequence. `QuestEvaluator` uses `map_distance_steps` for live travel-cost estimation whenever a real target exists.

There is intentionally no 5–7-offer cap in the current one-city Prototype 0 build. Stronger offers may remain visible in the tavern while Hard Filter prevents the hero from considering them until their base persistent HeroPower is sufficient.

Only the accepted quest offer is regenerated. Its existing map target remains reserved and visible while the hero selects it, walks the real route to it, and performs the quest. `TravelSystem` advances `WorldState.hero_position` by exactly one adjacent route hex per completed world tick. After the final objective is completed and the hero starts the real route back to the Starting City center, the old target reservation is released and its map marker disappears; successful turn-in then regenerates only that tavern slot and the replacement offer immediately receives a fresh valid map placement. Fatal cancellation releases the target immediately and returns the dead hero's map position to the city for the resurrection timer, while replacement still waits until city recovery returns the hero to quest choice. Other offers retain their rolled values, identities, and target hexes.

At every `CHOOSING_QUEST` decision point:

1. `QuestEvaluator` applies the Hard Filter:
   `MobPower <= HeroPower × 0.95`;
2. only allowed quests participate further;
3. the weakest allowed mob becomes the recovery baseline (`1`);
4. for every allowed quest:
   `RelativeRecoveryCost = MobPower / WeakestAllowedMobPower`;
5. `EstimatedCostPerMob = 1 fight tick + RelativeRecoveryCost`;
6. `EstimatedQuestTicks = Distance + MobCount × EstimatedCostPerMob + Distance + 1 turn-in tick`;
7. `BaseAttractiveness = GoldReward / EstimatedQuestTicks`;
8. Courage, Morality, and Greed modifiers are applied from the hero's current traits; if one current eligible quest is guided by the god, that offer receives `DivineModifier = +0.20` for this selection only; otherwise DivineModifier is `0`;
9. the highest final `QuestScore` is selected with no roulette.

The currently selected quest is then handed to `QuestRunner`, which remains responsible only for execution.

`Simulation.new()` without an explicit `null` quest keeps the old fixed-Goblin default for regression compatibility. The real developer UI uses `Simulation.new(seed, null)`, which enables autonomous selection from the quest pool.

Cumulative combat statistics remain keyed by mob id and continue to be shown in the fixed developer panel.

## Current quest loop

Current successful loop:

```text
choose quest
→ travel
→ fight
→ XP / possible level-up
→ full post-fight recovery
→ next mob or return
→ turn in
→ Gold
→ one market/sale tick
→ one or more shopping ticks while meaningful affordable upgrades exist
→ if no ready local dungeon: repeat ordinary quest loop
→ if a local dungeon passes first-attempt/retry readiness: TRAVEL_TO_DUNGEON → AT_DUNGEON_ENTRANCE
```

Current defeat loop:

```text
fight lost
→ quest canceled
→ DEAD_RESPAWNING for 100 ticks
→ resurrect at 1 HP
→ RECOVERING_IN_CITY
→ full HP
→ CHOOSING_QUEST
```

Quest selection now happens autonomously before `QuestRunner` begins execution.

## Quest events and narrative

Current chain remains:

```text
QuestRunner
→ QuestEvent
→ QuestNarrator
→ DebugLog
```

Death, natural resurrection, and city recovery use structured events rather than hard-coded UI text.

The diary remains unimplemented and receives no gameplay events yet.

## Debug log window

The debug log retains only the last 100 world ticks.

Retention is tick-based rather than line-based:
- ordinary tick messages belong to their world tick;
- all start/action/result lines from one fight belong to the single world tick consumed by that fight;
- therefore a verbose fight still counts as exactly one tick for log retention.

The UI defers its scroll update until TextEdit wrapping/layout is complete, so every new log entry remains visible at the actual bottom without manual scrolling.

## UI

Current layout:
- a persistent top menu with Hero, Inventory, Map, and Menu buttons;
- hero panel on the left;
- god-energy panel and three ability buttons above the center log/diary;
- log/diary in the center;
- opponent panel on the right;
- developer speed controls in the bottom-right corner.

`MainUI` now coordinates dedicated `InventoryScreen`, `GodPanel`, and `NarrativePanel` scenes. `GodPanel` owns the current divine controls, while `NarrativePanel` owns the Log/Diary tabs and debug-log autoscroll; all three receive the same live `Simulation` and do not own gameplay rules.

The Map button opens a dedicated `MapScreen`. `data/map/prototype_02_map.tres` owns the 20 × 15 source geometry and references the editable exact-color texture `assets/map/prototype_02_hex_layout.png`. `HexMapImageDecoder` samples the center of all 300 flat-top hexes, rejects unknown colors with coordinates, derives both compact seven-hex city clusters, identifies the unique bright-red hero-start center, and reconstructs the one unbranched road between the cities. Runtime `HexMap` converts every logical cell into a `HexDefinition` containing its own coordinates, decoded terrain, `region_id`, and permanent semantic tags; the technical `hero_start` marker becomes normal `starting_city` terrain in the game-level hex data. Current tag vocabulary is deliberately small: `city` marks all city cells, `city_center` marks only the two authored centers, and `road` follows the authored ordered road path rather than relying on the temporary road-as-terrain encoding. Starting Region and Mid Region each extend up to seven adjacent-hex steps from their city center. Cells inside both radii belong to the nearer center; the four current equal-distance cells are split by the midpoint between city-center X coordinates, producing 124 hexes per city region and 52 peripheral no-region hexes. `Simulation` owns this `HexMap`, mutable `WorldState`, and `TravelSystem`; the hero begins at the Starting City center, and `HexMap` provides deterministic adjacent-hex routes, step distance, and the fixed 3 km-per-hex world distance. When a map-backed quest is selected, `TravelSystem` follows that route one adjacent hex per world tick to the offer target and later one hex per tick back to the city center; `MapScreen` continuously follows the resulting live `WorldState.hero_position`. `MapTileVisuals` supplies three real `158 × 140` PNG variants for each normal biome from `res://assets/map/biomes/` plus the authored `418 × 440` `town1.png`; variant selection is deterministic from hex coordinates, city cells use plains art underneath, and `MapScreen` draws both biome tiles and the town overlay 1:1 at base zoom. Both city clusters use the same town overlay, centered on the city-center hex and aligned by the overlay's bottom edge to the bottom edge of the full seven-hex cluster; internal city-hex outlines are omitted so the town art remains visually continuous. Road cells temporarily reuse plains biome art underneath the existing road line. The map hero visual uses the permanent `res://assets/map/characters/hero_map.png` source. The source remains high-resolution and `MapScreen` scales it only for display to 120 px tall at base zoom, centered horizontally on the current live hero hex and shifted 5 px upward for visual placement. Every currently placed quest-board offer is also drawn at its real `target_hex` using the supplied `res://assets/map/activities/quest.png` 426 × 400 RGBA sprite, scaled only at draw time to 65 px tall (about 69.2 × 65 px) and centered on the target hex. The hero's currently selected `active_quest` receives a brighter three-layer orange outline (`#FF8C00`) around that same sprite, following the visual principle of the existing item-rarity outline; other quest markers remain unchanged. Completed/cancelled offers disappear when their reservation is released, and replacement offers appear at their new placement. `MapScreen` remains pointer-interactive for inspection only: hovering a hex shows its coordinates, terrain, region, and permanent tags in a debug tooltip without changing simulation state. Mouse-wheel input zooms the map between 0.6× and 2.0× around the cursor, while holding the right mouse button and dragging pans the map; the map transform applies to hexes, roads, quest sprites, hero marker, and city labels, while the screen UI and tooltip remain fixed. Panning is clamped so the map cannot be dragged completely off-screen. The shared top menu and red close button remain available, and opening the map changes only UI visibility while the existing Simulation continues running.

The Inventory button opens the dedicated `InventoryScreen` scene owned by `scripts/ui/screens/inventory_screen.gd`; `MainUI` retains only screen navigation and passes the existing `Simulation` into it. The main developer content is hidden while the shared top menu remains visible; the Inventory button becomes Back, and a separate red close button provides the same return action. The screen displays the hero over a dark `256 × 464` portrait panel. Five armor slots remain in a column on the left. Main-hand and off-hand slots sit below the portrait, with the sword on the left and shield on the right. The right column is jewelry-only in this order: necklace, earrings, ring, ring, belt. All seven current items show their equipped icons, quality outlines, and shared hover tooltip. Helmet, gloves, pants, and boots use the supplied 300 × 300 RGBA PNG icons; chest, sword, and shield keep their current icon assets. All five armor pieces now have aligned `441 × 800` paper-doll overlays, and equipped helmet, chest, gloves, pants, and boots are layered over the base hero portrait. A titled `6 × 6` grid displays up to 36 retained item instances. Better quality replaces the equipped item in the matching slot and moves the old one into inventory; equal or worse rewards enter inventory directly. Adding item 37 drops the oldest retained item. Manual equipping, dragging, selling, and set bonuses are not implemented. This UI-only screen switch does not pause or replace `Simulation`, so world time and autonomous gameplay continue normally.

The hero panel displays HP with one decimal place and now shows:
- dead state with remaining resurrection ticks;
- city-recovery state after resurrection.

The opponent panel is populated only during active combat.

God-panel button availability follows gameplay state, energy, cooldowns, active buff charges, current HP, and death/respawn state. Instant resurrection is disabled until the hero dies; its button displays the current dynamic energy cost.

Combat blessing starts its 120-tick cooldown immediately on use. While the five-fight effect remains active, the UI displays both independent counters (`Боёв` and `КД`) at the same time.

A separate panel in the bottom-right corner continuously shows cumulative combat count, wins, losses, and winrate for the current quest mob.

## Tests

Current coverage includes:
- world time and speed controls;
- seeded RNG;
- hero progression;
- combat timing, crits, and simultaneous death;
- fight-local Rage, the level-10 Power Strike unlock, autonomous replacement of the next attack, cooldown/cost, guaranteed hit, critical hits, WIS scaling, blocked/avoided incoming-hit Rage rules, cap/reset, and distinct combat narration;
- the level-20 Battle Guard unlock, post-threshold activation order, 10-second duration, 60-second cooldown, no Rage cost, post-defense mitigation, WIS scaling, locked-state behavior, and distinct activation narration;
- quest combat/XP/recovery;
- death and quest cancellation;
- exact 100-tick natural resurrection;
- resurrection at 1 HP;
- city recovery to full HP;
- retention of earlier XP/levels and no Gold for a failed quest;
- generic validity/progression checks for the current Goblin, Wolf, and Bear tuning cards;
- offer replacement without assuming a fixed tavern pool size;
- god ability integration, including the `+0.20` one-selection quest guidance modifier;
- current Starting City ilvl 1 Ironwake/ilvl 10 Ironward shop bands, unique slots per band and rarity, reuse of shared item generation data, deterministic 200-tick refresh, persistent purchased vacancies, separate sale/shopping ticks, +20% purchase threshold, maximum real HeroPower-gain selection, and immediate resale of replaced equipment.

UI note: during active combat, the hero panel displays live CombatSession HP rather than only the last committed HeroState HP.
