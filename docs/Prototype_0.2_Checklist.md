# The Hero’s Story — Prototype 0.2 Checklist

Last verified against the current repository, `current-state.md`, and the Prototype 0.2 Scope: **2026-09-08**.

This is a **player/development progress map**, not a design or architecture document. It is intentionally concise and does not track every tuning change, test, file, or implementation detail.

If it conflicts with the Scope, `current-state.md`, or current repository code, use the newer source of truth and update this checklist.

Status:
- ✅ implemented and usable in the current build;
- 🟡 partially implemented / current build differs from the final Prototype 0.2 target;
- ⬜ not implemented yet;
- 🚫 explicitly outside Prototype 0.2.

---

## 1. Simulation and hero foundation

- ✅ One autonomous Warrior hero; the player does not directly control movement, quest choice, combat, equipment choice, shopping, or dungeon attempts.
- ✅ World ticks, pause, accelerated developer speeds, seeded gameplay RNG and reproducible derived RNG streams.
- ✅ Shared Hero/Mob `PowerCalculator` and centralized stat-resolution path.
- ✅ STR / DEX / INT / CON / WIS, XP, levels, excess-XP carryover and pending player-distributed primary-attribute points.
- ✅ Before specialization, each level grants +1 fixed Warrior STR and +4 player-distributed primary-attribute points; unspent points remain pending and provide no benefit until spent.
- ✅ Player-facing allocation of pending primary-attribute points works without directly commanding hero behaviour.
- 🟡 Progression mechanics work, but full compressed level 1–30 content/balance is incomplete.
- ✅ Four-question starting background assigns exactly three attribute points and mild hidden personality biases through selected answers.
- ⬜ Post-specialization attribute growth/reward rules.
- ⬜ Long-run Prototype 0.2 balance/soak validation.

## 2. Combat and Warrior abilities

- ✅ Live one-on-one automatic combat with Accuracy/Dodge, Armor, elemental Resistances, Block, Critical Chance/Damage and Attack Speed.
- ✅ Fight-local Rage generation/cap/reset.
- ✅ Level 5 Power Strike is learned at Skill Level 1; combat scaling supports Skill Levels 1–10 from ×1.50 to ×2.50 plus separate WIS scaling.
- ✅ Level 10 Battle Guard is learned at Skill Level 1; combat scaling supports Skill Levels 1–10 from 25% to 45% base reduction plus separate WIS scaling.
- ✅ Per-mob XP, post-fight recovery, mid-quest level-up and stat refresh.
- ✅ Death, failed activity handling, 100-tick natural resurrection and city recovery.
- 🟡 Elemental mitigation exists, but current ordinary content is still effectively physical.
- ✅ Autonomous purchase of unlocked Skill Levels 2–10 is live after market sale, one purchased rank per shopping tick with the approved price curve.
- ⬜ Protector ability: Shield Bash.
- ⬜ Slayer ability: Crippling Blows.

## 3. Personality and autonomous behaviour

- ✅ Final four Prototype 0.2 axes: Brave ↔ Cautious, Noble ↔ Devious, Greedy ↔ Generous, Curious ↔ Conservative.
- ✅ Hidden values use −100…+100 with ±40 trait activation and ±20 return-to-neutral hysteresis.
- ✅ Personality and player-guided primary-attribute development are separate; traits do not distribute the player's level-up points.
- ✅ Formative / Expressive / Neutral decision roles exist in the event framework.
- ✅ Current authored events use real Formative movement and Expressive checks without self-reinforcing the same trait; current live content exercises Courage, Morality and Curiosity movement plus Brave, Greedy, Curious, Noble and Devious expression.
- ✅ Ordinary quest selection uses the current personality-adjusted Power windows.
- ✅ Normal new games begin with questionnaire-driven biases and no established starting traits.
- 🟡 Seeded starting traits remain only in direct legacy/headless constructors without background answers, preserving fixture compatibility.

