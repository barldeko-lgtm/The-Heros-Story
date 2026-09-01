# The Hero’s Story — Prototype 0.2 Checklist

Last verified against the current repository, `current-state.md`, tests, and the Prototype 0.2 Scope: **2026-09-01**.

This file is a short working progress map, not a design authority.

If this checklist conflicts with the current Scope, `current-state.md`, or repository code, use the newer source of truth and update this checklist.

Status:
- ✅ implemented and usable in the current build;
- 🟡 partially implemented / current prototype differs from the final 0.2 requirement;
- ⬜ not implemented yet;
- 🚫 explicitly outside Prototype 0.2.

---

## 1. Simulation foundation

- ✅ One autonomous hero; the player does not directly control movement/combat/equipment.
- ✅ World ticks and simulation time.
- ✅ Pause plus ×1 / ×2 / ×5 / ×10 / ×20 / ×100 developer speeds.
- ✅ Seeded gameplay RNG and reproducible derived RNG streams for current implemented systems.
- ✅ Shared Hero/Mob `PowerCalculator`.
- ✅ Simulation / runtime state / stat resolution / narrative / UI remain separated.
- 🟡 Regression coverage is broad, but several old fixed-quest timing tests still contain stale legacy expectations.
- ⬜ Long-run Prototype 0.2 balance/soak validation.

## 2. Hero progression and stats

- ✅ STR / DEX / INT / CON / WIS exist and start at 5.
- ✅ Current STR / DEX / CON combat contributions.
- ✅ HP, Armor, Dodge, Accuracy, Damage, Attack Speed, Crit, Crit Damage, Fire/Cold/Lightning Resistance, Block.
- ✅ Shared Armor / Resistance / Accuracy-Dodge / Block combat formulas.
- ✅ XP, levels, excess-XP carryover.
- 🟡 Current code still uses the legacy pre-specialization automatic growth of +2 STR / +1 DEX / +1 CON per level; this must be replaced by the final 0.2 rule.
- 🟡 Level progression framework works, but full 1–60 content/balance is not complete.
- ⬜ Lightweight starting questionnaire about the hero's past.
- ⬜ Questionnaire grants a small additional primary-attribute pool that the player distributes among STR / DEX / INT / CON / WIS.
- ⬜ Final pre-specialization growth: +1 STR from Warrior automatically + 4 primary-attribute points distributed directly by the player per level.
- ⬜ Unspent player-distributed primary-attribute points remain pending, provide no benefit until spent, and persist through save/load.
- ⬜ First-specialization-specific +1 primary-attribute point per later level.
- ⬜ Immediate specialization-profile attribute reward and delayed post-40 catch-up growth.

## 3. Combat and Warrior abilities

- ✅ Live one-on-one combat with independent attack timers.
- ✅ Crits, misses, Block, physical mitigation and elemental resistance formulas.
- ✅ Fight-local Rage generation/cap/reset.
- ✅ Level 10 Power Strike, autonomous use, Skill Level 1 and WIS scaling.
- ✅ Level 20 Battle Guard, autonomous use, Skill Level 1 and WIS scaling.
- ✅ Per-mob XP, post-fight recovery and level-up during a quest.
- ✅ Death, quest failure, 100-tick resurrection and city recovery.
- ⬜ Purchasable Power Strike Skill Levels 2–10.
- ⬜ Purchasable Battle Guard Skill Levels 2–10.
- ⬜ Protector ability: Shield Bash.
- ⬜ Slayer ability: Crippling Blows.

## 4. Personality and autonomous decisions

