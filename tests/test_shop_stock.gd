extends SceneTree

func _init() -> void:
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	var simulation = simulation_script.new(17)
	var shop = simulation.shop_system
	var listings: Array = shop.get_listings()

	assert(listings.size() == 16, "Starting City shop must contain two bands: 8 ilvl 1 Ironwake + 8 ilvl 10 Ironward listings.")
	assert_shop_band(listings, 1, "ironwake_sentinel")
	assert_shop_band(listings, 10, "ironward_vanguard")

	simulation.hero_state.gold = 100000
	var purchased = shop.purchase_listing(simulation.hero_state, 0)
	assert(purchased["purchased"], "A funded direct shop transaction must purchase the selected listing.")
	assert(shop.get_listings()[0]["item_instance"] == null, "Purchased listing must remain empty until normal stock refresh.")
	assert(not shop.advance_world_tick(199), "Shop stock must not refresh before tick 200.")
	assert(shop.get_listings()[0]["item_instance"] == null, "A purchased vacancy must persist before the refresh tick.")
	assert(shop.advance_world_tick(200), "Shop stock must refresh exactly on tick 200.")
	assert(shop.get_listings().size() == 16, "Refresh must rebuild both current 8-listing bands.")
	for listing in shop.get_listings():
		assert(listing.get("item_instance") != null, "Normal refresh must refill every shop listing.")

	var same_seed_simulation = simulation_script.new(17)
	var second_same_seed_simulation = simulation_script.new(17)
	assert(stock_signature(same_seed_simulation.shop_system.get_listings()) == stock_signature(second_same_seed_simulation.shop_system.get_listings()), "Shop generation must be reproducible for the same simulation seed.")

	var refresh_log_simulation = simulation_script.new(19)
	refresh_log_simulation.hero_state.loop_state = "DOING_QUEST"
	refresh_log_simulation.on_world_tick_completed(200)
	assert(refresh_log_simulation.debug_log.get_text().contains("Магазин: ассортимент обновлён."), "A scheduled stock refresh must be visible in the developer log even when the hero is away from the shop.")

	print("PASS: Starting City shop uses separate ilvl 1 Ironwake and ilvl 10 Ironward bands with unique rarity slots and 200-tick refresh.")
	quit()

func assert_shop_band(listings: Array, item_level: int, family_path_part: String) -> void:
	for rarity in [0, 1]:
		var expected_count: int = 6 if rarity == 0 else 2
		var slots: Array[String] = []
		var matching_count := 0
		for listing in listings:
			assert(listing.size() == 1 and listing.has("item_instance"), "Shop listing must not duplicate data owned by ItemInstance and ItemDefinition.")
			var item_instance = listing.get("item_instance")
			assert(item_instance != null, "Fresh shop listings must contain real ItemInstance objects.")
			if item_instance.item_level != item_level or item_instance.rarity != rarity:
				continue
			matching_count += 1
			assert(item_instance.definition.resource_path.contains(family_path_part), "Each shop band must use its assigned visual family.")
			assert_uses_shared_generation(item_instance)
			var slot: String = item_instance.definition.equipment_slot
			assert(not slots.has(slot), "One band/rarity rotation must not contain duplicate equipment slots.")
			slots.append(slot)
		assert(matching_count == expected_count, "Each shop band must contain exactly 6 White and 2 Green listings.")

func assert_uses_shared_generation(item_instance) -> void:
	var expected_armor: float = 5.0 if item_instance.item_level == 1 else 7.0
	var expected_attack: float = 10.0 if item_instance.item_level == 1 else 13.0
	var expected_block: float = 10.0 if item_instance.item_level == 1 else 13.0
	match item_instance.definition.equipment_slot:
		"helmet", "chest", "gloves", "pants", "boots":
			assert(is_equal_approx(item_instance.get_base_stat("armor"), expected_armor), "Shop armor must use its band item level through the shared base-stat table.")
		"weapon":
			assert(is_equal_approx(item_instance.get_base_stat("attack"), expected_attack), "Shop sword must use its band item level through the shared base-stat table.")
			assert(is_equal_approx(item_instance.get_base_stat("attack_speed"), 0.10), "Shop sword must preserve the shared Attack Speed rule.")
		"shield":
			assert(is_equal_approx(item_instance.get_base_stat("block"), expected_block), "Shop shield must use its band item level through the shared base-stat table.")
	if item_instance.rarity == 0:
		assert(item_instance.affixes.is_empty(), "White shop items must use the shared zero-affix rarity rule.")
	elif item_instance.rarity == 1:
		assert(item_instance.affixes.size() == 1, "Green shop items must use the shared one-affix rarity rule.")
		assert(item_instance.rolled_total_modifier_budget > 0.0, "Green shop items must receive modifier budget through ItemGenerator.")

func stock_signature(listings: Array) -> Array[String]:
	var result: Array[String] = []
	for listing in listings:
		var item_instance = listing.get("item_instance")
		result.append("%d:%d:%s:%s:%.6f" % [
			item_instance.item_level,
			item_instance.rarity,
			item_instance.definition.resource_path,
			item_instance.definition.equipment_slot,
			item_instance.rolled_total_modifier_budget,
		])
	return result
