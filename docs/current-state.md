# The Hero’s Story — Current Project State

This document describes what is **actually implemented now**.

## Current development focus

The project is building the first authored Prototype 0.2 world-map slice. Ordinary quest-board placement/travel and both Starting Region ordinary dungeons now use the shared map-backed placement/discovery/travel/combat/retry-readiness/potion-preparation/completion-reward flow; temporary travel events and city relocation remain unintegrated.

Implemented:
- one autonomous hero;
- a three-piece Common starting outfit equipped on every new hero: `Поношенная рубаха`, `Поношенные штаны`, and `Поношенные сапоги`; each fixed ilvl 1 piece grants exactly +1 Armor, has no random affixes, uses its supplied inventory icon and aligned paper-doll overlay, and sells for 1 Gold after a normal upgrade replaces it;
- Prototype 0.2 Warrior primary attributes with +1 fixed STR and 4 pending player-distributed primary-attribute points on every pre-specialization level-up;
- world tick;
- pause and developer speed controls (×0, ×1, ×2, ×5, ×10, ×20, ×100);
- one shared seeded RNG for current simulation randomness;
- one shared Power calculation for hero and mobs;
- live one-on-one combat with timed strikes;
- fight-local Warrior Rage plus the autonomous compressed Level 5 Power Strike and Level 10 Battle Guard at Skill Level 1;
- per-mob XP and post-fight recovery;
- death, 100-tick natural resurrection, and city recovery;
- twenty-two Starting City mob definitions on the approved gradually widening Power curve from approximately 30 to 650, including the added Stray Dog, Experienced Goblin, Wounded Troll, Mature Wolf, Young Troll, Experienced Ogre, and Orc Veteran;
- twenty-two matching Starting City quest templates;
- three live seven-piece visual equipment families, each with five armor pieces plus sword and shield and Common/Uncommon/Rare definitions: ilvl 1 `Посвящённый Ржавой Цепи` (`Rustchain Initiate`), compressed ilvl 5 `Страж Железного Следа` (`Ironwake Sentinel`), and compressed ilvl 10 `Авангард Железного Оплота` (`Ironward Vanguard`), whose sword and shield still use neutral placeholders;
- separate compressed ilvl 5 and ilvl 10 accessory sets for necklace, earrings, two mechanically separate ring slots, and Belt; both rings within each tier share the supplied tier icon, all accessories use inventory/equipment icons without hero paper-doll overlays, and Belt rarity provides 1 / 2 / 3 / 4 potion slots for Common / Uncommon / Rare / Epic while Item Level limits the strongest legal potion tier;
- source-driven ordinary-mob equipment drops keep the same 5% chance and Common/Uncommon/Rare distribution of 70%/25%/5% with an 8/7/7 Power-band split: the eight lower-band mobs use seven-slot ilvl 1 Rustchain; the seven middle-band mobs from Giant Spider through Young Troll use the twelve-slot compressed ilvl 5 source with Ironwake core equipment plus existing accessories; the seven higher-band mobs from Young Ogre through Orc Veteran use twelve-slot compressed ilvl 10 Ironward core equipment plus the existing accessories;
- virtual-equip comparison by real base HeroPower plus a 36-slot FIFO inventory for unequipped drops before city sale;
- a Starting City equipment shop with compressed ilvl 1 Rustchain, ilvl 5 Ironwake-core-plus-accessory, and ilvl 10 Ironward bands; each contains 6 White unique-slot listings and 2 Green unique-slot listings for 24 total listings, deterministic 200-world-tick stock refresh, and autonomous one-purchase-per-tick upgrade buying;
- twenty-two Starting City quest templates grouped into 8 lower / 7 middle / 7 higher bands; for current development testing the normal 3-offers-per-band board cap is temporarily disabled, so every currently eligible template may appear on the board at once;
- autonomous choice among the current quest offers;
- seeded assignment of 1–2 starting personality traits from Coward, Brave, Dishonorable, Noble, and Greedy;
- current personality modifiers in QuestScore (Courage up to ±0.30, Greed up to +0.30, Morality +0.20) and 10% category damage for Noble/Dishonorable;
- ordinary quest Hard Filter now uses the Scope Power window before QuestScore: standard 55–95% of HeroPower, Brave 60–100%, and the current legacy Coward trait as the temporary Cautious equivalent at 50–90%;
- headless god-system core with 100 starting energy, world-tick recovery, cooldowns, instant resurrection, divine healing, five-fight Attack buff, one-selection quest guidance, and Divine Vision for revealing an unknown dungeon in the current region;
- a quest execution loop after the selected quest is assigned;
- structured quest/death events;
- separate quest narration;
- debug log;
- empty diary shell;
- rough developer UI;
- ordinary `DungeonDefinition` resources are loaded automatically from `data/dungeons/starting_region/` and `data/dungeons/mid_region/`; dungeon-only mob resources in those folders are ignored by the loader, while `data/dungeons/specialization/` remains separate from the ordinary population. The current population contains both required Starting Region dungeons: `Заброшенные железные шахты`, placed on one deterministic reserved hill hex 4–7 steps from the Starting City center, and `Городище Черноклыков`, placed on one reserved forest hex 5–7 steps from that center. Both begin unknown, may be discovered by Divine Vision or physical entry, and use the supplied 440×400 dungeon map sprite at 65 px draw height; the current developer map intentionally renders unknown dungeons at 40% opacity while keeping their names hidden until discovery;
- every ordinary dungeon authors one ordinary mob type and a 3–5 room count, so that same ordinary mob is fought in every pre-boss room before the dungeon's unique boss. `Заброшенные железные шахты` authors `3 × Шахтный троглодит` (~200 Power, 150 XP) → `Глубинный пожиратель` (~300 Power, 185 XP), with 700 Gold + one compressed ilvl 5 75% Rare / 25% Epic completion item. `Городище Черноклыков` authors `3 × Гоблин-гвардеец` (~600 Power, 260 XP) → `Король гоблинов` (~750 Power, 320 XP), for 1100 total combat XP and a completion reward of 2000 Gold + one compressed ilvl 10 item rolled uniformly across the full twelve-slot Ironward source at the same 75% Rare / 25% Epic split. Discovery does not interrupt the hero's current activity, and after the current quest is turned in and the normal market/shopping routine finishes a known local dungeon is considered before another ordinary quest only if its current readiness check passes; `DungeonRunner` sends the hero along the real `TravelSystem` route and executes each authored 3+boss sequence through the same live `CombatSession` used by quests. Current HP carries between encounters, each ordinary victory creates exactly one world tick of between-fight preparation, and the potion system may consume multiple prepared potions inside that same tick when the approved ordinary-room or pre-boss healing rules call for them; ordinary-room healing never intentionally overheals, while pre-boss preparation may accept overheal to reach full HP. Ordinary/boss combat grants XP but no ordinary equipment drop or per-mob Gold. Completion rewards use the normal generated-item/equipment-evaluation pipeline; non-Belt Epic instances receive the existing three-affix Epic budget while Belt remains affixless and uses its Epic four-slot potion capacity instead. Successful completion releases that dungeon's map reservation so its marker and discovered-map entry disappear immediately, then `DungeonRunner` starts a real `TravelSystem` route back to the Starting City at one adjacent hex per world tick; arrival enters the normal `VISITING_MARKET → SHOPPING → next activity` city cycle. Dungeon death still returns the hero to the city with the normal 100-tick resurrection/city-recovery flow; every failed attempt remembers the HeroPower recorded when that attempt began and the reached progress, and later post-shopping dungeon decisions are blocked until Power reaches the current retry gate: +25% if no ordinary enemy was killed, +15% after ordinary progress before the boss, or +10% after reaching the boss; a new failed retry replaces the baseline with that retry's own starting HeroPower; every attempt additionally requires every current Belt slot to be filled with a legal potion before travel begins;
- a 26 × 15 PNG-driven hex world foundation where all 390 logical gameplay cells become `HexDefinition` objects with logical coordinates, terrain, city-region ownership, and permanent semantic tags; the enlarged 1448 × 1086 source art contains 13 additional decorative bottom hexes that are intentionally outside the logical gameplay rectangle. Current tags are `city` on all 14 city hexes, `city_center` on the two city centers, and `road` on the authored ordered road path, with ordinary untagged cells allowed; each city region extends up to seven hex steps from its city center, overlapping candidates belong to the nearer city, and the resulting current map contains 150 Starting Region hexes, 150 Mid Region hexes, and 90 peripheral hexes with no region; `HexMap` can return complete radius areas around a center, `WorldState` can atomically reserve/release map hexes for active activities with a strict one-activity-per-hex rule, `ActivityPlacementFinder` can filter valid activity centers, and `TravelSystem` owns deterministic multi-tick hero movement along `HexMap` routes at exactly one adjacent hex per world tick; ordinary selected quests travel from the Starting City center to their real `QuestOffer.target_hex` and return to the city center after completion; plains/forest/hill cells render from three authored 158 × 140 RGBA sprite variants per biome, road cells temporarily reuse plains sprites under the existing road line, both seven-hex city clusters use the same authored 418 × 440 RGBA `town1.png` overlay at native size, and the current hero map visual uses the supplied high-resolution sprite scaled only at draw time to 120 px tall while following the live `WorldState.hero_position`; the map also has one-pixel black hex outlines on non-city cells, runtime route/distance queries, an interactive debug tooltip that shows coordinates, terrain, region, and tags, mouse-wheel zoom, and right-button drag panning;
- automated regression tests and GitHub CI.

