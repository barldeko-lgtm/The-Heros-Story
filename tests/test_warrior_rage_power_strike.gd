extends SceneTree

const POWER_STRIKE_ID := "power_strike"

func _init() -> void:
	var hero_state_script: Script = load("res://scripts/hero/hero_state.gd")
	var hero_progression_script: Script = load("res://scripts/hero/hero_progression.gd")
	var combat_simulator_script: Script = load("res://scripts/combat/combat_simulator.gd")
	var combat_stats_script: Script = load("res://scripts/model/runtime/combat_stats.gd")
	var quest_narrator_script: Script = load("res://scripts/narrative/quest_narrator.gd")
	assert(hero_state_script != null and hero_progression_script != null, "Hero progression scripts must exist.")
	assert(combat_simulator_script != null and combat_stats_script != null, "Combat scripts must exist.")

	var hero_state: RefCounted = hero_state_script.new("Тест")
	var hero_progression: RefCounted = hero_progression_script.new()
	hero_state.level = 4
	hero_state.experience_to_next_level = hero_progression.get_experience_required_for_next_level(4)
	hero_progression.add_experience(hero_state, hero_state.experience_to_next_level)
	assert(hero_state.level == 5, "The setup must advance the Warrior to level 5.")
	assert(hero_state.power_strike_skill_level == 1, "Reaching level 5 must learn Power Strike at Skill Level 1.")

	var hero_stats: RefCounted = make_stats(combat_stats_script, 1000.0, 10.0, 1.0, 0.0, 100.0, 0.0)
	var passive_mob_stats: RefCounted = make_stats(combat_stats_script, 1000.0, 0.0, 0.01, 0.0, 100.0, 0.0)
	var combat_simulator: RefCounted = combat_simulator_script.new()
	var session = combat_simulator.create_session(hero_stats, passive_mob_stats, null, 1.0, hero_state.power_strike_skill_level, hero_state.wisdom)

	var opening_actions: Array = session.advance(11.5)
	assert(opening_actions.size() == 6, "Six normal attack opportunities must resolve before the first Power Strike.")
	assert(session.rage == 30, "Six successful normal hits must generate exactly 30 Rage.")
	for action in opening_actions:
		assert(action.action_id != POWER_STRIKE_ID, "Power Strike must not activate before 30 Rage is available.")

	var power_strike_actions: Array = session.advance(2.0)
	assert(power_strike_actions.size() == 1, "Power Strike must replace one normal attack rather than add an extra strike.")
	var power_strike = power_strike_actions[0]
	assert(power_strike.action_id == POWER_STRIKE_ID, "The next ready attack must be identified as Power Strike.")
	assert(power_strike.did_hit, "An activated Power Strike cannot miss.")
	assert(is_equal_approx(power_strike.damage, 15.0), "Skill Level 1 Power Strike at starting Wisdom must deal x1.50 weapon damage.")
	assert(session.rage == 0, "Power Strike must spend 30 Rage and must not generate Rage from its own hit.")

	session.rage = 30
	var cooldown_action: Array = session.advance(2.0)
	assert(cooldown_action.size() == 1 and cooldown_action[0].action_id != POWER_STRIKE_ID, "Power Strike must remain unavailable during its 10-second cooldown.")
	assert(session.rage == 35, "A normal hit during Power Strike cooldown must still generate Rage.")

	var high_dodge_mob: RefCounted = make_stats(combat_stats_script, 1000.0, 0.0, 0.01, 0.0, 100.0, 1000000.0)
	var guaranteed_session = combat_simulator.create_session(hero_stats, high_dodge_mob, null, 1.0, 1, 105)
	guaranteed_session.rage = 30
	var guaranteed_action = guaranteed_session.advance(1.5)[0]
	assert(guaranteed_action.action_id == POWER_STRIKE_ID and guaranteed_action.did_hit, "Power Strike must bypass the ordinary hit roll.")
	assert(is_equal_approx(guaranteed_action.damage, 25.0), "105 Wisdom must raise the Skill Level 1 multiplier from x1.50 to x2.50.")

	var critical_hero_stats: RefCounted = make_stats(combat_stats_script, 1000.0, 10.0, 1.0, 1.0, 100.0, 0.0)
	var critical_session = combat_simulator.create_session(critical_hero_stats, passive_mob_stats)
	critical_session.advance(1.5)
	assert(critical_session.rage == 7, "A successful critical normal hit must generate 7 Rage instead of 5.")

	var slow_hero_stats: RefCounted = make_stats(combat_stats_script, 1000.0, 0.0, 0.01, 0.0, 100.0, 0.0)
	var attacking_mob_stats: RefCounted = make_stats(combat_stats_script, 1000.0, 10.0, 1.0, 0.0, 100.0, 0.0)
	var receiving_session = combat_simulator.create_session(slow_hero_stats, attacking_mob_stats)
	receiving_session.rage = 99
	receiving_session.advance(2.0)
	assert(receiving_session.rage == 100, "Receiving a successful enemy hit must grant 3 Rage without exceeding 100.")

	var blocked_case_found := false
	var blocking_hero_stats: RefCounted = make_stats(combat_stats_script, 1000.0, 0.0, 0.01, 0.0, 100.0, 0.0)
	blocking_hero_stats.block = 1000000.0
	for seed_value in range(1, 100):
		var rng := RandomNumberGenerator.new()
		rng.seed = seed_value
		var blocked_session = combat_simulator.create_session(blocking_hero_stats, attacking_mob_stats, rng)
		var blocked_actions: Array = blocked_session.advance(2.0)
		if blocked_actions[0].was_blocked:
			assert(blocked_session.rage == 3, "A blocked incoming hit must still generate 3 Rage.")
			blocked_case_found = true
			break
	assert(blocked_case_found, "The deterministic seed range must include a blocked incoming hit.")

	var avoided_case_found := false
	var dodging_hero_stats: RefCounted = make_stats(combat_stats_script, 1000.0, 0.0, 0.01, 0.0, 100.0, 1000000.0)
	for seed_value in range(1, 100):
		var rng := RandomNumberGenerator.new()
		rng.seed = seed_value
		var avoided_session = combat_simulator.create_session(dodging_hero_stats, attacking_mob_stats, rng)
		var avoided_actions: Array = avoided_session.advance(2.0)
		if not avoided_actions[0].did_hit:
			assert(avoided_session.rage == 0, "An avoided enemy attack must not generate Rage.")
			avoided_case_found = true
			break
	assert(avoided_case_found, "The deterministic seed range must include an avoided enemy attack.")

	var critical_power_session = combat_simulator.create_session(critical_hero_stats, high_dodge_mob, null, 1.0, 1, 5)
	critical_power_session.rage = 30
	var critical_power_action = critical_power_session.advance(1.5)[0]
	assert(critical_power_action.is_critical, "Power Strike must retain the ordinary critical-hit roll.")
	assert(is_equal_approx(critical_power_action.damage, 30.0), "A critical Skill Level 1 Power Strike must multiply the resolved critical weapon hit by x1.50.")

	assert(combat_simulator.create_session(hero_stats, passive_mob_stats).rage == 0, "Every new combat encounter must begin at 0 Rage.")

	var narrator: RefCounted = quest_narrator_script.new()
	var quest_definition: Resource = load("res://data/quests/0001_goblin_road_problem.tres")
	var narration: String = narrator.describe_combat_action(power_strike, hero_state.hero_name, quest_definition)
	assert(narration.contains("Мощный удар"), "The combat log must distinguish Power Strike from a normal attack.")

	print("PASS: Warrior Rage and autonomous Level 1 Power Strike follow the approved first-slice rules.")
	quit()

func make_stats(combat_stats_script: Script, max_hp: float, attack: float, attack_speed: float, crit_chance: float, accuracy: float, dodge: float) -> RefCounted:
	var stats: RefCounted = combat_stats_script.new()
	stats.max_hp = max_hp
	stats.attack = attack
	stats.attack_speed = attack_speed
	stats.crit_chance = crit_chance
	stats.crit_damage = 2.0
	stats.accuracy = accuracy
	stats.dodge = dodge
	return stats
