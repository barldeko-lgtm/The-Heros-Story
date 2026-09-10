# The Hero’s Story — Dependencies and Invariants

This document records the **runtime flows, ownership boundaries, and fragile cross-system contracts** that must survive refactoring.

It is intentionally not a balance sheet or a second gameplay specification.

- Current implemented values and temporary deviations belong in `current-state.md`.
- File locations and ownership summaries belong in `project-map.md`.
- Intended Prototype 0.2 design belongs in the Scope.

Use this file when changing a system that hands state or decisions to another system.

## Persistence boundary

`startup_flow.gd` owns session replacement through `save_controller.gd`; MainUI only emits Save/Load requests. Snapshots are captured synchronously after a completed simulation update, never from UI widgets. Loading constructs and validates a detached simulation before replacing MainUI, so every screen binds to the restored live owners. Creation bonuses are not reapplied to the restored state; wall time does not advance simulation on load.

`save_store.gd` reads primitive Variant data only (never executable object deserialization), verifies a SHA-256 envelope, and keeps independent manual/auto files and prior-copy backups. Temporary writes are verified before replacing a target; a corrupt primary never overwrites a valid backup. File format and snapshot schema have independent versions; incompatible data is rejected rather than partly loaded. UI tests must override `startup.save_directory` to a unique project `.godot/` directory, never touch real `user://saves`.

`simulation_snapshot.gd` requires the complete serialized script-property set for the current schema; adding/removing persisted runtime fields needs an explicit compatibility/version decision, not silent constructor-default fallback. Hydration validates values and rebuilds typed arrays before `Object.set` (Godot can silently refuse an untyped Array). Saved questionnaire bonuses/history are restored, not replayed. Both world-position and world-clock callbacks reconnect after hydration. Whole-graph round-trip/continuation comparisons cover history and shared owners, not only HP/Gold.

New-game overwrite confirmation belongs after questionnaire/class selection and before creating/attaching a fresh simulation. Only an existing autosave triggers it; cancellation keeps the selected answers and class without writing either slot. Manual overwrite and load replacement have separate confirmations. A failed normal-close autosave must cancel exit and expose its error.

## Global architectural invariants

Preserve these boundaries unless an explicit approved redesign says otherwise:

```text
definitions / authored data
→ mutable runtime state
→ gameplay / simulation decisions and facts
→ narrative wording
→ UI presentation
```

Core rules:

- UI may request approved actions, but must not own gameplay rules or mutate authoritative gameplay state directly.
- Narrative may describe structured gameplay facts, but must not choose quests, resolve combat, create rewards, change personality, or otherwise invent simulation outcomes.
- `Simulation` coordinates systems and hand-offs; it should not absorb every subsystem's internal rules.
- immutable `.tres` definitions must not become hidden mutable runtime state;
- mutable runtime objects must not duplicate tuning that belongs in definitions/shared balance resources;
- gameplay remains testable without player-facing UI.

## Core runtime coordination

The current high-level autonomous loop is coordinated through `Simulation`:

```text
UI / test command
→ Simulation
→ owning gameplay system
→ structured state/result/fact
→ Simulation hand-off
→ next owning system and/or narrative store
→ UI reads resulting state
```

`Simulation` is allowed to coordinate transitions that cross subsystem boundaries, for example:

- applying XP after a combat victory;
- refreshing resolved hero stats after persistent state changes;
- routing a completed `CombatResult` to the quest, dungeon, or event runner that owns the current fight;
- moving from quest turn-in into market/shopping/dungeon consideration;
- forwarding already-decided facts to Debug Log or Diary narration.

It should not duplicate formulas already owned by a subsystem.

## World time and combat boundary

`WorldClock` is the single authority for ordinary world ticks.

Current timing contract:

```text
ordinary activity
→ WorldClock advances

active CombatSession
→ ordinary WorldClock progression pauses
→ combat resolves on internal combat time
→ completed fight is committed
→ exactly one world tick is consumed for that fight
```

Important invariants:

- pause/developer speed operates through the normal world-time path rather than special-case timers;
- resurrection, travel, recovery, shop refresh, event population timing and God cooldown/recovery all depend on completed world ticks;
- combat must not independently advance those world-tick systems while the duel is active;
- one finished duel produces one `CombatResult` and one world-tick completion, never multiple world ticks because the fight had many attack lines;
- cumulative combat telemetry and narrative logging must not alter combat outcome or tick accounting.

`CombatSession` owns one duel only. It must not:

- cancel quests;
- award quest Gold;
- apply quest/dungeon progression;
- run resurrection/city recovery;
- mutate shop/event/map state;
- write Diary entries directly.

The completed `CombatResult` returns to `Simulation`, which routes it to the current activity owner.

## Mini-window presentation boundary

MainUI owns the mini-mode entry button; its child `mini_window_mode.gd` temporarily hides direct ordinary CanvasItems and displays a single status label with Expand. MainUI refreshes this label immediately after advancing Simulation, instead of refreshing hidden normal UI. MiniWindowMode owns the presentation-only grouping of HeroState.loop_state plus active_combat_session/active_combat_context; it never parses diary text or advances gameplay. Death overrides combat; a stale combat context without a live session never shows a fight. The label ignores mouse input so dragging still reaches the panel. MainUI itself keeps processing the same Simulation: no reparenting, recreation, pause, speed change, or second clock. Restore uses the captured per-control visibility and native window settings, including borderless and content_scale_size (disabled only while mini-sized). On exit, capture mini position before restoring normal window geometry; on re-entry, apply it after mini size/flags. Mini position is session-local, separate from the normal-window snapshot, with no disk persistence. The blank panel requests native window dragging on left press; the icon button consumes its own input without starting a drag. On Windows, set the resize/topmost flags before assigning mini client size because changing window decorations can alter client dimensions.

