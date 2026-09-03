class_name ShopSystem
extends RefCounted

const ItemPriceCalculatorScript = preload("res://scripts/economy/item_price_calculator.gd")

var shop_definition: Resource
var item_generator
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var listings: Array = []
var last_refresh_tick: int = 0
var item_price_calculator = ItemPriceCalculatorScript.new()

func _init(initial_shop_definition: Resource, initial_item_generator, initial_seed: int) -> void:
	shop_definition = initial_shop_definition
	item_generator = initial_item_generator
	rng.seed = initial_seed
	refresh_stock(0)

func get_listings() -> Array:
	return listings

func get_healing_potion_definitions() -> Array:
	if shop_definition == null:
		return []
	return shop_definition.healing_potion_definitions.duplicate()

func advance_world_tick(completed_tick: int) -> bool:
	if shop_definition == null or shop_definition.refresh_interval_ticks <= 0:
		return false
	if completed_tick > 0 and completed_tick != last_refresh_tick and completed_tick % shop_definition.refresh_interval_ticks == 0:
		refresh_stock(completed_tick)
		return true
	return false

func refresh_stock(completed_tick: int) -> void:
	listings.clear()
	last_refresh_tick = completed_tick
	if shop_definition == null or item_generator == null or rng == null:
		return
	for stock_band in shop_definition.stock_bands:
		if stock_band == null:
			continue
		append_unique_listings(stock_band.item_level, get_definitions_for_rarity(stock_band, 0), stock_band.white_listings)
		append_unique_listings(stock_band.item_level, get_definitions_for_rarity(stock_band, 1), stock_band.uncommon_listings)

func get_definitions_for_rarity(stock_band: Resource, rarity: int) -> Array:
	var result: Array = []
	for item_definition in stock_band.item_definitions:
		if item_definition != null and int(item_definition.quality) == rarity:
			result.append(item_definition)
	return result

func append_unique_listings(item_level: int, definitions: Array, count: int) -> void:
	var available: Array = definitions.duplicate()
	var picks: int = mini(count, available.size())
	for _pick_index in picks:
		var definition_index: int = rng.randi_range(0, available.size() - 1)
		var item_definition = available.pop_at(definition_index)
		for remaining_index in range(available.size() - 1, -1, -1):
			if available[remaining_index].equipment_slot == item_definition.equipment_slot:
				available.remove_at(remaining_index)
		var item_instance = item_generator.generate(item_definition, item_level, rng)
		if item_instance == null:
			continue
		listings.append({"item_instance": item_instance})

func purchase_listing(hero_state, listing_index: int, target_slot: String = "") -> Dictionary:
	var result: Dictionary = {
		"purchased": false,
		"item_instance": null,
		"price_paid": 0,
		"replaced_item": null,
		"replaced_item_sale_value": 0,
		"target_slot": "",
	}
	if hero_state == null or listing_index < 0 or listing_index >= listings.size():
		return result
	var listing: Dictionary = listings[listing_index]
	var item_instance = listing.get("item_instance")
	if item_instance == null or item_instance.definition == null:
		return result
	var price: int = item_price_calculator.get_reference_shop_value_for_item(item_instance)
	if price < 0 or hero_state.gold < price:
		return result

	hero_state.gold -= price
	var resolved_target_slot: String = item_instance.definition.equipment_slot if target_slot.is_empty() else target_slot
	var replaced_item = hero_state.equipment.replace_item(item_instance, resolved_target_slot)
	var resale_value: int = 0
	if replaced_item != null:
		resale_value = item_price_calculator.get_sell_price_for_item(replaced_item)
		if resale_value > 0:
			hero_state.gold += resale_value
	listing["item_instance"] = null
	listings[listing_index] = listing

	result["purchased"] = true
	result["item_instance"] = item_instance
	result["price_paid"] = price
	result["replaced_item"] = replaced_item
	result["replaced_item_sale_value"] = maxi(0, resale_value)
	result["target_slot"] = resolved_target_slot
	return result
