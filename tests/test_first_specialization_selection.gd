extends SceneTree

const HeroStateScript = preload("res://scripts/hero/hero_state.gd")
const HeroTraitsScript = preload("res://scripts/hero/hero_traits.gd")
const HeroSpecializationScript = preload("res://scripts/hero/hero_specialization.gd")
const SimulationScript = preload("res://scripts/core/simulation.gd")

func _init() -> void:
	test_level_one_preview_and_level_twenty_snapshot()
	test_live_allocated_stats_and_divine_guidance_resolve_immediately()
	test_timeout_waits_full_180_ticks_and_is_deterministic()
	print("PASS: First specialization preview, frozen courage trait, live stat weights, +0.15 guidance and 180-tick target selection work without granting the class early.")
	quit()

func test_level_one_preview_and_level_twenty_snapshot() -> void:
	var hero = HeroStateScript.new("Preview")
	var preview: Dictionary = HeroSpecializationScript.get_debug_state(hero)
	assert(not bool(preview["decision_active"]), "Specialization choice must be inactive before Level 20.")
	assert(int(preview["mandatory_strength"]) == 0, "Level 1 preview must subtract no class-earned Strength.")
	assert(is_equal_approx(float(preview["slayer_base"]), 0.5) and is_equal_approx(float(preview["protector_base"]), 0.5), "Symmetric Level 1 stats must preview equal specialization weights.")

	hero.level = 20
	hero.strength = 24 # 5 starting + 19 mandatory Warrior level-up points.
	hero.dexterity = 5
	hero.constitution = 5
	hero.wisdom = 5
	hero.personality_traits_by_axis["courage"] = HeroTraitsScript.BRAVE
	assert(HeroSpecializationScript.start_if_needed(hero, 100), "Level 20 must open the first-specialization decision window.")
	var started: Dictionary = HeroSpecializationScript.get_debug_state(hero)
	assert(int(started["mandatory_strength"]) == 19 and int(started["personal_strength"]) == 5, "Level 20 must remove exactly the 19 actually earned mandatory Warrior STR points.")
	assert(str(started["courage_trait"]) == HeroTraitsScript.BRAVE and is_equal_approx(float(started["slayer_trait_modifier"]), 0.05), "Brave must freeze as +0.05 Slayer influence at Level 20.")
	assert(int(started["ticks_remaining"]) == 180, "The decision must open with the full 180 ticks remaining.")
	hero.personality_traits_by_axis["courage"] = HeroTraitsScript.CAUTIOUS
	var after_trait_change: Dictionary = HeroSpecializationScript.get_debug_state(hero)
	assert(str(after_trait_change["courage_trait"]) == HeroTraitsScript.BRAVE, "Later personality changes must not alter the frozen Level-20 courage trait.")

func test_live_allocated_stats_and_divine_guidance_resolve_immediately() -> void:
	var simulation = SimulationScript.new(5151, null)
	var hero = simulation.hero_state
	hero.level = 20
	hero.strength = 24
	hero.dexterity = 5
	hero.constitution = 5
	hero.wisdom = 5
	hero.pending_primary_attribute_points = 1
	hero.personality_traits_by_axis["courage"] = HeroTraitsScript.BRAVE
	assert(HeroSpecializationScript.start_if_needed(hero, simulation.world_clock.world_tick), "Fixture must start the decision window.")
	var before: Dictionary = simulation.get_first_specialization_debug_state()
	assert(is_equal_approx(float(before["protector_base"]), 0.5), "Balanced fixture must start at 0.5 Protector stat weight.")
	assert(simulation.allocate_primary_attribute("constitution"), "A pending point distributed during the window must use the normal attribute command.")
	var after: Dictionary = simulation.get_first_specialization_debug_state()
	assert(float(after["protector_base"]) > float(before["protector_base"]), "A newly distributed CON point must immediately raise Protector stat weight.")
	assert(int(after["pending_primary_attribute_points"]) == 0, "Spent primary points must disappear from the specialization debug state.")
	var energy_before: float = simulation.god_state.energy
	assert(simulation.guide_first_specialization(HeroSpecializationScript.PROTECTOR_ID), "The player must be able to spend the one-time +0.15 Protector influence during the active window.")
	assert(is_equal_approx(simulation.god_state.energy, energy_before - simulation.god_state.SPECIALIZATION_GUIDANCE_COST), "Specialization guidance must spend the approved 80 Divine Energy.")
	assert(hero.first_specialization_id == HeroSpecializationScript.PROTECTOR_ID, "Guidance must immediately end the window and fix the winning specialization target.")
	assert(hero.hero_class_id == HeroSpecializationScript.WARRIOR_ID, "Choosing a specialization target must not grant the class before the specialization dungeon/quest is completed.")
	assert(not hero.specialization_decision_active and hero.specialization_decision_ticks_remaining == 0, "Player influence must close the decision immediately.")
	assert(not simulation.guide_first_specialization(HeroSpecializationScript.SLAYER_ID), "The one-time specialization influence must not be usable after the decision is resolved.")

func test_timeout_waits_full_180_ticks_and_is_deterministic() -> void:
	var hero = HeroStateScript.new("Timeout")
	hero.level = 20
	hero.strength = 60
	hero.dexterity = 30
	hero.constitution = 5
	hero.wisdom = 5
	assert(HeroSpecializationScript.start_if_needed(hero, 50), "Timeout fixture must start.")
	var large_lead: Dictionary = HeroSpecializationScript.get_debug_state(hero)
	assert(float(large_lead["difference"]) > 0.20, "Fixture must have a deliberately decisive Slayer lead.")
	assert(HeroSpecializationScript.advance_world_tick(hero, 51, 777).is_empty() and hero.specialization_decision_active, "A large lead must no longer cause an early autonomous decision.")
	for tick in range(52, 230):
		assert(HeroSpecializationScript.advance_world_tick(hero, tick, 777).is_empty(), "The window must remain unresolved before its 180th elapsed tick.")
	assert(hero.specialization_decision_ticks_remaining == 1, "Exactly one decision tick must remain after 179 elapsed ticks.")
	var result: String = HeroSpecializationScript.advance_world_tick(hero, 230, 777)
	assert(result == HeroSpecializationScript.SLAYER_ID and hero.first_specialization_id == HeroSpecializationScript.SLAYER_ID, "The 180th elapsed tick must resolve to the current higher score and fix that specialization target.")
	assert(hero.hero_class_id == HeroSpecializationScript.WARRIOR_ID, "Timeout resolution must also leave the hero mechanically Warrior until the specialization trial is completed.")

	var tie_a = HeroStateScript.new("Tie A")
	var tie_b = HeroStateScript.new("Tie B")
	for tied_hero in [tie_a, tie_b]:
		tied_hero.level = 20
		tied_hero.strength = 24
		tied_hero.dexterity = 5
		tied_hero.constitution = 5
		tied_hero.wisdom = 5
		assert(HeroSpecializationScript.start_if_needed(tied_hero, 1000))
	var tie_result_a: String = HeroSpecializationScript.resolve(tie_a, 9999, 1180)
	var tie_result_b: String = HeroSpecializationScript.resolve(tie_b, 9999, 1180)
	assert(tie_result_a == tie_result_b and HeroSpecializationScript.is_valid_specialization_id(tie_result_a), "Exact ties must use one deterministic seeded tie-break rule.")
