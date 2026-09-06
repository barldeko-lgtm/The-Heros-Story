extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")

const EVENT_6 := "res://data/events/starting_region/0006_ownerless_campfire.tres"
const EVENT_7 := "res://data/events/starting_region/0007_wolves_at_pasture.tres"
const EVENT_8 := "res://data/events/starting_region/0008_strangers_casket.tres"
const EVENT_9 := "res://data/events/starting_region/0009_fugitive_mercenary.tres"
const EVENT_10 := "res://data/events/starting_region/0010_wounded_scout.tres"
const EVENT_11 := "res://data/events/starting_region/0011_old_prospectors_stones.tres"
const EVENT_12 := "res://data/events/starting_region/0012_beast_in_broken_cage.tres"
const EVENT_13 := "res://data/events/starting_region/0013_boundary_stone_dispute.tres"

func _init() -> void:
	test_ownerless_campfire_curiosity_can_activate_same_event()
	test_ownerless_campfire_conservative_avoids_combat()
	test_wolves_dex_noble_branch()
	test_wolves_con_standard_branch()
	test_casket_greedy_and_generous_outcomes()
	test_fugitive_dex_fight_and_wis_devious_surrender()
	test_wounded_scout_safe_and_brave_hunt()
	test_prospector_formative_traits_activate_same_event()
	test_broken_cage_con_establishes_cautious_before_second_stage()
	test_boundary_noble_and_devious_outcomes()
	print("PASS: Events 6-13 resolve live formative/expressive combinations, partial-HP combats, XP, Gold, equipment rewards, and same-event trait activation.")
	quit()

func test_ownerless_campfire_curiosity_can_activate_same_event() -> void:
	var setup = create_started_event(10601, EVENT_6)
	var s = setup["simulation"]
	reset_personality(s)
	s.trait_development.apply_movement(s.hero_state, "curiosity", 35)
	prepare_combat_branch(s, "dexterity")
	var items_before := count_items(s, 10, 0)
	var xp_before: int = s.hero_state.experience
	assert(advance_until_combat(s, 20) > 0)
	assert(s.hero_state.personality_axis_values["curiosity"] == 40 and s.trait_development.has_trait(s.hero_state, "curious"))
	assert_event_combat_and_win(s, "bandit_veteran", 1.0)
	assert(s.hero_state.experience == xp_before + 145)
	advance_until_complete_without_combat(s, 10)
	assert(count_items(s, 10, 0) == items_before + 1)
	assert(setup["event"].outcome_id == "bandit_hideout_found")

func test_ownerless_campfire_conservative_avoids_combat() -> void:
	var setup = create_started_event(10602, EVENT_6)
	var s = setup["simulation"]
	reset_personality(s)
	s.trait_development.apply_movement(s.hero_state, "curiosity", -40)
	set_primary_winner(s, "wisdom", false)
	var gold_before: int = s.hero_state.gold
	advance_until_complete_without_combat(s, 20)
	assert(s.hero_state.gold == gold_before + 40)
	assert(s.hero_state.personality_axis_values["courage"] == -5)
	assert(s.hero_state.personality_axis_values["curiosity"] == -40)
	assert(setup["event"].outcome_id == "trap_avoided")

func test_wolves_dex_noble_branch() -> void:
	var setup = create_started_event(10701, EVENT_7)
	var s = setup["simulation"]
	reset_personality(s)
	s.trait_development.apply_movement(s.hero_state, "morality", 40)
	prepare_combat_branch(s, "dexterity")
	var xp_before: int = s.hero_state.experience
	var gold_before: int = s.hero_state.gold
	assert(advance_until_combat(s, 20) > 0)
	assert_event_combat_and_win(s, "mature_wolf", 0.75)
	assert(s.hero_state.experience == xp_before + 120)
	advance_until_complete_without_combat(s, 10)
	assert(s.hero_state.gold == gold_before + 75)
	assert(s.hero_state.personality_axis_values["curiosity"] == 5)
	assert(setup["event"].outcome_id == "pasture_restored")

func test_wolves_con_standard_branch() -> void:
	var setup = create_started_event(10702, EVENT_7)
	var s = setup["simulation"]
	reset_personality(s)
	prepare_combat_branch(s, "constitution")
	var gold_before: int = s.hero_state.gold
	assert(advance_until_combat(s, 20) > 0)
	assert_event_combat_and_win(s, "mature_wolf", 0.80)
	advance_until_complete_without_combat(s, 10)
	assert(s.hero_state.gold == gold_before + 40)
	assert(s.hero_state.personality_axis_values["courage"] == -5)
	assert(setup["event"].outcome_id == "pasture_saved")