## 4. World map, cities and travel

- ✅ Authored 26 × 15 hex map with two seven-hex city clusters, one road, regions and semantic tags.
- ✅ Real hero map position, shared activity reservations and placement filtering.
- ✅ Real route movement: 1 traversed hex = 1 world tick; 1 hex = 3 km.
- ✅ Map Screen shows terrain, both city clusters, road, hero, current quest targets, dungeon markers, temporary-event footprints, zoom and panning.
- ✅ Travel interruption/resumption works for ordinary quest travel plus outbound and completed-return ordinary-dungeon travel, including event-owned detours.
- 🟡 Map Screen is functional, but current-route/destination presentation and final hidden-information presentation remain incomplete.
- ⬜ Full city runtime/context system.
- ⬜ Autonomous relocation from Starting City to Mid-Level City.
- ⬜ Mid-Level City as a complete gameplay/economy/quest context.

## 5. Ordinary quests and quest board

- ✅ 22 / 22 Starting City ordinary quest templates with real map-placement constraints and concrete runtime targets.
- ✅ Starting City strength-band split: 8 lower / 7 middle / 7 higher.
- ✅ Autonomous `Hard Filter → QuestScore → best valid quest` selection.
- ✅ Real travel to quest target, combat/recovery loop, real return travel, turn-in and Gold reward.
- ✅ Shared 50-world-tick full-board refresh and strict 50-world-tick completed-template cooldown.
- ✅ Current quest-board working tuning is live at up to 12 offers / 4 per strength band, with deterministic rerolls every 50 ticks and vacancies left until the next shared refresh.
- ⬜ 15 Mid-Level City ordinary quest templates.
- ⬜ City-local quest pools across both cities.
- ⬜ "Hero outgrew this city" relocation trigger from the current active opportunities.

## 6. Temporary events

- ✅ Generic event system, map placement/reservations, population lifecycle, authored stages, shared combat, rewards, personality effects and travel detours are live.
- ✅ Current Starting Region events: **15** — `У старой вырубки`, `Дым над старой башней`, `Чужие силки`, `Мёртвый гонец`, `Огр у старого кургана`, `Костёр без хозяина`, `Волки на пастбище`, `Чужая шкатулка`, `Беглый наёмник`, `Раненый разведчик`, `Камни старого старателя`, `Зверь в сломанной клетке`, `Спор у межевого камня`, `Лекарство до заката`, `Сигнал из старого карьера`.
- ✅ Current population pacing supports the tick-100 opening, shared rotations, up to five simultaneous events and per-definition engagement cooldowns.
- ✅ Events can suspend/resume an ordinary quest route or either leg of an ordinary-dungeon trip, and can use their own real travel objective.
- 🟡 Current event framework is functional and the Starting Region now has a complete first-city batch of 15 authored events, but Mid Region event content and the final two-region distribution remain incomplete.
- ⬜ Approximately **15–20 handcrafted events total** across both regions.

## 7. Ordinary dungeons

- ✅ Dungeon definition/instance/system/runner/evaluator foundation with real map placement and discovery.
- ✅ Starting Region ordinary dungeons: **2 / 2** — `Заброшенные железные шахты` and `Городище Черноклыков`.
- ✅ Full current dungeon loop: discovery → city decision → preparation → real travel → sequential shared combat → carried HP → potion use → boss → success/death → reward/retry/return.
- ✅ Dungeon attempts require a complete legal Belt potion loadout.
- ✅ Failure memory and current progress-based retry Power gates work.
- ✅ Dungeon completion uses the normal item pipeline and supports Rare/Epic rewards.
- ✅ Divine Vision can reveal one existing unknown dungeon in the current region.
- ⬜ Mid Region ordinary dungeons: **0 / 2**.

## 8. Items, equipment, loot and inventory