- 🟡 Current prototype rolls 1–2 starting traits from the older `Coward / Brave / Dishonorable / Noble / Greedy` set and uses them in quest/combat decisions.
- 🟡 Current QuestScore personality modifiers work, but the final Scope personality model is not yet implemented.
- ⬜ Final four Prototype 0.2 personality axes: Brave ↔ Cautious, Noble ↔ Devious, Greedy ↔ Generous, Curious ↔ Conservative.
- ⬜ Hidden continuous personality values, thresholds/hysteresis and visible-trait development.
- ⬜ Starting questionnaire applies small hidden personality shifts that remain below the visible-trait threshold by themselves.
- ⬜ Decision-point roles: Formative / Expressive / Neutral.
- ⬜ Formative decisions do not read general personality and may move hidden personality axes according to the authored meaning of the chosen action.
- ⬜ Expressive decisions may use established personality but do not move the general personality axes.
- ⬜ Neutral decisions neither need to read nor modify general personality.
- ⬜ Personality and primary-attribute development remain independent; traits do not distribute level-up stat points.
- ✅ Ordinary quest autonomous selection uses the Scope's personality-adjusted MobPower window: standard 55–95% of HeroPower, Brave 60–100%, and the current legacy Coward trait as the temporary Cautious equivalent at 50–90%.

## 5. World map and travel

- ✅ Authored 20 × 15 exact-color hex map.
- ✅ Two seven-hex city clusters exist geographically.
- ✅ One authored road between the cities.
- ✅ Plains / forest / hills plus current temporary road/city terrain handling.
- ✅ Starting Region and Mid Region ownership.
- ✅ Permanent semantic tags: `city`, `city_center`, `road`.
- ✅ Hex adjacency, radius, route and distance queries.
- ✅ 1 hex = 3 km.
- ✅ 1 traversed hex = 1 world tick.
- ✅ Activity reservation: one active activity per hex; multi-hex atomic footprints supported.
- ✅ Placement filtering by region, distance, terrain, allowed/forbidden tags and radius.
- ✅ `TravelSystem`: real route movement one adjacent hex per world tick.
- ✅ Hero sprite follows live map position.
- ✅ Quest activity sprite on real target hexes.
- ✅ Current selected quest target is marked by a brighter orange rarity-style outline.
- ✅ Map zoom and right-mouse panning.
- 🟡 Map Screen is functional but does not yet show the current travel route/destination line required by the final 0.2 UI.
- ⬜ Full city runtime/context system.
- ⬜ Autonomous relocation from Starting City to Mid-Level City.
- ⬜ Mid-Level City as a complete playable economic/quest context.
- ⬜ Travel interruption and resumption.

## 6. Ordinary quests and quest board

- ✅ `QuestDefinition` and runtime `QuestOffer` are separate.
- ✅ 15 current Starting City quest templates.
- ✅ Each current quest has authored hex-distance and terrain/tag placement constraints.
- ✅ Quest offers receive concrete unique `target_hex` positions.
- ✅ Quest target reservation/release lifecycle.
- ✅ Real travel to target and real travel back to Starting City.
- ✅ Live QuestScore travel cost uses actual route length in hexes.
- ✅ Current combat/recovery/turn-in/Gold quest loop.
- ✅ Starting City content target: **15 / 15** ordinary quest templates.
- ⬜ Mid-Level City content target: **0 / 15** ordinary quest templates.
- ⬜ Three explicit quest strength bands: 5 lower / 5 middle / 5 higher per city.
- ⬜ Final active board: maximum 6 offers per city, maximum 2 from each band.
- ⬜ 100-world-tick offer lifetime and automatic rotation.
- ⬜ 150-world-tick template cooldown after completion.
- ⬜ City-local quest pools for both cities.
- ⬜ "Hero outgrew this city" relocation trigger from the current active offers.
- 🟡 Current build exposes all 15 Starting City templates simultaneously; this is a prototype state, not the final rotating-board rule.

## 7. Temporary events

- 🟡 Generic placement/reservation foundation already supports event-style radius footprints; radius 1 = 7 reserved hexes.
- ⬜ `EventSystem` runtime lifecycle.
- ⬜ 2–4 simultaneous active temporary events.
- ⬜ Event lifetime / replacement timing.
- ⬜ Travel collision/activation with event areas.
- ⬜ Suspend original travel objective → resolve event → resume travel.
- ⬜ Conditional event options and autonomous reactions.
- ⬜ Event decision stages support Formative / Expressive / Neutral roles.
- ⬜ Formative event stages can change hidden personality according to the chosen action without reading current general personality.
- ⬜ Expressive event stages can react to established traits without reinforcing those same general traits.
- ⬜ Approximately 15–20 handcrafted events across both regions.

