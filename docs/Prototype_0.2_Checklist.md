# The Hero’s Story — Prototype 0.2 Checklist

Last verified against the current repository, `current-state.md`, and the Prototype 0.2 Scope: **2026-09-11**.

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
- 🟡 Progression mechanics work and the current XP curve is tuned to 500 XP at Level 1, early +500/+600/+700 steps, +800 requirement growth through Level 13, then +1000 per level; full compressed level 1–30 balance/soak validation is still incomplete.
- ✅ Four-question starting background assigns exactly three attribute points and mild hidden personality biases through selected answers.
- ⬜ Post-specialization attribute growth/reward rules.
- ⬜ Long-run Prototype 0.2 balance/soak validation.

## 2. Combat and Warrior abilities

- ✅ Live one-on-one automatic combat with Accuracy/Dodge, Armor, elemental Resistances, Block, Critical Chance/Damage and Attack Speed.
- ✅ Fight-local Rage generation/cap/reset.
- ✅ Level 5 Power Strike is learned at Skill Level 1; combat scaling supports Skill Levels 1–10 from ×1.50 to ×2.50 plus separate WIS scaling with the current 2.5 coefficient.
- ✅ Level 10 Battle Guard is learned at Skill Level 1; combat scaling supports Skill Levels 1–10 from 25% to 45% base reduction plus separate WIS scaling with the current 0.30 coefficient and an 80% MaxHP activation threshold.
- ✅ Per-mob XP, post-fight recovery, mid-quest level-up and stat refresh.
- ✅ Death, failed activity handling, 100-tick natural resurrection and city recovery.
- ✅ Fire/Cold/Lightning ordinary attacks are live in Arden; elemental hits keep Accuracy/Dodge/Crit/Block, ignore Armor, use direct-percentage matching Resistance (75% cap), and receive the current ×1.20 elemental-offense weight inside shared Power. The Warrior now also has an innate 10% Fire / Cold / Lightning Resistance baseline before equipment.
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
- 🟡 City-local runtime/context switching now exists for Дорнвальд and Арден ordinary quests; the full per-city economy/dungeon/event context is still incomplete.
- 🟡 Autonomous relocation from Starting City to Mid-Level City is live with the temporary Level-13 trigger and real map travel; richer long-term-goal logic is deferred.
- 🟡 Арден has local ordinary quests and its own equipment shop/economy after arrival; local events and Mid Region dungeons are still missing.

## 5. Ordinary quests and quest board

- ✅ 22 / 22 Starting City ordinary quest templates with real map-placement constraints and concrete runtime targets.
- ✅ Starting City strength-band split: 8 lower / 7 middle / 7 higher.
- ✅ Arden ordinary-mob roster is authored as 26 distinct `0101`–`0126` definitions on the approved non-linear 300→900 Power curve, with matching local ordinary quests.
- ✅ Autonomous `Hard Filter → QuestScore → best valid quest` selection.
- ✅ Real travel to quest target, combat/recovery loop, real return travel, turn-in and Gold reward.
- ✅ Shared 50-world-tick full-board refresh and strict 50-world-tick completed-template cooldown.
- ✅ Current quest-board working tuning is live at up to 12 offers per city: Дорнвальд uses 4/4/4 across three bands, while Арден uses 3/3/3/3 across four loot-aligned bands; deterministic rerolls still occur every 50 ticks and vacancies remain until the next shared refresh.
- ✅ 26 Mid-Level City / Arden ordinary quest templates (`0101`–`0126`), split 5 transition / 4 lower / 8 middle / 9 higher with 3–7-hex Mid Region placement and band boundaries aligned to ilvl 10/15/20/25 mob drops.
- ✅ City-local ordinary quest pools across both cities; physical arrival in Arden switches board content/placement and QuestRunner return/death routing to the Mid Region city center.
- 🟡 Prototype 0.2 currently uses the simpler fixed Level-13 relocation trigger instead of active-offer exhaustion; the richer progression/goal rule is deferred.

