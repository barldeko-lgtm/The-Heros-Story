# The Hero’s Story — Project Map

This document is a **navigation map of the current project**.

Use it to answer:

- where a system lives;
- which file owns a responsibility;
- which nearby files are usually involved in a change;
- which layer should *not* receive that logic.

It is intentionally not a second gameplay specification. Current implemented behaviour and temporary deviations belong in `current-state.md`; fragile runtime contracts belong in `dependencies.md`; intended Prototype 0.2 design belongs in the Scope.

## Quick routing index

If the task is about...

- **overall simulation flow** → `scripts/core/simulation.gd`;
- **world ticks / pause / speed** → `scripts/core/world_clock.gd`;
- **hero mutable state** → `scripts/hero/hero_state.gd`;
- **XP / level-up / primary-point spending** → `scripts/hero/hero_progression.gd`;
- **personality axes / trait activation** → `scripts/hero/trait_development.gd` and `scripts/hero/hero_traits.gd`;
- **resolved hero stats** → `scripts/hero/stat_resolver.gd`;
- **combat rules** → `scripts/combat/`;
- **shared Hero/Mob Power** → `scripts/combat/power_calculator.gd`;
- **world map / routes / occupancy / current city relocation** → `scripts/world/` plus `data/map/`, coordinated by `scripts/core/simulation.gd`;
- **ordinary quest content** → `data/quests/` and `data/mobs/`;
- **quest board / autonomous selection** → `scripts/quests/quest_pool.gd` and `quest_evaluator.gd`;
- **quest execution** → `scripts/quests/quest_runner.gd`;
- **temporary events** → `scripts/events/` and `data/events/`;
- **ordinary dungeons** → `scripts/dungeons/` and `data/dungeons/`;
- **generated equipment / affixes / ItemPower** → `scripts/items/` and `data/items/balance/`;
- **loot routing** → `scripts/loot/` and `data/loot/`;
- **shop / sales / autonomous spending / potions** → `scripts/economy/` and `data/shops/`;
- **God abilities** → `scripts/god/`;
- **debug narration / Diary** → `scripts/narrative/` and `data/narrative/`;
- **player/developer presentation** → `scripts/ui/` and `scenes/ui/`;
- **shared main-screen button/tab appearance** → `scripts/ui/main_screen_button_style.gd`, used by MainUI, GodPanel and NarrativePanel; `tests/test_main_button_style.gd` checks styling and preserved interaction;
- **mini-window status grouping, enter/expand and native window restoration** → `scripts/ui/mini_window_mode.gd`, created by `main_ui.gd`; focused coverage in `tests/test_mini_window_mode.gd` and `tests/test_mini_window_status.gd`;
- **regression coverage** → `tests/`.

## Project root

- `project.godot` — Godot project configuration and main-scene registration.
- `scenes/main/startup.tscn` — normal application root: background questionnaire → story and Warrior selection (three locked classes) → game.
- `scenes/main/main.tscn` — direct MainUI scene retained for isolated game-UI use/tests; normal startup injects its newly created Simulation into MainUI.
- `.github/workflows/tests.yml` — GitHub Actions test workflow.
- `assets/` — visual source assets and shaders used by current UI.
- `data/` — immutable authored/tuning resources.
- `scenes/` — Godot scenes.
- `scripts/` — runtime, gameplay, narrative and UI code.
- `tests/` — deterministic and integration regression tests.
- `docs/` — Scope, current state, project map, dependencies and working checklist.

Several future Prototype 0.2 folders exist only as `.gitkeep` scaffolding. An empty directory is not an implemented system.

## Core coordination

### `scripts/core/simulation.gd`

Top-level runtime coordinator for the current prototype.

It creates/owns the major runtime systems, advances the autonomous hero loop, coordinates hand-offs between systems, refreshes resolved stats after state changes, forwards structured facts to narrative/log stores, and exposes stable command boundaries used by UI/tests.

Important boundaries:

- it coordinates systems but should not absorb their internal rules;
- combat rules remain in `scripts/combat/`;
- quest scoring remains in `QuestEvaluator`;
- authored event logic remains in event data/runner;
- item generation/evaluation remains in item/loot systems;
- narrative text generation remains in `scripts/narrative/`;
- UI must call Simulation/gameplay boundaries rather than mutate gameplay state directly.

The constructor still supports a fixed-quest compatibility path for old tests; the normal developer build uses autonomous quest selection. See `current-state.md` for the current compatibility details.

### `scripts/core/world_clock.gd`

Single world-tick authority. Tracks elapsed partial tick progress and completed world ticks. Simulation applies time scale before advancing it.