## New-game background and startup boundary

Normal launch: StartupFlow → BackgroundScreen (selection only) → ClassSelectionScreen (explicit Warrior selection; three locked alternatives) → Simulation constructed with complete background answers → existing MainUI using that same Simulation.

- Neither setup screen owns or advances world time; no Simulation exists until the second Next, which is guarded by a valid Warrior choice.
- Simulation owns the one-time background-created arrival: creation at tick 0 enters VISITING_GUILD at **Дорнвальд** (Starting City) center and records narrator-produced text naming the city before MainUI binds; the first completed world tick enters ordinary autonomous quest selection. No UI-generated diary entries, additional map route, or changes to legacy no-background fixture timing.
- HeroBackground validates all answer indices before mutation, assigns the authored attribute points, and resets/applies personality through TraitDevelopment rather than duplicating threshold rules.
- HeroState.background_answers records the applied selection and prevents applying another background to the same hero.
- Simulation applies background before its first StatResolver pass/full-HP initialization. Questionnaire points never enter the level-up pending-points pool.
- Existing direct/headless constructors without answers retain the seeded trait bootstrap for fixture compatibility; normal startup supplies answers and never rolls established starting traits.
- MainUI accepts an existing Simulation without creating a replacement. Direct MainUI construction remains available for existing isolated UI tests.
- The second screen currently shows Warrior, Archer, Mage, and Assassin; only Warrior is selectable in Prototype 0.2, while the other three choices are visibly locked. Explicit Warrior selection is required before the second Next can start the simulation. Question-per-screen presentation is deferred.

## Hero stats and shared Power

Persistent hero combat values must always resolve through:

```text
HeroState / HeroProgression / Equipment
→ StatResolver
→ base persistent CombatStats
```

Temporary effects use the same resolver to produce an effective combat view:

```text
base persistent sources
+ HeroState.active_effects
→ StatResolver
→ effective CombatStats
```

Contracts:

- persistent equipment and primary-attribute changes affect the base persistent view;
- temporary finite effects affect effective combat stats but must not silently rewrite the persistent base view;
- quest Hard Filter and ordinary virtual-equipment HeroPower comparison use the base persistent view;
- live combat uses the effective view;
- primary-attribute spending routes through gameplay (`Simulation` → `HeroProgression`) and triggers normal stat resolution afterward;
- UI does not apply stat points or recalculate combat stats itself.

Hero and mobs share one Power formula:

```text
CombatStats
 + authored ordinary damage type when relevant
→ PowerCalculator
→ Power
```

Never introduce separate HeroPower and MobPower formulas.

The shared calculator currently applies an elemental-offense evaluation factor of ×1.20 to Fire/Cold/Lightning EffectiveDPS and ×1.00 to Physical. HeroPower and ItemPower keep the default Physical factor unless their evaluated ordinary attack is explicitly elemental in future content. `MobDefinition.get_power()` is the authoritative ordinary-mob entry because it supplies the mob's authored `attack_damage_type`; live opponent Power presentation must preserve that same input rather than recalculating from bare `CombatStats` and losing the damage type.

`ItemPower` may also use `PowerCalculator` against its approved reference profile, but it remains an item rating. It is not added to hero Power and must not become a second runtime Power formula.

## Warrior combat-resource and ability ownership

Current Warrior ability ownership crosses progression/state/combat without merging those responsibilities:

```text
HeroProgression learns Skill Level 1 and defines hero-level rank availability
→ SkillTrainingSystem purchases unlocked higher Skill Levels with Gold
→ HeroState stores learned Skill Levels
→ Simulation supplies the current learned levels + relevant hero attributes when a fight starts
→ CombatSession owns fight-local Rage and the live ability timelines
→ CombatAction carries structured action ids for narration/telemetry
```

Contracts:

- Rage is fight-local `CombatSession` state and is not carried between fights in `HeroState`;
- ability unlock/progression state belongs to hero progression/state, not to `CombatSession`;
- `SkillTrainingSystem` may advance only an already-learned rank that `HeroProgression` says is currently unlocked; it does not grant Skill Level 1 or invent hero-level gates;
- `CombatSession` decides autonomous use of already-learned combat abilities during the duel;
- ability-specific WIS scaling belongs to the ability/combat implementation rather than a fake generic WIS stat conversion in `StatResolver`;
- narrative identifies special actions from structured combat facts/action ids rather than inferring them from damage numbers.

Exact current unlock levels, costs, cooldowns and multipliers live in `current-state.md`/Scope.

## Personality and established traits

Personality flow:

```text
starting bias / authored Formative decision
→ TraitDevelopment
→ HeroState hidden axis values
→ threshold / hysteresis transition
→ established visible trait by axis
→ consumers such as QuestEvaluator / combat / UI
```

Contracts:

- `HeroState` stores mutable axis values and established-trait state;
- `TraitDevelopment` owns clamping, axis-side mapping, activation/hysteresis transitions, and authored Formative movement;
- there is no separate legacy free-form trait list that may disagree with the four axes;
- Formative event choices may move an authored axis because of the meaning of that choice, but should not be chosen by reading the same general personality trait;
- Expressive event choices may read an established trait, but do not automatically reinforce that trait;
- an Expressive stage may author an "any of these traits" check when multiple established traits intentionally lead to the same single branch; this remains one Expressive decision and must not stack the branch effect when more than one listed trait is present;
- an authored Formative movement may establish a visible trait early enough for a later Expressive stage in the same event to observe it;
- UI may display current development/debug state but must not own personality-transition logic.

