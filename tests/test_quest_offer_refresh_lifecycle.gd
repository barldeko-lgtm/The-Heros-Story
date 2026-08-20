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

	var untouched_offers: Array = initial_offers.duplicate()
	simulation.set_time_scale(100.0)
	var guard := 0
	while simulation.hero_state.gold == 0 and guard < 2000:
		simulation.advance_time(0.01)
		guard += 1

	assert(guard < 2000, "The selected safe quest must complete during the test.")
	var refreshed_offers: Array = simulation.quest_pool.get_available_quests()

	assert(refreshed_offers.size() == initial_offers.size(), "Replacing one accepted offer must not change the tavern pool size.")
	assert(refreshed_offers[accepted_index] != accepted_offer, "Turning in an accepted quest must replace only that tavern slot with a new offer.")
	for index in refreshed_offers.size():
		if index != accepted_index:
			assert(refreshed_offers[index] == untouched_offers[index], "Unaccepted tavern offers must stay unchanged after another quest is turned in.")

	print("PASS: Turning in a quest refreshes only its tavern offer without assuming a fixed pool size.")
	quit()
