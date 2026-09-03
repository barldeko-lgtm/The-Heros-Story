# The Hero’s Story — Dependencies and Invariants

This document records current cross-file dependencies and contracts that can be broken by refactoring.

## Runtime flow

```text
main_ui.gd
→ Simulation
→ WorldClock / CombatSession
→ QuestPool / QuestEvaluator
→ QuestRunner
→ QuestEvent
→ QuestNarrator
→ DebugLog
```

Live combat:

```text
CombatSession
→ CombatResult
→ Simulation
    ├── victory → HeroProgression XP / possible stat refresh
    └── result → QuestRunner
→ exactly one completed world tick
```

## World time

`WorldClock` remains the single world-tick source.

Contracts:
- active combat freezes ordinary world-tick progress;
- a resolved fight still counts as exactly one world tick;
- `DEAD_RESPAWNING` advances only through normal world ticks;
- pause therefore freezes the respawn timer;
- developer speed controls accelerate the respawn timer in the same way as travel/recovery.

## Combat / death boundary

`CombatSession` owns only one duel and reports victory or defeat through `CombatResult`.

It must not:
- cancel quests;
- award XP;
- run the resurrection timer;
- restore city HP;
- write UI or diary state.

Death handling begins only after the completed `CombatResult` reaches the quest/simulation layer.

## Warrior Rage and Base Abilities

Current flow:

```text
HeroProgression reaches Levels 10 / 20
→ HeroState owns Power Strike / Battle Guard Skill Level 1
→ Simulation supplies both Skill Levels + current WIS when combat starts
→ CombatSession owns fight-local Rage and both ability timelines
→ CombatAction.action_id distinguishes Power Strike and Battle Guard activation
→ QuestNarrator writes the combat-log wording
```

Contracts:
- each new CombatSession starts at 0 Rage; Rage is not stored or carried between fights;
- a successful normal hero hit grants 5 Rage, or 7 instead when critical;
- a successful incoming hit grants 3 Rage even when blocked; an avoided hit grants none;
- Rage cannot exceed 100;
- reaching Level 10 automatically learns Power Strike at Skill Level 1;
- when at least 30 Rage is available and its 10-second cooldown is ready, Power Strike replaces the next normal hero attack opportunity rather than adding a separate strike;
- activation spends 30 Rage and starts cooldown immediately;
- Power Strike cannot miss, can still critically hit, and does not generate Rage from its own hit;
- its current Skill Level 1 multiplier is `1.50 + 2.0 × WisdomFactor`, where `WisdomFactor = max(0, WIS - 5) / (max(0, WIS - 5) + 100)`;
- reaching Level 20 automatically learns Battle Guard at Skill Level 1;
- Battle Guard costs no Rage and has no shield requirement;
- when an incoming hit first leaves the hero at or below 75% MaxHP, that hit resolves in full before Battle Guard activates;
- Battle Guard lasts 10 seconds and starts its 60-second cooldown on activation;
- while active, Battle Guard applies after Block and Armor / elemental Resistance by multiplying already-mitigated incoming damage by `1 - (0.25 + 0.15 × WisdomFactor)`;
- Battle Guard cannot activate again while active or before its cooldown is ready;
- purchased higher Skill Levels and skill UI remain outside this implemented slice.

## Primary attributes

`HeroState` stores the five Prototype 0.2 primary attributes. `StatResolver` is the only normal conversion path from those attributes to current combat-facing values.

Current contracts:
- a new Warrior starts with STR / DEX / INT / CON / WIS all equal to 5;
- STR grants +2 physical Damage and +5 percentage points Critical Damage per point;
- DEX grants +10 Accuracy, +2 Dodge, and +3 percentage points Critical Chance per point;
- CON grants +20 MaxHP and +1 Armor per point;
- INT and WIS currently remain stored without a resolved Warrior combat bonus;
- primary attributes do not change Attack Speed;
- until the deity-guided and personality-directed growth channels exist, level-up grants +2 STR / +1 DEX / +1 CON only; the missing divine point is neither assigned nor stored;
- current experimental equipment Strength uses the same centralized STR conversion and no longer grants MaxHP;
- Armor, Accuracy/Dodge, elemental Resistance, and Block are resolved through the shared `DamageResolver`; `CombatStats` does not store a parallel `damage_reduction` value.

## Autonomous quest selection

Owners:
- `scripts/quests/quest_pool.gd` — immutable templates and current quest offers;
- `scripts/quests/quest_evaluator.gd` — Hard Filter and QuestScore;
- `scripts/quests/quest_runner.gd` — execution only;
- `scripts/core/simulation.gd` — coordination between selection and execution.

Current decision flow:

```text
CHOOSING_QUEST
→ QuestPool current single-city offers
→ personality-adjusted Hard Filter Power window:
   standard 55–95% / Brave 60–100% / current legacy Coward-as-Cautious 50–90%
→ WeakestAllowedMobPower among allowed quests
→ RelativeRecoveryCost = MobPower / WeakestAllowedMobPower
→ EstimatedCostPerMob = 1 + RelativeRecoveryCost
→ EstimatedQuestTicks = Distance × 2 + MobCount × EstimatedCostPerMob + 1
→ BaseAttractiveness = GoldReward / EstimatedQuestTicks
→ current Courage / Morality / Greed modifiers
→ optional DivineModifier = +0.20 for the currently guided eligible offer, otherwise 0
→ strict highest QuestScore
→ selected QuestOffer assigned to QuestRunner
→ QuestRunner executes
```

