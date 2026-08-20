extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")

func _init() -> void:
	var simulation = SimulationScript.new(9090, null)
	simulation.hero_state.hero_name = "Алексей"
	var initial_offers: Array = simulation.quest_pool.get_available_quests()

	simulation.advance_time(10.0)
	var cancelled_offer = simulation.hero_state.active_quest
	assert(cancelled_offer != null, "Autonomous selection must accept an offer before it can be cancelled.")
	var cancelled_index := initial_offers.find(cancelled_offer)
	assert(cancelled_index >= 0, "The accepted quest must be part of the current tavern list.")
	var untouched_offers: Array = initial_offers.duplicate()

	cancelled_offer.mob_definition.attack = 500.0
	cancelled_offer.mob_definition.crit_chance = 0.0
	simulation.set_time_scale(100.0)
	var guard := 0
	while simulation.hero_state.loop_state != HeroState.DEAD_RESPAWNING and guard < 1000:
		simulation.advance_time(0.01)
		guard += 1
	assert(guard < 1000, "The deliberately lethal accepted quest must cancel into natural resurrection.")
	assert(simulation.quest_pool.get_available_quests()[cancelled_index] == cancelled_offer, "The cancelled offer must remain visible until city recovery finishes.")

	# 100 dead ticks (1000 simulated seconds) plus five 20%-HP recovery ticks
	# (50 simulated seconds) return the starting Warrior to quest choice exactly.
	simulation.advance_time(10.5)
	assert(simulation.hero_state.loop_state == HeroState.CHOOSING_QUEST, "Natural resurrection and city recovery must return the hero to quest choice.")

	var refreshed_offers: Array = simulation.quest_pool.get_available_quests()
	assert(refreshed_offers[cancelled_index] != cancelled_offer, "A cancelled quest must be replaced when the hero returns to quest choice after recovery.")
	for index in refreshed_offers.size():
		if index != cancelled_index:
			assert(refreshed_offers[index] == untouched_offers[index], "Unaccepted tavern offers must persist through another quest's cancellation.")

	print("PASS: A cancelled quest refreshes only after resurrection and city recovery.")
	quit()
