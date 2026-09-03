extends SceneTree

const COMMON_CHEST_PATH := "res://data/items/visual_families/ironwake_sentinel/ironwake_sentinel_chestplate.tres"

class EmptyRng:
	extends RefCounted

	func randf() -> float:
		return 0.5

	func randi_range(from: int, _to: int) -> int:
		return from

func _init() -> void:
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	var simulation = simulation_script.new(1)
	var common_item = simulation.item_generator.generate(load(COMMON_CHEST_PATH), 10, EmptyRng.new())
	assert(common_item != null, "The market-tick test item must generate.")
	simulation.hero_state.inventory.add_item(common_item)

	simulation.hero_state.loop_state = "TURNING_IN_QUEST"
	var turn_in_event = simulation.quest_runner.advance(simulation.hero_state, simulation.combat_stats)
	if simulation.hero_state.loop_state != "VISITING_MARKET":
		push_error("Quest turn-in must schedule a separate market visit instead of returning directly to quest choice.")
		quit(1)
		return
	assert(turn_in_event != null and turn_in_event.event_type == "HERO_TURNED_IN_QUEST", "Quest turn-in must still report its normal structured event.")
	var gold_after_quest_reward: int = simulation.hero_state.gold
	assert(simulation.hero_state.inventory.get_items().size() == 1, "Equipment must remain unsold during the quest-turn-in tick.")

	var full_shop_before_sale: int = count_filled_shop_listings(simulation.shop_system.get_listings())
	simulation.on_world_tick_completed(10)
	assert(simulation.hero_state.loop_state == "SHOPPING", "The dedicated sale tick must transition to shopping instead of buying on the same tick.")
	assert(simulation.hero_state.inventory.get_items().is_empty(), "The dedicated market tick must sell current unequipped ordinary equipment.")
	assert(simulation.hero_state.gold == gold_after_quest_reward + 50, "The market tick must add the ilvl 10 White resale value after quest Gold.")
	assert(count_filled_shop_listings(simulation.shop_system.get_listings()) == full_shop_before_sale, "Selling and buying must not happen on the same world tick.")
	assert(simulation.debug_log.get_text().contains("Рынок") and simulation.debug_log.get_text().contains("+50 золота"), "The dedicated market tick must write a clear sale summary.")

	print("PASS: Quest turn-in schedules a dedicated sale tick before the separate shopping phase.")
	quit()

func count_filled_shop_listings(listings: Array) -> int:
	var count: int = 0
	for listing in listings:
		if listing.get("item_instance") != null:
			count += 1
	return count