Contracts:
- Hard Filter uses full-HP **base persistent HeroPower**, not current injured HP and not temporary combat-only bonuses;
- standard heroes consider MobPower from 55% through 95% of HeroPower; Brave uses 60–100%; the current legacy Coward trait temporarily represents Cautious and uses 50–90%;
- both bounds are inclusive within evaluator epsilon; quests below the minimum are outgrown and quests above the maximum are too dangerous, so neither participates in QuestScore;
- temporary finite effects such as the divine five-fight `+3 Attack` do not alter HeroPower or Hard Filter;
- conditional Noble/Dishonorable +10% category damage does not alter HeroPower or Hard Filter;
- mob count does not affect Hard Filter;
- filtered-out quests never participate in QuestScore;
- the weakest allowed mob is normalized to recovery cost `1`;
- one fight contributes exactly `1` estimated tick before recovery cost;
- fractional estimated ticks are allowed because this is pre-choice estimation only;
- current selection has no general roulette;
- starting traits use the shared seeded RNG and opposing traits are mutually exclusive;
- personality modifiers apply only after Hard Filter;
- Noble deals 10% more actual damage to MONSTER and Dishonorable to HUMANOID;
- quest guidance may add `+0.20` only to one current eligible offer for the next selection action and cannot bypass Hard Filter;
- QuestEvaluator must not execute quests;
- QuestRunner must not calculate Hard Filter or QuestScore;
- UI must not choose quests;
- changing `.tres` mob/quest tuning must not require changing selection code.

`QuestPool` loads immutable reusable quest templates from `data/quests` and uses the established quest RNG to create current `QuestOffer` objects. In the current one-city Prototype 0 build, every current initial-city template is exposed simultaneously; with the present content set this means 15 offers. Templates own tuning ranges plus map-placement constraints, while each offer owns rolled count, legacy abstract distance, gold per mob, a runtime `target_hex`, and its one-hex map reservation id. Total Gold remains derived as `MobCount × GoldPerMob`. A separate deterministic placement RNG stream chooses targets so adding map placement does not perturb the established quest-roll sequence.

There is no current 5–7-offer cap. Stronger offers remain in the single-city pool and are excluded from actual consideration by Hard Filter until the hero is strong enough.

`QuestPool` owns offer replacement, pending cancelled-offer state, and the current quest-board target reservations. An accepted offer retains its target while the hero travels/performs the quest under the legacy abstract loop. When the final objective is complete and the runner enters `RETURNING_TO_CITY`, that target reservation is released and the map marker disappears. Successful turn-in then regenerates only that accepted offer from the same immutable template in the same slot and places the replacement on a valid free target. Fatal cancellation releases the target immediately, while regeneration still waits until city recovery returns the hero to `CHOOSING_QUEST`. `Simulation` forwards the structured quest event and current loop state but does not store offer-lifecycle state. Unaccepted offers must retain their exact runtime values, identities, and target reservations.

## Quest execution and death

`scripts/quests/quest_runner.gd` owns the current quest-execution states.

On defeat it must:
- clamp hero current HP to 0;
- cancel `active_quest`;
- clear current quest execution counters;
- enter `DEAD_RESPAWNING` with exactly 100 ticks remaining;
- not grant Gold.

XP remains outside `QuestRunner`. `Simulation` applies mob XP through `HeroProgression` only when `combat_result.hero_won` is true.

Therefore a mob that kills the hero cannot grant XP, while previously earned XP and levels remain untouched.

## Natural resurrection

Current contract:

```text
DEAD_RESPAWNING (100 world ticks)
→ current HP = 1
→ RECOVERING_IN_CITY
→ +20% MaxHP per world tick
→ full MaxHP
→ CHOOSING_QUEST
```

The resurrection tick changes the state to `RECOVERING_IN_CITY` but does not also perform the first recovery tick. Recovery begins on the following world tick.

The hero cannot start a new quest while injured.

## Structured events and narrative

Death-related gameplay reports structured facts through `QuestEvent`:
- `HERO_DIED`;
- `HERO_WAITING_FOR_RESURRECTION`;
- `HERO_RESURRECTED`;
- `HERO_RECOVERING_IN_CITY`.

`QuestNarrator` owns their current Russian wording.

The diary remains separate and is not implemented as part of the death slice.

## Authored map / runtime world foundation

Current flow:

