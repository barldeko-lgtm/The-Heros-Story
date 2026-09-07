extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
var failures := 0

func check(value: bool, message: String) -> void:
	if not value:
		failures += 1
		printerr("FAIL: " + message)

func _init() -> void:
	for path in ["res://scripts/narrative/economy_narrator.gd", "res://scripts/narrative/item_narrator.gd"]:
		if not FileAccess.file_exists(path):
			printerr("FAIL: missing extracted narrator " + path)
			quit(1)
			return
	var economy = load("res://scripts/narrative/economy_narrator.gd").new()
	var items = load("res://scripts/narrative/item_narrator.gd").new()
	var simulation = SimulationScript.new(9104, null)
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var definition = load("res://data/items/visual_families/ironward_vanguard/ironward_belt.tres")
	var item = simulation.item_generator.generate(definition, 5, rng)
	var name: String = item.definition.display_name
	var quality: String = item.get_quality_display_name()
	check(economy.describe_stock_refreshed() == "Магазин: ассортимент обновлён.", "Stock refresh wording")
	check(economy.describe_market_sale("Герой", {"sold_count": 2, "gold_gained": 10}) == "Рынок: продано предметов: 2, получено +10 золота.", "Sale wording")
	check(economy.describe_market_sale("Герой", {"sold_count": 0, "gold_gained": 0}) == "Герой посетил рынок, но продавать было нечего.", "Empty market wording")
	check(economy.describe_no_purchase("Герой") == "Герой осмотрел магазин, но достаточно выгодных покупок не нашёл.", "No purchase wording")
	check(economy.describe_purchase_failed("Герой") == "Герой не смог завершить выбранную покупку.", "Failed purchase wording")
	check(economy.describe_stock([]) == "Магазин: белые — нет; зелёные — нет.", "Empty stock wording")
	check(economy.describe_stock([{"item_instance": item}, {"item_instance": null}]) == "Магазин: белые — пояс; зелёные — нет.", "Stock slots and vacancies")
	var slots := ["helmet", "chest", "gloves", "pants", "boots", "weapon", "shield", "necklace", "earrings", "ring_1", "ring_2", "belt", "unknown"]
	var labels := ["шлем", "нагрудник", "перчатки", "штаны", "сапоги", "меч", "щит", "ожерелье", "серьги", "кольцо 1", "кольцо 2", "пояс", "unknown"]
	for i in slots.size():
		check(simulation.get_shop_slot_debug_name(slots[i]) == labels[i], "Public slot wrapper " + slots[i])
	var result := {"item_instance": item, "price_paid": 100, "power_gain": 1.25, "replaced_item": null, "replaced_item_sale_value": 10}
	check(economy.describe_purchase("Герой", result, {}) == "Герой купил «%s» (%s, ilvl 5) за 100 золота; сила героя +1.25." % [name, quality], "Ordinary purchase wording")
	result["replaced_item"] = item
	check(economy.describe_purchase("Герой", result, {"comparison_mode": "belt_utility", "candidate_belt_healing": 200.0}) == "Герой купил «%s» (%s, ilvl 5) за 100 золота; пояс теперь поддерживает до 200 HP лечения. Старый предмет «%s» сразу продан за 10 золота." % [name, quality, name], "Belt and replacement wording")
	check(items.describe_received("Герой", item, true) == "Герой получил «%s» (%s, ilvl 5) и надел предмет." % [name, quality], "Equipped reward wording")
	check(items.describe_received("Герой", item, false) == "Герой получил «%s» (%s, ilvl 5) и убрал предмет в инвентарь." % [name, quality], "Retained reward wording")
	check(items.describe_overflow(item) == "Инвентарь переполнен: самый старый предмет «%s» (%s) выпал." % [name, quality], "Overflow wording")
	check(simulation.world_clock.world_tick == 0 and simulation.hero_state.gold == 0, "Narration does not advance time or grant Gold")
	simulation.hero_state.hero_name = "Герой"
	var diary_before: String = simulation.diary.get_text()
	simulation.hero_state.loop_state = HeroState.VISITING_MARKET
	simulation.advance_market_sale_tick(7)
	check(simulation.debug_log.entries[-1] == "Тик 7 — Герой посетил рынок, но продавать было нечего.", "Simulation records market wording at the supplied tick")
	simulation.finalize_item_reward({"item_instance": item, "equipped": false, "dropped_item": item}, 8, simulation.combat_stats.max_hp, false)
	check(simulation.debug_log.entries[-2] == "Тик 8 — Герой получил «%s» (%s, ilvl 5) и убрал предмет в инвентарь." % [name, quality], "Reward entry order and tick")
	check(simulation.debug_log.entries[-1] == "Тик 8 — Инвентарь переполнен: самый старый предмет «%s» (%s) выпал." % [name, quality], "Overflow follows reward at the same tick")
	check(simulation.diary.get_text() == diary_before, "Suppressed equipment Diary remains unchanged")
	if failures == 0:
		print("PASS: economy/item narrators preserve exact text, slot wrappers, log order/ticks and Diary suppression")
	quit(0 if failures == 0 else 1)
