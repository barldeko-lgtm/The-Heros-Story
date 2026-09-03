extends SceneTree

func _init() -> void:
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	var simulation = simulation_script.new(23)
	simulation.hero_state.gold = 10000
	simulation.hero_state.loop_state = "SHOPPING"

	var best_before: Dictionary = simulation.spending_evaluator.select_best_equipment_purchase(simulation.hero_state, simulation.shop_system.get_listings())
	assert(not best_before.is_empty(), "A funded unequipped starting hero must find at least one meaningful shop upgrade.")
	var expected_item = best_before["item_instance"]
	var expected_listing_index: int = int(best_before["listing_index"])
	var expected_power_gain: float = float(best_before["power_gain"])
	var expected_price: int = int(best_before["price"])
	var gold_before: int = simulation.hero_state.gold
	var filled_before: int = count_filled_shop_listings(simulation.shop_system.get_listings())

	var purchase_result: Dictionary = simulation.advance_shop_purchase_tick(11)
	assert(purchase_result["purchased"], "Shopping tick must buy the best meaningful affordable upgrade.")
	assert(purchase_result["item_instance"] == expected_item, "Shopping must choose the candidate with the largest real HeroPower gain.")
	assert(is_equal_approx(float(purchase_result["power_gain"]), expected_power_gain), "Recorded purchase gain must match the virtual-equip comparison.")
	assert(simulation.hero_state.equipment.get_item(expected_item.definition.equipment_slot) == expected_item, "Purchased item must be equipped immediately.")
	assert(simulation.shop_system.get_listings()[expected_listing_index]["item_instance"] == null, "Purchased shop position must remain empty.")
	assert(count_filled_shop_listings(simulation.shop_system.get_listings()) == filled_before - 1, "Exactly one listing may be consumed by one shopping tick.")
	assert(simulation.hero_state.gold == gold_before - expected_price, "First purchase without replacement must spend exactly the shop price.")
	var first_purchase_log: String = simulation.debug_log.get_text()
	assert(first_purchase_log.contains("Магазин: белые —") and first_purchase_log.contains("зелёные —"), "Every shopping tick must log the compact current White/Green assortment before choosing a purchase.")
	assert(contains_known_shop_slot_name(first_purchase_log), "Shop assortment log must use readable Russian slot names.")
	assert(not first_purchase_log.contains("Сила предмета") and not first_purchase_log.contains("Бюджет модификаторов"), "Compact assortment log must not dump item stats.")
	assert(first_purchase_log.contains("купил") and first_purchase_log.contains("сила героя +"), "Purchase must write a concise debug-log entry with price and Power gain.")

	var replacement_simulation = simulation_script.new(29)
	var old_chest_definition = load("res://data/items/visual_families/rustchain_initiate/rustchain_initiate_chestplate.tres")
	var replacement_chest_definition = load("res://data/items/visual_families/ironward_vanguard/boar_chestplate.tres")
	var local_rng := RandomNumberGenerator.new()
	local_rng.seed = 99
	var old_item = replacement_simulation.item_generator.generate(old_chest_definition, 1, local_rng)
	var replacement_item = replacement_simulation.item_generator.generate(replacement_chest_definition, 20, local_rng)
	replacement_simulation.hero_state.equipment.replace_item(old_item)
	replacement_simulation.refresh_combat_stats()
	replacement_simulation.hero_state.current_hp = replacement_simulation.combat_stats.max_hp
	replacement_simulation.shop_system.listings = [{"item_instance": replacement_item}]
	var replacement_price: int = replacement_simulation.shop_system.item_price_calculator.get_reference_shop_value_for_item(replacement_item)
	var old_sell_value: int = replacement_simulation.shop_system.item_price_calculator.get_sell_price_for_item(old_item)
	replacement_simulation.hero_state.gold = replacement_price + 1000
	replacement_simulation.hero_state.loop_state = "SHOPPING"
	var gold_before_replacement: int = replacement_simulation.hero_state.gold
	var replacement_result: Dictionary = replacement_simulation.advance_shop_purchase_tick(12)
	assert(replacement_result["purchased"], "A shop item comfortably above the 20% ItemPower threshold must be purchased when it improves real HeroPower.")
	assert(replacement_result["replaced_item"] == old_item, "Replacing shop purchase must remove the previously equipped item.")
	assert(replacement_result["replaced_item_sale_value"] == old_sell_value, "Replaced item must use the normal 10% resale value.")
	assert(replacement_simulation.hero_state.gold == gold_before_replacement - replacement_price + old_sell_value, "Old equipment must be sold immediately in the same purchase transaction.")
	assert(not replacement_simulation.hero_state.inventory.get_items().has(old_item), "Immediately sold replaced gear must not enter Inventory.")
	assert(replacement_simulation.debug_log.get_text().contains("Старый предмет") and replacement_simulation.debug_log.get_text().contains("сразу продан"), "Replacement purchase log must explain the immediate sale of old equipment.")

	var equal_item = replacement_simulation.item_generator.generate(replacement_chest_definition, 20, local_rng)
	replacement_simulation.shop_system.listings = [{"item_instance": equal_item}]
	replacement_simulation.hero_state.gold = 100000
	assert(replacement_simulation.spending_evaluator.select_best_equipment_purchase(replacement_simulation.hero_state, replacement_simulation.shop_system.get_listings()).is_empty(), "A technically equal item must not pass the 20% shop-upgrade threshold.")

	print("PASS: Shopping buys one best HeroPower upgrade per tick and immediately sells replaced equipment.")
	quit()

func count_filled_shop_listings(listings: Array) -> int:
	var count: int = 0
	for listing in listings:
		if listing.get("item_instance") != null:
			count += 1
	return count

func contains_known_shop_slot_name(text: String) -> bool:
	for slot_name in ["шлем", "нагрудник", "перчатки", "штаны", "сапоги", "меч", "щит"]:
		if text.contains(slot_name):
			return true
	return false

