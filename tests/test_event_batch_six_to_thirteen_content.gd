extends SceneTree

const EVENT_PATHS := [
	"res://data/events/starting_region/0006_ownerless_campfire.tres",
	"res://data/events/starting_region/0007_wolves_at_pasture.tres",
	"res://data/events/starting_region/0008_strangers_casket.tres",
	"res://data/events/starting_region/0009_fugitive_mercenary.tres",
	"res://data/events/starting_region/0010_wounded_scout.tres",
	"res://data/events/starting_region/0011_old_prospectors_stones.tres",
	"res://data/events/starting_region/0012_beast_in_broken_cage.tres",
	"res://data/events/starting_region/0013_boundary_stone_dispute.tres",
]

func _init() -> void:
	for path in EVENT_PATHS:
		var definition = load(path)
		assert(definition != null and definition.validate_definition(), "New authored event must load and pass the strict EventDefinition validator: %s" % path)
	test_ownerless_campfire()
	test_wolves_at_pasture()
	test_strangers_casket()
	test_fugitive_mercenary()
	test_wounded_scout()
	test_old_prospectors_stones()
	test_beast_in_broken_cage()
	test_boundary_stone_dispute()
	print("PASS: Events 6-13 have approved placement, formative stats/personality, expressive traits, combat branches, authored rewards, and diary text.")
	quit()

func test_ownerless_campfire() -> void:
	var d = load(EVENT_PATHS[0])
	assert(d.id == "ownerless_campfire" and d.placement_distance_hex_min == 3 and d.placement_distance_hex_max == 5)
	assert(d.placement_allowed_terrain_ids == PackedStringArray(["forest"]))
	assert(d.placement_forbidden_tags.has("road") and d.placement_forbidden_tags.has("city"))
	assert_option(d, "first_decision", "strength", "courage", 5)
	assert_option(d, "first_decision", "dexterity", "curiosity", 5)
	assert_option(d, "first_decision", "wisdom", "courage", -5)
	assert_trait_check(d, "curious_check", "curious")
	assert_trait_check(d, "conservative_check", "conservative")
	assert(d.get_stage("curious_combat").mob_definition.id == "bandit_veteran")
	assert_reward(d, "curious_end", 0, 10, 0)
	assert_reward(d, "conservative_end", 40, -1, -1)
	assert_reward(d, "neutral_end", 25, -1, -1)

func test_wolves_at_pasture() -> void:
	var d = load(EVENT_PATHS[1])
	assert(d.placement_allowed_terrain_ids == PackedStringArray(["plains"]))
	assert(d.placement_distance_hex_min == 3 and d.placement_distance_hex_max == 5)
	assert_option(d, "first_decision", "strength", "courage", 5)
	assert_option(d, "first_decision", "dexterity", "curiosity", 5)
	assert_option(d, "first_decision", "constitution", "courage", -5)
	assert_combat(d, "str_combat", "mature_wolf", 0.90)
	assert_combat(d, "dex_combat", "mature_wolf", 0.75)
	assert_combat(d, "con_combat", "mature_wolf", 0.80)
	assert_trait_check(d, "noble_check", "noble")
	assert(d.get_stage("noble_help").duration_ticks == 2)
	assert_reward(d, "standard_end", 40, -1, -1)
	assert_reward(d, "noble_end", 75, -1, -1)

func test_strangers_casket() -> void:
	var d = load(EVENT_PATHS[2])
	assert(d.placement_allowed_terrain_ids.is_empty())
	assert(d.placement_allowed_tags.has("road") and d.placement_distance_hex_min == 2 and d.placement_distance_hex_max == 4)
	assert_option(d, "first_decision", "wisdom", "morality", 5)
	assert_option(d, "first_decision", "dexterity", "curiosity", 5)
	assert_option(d, "first_decision", "constitution", "morality", 5)
	assert_trait_check(d, "greedy_check", "greedy")
	assert_trait_check(d, "generous_check", "generous")
	assert_reward(d, "greedy_end", 120, -1, -1)
	assert_reward(d, "generous_end", 0, 5, 1)
	assert_reward(d, "neutral_end", 60, -1, -1)

func test_fugitive_mercenary() -> void:
	var d = load(EVENT_PATHS[3])
	assert(d.placement_allowed_terrain_ids == PackedStringArray(["hill"]))
	assert(d.placement_distance_hex_min == 4 and d.placement_distance_hex_max == 6)
	assert_option(d, "first_decision", "strength", "courage", 5)
	assert_option(d, "first_decision", "dexterity", "curiosity", 5)
	assert_option(d, "first_decision", "wisdom", "morality", 5)
	assert_trait_check(d, "str_devious_check", "devious")
	assert_trait_check(d, "dex_devious_check", "devious")
	assert_trait_check(d, "wis_devious_check", "devious")
	assert_combat(d, "str_combat", "bandit_veteran", 1.0)
	assert_combat(d, "dex_combat", "bandit_veteran", 0.70)
	assert_combat(d, "wis_combat", "bandit_veteran", 0.85)
	assert_reward(d, "alive_end", 100, -1, -1)
	assert_reward(d, "dead_end", 60, -1, -1)

