class_name DungeonPreparationBudget
extends RefCounted

# Read-only economic policy. Simulation supplies dungeon readiness;
# PotionPreparationSystem remains the owner of loadout calculation.
func get_optional_spending_gold_budget(gold: int, preparation_plan: Dictionary) -> int:
	if preparation_plan.is_empty() or not bool(preparation_plan.get("can_prepare", false)):
		return gold
	return maxi(0, gold - int(preparation_plan.get("purchase_cost", 0)))

func get_equipment_gold_budget(gold: int, preparation_plan: Dictionary) -> int:
	return get_optional_spending_gold_budget(gold, preparation_plan)

func filter_equipment_listings(hero_state, shop_system, potion_preparation_system, has_power_ready_dungeon: bool) -> Array:
	var listings: Array = shop_system.get_listings().duplicate(true)
	if not has_power_ready_dungeon:
		return listings
	var potion_definitions: Array = shop_system.get_healing_potion_definitions()
	for listing_index in listings.size():
		var listing: Dictionary = listings[listing_index]
		var item_instance = listing.get("item_instance")
		if item_instance == null or item_instance.definition == null or item_instance.definition.equipment_slot != "belt":
			continue
		var price: int = shop_system.item_price_calculator.get_reference_shop_value_for_item(item_instance)
		if price < 0 or price > hero_state.gold:
			continue
		var remaining_gold: int = hero_state.gold - price
		var candidate_plan: Dictionary = potion_preparation_system.get_full_loadout_plan(
			hero_state,
			potion_definitions,
			item_instance,
			remaining_gold
		)
		if bool(candidate_plan.get("can_prepare", false)):
			continue
		listings[listing_index] = {"item_instance": null}
	return listings
