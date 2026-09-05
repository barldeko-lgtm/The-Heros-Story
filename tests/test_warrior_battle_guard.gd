extends SceneTree

const BATTLE_GUARD_ID := "battle_guard"

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
	hero_state.level = 9
	hero_state.power_strike_skill_level = 1
	hero_state.experience_to_next_level = hero_progression.get_experience_required_for_next_level(9)
	hero_progression.add_experience(hero_state, hero_state.experience_to_next_level)
	assert(hero_state.level == 10, "The setup must advance the Warrior to level 10.")
	assert(hero_state.battle_guard_skill_level == 1, "Reaching level 10 must learn Battle Guard at Skill Level 1.")

	var hero_stats: RefCounted = make_stats(combat_stats_script, 1000.0, 0.0, 0.01, 0.0)
	var mob_stats: RefCounted = make_stats(combat_stats_script, 1000.0, 100.0, 1.0, 0.0)
	var combat_simulator: RefCounted = combat_simulator_script.new()
	var session = combat_simulator.create_session(hero_stats, mob_stats, null, 1.0, 0, 5, hero_state.battle_guard_skill_level)
	session.hero_remaining_hp = 760.0
	session.rage = 50

	var threshold_actions: Array = session.advance(2.0)
	assert(threshold_actions.size() == 2, "The threshold hit must be followed by one Battle Guard activation event.")
	assert(threshold_actions[0].attacker_id == "mob", "The threshold-crossing hit must resolve before Battle Guard activates.")
	assert(is_equal_approx(threshold_actions[0].damage, 100.0), "The threshold-crossing hit must not be reduced retroactively.")
	assert(is_equal_approx(session.hero_remaining_hp, 660.0), "The full threshold hit must be applied before activation.")
	assert(threshold_actions[1].action_id == BATTLE_GUARD_ID, "Battle Guard activation must be a distinct structured combat action.")
	assert(session.is_battle_guard_active(), "Battle Guard must become active immediately after the threshold-crossing hit.")
	assert(session.rage == 53, "Battle Guard must spend no Rage while the received hit still grants 3 Rage.")

	var protected_actions: Array = session.advance(2.0)
	assert(protected_actions.size() == 1 and protected_actions[0].attacker_id == "mob", "The next incoming hit must resolve while Battle Guard is active.")
	assert(is_equal_approx(protected_actions[0].damage, 75.0), "Skill Level 1 Battle Guard at starting Wisdom must reduce remaining incoming damage by 25%.")
	assert(is_equal_approx(session.hero_remaining_hp, 585.0), "Only the post-mitigation Battle Guard damage must reach HP.")

	session.advance(10.0)
	assert(not session.is_battle_guard_active(), "Battle Guard must expire after 10 seconds.")
	var cooldown_actions: Array = session.advance(2.0)
	var last_mob_action = find_last_mob_action(cooldown_actions)
	assert(last_mob_action != null and is_equal_approx(last_mob_action.damage, 100.0), "Expired Battle Guard must not reduce damage while its 60-second cooldown remains active.")
	assert(not has_action(cooldown_actions, BATTLE_GUARD_ID), "Battle Guard must not reactivate before its 60-second cooldown is ready.")

	var wise_session = combat_simulator.create_session(hero_stats, mob_stats, null, 1.0, 0, 105, 1)
	wise_session.hero_remaining_hp = 760.0
	wise_session.advance(2.0)
	var wise_protected_actions: Array = wise_session.advance(2.0)
	assert(is_equal_approx(wise_protected_actions[0].damage, 67.5), "105 Wisdom must raise Battle Guard reduction from 25% to 32.5%.")

	var locked_session = combat_simulator.create_session(hero_stats, mob_stats, null, 1.0, 0, 105, 0)
	locked_session.hero_remaining_hp = 760.0
	var locked_actions: Array = locked_session.advance(4.0)
	assert(not has_action(locked_actions, BATTLE_GUARD_ID), "Battle Guard must remain unavailable before it is learned.")
	assert(is_equal_approx(locked_session.hero_remaining_hp, 560.0), "A Warrior without Battle Guard must take both incoming hits in full.")

	var narrator: RefCounted = quest_narrator_script.new()
	var quest_definition: Resource = load("res://data/quests/0001_goblin_road_problem.tres")
	var narration: String = narrator.describe_combat_action(threshold_actions[1], hero_state.hero_name, quest_definition)
	assert(narration.contains("Боевой заслон"), "The combat log must name Battle Guard activation separately.")

	print("PASS: Autonomous Level 1 Battle Guard follows the approved threshold, duration, cooldown, mitigation, and Wisdom rules.")
	quit()

func make_stats(combat_stats_script: Script, max_hp: float, attack: float, attack_speed: float, armor: float) -> RefCounted:
	var stats: RefCounted = combat_stats_script.new()
	stats.max_hp = max_hp
	stats.attack = attack
	stats.attack_speed = attack_speed
	stats.accuracy = 100.0
	stats.armor = armor
	stats.crit_chance = 0.0
	stats.crit_damage = 2.0
	return stats

func has_action(actions: Array, action_id: String) -> bool:
	for action in actions:
		if action.action_id == action_id:
			return true
	return false

func find_last_mob_action(actions: Array):
	for index in range(actions.size() - 1, -1, -1):
		if actions[index].attacker_id == "mob":
			return actions[index]
	return null
