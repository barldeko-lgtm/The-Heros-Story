extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const EVENT_PATHS := [
	"res://data/events/mid_region/0006_wargs_at_supply_wagon.tres",
	"res://data/events/mid_region/0007_blood_at_resin_kilns.tres",
	"res://data/events/mid_region/0008_surveyors_lost_case.tres",
	"res://data/events/mid_region/0009_beast_at_mountain_cistern.tres",
	"res://data/events/mid_region/0010_water_from_old_channel.tres",
]

func _init() -> void:
	var definitions: Array = []
	for path in EVENT_PATHS:
		var definition = load(path)
		assert(definition != null and definition.validate_definition(), "Mid Region event must load and validate: %s" % path)
		assert(definition.region_id == "mid_region")
		definitions.append(definition)

	assert(definitions[0].display_name == "Варги у обоза снабжения")
	assert(definitions[1].display_name == "Кровь у смоляных печей")
	assert(definitions[2].display_name == "Ящик землемера")
	assert(definitions[3].display_name == "Зверь у горного водосбора")
	assert(definitions[4].display_name == "Вода из старого канала")

	var terrain_counts := {"plains": 0, "forest": 0, "hill": 0}
	var movement_counts := {
		"brave": 0,
		"cautious": 0,
		"noble": 0,
		"devious": 0,
		"generous": 0,
		"greedy": 0,
		"curious": 0,
		"conservative": 0,
	}
	var attribute_counts := {"strength": 0, "dexterity": 0, "constitution": 0, "wisdom": 0}
	var combat_event_count := 0
	var secondary_event_count := 0
	for definition in definitions:
		assert(definition.placement_allowed_terrain_ids.size() == 1)
		var terrain_id: String = definition.placement_allowed_terrain_ids[0]
		assert(terrain_counts.has(terrain_id))
		terrain_counts[terrain_id] += 1
		if definition.secondary_target_enabled:
			secondary_event_count += 1
		if has_combat(definition):
			combat_event_count += 1
		var decision = definition.get_stage("first_decision")
		assert(decision != null and decision.decision_role == 1 and decision.selection_rule == "highest_primary_attribute")
		assert(decision.options.size() == 3)
		for option in decision.options:
			assert(attribute_counts.has(option.driver_attribute))
			attribute_counts[option.driver_attribute] += 1
			var trait_id: String = movement_trait(option.personality_axis_id, option.personality_delta)
			assert(movement_counts.has(trait_id), "Every Formative option must map to one approved personality side.")
			movement_counts[trait_id] += 1

	assert(terrain_counts == {"plains": 1, "forest": 2, "hill": 2})
	assert(combat_event_count == 3)
	assert(secondary_event_count == 1)
	assert(attribute_counts == {"strength": 4, "dexterity": 4, "constitution": 4, "wisdom": 3})
	assert(definitions[2].secondary_target_enabled)
	assert(not definitions[0].secondary_target_enabled and not definitions[1].secondary_target_enabled and not definitions[3].secondary_target_enabled and not definitions[4].secondary_target_enabled)
	assert(has_combat(definitions[0]) and has_combat(definitions[1]) and has_combat(definitions[3]))
	assert(not has_combat(definitions[2]) and not has_combat(definitions[4]))
	assert(movement_counts == {
		"brave": 1,
		"cautious": 0,
		"noble": 2,
		"devious": 3,
		"generous": 2,
		"greedy": 3,
		"curious": 2,
		"conservative": 2,
	})

	for index in range(definitions.size()):
		assert_can_spawn_in_mid_region(definitions[index], 23000 + index)

	var simulation = SimulationScript.new(23999, null, [], true)
	assert(count_region_events(simulation, "starting_region") == 20)
	assert(count_region_events(simulation, "mid_region") >= 10)
	print("PASS: Mid Region events 6-10 provide 1 plains / 2 forest / 2 hill placements, 3 combat events, 1 secondary detour, balanced primary-stat participation and the approved second-batch personality distribution.")
	quit()

func has_combat(definition) -> bool:
	for stage in definition.stages:
		if stage.stage_type == 3:
			return true
	return false

func movement_trait(axis_id: String, delta: int) -> String:
	if axis_id == "courage":
		return "brave" if delta > 0 else "cautious"
	if axis_id == "morality":
		return "noble" if delta > 0 else "devious"
	if axis_id == "greed":
		return "generous" if delta > 0 else "greedy"
	if axis_id == "curiosity":
		return "curious" if delta > 0 else "conservative"
	return ""

func assert_can_spawn_in_mid_region(definition, seed: int) -> void:
	var simulation = SimulationScript.new(seed, null, [], true)
	simulation.quest_pool.release_available_offer_map_targets()
	simulation.event_system.clear_instances()
	simulation.event_system.set_definitions([definition])
	var origin: Vector2i = simulation.hex_map.definition.mid_city_center
	assert(simulation.event_system.spawn_definition(definition, origin, 100), "Mid Region event must have a valid authored map placement: %s" % definition.id)
	var event_instance = simulation.event_system.get_active_events()[0]
	assert(event_instance.definition.id == definition.id)
	var target_hex = simulation.hex_map.get_hex(event_instance.target_hex)
	assert(target_hex != null and target_hex.region_id == "mid_region")
	assert(definition.placement_allowed_terrain_ids.has(target_hex.terrain_id))
	if definition.secondary_target_enabled:
		assert(event_instance.has_secondary_target())
		var secondary_hex = simulation.hex_map.get_hex(event_instance.secondary_target_hex)
		assert(secondary_hex != null and secondary_hex.region_id == "mid_region")

func count_region_events(simulation, region_id: String) -> int:
	var count := 0
	for definition in simulation.event_system.event_definitions:
		if definition != null and definition.region_id == region_id:
			count += 1
	return count
