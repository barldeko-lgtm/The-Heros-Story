extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const SimulationSnapshot = preload("res://scripts/core/simulation_snapshot.gd")
const PriceCalculatorScript = preload("res://scripts/economy/item_price_calculator.gd")

func _init() -> void:
	test_approved_price_progression()
	test_physical_arden_arrival_switches_shop_and_allows_equipment_purchase()
	print("PASS: Approved equipment prices and physical Arden arrival activate the city-local equipment shop.")
	quit()

func test_approved_price_progression() -> void:
	var calculator = PriceCalculatorScript.new()
	var expected := {
		10: [900, 2700],
		15: [1350, 4050],
		20: [2300, 6900],
		25: [3600, 10800],
	}
	for item_level in expected:
		assert(calculator.get_reference_shop_value(item_level, 0) == expected[item_level][0], "White ilvl %d price must match the approved value." % item_level)
		assert(calculator.get_reference_shop_value(item_level, 1) == expected[item_level][1], "Green ilvl %d price must remain exactly three times the White value." % item_level)

func test_physical_arden_arrival_switches_shop_and_allows_equipment_purchase() -> void:
	var simulation = SimulationScript.new(9631, null)
	assert(simulation.shop_system.shop_definition.city_id == HeroState.STARTING_CITY_ID, "A new hero must still begin with Dornwald's separate shop.")
	simulation.hero_state.level = 13
	assert(simulation.try_start_mid_city_relocation(1), "The level-13 fixture must begin normal physical relocation to Arden.")
	var guard: int = 0
	while simulation.hero_state.loop_state == HeroState.TRAVEL_TO_CITY and guard < 100:
		simulation.advance_time(10.0)
		guard += 1
	assert(guard < 100 and simulation.hero_state.current_city_id == HeroState.MID_CITY_ID, "The fixture must physically arrive in Arden.")
	assert(simulation.shop_system.shop_definition.city_id == HeroState.MID_CITY_ID, "Physical arrival in Arden must switch the active shop definition from Dornwald to Arden.")

	var counts := {
		15: {0: 0, 1: 0},
		20: {0: 0, 1: 0},
		25: {0: 0, 1: 0},
	}
	for listing in simulation.shop_system.get_listings():
		var item_instance = listing.get("item_instance")
		assert(item_instance != null and counts.has(item_instance.item_level), "Arden shop must contain only real ilvl 15/20/25 equipment listings.")
		counts[item_instance.item_level][item_instance.rarity] += 1
	assert(counts[15][0] == 6 and counts[15][1] == 2, "Arden ilvl 15 band must expose 6 White and 2 Green listings.")
	assert(counts[20][0] == 5 and counts[20][1] == 2, "Arden ilvl 20 band must expose all 5 White armor slots and 2 Green listings.")
	assert(counts[25][0] == 5 and counts[25][1] == 2, "Arden ilvl 25 band must expose all 5 White armor slots and 2 Green listings.")

	simulation.hero_state.gold = 100000
	simulation.hero_state.loop_state = HeroState.SHOPPING
	var result: Dictionary = simulation.advance_shop_purchase_tick(simulation.world_clock.world_tick + 1)
	assert(bool(result.get("purchased", false)) and result.get("item_instance") != null, "A funded Arden shopping tick must evaluate and buy a meaningful equipment upgrade, not stop after skill training.")
	assert(int(result.item_instance.item_level) in [15, 20, 25], "The purchased Arden item must come from its local shop stock.")

	var captured: Dictionary = SimulationSnapshot.capture(simulation)
	assert(str(captured.get("error", "")).is_empty(), "An Arden shop state must remain serializable through the normal snapshot graph.")
	var restored_result: Dictionary = SimulationSnapshot.restore(captured)
	assert(str(restored_result.get("error", "")).is_empty(), "An Arden shop snapshot must restore without falling back to constructor defaults.")
	var restored = restored_result.get("simulation")
	assert(restored != null and restored.hero_state.current_city_id == HeroState.MID_CITY_ID, "Snapshot restore must preserve Arden as the authoritative current city.")
	assert(restored.shop_system.shop_definition.resource_path == simulation.shop_system.shop_definition.resource_path, "Snapshot restore must preserve Arden's shop definition instead of reverting to Dornwald.")
	assert(shop_stock_signature(restored.shop_system.get_listings()) == shop_stock_signature(simulation.shop_system.get_listings()), "Snapshot restore must preserve Arden's purchased vacancy and remaining generated stock exactly.")
	assert(restored.shop_system.rng.state == simulation.shop_system.rng.state, "Snapshot restore must preserve Arden's deterministic future refresh stream.")

func shop_stock_signature(listings: Array) -> Array[String]:
	var result: Array[String] = []
	for listing in listings:
		var item = listing.get("item_instance")
		if item == null:
			result.append("empty")
		else:
			result.append("%d:%d:%s:%s" % [item.item_level, item.rarity, item.definition.resource_path, item.definition.equipment_slot])
	return result
