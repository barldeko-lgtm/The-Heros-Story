extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const EVENT_PATHS := [
	"res://data/events/mid_region/0011_wagon_in_flooded_hollow.tres",
	"res://data/events/mid_region/0012_orc_at_field_granary.tres",
	"res://data/events/mid_region/0013_smoke_beyond_firebreak.tres",
	"res://data/events/mid_region/0014_shaman_at_thunder_stone.tres",
	"res://data/events/mid_region/0015_bell_on_far_ridge.tres",
]

func _init() -> void:
	var definitions: Array = []
	for path in EVENT_PATHS:
		var definition = load(path)
		assert(definition != null and definition.validate_definition(), "Mid Region event must load and validate: %s" % path)
		assert(definition.region_id == "mid_region")
		definitions.append(definition)

	assert(definitions[0].display_name == "Телега в размокшей низине")
	assert(definitions[1].display_name == "Орк у полевого амбара")
	assert(definitions[2].display_name == "Дым за лесной просекой")
	assert(definitions[3].display_name == "Шаман у громового камня")
	assert(definitions[4].display_name == "Колокол на дальнем гребне")

	var batch_summary := summarize_definitions(definitions)
	assert(batch_summary["terrain"] == {"plains": 2, "forest": 1, "hill": 2})
	assert(batch_summary["combat"] == 2)
	assert(batch_summary["secondary"] == 2)
	assert(batch_summary["attributes"] == {"strength": 4, "dexterity": 3, "constitution": 4, "wisdom": 4})
	assert(batch_summary["movement"] == {
		"brave": 0,
		"cautious": 1,
		"noble": 2,
		"devious": 2,
		"generous": 3,
		"greedy": 2,
		"curious": 2,
		"conservative": 3,
	})
	assert(definitions[2].secondary_target_enabled and definitions[4].secondary_target_enabled)
	assert(not definitions[0].secondary_target_enabled and not definitions[1].secondary_target_enabled and not definitions[3].secondary_target_enabled)
	assert(has_combat(definitions[1]) and has_combat(definitions[3]))
	assert(not has_combat(definitions[0]) and not has_combat(definitions[2]) and not has_combat(definitions[4]))

	for index in range(definitions.size()):
		assert_can_spawn_in_mid_region(definitions[index], 25000 + index)

	var all_mid := load_event_directory("res://data/events/mid_region")
	assert(all_mid.size() == 15)
	var mid_summary := summarize_definitions(all_mid)
	assert(mid_summary["terrain"] == {"plains": 5, "forest": 5, "hill": 5})
	assert(mid_summary["combat"] == 7)
	assert(mid_summary["secondary"] == 5)
	assert(mid_summary["attributes"] == {"strength": 12, "dexterity": 11, "constitution": 11, "wisdom": 11})
	assert(mid_summary["movement"] == {
		"brave": 2,
		"cautious": 2,
		"noble": 6,
		"devious": 8,
		"generous": 7,
		"greedy": 7,
		"curious": 5,
		"conservative": 8,
	})

	var all_starting := load_event_directory("res://data/events/starting_region")
	assert(all_starting.size() == 20)
	var world_movement := empty_movement_counts()
	accumulate_movement(all_starting, world_movement)
	accumulate_movement(all_mid, world_movement)
	assert(world_movement == {
		"brave": 13,
		"cautious": 13,
		"noble": 12,
		"devious": 13,
		"generous": 13,
		"greedy": 13,
		"curious": 12,
		"conservative": 13,
	})

	var simulation = SimulationScript.new(25999, null, [], true)
	assert(count_region_events(simulation, "starting_region") == 20)
	assert(count_region_events(simulation, "mid_region") == 15)
	print("PASS: Mid Region events 11-15 close the approved Arden pool at 5/5/5 terrain, 7 combat, 5 detours and the exact two-region personality target.")
	quit()

func summarize_definitions(definitions: Array) -> Dictionary:
	var summary := {
		"terrain": {"plains": 0, "forest": 0, "hill": 0},
		"movement": empty_movement_counts(),
		"attributes": {"strength": 0, "dexterity": 0, "constitution": 0, "wisdom": 0},
		"combat": 0,
		"secondary": 0,
	}
	for definition in definitions:
		assert(definition.placement_allowed_terrain_ids.size() == 1)
		var terrain_id: String = definition.placement_allowed_terrain_ids[0]
		assert(summary["terrain"].has(terrain_id))
		summary["terrain"][terrain_id] += 1
		if definition.secondary_target_enabled:
			summary["secondary"] += 1
		if has_combat(definition):
			summary["combat"] += 1
		var decision = definition.get_stage("first_decision")
		assert(decision != null and decision.decision_role == 1 and decision.selection_rule == "highest_primary_attribute")
		assert(decision.options.size() >= 2 and decision.options.size() <= 3)
		for option in decision.options:
			assert(summary["attributes"].has(option.driver_attribute))
			summary["attributes"][option.driver_attribute] += 1
			var trait_id: String = movement_trait(option.personality_axis_id, option.personality_delta)
			if not trait_id.is_empty():
				assert(summary["movement"].has(trait_id))
				summary["movement"][trait_id] += 1
	return summary

func load_event_directory(path: String) -> Array:
	var definitions: Array = []
	var file_names := Array(DirAccess.get_files_at(path))
	file_names.sort()
	for file_name in file_names:
		if not file_name.ends_with(".tres"):
			continue
		var definition = load(path.path_join(file_name))
		assert(definition != null and definition.validate_definition())
		definitions.append(definition)
	return definitions

func accumulate_movement(definitions: Array, counts: Dictionary) -> void:
	for definition in definitions:
		var decision = definition.get_stage("first_decision")
		assert(decision != null)
		for option in decision.options:
			var trait_id: String = movement_trait(option.personality_axis_id, option.personality_delta)
			if not trait_id.is_empty():
				counts[trait_id] += 1

func empty_movement_counts() -> Dictionary:
	return {
		"brave": 0,
		"cautious": 0,
		"noble": 0,
		"devious": 0,
		"generous": 0,
		"greedy": 0,
		"curious": 0,
		"conservative": 0,
	}

func has_combat(definition) -> bool:
	for stage in definition.stages:
		if stage.stage_type == 3:
			return true
	return false

func movement_trait(axis_id: String, delta: int) -> String:
	if delta == 0:
		return ""
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