## 6. Temporary events

- ✅ Generic event system, map placement/reservations, population lifecycle, authored stages, shared combat, rewards, personality effects and travel detours are live.
- ✅ Current Starting Region events: **15** — `У старой вырубки`, `Дым над старой башней`, `Чужие силки`, `Мёртвый гонец`, `Огр у старого кургана`, `Костёр без хозяина`, `Волки на пастбище`, `Чужая шкатулка`, `Беглый наёмник`, `Раненый разведчик`, `Камни старого старателя`, `Зверь в сломанной клетке`, `Спор у межевого камня`, `Лекарство до заката`, `Сигнал из старого карьера`.
- ✅ Current population pacing supports the tick-100 opening, shared rotations, up to five simultaneous events and per-definition engagement cooldowns.
- ✅ Events can suspend/resume an ordinary quest route or either leg of an ordinary-dungeon trip, and can use their own real travel objective.
- 🟡 Current event framework is functional and the Starting Region now has a complete first-city batch of 15 authored events, but Mid Region event content and the final two-region distribution remain incomplete.
- 🟡 The current total is **15 handcrafted events**, all in the Starting Region; Mid Region event content and the final two-region distribution are still missing.

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
- ✅ Source-driven ordinary mob drops and autonomous equip/inventory routing across both cities: Arden keeps five ilvl 10 transition mobs, then uses Azure Dawnplate ilvl 15 / Crimson Thornplate ilvl 20 / Gilded Wyrm ilvl 25 by strength band at the normal 5% drop chance and 70/25/5 rarity split.
- 🟡 Inventory is a functional first pass: 36 retained equipment items plus separate persistent potion counts/visual bottle slots.
- ✅ Ordinary quest equipment `QuestLoot` flow is live: mob drops wait until objective completion, all found equipment is reviewed in one dedicated tick, unreviewed equipment is lost on quest death, and reviewed items become normal permanent Equipment/Inventory before the return trip.
- ⬜ General trophy/backpack carried-loot handling beyond ordinary equipment.
- ⬜ Full legal two-handed / hand-configuration content and evaluation.
- 🟡 Six visual armor families now exist across the two-city progression; later Arden families still lack some weapon/shield/accessory and overlay breadth, so the full equipment-content target is not complete.

## 9. Economy, shops, Belt and healing potions

- ✅ Quest/dungeon/event Gold can feed the current economy; unwanted ordinary equipment can be sold automatically in the city flow.
- ✅ Starting City equipment shop has all three current ilvl 1 / 5 / 10 bands, 24 rotating equipment listings and deterministic stock refresh.
- ✅ Autonomous equipment purchase evaluation and protected Gold for required dungeon preparation.
- ✅ Belt is a real utility slot with rarity-based 1 / 2 / 3 / 4 potion capacity and Item-Level potion eligibility.
- ✅ Starting City Level 5 / 10 healing potions, persistent inventory, full-Belt preparation and dungeon-only consumption are live.
- ✅ Missing dungeon potions are bought in the current dedicated preparation tick; already-owned complete loadouts do not invent an extra purchase tick.
- ✅ Mid-Level City equipment shop bands at ilvl 15/20/25 are live with the currently supplied slots.
- ✅ Arden adds Level 15/20/25 potions: 200/250/300 HP for 300/400/500 Gold, retaining Level 5/10 options.
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
- 🟡 Diary episode grouping is still missing; current Diary/Log history is preserved by save/load.
- ⬜ Player-facing Explanatory Log and its UI.

## 12. UI

- 🟡 Current developer-oriented Main UI is functional but is not the finished Prototype 0.2 player-facing interface.
- ✅ Hero development view includes live stats/personality and player primary-attribute allocation.
- 🟡 Inventory Screen is a strong functional first pass with paper doll, all 12 equipment slots, retained gear and potion display.
- 🟡 Map Screen is functional but still needs final route/destination and hidden-information presentation.
- 🟡 God panel and Log/Diary presentation are functional; ordinary quest-guidance UI is still missing.
- 🟡 Debug questionnaire is live on one screen; the following class screen shows Warrior plus three visibly locked future classes. Separate question pages and non-Warrior class implementations remain deferred.
- ⬜ Finished player-facing Hero/Main/Diary presentation.
- ⬜ Player-facing Explanatory Log UI.
- 🟡 Functional startup and running-game menus exist; final Menu Screen presentation remains incomplete.