Exact axis values, thresholds and current starting bootstrap are documented in `current-state.md` and Scope rather than duplicated here.

## Ordinary quest selection and execution

Ownership must stay split:

```text
QuestDefinition
→ QuestPool creates current QuestOffer
→ QuestEvaluator decides suitability/rank
→ Simulation assigns selected QuestOffer
→ QuestRunner executes it
```

### Quest data/runtime boundary

- `QuestDefinition` is immutable authored/tuning data.
- `QuestOffer` owns rolled runtime values and concrete current map target/reservation metadata.
- concrete target hexes and rolled rewards must not be written back into the immutable template.

### QuestPool boundary

`QuestPool` owns:

- quest-template discovery;
- current available board offers;
- offer creation/removal/refresh lifecycle;
- template completion eligibility/cooldown state;
- board-offer map reservations.

It does not calculate QuestScore and does not execute accepted quests.

An accepted quest is no longer an available board entry, but its runtime target remains reserved for the active quest until the quest's own lifecycle releases it. A board refresh must never accidentally release or replace the separate active target.

Successful completion and cancellation are different lifecycle outcomes. Cancellation must not be treated as a successful completion for cooldown/reward purposes.

### QuestEvaluator boundary

`QuestEvaluator` owns:

- Hard Filter eligibility;
- current QuestScore calculation;
- current personality/God influences on that score;
- strict best-offer selection;
- ranked copies of the already-calculated records used for developer diagnostics.

Contracts:

- Hard Filter uses base persistent HeroPower, not current injury and not temporary finite combat effects;
- filtered-out offers do not enter QuestScore;
- personality/God score modifiers apply only inside the evaluator's approved decision path;
- guidance cannot bypass Hard Filter;
- debug narration may display evaluator records, but must not reimplement the score formula;
- UI must not choose the quest itself.

### QuestRunner boundary

`QuestRunner` executes one already selected quest.

It may own quest-specific state transitions such as travel phase, objective progress, post-fight recovery, the post-objective equipment-review gate, return/turn-in and ordinary-quest death/resurrection flow. Whether any generated quest equipment is waiting is supplied to it by coordination; it does not inspect, generate or evaluate those items itself.

It must not own:

- QuestPool generation/refresh;
- Hard Filter or QuestScore;
- combat formulas;
- ordinary equipment generation/evaluation;
- God rules;
- Diary prose;
- UI rules.

XP remains outside `QuestRunner`: `Simulation` applies defeated-mob XP only after a winning `CombatResult`.

## Death and resurrection ownership

Death is activity-contextual even though the broad recovery contract is shared.

`HeroRecovery` implements the shared countdown, resurrection and city-recovery rules without storing runtime state. Each runner retains its own timer, entry guards, failure/context cleanup and original result payloads; Simulation and GodSystem still route through the active runner. Only that owner advances its timer once per completed world tick. Natural and forced resurrection use the same HP/state operation. Ordinary post-victory quest healing remains in QuestRunner and is not tied to city-recovery tuning.

Current pattern:

```text
CombatSession reports defeat
→ Simulation routes defeat to current activity owner
→ that owner cancels/fails its own runtime activity correctly
→ shared safe-city respawn/recovery behaviour
→ normal autonomous flow resumes only after recovery
```

Important contracts:

- the losing mob does not grant victory XP;
- previously earned XP/levels remain;
- failed ordinary quests do not grant completion Gold;
- quest/dungeon/event runtime cleanup belongs to the activity that actually owned the failed fight;
- Divine instant resurrection must route through the currently active respawn owner rather than assuming all deaths belong to `QuestRunner`;
- UI reads remaining respawn state through Simulation's shared boundary and never decrements it itself.

Exact current respawn/recovery values live in `current-state.md`.

## Map, placement, reservations and travel

The map flow is deliberately split:

```text
authored map PNG / HexMapDefinition
→ HexMapImageDecoder
→ HexMap runtime query layer
→ HexDefinition cells

WorldState
→ mutable hero position + activity occupancy

ActivityPlacementFinder
→ candidate locations only

QuestPool / DungeonSystem / EventSystem
→ choose + reserve their own activity locations

TravelSystem
→ execute movement to an already chosen destination
```

### Authored map versus runtime state

- `HexMapDefinition`/source PNG define authored topology and decoding rules;
- `HexMap` derives/querys runtime logical cells, tags, regions, neighbors, routes and distances;
- `WorldState` owns mutable hero position and current activity occupancy;
- neither `HexMap` nor `WorldState` chooses which quest/event/dungeon the hero should pursue.

### Reservation contract

- active map activities reserve footprints through `WorldState`;
- reservation is atomic: a failed footprint reservation must not partially occupy cells;
- one hex may belong to at most one active activity reservation;
- hero presence is not itself an activity reservation;
- releasing an activity must release its complete stored footprint;
- each activity system owns the lifecycle of its own reservation.

### Placement contract

`ActivityPlacementFinder` is read-only. It may filter candidates by region, distance, terrain/tags, footprint validity and current occupancy, but it must not:

- roll RNG;
- reserve cells;
- instantiate quest/event/dungeon runtime state;
- mutate Simulation.

QuestPool, DungeonSystem and EventSystem each use their own placement/lifecycle logic around this shared filter.

### Travel contract

