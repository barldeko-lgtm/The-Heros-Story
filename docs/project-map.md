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
Owns XP and Warrior level growth.

### `scripts/hero/stat_resolver.gd`
Builds stable base stats and effective combat stats from the same sources. Persistent equipment contributes to both; effective stats additionally include generic bonuses from `HeroState.active_effects`. Ten Armor currently resolves to 5% damage reduction.

## Combat

### `scripts/combat/combat_simulator.gd`
Creates one live duel from already resolved hero and mob `CombatStats`.

### `scripts/combat/combat_session.gd`
Owns only one fight: internal combat time, HP, attacks, crits, target damage reduction, conditional hero damage multiplier, and victory/defeat.

It does not own resurrection, quest cancellation, god ability state, or flat stat-bonus injection.

### `scripts/combat/combat_action.gd`
One resolved attack.

### `scripts/combat/combat_result.gd`
One duel result.

### `scripts/combat/power_calculator.gd`
Shared hero/mob Power calculation. Quest Hard Filter uses the hero's base persistent `CombatStats` view; temporary finite effects are intentionally excluded.

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
Current developer UI.

Displays:
- persistent top navigation;
- hero panel left;
- god energy and Healing/Blessing/Resurrection controls above the narrative panel;
- log/diary center;
- active opponent right;
- current death-respawn countdown through the hero state label;
- fixed bottom-right cumulative combat-statistics panel;
- an Inventory screen with Back and close-button navigation, a scaled hero portrait, five left-side armor slots, two weapon slots below the portrait, a right-side necklace/earrings/two-rings/belt column, and a titled `6 × 6` inventory grid.

The main developer controls and the Inventory shell are separate UI layers under the same `MainUI`. Switching between them changes visibility only; the existing `Simulation` instance continues advancing.

`assets/hero/hero_reference.png` is the unchanged supplied `441 × 800` RGBA reference image currently displayed at `256 × 464` over an explicit dark backing panel. All five armor slots plus the main-hand and off-hand slots display equipped state. The right jewelry column exposes stable empty slots for necklace, earrings, two separate rings, and belt. Helmet, gloves, pants, and boots use supplied `300 × 300` RGBA PNG icons under `assets/items/icons/ironward_vanguard/`; chest, sword, and shield retain their current icon assets. Helmet, chest, gloves, pants, and boots each provide a dedicated `441 × 800` paper-doll overlay under `assets/items/overlays/ironward_vanguard/`; the UI layers equipped armor over the base hero in stable back-to-front order. The 36 inventory cells display retained item instances. Equipped and inventory icons share a custom hover tooltip; `assets/shaders/item_quality_outline.gdshader` provides the three-band green/blue quality outline.

## Item data

### `scripts/model/definitions/item_definition.gd`
Immutable item card: id, display name, equipment slot, icon, hero overlay, and current stat bonuses.

### `scripts/model/runtime/item_instance.gd`
One concrete acquired item referencing its immutable definition.

### `scripts/items/item_power_calculator.gd`
Calculates static ItemPower through the shared `PowerCalculator`. It applies item bonuses to the approved minimal reference combat profile and subtracts that profile's baseline Power, avoiding arbitrary item-score coefficients.

### `data/items/visual_families/ironward_vanguard/boar_chestplate.tres`
Defines Common `Кираса Авангарда Железного Оплота`: +20 direct MaxHP, +10 Armor, +1 Strength.

`data/items/visual_families/ironward_vanguard/boar_chestplate_uncommon.tres` defines Uncommon `Кираса Авангарда Железного Оплота`: +25 direct MaxHP, +15 Armor, +2 Strength. `data/items/visual_families/ironward_vanguard/boar_chestplate_rare.tres` defines Rare: +35 direct MaxHP, +20 Armor, +3 Strength. All three reuse the supplied icon and portrait overlay.

The same three-quality armor progression is defined for `boar_helmet*`, `boar_gauntlets*`, `boar_leggings*`, and `boar_boots*`. Their localized names are `Шлем Авангарда Железного Оплота`, `Рукавицы Авангарда Железного Оплота`, `Поножи Авангарда Железного Оплота`, and `Сапоги Авангарда Железного Оплота`; every quality of each family reuses its supplied paper-doll overlay. `boar_sword*` defines `Меч Авангарда Железного Оплота` with Common/Uncommon/Rare Attack/CritChance/CritDamage bonuses of `3/5%/10%`, `4/7%/15%`, and `5/10%/20%`. `boar_shield*` defines `Щит Авангарда Железного Оплота` with MaxHP/Armor bonuses of `10/20`, `15/25`, and `20/30`. Internal `boar_*` ids and filenames remain unchanged technical keys.

Seven quests reference equal-third quality pools: `boars_in_fields` → chest, `wolf_hunt` → helmet, `bear_hunt` → gloves, `granary_rat_problem` → pants, `trade_road_ambush` → boots, `old_mill_webs` → sword, and `fearless_elk` → shield. Every successful turn-in rolls one reward through the shared seeded RNG. `Simulation` equips the first item per slot, upgrades only to a higher quality in that slot, and routes non-equipped/replaced items through FIFO Inventory.

Item tooltips call their definition's ItemPower calculation and display the stable result alongside quality and raw bonuses.

The hero panel displays stable base Attack/HeroPower and shows temporary blessing and conditional trait combat bonuses separately.

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
