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
	for item_level in shop_definition.item_levels:
		append_unique_listings(item_level, get_definitions_for_rarity(0), shop_definition.white_listings_per_band)
		append_unique_listings(item_level, get_definitions_for_rarity(1), shop_definition.uncommon_listings_per_band)

func get_definitions_for_rarity(rarity: int) -> Array:
	var result: Array = []
	for item_definition in shop_definition.item_definitions:
		if item_definition != null and int(item_definition.quality) == rarity:
			result.append(item_definition)
	return result

func append_unique_listings(item_level: int, definitions: Array, count: int) -> void:
	var available: Array = definitions.duplicate()
	var picks: int = mini(count, available.size())
	for _pick_index in picks:
		var definition_index: int = rng.randi_range(0, available.size() - 1)
		var item_definition = available.pop_at(definition_index)
		var item_instance = item_generator.generate(item_definition, item_level, rng)
		if item_instance == null:
			continue
		listings.append({"item_instance": item_instance})

func purchase_listing(hero_state, listing_index: int) -> Dictionary:
	var result: Dictionary = {
		"purchased": false,
		"item_instance": null,
		"price_paid": 0,
		"replaced_item": null,
		"replaced_item_sale_value": 0,
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
	var replaced_item = hero_state.equipment.replace_item(item_instance)
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
	return result