```text
assets/map/prototype_02_hex_layout.png
→ HexMapImageDecoder
→ HexMapDefinition decoded source layout
→ HexMap builds 300 HexDefinition cells (coordinates + terrain + region + semantic tags)
→ HexMap runtime adjacency / radius / route / distance queries
→ WorldState mutable hero position + active-activity hex occupancy
→ ActivityPlacementFinder valid center queries from region / distance / terrain / tags / free footprint
→ DungeonSystem auto-loads ordinary DungeonDefinition resources from the Starting/Mid region folders, then uses a dedicated seeded placement RNG to choose/reserve their targets and owns known/unknown discovery state
→ QuestPool uses a dedicated seeded placement RNG to choose and reserve current QuestOffer.target_hex values
→ TravelSystem owns the active adjacent-hex route and advances WorldState.hero_position by one route step per completed world tick
→ QuestRunner starts outward/return travel for the already selected QuestOffer and reacts to TravelSystem arrival
→ after a known-dungeon post-quest city decision, DungeonEvaluator checks first-attempt/retry Power readiness
→ PotionPreparationSystem produces a complete legal Belt-loadout plan before the attempt is allowed
→ if missing potions must be bought: HeroState.PREPARING_DUNGEON consumes one world tick and Simulation executes the complete missing purchase
→ DungeonRunner starts/advances the real route to the dungeon entrance through the same TravelSystem
→ DungeonRunner owns the authored encounter cursor / between-fight timing while Simulation uses the same shared CombatSession for each dungeon fight
→ Simulation applies PotionPreparationSystem healing inside the existing one-tick between-fight windows
→ future Event systems reuse the same placement/reservation and travel foundations
→ MapTileVisuals loads 3 authored 158 × 140 sprites per normal biome + 418 × 440 town overlay + hero/quest/dungeon map sprites
→ MapScreen sprite drawing / city overlays / live quest sprites / dungeon debug/discovered sprites / live hero sprite / hover inspection / camera transform
```

