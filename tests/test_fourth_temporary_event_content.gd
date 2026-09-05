extends SceneTree

const EventDefinitionResource = preload("res://data/events/starting_region/0004_dead_courier.tres")

func _init() -> void:
	var definition = EventDefinitionResource
	assert(definition.validate_definition(), "Dead Courier must be a structurally valid temporary event.")
	assert(definition.id == "dead_courier")
	assert(definition.display_name == "Мёртвый гонец")
	assert(definition.region_id == "starting_region")
	assert(definition.placement_distance_hex_min == 2 and definition.placement_distance_hex_max == 5)
	assert(definition.placement_allowed_terrain_ids == PackedStringArray(["plains"]))
	assert(definition.placement_forbidden_tags.has("city"))
	assert(definition.placement_forbidden_tags.has("road"))
	assert(not definition.secondary_target_enabled)

	var first_decision = definition.get_stage("first_decision")
	assert(first_decision.decision_role == 1 and first_decision.options.size() == 3)
	var options_by_driver: Dictionary = {}
	for option in first_decision.options:
		options_by_driver[option.driver_attribute] = option
	assert(options_by_driver.has("wisdom") and options_by_driver.has("dexterity") and options_by_driver.has("constitution"))
	assert(options_by_driver["wisdom"].personality_axis_id == "courage" and options_by_driver["wisdom"].personality_delta == 5)
	assert(options_by_driver["dexterity"].personality_axis_id == "curiosity" and options_by_driver["dexterity"].personality_delta == 5)
	assert(options_by_driver["constitution"].personality_axis_id == "morality" and options_by_driver["constitution"].personality_delta == 5)
	assert(definition.get_stage("wis_investigation").duration_ticks == 2)
	assert(definition.get_stage("dex_investigation").duration_ticks == 2)
	assert(definition.get_stage("con_investigation").duration_ticks == 4)

	for check_id in ["wis_devious_check", "dex_devious_check", "con_devious_check"]:
		var check = definition.get_stage(check_id)
		assert(check.decision_role == 2 and check.checked_trait_id == "devious")
	for check_id in ["wis_curious_check_direct", "wis_curious_check_devious", "dex_curious_check_fight", "dex_curious_check_devious", "con_curious_check_fight", "con_curious_check_devious"]:
		var check = definition.get_stage(check_id)
		assert(check.decision_role == 2 and check.checked_trait_id == "curious")

	for combat_id in ["dex_combat", "con_combat"]:
		var combat = definition.get_stage(combat_id)
		assert(combat.mob_definition != null and combat.mob_definition.id == "bandit")
		assert(combat.mob_definition.resource_path == "res://data/mobs/0006_bandit.tres")
		assert(combat.mob_definition.experience_reward == 90)

	for end_id in ["wis_end_direct", "wis_end_devious"]:
		assert(definition.get_stage(end_id).gold_reward == 75)
	for end_id in ["wis_end_direct_curious", "wis_end_devious_curious"]:
		assert(definition.get_stage(end_id).gold_reward == 125)
	for end_id in ["dex_end_fight", "dex_end_devious"]:
		var end_stage = definition.get_stage(end_id)
		assert(end_stage.gold_reward == 75)
		assert(end_stage.equipment_reward_source != null and end_stage.equipment_reward_source.item_level == 5)
		assert(end_stage.equipment_rarity_override == 0)
	for end_id in ["dex_end_fight_curious", "dex_end_devious_curious"]:
		var end_stage = definition.get_stage(end_id)
		assert(end_stage.gold_reward == 125)
		assert(end_stage.equipment_reward_source != null and end_stage.equipment_reward_source.item_level == 5)
		assert(end_stage.equipment_rarity_override == 0)
	for end_id in ["con_end_fight", "con_end_devious"]:
		assert(definition.get_stage(end_id).gold_reward == 100)
	for end_id in ["con_end_fight_curious", "con_end_devious_curious"]:
		assert(definition.get_stage(end_id).gold_reward == 150)

	for stage in definition.stages:
		if stage.stage_type == 4:
			assert(not stage.diary_text.is_empty())

	print("PASS: Dead Courier has approved plains placement, distinct WIS/DEX/CON rewards, Devious/Curious expression, Bandit combat, and diary text.")
	quit()
