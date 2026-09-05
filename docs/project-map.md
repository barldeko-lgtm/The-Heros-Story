# The Hero’s Story — Project Map

## Project root

- `project.godot` — Godot project configuration and main scene.
- `.github/workflows/tests.yml` — GitHub Actions regression-test workflow.
- `assets/` — supplied visual assets used by the current UI. Hero art lives under `assets/hero/`; item icons and overlays are separated under `assets/items/icons/` and `assets/items/overlays/`; the editable exact-color world layout and its Russian palette guide live under `assets/map/`.
- `data/` — concrete game data. The current visual equipment families live under `data/items/visual_families/rustchain_initiate/`, `data/items/visual_families/ironwake_sentinel/`, and `data/items/visual_families/ironward_vanguard/`; the fixed three-piece new-hero outfit lives under `data/items/starting_equipment/`; the first authored world layout lives at `data/map/prototype_02_map.tres`.
- `scenes/` — Godot scenes.
- `scripts/` — runtime/gameplay/UI code.
- `tests/` — regression tests.

The target Prototype 0.2 directory scaffold from the Scope is tracked with `.gitkeep` placeholders. Empty folders do not mean that their future systems are implemented. Existing scripts, scenes, tests, mobs, and quests remain in their current working locations until an approved system-specific change requires moving them.

## Core

### `scripts/core/simulation.gd`
Runtime coordinator. It equips every newly created hero with the three fixed starting armor instances before resolving initial combat stats. The default constructor keeps the fixed Goblin quest for regression compatibility; passing `null` as the initial quest enables autonomous selection from QuestPool.

Coordinates:
- WorldClock;
- SeededRng;
- HeroState / HeroProgression / StatResolver;
- PowerCalculator;
- live CombatSession;
- QuestPool / QuestEvaluator;
- QuestRunner;
- DungeonSystem / DungeonRunner;
- QuestNarrator;
- DebugLog;
- Diary shell;
- GodState commands and active-effect coordination.

On combat completion it records cumulative per-mob win/loss statistics, applies XP only after victory, consumes one active divine-blessing fight when present, passes the result to `QuestRunner`, logs the resulting structured event, and completes exactly one world tick for the fight.

### `scripts/core/world_clock.gd`
Single world-time authority used by travel, recovery, the natural resurrection timer, god energy recovery, and god cooldowns.

### `scripts/core/seeded_rng.gd`
Owns the current seeded RNG.

## Hero

### `scripts/hero/hero_state.gd`
Mutable hero state and centralized loop-state ids, including:
- `DEAD_RESPAWNING`;
- `RECOVERING_IN_CITY`.

Also owns current `active_effects`, learned Power Strike and Battle Guard Skill Levels, the hero's pending player-distributed primary-attribute points, the hero's `Equipment`, the current `Inventory`, and the ordered levels of healing potions currently prepared into Belt slots for dungeon use.

### `scripts/hero/equipment.gd`
Owns equipped `ItemInstance` objects by slot, replaces an item when Simulation approves a better quality, and exposes persistent stat totals.

### `scripts/hero/inventory.gd`
Stores up to 36 retained equipment item instances in acquisition order; adding equipment item 37 removes and returns the oldest equipment item. The same Inventory model also owns persistent healing-potion counts by potion level, separate from that equipment FIFO so consumables are not accidentally sold or evicted as ordinary gear.

### `scripts/hero/hero_traits.gd`
Owns the five Prototype 0 trait IDs, seeded assignment of 1–2 compatible starting traits, Russian display names, QuestScore personality constants, and the Noble/Dishonorable category-damage multiplier.

### `scripts/hero/hero_progression.gd`
Owns XP, the approved pre-specialization level growth of +1 fixed Warrior STR plus 4 pending player-distributed primary-attribute points, explicit spending of those pending points into STR / DEX / INT / CON / WIS, and the automatic Skill Level 1 unlocks of Power Strike at compressed Level 5 and Battle Guard at compressed Level 10.

### `scripts/hero/stat_resolver.gd`
Builds stable base stats and effective combat stats from the same sources. It is the centralized conversion path from STR / DEX / CON to current combat-facing values; INT and WIS are stored but currently add no generic CombatStats bonus, while ability-specific WIS scaling is resolved by the owning ability. Persistent equipment contributes to both views; effective stats additionally include generic bonuses from `HeroState.active_effects`. It resolves raw Armor, Accuracy, Dodge, Resistances, and Block values but does not calculate hit or mitigation outcomes.

## Combat

### `scripts/combat/combat_simulator.gd`
Creates one live duel from already resolved hero and mob `CombatStats`.

### `scripts/combat/combat_session.gd`
Owns only one fight: internal combat time, HP, attack opportunities, crits, calls to the shared hit/mitigation rules, conditional hero damage multiplier, fight-local Rage, autonomous Skill Level 1 Power Strike, and autonomous Skill Level 1 Battle Guard threshold/duration/cooldown/post-defense mitigation/WIS scaling before victory or defeat.

It does not own resurrection, quest cancellation, god ability state, or flat stat-bonus injection.

### `scripts/combat/combat_action.gd`
One resolved attack, including its structured action id, hit/miss, critical, Block, damage type, and final damage facts.

### `scripts/combat/damage_resolver.gd`
Shared Prototype 0.2 formulas for Accuracy/Dodge, Armor, elemental Resistances, Block chance, expected Block mitigation, and direct-hit mitigation. Both hero and mob combat use the same implementation.

### `scripts/combat/combat_result.gd`
One duel result.

### `scripts/combat/power_calculator.gd`
Shared complete Prototype 0.2 hero/mob Power calculation. It includes expected physical DPS, the reference Accuracy factor, the 70/10/10/10 incoming-damage mix, reference Dodge, Armor, all three elemental Resistances, and expected Block mitigation. Quest Hard Filter uses the hero's base persistent `CombatStats` view; temporary finite effects are intentionally excluded.

## World map foundation

