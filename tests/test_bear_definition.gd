extends SceneTree

const TARGET_POWER: float = 20.38
const POWER_TOLERANCE: float = 0.01

func _init() -> void:
	var bear = load("res://data/mobs/0003_bear.tres")
	assert(bear != null, "Bear definition must exist.")
	assert(bear.id == "bear", "Bear ID must remain stable.")
	assert(bear.display_name == "Медведь", "Bear display name must be Russian.")
	assert(bear.category == 1, "Bear must be MONSTER.")
	assert(is_equal_approx(bear.max_hp, 180.0), "Bear MaxHP must be 180.")
	assert(is_equal_approx(bear.attack, 5.0), "Bear Attack must be 5.")
	assert(is_equal_approx(bear.attack_speed, 0.90), "Bear AttackSpeed must be 0.90.")
	assert(is_equal_approx(bear.crit_chance, 0.05), "Bear CritChance must be 5%.")
	assert(is_equal_approx(bear.crit_damage, 1.50), "Bear CritDamage must be 150%.")
	assert(is_equal_approx(bear.damage_reduction, 0.0), "Bear DamageReduction must be 0.")
	assert(bear.experience_reward == 0, "Calibration Bear must not grant XP yet.")
	assert(absf(bear.get_power() - TARGET_POWER) < POWER_TOLERANCE, "Bear Power must stay approximately 20.38.")

	print("PASS: Bear stays at approximately 95% of starting HeroPower.")
	quit()