Current next major gameplay step:
- continue Prototype 0.2 from the now-working first-dungeon + Belt/potion vertical slice into the next approved gameplay/content block without expanding unrelated systems.

Still missing from the current build:
- diary episodes;
- player-facing quest-guidance selection UI;
- later potion tiers beyond the currently live Starting City compressed Level 5 / 10 consumables, prepared-Belt-slot visualization, and the two Mid Region ordinary dungeons;
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
- `DUNGEON_RETURNING_TO_CITY`;
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

Each pre-specialization level-up now follows the approved player-guided rule:
- +1 STR is applied automatically as fixed Warrior class growth;
- +4 primary-attribute points are added to `HeroState.pending_primary_attribute_points`;
- pending points provide no stat benefit until the player explicitly spends them on STR / DEX / INT / CON / WIS;
- unspent points accumulate across later level-ups rather than being auto-assigned or discarded.

`Simulation.allocate_primary_attribute()` is the gameplay command boundary for spending one pending point. It rejects allocation during an already active combat session, delegates the actual point spend to `HeroProgression`, then refreshes resolved CombatStats. A Constitution allocation updates MaxHP through the same persistent-stat refresh path rather than bypassing `StatResolver`.

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

Persistent equipment contributes to both views. A new hero begins with three fixed Common ilvl 1 `ItemInstance` objects already equipped in Chest, Pants, and Boots; each contributes exactly +1 Armor and has no random affixes. Rustchain Initiate drops are generated as ilvl 1 `ItemInstance` objects: armor receives 5 inherent Armor, the sword receives 10 inherent Damage and +0.10 Attack Speed, and the shield receives 10 inherent Block. The former ilvl 10 tier is now compressed to ilvl 5 without changing strength: Ironwake Sentinel uses 7 Armor, 13 sword Damage/+0.10 Attack Speed, and 13 shield Block; its jewelry keeps inherent Resistance 20 and its Belt keeps 40 Health. The former ilvl 20 tier is now compressed to ilvl 10 without changing strength: Ironward Vanguard uses 10 Armor, 17 sword Damage/+0.10 Attack Speed, and 17 shield Block; its jewelry keeps inherent Resistance 25 and its Belt keeps 50 Health. The full equipment control-point scale is compressed from `1/10/20/30/40/50/60` to `1/5/10/15/20/25/30` while all corresponding stat and modifier-budget values remain unchanged. Belt uses no ordinary random-affix budget: rarity instead supplies Common/Uncommon/Rare/Epic potion capacities of 1/2/3/4 slots, while Belt Item Level limits the strongest supported potion level. Current potion labels are compressed in parallel from Level 10/20 to Level 5/10 so existing Belt compatibility, healing values, and prices remain unchanged. Belt tooltips expose both capacity and the current potential full-loadout healing. Serialized fixed stat fields on older visual definitions are not runtime stat sources.

