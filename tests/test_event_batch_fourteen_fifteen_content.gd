extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const EVENT_14 := "res://data/events/starting_region/0014_medicine_before_sunset.tres"
const EVENT_15 := "res://data/events/starting_region/0015_signal_from_old_quarry.tres"

func _init() -> void:
	var medicine = load(EVENT_14)
	var quarry = load(EVENT_15)
	assert(medicine != null and medicine.validate_definition())
	assert(quarry != null and quarry.validate_definition())
	test_medicine_content(medicine)
	test_quarry_content(quarry)
	var simulation = SimulationScript.new(1141501, null, [], true)
	assert(simulation.event_system.event_definitions.size() == 15, "Starting Region event pool must contain exactly fifteen authored events after events 14-15 are added.")
	print("PASS: Events 14-15 use underrepresented CON/STR and Generous/Cautious content with real secondary map objectives.")
	quit()

func test_medicine_content(definition) -> void:
	assert(definition.id == "medicine_before_sunset")
	assert(definition.placement_distance_hex_min == 2 and definition.placement_distance_hex_max == 4)
	assert(definition.placement_allowed_tags.has("road") and definition.placement_forbidden_tags.has("city"))
	assert_secondary_target(definition, 4, 6, 2, 4)
	assert(definition.secondary_target_allowed_terrain_ids.has("plains"))
	assert(definition.secondary_target_allowed_terrain_ids.has("forest"))
	assert(definition.secondary_target_forbidden_tags.has("road"))
	assert_formative_attributes(definition, ["constitution", "strength"])
	assert_option(definition, "strength", "courage", 5)
	assert_option(definition, "constitution", "greed", 5)
	assert_travel(definition, "str_travel_out", 2)
	assert_travel(definition, "con_travel_out", 2)
	assert_trait_check(definition, "str_generous_check", "generous")
	assert_trait_check(definition, "con_generous_check", "generous")
	assert_reward(definition, "str_standard_end", 70)
	assert_reward(definition, "con_standard_end", 100)
	assert_reward(definition, "str_generous_end", 20)
	assert_reward(definition, "con_generous_end", 20)

func test_quarry_content(definition) -> void:
	assert(definition.id == "signal_from_old_quarry")
	assert(definition.placement_allowed_terrain_ids == PackedStringArray(["hill"]))
	assert(definition.placement_distance_hex_min == 3 and definition.placement_distance_hex_max == 5)
	assert_secondary_target(definition, 5, 7, 2, 4)
	assert(definition.secondary_target_allowed_terrain_ids == PackedStringArray(["hill"]))
	assert_formative_attributes(definition, ["constitution", "strength"])
	assert_option(definition, "strength", "courage", 5)
	assert_option(definition, "constitution", "courage", -5)
	assert_travel(definition, "str_travel_out", 2)
	assert_travel(definition, "con_travel_out", 2)
	assert_trait_check(definition, "str_cautious_check", "cautious")
	assert_trait_check(definition, "con_cautious_check", "cautious")
	assert(definition.get_stage("cautious_wait").duration_ticks == 3)
	assert_combat(definition, "str_combat", "cave_lizard", 1.0)
	assert_combat(definition, "con_combat", "cave_lizard", 0.85)
	assert_travel(definition, "cautious_return", 1)
	assert_travel(definition, "fight_return", 1)
	assert_reward(definition, "cautious_end", 70)
	assert_reward(definition, "fight_end", 70)

func assert_secondary_target(definition, city_min: int, city_max: int, event_min: int, event_max: int) -> void:
	assert(definition.secondary_target_enabled)
	assert(definition.secondary_target_distance_hex_min == city_min and definition.secondary_target_distance_hex_max == city_max)
	assert(definition.secondary_target_distance_from_event_hex_min == event_min and definition.secondary_target_distance_from_event_hex_max == event_max)
	assert(definition.secondary_target_radius == 0 and definition.secondary_target_must_be_farther_from_region_origin)

func assert_formative_attributes(definition, expected_attributes: Array) -> void:
	var decision = definition.get_stage("first_decision")
	assert(decision != null and decision.decision_role == 1 and decision.selection_rule == "highest_primary_attribute")
	var actual: Array[String] = []
	for option in decision.options:
		actual.append(option.driver_attribute)
	actual.sort()
	var expected: Array[String] = []
	for attribute_id in expected_attributes:
		expected.append(str(attribute_id))
	expected.sort()
	assert(actual == expected)

func assert_option(definition, attribute_id: String, axis_id: String, delta: int) -> void:
	var decision = definition.get_stage("first_decision")
	for option in decision.options:
		if option.driver_attribute == attribute_id:
			assert(option.personality_axis_id == axis_id and option.personality_delta == delta)
			return
	assert(false, "Missing formative option: %s" % attribute_id)

func assert_trait_check(definition, stage_id: String, trait_id: String) -> void:
	var stage = definition.get_stage(stage_id)
	assert(stage != null and stage.decision_role == 2)
	assert(stage.selection_rule == "trait_present" and stage.checked_trait_id == trait_id)

func assert_travel(definition, stage_id: String, travel_target: int) -> void:
	var stage = definition.get_stage(stage_id)
	assert(stage != null and stage.stage_type == 2 and stage.travel_target == travel_target)

func assert_combat(definition, stage_id: String, mob_id: String, hp_ratio: float) -> void:
	var stage = definition.get_stage(stage_id)
	assert(stage != null and stage.stage_type == 3 and stage.mob_definition.id == mob_id)
	assert(is_equal_approx(stage.combat_start_hp_ratio, hp_ratio))

func assert_reward(definition, stage_id: String, gold_reward: int) -> void:
	var stage = definition.get_stage(stage_id)
	assert(stage != null and stage.stage_type == 4)
	assert(stage.gold_reward == gold_reward and not stage.diary_text.is_empty())