### `scripts/core/seeded_rng.gd`

Seeded randomness helper used by the simulation and derived deterministic streams. Systems that must not perturb gameplay randomness should use their own derived stream rather than casually consuming the main sequence.

### `scripts/core/hero_name_repository.gd` / `data/hero_names_ru.txt`

Loads the authored Russian hero-name list and returns a seeded random name with a fallback when the file is empty.

## Shared model types

### `scripts/model/runtime/combat_stats.gd`

Plain resolved combat-stat container shared by hero and mobs: HP, attack, attack speed, Accuracy, Dodge, Armor, Resistances, Block and critical values.

### `scripts/model/definitions/mob_definition.gd`

Immutable mob card: identity/category, authored base combat values, XP/Gold fields and optional equipment-drop source. Converts itself to `CombatStats` and uses the shared `PowerCalculator` for Power.

Concrete ordinary mobs live under `data/mobs/`; dungeon-only mobs live beside their owning dungeon content.

## Hero state, progression and stats

### `scripts/hero/hero_state.gd`

Central mutable hero state.

Owns, among other things:

- hero identity and current HP/progression state;
- current autonomous loop-state id;
- current normal-city context id (`starting_city` / `mid_city`) plus the shared authored display names **Дорнвальд** / **Арден**;
- primary attributes and pending player-distributed points;
- hidden personality-axis values and established trait per axis;
- learned Warrior ability Skill Levels;
- temporary active effects;
- equipped items through `Equipment`;
- retained items and potion counts through `Inventory`;
- prepared Belt potion levels.

It stores state; rule-heavy calculations should remain in their owning systems.

### `scripts/hero/hero_background.gd` / `data/hero/starting_background.json`

Authored four-question background and Hero-layer answer validation/resolution/application. Grants fixed attribute increments and routes signed personality shifts through TraitDevelopment. Validates the full selection before mutation and uses HeroState.background_answers to reject repeat application. Simulation applies this at construction before StatResolver/full-HP initialization; UI only selects answer indices.

### `scripts/hero/hero_recovery.gd`

Shared stateless death-recovery rules used by QuestRunner, DungeonRunner and EventRunner: respawn countdown calculation, resurrection HP/state, and city healing/full-recovery transition. Uses supplied current CombatStats; owns no timer, activity context, world time, travel, rewards or narration. Existing runner constants alias the shared tuning; ordinary post-victory quest recovery remains separate.

### `scripts/hero/hero_progression.gd`

Owns XP application, level-up growth, pending primary-point creation/spending and current automatic Warrior ability unlocks.

### `scripts/hero/hero_traits.gd`

Owns the canonical current trait IDs/display names and the small constants/helpers that are genuinely trait-specific, including the temporary seeded starting-trait pool and current trait-linked quest/combat modifiers.

### `scripts/hero/trait_development.gd`

Owns the four personality axes, clamping, activation/hysteresis transitions, mapping between axis sides and visible traits, starting-trait initialization and authored Formative movement.

`HeroState` stores values; `TraitDevelopment` owns transition rules.

### `scripts/hero/equipment.gd`

Owns currently equipped `ItemInstance` objects by equipment slot and exposes the equipped loadout to stat calculation/evaluation.

It does not decide whether an item is better.

### `scripts/hero/inventory.gd`

Owns retained unequipped equipment in FIFO order plus persistent healing-potion counts. Consumables are separate from the equipment FIFO capacity.

### `scripts/hero/stat_resolver.gd`

Single hero-stat resolution path.

Builds:

- base persistent `CombatStats` used by base HeroPower and stable comparisons;
- effective `CombatStats` including current temporary effects for live combat.

Consumes hero progression/attributes/equipment/effects. It does not resolve hit chance, mitigation outcomes or quest selection.

### `scripts/hero/equipment_evaluator.gd`

Evaluates a candidate item without mutating live equipment.

Ordinary equipment uses virtual replacement plus the shared resulting HeroPower. Rings are compared against both ring positions. Belt uses its separate potion-utility rule rather than pretending potion capacity is ordinary Power.

## Combat

### `scripts/combat/combat_simulator.gd`

Factory/entry helper that creates one live duel from already resolved hero and mob `CombatStats`.

### `scripts/combat/combat_session.gd`

Owns one active duel: internal combat time, live HP, attack opportunities, hit/crit/block resolution calls, fight-local Rage, current autonomous Warrior abilities and final victory/defeat state.

It must not own quest cancellation, resurrection, shop logic, dungeon progression or God-system state.

### `scripts/combat/combat_action.gd`