Common items have no random affix, Uncommon items have one, and Rare items have two unique affixes. The live compressed ilvl 1/5/10 Green affix budgets remain 60/78/101. Rare affixes each use 85% of the matching Green budget. One seeded item-wide roll varies total modifier budget from 95% to 105%, after which the result is split equally between all affixes. Affix values use the current centralized stat-cost table from Scope 19.5, including Block at 13 and each exact elemental Resistance at 5 budget per point. Jewelry rolls only Fire/Cold/Lightning Resistance, Health, Dodge, Accuracy, Critical Chance, or Critical Damage; generated equipment uses secondary stats only.

`ItemInstance` now owns Item Level, rarity, inherent stats, rolled total budget, affixes, resolved item stats, tooltip text, and dynamic ItemPower. ItemPower applies the complete generated contribution to the approved fixed reference profile and uses the shared `PowerCalculator`. `Equipment` and `StatResolver` consume the generated instance values for Health, Armor, Dodge, Accuracy, Damage, Attack Speed, Critical stats, Resistances, and Block.

Every generated candidate is now evaluated through `EquipmentEvaluator` before routing. Standard equipment compares the hero's full base persistent HeroPower with the current loadout against a copied loadout containing the candidate and equips only on a strict HeroPower increase. Ring candidates are evaluated against both `ring_1` and `ring_2`; the target slot is whichever replacement produces the higher final HeroPower, so an authored Ring 1 item may correctly replace a weaker Ring 2 item and vice versa. Belt is the explicit utility exception: it first compares total potential healing from a fully loaded Belt using the strongest supported current potion tier, then uses the Belt's inherent Health as the tie-breaker. Temporary divine effects are excluded, displayed ItemPower is not used as the final decision rule, and evaluation does not mutate live equipment.