## 8. Dungeons

- ✅ Runtime dungeon definition/instance foundation and real map placement for the first Starting Region dungeon.
- ✅ Dungeon discovery / known-vs-unknown world knowledge for physical hex entry and Divine Vision.
- 🟡 Starting Region ordinary dungeons: **1 / 2** (`Заброшенные железные шахты`).
- ⬜ Mid Region ordinary dungeons: **0 / 2**.
- ✅ First dungeon executes its authored `3 × Шахтный троглодит → Глубинный пожиратель` sequence through the shared live combat system.
- ✅ Dungeon discovery does not interrupt the current activity; after quest turn-in → market → shopping, a known local dungeon takes priority over selecting another ordinary quest.
- ✅ Real map travel to the known dungeon entrance through `TravelSystem`.
- ✅ Dungeon combat preserves current HP between encounters, grants normal combat XP, and does not roll ordinary mob equipment drops.
- ✅ Exactly 1 world tick of between-fight preparation after each ordinary encounter, including before the boss; the current no-potion slice gives no free healing.
- ✅ Dungeon death uses the normal 100-tick resurrection / city-recovery contract and Divine instant resurrection.
- 🟡 Dungeon readiness now includes post-failure HeroPower retry gates; first-attempt/potion preparation rules are still incomplete.
- ⬜ Potion preparation before attempts.
- 🟡 Between-fight potion window exists, but Belt/potion selection and actual healing are not implemented yet.
- ✅ Failure memory and current +25% / +15% / +10% retry Power gates based on progress in the failed attempt.
- ⬜ Dungeon completion Gold + Blue/Rare or Purple/Epic equipment reward.
- ✅ Divine Vision reveal integration: 80 Energy, 1500-tick cooldown, one unknown dungeon in the current region.

## 9. First Warrior specialization

- ⬜ Protector / Slayer preference scores.
- ⬜ Player-guided primary attributes contribute to specialization preference while mandatory Warrior STR is excluded from false Slayer bias.
- ⬜ Brave / Cautious provides an independent soft specialization modifier; exact numerical strength remains a tuning value.
- ⬜ One-time divine specialization guidance.
- ⬜ Specialization decision window / lock.
- ⬜ Specialization Quest activation.
- ⬜ Protector specialization dungeon variant.
- ⬜ Slayer specialization dungeon variant.
- ⬜ Relic/objective completion and specialization granting.
- ⬜ Protector/Slayer post-specialization +1 attribute growth and immediate profile reward.

## 10. Items, equipment, loot and inventory

- ✅ Item Level framework and base-stat tables.
- ✅ White / Green / Blue(Rare) affix-count/budget generation foundation.
- 🟡 Purple/Epic budget rules exist in data/code, but Purple is not yet part of the live content/reward loop.
- ✅ ±5% rolled total modifier budget and stat-cost tables.
- ✅ Generated `ItemInstance`, affixes, inherent stats, ItemPower and tooltips.
- ✅ Shared-Power-based ItemPower calculation.
- ✅ Virtual-equip HeroPower comparison.
- ✅ Current five armor slots + sword + shield mechanically generate/equip/drop.
- ✅ Five armor paper-doll overlays work.
- 🟡 12-slot UI structure exists, but real live item content is still mostly the current seven armor/weapon/shield slots.
- ⬜ Functional jewelry items: rings, necklace, earrings with inherent Resistance rules.
- ⬜ Functional Belt item with Health + potion capacity/level rules.
- ⬜ Two-handed / full legal hand-configuration equipment content and evaluation.
- 🟡 Source-driven mob drops exist for current ilvl 1 / ilvl 10 families, but the final six city quest-band ilvl sources are incomplete.
- ⬜ `QuestLoot` temporary unsafe adventure loot.
- ⬜ Death clears unsafe QuestLoot while preserving permanent/equipped gear.
- 🟡 Backpack/inventory exists as a 36-item first pass; final inventory categories (QuestLoot, potions, quest/special items) are incomplete.

