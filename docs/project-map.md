# The Hero’s Story — Project Map

## Project root

- `project.godot` — Godot project configuration and main scene.
- `.github/workflows/tests.yml` — GitHub Actions regression-test workflow.
- `assets/` — supplied visual assets used by the current UI. Hero art lives under `assets/hero/`; item icons and overlays are separated under `assets/items/icons/` and `assets/items/overlays/`.
- `data/` — concrete game data. The current Ironward Vanguard definitions live under `data/items/visual_families/ironward_vanguard/`.
- `scenes/` — Godot scenes.
- `scripts/` — runtime/gameplay/UI code.
- `tests/` — regression tests.

The target Prototype 0.2 directory scaffold from the Scope is tracked with `.gitkeep` placeholders. Empty folders do not mean that their future systems are implemented. Existing scripts, scenes, tests, mobs, and quests remain in their current working locations until an approved system-specific change requires moving them.

## Core

### `scripts/core/simulation.gd`
Runtime coordinator. The default constructor keeps the fixed Goblin quest for regression compatibility; passing `null` as the initial quest enables autonomous selection from QuestPool.

Coordinates:
- WorldClock;
- SeededRng;
- HeroState / HeroProgression / StatResolver;
- PowerCalculator;
- live CombatSession;
- QuestPool / QuestEvaluator;
- QuestRunner;
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

Also owns current `active_effects`, the hero's `Equipment`, and the current 36-item FIFO `Inventory`.

### `scripts/hero/equipment.gd`
Owns equipped `ItemInstance` objects by slot, replaces an item when Simulation approves a better quality, and exposes persistent stat totals.

### `scripts/hero/inventory.gd`
Stores up to 36 retained item instances in acquisition order. Adding item 37 removes and returns the oldest item.

### `scripts/hero/hero_traits.gd`
Owns the five Prototype 0 trait IDs, seeded assignment of 1–2 compatible starting traits, Russian display names, QuestScore personality constants, and the Noble/Dishonorable category-damage multiplier.

### `scripts/hero/hero_progression.gd`
Owns XP and the current pre-specialization Warrior level growth of +2 STR / +1 DEX / +1 CON. The future deity-guided point is not yet assigned or stored.

### `scripts/hero/stat_resolver.gd`
Builds stable base stats and effective combat stats from the same sources. It is the centralized conversion path from STR / DEX / CON to current combat-facing values; INT and WIS are stored but currently have no Warrior combat contribution. Persistent equipment contributes to both views; effective stats additionally include generic bonuses from `HeroState.active_effects`. It resolves raw Armor, Accuracy, Dodge, Resistances, and Block values but does not calculate hit or mitigation outcomes.

## Combat

### `scripts/combat/combat_simulator.gd`
Creates one live duel from already resolved hero and mob `CombatStats`.

### `scripts/combat/combat_session.gd`
Owns only one fight: internal combat time, HP, attack opportunities, crits, calls to the shared hit/mitigation rules, conditional hero damage multiplier, and victory/defeat.

It does not own resurrection, quest cancellation, god ability state, or flat stat-bonus injection.

### `scripts/combat/combat_action.gd`
One resolved attack, including hit/miss, critical, Block, damage type, and final damage facts.

### `scripts/combat/damage_resolver.gd`
Shared Prototype 0.2 formulas for Accuracy/Dodge, Armor, elemental Resistances, Block chance, expected Block mitigation, and direct-hit mitigation. Both hero and mob combat use the same implementation.

### `scripts/combat/combat_result.gd`
One duel result.

### `scripts/combat/power_calculator.gd`
Shared complete Prototype 0.2 hero/mob Power calculation. It includes expected physical DPS, the reference Accuracy factor, the 70/10/10/10 incoming-damage mix, reference Dodge, Armor, all three elemental Resistances, and expected Block mitigation. Quest Hard Filter uses the hero's base persistent `CombatStats` view; temporary finite effects are intentionally excluded.

## Quests

### `scripts/quests/quest_pool.gd`
Owns immutable quest templates and the currently available runtime tavern offers for this Prototype 0 slice.