Current equipment reference prices are centralized for compressed ilvl 1/5/10. White uses the unchanged 100/500/1000 Gold, Green uses ×3, and the currently approved Rare reference uses ×9; sale value is 10% of reference price. Current ilvl 1 White/Green/Rare generated items sell for 10/30/90 Gold, compressed ilvl 5 equivalents sell for 50/150/450 Gold, and compressed ilvl 10 equivalents sell for 100/300/900 Gold. The three authored starting pieces use a definition-level reference-value override of 10 Gold and therefore sell for exactly 1 Gold without changing ordinary ilvl 1 prices. Successful quest turn-in enters `VISITING_MARKET`. On the following dedicated world tick, every unequipped ordinary equipment item in Inventory is sold, removed, and converted into Gold, then the hero enters `SHOPPING`; healing-potion stacks are separate persistent Inventory state and are not part of this automatic sale. Each later shopping world tick can buy at most one equipment item. Standard equipment must be affordable, meet the current +20% ItemPower threshold against the equipped comparison item, and improve the hero through real virtual-equip HeroPower evaluation; Belt purchases instead use the approved Belt-utility comparison. If a known dungeon already passes its Power readiness gate, the Gold needed to complete the current full Belt potion loadout is protected from optional equipment spending, and a Belt upgrade is itself rejected when buying it would leave too little Gold to fill all slots of the newly equipped Belt. Purchased stock positions remain empty until refresh; replaced equipped gear is sold immediately for its normal resale value instead of entering Inventory. When equipment shopping finishes, a known local dungeon must pass both the first-attempt/retry Power rule and full-Belt potion preparation before travel starts. If the complete loadout requires any new potion purchase, the hero enters `PREPARING_DUNGEON` and spends exactly one separate world tick buying all missing potions; dungeon travel begins only after that tick. A complete loadout already owned in Inventory can be prepared without inventing an extra purchase tick. Dungeon discovery still never interrupts an activity already in progress. Death and other events do not trigger sale. Item tooltips show both reference shop value and sell price.