Contracts:
- the authored map is exactly 20 × 15 flat-top hexes in the current slice;
- the imported PNG uses lossless compression with no mipmaps, and the decoder samples the exact center pixel of every logical hex;
- only the approved exact-color palette is accepted; unknown colors report the affected hex coordinate instead of becoming plains;
- the unique bright-red hero-start marker is the Starting City center and must be surrounded by exactly six Starting City markers;
- the Mid-Level City occupies one center hex plus its six direct neighbors;
- the one ordered road path begins in the Starting City cluster, ends in the Mid-Level City cluster, and has no branches;
- all non-city/non-road cells are currently plains, forest, or hills; there are no mountains or water;
- `HexMapDefinition` owns authored source layout and adjacency validation but not mutable world state;
- each runtime `HexDefinition` currently owns logical coordinates, terrain id, `region_id`, and permanent semantic tags queried through `has_tag()`;
- the PNG's technical `hero_start` marker is used to derive the Starting City center but is normalized to `starting_city` in `HexDefinition.terrain_id`;
- `HexMap` creates all 300 `HexDefinition` cells, derives the current semantic tags (`city` for all 14 city cells, `city_center` for the two authored city centers, and `road` from the authored ordered road path), derives city-region ownership, and is the runtime query layer for hex lookup, valid neighbors, valid cells within a requested radius, deterministic shortest adjacent-hex routes, and distance; radius 0 contains only the center and radius 1 contains the center plus its six direct neighbors when the full footprint exists on the map; the `road` tag intentionally follows road topology rather than depending on the current temporary road-as-terrain encoding; the fixed world scale is 3 km per traversed hex;
- `starting_region` and `mid_region` each extend at most seven adjacent-hex steps from their city center; if a cell is inside both radii it belongs to the nearer city, while exact equal-distance cells are split by the X midpoint between city centers; on the current authored map this produces 124 Starting Region cells, 124 Mid Region cells, and 52 cells with no region;
- `WorldState` owns the mutable hero map position and the current activity occupancy of map hexes, and initializes hero position at the decoded Starting City center;
- an active activity reserves one or more valid hexes atomically through `WorldState`; if any requested hex is already occupied, the entire reservation fails without partial mutation; one hex may belong to only one active activity, while one activity may reserve multiple hexes and later release its complete footprint;
- hero presence does not reserve a hex as an activity; changing `WorldState.hero_position` must validate the destination through `HexMap`; destination choice and tick-by-tick travel do not belong to `WorldState`;
- `ActivityPlacementFinder` is a read-only placement filter: the requested center must belong to the requested region, lie inside the inclusive min/max hex-step distance from the supplied origin, satisfy any allowed-terrain filter plus the center's allowed/forbidden tag filters, and have a complete footprint for the requested radius; every footprint hex must remain inside the same region and be unoccupied; allowed terrain and allowed/forbidden tags apply to the center only, a non-empty terrain list requires an exact terrain-id match, and a non-empty allowed-tag list means at least one listed tag must match;
- current Starting City `QuestDefinition` resources already author future map placement through inclusive `placement_distance_hex_min/max`, optional `placement_allowed_terrain_ids`, optional `placement_allowed_tags`, and `placement_forbidden_tags`; every current ordinary quest forbids `city`, and the thirteen-template set is regression-tested to fit simultaneously on unique Starting Region hexes;
- `ActivityPlacementFinder` remains a pure filter and does not choose a candidate, reserve cells, create runtime activities, or mutate Simulation; current `DungeonSystem` and `QuestPool` are separate consumers, each using its own deterministic placement RNG stream and reserving its chosen footprint through `WorldState`; future Event systems remain responsible for their own choice/lifecycle logic;
- ordinary dungeon content under `data/dungeons/starting_region/` and `data/dungeons/mid_region/` is discovered automatically by `DungeonSystem`; only `DungeonDefinition` resources join the ordinary dungeon population, dungeon mob resources are ignored, ids must be unique, and the separate specialization folder is not part of this automatic ordinary-dungeon loading path;
- each ordinary `DungeonDefinition` owns one `ordinary_mob_definition` plus an `ordinary_encounter_count` of 3–5, and `DungeonRunner` must use that same ordinary mob for every pre-boss room before switching to the definition's unique boss;
- each current board `QuestOffer` owns one concrete `target_hex` plus the reservation id that protects that hex and a `map_distance_steps` value equal to the actual shortest route length from the Starting City center; live QuestScore travel estimation uses that real route distance whenever a map target exists, while legacy `distance_km_min/max` remains only for fixed compatibility offers that have no map target;
- `TravelSystem` owns only active map-route execution: `start_travel()` builds a deterministic `HexMap` route from the current hero position to the destination, starting travel does not teleport the hero, and each `advance_one_tick()` moves `WorldState.hero_position` to exactly one adjacent route cell until arrival;
- `QuestRunner` remains the ordinary-quest execution owner: on a map-backed selected offer it starts `TravelSystem` toward `target_hex`, enters combat only after the hero physically reaches that target, and after the final objective/recovery starts a real return route to the Starting City center; it does not calculate pathfinding itself;
- discovering a dungeon never interrupts the current activity or replaces an active quest route; after successful quest turn-in, the dedicated market tick and all current shopping decisions finish first; only when shopping has no further valid purchase does a known dungeon in the hero's current region become a candidate for dungeon readiness instead of automatically overriding `CHOOSING_QUEST`;
- `DungeonRunner` owns the dungeon-specific route and expedition sequence: it records base HeroPower at the start of each approved attempt; after reaching the real `target_hex` the first authored encounter becomes combat-ready, every ordinary victory preserves current HP and enters exactly one `DUNGEON_BETWEEN_FIGHTS` world tick, then the next ordinary fight or boss becomes ready; `PotionPreparationSystem` may consume prepared potions inside that same tick but there is never free healing; boss victory marks the runtime dungeon completed and immediately starts the real route back to the Starting City; return travel advances one adjacent hex per world tick and arrival hands the hero to `VISITING_MARKET`; failure reports the start Power and reached progress; it does not reuse or expand `QuestRunner`;
- `DungeonEvaluator` owns the current retry Power gate and does not participate in QuestScore: first attempt has no retry threshold; a failed attempt stores its starting HeroPower and requires +25% after zero ordinary kills, +15% after ordinary progress before the boss, or +10% after reaching the boss; a later failed retry replaces the remembered baseline with that attempt's own starting HeroPower;
- after a failed dungeon and normal resurrection/recovery, the hero returns to ordinary quest progression; each later post-shopping decision reevaluates the known dungeon, starts no dungeon route while current HeroPower is below the remembered threshold, and after the Power gate passes additionally requires a complete legal potion loadout for every current Belt slot; if that valid loadout requires purchases, one `PREPARING_DUNGEON` world tick buys all missing bottles before route start; retries therefore require both remembered Power growth and full-Belt preparation;
- dungeon fights use the same `CombatSession` / Warrior Rage / Power Strike / Battle Guard / trait damage path as quest fights; each fight starts from carried `HeroState.current_hp` rather than resetting to MaxHP;
- current dungeon ordinary enemies and boss grant their authored normal combat XP (150 / 185 for the first dungeon), but dungeon combat does not roll ordinary mob equipment drops or per-mob Gold; full completion of the first dungeon grants the authored 700 Gold plus exactly one ilvl 10 equipment reward from the unchanged full twelve-slot source now containing Ironwake core equipment plus existing accessories, with `completion_epic_chance = 0.25` producing 75% Rare/Blue and 25% Epic/Purple; standard equipment follows its normal rarity affixes, while Belt remains affixless because its rarity instead grants 1 / 2 / 3 / 4 potion slots; the item flows through `LootGenerator → ItemGenerator → ItemInstance → EquipmentEvaluator → Equipment/Inventory`;
- dungeon death is owned by `DungeonRunner`: the hero returns to the safe city map hex, uses the normal 100-tick respawn and 1-HP resurrection/city-recovery contract, and Divine instant resurrection routes through the active respawn owner instead of pretending the death belongs to `QuestRunner`;
- the accepted quest target stays reserved during outward travel, combat, and between-fight recovery; when the final objective is complete and return travel begins, the reservation is released; on fatal cancellation it is released immediately and the dead hero is returned to the safe city position for the resurrection timer; replacement offers acquire a new valid reservation only when their board slot is regenerated;
- `MapTileVisuals` is presentation-only and loads exactly three `158 × 140` project PNGs each for plains, forest, and hills from `res://assets/map/biomes/` plus the authored `418 × 440` `town1.png`; selection is deterministic by hex coordinates, while road and city cells temporarily reuse plains art as their base terrain visual. It also resolves the hero map texture from `res://assets/map/characters/hero_map.png`; it does not own hero position;
- `MapScreen` is observation-only presentation: it reads runtime hex data, current board QuestOffers, active dungeon map targets, and the live hero position from Simulation; it draws biome textures 1:1 at base zoom, keeps one-pixel black outlines on non-city hexes, omits internal city-hex outlines, draws `town1.png` as a native-size overlay on both seven-hex city clusters, and draws each currently placed QuestOffer with `res://assets/map/activities/quest.png` at its `target_hex`. The supplied 426 × 400 source is kept unchanged and scaled only at draw time to 65 px tall (about 69.2 × 65 px), centered on the target hex. Quest/dungeon-marker and hero-position changes trigger redraws and the sprites scale/pan with map content. Because completed dungeons lose their active map activity, their marker signature drops out automatically without MapScreen mutating gameplay state. The hero sprite follows the real tick-by-tick `WorldState.hero_position` produced by `TravelSystem`. The screen exposes current coordinates, terrain, region, and permanent semantic tags through the debug hover tooltip and owns only presentation camera state; it must not choose destinations, reserve/release activities, move the hero, calculate travel time, or otherwise modify Simulation;
- the first Starting Region dungeon reserves one hill hex 4–7 steps from the Starting City, begins unknown, and becomes discovered either when the hero physically enters its target hex or through Divine Vision; its live authored sequence is `3 × Mine Troglodyte (~200 Power, 150 XP) → Deep Devourer (~300 Power, 185 XP)` with one preparation tick after each ordinary encounter, including before the boss; prepared potions may be consumed within that tick according to the approved ordinary/no-overheal and pre-boss/survival rules; after boss victory `DungeonSystem` releases that dungeon's map activity and the completed instance no longer appears in active discovered/marker lookup;
- MapScreen uses `assets/map/activities/dungeon.png` at 65 px draw height; the current developer-only view deliberately shows an unknown dungeon at 40% opacity while keeping its identity out of the tooltip, then renders it fully opaque and named after discovery;
- opening MapScreen changes visibility only; the existing Simulation continues running;
- ordinary quest-board locations/travel and first-dungeon placement/discovery/post-quest priority/travel/sequential combat/+25%/+15%/+10% Power retry readiness/full-Belt potion preparation/dedicated missing-potion purchase tick/between-fight potion use/completion reward/removal from the active map are integrated; current Level 10/20 potions are visible individually in a vertical Inventory column with one bottle per slot, while prepared-Belt-slot visualization, current-route presentation, travel interruption/resumption, city relocation, events, and later potion tiers remain intentionally unintegrated.