The developer build loads every `.tres` under `res://data/quests` in stable filename order, then uses the shared seeded RNG to roll one offer from each template's integer count, distance, and per-mob-gold ranges. With the current single-city content set this means all 13 current quest templates are available simultaneously. An offer calculates its total Gold reward as `MobCount × GoldPerMob`.

There is intentionally no 5–7-offer cap in the current one-city Prototype 0 build. Stronger offers stay present and are filtered by `QuestEvaluator` until the hero is strong enough.

After a successful turn-in or a fatal cancellation followed by city recovery, only that accepted offer's same pool slot is regenerated from the same immutable template; unaccepted offers persist. Tests may inject an explicit fixed offer list instead.

### `scripts/model/runtime/quest_offer.gd`
Runtime quest offer. Owns the rolled mob count, distance, and gold per mob for one tavern slot. Its total Gold is derived as `MobCount × GoldPerMob`; it is never serialized into a quest template.

### `scripts/quests/quest_evaluator.gd`
Owns autonomous quest evaluation:
- 95% Hard Filter;
- weakest-allowed-mob normalization;
- estimated combat/recovery cost;
- BaseAttractiveness;
- Coward/Brave modifier;
- Dishonorable/Noble modifier;
- Greedy modifier;
- optional one-selection `DivineModifier = +0.20` for the currently guided eligible offer;
- strict highest-score selection.

Hard Filter uses base persistent HeroPower. Guidance cannot bypass Hard Filter.

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

## God system

### `scripts/god/god_state.gd`
Owns energy, six-tick recovery progress, ability cooldowns, pending quest guidance, and resurrection energy cost. The active blessing and its remaining fights live in `HeroState.active_effects`; `Simulation` validates commands and coordinates their owning systems.

### `tests/test_god_state.gd`
Protects energy, recovery, cooldown activation rules, guidance consumption, and resurrection cost.

### `tests/test_god_abilities_integration.gd`
Protects Simulation integration for healing, instant resurrection, +3 Attack combat buff through `StatResolver`, unchanged base HeroPower while that temporary effect is active, and one-selection `DivineModifier = +0.20`.

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

`MainUI` instantiates the dedicated Inventory, God, and Narrative components and passes each the existing `Simulation`. It refreshes high-level screen state and owns Inventory Back/close navigation. Switching screens changes visibility only; the same `Simulation` instance continues advancing.

### `scenes/ui/screens/inventory_screen.tscn`
Dedicated Inventory screen root instantiated by `MainUI`.

### `scripts/ui/screens/inventory_screen.gd`
Owns Inventory presentation: the scaled hero portrait and armor overlays, equipment slots, the `6 × 6` retained-item grid, quality outlines, and item tooltips. It reads equipment/inventory state from the supplied `Simulation` but does not grant, equip, replace, or drop items.

### `scenes/ui/components/god_panel.tscn` / `scripts/ui/components/god_panel.gd`
Owns the God panel presentation and button commands: energy, cooldowns, healing, combat blessing, and instant resurrection. It sends approved requests through the supplied `Simulation` and reports hero-display changes back to `MainUI` through a signal.

### `scenes/ui/components/narrative_panel.tscn` / `scripts/ui/components/narrative_panel.gd`
Owns the current Log/Diary tab container, subscribes to `DebugLog` and world-tick updates, and keeps wrapped log output scrolled to the newest entry. It displays narrative state but does not create gameplay outcomes.

`assets/hero/hero_reference.png` is the unchanged supplied `441 × 800` RGBA reference image currently displayed at `256 × 464` over an explicit dark backing panel. All five armor slots plus the main-hand and off-hand slots display equipped state. The right jewelry column exposes stable empty slots for necklace, earrings, two separate rings, and belt. Helmet, gloves, pants, and boots use supplied `300 × 300` RGBA PNG icons under `assets/items/icons/ironward_vanguard/`; chest, sword, and shield retain their current icon assets. Helmet, chest, gloves, pants, and boots each provide a dedicated `441 × 800` paper-doll overlay under `assets/items/overlays/ironward_vanguard/`; the UI layers equipped armor over the base hero in stable back-to-front order. The 36 inventory cells display retained item instances. Equipped and inventory icons share a custom hover tooltip; `assets/shaders/item_quality_outline.gdshader` provides the three-band green/blue quality outline.