## 13. First Warrior specialization

- ⬜ Autonomous Protector / Slayer preference from player-shaped attributes plus independent Brave/Cautious influence.
- ⬜ One-time divine specialization guidance and specialization decision window.
- ⬜ Specialization Quest and dedicated Protector/Slayer specialization dungeon content.
- ⬜ Specialization granting, immediate/profile progression rewards and later specialization-directed attribute growth.
- ⬜ Protector/Slayer abilities and their later Skill Level progression.

## 14. Save / load / persistence

- ✅ Two independent rolling slots are live: Manual and Autosave; Continue selects the newest valid candidate and Load exposes both slots.
- ✅ Autosave is live after new-game creation, approximately every 10 real minutes, on normal close, and after an increased completed-dungeon count.
- 🟡 Major dungeon-completion autosave is live; specialization autosave remains pending because specialization itself is not implemented.
- ✅ The current simulation snapshot preserves the required live graph including progression/personality, equipment/inventory, world/activity state, dungeon/event state, God state, Diary/Log history and deterministic RNG continuation.
- 🟡 Save/Load/Return controls are live in the current running-game menu; final Menu Screen presentation is still incomplete.
- 🚫 Offline simulation while the game is closed.

## 15. Prototype 0.2 content targets at a glance

| Content | Current | Prototype 0.2 target |
|---|---:|---:|
| Normal cities | 2 on map / 1 complete + Arden ordinary-quest context | 2 complete |
| Ordinary quest templates | 48 (22 + 26) | 48 current approved target (22 + 26) |
| Handcrafted temporary events | 15 | ~15–20 across both regions |
| Ordinary dungeons | 2 | 4 |
| First specialization paths | 0 | 2 |
| Specialization dungeon variants | 0 | 2 |
| Base Warrior abilities | 2 + purchasable Skill Levels 2–10 | 2 + purchasable ranks |
| First-specialization abilities | 0 | 2 |
| Personality axes | 4 live | 4 |
| Visual armor families | 6 | at least 5–6 |
| Item rarity | White / Green / Blue + dungeon Purple | White / Green / Blue / Purple |
| Main playable progression | Starting City + Arden ordinary-quest slice live | compressed level ~1–30 |

The current ordinary quest-board tuning is up to 12 offers per city: 4/4/4 in Дорнвальд and 3/3/3/3 in Арден. These values are deliberately still treated as balance tuning and may be adjusted after transition testing.

## 16. Major remaining Prototype 0.2 blocks

This is a progress-oriented list, not automatic permission or a fixed implementation order:

1. Continue expanding the already broad early-game Hero Diary coverage with the remaining progression sources and more phrase variation.
2. Replace the debug all-in-one questionnaire layout with separate question pages when needed and later implement the currently locked non-Warrior classes outside the present Warrior slice.
3. Complete the Mid-Level City gameplay context behind the now-live Level-13 relocation/arrival and Arden ordinary-quest foundation, especially local events and dungeons.
4. Add Mid Region temporary-event content and decide the final two-region distribution within/around the current ~15–20 prototype target as that city is implemented.
5. Add the two Mid Region ordinary dungeons plus later equipment/potion progression content.
6. Implement the first Protector / Slayer specialization flow, specialization dungeons and specialization abilities.
7. Complete the remaining generalized trophy/backpack side of QuestLoot, remaining equipment/hand-configuration breadth, player-facing Explanatory Log and final UI screens.
8. Extend persistence only for still-missing future systems such as specialization, then run long-duration Prototype 0.2 validation through the intended compressed level range.