`TravelSystem` receives an already chosen destination, builds/owns the active route and moves the hero through `WorldState`.

It does not choose destinations.

Quest and dungeon runners use the shared travel system instead of implementing their own pathfinding. Event detours use the same system while preserving the interrupted destination where applicable.

### Current city-relocation hand-off

Prototype 0.2 currently uses a deliberately simple temporary relocation gate:

```text
hero reaches Level 13
→ finish current activity and normal Дорнвальд sale/shopping
→ Simulation chooses Арден relocation at the next safe city decision point
→ TravelSystem executes the real route to mid_city_center
→ HeroState.current_city_id remains starting_city during travel
→ physical arrival changes current_city_id to mid_city
→ the arrival tick records one Арден Diary passage and remains ARRIVED_IN_CITY
→ the following tick enters VISITING_GUILD
→ physical arrival also switches the active QuestPool/placement origin and QuestRunner return center to Арден / Mid Region
→ the next normal guild decision may select from Арден's local 4/4/4 board
```

Contracts:

- Level 13 never interrupts an already active quest, dungeon, temporary event, return journey, sale tick or successful shopping tick;
- after shopping is exhausted, relocation takes priority over starting another Starting Region dungeon or ordinary quest;
- `TravelSystem` only executes the already chosen destination and does not own the Level-13 rule;
- supported temporary events may interrupt `TRAVEL_TO_CITY` through the existing suspend/resume contract; an event death before arrival leaves Starting City as the current city, so the Level-13 relocation can be attempted again after recovery;
- city-local ordinary quest content must never leak across cities: Дорнвальд uses the root Starting City quest directory/Starting Region origin, while Арден uses `data/quests/mid_city/` and `mid_city_center` / Mid Region placement;
- ordinary quest completion, cancellation/death, natural resurrection/recovery, and the next quest selection must preserve the authoritative current city. In particular an Арден quest death returns to `mid_city_center`, not the historical `starting_city_center` hardcode.

## Temporary events

Temporary-event ownership is split into population, authored execution and narrative:

```text
EventDefinition / stages / options
→ EventSystem population + placement + instance lifecycle
→ EventRunner executes one engaged graph
→ shared CombatSession / TraitDevelopment / TravelSystem as needed
→ EventSystem cleanup
→ EventNarrator for developer wording
```

### EventSystem contracts

`EventSystem` owns:

- definition loading;
- population/availability lifecycle;
- seeded placement;
- current event reservations;
- engagement lookup;
- per-definition cooldown/eligibility state;
- instance cleanup.

It does not execute stages, move the hero, resolve combat or mutate personality directly.

If event placement competes with available quest-board reservations, only the currently available board markers may be released/rebuilt. An already accepted active quest target must never be displaced just to make an event fit.

An engaged event must survive ordinary population rotation until its own normal completion/failure cleanup.

Primary and optional secondary event objectives must be reserved/released consistently as one event lifecycle.

### EventRunner contracts

`EventRunner` owns execution of one engaged authored graph.

It may:

- advance timed stages;
- route Formative movement through `TraitDevelopment`;
- read established traits for single-trait or authored any-of-traits Expressive stages;
- request shared combat;
- use `TravelSystem` for authored detours;
- own event-context death/recovery;
- resume the previously interrupted travel target after successful resolution.

It does not own general event population/placement.

`EventDefinition.validate_definition()` is the content boundary before a definition enters runtime. SCENE, TRAVEL, DECISION, COMBAT and END validation must remain independent stage-type checks; malformed decision links/rules or combat targets must be rejected even when the event contains no TRAVEL stage.

Event COMBAT stages may author a starting current-HP ratio for their referenced mob. `Simulation` applies that ratio only to `CombatSession.mob_remaining_hp` when the event fight starts. The referenced immutable `MobDefinition`, its `CombatStats.max_hp`, Attack, Armor, Attack Speed, Power inputs and other authored stats remain unchanged. A ratio of `1.0` is the default and preserves all older event fights unchanged.

### Travel interruption contract

When an event interrupts supported travel:

```text
current TravelSystem destination
→ suspend original destination
→ run event / optional detour
→ finish event successfully
→ rebuild route from hero's current hex to original destination
```

The event engagement hex is runtime state and may matter independently of the event center.

If an event kills the hero during outbound dungeon travel before the hero entered the dungeon, the dungeon trip is cancelled as an external failure. It must **not** create dungeon failed-attempt memory or retry-Power penalties.

If an event interrupts return travel after the dungeon was already completed, successful event resolution must resume the route to the city from the hero's new hex. If the event kills the hero, the completed dungeon and its already-granted rewards remain completed/permanent; only the stale return-trip runtime is cleared, and no new dungeon failed-attempt memory or retry-Power penalty is created.

Exact current event timing/population tuning and supported interception states live in `current-state.md`.

## Ordinary dungeons

Dungeon ownership remains separate from quests:

```text
DungeonDefinition
→ DungeonSystem placement / discovery / map lifecycle
→ DungeonEvaluator readiness
→ PotionPreparationSystem readiness
→ DungeonRunner expedition
→ shared TravelSystem + CombatSession
→ reward routing / map cleanup / return flow
```

### DungeonSystem boundary

`DungeonSystem` owns:

- ordinary dungeon definition discovery/loading;
- map placement and reservations;
- known/unknown discovery state;
- Divine Vision reveal support;
- completed-dungeon map cleanup.

It does not execute travel or dungeon combat.

Dungeon discovery changes knowledge state only. It must not automatically interrupt the hero's currently active quest/event/travel activity or force an immediate expedition.