Structured facts for one resolved attack/action: action id, hit/miss, crit, block, damage type and final damage.

### `scripts/combat/combat_result.gd`

Structured result of one completed duel.

### `scripts/combat/damage_resolver.gd`

Shared combat formulas for hit chance, Armor/Resistance mitigation and Block behaviour. Both hero and mobs use the same rules.

### `scripts/combat/power_calculator.gd`

Single shared Power calculation for `CombatStats`.

Do not create a separate HeroPower or MobPower formula elsewhere. Hero, mob and virtual equipment comparisons ultimately rely on this shared calculation.

## World map, placement and travel

### `scripts/model/definitions/hex_map_definition.gd`

Immutable authored map-source contract: logical dimensions, PNG sampling geometry, adjacency convention, decoded terrain/city/road structure and validation.

### `scripts/model/definitions/hex_definition.gd`

One runtime logical map cell: coordinates, terrain id, region id and permanent semantic tags. Current shared tag queries go through this type.

### `scripts/world/hex_map_image_decoder.gd`

Pure exact-color decoder for the authored technical map PNG. Converts approved source colors into logical terrain/city/road information and validates authored structure.

### `assets/map/prototype_02_hex_layout.png` / `assets/map/README.md`

Editable authored technical world image and its exact-color editing/palette contract.

### `data/map/prototype_02_map.tres`

Authored `HexMapDefinition` resource pointing to the technical PNG and its sampling geometry.

### `scripts/world/hex_map.gd`

Read/query layer over the authored map.

Builds logical `HexDefinition` objects, derives regions/tags, exposes neighbors/radius queries, shortest routes and route distance. It does not choose hero destinations or reserve activities.

### `scripts/world/world_state.gd`

Mutable map state: current hero hex plus active activity reservations/footprints.

Reservations are the shared occupancy boundary for quests, dungeons and events. `WorldState` does not decide which activity should spawn or where the hero should travel.

### `scripts/world/activity_placement_finder.gd`

Pure candidate finder shared by map-backed activities. Filters possible centers by region, distance, terrain/tags, footprint validity and current reservations.

It does not roll RNG, reserve cells or create an activity.

### `scripts/world/travel_system.gd`

Owns one active route toward an already chosen destination and advances the hero through `WorldState` along `HexMap` routes.

Supports suspension/resumption and event detours. It never chooses quests, dungeons, events or city relocation goals.

Current Prototype 0.2 city relocation is chosen by `Simulation` at the Level-13 safe-city decision boundary and then executed by this same normal route system. Mid-Level City gameplay itself is still a later city-context task.

## Ordinary quests

### `scripts/model/definitions/quest_definition.gd` / `data/quests/*.tres`

Immutable ordinary-quest templates.

Own authored combat/reward ranges, strength-band identity and map-placement rules. They do not store rolled runtime values or concrete occupied hexes.

An individual quest may optionally reference its own `QuestDiaryTextDefinition`; otherwise ordinary diary prose uses the shared narrative bank.

### `scripts/model/runtime/quest_offer.gd`

One rolled runtime offer created from a template. Owns the concrete enemy count/reward roll plus current map target/reservation metadata.

### `scripts/quests/quest_pool.gd`

Owns quest-template discovery, the currently available board, creation/removal/refresh of runtime offers, per-template eligibility/cooldown state and current board-offer map reservations.

It does not score offers or execute the accepted quest. Current board-size/timing deviations are documented in `current-state.md` rather than duplicated here.

### `scripts/quests/quest_evaluator.gd`

Owns autonomous ordinary-quest evaluation:

- Hard Filter eligibility;
- current QuestScore components;
- strict best-offer selection;
- ranked copies of the same evaluation records for developer diagnostics.

It evaluates; it does not mutate the board or execute the quest.

### `scripts/quests/quest_runner.gd`

Executes one already selected ordinary quest: travel-state progression, objective progress, post-fight recovery, the post-objective equipment-review gate, return/turn-in and ordinary-quest death/resurrection/city-recovery flow.

It does **not** choose quests, calculate QuestScore, resolve combat internally, generate loot, write diary prose, own God rules or own UI.

### `scripts/quests/quest_event.gd`

Structured quest/runtime facts used by coordination and narrative layers, including selection/completion/death-related events.

## Temporary events

### `scripts/model/definitions/event_definition.gd`
### `scripts/model/definitions/event_stage_definition.gd`
### `scripts/model/definitions/event_option_definition.gd`
### `data/events/starting_region/*.tres`

Immutable authored temporary-event content.

