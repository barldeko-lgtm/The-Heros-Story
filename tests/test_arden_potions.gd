extends SceneTree

func _init() -> void:
	var shop = load("res://data/shops/arden_shop.tres")
	var definitions: Array = shop.healing_potion_definitions
	assert(definitions.size() == 5)
	var simulation = load("res://scripts/core/simulation.gd").new(9108, null)
	assert(simulation.shop_system.get_healing_potion_definitions().size() == 2)
	var rules = load("res://scripts/items/belt_potion_rules.gd").new()
	var belt = simulation.item_generator.generate(load("res://data/items/visual_families/azure_dawnplate/azure_dawn_belt.tres"), 15, RandomNumberGenerator.new())
	for index in definitions.size():
		var potion = definitions[index]
		var level: int = (index + 1) * 5
		assert(potion.potion_level == level)
		assert(potion.id == "healing_potion_ilvl%d" % level)
		assert(potion.healing_amount == 100.0 + index * 50.0)
		assert(potion.shop_price == (index + 1) * 100)
		assert(potion.icon_texture != null)
		assert(potion.icon_texture.resource_path == "res://assets/items/icons/consumables/healing_potion_ilvl%d.png" % level)
		if level < 15:
			continue
		assert(potion.icon_texture.get_size() == Vector2(300, 300))
		belt.item_level = level
		simulation.hero_state.equipment.replace_item(belt)
		simulation.hero_state.gold = potion.shop_price
		assert(rules.get_best_supported_potion(belt).potion_level == level)
		var preparation: Dictionary = simulation.potion_preparation_system.prepare_full_loadout(simulation.hero_state, definitions)
		assert(preparation.can_prepare)
		assert(simulation.hero_state.gold == 0)
		assert(simulation.hero_state.prepared_healing_potion_levels == [level])
		simulation.hero_state.current_hp = 100.0
		var use: Dictionary = simulation.potion_preparation_system.use_between_fight_potions(simulation.hero_state, 1000.0, false, definitions)
		assert(use.consumed_count == 1)
		assert(use.actual_healing == potion.healing_amount)
		assert(simulation.hero_state.inventory.get_total_healing_potion_count() == 0)
	print("PASS: Arden potion levels, icons, prices, belt restrictions, purchases and healing; Dornwald unchanged.")
	quit()