Specialization dungeons remain outside the ordinary-dungeon loader.

### DungeonEvaluator boundary

`DungeonEvaluator` owns dungeon readiness/retry Power evaluation from stored attempt memory.

It is not part of QuestScore and must not become a second quest evaluator.

The failed-attempt runtime instance stores facts such as attempt-start Power and reached progress; the evaluator owns the rule that turns those facts into a retry requirement.

### Potion readiness boundary

Dungeon readiness is not only a Power question. The complete current Belt loadout must also pass through `PotionPreparationSystem`.

`PotionPreparationSystem` owns:

- planning a complete legal prepared loadout;
- purchase of missing bottles when the city flow reaches the approved preparation step;
- prepared-slot state;
- allowed between-fight consumption decisions.

It does not own dungeon travel/combat or Belt generation.

### DungeonRunner boundary

`DungeonRunner` owns one approved expedition:

- travel to the target through `TravelSystem`;
- authored encounter cursor;
- carried HP between fights;
- dungeon between-fight states;
- transition to boss;
- success/failure progression;
- successful return travel;
- dungeon-context death/resurrection/recovery.

Combat itself remains the shared `CombatSession`.

Potion consumption remains coordinated through `PotionPreparationSystem` inside the approved between-fight window.

Dungeon execution must not be forced into `QuestRunner` simply because both activities contain combat and travel.

## Generated equipment, loot and inventory

Generated equipment must preserve this chain:

```text
drop/reward source
→ LootGenerator
→ ItemGenerator
→ ItemInstance
→ EquipmentEvaluator
→ Equipment or Inventory
→ StatResolver refresh
```

Ordinary quest mob equipment now inserts a delayed review boundary into that same chain:

```text
mob defeated
→ LootGenerator rolls the source drop
→ ItemGenerator creates the concrete ItemInstance immediately
→ current quest equipment buffer (not yet Equipment / Inventory)
→ main mob objective completed
→ if buffer is non-empty: exactly one world-tick review phase
→ EquipmentEvaluator routes every buffered item in sequence
→ Equipment or Inventory
→ StatResolver refresh as required
→ normal return travel
```

No equipment drop means no review phase and no extra world tick. Multiple buffered items are all reviewed inside the same single review tick; item count must not multiply world-time cost. A failed unresolved ordinary quest clears its still-buffered equipment. This current buffer is a narrow equipment-only implementation slice and must not be mistaken for the final generalized QuestLoot/trophy/backpack model.

### Definition/runtime boundary

- `ItemDefinition` is immutable identity/visual/base data;
- `ItemInstance` is the concrete acquired/generated item with current generated values;
- shared inherent-stat, budget, stat-cost and price tables remain central data resources, not copied into every item definition;
- old compatibility fields on visual definitions must not silently become competing runtime stat sources.

### LootGenerator boundary

`LootGenerator` selects the approved source/slot/rarity outcome. It does not generate final affix values and does not mutate the hero.

### ItemGenerator boundary

`ItemGenerator` turns approved source data into a concrete `ItemInstance` using shared item-balance resources and seeded RNG.

It does not decide whether the result should be equipped.

### EquipmentEvaluator boundary

`EquipmentEvaluator` compares a candidate without mutating live Equipment.

Contracts:

- ordinary equipment uses virtual replacement and compares resulting base persistent HeroPower;
- displayed rarity or ItemPower alone must not decide final ordinary equip routing;
- temporary effects are excluded from both sides of virtual-equip comparison;
- ring candidates must be evaluated against both ring positions and return the best actual target slot;
- Belt is the explicit utility exception and uses its approved potion-utility ordering rather than fake HeroPower from capacity;
- callers must respect the target slot returned by evaluation instead of blindly using the authored ring slot.

### Inventory boundary

- equipped items and retained unequipped equipment are distinct state;
- healing-potion counts are persistent Inventory state but are separate from retained-equipment FIFO capacity;
- automatic sale systems must never treat potions as ordinary equipment;
- ordinary found/reward equipment that replaces an equipped item routes the displaced/rejected permanent gear through the normal retained-Inventory path, while a **shop purchase** follows the separate shop transaction rule where the replaced equipped item is sold immediately instead of entering Inventory;
- still-unreviewed ordinary quest equipment remains separate from permanent Equipment/Inventory so quest failure can clear unsafe carried equipment without deleting permanent gear; a future generalized QuestLoot/trophy/backpack model must preserve that separation.

Exact current slot counts, tier mappings, drop chances and rarity tuning live in `current-state.md`/data.

## Economy, shop and autonomous spending

The current safe-city economy hand-off is:

```text
successful quest turn-in
→ VISITING_MARKET
→ EquipmentSaleSystem
→ SHOPPING
→ SpendingEvaluator reads established Curious / Conservative preference
   → Curious or neutral: SkillTrainingSystem first, then equipment
   → Conservative: equipment first, then SkillTrainingSystem
→ preferred category has no valid affordable purchase: evaluate the lower-priority category on the same tick
→ successful SkillTrainingSystem or ShopSystem transaction ends this world tick and remains in SHOPPING when another optional purchase is possible
→ repeat while another valid purchase exists
→ dungeon readiness / potion preparation or next activity
```

### Sale contract

- quest turn-in does not directly perform all economy work in the same state transition;
- `EquipmentSaleSystem` owns automatic sale of eligible unequipped ordinary equipment;
- it must not sell equipped gear or healing potions;
- death and unrelated runtime events must not trigger automatic city sale;
- unpriced items remain retained rather than receiving invented pricing.

### SpendingEvaluator contract

