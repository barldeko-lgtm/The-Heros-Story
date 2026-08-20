extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")

func _init() -> void:
	test_divine_healing()
	test_instant_resurrection()
	test_combat_buff()
	test_quest_guidance()
	print("PASS: Simulation integrates all four god abilities with hero, combat, and quest selection.")
	quit()

func test_divine_healing() -> void:
	var simulation = SimulationScript.new(1001, null)
	simulation.hero_state.current_hp = 1.0
	var expected_hp: float = minf(simulation.combat_stats.max_hp, 1.0 + simulation.combat_stats.max_hp * 0.50)
	assert(simulation.use_divine_healing(), "Divine healing must work on an injured living hero outside combat.")
	assert(is_equal_approx(simulation.hero_state.current_hp, expected_hp), "Divine healing must restore 50% MaxHP without exceeding MaxHP.")
	assert(not simulation.use_divine_healing(), "Divine healing must respect its cooldown.")

	var combat_simulation = SimulationScript.new(1011, null)
	assert(combat_simulation.choose_next_quest(), "Combat-healing test requires one eligible quest offer.")
	combat_simulation.start_combat()
	combat_simulation.active_combat_session.hero_remaining_hp = 10.0
	var expected_combat_hp: float = minf(combat_simulation.combat_stats.max_hp, 10.0 + combat_simulation.combat_stats.max_hp * 0.50)
	assert(combat_simulation.use_divine_healing(), "Divine healing must be usable during an active fight.")
	assert(is_equal_approx(combat_simulation.active_combat_session.hero_remaining_hp, expected_combat_hp), "Combat healing must modify live CombatSession HP.")

func test_instant_resurrection() -> void:
	var simulation = SimulationScript.new(1002, null)
	simulation.hero_state.loop_state = HeroState.DEAD_RESPAWNING
	simulation.hero_state.current_hp = 0.0
	simulation.quest_runner.respawn_ticks_remaining = 20
	var previous_energy: float = simulation.god_state.energy
	assert(simulation.use_instant_resurrection(), "Instant resurrection must work while the hero is waiting to respawn.")
	assert(simulation.hero_state.loop_state == HeroState.RECOVERING_IN_CITY, "Instant resurrection must enter normal city recovery.")
	assert(is_equal_approx(simulation.hero_state.current_hp, 1.0), "Instant resurrection must restore exactly one HP.")
	assert(is_equal_approx(simulation.god_state.energy, previous_energy - 10.0), "Twenty remaining ticks must cost 10 energy.")

func test_combat_buff() -> void:
	var simulation = SimulationScript.new(1003, null)
	simulation.hero_state.traits.clear()
	simulation.combat_stats.crit_chance = 0.0
	assert(simulation.choose_next_quest(), "Combat-buff test requires one eligible quest offer.")
	assert(simulation.use_combat_buff(), "Combat buff must activate through Simulation.")
	simulation.start_combat()
	var first_attack_time: float = simulation.active_combat_session.hero_next_attack_time
	var actions: Array = simulation.active_combat_session.advance(first_attack_time)
	assert(not actions.is_empty() and actions[0].attacker_id == "hero", "The buff test must observe the first hero strike.")
	assert(is_equal_approx(actions[0].damage, simulation.combat_stats.attack + 3.0), "Combat buff must add exactly 3 Attack to actual fight damage.")

func test_quest_guidance() -> void:
	var simulation = SimulationScript.new(1004, null)
	var target_quest = null
	var hard_filter_limit: float = simulation.get_hero_power() * 0.95
	for quest in simulation.quest_pool.get_available_quests():
		if quest.mob_definition.get_power() <= hard_filter_limit:
			target_quest = quest
			break
	assert(target_quest != null, "Guidance test requires an eligible quest.")
	assert(simulation.guide_hero_to_quest(target_quest.id), "God must be able to guide toward one current tavern offer.")
	assert(simulation.choose_next_quest(), "Guided quest selection must still produce an eligible result.")
	var target_evaluation: Dictionary = {}
	for evaluation in simulation.last_quest_selection["evaluations"]:
		if evaluation["quest"].id == target_quest.id:
			target_evaluation = evaluation
			break
	assert(not target_evaluation.is_empty(), "The guided eligible quest must participate in QuestScore.")
	assert(is_equal_approx(target_evaluation["divine_modifier"], 0.20), "Guidance must add exactly 0.20 to the target offer for one selection.")
	assert(simulation.god_state.guided_quest_id.is_empty(), "Guidance must be consumed after the next selection action.")
