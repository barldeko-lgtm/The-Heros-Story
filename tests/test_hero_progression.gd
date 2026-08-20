extends SceneTree

func _init() -> void:
	var hero_state_script: Script = load("res://scripts/hero/hero_state.gd")
	var hero_progression_script: Script = load("res://scripts/hero/hero_progression.gd")
	var stat_resolver_script: Script = load("res://scripts/hero/stat_resolver.gd")
	assert(hero_state_script != null, "HeroState script must exist.")
	assert(hero_progression_script != null, "HeroProgression script must exist.")
	assert(stat_resolver_script != null, "StatResolver script must exist.")

	var hero_state: RefCounted = hero_state_script.new("Тест")
	var hero_progression: RefCounted = hero_progression_script.new()
	var stat_resolver: RefCounted = stat_resolver_script.new()

	hero_state.experience = 950
	var levels_gained: int = hero_progression.add_experience(hero_state, 50)

	assert(levels_gained == 1, "Reaching 1000 XP must grant exactly one level.")
	assert(hero_state.level == 2, "The Warrior must reach level 2.")
	assert(hero_state.experience == 0, "Spent XP must be removed after level-up.")
	assert(hero_state.experience_to_next_level == 1500, "Level 2 must require 1500 XP for the next level.")
	assert(hero_state.strength == 6, "Each Warrior level must grant +4 Strength.")
	assert(hero_state.agility == 3, "Each Warrior level must grant +1 Agility.")
	assert(hero_state.intelligence == 2, "Warrior level-up must not change Intelligence.")

	var level_two_stats: RefCounted = stat_resolver.resolve(hero_state)
	assert(is_equal_approx(level_two_stats.max_hp, 150.0), "Level 2 Warrior MaxHP must be 150 after direct HP and Strength growth.")
	assert(is_equal_approx(level_two_stats.attack, 11.0), "Level 2 Warrior Attack must be 11.")
	assert(is_equal_approx(level_two_stats.attack_speed, 1.13), "Level 2 Warrior AttackSpeed must be 1.13.")
	assert(is_equal_approx(level_two_stats.crit_chance, 0.13), "Level 2 Warrior CritChance must be 13%.")
	assert(is_equal_approx(level_two_stats.crit_damage, 1.59), "Level 2 Warrior CritDamage must be 159%.")

	levels_gained = hero_progression.add_experience(hero_state, 3550)
	assert(levels_gained == 2, "Large XP rewards must support multiple level-ups.")
	assert(hero_state.level == 4, "Two more level-ups must reach level 4.")
	assert(hero_state.experience == 50, "Excess XP must carry over after multiple level-ups.")
	assert(hero_state.experience_to_next_level == 2500, "Level 4 must require 2500 XP for the next level.")

	print("PASS: HeroProgression owns XP, level-up, stat growth, and excess-XP carryover.")
	quit()
