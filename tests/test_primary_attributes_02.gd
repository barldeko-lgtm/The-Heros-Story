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

	assert(hero_state.strength == 5, "Prototype 0.2 Warrior must start with 5 STR.")
	assert(hero_state.dexterity == 5, "Prototype 0.2 Warrior must start with 5 DEX.")
	assert(hero_state.intelligence == 5, "Prototype 0.2 Warrior must start with 5 INT.")
	assert(hero_state.constitution == 5, "Prototype 0.2 Warrior must start with 5 CON.")
	assert(hero_state.wisdom == 5, "Prototype 0.2 Warrior must start with 5 WIS.")

	var starting_stats: RefCounted = stat_resolver.resolve(hero_state)
	assert(is_equal_approx(starting_stats.max_hp, 200.0), "5 CON must add 100 MaxHP to the 100 base MaxHP.")
	assert(is_equal_approx(starting_stats.attack, 15.0), "5 STR must add 10 physical Damage to the 5 base Damage.")
	assert(is_equal_approx(starting_stats.accuracy, 50.0), "5 DEX must add 50 Accuracy.")
	assert(is_equal_approx(starting_stats.dodge, 10.0), "5 DEX must add 10 Dodge.")
	assert(is_equal_approx(starting_stats.armor, 5.0), "5 CON must add 5 Armor.")
	assert(is_equal_approx(starting_stats.attack_speed, 1.10), "Primary attributes must not change Attack Speed.")
	assert(is_equal_approx(starting_stats.crit_chance, 0.25), "5 DEX must add 15 percentage points of Critical Chance.")
	assert(is_equal_approx(starting_stats.crit_damage, 1.75), "5 STR must add 25 percentage points of Critical Damage.")

	hero_progression.apply_level_up(hero_state)
	assert(hero_state.strength == 7, "Pre-specialization Warrior level-up must currently grant +2 STR.")
	assert(hero_state.dexterity == 6, "Pre-specialization Warrior level-up must currently grant +1 DEX.")
	assert(hero_state.constitution == 6, "Pre-specialization Warrior level-up must currently grant +1 CON.")
	assert(hero_state.intelligence == 5, "Warrior level-up must not currently change INT.")
	assert(hero_state.wisdom == 5, "Warrior level-up must not currently change WIS.")

	var level_two_stats: RefCounted = stat_resolver.resolve(hero_state)
	assert(is_equal_approx(level_two_stats.max_hp, 220.0), "Level 2 MaxHP must come from 6 CON without the removed direct HP bonus.")
	assert(is_equal_approx(level_two_stats.attack, 19.0), "Level 2 physical Damage must include 7 STR.")
	assert(is_equal_approx(level_two_stats.accuracy, 60.0), "Level 2 Accuracy must include 6 DEX.")
	assert(is_equal_approx(level_two_stats.dodge, 12.0), "Level 2 Dodge must include 6 DEX.")
	assert(is_equal_approx(level_two_stats.armor, 6.0), "Level 2 Armor must include 6 CON.")
	assert(is_equal_approx(level_two_stats.crit_chance, 0.28), "Level 2 Critical Chance must include 6 DEX.")
	assert(is_equal_approx(level_two_stats.crit_damage, 1.85), "Level 2 Critical Damage must include 7 STR.")

	print("PASS: Prototype 0.2 primary attributes and their current Warrior bonuses are resolved.")
	quit()
