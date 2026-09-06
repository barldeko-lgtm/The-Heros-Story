extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")

func _init() -> void:
	test_rotation_schedule_and_cap()
	test_engagement_cooldown_and_rotation_survival()
	print("PASS: Temporary events rotate every 200 ticks from tick 100, cap at five, and engaged definitions receive a 500-tick cooldown.")
	quit()

func test_rotation_schedule_and_cap() -> void:
	var simulation = SimulationScript.new(9301, null, [], true)
	assert(simulation.event_system.MAX_ACTIVE_EVENTS == 5)
	assert(simulation.event_system.EVENT_ROTATION_INTERVAL_TICKS == 200)
	assert(simulation.event_system.EVENT_COOLDOWN_AFTER_ENGAGE_TICKS == 500)
	assert(not simulation.event_system.is_population_rotation_tick(99))
	assert(simulation.event_system.is_population_rotation_tick(100))
	assert(not simulation.event_system.is_population_rotation_tick(299))
	assert(simulation.event_system.is_population_rotation_tick(300))
	assert(simulation.event_system.is_population_rotation_tick(500))

	simulation.quest_pool.release_available_offer_map_targets()
	var first_population: Dictionary = simulation.event_system.advance_population(100)
	assert(simulation.event_system.current_cycle_definition_ids.size() == 5, "The tick-100 population must select exactly five definitions when the authored pool exceeds the five-event cap.")
	assert(not first_population["spawned"].is_empty())
	assert(simulation.event_system.get_active_events().size() <= 5)
	if simulation.event_system.get_active_events().size() < 5:
		assert(simulation.event_system.has_pending_current_population(100))
	var first_instances: Dictionary = instances_by_definition_id(simulation.event_system.get_active_events())
	assert(first_instances.size() == simulation.event_system.get_active_events().size())

	var before_rotation: Dictionary = simulation.event_system.advance_population(299)
	assert(before_rotation["rotated_out"].is_empty() and before_rotation["spawned"].is_empty())
	for definition_id in first_instances:
		assert(simulation.event_system.get_active_events().has(first_instances[definition_id]), "No event instance may be replaced before the shared tick-300 rotation.")

	var second_population: Dictionary = simulation.event_system.advance_population(300)
	assert(second_population["rotated_out"].size() == first_instances.size(), "The shared tick-300 rotation must remove every unengaged event from the previous population together.")
	assert(simulation.event_system.current_cycle_definition_ids.size() == 5, "The tick-300 rotation must again select exactly five eligible definitions from the larger authored pool.")
	assert(simulation.event_system.get_active_events().size() == second_population["spawned"].size())
	assert(simulation.event_system.get_active_events().size() <= 5)
	if simulation.event_system.get_active_events().size() < 5:
		assert(simulation.event_system.has_pending_current_population(300), "A selected definition that cannot fit immediately must remain pending in the current population cycle.")
	for old_instance in second_population["rotated_out"]:
		assert(not simulation.event_system.get_active_events().has(old_instance), "Rotated event instances must be replaced rather than silently kept alive.")

func test_engagement_cooldown_and_rotation_survival() -> void:
	var simulation = SimulationScript.new(9302, null, [], true)
	simulation.quest_pool.release_available_offer_map_targets()
	var first_population: Dictionary = simulation.event_system.advance_population(100)
	assert(not first_population["spawned"].is_empty())
	var engaged_event = first_population["spawned"][0]
	var engaged_definition_id: String = engaged_event.definition.id
	assert(simulation.event_system.engage(engaged_event, 120))
	assert(simulation.event_system.get_definition_cooldown_until_tick(engaged_definition_id) == 620)

	var tick_300: Dictionary = simulation.event_system.advance_population(300)
	assert(simulation.event_system.get_active_events().has(engaged_event), "An event already being resolved must survive a population rotation instead of being aborted.")
	assert(not tick_300["rotated_out"].has(engaged_event))
	assert(find_event_by_id(tick_300["spawned"], engaged_definition_id) == null, "An engaged definition must not be duplicated into the new population.")

	assert(simulation.event_system.complete_instance(engaged_event, "test_completion"))
	var tick_500: Dictionary = simulation.event_system.advance_population(500)
	assert(find_event_by_id(tick_500["spawned"], engaged_definition_id) == null, "The activated event must remain unavailable while its 500-tick cooldown is active.")
	assert(simulation.event_system.is_definition_on_cooldown(engaged_definition_id, 619))
	assert(not simulation.event_system.is_definition_on_cooldown(engaged_definition_id, 620))

	simulation.event_system.clear_instances()
	simulation.event_system.set_definitions([engaged_event.definition])
	var tick_700: Dictionary = simulation.event_system.advance_population(700)
	assert(simulation.event_system.current_cycle_definition_ids.has(engaged_definition_id), "Once the cooldown has ended, the event must be eligible for selection at the next 200-tick population rotation even if its footprint has to remain pending.")

func instances_by_definition_id(events: Array) -> Dictionary:
	var result: Dictionary = {}
	for event_instance in events:
		if event_instance != null and event_instance.definition != null:
			result[event_instance.definition.id] = event_instance
	return result

func find_event_by_id(events: Array, event_id: String):
	for event_instance in events:
		if event_instance != null and event_instance.definition != null and event_instance.definition.id == event_id:
			return event_instance
	return null