Definitions own placement/lifetime metadata and stage graphs. Stages/options own authored scene timing, decision rules, Formative/Expressive meaning, travel/combat references, rewards/outcomes and event-specific narrative text where appropriate. Current decision data supports both one-trait Expressive checks and an authored any-of-traits check; COMBAT stages may also author a reduced starting current-HP ratio while still referencing an ordinary immutable `MobDefinition` for all combat stats.

Current event content lives in `data/events/starting_region/`; exact authored branches belong in those resources, not in generic event code. The current Starting Region pool contains fifteen resources (`0001`–`0015`). `0005_ogre_at_old_barrow.tres` is the first event to use the any-of-traits Expressive rule and authored partial starting mob HP; events `0006`–`0013` intentionally reuse the established framework for a broader content mix, while `0014_medicine_before_sunset.tres` and `0015_signal_from_old_quarry.tres` add two more real secondary-objective travel stories without introducing one-off event scripts.

### `scripts/model/runtime/event_instance.gd`

Mutable runtime state for one spawned event: reservations/targets, current stage, encounter location, engagement/completion state and local flags.

### `scripts/events/event_system.gd`

Owns event-definition loading, population lifecycle, seeded placement, per-definition availability/cooldown state, map reservations, encounter lookup and cleanup.

It does not execute event stages, move the hero, resolve combat or mutate personality directly.

### `scripts/events/event_decision_resolver.gd`

Reusable resolver for the current authored primary-attribute comparison pattern used by Formative event openings.

### `scripts/events/event_runner.gd`

Executes one engaged event graph.

Handles timed stages, Formative movement through `TraitDevelopment`, single-trait and any-of-traits Expressive checks, event detours through `TravelSystem`, shared-combat requests, event-owned death/recovery flow and resumption of the interrupted activity. The runner exposes the authored current COMBAT stage; Simulation uses that stage's optional starting-HP ratio only when creating event combat, leaving the referenced mob definition immutable.

Combat itself remains `CombatSession`; map population remains `EventSystem`.

### `scripts/narrative/event_narrator.gd`

Developer/debug presentation for event facts. It must not resolve or change event state. Future player-facing event Diary prose should come from the event's authored narrative data rather than generic debug text.

## Ordinary dungeons

### `scripts/model/definitions/dungeon_definition.gd` / `data/dungeons/starting_region/*.tres`

Immutable ordinary-dungeon content: placement constraints, ordinary encounter definition/count, unique boss and completion reward configuration.

Dungeon-only mob resources may live beside the dungeon definition; they are not ordinary quest mobs.

`data/dungeons/mid_region/` is reserved for the later Mid Region ordinary dungeons. `data/dungeons/specialization/` is intentionally separate from the ordinary-dungeon loader.

### `scripts/model/runtime/dungeon_instance.gd`

Mutable runtime state for one placed dungeon: target/reservation, discovery/completion state and failed-attempt memory used by retry evaluation.

### `scripts/dungeons/dungeon_system.gd`

Owns ordinary-dungeon definition loading, deterministic map placement/reservations, discovery/knowledge state, Divine Vision reveal support and cleanup after completion.

It does not execute the expedition or combat.

### `scripts/dungeons/dungeon_evaluator.gd`

Owns current dungeon readiness/retry Power evaluation from persistent attempt memory. It is separate from ordinary `QuestEvaluator` and QuestScore.

### `scripts/dungeons/dungeon_runner.gd`

Owns one approved ordinary dungeon expedition: travel to the dungeon, encounter cursor, carried HP, between-fight state, boss progression, success/return flow and dungeon-combat death/recovery state.

It requests shared `CombatSession` fights. Potion preparation/use remains in `PotionPreparationSystem`. Completed-dungeon map knowledge/reservation remains in `DungeonSystem`.

### `scripts/narrative/dungeon_narrator.gd`

Developer/debug narration for dungeon combat/progression facts only.

## Item definitions and generation

### `scripts/model/definitions/item_definition.gd`

Immutable visual/base item identity: id, name, slot, icon/overlay references and authored definition-level fields.

Concrete generated combat values belong to `ItemInstance`, not to the visual definition.

### `scripts/model/runtime/item_instance.gd`

One acquired/generated equipment item. Owns concrete Item Level, rarity, inherent stats, rolled affixes/resolved values, ItemPower and tooltip-facing generated information.

### `scripts/model/definitions/item_base_stat_table_definition.gd`
### `data/items/balance/item_base_stat_table.tres`

Central inherent-stat control points by item type/Item Level.

### `scripts/model/definitions/item_modifier_budget_table_definition.gd`
### `data/items/balance/item_modifier_budget_table.tres`