The Starting City shop uses three authored stock-band resources with shared compressed ilvl 1/5/10 mechanics. Each band samples six distinct White slots and two distinct Green slots, for 24 rotating equipment listings when fully stocked. The ilvl 1 candidate pool has seven Rustchain armor/weapon/shield slots; the ilvl 5 pool has seven Ironwake core slots plus necklace, earrings, both rings, and Belt; the ilvl 10 pool likewise has seven Ironward core slots plus its own necklace, earrings, both rings, and Belt. The same shop definition also exposes fixed healing-potion availability outside the rotating equipment stock: compressed Level 5 restores 100 HP for 100 Gold and Level 10 restores 150 HP for 200 Gold; both live potion definitions reference their supplied 550 × 550 inventory sprites. Concrete equipment stats, affix budgets, rarity behavior, ItemPower, and prices still come from shared item-generation/economy data. Green listings use the normal generated-affix pipeline. The shop uses a deterministic RNG stream derived from the simulation seed so equipment rotation remains reproducible without perturbing the existing main simulation RNG sequence. Full equipment-stock refresh occurs at world ticks 200, 400, 600, and so on regardless of where the hero is. Before each shopping decision tick, the developer debug log prints one compact equipment-assortment summary by rarity and readable slot name without dumping item stats.

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
- reaching hero level 5 learns Power Strike at Skill Level 1; when its 10-second cooldown is ready and at least 30 Rage is available, it automatically replaces the next normal attack opportunity, spends 30 Rage, cannot miss, can still crit, and uses the Scope-approved `1.50 + 2.0 × WisdomFactor` damage multiplier;
- Power Strike actions carry their own structured action id and are named separately in the combat log;
- reaching hero level 10 learns Battle Guard at Skill Level 1; after an incoming hit first leaves the hero at 75% MaxHP or lower, it activates without retroactively reducing that threshold-crossing hit, lasts 10 seconds, has a 60-second cooldown, costs no Rage, requires no shield, and multiplies subsequent already-mitigated incoming damage by `1 - (0.25 + 0.15 × WisdomFactor)`;
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

Concrete mob values and immutable quest templates live in `data/mobs/` and `data/quests/` and are intentionally treated as tuning data rather than duplicated here. The current Starting City mob roster follows one gradually widening Power curve with targets `30, 35, 43, 52, 61, 70, 80, 90 / 100, 120, 142, 166, 192, 220, 250 / 275, 325, 380, 440, 505, 575, 650`; individual combat identities use Health, Damage, Armor, Accuracy, Dodge, Critical Chance/Critical Damage and restrained Attack Speed rather than scaling only Health and Damage. The current quest balance pass also keeps `Банда у каменного моста` at its reduced reward band and uses varied enemy-count rolls on stronger quests. A quest template contains inclusive mob-count and gold-per-mob ranges plus authored map-placement rules: `placement_distance_hex_min/max`, optional allowed terrain ids, optional allowed semantic tags, and forbidden semantic tags. All twenty-two current Starting City templates have a 1–7-hex placement band, one terrain-or-tag placement constraint, and `city` forbidden. The old `distance_km_min/max` fields remain only as a temporary compatibility path for fixed legacy tests/offers that do not receive map targets; live autonomous quest selection and travel no longer use that abstract distance as their spatial authority. Templates do not store rolled values, a total Gold reward, concrete target hexes, or equipment rewards. Current ordinary quests reward Gold only.