## Item data

### `scripts/model/definitions/item_definition.gd`
Immutable item card: id, display name, equipment slot, icon, hero overlay, and current stat bonuses.

### `scripts/model/runtime/item_instance.gd`
One concrete acquired item referencing its immutable definition.

### `scripts/items/item_power_calculator.gd`
Calculates generated ItemInstance ItemPower through the shared `PowerCalculator`. It applies all inherent and affix stats to the approved fixed reference profile and subtracts that profile's baseline Power, avoiding arbitrary item-score coefficients. A compatibility path remains for old definition-level test data, but live equipment uses instance stats.

### `scripts/model/definitions/item_modifier_budget_table_definition.gd` / `data/items/balance/item_modifier_budget_table.tres`
Central Scope 19 budget data: Green affix budgets for ilvl 1/10/20/30/40/50/60, 0/1/2/3 affix counts, 1.0/0.85/0.7225 per-affix rarity multipliers, the 30% adjacent-tier growth target, and the one-time 0.95–1.05 total-budget roll.

### `scripts/model/definitions/item_modifier_stat_cost_table_definition.gd` / `data/items/balance/item_modifier_stat_costs.tres`
Central Scope 19.5 conversion costs from modifier budget into Health, Armor, Dodge, Accuracy, Damage, critical stats, speed stats, elemental Resistance, and Block. Primary attributes are absent from the table.

### `scripts/model/definitions/item_base_stat_table_definition.gd` / `data/items/balance/item_base_stat_table.tres`
Central inherent base-stat control points for ilvl 1/10/20/30/40/50/60. The current seven-slot set uses armor Armor, sword Damage/+0.10 Attack Speed, and shield Block from this table.

### `scripts/items/item_generator.gd`
Creates one generated `ItemInstance` from a visual rarity definition, source Item Level, and the shared seeded RNG. It resolves inherent stats, rolls the item-wide modifier budget, selects unique slot-legal affixes, splits budget equally, converts budget through stat costs, and stores both readable affixes and combat-ready resolved values.

### `scripts/hero/equipment_evaluator.gd`
Performs virtual equip for one candidate against the hero's complete current equipment dictionary. It resolves base persistent CombatStats for current and copied candidate configurations, compares both through the shared `PowerCalculator`, and recommends replacement only for a strict HeroPower increase. It never mutates live equipment and excludes temporary effects.

### `scripts/model/definitions/item_price_table_definition.gd` / `data/items/balance/item_price_table.tres`
Central current equipment reference values for ilvl 1/10/20. White control points are 100/500/1000 Gold, Green uses ×3, Rare uses the approved current ×9 extension, and resale uses 10% of reference value. Undefined Item Levels/rarities remain unpriced instead of silently extrapolating.

### `scripts/economy/item_price_calculator.gd`
Reads the central price table and returns reference shop value or resale value for an Item Level/rarity pair or a concrete generated `ItemInstance`.

### `scripts/economy/equipment_sale_system.gd`
Owns automatic ordinary-equipment liquidation from Inventory. It removes only priced unequipped instances, totals their resale values, adds Gold to `HeroState`, and returns a structured sold-items/count/Gold result. Quest turn-in schedules `VISITING_MARKET`; `Simulation` invokes the sale system on the following dedicated world tick, then enters the separate `SHOPPING` phase.

### `scripts/model/definitions/shop_definition.gd` / `data/shops/starting_city_shop.tres`
Defines the current Starting City equipment shop as immutable authored data: one current ilvl 10 source band, 6 White and 2 Green listings, 200-world-tick refresh interval, and references to the existing Ironward Vanguard White/Green item definitions. It does not duplicate item stats, affix budgets, ItemPower, or price data.

### `scripts/economy/shop_system.gd`
Owns mutable shop stock, deterministic stock refresh, purchased vacancies, and equipment purchase transactions. It generates real `ItemInstance` listings through the shared `ItemGenerator`, refreshes independently of hero presence on ticks divisible by 200, deducts shop price, equips the purchased instance, and immediately converts replaced ordinary equipment into its normal resale Gold instead of routing it through Inventory.

