# The Hero’s Story — Project Map

## Project root

- `project.godot` — Godot project configuration and main scene.
- `.github/workflows/tests.yml` — GitHub Actions regression-test workflow.
- `data/` — concrete game data.
- `scenes/` — Godot scenes.
- `scripts/` — runtime/gameplay/UI code.
- `tests/` — regression tests.

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
- Diary shell.

On combat completion it records cumulative per-mob win/loss statistics, applies XP only after victory, passes the result to `QuestRunner`, logs the resulting structured event, and completes exactly one world tick for the fight.

### `scripts/core/world_clock.gd`
Single world-time authority used by travel, recovery, and the natural resurrection timer.

### `scripts/core/seeded_rng.gd`
Owns the current seeded RNG.

## Hero

### `scripts/hero/hero_state.gd`
Mutable hero state and centralized loop-state ids, including:
- `DEAD_RESPAWNING`;
- `RECOVERING_IN_CITY`.

### `scripts/hero/hero_traits.gd`
Owns the five Prototype 0 trait IDs, seeded assignment of 1–2 compatible starting traits, Russian display names, and the Noble/Dishonorable category-damage multiplier.

### `scripts/hero/hero_progression.gd`
Owns XP and Warrior level growth.

### `scripts/hero/stat_resolver.gd`
Builds final `CombatStats`.

## Combat

### `scripts/combat/combat_simulator.gd`
Creates one live duel.

### `scripts/combat/combat_session.gd`
Owns only one fight: internal combat time, HP, attacks, crits, and victory/defeat.

It does not own resurrection or quest cancellation.

### `scripts/combat/combat_action.gd`
One resolved attack.

### `scripts/combat/combat_result.gd`
One duel result.

### `scripts/combat/power_calculator.gd`
Shared hero/mob Power calculation.

## Quests

### `scripts/quests/quest_pool.gd`
Owns immutable quest templates and the currently available runtime tavern offers for this Prototype 0 slice.

The developer build loads every `.tres` under `res://data/quests` in stable filename order, then uses the shared seeded RNG to roll one offer from each template's integer count, distance, and per-mob-gold ranges. An offer calculates its total Gold reward as `MobCount × GoldPerMob`.

After a successful turn-in or a fatal cancellation followed by city recovery, only that accepted offer's same pool slot is regenerated; unaccepted offers persist. Tests may inject an explicit fixed offer list instead.

### `scripts/model/runtime/quest_offer.gd`
Runtime quest offer. Owns the rolled mob count, distance, and gold per mob for one tavern slot. Its total Gold is derived as `MobCount × GoldPerMob`; it is never serialized into a quest template.

### `scripts/quests/quest_evaluator.gd`
Owns autonomous quest evaluation:
- 95% Hard Filter;
- weakest-allowed-mob normalization;
- estimated combat/recovery cost;
- BaseAttractiveness;
- current neutral QuestScore;
- strict highest-score selection.

Applies the approved Coward/Brave, Dishonorable/Noble, and Greedy QuestScore modifiers. DivineModifier remains a zero-value future slot.

### `tests/test_personality_traits.gd`
Protects seeded compatible starting traits and the approved QuestScore formulas.

### `tests/test_trait_combat_bonus.gd`
Protects the 10% Noble/Dishonorable category bonus in actual combat damage.

### `scripts/quests/quest_runner.gd`
Executes the current single quest.

Owns current execution-state transitions including:
- travel;
- defeated-mob count;
- post-fight recovery;
- return/turn-in;
- defeat and quest cancellation;
- 100-tick natural resurrection timer;
- city recovery after resurrection.

It does not award XP or implement combat itself.

### `scripts/quests/quest_event.gd`
Structured quest/runtime events, now including death, resurrection, and city recovery.

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
- hero panel left;
- log/diary center;
- active opponent right;
- current death-respawn countdown through the hero state label;
- fixed bottom-right cumulative combat-statistics panel.


## Quest and mob data

Concrete tuning lives in:
- `data/mobs/`;
- `data/quests/`.

Quest selection does not hard-code individual quest files. `QuestPool` discovers current quest `.tres` resources from the quest directory.

## Tests

### `tests/test_quest_pool.gd`
Protects automatic discovery of quest resources from `data/quests`.

### `tests/test_quest_offer_randomization.gd`
Protects seeded integer offer rolls, per-mob reward calculation, and preservation of unaccepted offers when one is replaced.

### `tests/test_quest_template_offer_boundary.gd`
Protects the boundary: templates retain only ranges, while `QuestOffer` owns the rolled values and derives total Gold.

### `tests/test_initial_city_content_expansion.gd`
Protects the ten added initial-city mob/quest pairs: unique IDs, valid ranges, every new mob stronger than Goblin, and exactly six stronger than Bear.

### `tests/test_quest_offer_refresh_lifecycle.gd`
Protects the Simulation-to-QuestPool integration for replacing only a turned-in quest offer.

### `tests/test_quest_offer_cancelled_lifecycle.gd`
Protects delayed replacement of only a cancelled offer after natural resurrection and city recovery.

### `tests/test_quest_evaluator.gd`
Protects the 95% Hard Filter, weakest-mob normalization, estimated quest time, and strict highest QuestScore selection using in-memory test data.

### `tests/test_autonomous_quest_choice.gd`
Integration coverage that `Simulation` selects first and `QuestRunner` executes the already selected quest.



### `tests/test_wolf_definition.gd`
Protects the Wolf calibration card and Power ≈ 20.38.

### `tests/test_wolf_quest_definition.gd`
Protects the Wolf quest template's approved integer ranges.

### `tests/test_combat_statistics.gd`
Protects cumulative fight/win/loss/winrate counting.


### `tests/test_bear_definition.gd`
Protects the slow/high-HP Bear calibration card and Power ≈ 20.38.

### `tests/test_bear_quest_definition.gd`
Protects the Bear quest template's approved integer ranges.

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