## UI boundary

`main_ui.gd` coordinates top-level screens and the remaining main developer panels. It instantiates `InventoryScreen`, `GodPanel`, and `NarrativePanel`, supplies the same live `Simulation` to each, and owns Inventory Back/close navigation.

It may read the active respawn countdown only through `Simulation.get_respawn_ticks_remaining()` so quest- and dungeon-owned deaths display consistently; UI does not decrement the timer or change HP/state.

`scripts/ui/screens/inventory_screen.gd` reads equipped and retained-item state to display icons, quality outlines, tooltips, and portrait overlays. Its equipment layout is fixed to five armor slots left of the portrait, main-hand/off-hand below it, and necklace/earrings/two-rings/belt on the right. It does not grant, equip, drop, or modify items.

`scripts/ui/components/god_panel.gd` reads God/hero state and sends healing, blessing, and resurrection requests only through `Simulation`. It does not mutate `GodState`, HP, effects, cooldowns, or respawn state directly.

`scripts/ui/components/narrative_panel.gd` reads `Diary` and subscribes to `DebugLog`/world-time signals to display text and maintain autoscroll. It does not create or rewrite gameplay facts.

## God-system core

`scripts/god/god_state.gd` owns god energy, cooldowns, and pending quest guidance. `HeroState.active_effects` owns the active blessing and remaining fights. `scripts/god/god_system.gd` owns divine-command validation and applies each command through the existing hero, quest, and combat owners. `Simulation` retains stable public wrappers, performs required stat refreshes, and forwards resulting events to narrative/debug output.

Contracts:
- energy starts/maxes at 100 and recovers +1 every 6 completed world ticks, including fight and resurrection ticks;
- pause freezes recovery and cooldowns because no world ticks complete;
- instant resurrection spends `RemainingRespawnTicks × 0.5`, bypasses the timer, and uses the shared post-resurrection contract:

```text
resurrection
→ 1 HP
→ RECOVERING_IN_CITY
```

- healing cannot be used while dead or at full HP; during active combat it modifies live CombatSession HP rather than stale HeroState HP;
- combat blessing creates a generic `×1.15 resolved Physical Damage` active effect; `StatResolver` includes it in effective CombatStats, while base CombatStats/HeroPower remain unchanged;
- CombatSession receives ready-made effective CombatStats and must not accept a separate divine damage bonus;
- the active blessing consumes one HeroState effect charge after every finished fight and refreshes resolved stats when changed or removed;
- Noble/Dishonorable conditional damage and temporary blessings are displayed separately in UI and intentionally excluded from HeroPower/Hard Filter;
- guidance can target only a current tavern offer, never bypasses Hard Filter, and is consumed by the next quest-selection action even if it does not win;
- the guided eligible offer receives `DivineModifier = +0.20` for that one selection action; all other offers receive `0`;
- Divine Vision costs 80 Energy, starts a 1500-world-tick cooldown, and may reveal one random already-existing unknown dungeon only in the hero's current region; it never creates a dungeon or orders the hero to visit it;
- UI must call Simulation command wrappers rather than mutate GodState, GodSystem, dungeon discovery state, HP, quest scores, combat stats, or respawn state directly.

