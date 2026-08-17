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

	assert(is_equal_approx(combat_stats.max_hp, 110.0), "Starting Warrior max HP must be 110.")
	assert(is_equal_approx(combat_stats.attack, 7.0), "Starting Warrior attack must be 7.")
	assert(is_equal_approx(combat_stats.attack_speed, 1.12), "Starting Warrior attack speed must be 1.12.")
	assert(is_equal_approx(combat_stats.crit_chance, 0.12), "Starting Warrior crit chance must be 12%.")
	assert(is_equal_approx(combat_stats.crit_damage, 1.56), "Starting Warrior crit damage must be 156%.")
	assert(absf(power_calculator.calculate(combat_stats) - 21.45) < 0.01, "Starting Warrior power must be approximately 21.45.")

	print("PASS: StatResolver and PowerCalculator calculate starting Warrior stats.")
	quit()
