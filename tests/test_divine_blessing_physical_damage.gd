extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")

func _init() -> void:
	var simulation = SimulationScript.new(2402, null)
	simulation.trait_development.apply_starting_traits(simulation.hero_state, [])
	var base_physical_damage: float = simulation.base_combat_stats.attack
	var base_power: float = simulation.get_hero_power()

	assert(simulation.choose_next_quest(), "Blessing test requires one eligible quest offer.")
	assert(simulation.use_combat_buff(), "Combat blessing must activate through Simulation.")
	assert(simulation.get_combat_buff_fights_remaining() == 5, "Combat blessing must begin with five fight charges.")
	assert(is_equal_approx(simulation.base_combat_stats.attack, base_physical_damage), "Temporary blessing must not change base Physical Damage.")
	assert(is_equal_approx(simulation.combat_stats.attack, base_physical_damage * 1.15), "Combat blessing must multiply resolved Physical Damage by 1.15.")
	assert(is_equal_approx(simulation.get_hero_power(), base_power), "Temporary blessing must not change persistent HeroPower.")

	simulation.combat_stats.crit_chance = 0.0
	simulation.start_combat()
	var first_attack_time: float = simulation.active_combat_session.hero_next_attack_time
	var actions: Array = simulation.active_combat_session.advance(first_attack_time)
	assert(not actions.is_empty() and actions[0].attacker_id == "hero", "Blessing test must observe the first hero strike.")
	assert(is_equal_approx(actions[0].damage, base_physical_damage * 1.15), "Combat must use the blessed resolved Physical Damage.")

	for _fight in 5:
		simulation.consume_combat_buff_fight()
	assert(simulation.get_combat_buff_fights_remaining() == 0, "Five completed fights must remove the blessing.")
	assert(is_equal_approx(simulation.combat_stats.attack, base_physical_damage), "Physical Damage must return to base after the blessing expires.")

	print("PASS: Divine blessing grants +15% resolved Physical Damage for five fights without changing base HeroPower.")
	quit()
