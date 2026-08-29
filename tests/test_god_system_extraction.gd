extends SceneTree

const GOD_SYSTEM_PATH := "res://scripts/god/god_system.gd"

func _init() -> void:
	var god_system_script: Script = load(GOD_SYSTEM_PATH)
	if god_system_script == null:
		push_error("GodSystem must exist as the owner of divine command rules.")
		quit(1)
		return

	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	assert(simulation_script != null, "God-system extraction test requires Simulation.")

	var healing_simulation = simulation_script.new(1)
	var healing_system = god_system_script.new(healing_simulation.god_state)
	healing_simulation.hero_state.current_hp = healing_simulation.combat_stats.max_hp * 0.25
	assert(healing_system.use_divine_healing(healing_simulation.hero_state, healing_simulation.combat_stats, null), "GodSystem must apply valid divine healing.")
	assert(is_equal_approx(healing_simulation.hero_state.current_hp, healing_simulation.combat_stats.max_hp * 0.75), "Divine healing must restore 50% MaxHP through GodSystem.")

	var buff_simulation = simulation_script.new(2)
	var buff_system = god_system_script.new(buff_simulation.god_state)
	assert(buff_system.use_combat_buff(buff_simulation.hero_state), "GodSystem must activate the combat blessing.")
	assert(buff_system.get_combat_buff_fights_remaining(buff_simulation.hero_state) == 5, "GodSystem must expose all five blessing charges.")
	for _fight in 5:
		assert(buff_system.consume_combat_buff_fight(buff_simulation.hero_state), "Each active blessing charge must be consumed through GodSystem.")
	assert(buff_system.get_combat_buff_fights_remaining(buff_simulation.hero_state) == 0, "GodSystem must remove the blessing after five fights.")

	var guidance_simulation = simulation_script.new(3, null)
	var guidance_system = god_system_script.new(guidance_simulation.god_state)
	var available_quests: Array = guidance_simulation.quest_pool.get_available_quests()
	assert(not available_quests.is_empty(), "Guidance test requires at least one available quest.")
	assert(guidance_system.guide_hero_to_quest(available_quests[0].id, true, available_quests), "GodSystem must validate and store guidance for an available quest.")

	var resurrection_simulation = simulation_script.new(4)
	var resurrection_system = god_system_script.new(resurrection_simulation.god_state)
	resurrection_simulation.hero_state.loop_state = "DEAD_RESPAWNING"
	resurrection_simulation.hero_state.current_hp = 0.0
	resurrection_simulation.quest_runner.respawn_ticks_remaining = 100
	var resurrection_result: Dictionary = resurrection_system.use_instant_resurrection(resurrection_simulation.hero_state, resurrection_simulation.quest_runner, resurrection_simulation.combat_stats)
	assert(resurrection_result["succeeded"], "GodSystem must coordinate a valid instant resurrection.")
	assert(resurrection_simulation.hero_state.loop_state == "RECOVERING_IN_CITY", "Instant resurrection must preserve the existing city-recovery transition.")
	assert(is_equal_approx(resurrection_simulation.hero_state.current_hp, 1.0), "Instant resurrection must preserve the existing 1 HP result.")

	var compatibility_simulation = simulation_script.new(5)
	assert(compatibility_simulation.use_combat_buff(), "Simulation.use_combat_buff must remain a compatible public wrapper.")
	assert(compatibility_simulation.get_combat_buff_fights_remaining() == 5, "The Simulation wrapper must expose GodSystem blessing charges.")

	print("PASS: GodSystem owns divine command rules while Simulation keeps compatible public commands.")
	quit()
