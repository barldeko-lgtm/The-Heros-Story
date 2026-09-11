extends SceneTree

const HeroStateScript = preload("res://scripts/hero/hero_state.gd")
const CombatStatsScript = preload("res://scripts/model/runtime/combat_stats.gd")
const PowerCalculatorScript = preload("res://scripts/combat/power_calculator.gd")

func _init() -> void:
	var calculator = PowerCalculatorScript.new()
	var stats = make_stats()
	var hero = HeroStateScript.new("Тест")
	var base_power: float = calculator.calculate(stats)

	assert(is_equal_approx(calculator.calculate_hero(stats, hero), base_power), "Unlearned Warrior abilities must not change HeroPower.")

	hero.power_strike_skill_level = 1
	assert_ratio(calculator.calculate_hero(stats, hero), base_power, 1.04, "Power Strike SL1 must add 4.0% HeroPower.")
	hero.power_strike_skill_level = 2
	assert_ratio(calculator.calculate_hero(stats, hero), base_power, 1.0475, "Power Strike SL2 must add another 0.75% HeroPower.")

	hero.power_strike_skill_level = 0
	hero.battle_guard_skill_level = 1
	assert_ratio(calculator.calculate_hero(stats, hero), base_power, 1.045, "Battle Guard SL1 must add 4.5% HeroPower.")
	hero.battle_guard_skill_level = 2
	assert_ratio(calculator.calculate_hero(stats, hero), base_power, 1.049, "Battle Guard SL2 must add another 0.40% HeroPower.")

	hero.power_strike_skill_level = 2
	hero.battle_guard_skill_level = 1
	hero.wisdom = 5
	assert_ratio(calculator.calculate_hero(stats, hero), base_power, 1.0925, "PS2 + BG1 at WIS 5 must add the two approved skill bonuses only.")
	hero.wisdom = 20
	assert_ratio(calculator.calculate_hero(stats, hero), base_power, 1.1225, "With both base skills learned, WIS 20 must add 3.0% HeroPower above WIS 5.")

	hero.battle_guard_skill_level = 0
	assert_ratio(calculator.calculate_hero(stats, hero), base_power, 1.0475, "The provisional WIS HeroPower bonus must not apply until both base Warrior abilities are learned.")

	print("PASS: HeroPower applies approved Power Strike, Battle Guard, Skill Level, and provisional WIS valuation through the shared PowerCalculator.")
	quit()

func make_stats():
	var stats = CombatStatsScript.new()
	stats.max_hp = 1000.0
	stats.attack = 100.0
	stats.attack_speed = 1.0
	stats.accuracy = 100.0
	stats.dodge = 20.0
	stats.armor = 30.0
	stats.fire_resistance = 10.0
	stats.cold_resistance = 10.0
	stats.lightning_resistance = 10.0
	stats.block = 15.0
	stats.crit_chance = 0.15
	stats.crit_damage = 1.75
	return stats

func assert_ratio(actual_power: float, base_power: float, expected_ratio: float, message: String) -> void:
	assert(absf(actual_power / base_power - expected_ratio) < 0.000001, message)