### `scripts/economy/spending_evaluator.gd`
Owns the current autonomous equipment-purchase comparison. It filters for affordability and the Scope's +20% ItemPower threshold, validates the candidate through the existing virtual-equip `EquipmentEvaluator`, and chooses the valid listing with the largest real HeroPower increase. It does not mutate equipment or Gold.

### `scripts/loot/loot_generator.gd`
Owns the first stage of the current source-driven mob equipment roll. It checks the configured 5% drop chance, chooses one of seven existing slots with equal probability, and selects Common/Uncommon/Rare with 70%/25%/5% probability. `Simulation` then passes that definition and the drop table's current ilvl 10 to `ItemGenerator`.

### `scripts/model/definitions/equipment_drop_table_definition.gd` / `data/loot/initial_equipment_drop_table.tres`
The immutable shared table used by all thirteen current mob definitions. It stores the drop chance and three aligned seven-slot rarity pools, avoiding duplicated 21-item lists in every mob resource.

### `data/items/visual_families/ironward_vanguard/`
Contains the seven current visual item families in Common, Uncommon, and Rare variants. Their ids, slots, names, icons, and armor overlays select presentation and rarity. Live inherent and random combat stats are generated on `ItemInstance`; the old serialized experimental stat fields are ignored by current runtime generation.

Every current resource under `data/mobs/` references the same initial ilvl 10 equipment drop table. After each defeated mob, `Simulation` asks `LootGenerator` for a seeded slot/rarity roll and `ItemGenerator` for a seeded generated instance. `EquipmentEvaluator` then compares the candidate's real virtual HeroPower against the current loadout; strict improvements equip and replaced/rejected instances enter FIFO Inventory. Current quest definitions contain Gold rewards only.

Item tooltips read the generated instance and display rarity, ilvl, rolled budget, inherent stats, affixes, dynamic ItemPower, reference shop value, and sell price.

The hero panel displays stable base Attack/HeroPower and shows temporary blessing and conditional trait combat bonuses separately. During the current economy flow `VISITING_MARKET` means the dedicated sale tick and `SHOPPING` means the separate autonomous-purchase phase.

The god panel updates energy, cooldowns, buff charges, resurrection cost, and button availability every frame. Active combat blessing displays its remaining fights and already-running cooldown together. Quest-guidance controls are intentionally deferred, although the headless Simulation command is implemented.

Debug-log updates scroll to the final wrapped line after UI layout completes rather than using the raw logical line count.

### `tests/test_debug_log_autoscroll.gd`
Protects automatic scrolling to the actual bottom for long wrapped log entries.

## Quest and mob data

Concrete tuning lives in:
- `data/mobs/`;
- `data/quests/`.

Quest selection does not hard-code individual quest files. `QuestPool` discovers current quest `.tres` resources from the quest directory.

Current content contains 13 initial-city mob definitions and 13 matching quest templates. Their exact combat/reward numbers are tuning data rather than architectural contracts unless a test explicitly protects a progression relationship or data validity rule.

## Tests

### `tests/test_quest_pool.gd`
Protects automatic discovery of quest resources from `data/quests`.

### `tests/test_quest_offer_randomization.gd`
Protects seeded integer offer rolls, per-mob reward calculation, and preservation of unaccepted offers when one is replaced.

### `tests/test_quest_template_offer_boundary.gd`
Protects the boundary: templates retain only ranges, while `QuestOffer` owns the rolled values and derives total Gold.

### `tests/test_initial_city_content_expansion.gd`
Protects the ten added initial-city mob/quest pairs: unique IDs, valid ranges, every new mob stronger than Goblin, and the intended broad progression bands.

### `tests/test_quest_offer_refresh_lifecycle.gd`
Protects the Simulation-to-QuestPool integration for replacing only a turned-in quest offer without assuming a fixed tavern-pool size.

### `tests/test_quest_offer_cancelled_lifecycle.gd`
Protects delayed replacement of only a cancelled offer after natural resurrection and city recovery.

### `tests/test_quest_evaluator.gd`
Protects the 95% Hard Filter, weakest-mob normalization, estimated quest time, and strict highest QuestScore selection using in-memory test data.

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
