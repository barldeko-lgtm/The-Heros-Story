extends SceneTree

func _init() -> void:
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	var simulation = simulation_script.new(17)
	var shop = simulation.shop_system
	var listings: Array = shop.get_listings()

	assert(listings.size() == 8, "Current Starting City shop must contain only one ilvl 10 band: 6 White + 2 Green listings.")
	for rarity in [0, 1]:
		var expected_count: int = 6 if rarity == 0 else 2
		var slots: Array[String] = []
		var matching_count: int = 0
		for listing in listings:
			assert(listing.size() == 1 and listing.has("item_instance"), "Shop listing must not duplicate ilvl/rarity/item data already owned by ItemInstance and ItemDefinition.")
			var item_instance = listing.get("item_instance")
			assert(item_instance != null, "Fresh shop listings must contain real ItemInstance objects.")
			assert(item_instance.definition.resource_path.contains("ironward_vanguard"), "Current Starting City shop must use only the existing Ironward Vanguard family.")
			assert(item_instance.item_level == 10, "Current Starting City shop must generate only ilvl 10 equipment.")
			assert_uses_shared_ilvl10_generation(item_instance)
			if item_instance.rarity != rarity:
				continue
			matching_count += 1
			var slot: String = item_instance.definition.equipment_slot
			assert(not slots.has(slot), "One rarity rotation must not contain duplicate equipment slots.")
			slots.append(slot)
		assert(matching_count == expected_count, "Current shop rotation must contain exactly 6 White and 2 Green listings.")

	simulation.hero_state.gold = 100000
	var purchased = shop.purchase_listing(simulation.hero_state, 0)
	assert(purchased["purchased"], "A funded direct shop transaction must purchase the selected listing.")
	assert(shop.get_listings()[0]["item_instance"] == null, "Purchased listing must remain empty until normal stock refresh.")
	assert(not shop.advance_world_tick(199), "Shop stock must not refresh before tick 200.")
	assert(shop.get_listings()[0]["item_instance"] == null, "A purchased vacancy must persist before the refresh tick.")
	assert(shop.advance_world_tick(200), "Shop stock must refresh exactly on tick 200.")
	assert(shop.get_listings().size() == 8, "Refresh must rebuild the current 8-listing ilvl 10 assortment.")
	for listing in shop.get_listings():
		assert(listing.get("item_instance") != null, "Normal refresh must refill every shop listing.")

	var same_seed_simulation = simulation_script.new(17)
	var second_same_seed_simulation = simulation_script.new(17)
	assert(stock_signature(same_seed_simulation.shop_system.get_listings()) == stock_signature(second_same_seed_simulation.shop_system.get_listings()), "Shop generation must be reproducible for the same simulation seed.")

	var refresh_log_simulation = simulation_script.new(19)
	refresh_log_simulation.hero_state.loop_state = "DOING_QUEST"
	refresh_log_simulation.on_world_tick_completed(200)
	assert(refresh_log_simulation.debug_log.get_text().contains("Магазин: ассортимент обновлён."), "A scheduled stock refresh must be visible in the developer log even when the hero is away from the shop.")

	print("PASS: Current shop uses one ilvl 10 Ironward Vanguard band, shared item generation, unique rarity slots, and 200-tick refresh.")
	quit()

func assert_uses_shared_ilvl10_generation(item_instance) -> void:
	match item_instance.definition.equipment_slot:
		"helmet", "chest", "gloves", "pants", "boots":
			assert(is_equal_approx(item_instance.get_base_stat("armor"), 7.0), "Shop armor must take ilvl 10 base Armor from the shared base-stat table.")
		"weapon":
			assert(is_equal_approx(item_instance.get_base_stat("attack"), 13.0), "Shop sword must take ilvl 10 Damage from the shared base-stat table.")
			assert(is_equal_approx(item_instance.get_base_stat("attack_speed"), 0.10), "Shop sword must take Attack Speed from the shared base-stat table.")
		"shield":
			assert(is_equal_approx(item_instance.get_base_stat("block"), 13.0), "Shop shield must take ilvl 10 Block from the shared base-stat table.")
	if item_instance.rarity == 0:
		assert(item_instance.affixes.is_empty(), "White shop items must use the shared zero-affix rarity rule.")
	elif item_instance.rarity == 1:
		assert(item_instance.affixes.size() == 1, "Green shop items must use the shared one-affix rarity rule.")
		assert(item_instance.rolled_total_modifier_budget > 0.0, "Green shop items must receive their modifier budget through the shared ItemGenerator.")

func stock_signature(listings: Array) -> Array[String]:
	var result: Array[String] = []
	for listing in listings:
		var item_instance = listing.get("item_instance")
		result.append("%d:%d:%s:%.6f" % [
			item_instance.item_level,
			item_instance.rarity,
			item_instance.definition.equipment_slot,
			item_instance.rolled_total_modifier_budget,
		])
	return result