## Current equipment drop slice and future loot hook

Current generated-equipment flow for Rustchain Initiate, Ironwake Sentinel core equipment, and existing accessories:

```text
defeated current mob
→ 5% equipment-drop check
→ equal roll among 7 ilvl 1 slots for the five weakest mobs or 12 slots for both the ilvl 10 middle five and ilvl 20 strongest five
→ Common / Uncommon / Rare roll at 70% / 25% / 5%
→ mob's drop source supplies Rustchain ilvl 1, the full ilvl 10 source (Ironwake core plus jewelry/Belt), or Ironward core ilvl 20
→ EquipmentRewardSystem coordinates generated-equipment routing
→ ItemGenerator resolves inherent stats / budget / unique affixes
→ generated ItemInstance
→ EquipmentEvaluator copies current Equipment and virtually inserts candidate
→ StatResolver base persistent CombatStats for both configurations
→ shared PowerCalculator comparison
→ equip/replace or HeroState.Inventory
→ StatResolver refreshes BaseCombatStats / CombatStats
→ UI displays equipment/inventory icons, quality outlines, tooltip, and hero overlay
```

Safe-city economy flow:

```text
successful HERO_TURNED_IN_QUEST
→ HeroState.VISITING_MARKET
→ next normal world tick: EquipmentSaleSystem sells unequipped ordinary Inventory items
→ one debug-log sale summary
→ HeroState.SHOPPING
→ each later shopping world tick evaluates current shop stock
→ if a known local dungeon is Power-ready: reserve Gold needed for a complete current-Belt potion loadout
→ SpendingEvaluator: standard equipment uses affordability + 20% ItemPower threshold + virtual-equip HeroPower; Belt uses Belt utility
→ reject a Belt purchase if its resulting larger loadout could no longer be filled after paying for the Belt
→ choose the valid candidate under the relevant equipment/Belt rule
→ ShopSystem buys/equips at most one item on that tick
→ immediately sell replaced equipped item at normal resale value
→ purchased listing remains empty
→ repeat on later ticks while another valid purchase exists
→ if a local dungeon is known: DungeonEvaluator checks first-attempt / remembered retry Power readiness
→ if Power-ready: PotionPreparationSystem requires every Belt slot filled and plans any missing potion purchases
→ if missing potions must be bought: HeroState.PREPARING_DUNGEON
→ next world tick: buy all missing potions for the selected complete loadout
→ if full potion preparation succeeds: DungeonRunner → TRAVEL_TO_DUNGEON
→ if the complete loadout was already owned: no artificial purchase tick is added before DungeonRunner → TRAVEL_TO_DUNGEON
→ if blocked by retry Power: HeroState.CHOOSING_QUEST
→ if blocked by incomplete/unaffordable potion preparation: HeroState.CHOOSING_QUEST
```

Starting City stock:

```text
ShopDefinition
→ ilvl 1 Rustchain Initiate stock band
→ ilvl 10 Ironwake-core-plus-accessory stock band
→ ilvl 20 Ironward Vanguard stock band
→ ShopSystem
→ per band: 6 unique-slot White + 2 unique-slot Green ItemInstances
→ deterministic refresh on world ticks 200 / 400 / 600 / ...
→ fixed consumable availability: Level 10 healing potion (100 HP / 100 Gold) + Level 20 healing potion (150 HP / 200 Gold)
```

