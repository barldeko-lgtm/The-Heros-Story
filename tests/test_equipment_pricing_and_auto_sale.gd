extends SceneTree

const PRICE_CALCULATOR_PATH := "res://scripts/economy/item_price_calculator.gd"
const COMMON_CHEST_PATH := "res://data/items/visual_families/ironwake_sentinel/ironwake_sentinel_chestplate.tres"
const UNCOMMON_HELMET_PATH := "res://data/items/visual_families/ironwake_sentinel/ironwake_sentinel_helmet_uncommon.tres"
const RARE_SWORD_PATH := "res://data/items/visual_families/ironwake_sentinel/ironwake_sentinel_sword_rare.tres"

class ScriptedRng:
	extends RefCounted

	var float_values: Array = []
	var int_values: Array = []

	func _init(initial_float_values: Array = [], initial_int_values: Array = []) -> void:
		float_values = initial_float_values.duplicate()
		int_values = initial_int_values.duplicate()

	func randf() -> float:
		return float(float_values.pop_front())

	func randi_range(_from: int, _to: int) -> int:
		return int(int_values.pop_front())

func _init() -> void:
	var price_calculator_script: Script = load(PRICE_CALCULATOR_PATH)
	if price_calculator_script == null:
		push_error("The central item price calculator must exist.")
		quit(1)
		return
	var price_calculator = price_calculator_script.new()
	assert(price_calculator.get_reference_shop_value(5, 0) == 500, "Compressed ilvl 5 White reference shop value must preserve 500 Gold.")
	assert(price_calculator.get_reference_shop_value(5, 1) == 1500, "Compressed ilvl 5 Green reference shop value must preserve 1500 Gold.")
	assert(price_calculator.get_reference_shop_value(5, 2) == 4500, "Compressed ilvl 5 Rare reference shop value must preserve 4500 Gold.")
	assert(price_calculator.get_sell_price_for_level_and_rarity(5, 0) == 50, "Compressed ilvl 5 White sell value must preserve 50 Gold.")
	assert(price_calculator.get_sell_price_for_level_and_rarity(5, 1) == 150, "Compressed ilvl 5 Green sell value must preserve 150 Gold.")
	assert(price_calculator.get_sell_price_for_level_and_rarity(5, 2) == 450, "Compressed ilvl 5 Rare sell value must preserve 450 Gold.")
	assert(price_calculator.get_reference_shop_value(15, 0) < 0, "Undefined price tiers must not silently invent a value.")

	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	var simulation = simulation_script.new(1)
	var common_item = simulation.item_generator.generate(load(COMMON_CHEST_PATH), 5, ScriptedRng.new())
	var uncommon_item = simulation.item_generator.generate(load(UNCOMMON_HELMET_PATH), 5, ScriptedRng.new([0.5], [0]))
	var rare_item = simulation.item_generator.generate(load(RARE_SWORD_PATH), 5, ScriptedRng.new([0.5], [0, 0]))
	assert(common_item != null and uncommon_item != null and rare_item != null, "All sale-test items must generate.")
	assert(rare_item.get_tooltip_text().contains("Цена продажи: 450"), "Generated tooltip must show the current sell price.")

	simulation.hero_state.inventory.add_item(common_item)
	simulation.hero_state.inventory.add_item(uncommon_item)
	simulation.hero_state.inventory.add_item(rare_item)
	simulation.hero_state.gold = 7

	simulation.hero_state.loop_state = "DEAD_RESPAWNING"
	var death_sale: Dictionary = simulation.advance_market_sale_tick(1)
	assert(death_sale["sold_count"] == 0 and simulation.hero_state.inventory.get_items().size() == 3, "Death must not trigger safe-city equipment sale.")
	assert(simulation.hero_state.gold == 7, "A non-sale event must not change Gold.")

	simulation.hero_state.loop_state = "VISITING_MARKET"
	var sale_result: Dictionary = simulation.advance_market_sale_tick(2)
	assert(sale_result["sold_count"] == 3, "The dedicated market tick must sell every current unequipped ordinary item.")
	assert(sale_result["gold_gained"] == 650, "White + Green + Rare compressed ilvl 5 resale must preserve 50 + 150 + 450 Gold.")
	assert(simulation.hero_state.gold == 657, "Sale Gold must be added to the hero's existing balance.")
	assert(simulation.hero_state.inventory.get_items().is_empty(), "Sold equipment must leave Inventory.")
	assert(simulation.debug_log.get_text().contains("продано предметов: 3") and simulation.debug_log.get_text().contains("+650 золота"), "Automatic sale must write one concise market summary to the debug log.")

	print("PASS: Central ilvl/rarity prices drive 10% resale and safe quest turn-in automatically sells Inventory equipment.")
	quit()