The developer build loads all twenty-two `.tres` Starting City quest templates from `res://data/quests` into `QuestPool`. Their explicit 8 / 7 / 7 strength-band membership follows the approved mob-Power curve: eight are lower strength, seven middle, and seven higher. For current playtesting the normal maximum of three current offers per band is temporarily disabled: every currently eligible template in each band is turned into a runtime offer, so a fresh board may expose all twenty-two templates before active-quest and completion-cooldown exclusions. Each runtime `QuestOffer` owns its rolled mob count, compatibility-only legacy abstract distance, gold per mob, concrete `target_hex`, and `map_distance_steps` equal to the actual shortest route length from the Starting City center. A separate deterministic placement RNG stream plus `ActivityPlacementFinder` chooses a valid free target inside Starting Region for each current board offer and reserves that hex through `WorldState`. `QuestEvaluator` evaluates only the currently available board offers and uses `map_distance_steps` for live travel-cost estimation whenever a real target exists.

The Starting City quest board now has one global 50-world-tick refresh cycle. At ticks 50 / 100 / 150 / ... every still-available board offer is discarded and all currently eligible templates are instantiated again; the usual 3-per-band cap is temporarily bypassed for development testing. Taking a quest removes it from the available board immediately and leaves that vacancy empty until the next shared refresh. The active quest remains independent of the board and keeps its map target while it is being performed. Completing a quest puts its template on a 50-world-tick cooldown counted from completion; after the cooldown expires it becomes eligible for a later global board roll, but is not inserted immediately. Cooldowns remain strict.

An accepted offer's existing map target remains reserved and visible while the hero walks the real route to it and performs the quest even though that offer is no longer part of the available board. `TravelSystem` advances `WorldState.hero_position` by exactly one adjacent route hex per completed world tick. After the final objective is completed and the hero starts the real route back to the Starting City center, the old target reservation is released and its map marker disappears. Fatal cancellation releases the target immediately and returns the dead hero's map position to the city for the resurrection timer. Neither success nor cancellation performs an individual slot refresh; only the shared board cycle creates replacement offers.

At every `CHOOSING_QUEST` decision point:

1. `QuestEvaluator` applies the personality-adjusted Hard Filter Power window:
   - standard: `55% <= MobPower / HeroPower <= 95%`;
   - Brave: `60% <= MobPower / HeroPower <= 100%`;
   - current legacy Coward trait as temporary Cautious: `50% <= MobPower / HeroPower <= 90%`;
2. only quests inside both the lower and upper bounds participate further;
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
→ if a local dungeon passes first-attempt/retry readiness but needs potion purchases: one PREPARING_DUNGEON purchase tick
→ TRAVEL_TO_DUNGEON → AT_DUNGEON_ENTRANCE
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

The UI keeps the debug log pinned to the newest entry without rewriting identical text on every world tick. Real text changes are pushed toward the bottom immediately and corrected again after TextEdit wrapping/layout completes, preventing the visible top-to-bottom jump while still keeping the newest wrapped entry on screen.

## UI

Current layout:
- a persistent top menu with Hero, Inventory, Map, and Menu buttons;
- hero panel on the left;
- god-energy panel and three ability buttons above the center log/diary;
- log/diary in the center;
- opponent panel on the right;
- developer speed controls in the bottom-right corner.

`MainUI` now coordinates the main developer view, a lightweight Hero development screen, dedicated `InventoryScreen` / `MapScreen`, `GodPanel`, and `NarrativePanel`. The Hero screen displays the live pending primary-attribute pool and five `+1` allocation controls; those buttons send commands through `Simulation` and never mutate attributes directly. Allocation controls are disabled during an active combat session so the already-created `CombatSession` cannot diverge from newly resolved hero stats mid-fight. The same Hero screen also shows four decorative personality-axis previews (`Осторожный ↔ Смелый`, `Хитрый ↔ Благородный`, `Жадный ↔ Щедрый`, `Консервативный ↔ Любопытный`) on the intended −100…0…+100 scale. While these previews are neutral they show only the ±40 visible-trait activation thresholds; the future ±20 return-to-neutral thresholds are intentionally not shown until real trait state exists. The previews are currently fixed at neutral `0` and are presentation-only; hidden personality runtime values and trait development are not implemented yet.

