extends SceneTree

const HeroStateScript = preload("res://scripts/hero/hero_state.gd")
const EventDecisionResolverScript = preload("res://scripts/events/event_decision_resolver.gd")

const EventDefinitionResource = preload("res://data/events/starting_region/0001_old_clearing_ambush.tres")

func _init() -> void:
	var definition = EventDefinitionResource
	assert(definition.validate_definition(), "The first temporary event definition must be structurally valid.")
	assert(definition.id == "old_clearing_ambush")
	assert(definition.region_id == "starting_region")
	assert(definition.placement_radius == 1 and definition.activation_radius == 1)

	var first_decision = definition.get_stage("first_decision")
	assert(first_decision.options.size() == 3, "Warrior formative stat branching must use no more than three relevant stats.")
	var drivers := PackedStringArray()
	var options_by_driver: Dictionary = {}
	for option in first_decision.options:
		drivers.append(option.driver_attribute)
		options_by_driver[option.driver_attribute] = option
	drivers.sort()
	assert(drivers == PackedStringArray(["dexterity", "strength", "wisdom"]), "The first event must compare STR / DEX / WIS only.")
	assert(not drivers.has("intelligence"))
	assert(options_by_driver["strength"].personality_axis_id == "courage" and options_by_driver["strength"].personality_delta == 5, "Going directly must move Courage +5 toward Brave.")
	assert(options_by_driver["dexterity"].personality_axis_id == "morality" and options_by_driver["dexterity"].personality_delta == 5, "Flanking the ambush to rescue the merchant must move Morality +5 toward Noble.")
	assert(options_by_driver["wisdom"].personality_axis_id == "courage" and options_by_driver["wisdom"].personality_delta == -5, "Inspecting and avoiding the trap must move Courage -5 toward Cautious.")

	assert(branch_ticks(definition, ["intro", "first_decision", "str_approach", "str_combat", "str_end"]) == 5)
	assert(branch_ticks(definition, ["intro", "first_decision", "wis_tracks", "wis_bypass", "wis_observe", "wis_rescue", "wis_end"]) == 8)
	assert(branch_ticks(definition, ["intro", "first_decision", "dex_bypass", "dex_rescue", "dex_trait_check", "dex_standard_end"]) == 7)
	assert(branch_ticks(definition, ["intro", "first_decision", "dex_bypass", "dex_rescue", "dex_trait_check", "dex_brave_prepare", "dex_combat", "dex_brave_end"]) == 9)

	assert(definition.get_stage("str_end").gold_reward == 20)
	assert(definition.get_stage("wis_end").gold_reward == 30)
	assert(definition.get_stage("dex_standard_end").gold_reward == 15)
	var brave_end = definition.get_stage("dex_brave_end")
	assert(brave_end.gold_reward == 15)
	assert(brave_end.equipment_reward_source != null and brave_end.equipment_reward_source.item_level == 10)
	assert(brave_end.equipment_rarity_override == 1, "Brave DEX finish must grant guaranteed Green/Uncommon ilvl 10 equipment.")

	for end_stage_id in ["str_end", "wis_end", "dex_standard_end", "dex_brave_end"]:
		assert(not definition.get_stage(end_stage_id).diary_text.is_empty(), "Every authored final outcome must already contain future diary prose: %s" % end_stage_id)

	var resolver = EventDecisionResolverScript.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = 123
	var hero_one = HeroStateScript.new("Воин 1")
	hero_one.strength = 22
	hero_one.dexterity = 14
	hero_one.constitution = 12
	hero_one.intelligence = 5
	hero_one.wisdom = 20
	var result_one: Dictionary = resolver.resolve_highest_primary_attribute(hero_one, first_decision.options, rng)
	assert(result_one["selected_option"].driver_attribute == "strength")

	var hero_two = HeroStateScript.new("Воин 2")
	hero_two.strength = 15
	hero_two.dexterity = 22
	hero_two.constitution = 15
	hero_two.intelligence = 5
	hero_two.wisdom = 14
	var result_two: Dictionary = resolver.resolve_highest_primary_attribute(hero_two, first_decision.options, rng)
	assert(result_two["selected_option"].driver_attribute == "dexterity")

	print("PASS: Old Clearing content has approved branches, timings, rewards, stat drivers, and ready diary texts.")
	quit()

func branch_ticks(definition, stage_ids: Array) -> int:
	var total: int = 0
	for stage_id in stage_ids:
		total += int(definition.get_stage(stage_id).duration_ticks)
	return total