`SpendingEvaluator` evaluates purchase-category priority and equipment purchases; it does not mutate Gold/equipment.

It may use:

- affordability;
- current ordinary upgrade rules;
- `EquipmentEvaluator` results;
- established Curious / Conservative personality for category ordering;
- a protected-Gold budget supplied by Simulation when a Power-ready dungeon needs mandatory potion preparation.

Belt candidates continue through the Belt-specific utility rule rather than the ordinary equipment comparison path.

### SkillTrainingSystem contract

`SkillTrainingSystem` owns higher-rank training transactions, not world-time progression. Category order is supplied by the autonomous spending policy: established Curious and neutral Warrior behaviour check training before equipment; established Conservative checks meaningful equipment before training. The lower-priority category is not forbidden. If the preferred category has no valid affordable purchase, Simulation evaluates the other category on the same tick, so a failed preference check never adds empty world time.

Training receives the same protected optional-spending Gold budget used for normal equipment, so a feasible mandatory potion loadout for a Power-ready dungeon remains reserved. When more than one rank is available, the current deterministic base-skill order is used among affordable candidates; each later purchase requires its own world tick. After a successful equipment purchase, SHOPPING must remain active when either another valid equipment purchase or an affordable unlocked Skill Level still exists, so Conservative can exhaust its preferred equipment category and then continue into training instead of ending the city phase early.

### Dungeon preparation budget policy

`DungeonPreparationBudget` owns the read-only economic protection rule: reserve the missing potion purchase cost of a feasible current loadout from optional development spending, and reject Belt candidates whose post-purchase Gold cannot fill their resulting capacity. Already owned potions count through the existing `PotionPreparationSystem` planner.

Simulation supplies current-region known-dungeon Power readiness and keeps its public budget/listing/plan methods. No ready dungeon means no preparation reserve/filter; an unaffordable current loadout retains the existing unrestricted-budget behaviour. Filtering preserves listing indices and never mutates real shop stock or hero state. Actual potion purchasing, travel and world-tick transitions remain outside this policy.

### ShopSystem contract

`ShopSystem` owns mutable stock, deterministic refresh, vacancies and purchase transactions.

It uses shared `ItemGenerator`/price data rather than embedding duplicate generated stats or price formulas into shop stock.

Replacing an equipped item in a shop transaction follows the current shop replacement/sale flow rather than routing the replaced item through the ordinary retained-inventory path.

Exact shop cadence, listing counts, price thresholds and current tiers live in `current-state.md`.

## God system

God-state ownership is split deliberately:

```text
GodState
→ energy / cooldown / pending guidance state

GodSystem
→ validates/applies divine commands through existing gameplay owners

Simulation
→ stable public command boundary + coordination/refresh/narrative

HeroState.active_effects
→ active temporary combat blessing state
```

Contracts:

- UI sends divine requests through Simulation rather than mutating GodState or hero/combat state directly;
- divine healing during active combat must update live CombatSession HP rather than stale stored HP;
- a combat blessing enters the normal effective-stat path through `HeroState.active_effects` / `StatResolver` rather than adding a special extra damage parameter to CombatSession;
- blessing duration/remaining-fight charges live with the hero effect state; after a finished fight `Simulation` coordinates charge consumption and any required stat refresh rather than making `CombatSession` own persistent blessing lifetime; only fights that started with the blessing consume a charge, so activation during combat applies from the next fight;
- temporary blessing effects remain excluded from base HeroPower/Hard Filter;
- guidance only modifies an eligible current offer through the existing QuestEvaluator decision path and cannot bypass Hard Filter;
- Divine Vision reveals an already-existing unknown dungeon through `DungeonSystem`; it does not create a dungeon or command travel;
- instant resurrection routes through the active death owner and returns to the normal recovery contract.

Exact ability costs/cooldowns are current-state tuning rather than dependency documentation.

## Narrative, Debug Log and Diary

All player/developer text must remain downstream of gameplay facts:

```text
gameplay system
→ structured fact / result
→ narrator / formatter
→ narrative store
→ UI
```

Never parse UI/narrative text back into gameplay decisions.

### Developer Debug Log

- `QuestNarrator`, `EventNarrator` and `DungeonNarrator` format already-produced facts;
- debug narration may expose detailed diagnostics;
- quest-selection narration uses the evaluator's returned ranked records and must not recalculate QuestScore;
- DebugLog retention/scrolling must not affect simulation state or combat telemetry.

`EconomyNarrator` and `ItemNarrator` format already-resolved economic/item facts. They do not mutate hero state, evaluate purchases, generate rewards, consume RNG, or write to DebugLog/Diary. Simulation retains log insertion at the original world tick and in the original order, including reward-before-overflow messages. Item stat/HP refresh and explicit suppression of duplicate equipment Diary records remain in Simulation; the Rare/Epic recording filter belongs to DiaryRecorder.

### Hero Diary

Current ordinary-quest path:

```text
HERO_SELECTED_QUEST fact
→ Simulation / DiaryRecorder / DiaryNarrator
→ Diary temporary selection entry
→ remains visible while that quest is active

successful HERO_TURNED_IN_QUEST
→ remove temporary selection entry
→ add one permanent completion entry at the real completion tick

quest death / external cancellation
→ remove temporary selection entry
→ keep the separate meaningful death/event consequence entry
```

Combat death from any currently supported activity follows the shared narrative path:

```text
quest / dungeon / temporary-event combat defeat
→ Simulation keeps the real killer + owning activity context
→ DiaryNarrator shared death wording
→ Diary.add_entry(world_tick, text)
→ NarrativePanel
```