## 11. Visual equipment content

- 🟡 Visual armor families: **2 / minimum 5–6** (`Ironwake Sentinel`, `Ironward Vanguard`).
- ✅ Current families provide five visible armor overlays.
- ✅ Sword/shield icons and equipped state work for current families.
- ⬜ Remaining 3–4+ visual families required for Prototype 0.2.

## 12. Economy and shops

- ✅ Gold from current quest turn-in and sale of unwanted ordinary equipment.
- ✅ Automatic city sale tick.
- ✅ Autonomous equipment purchase evaluation.
- ✅ Current +20% ItemPower shop threshold plus real virtual-equip validation.
- ✅ Deterministic 200-world-tick shop refresh.
- ✅ Purchased shop slots remain empty until refresh.
- 🟡 Starting City shop currently has ilvl 1 + ilvl 10 bands (**2 / required 3**); ilvl 20 band is missing.
- 🟡 Current full stock is 16 equipment listings; final Starting City target is 24 (3 bands × 8).
- ⬜ Mid-Level City shop: ilvl 30 / 40 / 50 bands.
- ⬜ Healing potion purchasing/preparation.
- ⬜ Skill Level purchasing/training.
- ⬜ Curious ↔ Conservative spending priority.
- ⬜ Dungeon-preparation Gold reservation priority.

## 13. Belt and healing potions

- ⬜ Real Belt item content.
- ⬜ Belt rarity potion capacities: 1 / 2 / 3 / 4 slots.
- ⬜ Belt-level potion eligibility.
- ⬜ Potion tiers level 1 / 10 / 20 / 30 / 40 / 50.
- ⬜ Potion inventory and Belt preparation.
- ⬜ Autonomous potion purchase logic.
- ⬜ Between-dungeon-fight potion use.

## 14. God influence

- ✅ Divine Energy 0–100 and +1 per 6 world ticks.
- ✅ Divine Healing: 10 Energy, +50% MaxHP, 30-tick cooldown.
- ✅ Combat Empowerment: 10 Energy, +15% Physical Damage for 5 fights, 120-tick cooldown.
- ✅ Instant Resurrection with dynamic RemainingTicks × 0.5 Energy cost.
- 🟡 Ordinary quest guidance works in simulation, but there is no player-facing quest-guidance selection UI yet.
- ⬜ First-specialization divine guidance.
- ⬜ Vision: reveal one unknown dungeon in the current region.

## 15. Narrative and logs

- ✅ Structured quest/death facts and separate `QuestNarrator`.
- ✅ Developer Debug Log with bounded recent tick history.
- ✅ Debug log UI and automatic scrolling.
- ⬜ Player-facing Explanatory Log with structured decision reasons.
- ⬜ Hero Diary / Chronicle gameplay feed.
- ⬜ Diary grouping into meaningful episodes.
- ⬜ Persistent diary/history.
- ⬜ Narrative phrase/data layer for the full 0.2 diary.

## 16. UI

- 🟡 Main Screen exists as the current developer-oriented main UI, but it is not yet the finished 0.2 Main Screen.
- ⬜ Dedicated finished Hero Screen.
- 🟡 Inventory Screen is a strong first pass: paper doll, 12 visible slots, inventory grid and tooltips; final item categories/content remain incomplete.
- 🟡 Map Screen is functional: both cities, road, hero, quest targets, terrain inspection and camera; route display, dungeons/events/hidden-information presentation remain missing.
- ⬜ Menu Screen.
- 🟡 God controls exist for healing/blessing/resurrection; quest guidance UI is missing.
- ⬜ Player-facing primary-attribute allocation UI for pending stat points.
- ⬜ Starting questionnaire UI / flow.
- ⬜ Player-facing Diary UI with real diary content.
- ⬜ Player-facing Explanatory Log UI.