### `scripts/model/definitions/hex_definition.gd`
One logical map cell. Each current `HexDefinition` owns the cell's stable logical coordinates, game-level terrain id, city `region_id`, and permanent semantic `tags`. The current tag vocabulary is intentionally small: `city`, `city_center`, and `road`; `has_tag()` is the shared query boundary. The 300 instances are built from the authored PNG layout by `HexMap`; the technical `hero_start` source marker is normalized to `starting_city` terrain rather than becoming a separate gameplay terrain type. Region ownership and semantic tags are derived from authored map structure rather than encoded as extra PNG colors.

### `scripts/world/hex_map.gd`
Runtime read/query layer over the authored map definition. It validates the decoded map, creates one `HexDefinition` for every logical cell, derives permanent semantic tags from authored structure (`city` from city terrain, `city_center` from the two authored centers, and `road` from the ordered road path), derives the two non-overlapping seven-step city regions, exposes hex lookup and valid neighboring cells, returns all valid cells within a requested hex radius, builds deterministic shortest adjacent-hex routes, and reports route distance in steps and kilometres using the fixed Prototype 0.2 scale of 3 km per hex. Overlap belongs to the nearer city; equal-distance boundary cells are divided by the midpoint between the two city-center X coordinates. It does not choose destinations, reserve activities, or advance travel.

### `scripts/world/world_state.gd`
Mutable world-state owner for the current map slice. It owns the hero's current map hex and the current active-activity occupancy of map hexes. Activity reservations are atomic, one hex may belong to at most one active activity, and releasing an activity frees its complete stored footprint. Hero presence itself is not treated as activity occupancy. It initializes the hero position from the authored Starting City center and validates position changes against `HexMap`, but it does not decide where the hero should go or which activities should spawn.

### `scripts/world/travel_system.gd`
Owns real multi-tick map movement. It asks `HexMap` for the deterministic shortest route from the hero's current `WorldState.hero_position` to an already chosen destination, stores the active route, and advances exactly one adjacent hex per world tick when its caller advances travel. It exposes remaining route steps and arrival state but does not choose destinations, quests, events, or city relocation. Current ordinary quest execution is its first consumer.

### `scripts/world/activity_placement_finder.gd`
Pure placement-query helper for future map-backed quests, dungeons, and temporary events. It returns valid central hexes for a requested region, inclusive distance range from an origin, optional allowed terrain ids, optional allowed/forbidden semantic tags on the center, and footprint radius. A non-empty terrain list requires the center terrain to match one listed id; a non-empty allowed-tag list requires at least one matching center tag; any forbidden center tag rejects the candidate. Every footprint hex must exist, remain inside the requested region, and be free in `WorldState`. The finder does not reserve cells, choose among candidates, roll RNG, create activities, or mutate Simulation.

### `scripts/model/definitions/hex_map_definition.gd`
Authored map source contract. It owns dimensions, PNG sampling geometry, flat-top odd-column adjacency, decoded terrain lookup, derived city centers/seven-hex clusters, the ordered road path, and structural validation. It references the editable PNG but does not own hero movement, route choice, travel time, events, quests, or world simulation state.

### `scripts/world/hex_map_image_decoder.gd`
Pure exact-color decoder for the editable hex PNG. It samples one central pixel per logical hex through the imported lossless texture, maps only the approved palette, reports unknown colors with hex coordinates, validates the unique hero-start marker, validates both seven-hex city clusters, and reconstructs one connected non-branching road from Starting City to Mid-Level City.

### `assets/map/prototype_02_hex_layout.png` / `assets/map/README.md`
Editable 1448 × 1086 schematic map image and its palette/editing contract. The current gameplay rectangle is 26 × 15 = 390 logical hexes; the enlarged source art also contains 13 unused decorative bottom hexes on alternating columns. Recoloring one gameplay hex's technical center pixel with an approved exact palette color changes the decoded terrain after Godot reimports the PNG.

### `data/map/prototype_02_map.tres`
References the editable PNG and stores its 26 × 15 logical gameplay dimensions plus the current enlarged-source sampling geometry. Concrete terrain, city, road, and hero-start markers come from the PNG rather than duplicated coordinate arrays.

## Quests

### `scripts/model/definitions/quest_definition.gd` / `data/quests/*.tres`
Immutable ordinary-quest templates. In addition to combat/reward tuning, every current Starting City quest authors its map-placement band in hex steps plus either allowed terrain or an allowed semantic tag and forbidden tags. All twenty-two current templates forbid `city`; road-themed quests use the `road` tag, while the rest currently use plains, forest, or hill terrain constraints. Current tuning also keeps `Банда у каменного моста` at the reduced 24–28 Gold-per-mob range and gives several stronger templates wider enemy-count rolls. Legacy `distance_km_min/max` values remain temporarily for the still-unmigrated abstract QuestOffer/QuestRunner travel path and are not the future placement authority.

### `scripts/quests/quest_pool.gd`
Owns immutable quest templates and the currently available runtime tavern offers for this Prototype 0 slice.

The developer build loads every `.tres` under `res://data/quests` in stable filename order. The current twenty-two Starting City templates explicitly belong to lower / middle / higher strength bands in an 8 / 7 / 7 split. During the current playtest pass, `QuestPool` temporarily exposes every eligible template from all three bands instead of selecting only three per band; each runtime offer still rolls its integer count, legacy abstract distance, and per-mob-gold values through the established quest RNG. A separate deterministic placement RNG stream uses `ActivityPlacementFinder` plus each template's hex-distance/terrain/tag constraints to assign every current board offer one free Starting Region target and reserve it through `WorldState`. An offer calculates its total Gold reward as `MobCount × GoldPerMob`.

The Starting City board is capped at nine available offers with a maximum of three per strength band. `QuestEvaluator` sees only those current offers; a particular board roll is allowed to contain no offer suitable for the hero's present Hard Filter window.

`QuestPool` owns both board lifecycle and quest-target reservation lifecycle. The whole available board rerolls together every 50 completed world ticks. Accepting an offer removes it from the available board immediately and leaves the vacancy empty until the next global refresh, while the active QuestOffer keeps its target reservation during travel and quest execution. A global refresh releases/replaces only current board-offer reservations and preserves the separate active quest target. When the final objective is completed, that active target is released. Successful completion marks the template unavailable for 50 world ticks; cancellation has no completion cooldown. The cooldown is strict: blocked templates are not used as fallback fillers. Neither result triggers an individual replacement. `Simulation` forwards structured quest events and completed world ticks but does not own board state. Tests may still inject explicit fixed offers without map placement for regression use.

