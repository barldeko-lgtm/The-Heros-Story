extends SceneTree

const CombatStatsScript = preload("res://scripts/model/runtime/combat_stats.gd")
const PowerCalculatorScript = preload("res://scripts/combat/power_calculator.gd")

func _init() -> void:
	var calculator = PowerCalculatorScript.new()
	var baseline = make_stats()
	baseline.max_hp = 100.0
	baseline.attack = 10.0
	baseline.attack_speed = 2.0
	assert(absf(calculator.calculate(baseline) - 31.622776602) < 0.0001, "Neutral Power must equal sqrt(100 EHP × 10 EffectiveDPS).")

	var reference = make_stats()
	reference.max_hp = 1000.0
	reference.armor = 100.0
	reference.dodge = 50.0
	reference.accuracy = 100.0
	reference.attack = 100.0
	reference.attack_speed = 1.0
	reference.crit_chance = 0.25
	reference.crit_damage = 2.0
	reference.fire_resistance = 100.0
	reference.cold_resistance = 100.0
	reference.lightning_resistance = 100.0
	assert(absf(calculator.calculate(reference) - 433.012701892) < 0.0001, "The approved fixed reference profile must have Power approximately 433.013.")

	var blocked_reference = copy_stats(reference)
	blocked_reference.block = 200.0
	assert(calculator.calculate(blocked_reference) > calculator.calculate(reference), "Block must increase Power through expected mitigation.")

	var duplicate_reference = copy_stats(reference)
	assert(is_equal_approx(calculator.calculate(reference), calculator.calculate(duplicate_reference)), "The same CombatStats must always produce the same shared Power for heroes and mobs.")

	print("PASS: Prototype 0.2 shared Power formula includes offense, mitigation, Dodge, Resistances, and Block.")
	quit()

func make_stats():
	var stats = CombatStatsScript.new()
	stats.max_hp = 1.0
	stats.attack = 0.0
	stats.attack_speed = 1.0
	stats.accuracy = 0.0
	stats.dodge = 0.0
	stats.armor = 0.0
	stats.fire_resistance = 0.0
	stats.cold_resistance = 0.0
	stats.lightning_resistance = 0.0
	stats.block = 0.0
	stats.crit_chance = 0.0
	stats.crit_damage = 1.5
	return stats

func copy_stats(source):
	var stats = make_stats()
	stats.max_hp = source.max_hp
	stats.attack = source.attack
	stats.attack_speed = source.attack_speed
	stats.accuracy = source.accuracy
	stats.dodge = source.dodge
	stats.armor = source.armor
	stats.fire_resistance = source.fire_resistance
	stats.cold_resistance = source.cold_resistance
	stats.lightning_resistance = source.lightning_resistance
	stats.block = source.block
	stats.crit_chance = source.crit_chance
	stats.crit_damage = source.crit_damage
	return stats