Contracts:
- `ItemDefinition` is immutable data; `ItemInstance` is the acquired object;
- every new hero begins with fixed Common ilvl 1 instances in Chest, Pants, and Boots; each has exactly +1 resolved Armor, no random affixes, and its supplied icon/paper-doll overlay;
- starting armor is not added to ordinary drop or shop source tables; stronger found/purchased gear replaces it through the existing virtual-equip path and routes the replaced piece through normal Inventory/sale behavior;
- each starting definition overrides its reference shop value to 10 Gold, so the shared 10% resale rule returns exactly 1 Gold without changing central ilvl 1 generated-item prices;
- the five weakest current mobs retain the seven-slot ilvl 1 source with unchanged mechanics and Rustchain Initiate definitions;
- Giant Spider, Bear, Rabid Elk, Bandit Veteran, and Swamp Crocodile use the twelve-slot ilvl 10 source with Ironwake Sentinel core slots and the unchanged necklace, earrings, Ring 1, Ring 2, and Belt definitions;
- Young Ogre, Cave Lizard, Forest Troll, Mountain Beast, and Orc Raider use the twelve-slot ilvl 20 Ironward Vanguard source with separate necklace, earrings, Ring 1, Ring 2, and Belt definitions; the same full family is available in the third shop band, while the first dungeon deliberately remains ilvl 10;
- Belt is part of the current generated/drop slice with inherent Health and no ordinary random affixes; Belt rarity grants Common/Uncommon/Rare/Epic capacities of 1/2/3/4 potion slots, and Belt Item Level sets the maximum legal potion level through `PotionLevel <= BeltLevel`; the first dungeon uses the same twelve-slot ilvl 10 source with its separate guaranteed Rare/Epic roll;
- a drop roll happens only after a combat victory, never after defeat or quest turn-in;
- the seeded roll order is drop chance, equal slot selection, then rarity selection;
- current ordinary quests contain Gold rewards only and no equipment reward pools;
- `QuestRunner` does not equip the item or calculate its stats;
- `EquipmentRewardSystem` coordinates reward rolling, item generation, virtual-equip evaluation, and replacement/inventory routing, and returns structured result data;
- `Simulation` keeps the public reward entry points and coordinates stat refresh, HP adjustment, and logging after the reward system returns;
- `EquipmentEvaluator` must compare full base persistent HeroPower for standard equipment, not rarity and not displayed reference ItemPower; Belt is the explicit exception and compares potential full-loadout healing first, then inherent Belt Health on a tie;
- the evaluator resolves a copied candidate equipment configuration and must not mutate live Equipment during comparison;
- temporary finite effects are excluded from both sides of equipment evaluation;
- a standard candidate of any rarity, including the same rarity, equips only when candidate HeroPower is strictly greater; Belt instead follows its approved healing-capacity/Health ordering; rejected candidates enter Inventory;
- `ring_1` and `ring_2` are interchangeable placement slots for Ring evaluation: every new Ring candidate must be virtually tested in both positions, the placement with the highest resulting HeroPower becomes the transaction target, and loot/shop routing must replace that selected ring rather than blindly using the candidate definition's authored ring slot;
- replaced equipment enters Inventory before the new item becomes the active stat source;
- Inventory keeps at most 36 retained equipment item instances in FIFO order; adding equipment item 37 drops the oldest regardless of quality. Healing potions are separate persistent consumable counts owned by the same Inventory model and are not part of this equipment FIFO;
- current ilvl 1/10/20 White reference values are 100/500/1000 Gold; Green uses ×3 and Rare uses ×9;
- sale value is 10% of reference value; current ilvl 10 White/Green/Rare resale is 50/150/450 Gold;
- successful turn-in does not sell immediately; it schedules exactly one `VISITING_MARKET` world tick;
- the market tick performs sale only and then enters `SHOPPING`; buying cannot occur during the sale tick;
- each `SHOPPING` world tick may consume at most one listing, so multiple purchases require multiple world ticks;
- dungeon discovery never skips the market or shopping phases; only after shopping finishes may a known dungeon replace the normal transition back to `CHOOSING_QUEST`, and only when its first-attempt/retry Power readiness plus mandatory complete potion preparation both pass;
- if a Power-ready dungeon loadout needs one or more new potions, the equipment-shopping decision only schedules `PREPARING_DUNGEON`; Gold is not spent and potions are not created on that same shopping tick;
- `PREPARING_DUNGEON` consumes exactly one completed world tick and purchases all missing bottles for that one selected complete loadout during that tick; dungeon travel begins afterward, while a fully already-owned loadout requires no such purchase tick;
- a standard shop candidate must be affordable, at least 20% stronger by displayed ItemPower than the equipped comparison item when one exists, and a strict real HeroPower improvement through virtual equip; Belt candidates use their separate potential-healing/Health utility rule instead;
- when a known local dungeon is already Power-ready, optional equipment spending may use only Gold left after the current full-Belt potion preparation cost is protected; a proposed Belt upgrade is also blocked if paying for it would make the complete loadout of that new Belt unaffordable;
- among valid standard purchase candidates the current equipment slice chooses the largest real HeroPower gain; Belt-vs-Belt candidates prefer larger potential healing, then higher inherent Health, then lower price if otherwise equal;
- replaced equipped gear is sold immediately in the purchase transaction and never enters Inventory;
- purchased shop positions remain empty until the next stock refresh;
- the current Starting City shop exposes ilvl 1 Rustchain, ilvl 10 Ironwake-core-plus-accessories, and ilvl 20 Ironward-core-plus-accessories source bands, each with 6 distinct White listings and 2 distinct Green listings; the ilvl 1 band selects from seven core slots, while the ilvl 10 and ilvl 20 bands select from all twelve equipment slots; fixed Level 10 / 20 healing potions are separate from these rotating 24 equipment listings;
- shop stock references the existing ItemDefinitions and generates each listing through the shared ItemGenerator; shop data does not own duplicate item stats, affix budgets, ItemPower, or price formulas;
- shop stock refresh is driven by world ticks rather than hero visits and occurs every 200 completed world ticks, including while the hero is away from the city;
- shop randomness uses a reproducible stream derived from the simulation seed so adding/refreshing stock does not perturb the existing main RNG sequence;
- automatic sale never runs on death or other runtime events;
- automatic sale affects Inventory only and cannot sell equipped items;
- unpriced future Item Levels/rarities remain in Inventory instead of receiving an invented price;
- persistent equipment affects base HeroPower/Hard Filter and effective combat stats;
- Armor uses `PhysicalTaken = 100 / (100 + Armor)` through `DamageResolver`;
- Rustchain Initiate drops are ilvl 1 (5 armor Armor, 10 sword Damage/+0.10 Attack Speed, 10 shield Block); Ironwake Sentinel core drops are ilvl 10 (7 Armor, 13 sword Damage/+0.10 Attack Speed, 13 shield Block); live Ironward Vanguard core drops are ilvl 20 (10 Armor, 17 sword Damage/+0.10 Attack Speed, 17 shield Block);
- every ilvl 10/20 necklace, earrings, or ring has exactly one seeded inherent Fire/Cold/Lightning Resistance at the central value for its Item Level, independent of rarity; each Belt instead has inherent Health plus rarity-driven potion capacity, and the new ilvl 20 Belt supports Level 20 bottles;
- jewelry random affixes are limited to Fire/Cold/Lightning Resistance, Health, Dodge, Accuracy, Critical Chance, and Critical Damage;
- Common/Uncommon/Rare standard equipment creates 0/1/2 unique random affixes; Belt is the explicit current exception and stays affixless because its rarity controls potion capacity instead; current ordinary drops do not generate Epic;