Central modifier budgets, affix counts and rarity budget behaviour.

### `scripts/model/definitions/item_modifier_stat_cost_table_definition.gd`
### `data/items/balance/item_modifier_stat_costs.tres`

Central conversion costs from modifier budget to supported secondary stats.

### `scripts/items/item_generator.gd`

Creates a concrete `ItemInstance` from a visual definition, source Item Level/rarity and seeded RNG. Resolves inherent stats, affixes and generated values from shared balance data.

It does not decide whether the hero should equip the result.

### `scripts/items/item_power_calculator.gd`

Calculates generated ItemPower through the same shared `PowerCalculator` using the approved reference-profile method. ItemPower is descriptive/filtering data, not a second HeroPower formula.

### Equipment visual/content data

- `data/items/starting_equipment/` — fixed new-hero clothing definitions.
- `data/items/visual_families/rustchain_initiate/` — current low-tier armor/weapon/shield family.
- `data/items/visual_families/ironwake_sentinel/` — current middle-tier core family.
- `data/items/visual_families/ironward_vanguard/` — current higher-tier core/accessory definitions plus the current accessory resources used across compressed tiers.
- `assets/items/icons/` — inventory/equipment icons.
- `assets/items/overlays/` — paper-doll overlays.
- `assets/shaders/item_quality_outline.gdshader` — rarity-outline shader used by current item presentation.

Exact current tier labels, drop assignments and tuning belong in `current-state.md`/data rather than this map.

## Loot and reward routing

### `scripts/model/definitions/equipment_drop_table_definition.gd` / `data/loot/*.tres`

Immutable equipment-source/drop-pool data: source Item Level, chance and rarity-aligned candidate pools.

### `scripts/loot/loot_generator.gd`

Chooses source/slot/rarity outcome from an approved equipment source. It does not generate final affix stats or mutate the hero.

### `scripts/loot/equipment_reward_system.gd`

Coordinates generated-equipment reward routing. It can either complete the normal route immediately or split generation from later routing for the ordinary-quest post-objective review point:

`LootGenerator → ItemGenerator → EquipmentEvaluator → Equipment/Inventory`

Returns structured result data to its caller. Simulation remains responsible for surrounding activity rewards and stat refresh after equipment changes.

## Economy, shop and potions

### `scripts/model/definitions/item_price_table_definition.gd`
### `data/items/balance/item_price_table.tres`

Central equipment reference-price/resale data.

### `scripts/economy/item_price_calculator.gd`

Reads price data for definitions/generated items and returns reference or resale values.

### `scripts/economy/equipment_sale_system.gd`

Owns automatic liquidation of eligible unequipped ordinary equipment from Inventory and returns a structured sale result.

### `scripts/economy/skill_training_system.gd`

Owns current purchased Skill Level progression. It reads hero-level rank availability from `HeroProgression`, applies the shared rank-cost table, selects an affordable unlocked next rank in deterministic base-skill order, spends Gold and advances that learned rank. It does not advance world time, buy equipment, calculate dungeon-preparation reserve, or write narrative text.

### `scripts/model/definitions/shop_definition.gd`
### `scripts/model/definitions/shop_stock_band_definition.gd`
### `data/shops/starting_city_shop.tres`
### `data/shops/bands/*.tres`

Immutable shop configuration: authored equipment stock bands plus fixed consumable availability.

### `scripts/economy/shop_system.gd`

Owns mutable current shop stock, deterministic refresh, purchased vacancies and purchase transactions. Uses shared item generation rather than embedding generated stats in shop data.

### `scripts/economy/spending_evaluator.gd`

Owns autonomous optional-development preference plus equipment-purchase evaluation. Established Conservative selects equipment-before-training; Curious and neutral use Skill-Level-first. It also compares affordable equipment candidates using current upgrade rules and may receive a protected-Gold budget from Simulation.

It evaluates; it does not directly mutate live equipment or Gold.

### `scripts/model/definitions/healing_potion_definition.gd`
### `data/items/consumables/*.tres`

Immutable healing-potion data used by the shop/preparation systems.

### `scripts/items/belt_potion_rules.gd`

Central Belt capacity/potion-eligibility and potential-healing utility rules. It does not buy, store or consume potions.

### `scripts/economy/dungeon_preparation_budget.gd`

Read-only economic policy protecting dungeon potion preparation from optional development spending. Calculates the remaining Gold budget for Skill Level training / ordinary equipment from a supplied loadout plan and filters Belt purchases that would make the new full loadout unaffordable.