func test_wounded_scout() -> void:
	var d = load(EVENT_PATHS[4])
	assert(d.placement_allowed_terrain_ids == PackedStringArray(["hill"]))
	assert(d.placement_distance_hex_min == 4 and d.placement_distance_hex_max == 6)
	assert_option(d, "first_decision", "constitution", "morality", 5)
	assert_option(d, "first_decision", "wisdom", "courage", -5)
	assert_option(d, "first_decision", "dexterity", "curiosity", 5)
	assert_trait_check(d, "con_brave_check", "brave")
	assert_trait_check(d, "wis_brave_check", "brave")
	assert_trait_check(d, "dex_brave_check", "brave")
	assert_combat(d, "con_combat", "orc_raider", 1.0)
	assert_combat(d, "wis_combat", "orc_raider", 0.80)
	assert_combat(d, "dex_combat", "orc_raider", 0.70)
	assert_reward(d, "safe_end", 50, -1, -1)
	assert_reward(d, "brave_end", 50, 10, 0)

func test_old_prospectors_stones() -> void:
	var d = load(EVENT_PATHS[5])
	assert(d.placement_allowed_terrain_ids == PackedStringArray(["hill"]))
	assert(d.placement_distance_hex_min == 3 and d.placement_distance_hex_max == 5)
	assert_option(d, "first_decision", "strength", "greed", -5)
	assert_option(d, "first_decision", "wisdom", "curiosity", -5)
	assert_option(d, "first_decision", "dexterity", "curiosity", 5)
	assert_trait_check(d, "greedy_check", "greedy")
	assert_trait_check(d, "conservative_check", "conservative")
	assert_reward(d, "greedy_end", 120, -1, -1)
	assert_reward(d, "conservative_end", 50, -1, -1)
	assert_reward(d, "neutral_end", 80, -1, -1)

func test_beast_in_broken_cage() -> void:
	var d = load(EVENT_PATHS[6])
	assert(d.placement_allowed_terrain_ids == PackedStringArray(["forest"]))
	assert(d.placement_distance_hex_min == 4 and d.placement_distance_hex_max == 6)
	assert_option(d, "first_decision", "strength", "courage", 5)
	assert_option(d, "first_decision", "constitution", "courage", -5)
	assert_option(d, "first_decision", "wisdom", "curiosity", 5)
	assert_trait_check(d, "str_cautious_check", "cautious")
	assert_trait_check(d, "con_cautious_check", "cautious")
	assert_trait_check(d, "wis_cautious_check", "cautious")
	assert_combat(d, "str_combat", "bear", 0.80)
	assert_combat(d, "con_combat", "bear", 0.75)
	assert_combat(d, "wis_combat", "bear", 0.65)
	assert_combat(d, "str_extra_combat", "bear", 0.70)
	assert_combat(d, "con_extra_combat", "bear", 0.65)
	assert_combat(d, "wis_extra_combat", "bear", 0.55)
	assert_reward(d, "reward_end", 0, 5, 1)

func test_boundary_stone_dispute() -> void:
	var d = load(EVENT_PATHS[7])
	assert(d.placement_allowed_terrain_ids == PackedStringArray(["plains"]))
	assert(d.placement_forbidden_tags.has("road") and d.placement_distance_hex_min == 2 and d.placement_distance_hex_max == 4)
	assert_option(d, "first_decision", "wisdom", "morality", 5)
	assert_option(d, "first_decision", "constitution", "courage", -5)
	assert_option(d, "first_decision", "strength", "courage", 5)
	assert_trait_check(d, "noble_check", "noble")
	assert_trait_check(d, "devious_check", "devious")
	assert_reward(d, "noble_end", 70, -1, -1)
	assert_reward(d, "devious_end", 100, -1, -1)
	assert_reward(d, "neutral_end", 50, -1, -1)

func assert_option(definition, decision_id: String, attribute_id: String, axis_id: String, delta: int) -> void:
	var decision = definition.get_stage(decision_id)
	for option in decision.options:
		if option.driver_attribute == attribute_id:
			assert(option.personality_axis_id == axis_id and option.personality_delta == delta)
			return
	assert(false, "Missing formative option for %s in %s." % [attribute_id, definition.id])

func assert_trait_check(definition, stage_id: String, trait_id: String) -> void:
	var stage = definition.get_stage(stage_id)
	assert(stage != null and stage.decision_role == 2 and stage.selection_rule == "trait_present" and stage.checked_trait_id == trait_id)

func assert_combat(definition, stage_id: String, mob_id: String, hp_ratio: float) -> void:
	var stage = definition.get_stage(stage_id)
	assert(stage != null and stage.mob_definition != null and stage.mob_definition.id == mob_id)
	assert(is_equal_approx(stage.combat_start_hp_ratio, hp_ratio))

func assert_reward(definition, stage_id: String, gold: int, item_level: int, rarity: int) -> void:
	var stage = definition.get_stage(stage_id)
	assert(stage != null and not stage.diary_text.is_empty() and stage.gold_reward == gold)
	if item_level < 0:
		assert(stage.equipment_reward_source == null)
		return
	assert(stage.equipment_reward_source != null and stage.equipment_reward_source.item_level == item_level)
	assert(stage.equipment_rarity_override == rarity)