func test_casket_greedy_and_generous_outcomes() -> void:
	var greedy_setup = create_started_event(10801, EVENT_8)
	var greedy = greedy_setup["simulation"]
	reset_personality(greedy)
	greedy.trait_development.apply_movement(greedy.hero_state, "greed", -40)
	set_primary_winner(greedy, "wisdom", false)
	var greedy_gold: int = greedy.hero_state.gold
	advance_until_complete_without_combat(greedy, 30)
	assert(greedy.hero_state.gold == greedy_gold + 120)
	assert(greedy.hero_state.personality_axis_values["morality"] == 5)
	assert(greedy_setup["event"].outcome_id == "casket_money_taken")

	var generous_setup = create_started_event(10802, EVENT_8)
	var generous = generous_setup["simulation"]
	reset_personality(generous)
	generous.trait_development.apply_movement(generous.hero_state, "greed", 40)
	set_primary_winner(generous, "dexterity", false)
	var items_before := count_items(generous, 5, 1)
	var gold_before: int = generous.hero_state.gold
	advance_until_complete_without_combat(generous, 30)
	assert(generous.hero_state.gold == gold_before)
	assert(count_items(generous, 5, 1) == items_before + 1)
	assert(generous.hero_state.personality_axis_values["curiosity"] == 5)
	assert(generous_setup["event"].outcome_id == "cargo_returned_generously")

func test_fugitive_dex_fight_and_wis_devious_surrender() -> void:
	var fight_setup = create_started_event(10901, EVENT_9)
	var fight = fight_setup["simulation"]
	reset_personality(fight)
	prepare_combat_branch(fight, "dexterity")
	var fight_xp: int = fight.hero_state.experience
	var fight_gold: int = fight.hero_state.gold
	assert(advance_until_combat(fight, 20) > 0)
	assert_event_combat_and_win(fight, "bandit_veteran", 0.70)
	assert(fight.hero_state.experience == fight_xp + 145)
	advance_until_complete_without_combat(fight, 10)
	assert(fight.hero_state.gold == fight_gold + 60)
	assert(fight.hero_state.personality_axis_values["curiosity"] == 5)
	assert(fight_setup["event"].outcome_id == "fugitive_defeated")

	var devious_setup = create_started_event(10902, EVENT_9)
	var devious = devious_setup["simulation"]
	reset_personality(devious)
	devious.trait_development.apply_movement(devious.hero_state, "morality", -40)
	set_primary_winner(devious, "wisdom", false)
	var devious_xp: int = devious.hero_state.experience
	var devious_gold: int = devious.hero_state.gold
	advance_until_complete_without_combat(devious, 30)
	assert(devious.hero_state.experience == devious_xp)
	assert(devious.hero_state.gold == devious_gold + 100)
	assert(devious.hero_state.personality_axis_values["morality"] == -35)
	assert(devious.trait_development.has_trait(devious.hero_state, "devious"), "Existing Devious must remain established through hysteresis after WIS moves Morality +5.")
	assert(devious_setup["event"].outcome_id == "fugitive_taken_alive")

func test_wounded_scout_safe_and_brave_hunt() -> void:
	var safe_setup = create_started_event(11001, EVENT_10)
	var safe = safe_setup["simulation"]
	reset_personality(safe)
	set_primary_winner(safe, "wisdom", false)
	var safe_gold: int = safe.hero_state.gold
	var safe_xp: int = safe.hero_state.experience
	advance_until_complete_without_combat(safe, 30)
	assert(safe.hero_state.gold == safe_gold + 50 and safe.hero_state.experience == safe_xp)
	assert(safe.hero_state.personality_axis_values["courage"] == -5)
	assert(safe_setup["event"].outcome_id == "scout_rescued")

	var brave_setup = create_started_event(11002, EVENT_10)
	var brave = brave_setup["simulation"]
	reset_personality(brave)
	brave.trait_development.apply_movement(brave.hero_state, "courage", 40)
	prepare_combat_branch(brave, "dexterity")
	var brave_gold: int = brave.hero_state.gold
	var brave_xp: int = brave.hero_state.experience
	var items_before := count_items(brave, 10, 0)
	assert(advance_until_combat(brave, 30) > 0)
	assert_event_combat_and_win(brave, "orc_raider", 0.70)
	assert(brave.hero_state.experience == brave_xp + 240)
	advance_until_complete_without_combat(brave, 10)
	assert(brave.hero_state.gold == brave_gold + 50)
	assert(count_items(brave, 10, 0) == items_before + 1)
	assert(brave.trait_development.has_trait(brave.hero_state, "brave"))
	assert(brave_setup["event"].outcome_id == "scout_rescued_orc_hunted")