## 17. Save / load / persistence

- ⬜ One rolling main save.
- ⬜ Autosave approximately every 10 real minutes.
- ⬜ Save on normal exit.
- ⬜ Dungeon-completion milestone save.
- ⬜ Specialization milestone save.
- ⬜ Full simulation-state serialization.
- ⬜ Persist pending unspent primary-attribute points and already allocated player-guided attributes.
- ⬜ Persist questionnaire completion/state plus hidden personality values and visible traits.
- ⬜ RNG-state/reproducible continuation after load.
- ⬜ Save/load status in Menu Screen.
- 🚫 Offline simulation while the game is closed.

## 18. Prototype 0.2 content targets at a glance

- 🟡 Normal cities: **2 geographically / 1 complete gameplay context**.
- 🟡 Ordinary quest templates: **15 / 30 total target**.
- 🟡 Simultaneous quest offers: current **15 Starting City offers**, final target **up to 6 per city, 2/2/2 by band**.
- ⬜ Handcrafted temporary events: **0 / 15–20**.
- ⬜ Ordinary dungeons: **0 / 4**.
- ⬜ First specialization paths: **0 / 2 implemented**.
- ⬜ Specialization dungeon variants: **0 / 2**.
- ✅ Base Warrior abilities: **2 / 2** at Skill Level 1.
- ⬜ First-specialization abilities: **0 / 2**.
- ⬜ Final personality axes: **0 / 4**; current old trait prototype is temporary.
- 🟡 Visual armor families: **2 / minimum 5–6**.
- 🟡 Item rarity in live content: White / Green / Blue(Rare) functional; Purple/Epic not yet in the live reward loop.
- 🟡 Main progression: leveling framework exists, but final +1 Warrior STR / +4 player allocation, starting questionnaire, and complete approximately level 1–60 content/balance are not yet implemented.

## 19. Final integration / validation

- ⬜ Full autonomous loop across both cities.
- ⬜ Starting questionnaire creates only mild hidden personality bias rather than immediately assigning established traits.
- ⬜ Player-guided stat allocation affects capabilities without directly commanding hero decisions.
- ⬜ Formative decisions can create/change personality without reading the current general trait state.
- ⬜ Expressive decisions reflect established personality without automatically reinforcing it.
- ⬜ Events interrupt/resume real travel correctly.
- ⬜ Dungeons integrate travel, preparation, combat, loot, death and retry memory.
- ⬜ Specialization combines player-shaped stats, independent Brave/Cautious character influence, and optional divine guidance.
- ⬜ Specialization is reached through its full quest/dungeon flow rather than level alone.
- ⬜ Diary makes recent autonomous life understandable without reading the debug log.
- ⬜ Explanatory Log makes major decisions understandable without raw formulas.
- ⬜ Save/load reproduces the same continuing hero life.
- ⬜ Long-run simulation proves the economy, progression, quest rotation and city relocation remain stable.

---

## Suggested next large blocks

This is only a working order, not permission to implement automatically:

1. Finish the Starting City quest-board rules: 15 templates, strength bands, 6-offer 2/2/2 rotation, lifetime and cooldown.
2. Replace legacy automatic attribute growth with +1 Warrior STR + 4 player-distributed points, pending-point storage, and the lightweight starting questionnaire foundation.
3. Make the Mid-Level City a real gameplay context and implement autonomous relocation.
4. Implement temporary events and travel interruption/resumption together with Formative / Expressive / Neutral decision roles.
5. Replace the old trait prototype with the final four-axis hidden-value personality model and connect formative/expressive event behavior.
6. Implement Belt/potions, then ordinary dungeons and discovery/readiness/retry.
7. Implement first Warrior specialization using stats + Brave/Cautious + divine guidance, then the specialization dungeon flow.
8. Complete item/shop/content breadth, Diary, Explanatory Log and remaining UI screens.
9. Add Save/Load and run long-duration Prototype 0.2 validation.