- ✅ All 12 equipment slots are mechanically functional and visible.
- ✅ Item Level, rarity, inherent stats, random affixes, ItemPower and shared virtual-equip HeroPower evaluation.
- ✅ White / Green / Blue(Rare) ordinary generation; Purple/Epic exists through dungeon rewards.
- ✅ Ring candidates evaluate both ring positions; Belt uses its separate potion-utility comparison.
- ✅ Current Starting City equipment progression is live at compressed ilvl 1 / 5 / 10.
- ✅ Three current visual families: Rustchain Initiate, Ironwake Sentinel, Ironward Vanguard, including five armor paper-doll overlays.
- ✅ Source-driven ordinary mob drops and autonomous equip/inventory routing.
- 🟡 Inventory is a functional first pass: 36 retained equipment items plus separate persistent potion counts/visual bottle slots.
- ✅ Ordinary quest equipment `QuestLoot` flow is live: mob drops wait until objective completion, all found equipment is reviewed in one dedicated tick, unreviewed equipment is lost on quest death, and reviewed items become normal permanent Equipment/Inventory before the return trip.
- ⬜ General trophy/backpack carried-loot handling beyond ordinary equipment.
- ⬜ Full legal two-handed / hand-configuration content and evaluation.
- ⬜ Remaining 2–3+ visual armor families and later equipment tiers required for the full 0.2 content target.

## 9. Economy, shops, Belt and healing potions

- ✅ Quest/dungeon/event Gold can feed the current economy; unwanted ordinary equipment can be sold automatically in the city flow.
- ✅ Starting City equipment shop has all three current ilvl 1 / 5 / 10 bands, 24 rotating equipment listings and deterministic stock refresh.
- ✅ Autonomous equipment purchase evaluation and protected Gold for required dungeon preparation.
- ✅ Belt is a real utility slot with rarity-based 1 / 2 / 3 / 4 potion capacity and Item-Level potion eligibility.
- ✅ Starting City Level 5 / 10 healing potions, persistent inventory, full-Belt preparation and dungeon-only consumption are live.
- ✅ Missing dungeon potions are bought in the current dedicated preparation tick; already-owned complete loadouts do not invent an extra purchase tick.
- ⬜ Mid-Level City shop bands and later potion tiers.
- ✅ Skill Level purchasing/training uses protected optional-spending Gold and adds no extra tick when no rank can be bought.
- ✅ Curious ↔ Conservative spending priority: Curious/neutral prefer Skill Levels first, Conservative prefers meaningful equipment first, and both may fall through to the other category.

## 10. God influence

- ✅ Divine Energy and passive recovery.
- ✅ Divine Healing.
- ✅ Temporary Combat Empowerment.
- ✅ Instant Resurrection.
- ✅ Divine Vision for one unknown dungeon in the current region.
- 🟡 Ordinary quest guidance works in simulation, but its player-facing quest-selection UI is missing.
- ⬜ First-specialization divine guidance.

## 11. Narrative, logs and Hero Diary

- ✅ Structured quest/death facts and separate developer narration.
- ✅ Developer Debug Log with bounded recent history and automatic newest-entry scrolling.
- 🟡 Hero Diary is now a real live system for ordinary quest activity, combat death/resurrection, significant equipment, dungeon milestones and successful temporary-event outcomes; entries include their real world tick.
- ✅ Diary keeps only the newest **100 meaningful entries**; ordinary quest acceptance is temporary and is removed when that quest is successfully completed or cancelled, so completed quests do not occupy two permanent Diary records.
- 🟡 Ordinary quest Diary wording already lives in external narrative data with variant arrays and per-quest override support, but only one phrase per category is currently authored.
- 🟡 Diary UI updates live and stays scrolled to the newest entry.
- ⬜ Remaining required Diary sources include levels, visible trait changes, specialization, remaining divine/progression milestones and other important progression moments.
- ⬜ Diary episode grouping and persistent history/save integration.
- ⬜ Player-facing Explanatory Log and its UI.