### `scripts/model/runtime/quest_offer.gd`
Runtime quest offer. Owns the rolled mob count, legacy abstract distance, gold per mob, concrete `target_hex`, and the `map_activity_id` for its current one-hex reservation. Its total Gold is derived as `MobCount × GoldPerMob`. Target placement is runtime-only and is never serialized into the immutable quest template.

### `scripts/quests/quest_evaluator.gd`
Owns autonomous quest evaluation:
- personality-adjusted lower/upper MobPower Hard Filter window: standard 55–95%, Brave 60–100%, current legacy Coward as temporary Cautious 50–90%;
- weakest-allowed-mob normalization;
- estimated combat/recovery cost;
- BaseAttractiveness;
- Coward/Brave modifier;
- Dishonorable/Noble modifier;
- Greedy modifier;
- optional one-selection `DivineModifier = +0.20` for the currently guided eligible offer;
- strict highest-score selection.

Hard Filter uses base persistent HeroPower. Quests below the lower bound are treated as outgrown, quests above the upper bound are too dangerous, and neither group participates in QuestScore. Guidance cannot bypass Hard Filter.

### `scripts/quests/quest_runner.gd`
Executes the current already-selected quest.

Owns current execution-state transitions including:
- travel;
- defeated-mob count;
- post-fight recovery;
- return/turn-in;
- defeat and quest cancellation;
- 100-tick natural resurrection timer;
- city recovery after resurrection.

It does not award XP, choose quests, calculate QuestScore, or implement combat itself.

### `scripts/quests/quest_event.gd`
Structured quest/runtime events, including death, resurrection, and city recovery.

## Dungeons

### `scripts/model/definitions/dungeon_definition.gd` / `data/dungeons/starting_region/*.tres`
Immutable ordinary-dungeon data. Each ordinary dungeon authors one shared ordinary mob definition, a 3–5 ordinary-room count, and one unique boss; the same ordinary mob is therefore used in every pre-boss room of that dungeon. `Заброшенные железные шахты` uses a hill hex 4–7 steps from Starting City and `3 × Шахтный троглодит` → `Глубинный пожиратель`, rewarding 700 Gold + one compressed ilvl 5 Rare/Epic item. `Городище Черноклыков` uses a forest hex 5–7 steps from Starting City and `3 × Гоблин-гвардеец` → `Король гоблинов`, rewarding 2000 Gold + one compressed ilvl 10 Rare/Epic item from the full twelve-slot Ironward source. Both use `completion_epic_chance = 0.25`. Definitions store content/tuning only; they do not execute expeditions or award rewards.

### `data/dungeons/starting_region/0001_mine_troglodyte.tres` / `0001_deep_devourer.tres`
Dungeon-only `MobDefinition` resources. The Mine Troglodyte is tuned to approximately 200 shared Power and grants 150 XP; the Deep Devourer is approximately 300 shared Power and grants 185 XP. They are not ordinary city-quest mobs, grant no per-mob Gold, and have no normal equipment-drop table.

### `data/dungeons/starting_region/0002_blackfang_guard.tres` / `0002_goblin_king.tres` / `0002_blackfang_settlement.tres`
Second Starting Region dungeon content. The Blackfang Guard is a Humanoid tuned to approximately 600 shared Power and 260 XP; the Goblin King is a unique Humanoid boss at approximately 750 shared Power and 320 XP. Neither grants per-mob Gold or ordinary equipment drops. The dungeon uses exactly three guard rooms, forest placement 5–7 hexes from Starting City, and the full compressed ilvl 10 twelve-slot completion source for its 2000-Gold + Rare/Epic equipment reward.

### `scripts/model/runtime/dungeon_instance.gd`
Runtime dungeon placement/knowledge/progress state: immutable definition reference, concrete `target_hex`, reservation id, discovered flag/source, completed flag, and persistent failed-attempt memory used by retry readiness: attempt count, HeroPower at the start of the latest failed attempt, ordinary progress, and whether the boss was reached. It does not duplicate the tunable +25% / +15% / +10% balance rules; `DungeonEvaluator` derives the current requirement from this memory.

### `scripts/dungeons/dungeon_system.gd`
Owns ordinary-dungeon content loading, map placement, and discovery. By default it scans the ordinary region folders `data/dungeons/starting_region/` and `data/dungeons/mid_region/` in stable path order, loads only resources using `DungeonDefinition`, ignores dungeon-only mob resources beside them, and intentionally does not auto-load the separate `data/dungeons/specialization/` folder. It chooses valid free centers through `ActivityPlacementFinder`, reserves dungeon footprints through `WorldState`, exposes active known/unknown dungeon views including discovered dungeons by region, discovers a dungeon when the hero physically enters its exact hex, supports revealing one random unknown dungeon in a region for Divine Vision, and releases/clears the map activity of a successfully completed dungeon so it disappears from active map views. It does not execute travel or dungeon combat.

### `scripts/dungeons/dungeon_runner.gd`
Owns one ordinary dungeon expedition after the city decision point. It accepts an already-discovered uncompleted dungeon after readiness has been approved, records HeroPower at the start of that expedition, starts the shared `TravelSystem` route to its real `target_hex`, owns the authored encounter cursor, carries current hero HP between fights, inserts exactly one world tick of preparation after every ordinary victory, advances into the dungeon's unique boss after its authored ordinary-room count, marks completion after boss victory, then starts and advances the real `TravelSystem` route back to the Starting City for the current Starting Region content. On successful arrival it releases the completed expedition and hands the hero back to the normal `VISITING_MARKET` city flow. It also owns dungeon-specific 100-tick death/resurrection + city-recovery state. On failure it reports the attempt-start Power and reached progress so retry memory can be recorded. Potion selection/consumption does not live inside `DungeonRunner`: `Simulation` asks `PotionPreparationSystem` to apply approved healing inside the existing one-tick preparation window before advancing the runner to the next encounter. Combat itself remains the shared `CombatSession`; `QuestRunner` is not reused for dungeon execution.

