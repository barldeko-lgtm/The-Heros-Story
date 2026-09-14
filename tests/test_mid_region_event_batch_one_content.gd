extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const EVENT_PATHS := [
	"res://data/events/mid_region/0001_missing_garrison_pay.tres",
	"res://data/events/mid_region/0002_silent_signal_post.tres",
	"res://data/events/mid_region/0003_charcoal_burners_dispute.tres",
	"res://data/events/mid_region/0004_isolated_logging_camp.tres",
	"res://data/events/mid_region/0005_false_toll_at_pass.tres",
]

func _init() -> void:
	var definitions: Array = []
	for path in EVENT_PATHS:
		var definition = load(path)
		assert(definition != null and definition.validate_definition(), "Mid Region event must load and validate: %s" % path)
		assert(definition.region_id == "mid_region")
		definitions.append(definition)

	assert(definitions[0].display_name == "Пропавшее жалование")
	assert(definitions[1].display_name == "Молчание сигнального поста")
	assert(definitions[2].display_name == "Спор у углежогов")
	assert(definitions[3].display_name == "Отрезанная лесная артель")
	assert(definitions[4].display_name == "Пошлина на старом подъёме")

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

	assert(terrain_counts == {"plains": 2, "forest": 2, "hill": 1})
	assert(combat_event_count == 2)
	assert(secondary_event_count == 2)
	assert(attribute_counts == {"strength": 4, "dexterity": 4, "constitution": 3, "wisdom": 4})
	assert(definitions[1].secondary_target_enabled and definitions[3].secondary_target_enabled)
	assert(has_combat(definitions[1]) and has_combat(definitions[4]))
	assert(movement_counts == {
		"brave": 1,
		"cautious": 1,
		"noble": 2,
		"devious": 3,
		"generous": 2,
		"greedy": 2,
		"curious": 1,
		"conservative": 3,
	})

	for index in range(definitions.size()):
		assert_can_spawn_in_mid_region(definitions[index], 21000 + index)

	var simulation = SimulationScript.new(21999, null, [], true)
	assert(count_region_events(simulation, "starting_region") == 20)
	assert(count_region_events(simulation, "mid_region") >= 5, "Later Arden event batches must not invalidate the focused events 1-5 content test.")
	print("PASS: Mid Region events 1-5 provide 2 plains / 2 forest / 1 hill placements, 2 combat events, 2 secondary detours, and the approved first-batch personality distribution.")
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