Potion contracts:
- current Starting City potion definitions are Level 10 = 100 HP / 100 Gold and Level 20 = 150 HP / 200 Gold;
- both current potion definitions reference their supplied 550 × 550 inventory sprites, and Inventory presentation exposes each owned Level 10 / 20 bottle in its own vertical visual slot without consuming any of the 36 retained-equipment cells; the column scrolls when more bottles are owned than fit in its visible height;
- a prepared dungeon loadout must fill every current Belt slot; partial loadouts are not ready;
- among complete affordable loadouts, preparation maximizes total healing and reuses already-owned potions before buying missing ones;
- prepared potions remain physical Inventory counts; the Belt is not a separate storage inventory;
- ordinary quest flow never consumes healing potions;
- one dungeon between-fight world-tick window may consume multiple potions;
- between ordinary rooms, the selected potion combination must maximize restored HP without any overheal, preferring fewer potions when multiple combinations heal the same amount;
- before the boss, the hero may use multiple potions and accept overheal to reach full HP when possible;
- every consumed potion is removed from both Inventory count and the prepared Belt loadout.
- ilvl 10 Green affix budget is 78; each Rare affix uses 85% of that value;
- one seeded 0.95–1.05 roll applies to total modifier budget, then budget splits equally among all affixes;
- generated affixes use only the slot-legal secondary-stat pools and Scope 19.5 costs;
- increasing MaxHP at turn-in increases current HP by the same delta, preserving full-health state;
- Common has no outline; Uncommon uses a soft green 1.0/0.55/0.25 three-band outline; Rare uses the same blue outline;
- generated ItemPower must use `PowerCalculator`, not a parallel scoring formula: calculate the approved fixed reference profile with and without the complete ItemInstance contribution, then subtract its reference Power of approximately `433.013`;
- ItemPower is a stable item-comparison rating and is not directly added to the hero's runtime Power.
- inherent-stat, Green-budget, rarity-rule, and stat-cost data live in central resources under `data/items/balance/`, not in individual generated instances;
- `ItemInstance` owns its concrete ilvl, rarity, rolled total budget, affixes, and resolved stats;
- the old serialized fixed stats on current visual rarity definitions are compatibility data only and do not affect generated runtime equipment;
- helmet, chest, gloves, pants, and boots each use a dedicated aligned paper-doll overlay from their `ItemDefinition`; sword, shield, necklace, earrings, and rings have no hero portrait overlay, and UI must not synthesize worn art from equipment icons;
- no set-completion bonus exists in the current slice.

General item interactions and QuestLoot are still not implemented. When QuestLoot exists, death must clear only current-quest loot before entering the existing respawn path. Permanent equipment and retained Inventory must remain separate.

## Tests protecting this contract

`tests/test_death_respawn.gd` verifies:
- one lost fight still consumes one world tick;
- active quest cancellation;
- no XP from the losing mob;
- no Gold from the failed quest;
- retention of prior level/XP;
- exactly 100 respawn ticks;
- resurrection at exactly 1 HP;
- 20% MaxHP city recovery;
- full recovery before `CHOOSING_QUEST`.

`tests/test_quest_offer_refresh_lifecycle.gd` protects replacement of only the accepted offer without assuming a fixed number of tavern slots.

`tests/test_god_abilities_integration.gd` protects the one-selection `DivineModifier = +0.20` contract and the separation between base HeroPower and temporary combat effects.

## Combat validation telemetry

`Simulation` owns lightweight development-only cumulative combat-result counters keyed by mob id.

Contracts:
- recording statistics must not alter combat, XP, recovery, death, or quest outcomes;
- one finished fight increments exactly one result;
- counters track total fights, hero wins, hero losses, and derived winrate;
- cumulative combat statistics remain in `Simulation` and are displayed by UI; they are not written into the debug log;
- the same mechanism works for any mob definition and is not Wolf-specific.

`Simulation` may receive an explicit fixed quest for regression/development tests. Its default remains the existing Goblin quest. Passing `null` enables autonomous QuestPool selection; the developer UI now uses this autonomous mode.

## Debug-log retention

Owner:
- `scripts/narrative/debug_log.gd`

Contracts:
- visible history is limited to the latest 100 world ticks;
- retention is based on world-tick ids, not entry count;
- every line from one individual fight is tagged with the same upcoming world tick because one fight consumes exactly one world tick;
- trimming log history must not affect simulation state or cumulative combat statistics.