The Map button opens a dedicated `MapScreen`. `data/map/prototype_02_map.tres` owns the 26 × 15 gameplay source geometry and references the editable `assets/map/prototype_02_hex_layout.png`. `HexMapImageDecoder` samples the technical center of all 390 logical flat-top hexes, rejects unknown center colors with coordinates, derives both compact seven-hex city clusters, identifies the unique bright-red hero-start center, and reconstructs the one unbranched road between the cities. Runtime `HexMap` converts every logical cell into a `HexDefinition` containing its own coordinates, decoded terrain, `region_id`, and permanent semantic tags; the technical `hero_start` marker becomes normal `starting_city` terrain in the game-level hex data. Current tag vocabulary is deliberately small: `city` marks all city cells, `city_center` marks only the two authored centers, and `road` follows the authored ordered road path rather than relying on the temporary road-as-terrain encoding. Starting Region and Mid Region each extend up to seven adjacent-hex steps from their city center. Cells inside both radii belong to the nearer center; the current equal-distance boundary is split by the midpoint between city-center X coordinates, producing 150 hexes per city region and 90 peripheral no-region hexes. `Simulation` owns this `HexMap`, mutable `WorldState`, and `TravelSystem`; the hero begins at the Starting City center, and `HexMap` provides deterministic adjacent-hex routes, step distance, and the fixed 3 km-per-hex world distance. When a map-backed quest is selected, `TravelSystem` follows that route one adjacent hex per world tick to the offer target and later one hex per tick back to the city center; `MapScreen` continuously follows the resulting live `WorldState.hero_position`. `MapTileVisuals` supplies three real `158 × 140` PNG variants for each normal biome from `res://assets/map/biomes/` plus the authored `418 × 440` `town1.png`; variant selection is deterministic from hex coordinates, city cells use plains art underneath, and `MapScreen` draws both biome tiles and the town overlay 1:1 at base zoom. Both city clusters use the same town overlay, centered on the city-center hex and aligned by the overlay's bottom edge to the bottom edge of the full seven-hex cluster; internal city-hex outlines are omitted so the town art remains visually continuous. Road cells temporarily reuse plains biome art underneath the existing road line. The map hero visual uses the permanent `res://assets/map/characters/hero_map.png` source. The source remains high-resolution and `MapScreen` scales it only for display to 120 px tall at base zoom, centered horizontally on the current live hero hex and shifted 5 px upward for visual placement. Every currently placed quest-board offer is also drawn at its real `target_hex` using the supplied `res://assets/map/activities/quest.png` 426 × 400 RGBA sprite, scaled only at draw time to 65 px tall (about 69.2 × 65 px) and centered on the target hex. Hovering that quest sprite shows the concrete offer's player-facing quest name; outside the sprite, ordinary hex hover continues to show coordinates, terrain, region, and permanent tags. The hero's currently selected `active_quest` receives a brighter three-layer orange outline (`#FF8C00`) around that same sprite, following the visual principle of the existing item-rarity outline; other quest markers remain unchanged. Completed/cancelled offers disappear when their reservation is released, and replacement offers appear at their new placement. The old fixed terrain legend has been removed because the rendered map now uses authored biome/city sprites rather than matching those schematic legend swatches. `MapScreen` remains pointer-interactive for inspection only and does not change simulation state. Mouse-wheel input zooms the map between 0.6× and 2.0× around the cursor, while holding the right mouse button and dragging pans the map; the map transform applies to hexes, roads, quest sprites, hero marker, and city labels, while the screen UI and tooltip remain fixed. Panning is clamped so the map cannot be dragged completely off-screen. The shared top menu and red close button remain available, and opening the map changes only UI visibility while the existing Simulation continues running.

Active temporary events are now visible on `MapScreen` as a translucent dark-blue tint across their real runtime footprint. A normal radius-1 event shades seven hexes; quest, dungeon, and hero markers remain above the tint, and the area disappears automatically when the event instance is removed.

