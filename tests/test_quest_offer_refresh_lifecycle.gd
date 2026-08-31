extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")

func _init() -> void:
	var simulation = SimulationScript.new(8080, null)
	simulation.hero_state.hero_name = "Алексей"

	var initial_offers: Array = simulation.quest_pool.get_available_quests()
	assert(not initial_offers.is_empty(), "The tavern must start with at least one current quest offer.")

	simulation.advance_time(10.0)
	var accepted_offer = simulation.hero_state.active_quest
	assert(accepted_offer != null, "Autonomous selection must accept one current tavern offer.")
	var accepted_index := initial_offers.find(accepted_offer)
	assert(accepted_index >= 0, "The accepted quest must be one of the offers currently in the tavern.")
	assert(accepted_offer.has_map_target(), "Accepting a quest must keep its existing board target visible on the map while it is being performed.")
	var accepted_target: Vector2i = accepted_offer.target_hex
	var accepted_activity_id: String = accepted_offer.map_activity_id
	assert(simulation.world_state.get_activity_id_at_hex(accepted_target) == accepted_activity_id, "Accepted quest target must remain reserved during quest execution.")
	assert(simulation.world_state.hero_position == simulation.hex_map.definition.starting_city_center, "Old abstract quest travel must not move the map hero yet.")

	var untouched_offers: Array = initial_offers.duplicate()
	simulation.set_time_scale(100.0)
	var guard := 0
	while simulation.hero_state.loop_state != HeroState.RETURNING_TO_CITY and guard < 2000:
		simulation.advance_time(0.01)
		guard += 1
	assert(guard < 2000, "The selected safe quest must finish its objective during the test.")
	assert(not accepted_offer.has_map_target(), "Finishing the quest objective must remove its marker before the old abstract return trip starts.")
	assert(simulation.world_state.get_activity_id_at_hex(accepted_target) != accepted_activity_id, "Finishing the quest objective must free its target hex before turn-in.")

	while simulation.hero_state.gold == 0 and guard < 4000:
		simulation.advance_time(0.01)
		guard += 1
	assert(guard < 4000, "The selected safe quest must be turned in during the test.")
	var refreshed_offers: Array = simulation.quest_pool.get_available_quests()

	assert(refreshed_offers.size() == initial_offers.size(), "Replacing one accepted offer must not change the tavern pool size.")
	assert(refreshed_offers[accepted_index] != accepted_offer, "Turning in an accepted quest must replace only that tavern slot with a new offer.")
	var replacement_offer = refreshed_offers[accepted_index]
	assert(not accepted_offer.has_map_target(), "The completed QuestOffer must remain absent from the map after turn-in.")
	assert(simulation.world_state.get_activity_id_at_hex(accepted_target) != accepted_activity_id, "The completed quest's old map reservation must remain released after turn-in.")
	assert(replacement_offer.has_map_target(), "The replacement board offer must immediately receive a new reserved map target.")
	assert(replacement_offer.map_activity_id != accepted_activity_id, "The replacement board offer must own a fresh map activity reservation.")
	assert(simulation.world_state.get_activity_id_at_hex(replacement_offer.target_hex) == replacement_offer.map_activity_id, "The replacement quest marker must correspond to its own live reservation.")
	assert(simulation.world_state.hero_position == simulation.hex_map.definition.starting_city_center, "Completing the old abstract quest loop must still leave the map hero in Starting City.")
	for index in refreshed_offers.size():
		if index != accepted_index:
			assert(refreshed_offers[index] == untouched_offers[index], "Unaccepted tavern offers must stay unchanged after another quest is turned in.")

	print("PASS: Turning in a quest refreshes only its tavern offer without assuming a fixed pool size.")
	quit()