Resurrection follows the same downstream-only rule:

```text
natural respawn completion OR successful divine instant-resurrection command
→ Simulation knows the real resurrection source
→ DiaryNarrator shared resurrection wording
→ Diary.add_entry(world_tick, text)
→ NarrativePanel
```

Meaningful reward/drop equipment uses the shared acquisition path:

```text
mob drop / non-event reward source
→ EquipmentRewardSystem creates and routes the ItemInstance
→ Simulation finalizes the acquired item
→ Rare/Epic significance check
→ DiaryNarrator shared equipment-acquisition wording
→ Diary.add_entry(world_tick, text)
→ NarrativePanel
```

Successful temporary events use their authored branch ending directly:

```text
EventRunner resolves one concrete END stage
→ Simulation applies that END stage's real rewards
→ DiaryNarrator receives the resolved END stage
→ the END stage's authored diary_text becomes one Diary passage
→ NarrativePanel
```

Ordinary dungeon milestones use one coordinated downstream path:

```text
discovery / successful begin_trip / actual potion purchase / completion reward
→ Simulation keeps the already-decided dungeon facts
→ DiaryNarrator shared dungeon wording
→ Diary.add_entry(world_tick, text)
→ NarrativePanel
```

Contracts:

- `DiaryRecorder` owns the temporary quest-entry id/lifecycle, supplied-fact recording and Rare/Epic significance filter; it receives explicit data/ticks, never owns gameplay state, and uses the same live Diary/Narrator;
- Simulation keeps the existing record-call timing and public wrappers, supplies real outcomes and explicitly suppresses duplicate equipment records for event/dungeon rewards;
- `DiaryNarrator` describes approved facts only;
- `Diary` stores ready player-facing entries and owns no significance/gameplay rules;
- ordinary quest selection is the current narrow exception that uses a removable Diary entry for active-activity visibility; DiaryRecorder owns its lifecycle and clears it when Simulation reports successful turn-in, quest death, or external quest cancellation;
- real dynamic names/rewards/outcomes come from current game state/events rather than being duplicated in templates;
- generic reusable wording belongs in shared narrative data;
- shared death wording must receive the actual killer and owning quest/dungeon/event name from gameplay context rather than infer them from UI text;
- shared resurrection wording must receive the actual natural/divine source from Simulation; a failed divine command must never create a resurrection Diary entry;
- only acquired Rare/Blue and Epic/Purple reward/drop equipment currently enters the Diary through this path; Common/White and Uncommon/Green equipment remain routine noise;
- dungeon completion folds its guaranteed Rare/Epic equipment into the single dungeon-completion Diary entry, so the same reward must not also create the generic Rare/Epic acquisition entry;
- a successful temporary event uses the `diary_text` authored on the exact END stage that actually resolved; intermediate `scene_text`, decision diagnostics, travel progress, and combat detail remain Debug Log material;
- equipment granted by a successful temporary event must not also create a separate Rare/Epic acquisition Diary entry, because the event passage owns the whole outcome and reward context;
- dungeon potion wording uses the executed preparation result and therefore reports the number actually bought, not Belt capacity or planned loadout size;
- shop purchases are not routed through reward/drop acquisition Diary wording and remain a separate future Diary source;
- unique authored wording may remain with the content it belongs to;
- narrative phrase selection uses a dedicated RNG stream so adding or reordering wording variants cannot perturb gameplay RNG;
- UI displays Diary output and must not create Diary gameplay facts itself.

Current Diary coverage and missing sources are listed in `current-state.md`.

## UI boundary

The current UI is a presentation/command layer over one live `Simulation`.

Contracts:

- switching screens changes presentation visibility only; it does not replace or pause Simulation unless an explicit gameplay command does so;
- `MainUI` coordinates screens and forwards approved commands;
- Inventory UI reads equipment/inventory state but does not grant/equip/buy/sell/consume items;
- Map UI reads runtime map/activity state but does not choose destinations, reserve activities, move the hero or reveal dungeons directly;
- God UI sends commands through Simulation;
- NarrativePanel subscribes to DebugLog/Diary and displays them without changing gameplay;
- developer UI may temporarily expose hidden diagnostic values, but those displays are not authoritative gameplay state.

## RNG separation

The simulation is seeded/reproducible, but not every subsystem should consume one shared sequence casually.

Preserve separate/derived deterministic streams where adding behaviour in one subsystem must not alter unrelated outcomes.

Current examples include placement/shop/narrative streams.

General contract:

- adding a Diary phrase variant must not change loot or quest outcomes;
- changing shop refresh generation must not silently perturb core gameplay RNG sequence;
- map-placement retries in one activity system should not unpredictably reshuffle unrelated random systems;
- deterministic tests should be able to depend on a stable seed within the system they actually test.

Do not introduce a new RNG stream without a concrete need, but do not consume the main gameplay sequence for presentation-only randomness.

## Compatibility boundaries that should not spread

Some legacy compatibility paths still exist for old tests/data. They should remain isolated rather than becoming new design dependencies.

Examples:

- `Simulation` still supports an explicit fixed-quest construction path for regression tests while the real developer flow uses autonomous selection;
- legacy abstract quest-distance data may still exist for old fixed offers, while live map-backed gameplay uses concrete targets/routes;
- old serialized item-definition stat fields may exist as compatibility data while current generated equipment uses `ItemInstance` values/shared balance tables.

When touching these paths, prefer containing/removing legacy assumptions rather than spreading them into new systems.

## Tests protecting fragile hand-offs