Simulation supplies known-dungeon Power readiness and retains city-state transitions; `PotionPreparationSystem` still owns loadout calculations, purchases and consumption. The policy never changes Gold, stock, equipment, Inventory or prepared slots.

### `scripts/economy/potion_preparation_system.gd`

Owns current dungeon potion loadout planning, purchase of missing bottles, prepared-slot state updates and allowed between-fight consumption decisions.

It does not own dungeon travel/combat or Belt equipment generation.

## God system

### `scripts/god/god_state.gd`

Mutable divine resource state: energy/recovery progress, cooldowns and pending guidance state. Temporary combat blessing data itself lives with hero active effects.

### `scripts/god/god_system.gd`

Validates/applies divine commands through existing state owners: healing, resurrection, combat blessing, quest guidance and dungeon revelation support.

Simulation exposes the stable public command boundary and coordinates any required stat/narrative refresh afterward.

## Narrative, logs and Diary

Narrative code must describe facts produced by gameplay; it must not become a hidden gameplay-decision layer.

### `scripts/narrative/debug_log.gd`

Technical rolling developer-log store.

### `scripts/narrative/quest_narrator.gd`

Formats structured ordinary quest/combat/death facts for the developer Debug Log, including existing quest-selection diagnostics. It never recalculates QuestScore.

### `scripts/narrative/event_narrator.gd`

Formats temporary-event facts for developer/debug output.

### `scripts/narrative/dungeon_narrator.gd`

Formats dungeon facts for developer/debug output.

### `scripts/narrative/economy_narrator.gd`

Presentation-only developer wording for market sales, stock refresh/assortment, equipment purchases, immediate replacement sales, and unsuccessful shopping. Receives existing transaction/evaluation results; never selects purchases, spends Gold or writes logs.

### `scripts/narrative/item_narrator.gd`

Presentation-only developer wording for acquired/equipped/retained reward equipment and Inventory overflow. Receives already-resolved item routing; never generates items, equips them, or decides Diary significance.

Simulation retains log insertion, order and world ticks, plus the compatible shop-text/slot-name wrappers. Existing `DiaryNarrator` and Diary lifecycle remain separate and unchanged.

### `scripts/narrative/diary_recorder.gd`

Owns recording supplied Diary facts, temporary quest-entry lifecycle/id, and the current Rare/Epic acquisition significance filter. Receives explicit hero/context data and world ticks, calls `DiaryNarrator`, and writes to the same live `Diary` store.

It has no Simulation reference and never changes gameplay, rewards or world time. Simulation keeps compatible record methods and forwarding access to the narrator/temporary-entry id; it still supplies facts at their original points and explicitly suppresses duplicate equipment records for event/dungeon completion rewards.

### `scripts/narrative/diary.gd`

Stores already prepared player-facing Diary entries, adds the supplied real world tick and emits text updates. It also supports removable temporary entries used for an activity that must be visible while active but should not remain as a second permanent history line after resolution.

It does not decide significance or generate prose.

### `scripts/narrative/diary_narrator.gd`

Current player-facing Diary prose converter for ordinary quest selection/completion plus shared combat-death, resurrection, significant equipment-acquisition, ordinary-dungeon milestones, and successful temporary-event endings. Successful events pass through the authored `diary_text` of the exact END stage that actually resolved. Phrase selection uses the dedicated narrative RNG where variants exist and substitutes real structured values where needed.

It must remain presentation-only.

### `scripts/model/definitions/quest_diary_text_definition.gd`
### `data/narrative/quests/ordinary_quest_diary.tres`

External ordinary-quest Diary phrase data. Holds variant arrays for quest selection and completion. `QuestDefinition` may reference a bespoke override resource when a specific quest needs unique wording.

### `scripts/model/definitions/death_diary_text_definition.gd`
### `data/narrative/death_diary.tres`

Shared combat-death Diary wording. The activity kind/name and killer come from the live simulation context rather than being authored into the phrase resource.

### `scripts/model/definitions/resurrection_diary_text_definition.gd`
### `data/narrative/resurrection_diary.tres`

Shared resurrection Diary wording with separate natural and divine variant groups. Simulation supplies which resurrection path actually occurred; narrative does not infer it.

### `scripts/model/definitions/equipment_acquisition_diary_text_definition.gd`
### `data/narrative/equipment_acquisition_diary.tres`

Shared significant-equipment acquisition wording with separate Rare and Epic variant groups. The reward/drop pipeline supplies the actual acquired item; shop purchases remain a separate future Diary source.

### `scripts/model/definitions/dungeon_diary_text_definition.gd`
### `data/narrative/dungeon_diary.tres`