### `scripts/dungeons/dungeon_evaluator.gd`
Owns only the current dungeon retry-readiness Power rules without participating in QuestScore. A first attempt has no Power retry gate. After failure it requires current base HeroPower to reach the remembered threshold from that failed attempt: **+25%** when no ordinary enemy was killed, **+15%** after at least one ordinary victory without reaching the boss, or **+10%** after reaching the boss. The comparison uses the HeroPower recorded at the start of that failed attempt. `Simulation` combines this Power result with the separate mandatory full-Belt potion-preparation result before starting travel.

### `scripts/narrative/dungeon_narrator.gd`
Presentation-only dungeon combat/debug narration for encounter starts/actions, victories, one-tick preparation, death/resurrection/recovery, and completion. It does not resolve combat or change dungeon state.

### `tests/test_dungeon_map_discovery.gd`
Protects first-dungeon placement, reservation, unknown/known state, physical discovery, Divine Vision discovery, and the current 40%-visible developer marker before discovery.

### `tests/test_first_dungeon_content.gd`
Protects both current Starting Region dungeon definitions, including their fixed 3+boss structures, forest/hill placement constraints, approximately 200/300 and 600/750 Power tuning, XP values, absence of per-mob Gold/equipment drops, and compressed ilvl 5/10 completion sources.

### `tests/test_dungeon_post_quest_decision.gd`
Protects the current autonomous decision boundary: discovery cannot interrupt the active quest, the normal quest turn-in → market → shopping routine still completes first, a known local dungeon then takes priority over another ordinary quest, missing potion purchases consume one dedicated preparation world tick before travel, and the hero physically travels to its real map hex where the first encounter becomes ready without an extra arrival-delay tick.

### `tests/test_dungeon_combat_sequence.gd`
Protects the shared live combat loop across both current Starting Region dungeons: three ordinary fights, one preparation tick between encounters including before the boss, carried HP, boss completion, authored XP/Gold/item-level rewards, completed-map reservation removal, return travel, and dungeon-owned death/instant-resurrection behavior. The Blackfang path specifically protects its 1100 total combat XP, +2000 Gold, and one compressed ilvl 10 Rare/Epic item.

### `tests/test_dungeon_completion_reward.gd`
Protects the exact 75% Rare / 25% Epic completion roll for both Starting Region dungeons, their full twelve-slot compressed ilvl 5/10 source pools, normal three-affix Epic generation for standard equipment, and the affixless Belt exception whose rarity instead controls potion capacity.

### `tests/test_dungeon_retry_readiness.gd`
Protects the +25% / +15% / +10% retry thresholds, persistent failed-attempt Power/progress memory, blocking an immediate same-Power retry after first-room death, and allowing a later retry once the remembered required HeroPower is reached.

### `tests/test_belt_and_healing_potions.gd`
Protects the current compressed Level 5 / 10 potion data and supplied sprites, 1 / 2 / 3 / 4 Belt capacities, Belt-level potion eligibility, Belt comparison by total potential healing then inherent Health, full-slot preparation, healing-maximizing affordable mixed loadouts, one dedicated purchase tick when missing potions must be bought, multiple potion consumption in one between-fight window, allowed pre-boss overheal, mandatory full-Belt dungeon readiness, and the rule that a Belt purchase must not spend Gold needed to fill its resulting larger loadout.

## God system

### `scripts/god/god_state.gd`
Owns energy, six-tick recovery progress, ability cooldowns, pending quest guidance, and resurrection energy cost. The active blessing and its remaining fights live in `HeroState.active_effects`.

### `scripts/god/god_system.gd`
Owns divine-command rules and applies them through the existing state owners: live/non-combat healing, instant resurrection through whichever active respawn owner currently owns the death state (`QuestRunner` or `DungeonRunner`), five-fight blessing activation/consumption in `HeroState.active_effects`, and validation of quest-guidance targets. It returns structured results where coordination is still required. `Simulation` keeps the stable public command wrappers, refreshes resolved stats after blessing changes, and records context-appropriate resurrection narrative.

### `tests/test_god_state.gd`
Protects energy, recovery, cooldown activation rules, guidance consumption, and resurrection cost.

### `tests/test_god_abilities_integration.gd`
Protects Simulation integration for healing, instant resurrection, +15% resolved Physical Damage combat buff through `StatResolver`, unchanged base HeroPower while that temporary effect is active, and one-selection `DivineModifier = +0.20`.

### `tests/test_god_ui.gd`
Protects god-panel placement, energy display, startup safety, and state-based availability of healing, blessing, and resurrection.

## Narrative

### `scripts/narrative/quest_narrator.gd`
Turns quest/combat/death events into current Russian debug-log text.

### `scripts/narrative/debug_log.gd`
Technical log store. Retains only the last 100 world ticks; multiple combat lines from one fight share the single world tick consumed by that fight.

### `scripts/narrative/diary.gd`
Empty diary store; diary generation is not implemented yet.

## UI

### `scripts/ui/main_ui.gd`
Top-level developer UI coordinator and screen-navigation owner.

Displays:
- persistent top navigation;
- hero panel left;
- god energy and Healing/Blessing/Resurrection controls above the narrative panel;
- log/diary center;
- active opponent right;
- current death-respawn countdown through the hero state label;
- fixed bottom-right cumulative combat-statistics panel.

`MainUI` instantiates the lightweight Hero development view plus the dedicated Inventory, Map, God, and Narrative components and passes them the existing `Simulation`. The Hero view shows pending primary-attribute points and five allocation buttons that call `Simulation.allocate_primary_attribute()`; it does not own stat rules. It also currently contains four presentation-only personality-axis previews fixed at neutral `0`, with −100/+100 endpoints and only the ±40 activation-threshold markers visible in that neutral state. The future ±20 return-to-neutral markers are reserved for the later real active-trait state and are not shown yet; these previews are deliberately not connected to `HeroState`, quest selection, combat, or any trait-development logic. Switching screens changes visibility only; the same `Simulation` instance continues advancing.

