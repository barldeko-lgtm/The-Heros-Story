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
	assert(hero_state.strength == 6, "Each Warrior level must automatically grant exactly +1 Strength.")
	assert(hero_state.dexterity == 5, "Player-guided Dexterity must not be assigned automatically.")
	assert(hero_state.constitution == 5, "Player-guided Constitution must not be assigned automatically.")
	assert(hero_state.intelligence == 5, "Warrior level-up must not currently change Intelligence.")
	assert(hero_state.wisdom == 5, "Warrior level-up must not currently change Wisdom.")
	assert(hero_state.pending_primary_attribute_points == 4, "Each gained level must add four pending player-distributed primary-attribute points.")

	var level_two_stats: RefCounted = stat_resolver.resolve(hero_state)
	assert(is_equal_approx(level_two_stats.max_hp, 200.0), "Pending points must provide no MaxHP before the player spends them.")
	assert(is_equal_approx(level_two_stats.attack, 17.0), "Level 2 physical Damage must include only the fixed +1 Warrior Strength before player allocation.")
	assert(is_equal_approx(level_two_stats.attack_speed, 1.10), "Primary attributes must not change AttackSpeed.")
	assert(is_equal_approx(level_two_stats.crit_chance, 0.25), "Pending Dexterity must provide no Critical Chance before allocation.")
	assert(is_equal_approx(level_two_stats.crit_damage, 1.80), "Level 2 Critical Damage must include only the fixed +1 Warrior Strength before allocation.")

	assert(hero_progression.allocate_primary_attribute(hero_state, "constitution"), "A pending point must be spendable on Constitution.")
	assert(hero_progression.allocate_primary_attribute(hero_state, "wisdom"), "A pending point must be spendable on Wisdom.")
	assert(hero_progression.allocate_primary_attribute(hero_state, "strength"), "A pending point must be spendable on Strength.")
	assert(hero_progression.allocate_primary_attribute(hero_state, "dexterity"), "A pending point must be spendable on Dexterity.")
	assert(hero_state.pending_primary_attribute_points == 0, "Spending all four points must empty the pending pool.")
	assert(not hero_progression.allocate_primary_attribute(hero_state, "intelligence"), "No attribute may increase when no pending points remain.")

	levels_gained = hero_progression.add_experience(hero_state, 3550)
	assert(levels_gained == 2, "Large XP rewards must support multiple level-ups.")
	assert(hero_state.level == 4, "Two more level-ups must reach level 4.")
	assert(hero_state.experience == 50, "Excess XP must carry over after multiple level-ups.")
	assert(hero_state.experience_to_next_level == 2500, "Level 4 must require 2500 XP for the next level.")
	assert(hero_state.strength == 9, "Two later levels must add only their fixed Warrior Strength before player spending.")
	assert(hero_state.pending_primary_attribute_points == 8, "Two later levels must add eight new pending player points.")

	print("PASS: HeroProgression grants fixed Warrior Strength, stores four pending player points per level, and supports explicit allocation.")
	quit()
