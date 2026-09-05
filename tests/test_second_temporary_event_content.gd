extends SceneTree

const EventDefinitionResource = preload("res://data/events/starting_region/0002_smoke_over_old_tower.tres")

func _init() -> void:
	var definition = EventDefinitionResource
	assert(definition.validate_definition(), "Smoke Over Old Tower must be a structurally valid temporary event.")
	assert(definition.id == "smoke_over_old_tower")
	assert(definition.region_id == "starting_region")
	assert(definition.placement_distance_hex_min == 3 and definition.placement_distance_hex_max == 5)
	assert(definition.placement_allowed_terrain_ids == PackedStringArray(["hill"]))
	assert(definition.placement_forbidden_tags.has("city"))
	assert(definition.secondary_target_enabled)
	assert(definition.secondary_target_distance_hex_min == 5 and definition.secondary_target_distance_hex_max == 7)
	assert(definition.secondary_target_distance_from_event_hex_min == 2 and definition.secondary_target_distance_from_event_hex_max == 4)
	assert(definition.secondary_target_forbidden_tags.has("city"))
	assert(definition.secondary_target_radius == 0)
	assert(definition.secondary_target_must_be_farther_from_region_origin)

	var first_decision = definition.get_stage("first_decision")
	assert(first_decision.options.size() == 3)
	var options_by_driver: Dictionary = {}
	for option in first_decision.options:
		options_by_driver[option.driver_attribute] = option
	assert(options_by_driver.size() == 3 and options_by_driver.has("dexterity") and options_by_driver.has("wisdom") and options_by_driver.has("constitution"))
	assert(options_by_driver["dexterity"].personality_axis_id == "courage" and options_by_driver["dexterity"].personality_delta == 5, "Rushing to the tower must move Courage +5 toward Brave.")
	assert(options_by_driver["wisdom"].personality_axis_id == "courage" and options_by_driver["wisdom"].personality_delta == -5, "Studying and waiting must move Courage -5 toward Cautious.")
	assert(options_by_driver["constitution"].personality_axis_id == "morality" and options_by_driver["constitution"].personality_delta == 5, "Helping the wounded patrolman first must move Morality +5 toward Noble.")

	assert(definition.get_stage("dex_combat").mob_definition != null and definition.get_stage("dex_combat").mob_definition.id == "bandit", "DEX branch must fight the existing ordinary Bandit.")
	assert(definition.get_stage("dex_combat").mob_definition.resource_path == "res://data/mobs/0006_bandit.tres")
	assert(definition.get_stage("wis_tracks").duration_ticks == 1)
	assert(definition.get_stage("wis_observe").duration_ticks == 3, "WIS safety must pay three authored observation ticks at the tower.")
	assert(definition.get_stage("con_help").duration_ticks == 2, "CON branch must spend two ticks helping the wounded patrolman before leaving him safely.")
	assert(definition.get_stage("con_dead").scene_text.contains("мёртвым"), "CON branch must arrive too late and find the second patrolman dead.")

	for check_stage_id in ["dex_greedy_check", "wis_greedy_check", "con_greedy_check"]:
		var check_stage = definition.get_stage(check_stage_id)
		assert(check_stage.decision_role == 2 and check_stage.checked_trait_id == "greedy", "Every tower outcome must pass through the common expressive Greedy meaning.")
	for search_stage_id in ["dex_search", "wis_search", "con_search"]:
		assert(definition.get_stage(search_stage_id).duration_ticks == 2, "Greedy stash search must always cost two authored ticks.")

	for end_stage_id in ["dex_end", "wis_end", "con_end"]:
		var end_stage = definition.get_stage(end_stage_id)
		assert(end_stage.gold_reward == 50, "Every normal completion branch must award 50 Gold.")
		assert(end_stage.equipment_reward_source == null, "Non-Greedy completion must not receive the stash item.")
		assert(not end_stage.diary_text.is_empty())
	for end_stage_id in ["dex_greedy_end", "wis_greedy_end", "con_greedy_end"]:
		var end_stage = definition.get_stage(end_stage_id)
		assert(end_stage.gold_reward == 50)
		assert(end_stage.equipment_reward_source != null and end_stage.equipment_reward_source.item_level == 10, "Greedy stash must use the current ilvl 10 equipment source.")
		assert(end_stage.equipment_rarity_override == 0, "Greedy stash item must be guaranteed Common/White.")
		assert(not end_stage.diary_text.is_empty())

	print("PASS: Smoke Over Old Tower content has approved placement, DEX/WIS/CON meanings, Bandit combat, Greedy stash, rewards, and diary text.")
	quit()