### `scenes/ui/screens/inventory_screen.tscn`
Dedicated Inventory screen root instantiated by `MainUI`.

### `scripts/ui/screens/inventory_screen.gd`
Owns Inventory presentation: the scaled hero portrait and armor overlays, equipment slots, the `6 × 6` retained-equipment grid, and a separate scrollable vertical healing-potion column immediately to the right of jewelry. Every owned bottle receives its own visual slot using the supplied potion sprite and tooltip; there are no `×N` potion stacks. Potion presentation remains separate from the 36 retained-equipment capacity. It reads equipment/inventory state from the supplied `Simulation` but does not grant, equip, replace, drop, buy, or consume items. Live outline colors cover Green/Uncommon, Blue/Rare, and Purple/Epic so dungeon Epic rewards do not inherit the blue color of their shared Rare visual definition.

### `scripts/ui/map_tile_visuals.gd` / `assets/map/biomes/*.png` / `assets/map/characters/` / `assets/map/activities/`
Presentation-only map visual source. `MapTileVisuals` exposes three authored `158 × 140` RGBA PNG variants each for plains, forest, and hills plus the authored `418 × 440` `town1.png`. Biome variants are chosen deterministically from hex coordinates. Road and city cells temporarily reuse plains variants as their base terrain visuals; both city clusters then receive the same town overlay. The helper also resolves the optional high-resolution hero map sprite from `assets/map/characters/hero_map.png` and the supplied `426 × 400` quest activity sprite from `assets/map/activities/quest.png`. The helper does not own terrain, regions, map topology, hero position, quest placement, or gameplay state.

### `scenes/ui/screens/map_screen.tscn` / `scripts/ui/screens/map_screen.gd`
Dedicated Map screen. It renders terrain cells from the runtime `HexDefinition` data using the 1:1 biome textures supplied by `MapTileVisuals`, with one-pixel black outlines on non-city hexes. City cells use plains base sprites without internal outlines, and each seven-hex city cluster receives the same native-size `418 × 440` `town1.png` overlay, horizontally centered on the city-center hex and bottom-aligned to the full cluster. The existing road line remains drawn over temporarily plains-backed road cells but underneath the town overlays. Current quest-board offers with live `target_hex` reservations are drawn with the supplied `assets/map/activities/quest.png` sprite over their real target cells. The 426 × 400 source remains unchanged and is scaled only at draw time to 65 px tall (about 69.2 × 65 px), centered on the target hex. Hovering a quest sprite resolves the concrete `QuestOffer` and shows its player-facing `display_name`; outside quest sprites the same tooltip continues to expose the hovered hex's coordinates, terrain, region, and permanent semantic tags. The old fixed terrain legend is no longer rendered because its schematic swatches do not represent the authored biome/city sprites seen by the player. The currently selected `active_quest` receives a brighter three-layer orange rarity-style outline (`#FF8C00`) around its quest sprite; selection/marker changes trigger redraws and the quest sprites scale/pan with the map. The live hero position still comes from `Simulation.world_state.hero_position`, and its presentation uses the high-resolution hero map texture scaled at draw time to 120 px tall at base zoom, centered horizontally on the current hero hex and shifted 5 px upward. Map-backed ordinary quest travel now changes that live hero position by one adjacent route hex per world tick through `TravelSystem`. Mouse-wheel input zooms the map from 0.6× to 2.0× around the cursor, and holding the right mouse button while dragging pans the enlarged sprite-based map inside clamped bounds. The transform applies only to map content; fixed screen UI and the tooltip are not scaled or panned. The screen remains observation-only and does not choose quest destinations, reserve targets, move the hero, calculate routes, advance travel, reveal hidden locations, or otherwise modify Simulation.

Active temporary events are drawn by `MapScreen` as presentation-only translucent dark-blue polygons over every hex in the event's current `placement_radius` footprint. The normal radius-1 event therefore shades seven hexes, and quest/dungeon/hero markers are rendered above the area tint.

### `scenes/ui/components/god_panel.tscn` / `scripts/ui/components/god_panel.gd`
Owns the God panel presentation and button commands: energy, cooldowns, healing, combat blessing, and instant resurrection. It sends approved requests through the supplied `Simulation` and reports hero-display changes back to `MainUI` through a signal.

### `scenes/ui/components/narrative_panel.tscn` / `scripts/ui/components/narrative_panel.gd`
Owns the current Log/Diary tab container, subscribes to `DebugLog` and world-tick updates, and keeps wrapped log output scrolled to the newest entry. It displays narrative state but does not create gameplay outcomes.

`assets/hero/hero_reference.png` is the unchanged supplied `441 × 800` RGBA reference image currently displayed at `256 × 464` over an explicit dark backing panel. All five armor slots plus the main-hand and off-hand slots display equipped state. The right accessory column exposes stable slots for necklace, earrings, two separate rings, and belt; all twelve current equipment slots now display equipped state. Immediately beside it, the potion column displays one owned healing-potion bottle per `82 × 82` slot and scrolls vertically if the owned count exceeds the visible column. Helmet, gloves, pants, and boots use supplied `300 × 300` RGBA PNG icons under `assets/items/icons/ironward_vanguard/`; chest, sword, and shield retain their current icon assets. Helmet, chest, gloves, pants, and boots each provide a dedicated `441 × 800` paper-doll overlay under `assets/items/overlays/ironward_vanguard/`; the UI layers equipped armor over the base hero in stable back-to-front order. The 36 inventory cells display retained equipment item instances and remain independent of potion presentation. Equipped/equipment-inventory icons share the generated-item tooltip, while each potion slot shows its potion definition tooltip; `assets/shaders/item_quality_outline.gdshader` provides the rarity outline for generated equipment.

## Item data

### `scripts/model/definitions/item_definition.gd`
Immutable item card: id, display name, equipment slot, icon, hero overlay, current stat bonuses, and an optional authored reference-shop-value override used by the low-value starting outfit.

