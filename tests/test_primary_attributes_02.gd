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
	assert(hero_state.strength == 6, "Pre-specialization Warrior level-up must grant exactly +1 fixed STR.")
	assert(hero_state.dexterity == 5, "DEX must wait for player allocation.")
	assert(hero_state.constitution == 5, "CON must wait for player allocation.")
	assert(hero_state.intelligence == 5, "Warrior level-up must not currently change INT.")
	assert(hero_state.wisdom == 5, "Warrior level-up must not currently change WIS.")
	assert(hero_state.pending_primary_attribute_points == 4, "Level-up must bank four player-distributed primary-attribute points.")

	var level_two_stats: RefCounted = stat_resolver.resolve(hero_state)
	assert(is_equal_approx(level_two_stats.max_hp, 200.0), "Unspent player points must not change MaxHP.")
	assert(is_equal_approx(level_two_stats.attack, 17.0), "Level 2 physical Damage must include only 6 STR before player allocation.")
	assert(is_equal_approx(level_two_stats.accuracy, 50.0), "Unspent DEX must not change Accuracy.")
	assert(is_equal_approx(level_two_stats.dodge, 10.0), "Unspent DEX must not change Dodge.")
	assert(is_equal_approx(level_two_stats.armor, 5.0), "Unspent CON must not change Armor.")
	assert(is_equal_approx(level_two_stats.crit_chance, 0.25), "Unspent DEX must not change Critical Chance.")
	assert(is_equal_approx(level_two_stats.crit_damage, 1.80), "Level 2 Critical Damage must include only 6 STR before player allocation.")

	assert(hero_progression.allocate_primary_attribute(hero_state, "intelligence"), "INT must be a valid player allocation target even before it has generic Warrior combat output.")
	assert(hero_progression.allocate_primary_attribute(hero_state, "wisdom"), "WIS must be a valid player allocation target.")
	assert(hero_state.intelligence == 6 and hero_state.wisdom == 6 and hero_state.pending_primary_attribute_points == 2, "Allocated points must move from the pending pool into the selected primary attributes.")

	print("PASS: Prototype 0.2 primary attributes and their current Warrior bonuses are resolved.")
	quit()