func test_prospector_formative_traits_activate_same_event() -> void:
	var greedy_setup = create_started_event(11101, EVENT_11)
	var greedy = greedy_setup["simulation"]
	reset_personality(greedy)
	greedy.trait_development.apply_movement(greedy.hero_state, "greed", -35)
	set_primary_winner(greedy, "strength", false)
	var greedy_gold: int = greedy.hero_state.gold
	advance_until_complete_without_combat(greedy, 30)
	assert(greedy.hero_state.personality_axis_values["greed"] == -40)
	assert(greedy.trait_development.has_trait(greedy.hero_state, "greedy"))
	assert(greedy.hero_state.gold == greedy_gold + 120)
	assert(greedy_setup["event"].outcome_id == "prospector_cache_emptied")

	var conservative_setup = create_started_event(11102, EVENT_11)
	var conservative = conservative_setup["simulation"]
	reset_personality(conservative)
	conservative.trait_development.apply_movement(conservative.hero_state, "curiosity", -35)
	set_primary_winner(conservative, "wisdom", false)
	var conservative_gold: int = conservative.hero_state.gold
	advance_until_complete_without_combat(conservative, 30)
	assert(conservative.hero_state.personality_axis_values["curiosity"] == -40)
	assert(conservative.trait_development.has_trait(conservative.hero_state, "conservative"))
	assert(conservative.hero_state.gold == conservative_gold + 50)
	assert(conservative_setup["event"].outcome_id == "prospector_cache_left_early")

func test_broken_cage_con_establishes_cautious_before_second_stage() -> void:
	var setup = create_started_event(11201, EVENT_12)
	var s = setup["simulation"]
	reset_personality(s)
	s.trait_development.apply_movement(s.hero_state, "courage", -35)
	prepare_combat_branch(s, "constitution")
	var xp_before: int = s.hero_state.experience
	var items_before := count_items(s, 5, 1)
	assert(advance_until_combat(s, 30) > 0)
	assert(s.hero_state.personality_axis_values["courage"] == -40)
	assert(s.trait_development.has_trait(s.hero_state, "cautious"), "CON formative movement must establish Cautious before the same event's expressive check.")
	assert_event_combat_and_win(s, "bear", 0.65)
	assert(s.hero_state.experience == xp_before + 100)
	advance_until_complete_without_combat(s, 10)
	assert(count_items(s, 5, 1) == items_before + 1)
	assert(setup["event"].outcome_id == "escaped_bear_defeated")

func test_boundary_noble_and_devious_outcomes() -> void:
	var noble_setup = create_started_event(11301, EVENT_13)
	var noble = noble_setup["simulation"]
	reset_personality(noble)
	noble.trait_development.apply_movement(noble.hero_state, "morality", 35)
	set_primary_winner(noble, "wisdom", false)
	var noble_gold: int = noble.hero_state.gold
	advance_until_complete_without_combat(noble, 30)
	assert(noble.hero_state.personality_axis_values["morality"] == 40)
	assert(noble.trait_development.has_trait(noble.hero_state, "noble"))
	assert(noble.hero_state.gold == noble_gold + 70)
	assert(noble_setup["event"].outcome_id == "boundary_fairly_restored")

	var devious_setup = create_started_event(11302, EVENT_13)
	var devious = devious_setup["simulation"]
	reset_personality(devious)
	devious.trait_development.apply_movement(devious.hero_state, "morality", -40)
	set_primary_winner(devious, "strength", false)
	var devious_gold: int = devious.hero_state.gold
	advance_until_complete_without_combat(devious, 30)
	assert(devious.hero_state.gold == devious_gold + 100)
	assert(devious.hero_state.personality_axis_values["morality"] == -40)
	assert(devious.hero_state.personality_axis_values["courage"] == 5)
	assert(devious_setup["event"].outcome_id == "boundary_profitable_settlement")