### `scripts/model/runtime/item_instance.gd`
One concrete acquired equipment item referencing its immutable definition. Belt tooltips additionally expose live potion capacity, maximum supported potion level, and potential full-loadout healing without converting that utility into fake Power.

### `scripts/model/definitions/healing_potion_definition.gd` / `data/items/consumables/healing_potion_ilvl10.tres` / `healing_potion_ilvl20.tres`
Immutable healing-consumable data for the currently live Starting City tiers. Compressed Level 5 heals 100 HP for 100 Gold and still uses the legacy-named `assets/items/icons/consumables/healing_potion_ilvl10.png`; compressed Level 10 heals 150 HP for 200 Gold and still uses the legacy-named `assets/items/icons/consumables/healing_potion_ilvl20.png`. Both supplied sources are 550 × 550. These consumables are fixed shop availability rather than rotating equipment listings.

### `scripts/items/belt_potion_rules.gd`
Central Belt utility rules: Common / Uncommon / Rare / Epic capacities of 1 / 2 / 3 / 4, `PotionLevel <= BeltLevel`, strongest supported current potion lookup, and the potential full-loadout healing value used by Belt comparison. It does not buy, store, or consume potions.

### `scripts/items/item_power_calculator.gd`
Calculates generated ItemInstance ItemPower through the shared `PowerCalculator`. It applies all inherent and affix stats to the approved fixed reference profile and subtracts that profile's baseline Power, avoiding arbitrary item-score coefficients. A compatibility path remains for old definition-level test data, but live equipment uses instance stats.

### `scripts/model/definitions/item_modifier_budget_table_definition.gd` / `data/items/balance/item_modifier_budget_table.tres`
Central Scope 19 budget data: Green affix budgets for compressed ilvl 1/5/10/15/20/25/30, preserving the old per-tier values, plus 0/1/2/3 affix counts, 1.0/0.85/0.7225 per-affix rarity multipliers, the 30% adjacent-tier growth target, and the one-time 0.95–1.05 total-budget roll.

### `scripts/model/definitions/item_modifier_stat_cost_table_definition.gd` / `data/items/balance/item_modifier_stat_costs.tres`
Central Scope 19.5 conversion costs from modifier budget into Health, Armor, Dodge, Accuracy, Damage, critical stats, speed stats, elemental Resistance, and Block. Primary attributes are absent from the table.

### `scripts/model/definitions/item_base_stat_table_definition.gd` / `data/items/balance/item_base_stat_table.tres`
Central inherent base-stat control points for compressed ilvl 1/5/10/15/20/25/30 with the old stat values preserved one-for-one. Current generated items use armor Armor, sword Damage/+0.10 Attack Speed, shield Block, and jewelry elemental Resistance from this table.

### `scripts/items/item_generator.gd`
Creates one generated `ItemInstance` from a visual item definition, source Item Level, and the shared seeded RNG. It resolves inherent stats, rolls the item-wide modifier budget where allowed, selects unique slot-legal affixes, splits budget equally, converts budget through stat costs, and stores both readable affixes and combat-ready resolved values. Necklace, earrings, and both ring slots each receive one seeded inherent Fire/Cold/Lightning Resistance and use only the approved jewelry affix pool. Belt reads inherent Health from the shared base-stat table and intentionally skips the ordinary random-affix budget because Belt rarity now controls potion capacity through `BeltPotionRules`. Normal generation uses the definition rarity; completion rewards may pass an explicit ItemInstance rarity override so standard Ironward equipment can become mechanically real Epic/Purple without duplicating visual definitions.

### `scripts/hero/equipment_evaluator.gd`
Performs candidate equipment evaluation without mutating live Equipment. Standard equipment resolves current/candidate base persistent CombatStats and recommends replacement only for a strict shared-HeroPower increase. Ring candidates are the positional-slot exception inside that same Power rule: the evaluator virtually tries both `ring_1` and `ring_2`, returns the target slot whose replacement gives the highest final HeroPower, and routing/shop code preserves that chosen target. Belt is the separate utility exception: compare potential full-loadout potion healing first, then inherent Belt Health on an exact utility tie. Temporary effects remain excluded.

### `scripts/model/definitions/item_price_table_definition.gd` / `data/items/balance/item_price_table.tres`
Central current equipment reference values for compressed ilvl 1/5/10. White control points remain 100/500/1000 Gold, Green uses ×3, Rare uses the approved current ×9 extension, and resale uses 10% of reference value. Undefined Item Levels/rarities remain unpriced instead of silently extrapolating.

### `scripts/economy/item_price_calculator.gd`
Reads the central price table and returns reference shop value or resale value for an Item Level/rarity pair or a concrete generated `ItemInstance`.

### `scripts/economy/equipment_sale_system.gd`
Owns automatic ordinary-equipment liquidation from Inventory. It removes only priced unequipped instances, totals their resale values, adds Gold to `HeroState`, and returns a structured sold-items/count/Gold result. Quest turn-in schedules `VISITING_MARKET`; `Simulation` invokes the sale system on the following dedicated world tick, then enters the separate `SHOPPING` phase.

### `scripts/model/definitions/shop_definition.gd` / `scripts/model/definitions/shop_stock_band_definition.gd` / `data/shops/starting_city_shop.tres`
Defines the Starting City shop and its three immutable authored stock bands: ilvl 1 Rustchain Initiate, compressed ilvl 5 Ironwake core plus its existing accessories, and compressed ilvl 10 Ironward Vanguard core equipment plus its own accessories. Each owns its source item definitions plus 6 White/2 Green listing counts. The same `ShopDefinition` separately references the fixed compressed Level 5 / 10 healing-potion availability. Equipment bands do not duplicate generated stats, affix budgets, ItemPower, or price data.

### `scripts/economy/shop_system.gd`
Owns mutable equipment stock, deterministic equipment refresh, purchased vacancies, equipment purchase transactions, and read access to the shop's fixed healing-potion definitions. It generates real `ItemInstance` listings through the shared `ItemGenerator`, refreshes equipment independently of hero presence on ticks divisible by 200, deducts equipment price, equips the purchased instance, and immediately converts replaced ordinary equipment into its normal resale Gold instead of routing it through Inventory.