The Inventory button opens the dedicated `InventoryScreen` scene owned by `scripts/ui/screens/inventory_screen.gd`; `MainUI` retains only screen navigation and passes the existing `Simulation` into it. The main developer content is hidden while the shared top menu remains visible; the Inventory button becomes Back, and a separate red close button provides the same return action. The screen displays the hero over a dark `256 × 464` portrait panel. Chest, Pants, and Boots begin occupied by the supplied aligned starting-clothes art, while Helmet and Gloves remain empty. Five armor slots remain in a column on the left. Main-hand and off-hand slots sit below the portrait, with the sword on the left and shield on the right. The right equipment column is accessory-only in this order: necklace, earrings, ring, ring, belt. Immediately to the right of that jewelry column, Inventory now shows a separate vertical `Зелья` column. Every physical healing potion is represented by its own `82 × 82` visual slot rather than by an `×N` stack; the column keeps at least four visible placeholders and scrolls vertically if more owned bottles need to be shown. Potion slots use the same supplied sprites, now labeled as compressed Level 5 / 10, and individual potion hover tooltips. The underlying Inventory model still stores persistent potion counts separately from the 36 retained-equipment FIFO, so this presentation does not reduce equipment capacity. All twelve equipment slots are functional for generated/equipped items and show ItemInstance-rarity quality outlines plus shared hover tooltips; necklace, earrings, both rings, and Belt use supplied unchanged icons and intentionally have no hero paper-doll overlays. Belt tooltips expose potion-slot capacity, maximum supported potion level, and potential healing; a dedicated visual distinction of which displayed bottles are specifically prepared into Belt slots is still not implemented. All five armor pieces retain their aligned `441 × 800` paper-doll overlays. Standard equipment replacements use strict real HeroPower improvement, while Belt replacement uses potential potion healing first and inherent Belt Health on a tie. Adding equipment item 37 drops the oldest retained equipment item. Manual equipping, dragging, selling, and set bonuses are not implemented. This UI-only screen switch does not pause or replace `Simulation`, so world time and autonomous gameplay continue normally.

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
- fight-local Rage, the compressed level-5 Power Strike unlock, autonomous replacement of the next attack, cooldown/cost, guaranteed hit, critical hits, WIS scaling, blocked/avoided incoming-hit Rage rules, cap/reset, and distinct combat narration;
- the compressed level-10 Battle Guard unlock, post-threshold activation order, 10-second duration, 60-second cooldown, no Rage cost, post-defense mitigation, WIS scaling, locked-state behavior, and distinct activation narration;
- quest combat/XP/recovery;
- death and quest cancellation;
- exact 100-tick natural resurrection;
- resurrection at 1 HP;
- city recovery to full HP;
- retention of earlier XP/levels and no Gold for a failed quest;
- generic validity/progression checks for the current Goblin, Wolf, and Bear tuning cards;
- offer replacement without assuming a fixed tavern pool size;
- god ability integration, including the `+0.20` one-selection quest guidance modifier;
- current Starting City compressed ilvl 1 Rustchain / ilvl 5 Ironwake-core-plus-accessory / ilvl 10 Ironward shop bands, unique slots per band and rarity, reuse of shared item generation data, deterministic 200-tick refresh, persistent purchased vacancies, separate sale/shopping ticks, +20% purchase threshold, maximum real HeroPower-gain selection, and immediate resale of replaced equipment.
- Belt/potion integration: 1/2/3/4 Belt capacities, Level-based potion eligibility, compressed Level 5/10 potion prices/healing/sprites, individual one-bottle-per-slot Inventory presentation with tooltips, Belt-specific replacement ordering, complete affordable loadout preparation, Gold reservation including Belt-upgrade capacity changes, one dedicated purchase tick when missing potions must be bought, multi-potion ordinary/pre-boss healing, and mandatory full-Belt dungeon readiness.
- the live 8/7/7 ordinary-mob mapping across Rustchain ilvl 1, Ironwake-plus-accessories compressed ilvl 5, and Ironward core compressed ilvl 10 while the first dungeon remains on compressed ilvl 5.
- the fixed three-piece starting armor set, its resolved +3 total Armor, paper-doll/icon presentation, ordinary upgrade routing, and 1-Gold resale.

UI note: during active combat, the hero panel displays live CombatSession HP rather than only the last committed HeroState HP.