## 12. UI

- 🟡 Current developer-oriented Main UI is functional but is not the finished Prototype 0.2 player-facing interface.
- ✅ Hero development view includes live stats/personality and player primary-attribute allocation.
- 🟡 Inventory Screen is a strong functional first pass with paper doll, all 12 equipment slots, retained gear and potion display.
- 🟡 Map Screen is functional but still needs final route/destination and hidden-information presentation.
- 🟡 God panel and Log/Diary presentation are functional; ordinary quest-guidance UI is still missing.
- 🟡 Debug questionnaire is live on one screen, followed by an empty class-selection screen with Next; separate question pages and actual class choices remain deferred.
- ⬜ Finished player-facing Hero/Main/Diary presentation.
- ⬜ Player-facing Explanatory Log UI.
- ⬜ Menu Screen.

## 13. First Warrior specialization

- ⬜ Autonomous Protector / Slayer preference from player-shaped attributes plus independent Brave/Cautious influence.
- ⬜ One-time divine specialization guidance and specialization decision window.
- ⬜ Specialization Quest and dedicated Protector/Slayer specialization dungeon content.
- ⬜ Specialization granting, immediate/profile progression rewards and later specialization-directed attribute growth.
- ⬜ Protector/Slayer abilities and their later Skill Level progression.

## 14. Save / load / persistence

- ⬜ One rolling main save with periodic autosave and save on normal exit.
- ⬜ Major milestone saves for dungeon completion and specialization.
- ⬜ Full required simulation-state serialization, including hero progression/personality, equipment/inventory, world/activity state, dungeon memory, God state, Diary and reproducible RNG continuation.
- ⬜ Save/load status through the Menu Screen.
- 🚫 Offline simulation while the game is closed.

## 15. Prototype 0.2 content targets at a glance

| Content | Current | Prototype 0.2 target |
|---|---:|---:|
| Normal cities | 2 on map / 1 complete | 2 complete |
| Ordinary quest templates | 22 | 37 current target (22 + 15) |
| Handcrafted temporary events | 15 | ~15–20 across both regions |
| Ordinary dungeons | 2 | 4 |
| First specialization paths | 0 | 2 |
| Specialization dungeon variants | 0 | 2 |
| Base Warrior abilities | 2 at Skill Level 1 | 2 + purchasable ranks |
| First-specialization abilities | 0 | 2 |
| Personality axes | 4 live | 4 |
| Visual armor families | 3 | at least 5–6 |
| Item rarity | White / Green / Blue + dungeon Purple | White / Green / Blue / Purple |
| Main playable progression | early-game systems live | compressed level ~1–30 |

The current ordinary quest-board tuning is up to 12 offers / 4 per strength band. This 4/4/4 value is deliberately still treated as balance tuning and may be adjusted after first-to-second-city transition testing.

## 16. Major remaining Prototype 0.2 blocks

This is a progress-oriented list, not automatic permission or a fixed implementation order:

1. Continue expanding the already broad early-game Hero Diary coverage with the remaining progression sources and more phrase variation.
2. Replace the debug all-in-one questionnaire layout with separate question pages when needed; actual class-selection content is still absent.
3. Make the Mid-Level City a real gameplay context, add its ordinary quests/shop content, and implement autonomous relocation.
4. Add Mid Region temporary-event content and decide the final two-region distribution within/around the current ~15–20 prototype target as that city is implemented.
5. Add the two Mid Region ordinary dungeons plus later equipment/potion progression content.
6. Implement the first Protector / Slayer specialization flow, specialization dungeons and specialization abilities.
7. Complete the remaining generalized trophy/backpack side of QuestLoot, remaining equipment/hand-configuration breadth, player-facing Explanatory Log and final UI screens.
8. Add Save/Load and run long-duration Prototype 0.2 validation through the intended compressed level range.