### `scripts/economy/spending_evaluator.gd`
Owns the current autonomous equipment-purchase comparison. Standard equipment filters for affordability plus the Scope's +20% ItemPower threshold and then validates real virtual-equip HeroPower. Belt candidates bypass that ordinary threshold and use the Belt-specific utility decision from `EquipmentEvaluator`. `Simulation` may supply a reduced available-Gold budget when dungeon potion preparation must be protected. The evaluator does not mutate equipment or Gold.

### `scripts/economy/potion_preparation_system.gd`
Owns the current dungeon healing-consumable preparation/use rules. It finds the highest-total-healing **complete** affordable loadout for the equipped or proposed Belt using shop potion definitions and existing Inventory potion counts, can execute the purchase of only missing potions, records the prepared Belt levels on `HeroState`, and consumes physical Inventory counts during dungeon preparation windows. `Simulation` owns the timing boundary: if the selected full loadout needs purchases, it enters `PREPARING_DUNGEON` and executes that purchase once on the next world tick before travel; an already-owned complete loadout adds no artificial purchase tick. Ordinary-room use chooses the potion combination that restores the most HP without overheal, preferring fewer potions on an equal result; pre-boss use may consume multiple potions and accept overheal to reach full HP as closely as possible. The preparation system does not own dungeon travel/combat or equipment generation.

### `scripts/loot/loot_generator.gd`
Owns source-driven equipment rolls. Ordinary mob equipment keeps its configured 5% drop chance and Common/Uncommon/Rare 70%/25%/5% split; ilvl 1 sources roll seven equal slots, while both compressed ilvl 5 and ilvl 10 sources roll all twelve equipment slots including necklace, earrings, both rings, and Belt. Dungeon completion uses the same twelve-slot compressed ilvl 5 source but keeps its separate guaranteed 75% Rare / 25% Epic roll. `LootGenerator` selects source/slot/rarity only; `ItemGenerator` still creates the concrete stats.

### `scripts/loot/equipment_reward_system.gd`
Owns generated-equipment reward routing after a source is resolved. It asks `LootGenerator` and `ItemGenerator` for a concrete candidate where applicable, including the new guaranteed dungeon-completion roll, evaluates that candidate through `EquipmentEvaluator`, and mutates only the hero's Equipment/Inventory routing. It returns structured result data; `Simulation` grants the authored dungeon Gold, keeps public reward entry points, refreshes resolved combat stats/HP when equipment changes, and writes the current debug-log text.

### `scripts/model/definitions/equipment_drop_table_definition.gd` / `data/loot/*.tres`
The immutable drop tables store source item level, drop chance, and three aligned rarity pools. The lower-band mobs use the stable seven-slot `ironwake_sentinel_ilvl1_drop_table.tres` resource, whose content points to Rustchain Initiate. The middle band and the first dungeon completion reward use the twelve-slot `initial_equipment_drop_table.tres`, now compressed to ilvl 5 while keeping the former ilvl 10 stats; it combines seven Ironwake core slots with five accessory slots. The higher band uses the legacy-named `ironward_vanguard_ilvl20_drop_table.tres`, now compressed to ilvl 10 while keeping the former ilvl 20 stats; it combines seven Ironward core slots with five separate Ironward Vanguard accessory slots. The first dungeon applies its own guaranteed Rare/Epic rarity override to the compressed ilvl 5 source.

### `data/items/visual_families/ironward_vanguard/`
Contains the live compressed ilvl 10 Ironward Vanguard core family plus separate necklace, earrings, Ring 1, Ring 2, and Belt definitions in Common/Uncommon/Rare variants, alongside the compressed ilvl 5 accessory set. The five core armor pieces keep their supplied visuals; core sword/shield retain neutral placeholders. All twelve compressed ilvl 10 slots are connected to the seven higher-band ordinary mobs and the third Starting City shop band, but not to the first dungeon. Each tier's two mechanical ring slots share one supplied icon. Accessory icons appear only in equipment/inventory slots and provide no hero overlay. Belts contribute inherent Health, have no ordinary random affixes, and receive live potion capacity from rarity plus potion-level eligibility from Item Level, so the compressed ilvl 10 Belt supports compressed Level 10 bottles. Live inherent and random combat stats are generated on `ItemInstance`; old serialized experimental stat fields are ignored by current runtime generation.

### `data/items/visual_families/ironwake_sentinel/`
Contains the seven live core compressed ilvl 5 `Страж Железного Следа` (`Ironwake Sentinel`) definitions in Common, Uncommon, and Rare variants. They occupy the seven armor/weapon/shield positions in the same full middle-tier mob/shop/dungeon source; only the Item Level label was compressed, while the generated stats remain the former ilvl 10 values. The five armor slots use supplied 300 × 300 icons and aligned 441 × 800 hero overlays under `assets/items/icons/ironwake_sentinel/` and `assets/items/overlays/ironwake_sentinel/`. Sword and shield currently reuse the existing neutral placeholder icons and have no hero overlays. The supplied armor artwork is integrated unchanged, including its current green edge remnants.

### `data/items/visual_families/rustchain_initiate/`
Contains the 21 live ilvl 1 `Посвящённый Ржавой Цепи` (`Rustchain Initiate`) definitions: five armor pieces, sword, and shield in Common/Uncommon/Rare. The supplied 300 × 300 icons and 441 × 800 armor overlays are preserved unchanged under matching `assets/items/icons/rustchain_initiate/` and `assets/items/overlays/rustchain_initiate/` paths. The family replaces only the visuals/identity of the existing seven-slot ilvl 1 source; drop chance, rarity distribution, stats, mob assignments, shop counts, and economy remain unchanged. The supplied sword and shield icons have no hero paper-doll overlays.

### `data/items/starting_equipment/`
Contains the three Common starting definitions: `Поношенная рубаха` (Chest), `Поношенные штаны` (Pants), and `Поношенные сапоги` (Boots). Their supplied unchanged 300 × 300 icons and 441 × 800 overlays live under matching `assets/items/icons/starting_equipment/` and `assets/items/overlays/starting_equipment/` directories. `Simulation` creates fixed ilvl 1 instances with exactly +1 Armor each and no affixes; their authored 10-Gold reference-value override produces a 1-Gold resale value through the normal price calculator.

