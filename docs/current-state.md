# The Hero’s Story — Current Project State

This document describes what is **actually implemented now**.

## Current development focus

The project is at the early Prototype 0 foundation stage.

Implemented:
- one autonomous hero;
- Warrior starting stats and level-up progression;
- world tick;
- pause and developer speed controls (×0, ×1, ×2, ×5, ×10, ×20, ×100);
- one shared seeded RNG for current simulation randomness;
- one shared Power calculation for hero and mobs;
- live one-on-one combat with timed strikes;
- per-mob XP and post-fight recovery;
- death, 100-tick natural resurrection, and city recovery;
- thirteen initial-city mob definitions, from Goblin through Forest Troll and Cave Lizard;
- thirteen matching initial-city quest templates;
- autonomous choice among the current quest resources;
- seeded assignment of 1–2 starting personality traits from Coward, Brave, Dishonorable, Noble, and Greedy;
- doubled personality modifiers in QuestScore and 10% category damage for Noble/Dishonorable;
- headless god-system core with 100 starting energy, world-tick recovery, cooldowns, instant resurrection, divine healing, five-fight Attack buff, and one-selection quest guidance;
- a quest execution loop after the selected quest is assigned;
- structured quest/death events;
- separate quest narration;
- debug log;
- empty diary shell;
- rough developer UI;
- automated regression tests and GitHub CI.

Current next major gameplay step:
- decide and implement the separate quest-guidance selection UI, or continue to diary episodes.

Still missing from the current build:
- diary episodes;
- player-facing quest-guidance selection UI.

## God-system core

`scripts/god/god_state.gd` owns 100 maximum/starting energy, +1 energy per 6 world ticks, ability cooldowns, five combat-buff charges, and one pending guided quest id.

`Simulation` currently exposes all four approved commands to future UI:
- instant resurrection at `RemainingRespawnTicks × 0.5` energy;
- divine healing for 10 energy, +50% MaxHP, 30-tick cooldown;
- combat buff for 10 energy, +3 Attack for the next 5 fights, 120-tick cooldown;
- quest guidance for 5 energy, +0.20 DivineModifier for one next selection, 360-tick cooldown.

The center-top god panel now displays energy and provides working buttons for healing, combat blessing, and instant resurrection. Healing can modify live CombatSession HP during a fight. Quest guidance remains headless-only until its selection UI is approved.

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
- `DEAD_RESPAWNING`;
- `RECOVERING_IN_CITY`.

`scripts/hero/hero_progression.gd` owns XP application and Warrior level growth.

Each level:
- the next-level requirement starts at 1000 XP and increases by 500 per current level (`1000, 1500, 2000, ...`);
- carries excess XP forward;
- adds +20 direct MaxHP through the level bonus;
- adds +4 STR;
- adds +1 AGI.

Final combat stats remain:

```text
HeroState + HeroProgression
→ StatResolver
→ CombatStats
```

After a mid-quest level-up, `Simulation` refreshes `CombatStats` before recovery and the next fight.

## Combat

`scripts/combat/combat_session.gd` resolves one live hero-versus-mob duel using final `CombatStats`.

Current behaviour:
- each side attacks on its own `2 / AttackSpeed` interval;
- the hero’s first attack has a 0.5-second opening advantage;
- same-timestamp attacks resolve together;
- a simultaneous death counts as hero defeat;
- critical hits retain fractional damage internally;
- each resolved strike enters the debug log immediately while the world clock is frozen.

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

Full loot loss is still only a future hook because QuestLoot/inventory do not exist yet.


## Current quest content and selection

Concrete mob values and immutable quest templates live in `data/mobs/` and `data/quests/` and are intentionally treated as tuning data rather than duplicated here. A quest template contains only inclusive integer ranges for mob count, distance, and gold per mob; it does not store rolled values or a total Gold reward.

The developer build loads all `.tres` quest templates from `res://data/quests` into `QuestPool`. Using the shared seeded RNG, the pool creates one `QuestOffer` runtime object per template: it owns the rolled count, distance, and gold per mob, and derives `GoldReward = MobCount × GoldPerMob` whenever quest selection, turn-in, or narration needs it.

Only the accepted quest offer is regenerated: after a successful turn-in it is immediately replaced in its same tavern slot; after a fatal cancellation it is replaced when the hero finishes city recovery and returns to quest choice. Other offers retain their rolled values.

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
8. Courage, Morality, and Greed modifiers are applied from the hero's current traits; DivineModifier remains `0`;
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
→ repeat
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

## UI

Current layout:
- hero panel on the left;
- god-energy panel and three ability buttons above the center log/diary;
- log/diary in the center;
- opponent panel on the right.

The hero panel displays HP with one decimal place and now shows:
- dead state with remaining resurrection ticks;
- city-recovery state after resurrection.

The opponent panel is populated only during active combat.

God-panel button availability follows gameplay state, energy, cooldowns, active buff charges, current HP, and death/respawn state. Instant resurrection is disabled until the hero dies; its button displays the current dynamic energy cost.

A separate panel in the bottom-right corner continuously shows cumulative combat count, wins, losses, and winrate for the current quest mob.

## Tests

Current coverage includes:
- world time and speed controls;
- seeded RNG;
- hero progression;
- combat timing, crits, and simultaneous death;
- quest combat/XP/recovery;
- death and quest cancellation;
- exact 100-tick natural resurrection;
- resurrection at 1 HP;
- city recovery to full HP;
- retention of earlier XP/levels and no Gold for a failed quest.


UI note: during active combat, the hero panel displays live CombatSession HP rather than only the last committed HeroState HP.