Shared ordinary-dungeon milestone wording for discovery, attempt start, purchased-potion count, and successful completion reward. Dynamic dungeon/item/reward values come from live runtime facts.

Temporary-event Diary prose is intentionally owned by each branch-specific END stage in the corresponding resource under `data/events/`; it is not duplicated into `data/narrative/`.

Future reusable generic Diary wording should live under `data/narrative/`; unique event/dungeon/content wording should remain with the owning content where practical.

## UI and scenes

### `scripts/ui/startup_flow.gd` / `scenes/main/startup.tscn`

Owns pregame screen order and selected answer indices, not gameplay formulas. Creates no Simulation until the second Next; then constructs the normal autonomous/event-enabled Warrior simulation with background answers and injects it into MainUI. Duplicate submissions cannot create another game.

### `scripts/ui/screens/background_screen.gd` / `scenes/ui/screens/background_screen.tscn`

Debug questionnaire presentation: four questions in a two-column grid, exclusive answer groups, visible authored bonuses and a bottom-right Next gated on complete valid answers. Authored text/effects live in the separate background data. All options fit at 1366x768; a scroll container protects smaller layouts.

### `scripts/ui/screens/class_selection_screen.gd` / `scenes/ui/screens/class_selection_screen.tscn`

Presents the friend-loss/training story and four class options. Only Warrior is enabled; explicit selection unlocks Next. Owns presentation/selection only, not hero mutations or time.

### `scripts/ui/main_ui.gd`

Top-level developer UI coordinator. Owns navigation/visibility and passes the existing `Simulation` to dedicated screens/components.

It may issue approved gameplay commands through Simulation but must not own gameplay rules.

### `scenes/ui/components/hero_summary_panel.tscn`
### `scripts/ui/components/hero_summary_panel.gd`

Owns the structured main-screen hero card: name/class/traits, level and pending-point plus, gold, live HP/XP bars with numbers, separate activity/quest labels, and a scrollable rich-text detail body grouped into attributes, combat and resistances, retaining bonuses and Seed. The card remains at (32, 80), width 320, with a fixed 640 height; overflow is confined to the detail body. Receives the existing Simulation and never advances gameplay. MainUI retains refresh/signal routing and exposes the rich-text hero_details_label; hero_panel is the explicit geometry/style reference. Focused coverage: tests/test_hero_card.gd and tests/test_hero_summary_extraction.gd.

### `scenes/ui/screens/hero_screen.tscn`
### `scripts/ui/screens/hero_screen.gd`

Owns development-screen construction, primary-attribute buttons, personality axis controls and their presentation refresh. Receives the existing Simulation through setup; allocation requests use Simulation and emit hero_state_changed to refresh the main summary. MainUI retains navigation, visible-screen refresh scheduling, compatible update methods and live control references. Geometry and node names are unchanged.

### `scenes/ui/screens/inventory_screen.tscn`
### `scripts/ui/screens/inventory_screen.gd`

Inventory/equipment/potion presentation. Reads current hero equipment/inventory and renders paper doll, equipment slots, retained gear and potion column/tooltips.

It does not decide equipment upgrades, buy/sell items or consume potions.

### `scenes/ui/screens/map_screen.tscn`
### `scripts/ui/screens/map_screen.gd`

Observation-only world-map presentation: terrain/cities/road, hero position, quest/dungeon markers, temporary-event footprints, hover info, camera zoom/pan and developer hidden-location presentation.

It does not choose destinations, reserve activities, calculate travel or reveal locations by itself.

### `scripts/ui/map_tile_visuals.gd`
### `assets/map/biomes/`
### `assets/map/characters/`
### `assets/map/activities/`

Presentation-only map texture lookup/selection and supplied map sprites.

### `scenes/ui/components/god_panel.tscn`
### `scripts/ui/components/god_panel.gd`

God-energy/ability presentation and command forwarding through `Simulation`.

### `scenes/ui/components/narrative_panel.tscn`
### `scripts/ui/components/narrative_panel.gd`

Current Log/Diary tab presentation. Subscribes to DebugLog/Diary updates and keeps both text views pinned to their newest real entry.

It does not generate narrative or gameplay outcomes.

### Hero/item presentation assets

- `assets/hero/` — base hero presentation art.
- `assets/items/icons/` — equipment/consumable icons.
- `assets/items/overlays/` — armor paper-doll overlays.
- `assets/shaders/` — current item/UI shaders.

Exact pixel sizes, offsets and temporary visual placeholders belong in the UI code/assets rather than this document.

