extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")

func _init() -> void:
	test_divine_healing()
	test_instant_resurrection()
	test_combat_buff()
	test_quest_guidance()
	test_vision()
	print("PASS: Simulation integrates healing, resurrection, combat buff, quest guidance, and dungeon Vision.")
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
	var base_attack: float = simulation.base_combat_stats.attack
	var base_power: float = simulation.get_hero_power()
	assert(simulation.choose_next_quest(), "Combat-buff test requires one eligible quest offer.")
	assert(simulation.use_combat_buff(), "Combat buff must activate through Simulation.")
	assert(simulation.get_combat_buff_fights_remaining() == 5, "Combat buff charges must live in HeroState.active_effects.")
	assert(is_equal_approx(simulation.base_combat_stats.attack, base_attack), "Temporary buff must not change base Attack used by UI and HeroPower.")
	assert(is_equal_approx(simulation.combat_stats.attack, base_attack * 1.15), "StatResolver must apply the active +15% Physical Damage effect to combat CombatStats.")
	assert(is_equal_approx(simulation.get_hero_power(), base_power), "Temporary combat buff must not affect HeroPower or Hard Filter.")
	simulation.combat_stats.crit_chance = 0.0
	simulation.start_combat()
	var first_attack_time: float = simulation.active_combat_session.hero_next_attack_time
	var actions: Array = simulation.active_combat_session.advance(first_attack_time)
	assert(not actions.is_empty() and actions[0].attacker_id == "hero", "The buff test must observe the first hero strike.")
	assert(is_equal_approx(actions[0].damage, base_attack * 1.15), "Combat must use StatResolver output without a separate CombatSession damage bonus.")
	for _fight in 5:
		simulation.consume_combat_buff_fight()
	assert(simulation.get_combat_buff_fights_remaining() == 0, "Five completed fights must remove the active effect.")
	assert(is_equal_approx(simulation.combat_stats.attack, base_attack), "CombatStats must return to base Attack when the effect expires.")

func test_quest_guidance() -> void:
	var simulation = SimulationScript.new(1004, null)
	var target_quest = null
	var power_window: Dictionary = simulation.quest_evaluator.get_hard_filter_power_window(simulation.get_hero_power(), simulation.hero_state.traits)
	for quest in simulation.quest_pool.get_available_quests():
		var mob_power: float = quest.mob_definition.get_power()
		if mob_power >= float(power_window["minimum"]) and mob_power <= float(power_window["maximum"]):
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

func test_vision() -> void:
	var simulation = SimulationScript.new(1005, null)
	var dungeons: Array = simulation.dungeon_system.get_all_dungeons()
	assert(dungeons.size() == 2, "Vision integration must use the two current Starting Region dungeons.")
	for dungeon in dungeons:
		assert(not dungeon.discovered, "Vision integration test dungeons must begin unknown.")
	assert(simulation.has_unknown_dungeon_in_current_region(), "The Starting Region must expose valid unknown Vision targets.")
	assert(simulation.use_divine_vision(), "Vision must reveal an existing unknown dungeon through Simulation.")
	var discovered_count: int = 0
	for dungeon in dungeons:
		if dungeon.discovered:
			discovered_count += 1
			assert(dungeon.discovery_source == "vision", "The dungeon revealed by Vision must record Vision as its discovery source.")
	assert(discovered_count == 1, "One Vision use must reveal exactly one already-existing unknown dungeon.")
	assert(simulation.dungeon_system.get_all_dungeons().size() == dungeons.size(), "Vision must reveal an existing dungeon rather than create a replacement.")
	assert(simulation.has_unknown_dungeon_in_current_region(), "After revealing one of two current dungeons, the other must remain an unknown Vision target.")
