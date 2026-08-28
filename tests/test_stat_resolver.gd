extends SceneTree

func _init() -> void:
	var hero_state_script: Script = load("res://scripts/hero/hero_state.gd")
	var stat_resolver_script: Script = load("res://scripts/hero/stat_resolver.gd")
	var power_calculator_script: Script = load("res://scripts/combat/power_calculator.gd")
	assert(hero_state_script != null, "HeroState script must exist.")
	assert(stat_resolver_script != null, "StatResolver script must exist.")
	assert(power_calculator_script != null, "PowerCalculator script must exist.")

	var hero_state: RefCounted = hero_state_script.new("Тест")
	var stat_resolver: RefCounted = stat_resolver_script.new()
	var power_calculator: RefCounted = power_calculator_script.new()
	var combat_stats: RefCounted = stat_resolver.resolve(hero_state)

	assert(is_equal_approx(combat_stats.max_hp, 200.0), "Starting Warrior max HP must be 200.")
	assert(is_equal_approx(combat_stats.attack, 15.0), "Starting Warrior physical Damage must be 15.")
	assert(is_equal_approx(combat_stats.attack_speed, 1.10), "Starting Warrior attack speed must be 1.10.")
	assert(is_equal_approx(combat_stats.accuracy, 50.0), "Starting Warrior Accuracy must be 50.")
	assert(is_equal_approx(combat_stats.dodge, 10.0), "Starting Warrior Dodge must be 10.")
	assert(is_equal_approx(combat_stats.armor, 5.0), "Starting Warrior Armor must be 5.")
	assert(is_equal_approx(combat_stats.crit_chance, 0.25), "Starting Warrior crit chance must be 25%.")
	assert(is_equal_approx(combat_stats.crit_damage, 1.75), "Starting Warrior crit damage must be 175%.")
	assert(absf(power_calculator.calculate(combat_stats) - 48.93) < 0.01, "Prototype 0.2 Power must reflect all resolved starting stats.")

	print("PASS: StatResolver and PowerCalculator calculate starting Warrior stats.")
	quit()
