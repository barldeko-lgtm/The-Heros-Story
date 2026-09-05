extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")

func _init() -> void:
	var simulation = SimulationScript.new(9090, null)
	simulation.hero_state.hero_name = "Алексей"
	assert(start_current_quest(simulation), "Cancellation test must find one suitable current board offer before forcing a lethal fight.")
	var cancelled_offer = simulation.hero_state.active_quest
	assert(cancelled_offer != null, "Autonomous selection must accept an offer before it can be cancelled.")
	assert(not simulation.quest_pool.get_available_quests().has(cancelled_offer), "Accepted quest must leave the active board immediately instead of waiting for cancellation.")
	assert(cancelled_offer.has_map_target(), "Accepted quest must keep its map target until the quest is cancelled or completed.")
	var cancelled_target: Vector2i = cancelled_offer.target_hex
	var cancelled_activity_id: String = cancelled_offer.map_activity_id
	cancelled_offer.mob_definition.attack = 500.0
	cancelled_offer.mob_definition.crit_chance = 0.0
	simulation.set_time_scale(100.0)
	var guard := 0
	while simulation.hero_state.loop_state != HeroState.DEAD_RESPAWNING and guard < 1000:
		simulation.advance_time(0.01)
		guard += 1
	assert(guard < 1000, "The deliberately lethal accepted quest must cancel into natural resurrection.")
	assert(not simulation.quest_pool.get_available_quests().has(cancelled_offer), "Cancelled runtime offer must not be restored to the board immediately on death.")
	assert(not cancelled_offer.has_map_target(), "A cancelled quest must disappear from the map immediately on hero death.")
	assert(simulation.world_state.get_activity_id_at_hex(cancelled_target) != cancelled_activity_id, "Cancelling a quest must immediately free its target hex.")
	assert(simulation.world_state.hero_position == simulation.hex_map.definition.starting_city_center, "A hero killed at a quest location must return to the city map position for the resurrection timer.")

	# The shared board rotates independently while the hero is dead. A cancelled
	# template has no completion cooldown, so it may participate in that later roll.
	simulation.advance_time(10.5)
	assert(simulation.hero_state.loop_state == HeroState.CHOOSING_QUEST, "Natural resurrection and city recovery must return the hero to quest choice.")
	assert(simulation.quest_pool.last_board_refresh_tick >= 100, "The global quest board must keep its own 50-tick schedule even during death and recovery.")
	var current_offers: Array = simulation.quest_pool.get_available_quests()
	assert(current_offers.size() == 9, "A normal global refresh after cancellation must refill the full 3/3/3 board when all templates are eligible.")
	for current_offer in current_offers:
		assert(current_offer.has_map_target(), "Every globally rerolled offer after recovery must have a fresh map target.")
		assert(simulation.world_state.get_activity_id_at_hex(current_offer.target_hex) == current_offer.map_activity_id, "Every rerolled quest marker must correspond to its own live map reservation.")

	print("PASS: Cancelled quests leave vacancies immediately while the global board keeps rotating independently through death and recovery.")
	quit()

func start_current_quest(simulation) -> bool:
	for _roll in 10:
		simulation.advance_time(10.0)
		if simulation.hero_state.loop_state == HeroState.TRAVEL_TO_QUEST and simulation.hero_state.active_quest != null:
			return true
		assert(simulation.hero_state.loop_state == HeroState.CHOOSING_QUEST, "Failed current-board selection must leave the hero waiting for another board roll.")
		assert(simulation.quest_pool.refresh_board(simulation.world_clock.world_tick), "Test setup must be able to reroll the current board.")
	return false