## Content/data directories

### Ordinary mobs and quests

- `data/mobs/` — current ordinary mob cards.
- `data/quests/` — current Starting City ordinary quest templates.
- `data/mobs/mid_region/` — future Mid Region mob content scaffold.
- `data/quests/mid_city/` — future Mid-Level City ordinary quest scaffold.
- `data/quests/specialization/` — future specialization-quest scaffold.

Quest code discovers content by directory rather than hard-coding every individual quest filename.

### Temporary events

- `data/events/starting_region/` — current handcrafted Starting Region events.

### Dungeons

- `data/dungeons/starting_region/` — current ordinary Starting Region dungeons and their dungeon-only mobs.
- `data/dungeons/mid_region/` — future ordinary Mid Region dungeon scaffold.
- `data/dungeons/specialization/` — future specialization dungeon scaffold; intentionally not part of the ordinary loader.

### Items/economy

- `data/items/balance/` — shared item stats/budgets/stat costs/prices.
- `data/items/consumables/` — potion definitions.
- `data/items/starting_equipment/` — fixed new-hero clothing.
- `data/items/visual_families/` — current visual equipment families.
- `data/loot/` — equipment source/drop tables.
- `data/shops/` — shop definition and stock bands.

### Narrative

- `data/narrative/` — reusable player-facing narrative phrase data; currently ordinary quest and shared combat-death Diary phrases are live.

### Future scaffolds not yet implemented

Current repository scaffolding also includes directories such as:

- `scripts/decision/`;
- `scripts/persistence/`;
- `data/abilities/warrior/`;
- `data/cities/`;
- `data/specializations/`;
- `data/loot_tables/`.

Do not infer a working system from these placeholders.

## Tests

Tests live under `tests/`. They are intentionally grouped by behaviour rather than mirrored one-for-one here.

Important coverage families include:

- **core/time/RNG** — world clock, speed, seeded behaviour;
- **hero/progression/personality** — XP, stat allocation, traits, hysteresis;
- **combat** — timing, hit/crit/block, Rage, Power Strike, Battle Guard, death;
- **quests** — template/offer boundaries, board lifecycle, map targets, Hard Filter/QuestScore, autonomous choice and execution;
- **map/travel** — authored-map decoding, reservations, placement, movement;
- **events** — each authored event plus population, detours, interruption/resumption and event death;
- **dungeons** — placement/discovery, decision/readiness, combat sequence, retries, rewards and return flow;
- **items/economy** — generation, equipment evaluation, visual tiers, inventory, shop, sale, Belt/potions and reward routing;
- **God system** — state, gameplay integration and UI;
- **narrative/UI** — debug log, Diary, screen extraction/layout/autoscroll.

Representative high-value integration tests include:

- `tests/test_autonomous_quest_choice.gd`;
- `tests/test_quest_evaluator.gd`;
- `tests/test_event_population_rotation.gd`;
- `tests/test_event_travel_suspend_resume.gd`;
- `tests/test_event_batch_six_to_thirteen_content.gd`;
- `tests/test_event_batch_six_to_thirteen_runtime.gd`;
- `tests/test_event_batch_fourteen_fifteen_content.gd`;
- `tests/test_event_batch_fourteen_fifteen_runtime.gd`;
- `tests/test_dungeon_post_quest_decision.gd`;
- `tests/test_dungeon_combat_sequence.gd`;
- `tests/test_dungeon_retry_readiness.gd`;
- `tests/test_belt_and_healing_potions.gd`;
- `tests/test_god_abilities_integration.gd`;
- `tests/test_debug_log_autoscroll.gd`;
- `tests/test_ordinary_quest_diary.gd`;
- `tests/test_main_ui_component_extraction.gd`.

Before changing a system, prefer the narrow tests nearest that responsibility. See `current-state.md` for known current compatibility/stale-test notes.

## Architectural orientation

When unsure where new code belongs, preserve these ownership lines:

```text
definitions/data
→ runtime state
→ gameplay/simulation facts
→ narrative wording
→ UI
```

and:

```text
HeroState / HeroProgression / Equipment
→ StatResolver
→ CombatStats
→ PowerCalculator / CombatSession
```

and for generated equipment:

```text
drop/reward source
→ LootGenerator
→ ItemGenerator
→ EquipmentEvaluator
→ Equipment / Inventory
→ StatResolver
```

`project-map.md` should stay a map. If a future edit starts adding long tuning tables, exact branch scripts, reward numbers, pixel dimensions or design rationale here, that information probably belongs in data/code, `current-state.md`, `dependencies.md`, or the Scope instead.
