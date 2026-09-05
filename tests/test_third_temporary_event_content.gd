extends SceneTree

const EventDefinitionResource = preload("res://data/events/starting_region/0003_poachers_snares.tres")

func _init() -> void:
	var definition = EventDefinitionResource
	assert(definition.validate_definition(), "Poachers' Snares must be a structurally valid temporary event.")
	assert(definition.id == "poachers_snares")
	assert(definition.display_name == "Чужие силки")
	assert(definition.region_id == "starting_region")
	assert(definition.placement_distance_hex_min == 4 and definition.placement_distance_hex_max == 6)
	assert(definition.placement_allowed_terrain_ids == PackedStringArray(["forest"]))
	assert(definition.placement_forbidden_tags.has("city"))
	assert(not definition.secondary_target_enabled, "Poachers' Snares is local to one event footprint and must not invent a second map destination.")

	var first_decision = definition.get_stage("first_decision")
	assert(first_decision.decision_role == 1)
	assert(first_decision.options.size() == 3)
	var options_by_driver: Dictionary = {}
	for option in first_decision.options:
		options_by_driver[option.driver_attribute] = option
	assert(options_by_driver.size() == 3 and options_by_driver.has("strength") and options_by_driver.has("dexterity") and options_by_driver.has("wisdom"))
	assert(options_by_driver["strength"].personality_axis_id == "courage" and options_by_driver["strength"].personality_delta == 5)
	assert(options_by_driver["dexterity"].personality_axis_id == "curiosity" and options_by_driver["dexterity"].personality_delta == 5)
	assert(options_by_driver["wisdom"].personality_axis_id == "courage" and options_by_driver["wisdom"].personality_delta == -5)

	var boar_stage = definition.get_stage("str_combat")
	assert(boar_stage.mob_definition != null and boar_stage.mob_definition.id == "wild_boar")
	assert(boar_stage.mob_definition.resource_path == "res://data/mobs/0005_wild_boar.tres")
	assert(boar_stage.mob_definition.experience_reward == 75)
	assert(definition.get_stage("str_approach").duration_ticks == 1)
	assert(definition.get_stage("dex_tracks").duration_ticks == 4, "DEX must cost exactly two more authored ticks than the STR route including its combat tick.")
	assert(definition.get_stage("wis_detour").duration_ticks == 5, "WIS must cost exactly three more authored ticks than the STR route including its combat tick.")

	var curious_check = definition.get_stage("curious_check")
	assert(curious_check.decision_role == 2 and curious_check.checked_trait_id == "curious")
	assert(definition.get_stage("curious_search").duration_ticks == 2)
	for noble_check_id in ["noble_check_standard", "noble_check_curious"]:
		var noble_check = definition.get_stage(noble_check_id)
		assert(noble_check.decision_role == 2 and noble_check.checked_trait_id == "noble")
	for detain_stage_id in ["noble_detain_standard", "noble_detain_curious"]:
		assert(definition.get_stage(detain_stage_id).duration_ticks == 2)

	for end_stage_id in ["standard_end", "curious_end"]:
		assert(definition.get_stage(end_stage_id).gold_reward == 50)
	for end_stage_id in ["noble_end", "curious_noble_end"]:
		assert(definition.get_stage(end_stage_id).gold_reward == 75)
	for end_stage_id in ["standard_end", "noble_end"]:
		assert(definition.get_stage(end_stage_id).equipment_reward_source == null)
	for end_stage_id in ["curious_end", "curious_noble_end"]:
		var end_stage = definition.get_stage(end_stage_id)
		assert(end_stage.equipment_reward_source != null and end_stage.equipment_reward_source.item_level == 5)
		assert(end_stage.equipment_rarity_override == 0, "Curious camp search must award guaranteed Common/White ilvl 5 equipment.")
	for end_stage_id in ["standard_end", "noble_end", "curious_end", "curious_noble_end"]:
		assert(not definition.get_stage(end_stage_id).diary_text.is_empty())

	print("PASS: Poachers' Snares has approved forest placement, STR/DEX/WIS formative meanings, Curious/Noble expressive stages, Wild Boar combat, rewards, and diary text.")
	quit()

