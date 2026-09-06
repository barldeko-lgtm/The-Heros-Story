extends SceneTree

const EventDefinitionResource = preload("res://data/events/starting_region/0005_ogre_at_old_barrow.tres")

func _init() -> void:
	var definition = EventDefinitionResource
	assert(definition.validate_definition(), "Ogre at Old Barrow must be a structurally valid temporary event.")
	assert(definition.id == "ogre_at_old_barrow")
	assert(definition.display_name == "Огр у старого кургана")
	assert(definition.region_id == "starting_region")
	assert(definition.placement_distance_hex_min == 5 and definition.placement_distance_hex_max == 6)
	assert(definition.placement_allowed_terrain_ids == PackedStringArray(["plains"]))
	assert(definition.placement_forbidden_tags.has("city"))
	assert(not definition.secondary_target_enabled)

	var first_decision = definition.get_stage("first_decision")
	assert(first_decision.decision_role == 1 and first_decision.options.size() == 3)
	var options_by_driver: Dictionary = {}
	for option in first_decision.options:
		options_by_driver[option.driver_attribute] = option
	assert(options_by_driver.has("dexterity") and options_by_driver.has("strength") and options_by_driver.has("constitution"))
	assert(options_by_driver["dexterity"].personality_axis_id == "courage" and options_by_driver["dexterity"].personality_delta == 5)
	assert(options_by_driver["strength"].personality_axis_id.is_empty() and options_by_driver["strength"].personality_delta == 0)
	assert(options_by_driver["constitution"].personality_axis_id == "courage" and options_by_driver["constitution"].personality_delta == -5)

	assert(definition.get_stage("str_preparation").duration_ticks == 2)
	assert(definition.get_stage("con_preparation").duration_ticks == 3)
	for check_id in ["str_second_check", "con_second_check"]:
		var check_stage = definition.get_stage(check_id)
		assert(check_stage.decision_role == 2)
		assert(check_stage.selection_rule == "any_trait_present")
		assert(check_stage.checked_trait_ids == PackedStringArray(["devious", "conservative"]))
	assert(definition.get_stage("str_extra_preparation").duration_ticks == 2)
	assert(definition.get_stage("con_extra_preparation").duration_ticks == 2)

	var expected_ratios := {
		"dex_combat": 0.75,
		"str_combat": 0.80,
		"str_extra_combat": 0.65,
		"con_combat": 0.85,
		"con_extra_combat": 0.70,
	}
	for stage_id in expected_ratios:
		var combat_stage = definition.get_stage(stage_id)
		assert(combat_stage.mob_definition != null and combat_stage.mob_definition.id == "experienced_ogre")
		assert(combat_stage.mob_definition.display_name == "Опытный огр")
		assert(combat_stage.mob_definition.experience_reward == 195)
		assert(is_equal_approx(combat_stage.combat_start_hp_ratio, expected_ratios[stage_id]))

	var end_stage = definition.get_stage("reward_end")
	assert(end_stage.gold_reward == 0)
	assert(end_stage.equipment_reward_source != null and end_stage.equipment_reward_source.item_level == 10)
	assert(end_stage.equipment_rarity_override == 1, "Victory must guarantee one Green/Uncommon ilvl 10 item.")
	assert(not end_stage.diary_text.is_empty())

	print("PASS: Ogre at Old Barrow has approved plains placement, DEX/STR/CON preparation, Devious-or-Conservative follow-up, partial Ogre HP starts, and Green ilvl 10 reward.")
	quit()