Do not run the whole historical suite by default for a small change. Use the narrow tests nearest the contract being modified.

High-value integration coverage includes:

- `tests/test_autonomous_quest_choice.gd` — selection happens before execution;
- `tests/test_quest_evaluator.gd` — Hard Filter / score decision boundary;
- `tests/test_quest_offer_refresh_lifecycle.gd` and `test_quest_offer_cancelled_lifecycle.gd` — board versus active-offer lifecycle;
- `tests/test_death_respawn.gd` — combat defeat → activity cancellation → respawn/recovery;
- `tests/test_personality_traits.gd` and event runtime tests — personality transition/consumer boundaries;
- `tests/test_event_population_rotation.gd` — event population/reservation lifecycle;
- `tests/test_event_travel_suspend_resume.gd` — event detour and original-route restoration;
- `tests/test_event_batch_six_to_thirteen_content.gd` and `test_event_batch_six_to_thirteen_runtime.gd` — strict event-graph validation plus representative live branches across the expanded Starting Region content pool;
- `tests/test_event_batch_fourteen_fifteen_content.gd` and `test_event_batch_fourteen_fifteen_runtime.gd` — two-way CON/STR Formative content plus real secondary-objective travel, same-event Generous/Cautious activation, quarry combat/avoidance and route restoration;
- `tests/test_event_dungeon_travel_interruption.gd` — outbound and completed-return dungeon interruption/resumption without false dungeon failure memory;
- `tests/test_dungeon_post_quest_decision.gd` — market/shopping/readiness/preparation/dungeon hand-off;
- `tests/test_dungeon_combat_sequence.gd` — shared combat plus dungeon-owned expedition progression;
- `tests/test_dungeon_retry_readiness.gd` — failed-attempt memory → evaluator gate;
- `tests/test_belt_and_healing_potions.gd` — Belt/economy/potion/dungeon readiness integration;
- `tests/test_god_abilities_integration.gd` — God commands through existing stat/quest/death owners;
- `tests/test_ordinary_quest_diary.gd` — gameplay quest facts → Diary narration/store;
- `tests/test_debug_log_autoscroll.gd` and `test_main_ui_component_extraction.gd` — presentation updates without gameplay ownership.

If a refactor changes a hand-off named in this document, update or add the closest deterministic test rather than relying only on visual testing.

## Divine-action secondary labels

GodPanel retains the original Button nodes and command callbacks. refresh computes the same disabled states and detail strings; set_action_text puts the title in Button.text and the second line in its ActionDetail Label, also preserving the full string in the tooltip. The label ignores mouse input and cannot intercept clicks. Consumers that inspect costs or cooldowns read ActionDetail.text, not Button.text. No resource-cost or ability-availability rule moved into the new formatting helper.

## Main-screen button/tab appearance

MainUI, GodPanel and NarrativePanel opt into main_screen_button_style.gd; it owns only visual overrides, never disabled/toggle values or gameplay callbacks. Current navigation is highlighted without changing toggle_mode or pressed signals. Tab appearance must be applied to TabContainer itself: Godot forwards the owner theme to its internal TabBar and can overwrite direct child overrides. Legacy MainUI secondary-button styles remain for the mini-window Expand control; no global Theme replacement affects setup or other local screens.

## Hero summary presentation

MainUI → HeroSummaryPanel.setup(existing Simulation) → structured hero card. MainUI retains visible-screen scheduling and GodPanel/HeroScreen signal routing through update_hero_panel. HP reads get_current_hero_hp (including live combat); other stat values retain the prior base-stat sources, with conditional bonuses described separately. XP/level/gold read HeroState. Card refresh updates bars, labels, rich-text details and the pending-point indicator without advancing time or consuming RNG. The plus lives in the level HBox rather than using calculated text-line coordinates. The detail body scrolls independently within the fixed card; it retains all prior statistics, bonuses and Seed. hero_details_label now exposes a RichTextLabel, hero_panel owns geometry; obsolete state-spacer accessors were removed. tests/test_hero_card.gd and tests/test_hero_summary_extraction.gd cover rendering, indicator, navigation and read-only ownership.

## Hero development screen presentation

MainUI → HeroScreen.setup(existing Simulation) → screen-local controls/refresh.
Attribute button → Simulation.allocate_primary_attribute → hero_state_changed → MainUI hero summary refresh, then local allocation refresh. Rules and point consumption stay in Simulation.
MainUI owns time advancement and navigation; hidden HeroScreen has no polling loop and is refreshed immediately on opening. Existing update wrappers and control references remain available. `tests/test_hero_screen_extraction.gd` covers these contracts plus runtime geometry and personality markers.

## Refactor checklist

Before completing a cross-system change, verify:

- Did mutable state stay with its owner?
- Did calculations stay out of UI and narrative?
- Did `Simulation` coordinate rather than duplicate subsystem rules?
- Are base persistent stats still distinct from effective temporary stats?
- Is Power still shared through `PowerCalculator`?
- Does quest evaluation remain separate from quest execution?
- Are map placement, reservation and travel still separate responsibilities?
- Can an event detour resume the correct original route?
- Can dungeon failure memory only be created by an actual dungeon attempt?
- Does generated equipment still pass through the shared generation/evaluation chain?
- Are potions still separate from retained-equipment FIFO behaviour?
- Do God abilities route through the existing gameplay owners?
- Does narrative receive facts rather than create outcomes?
- Does presentation-only randomness remain isolated from gameplay RNG?

If the answer to any of these changes, that is an architectural change and should be explicit rather than an accidental side effect.