Every current mob references its assigned source-driven equipment table. After each defeated mob, `Simulation` delegates the equipment-reward operation to `EquipmentRewardSystem`, which preserves the seeded `LootGenerator → ItemGenerator → EquipmentEvaluator` chain. Strict improvements equip and replaced/rejected instances enter FIFO Inventory; `Simulation` then refreshes resolved stats/HP and records the result. Current quest definitions contain Gold rewards only.

Item tooltips read the generated instance and display rarity, ilvl, rolled budget, inherent stats, affixes, dynamic ItemPower, reference shop value, and sell price.

The hero panel displays stable base Attack/HeroPower and shows temporary blessing and conditional trait combat bonuses separately. During the current economy flow `VISITING_MARKET` means the dedicated sale tick and `SHOPPING` means the separate autonomous-purchase phase.

The god panel updates energy, cooldowns, buff charges, resurrection cost, and button availability every frame. Active combat blessing displays its remaining fights and already-running cooldown together. Quest-guidance controls are intentionally deferred, although the headless Simulation command is implemented.

Debug-log presentation ignores identical repeated text updates, keeps real new entries pinned near the bottom immediately, and then corrects to the final wrapped bottom after UI layout completes. This avoids visible top-to-bottom jumping while preserving newest-entry autoscroll.

### `tests/test_debug_log_autoscroll.gd`
Protects automatic scrolling to the actual bottom for long wrapped log entries.

## Quest and mob data

Concrete tuning lives in:
- `data/mobs/`;
- `data/quests/`.

Quest selection does not hard-code individual quest files. `QuestPool` discovers current quest `.tres` resources from the quest directory.

Current content contains 22 Starting City mob definitions and 22 matching quest templates. Their exact combat/reward numbers are tuning data rather than architectural contracts unless a test explicitly protects a progression relationship or data validity rule.

## Tests

### `tests/test_quest_pool.gd`
Protects automatic discovery of quest resources from `data/quests`.

### `tests/test_quest_offer_randomization.gd`
Protects seeded integer offer rolls, per-mob reward calculation, and preservation of unaccepted offers when one is replaced.

### `tests/test_quest_template_offer_boundary.gd`
Protects the boundary: templates retain only ranges, while `QuestOffer` owns the rolled values and derives total Gold.

### `tests/test_initial_city_content_expansion.gd`
Protects all 22 Starting City mob/quest pairs: unique IDs, valid quest ranges, strict mob-Power ordering, explicit 8/7/7 bands, and the approved gradually widening approximately 30-to-650 Power progression curve.

### `tests/test_quest_offer_refresh_lifecycle.gd`
Protects the Simulation-to-QuestPool integration for removing an accepted offer from the available board immediately, preserving its active map target, and starting completion cooldown without an immediate replacement.

### `tests/test_quest_offer_cancelled_lifecycle.gd`
Protects immediate removal/release of a cancelled active quest plus independent global board rotation during death and city recovery; cancellation does not receive the completion cooldown.

### `tests/test_quest_evaluator.gd`
Protects the standard 55–95% Hard Filter window, weakest-mob normalization, estimated quest time, and strict highest QuestScore selection using in-memory test data.

### `tests/test_quest_selection_balance.gd`
Protects the current Starting City balance pass: the reduced Stone Bridge reward, varied enemy-count rolls on stronger quests, full twenty-two-template Hard Filter coverage across the tested Power curve, the temporary all-eligible-template board mode, and varied suitable winners across sampled offer rolls.

### `tests/test_autonomous_quest_choice.gd`
Integration coverage that `Simulation` selects first and `QuestRunner` executes the already selected quest.

### `tests/test_personality_traits.gd`
Protects seeded compatible starting traits and the approved QuestScore formulas.

### `tests/test_trait_combat_bonus.gd`
Protects the 10% Noble/Dishonorable category bonus in actual combat damage.

### `tests/test_goblin_definition.gd`
Protects Goblin identity/category plus generic valid combat-data constraints without freezing ordinary tuning values.

### `tests/test_wolf_definition.gd`
Protects Wolf identity/category, generic valid combat-data constraints, and the current progression relationship `WolfPower > GoblinPower` without freezing the old 20.38 calibration card.

### `tests/test_wolf_quest_definition.gd`
Protects the Wolf quest template's approved integer ranges.

### `tests/test_bear_definition.gd`
Protects Bear identity/category, generic valid combat-data constraints, and the current progression relationship `BearPower > WolfPower` without freezing the old 20.38 calibration card.

### `tests/test_bear_quest_definition.gd`
Protects the Bear quest template's approved integer ranges.

### `tests/test_combat_statistics.gd`
Protects cumulative fight/win/loss/winrate counting.

### `tests/test_death_respawn.gd`
Integration coverage for:
- lethal combat defeat;
- quest cancellation;
- retained progression;
- no losing-mob XP / no quest Gold;
- 100 dead ticks;
- resurrection at 1 HP;
- city recovery to full HP.

Existing combat, quest, progression, clock, RNG, data, and narrative tests remain in place.

### `tests/test_starting_armor_set.gd`
Protects the fixed three-piece Common starting loadout, +1 Armor per item, +3 total equipment Armor, exact supplied texture canvases, Inventory/paper-doll presentation, normal replacement by stronger found gear, and 1-Gold resale.

### `tests/test_equipment_visual_tier_shift.gd`
Protects Rustchain across the unchanged ilvl 1 drops/shop, Ironwake across the seven core slots of the compressed ilvl 5 drops/shop/dungeon source, its compressed ilvl 5 accessories, the twelve-slot compressed ilvl 10 Ironward source/shop band, and Rustchain inventory/paper-doll rendering. The legacy-named `test_ilvl20_accessories_and_belt.gd` narrowly protects the supplied high-tier accessory icons, both ring slots, drop/shop connectivity, compressed dungeon tiers, and compressed Level 10 potion support on the high-tier Belt.