func create_started_event(seed: int, event_path: String) -> Dictionary:
	var s = SimulationScript.new(seed, null, [], true)
	s.quest_pool.release_available_offer_map_targets()
	s.event_system.clear_instances()
	var definition = load(event_path)
	assert(definition != null and definition.validate_definition())
	s.event_system.set_definitions([definition])
	var city: Vector2i = s.hex_map.definition.starting_city_center
	assert(s.event_system.spawn_definition(definition, city, 100), "Target event must have at least one valid free authored placement: %s" % definition.id)
	var active = s.event_system.get_active_events()
	assert(active.size() == 1)
	var event_instance = active[0]
	assert_placement_matches_definition(s, event_instance, city)
	assert(s.world_state.set_hero_position(event_instance.target_hex))
	assert(s.event_system.engage(event_instance, 100))
	var begin_result: Dictionary = s.event_runner.begin(s.hero_state, event_instance)
	assert(not begin_result.is_empty())
	return {"simulation": s, "event": event_instance}

func assert_placement_matches_definition(s, event_instance, city: Vector2i) -> void:
	var definition = event_instance.definition
	var hex = s.hex_map.get_hex(event_instance.target_hex)
	assert(hex != null)
	var distance: int = s.hex_map.get_distance_steps(city, event_instance.target_hex)
	assert(distance >= definition.placement_distance_hex_min and distance <= definition.placement_distance_hex_max)
	if not definition.placement_allowed_terrain_ids.is_empty():
		assert(definition.placement_allowed_terrain_ids.has(hex.terrain_id))
	for tag in definition.placement_allowed_tags:
		assert(hex.has_tag(tag))
	for tag in definition.placement_forbidden_tags:
		assert(not hex.has_tag(tag))

func reset_personality(s) -> void:
	s.trait_development.reset_state(s.hero_state)

func set_primary_winner(s, attribute_id: String, combat_ready: bool) -> void:
	s.hero_state.strength = 300 if combat_ready else 5
	s.hero_state.dexterity = 5
	s.hero_state.constitution = 300 if combat_ready else 5
	s.hero_state.wisdom = 5
	match attribute_id:
		"strength": s.hero_state.strength = 500 if combat_ready else 40
		"dexterity": s.hero_state.dexterity = 500 if combat_ready else 40
		"constitution": s.hero_state.constitution = 500 if combat_ready else 40
		"wisdom": s.hero_state.wisdom = 500 if combat_ready else 40
	s.refresh_combat_stats()
	s.hero_state.current_hp = s.combat_stats.max_hp

func prepare_combat_branch(s, attribute_id: String) -> void:
	set_primary_winner(s, attribute_id, true)

func advance_until_combat(s, max_ticks: int) -> int:
	var ticks := 0
	while s.event_runner.active_event != null and s.hero_state.loop_state != s.hero_state.EVENT_COMBAT and ticks < max_ticks:
		ticks += 1
		s.advance_event_tick(1000 + ticks)
	assert(s.event_runner.active_event != null and s.hero_state.loop_state == s.hero_state.EVENT_COMBAT)
	return ticks

func advance_until_complete_without_combat(s, max_ticks: int) -> int:
	var ticks := 0
	while s.event_runner.active_event != null and ticks < max_ticks:
		assert(s.hero_state.loop_state != s.hero_state.EVENT_COMBAT, "Expected a non-combat continuation but event entered combat: %s" % s.event_runner.active_event.definition.id)
		ticks += 1
		s.advance_event_tick(2000 + ticks)
	assert(s.event_runner.active_event == null, "Event did not complete inside the expected tick budget.")
	return ticks

func assert_event_combat_and_win(s, mob_id: String, hp_ratio: float) -> void:
	assert(s.event_runner.get_current_mob_definition().id == mob_id)
	s.start_event_combat()
	assert(s.active_combat_session != null)
	assert(is_equal_approx(s.active_combat_session.mob_remaining_hp, s.active_combat_session.mob_stats.max_hp * hp_ratio))
	var mob_definition = s.active_combat_mob_definition
	assert(is_equal_approx(s.active_combat_session.mob_stats.max_hp, mob_definition.max_hp), "Partial event HP must not rewrite the mob's MaxHP/stat card.")
	assert(is_equal_approx(s.active_combat_session.mob_stats.attack, mob_definition.attack))
	assert(is_equal_approx(s.active_combat_session.mob_stats.armor, mob_definition.armor))
	s.advance_active_combat(1000000.0)
	assert(s.hero_state.loop_state != s.hero_state.DEAD_RESPAWNING, "Combat-ready runtime fixture must win the authored event fight.")

func count_items(s, item_level: int, rarity: int) -> int:
	var count := 0
	for item in s.hero_state.inventory.get_items():
		if item != null and item.item_level == item_level and item.rarity == rarity:
			count += 1
	for item in s.hero_state.equipment.get_all_items():
		if item != null and item.item_level == item_level and item.rarity == rarity:
			count += 1
	return count
