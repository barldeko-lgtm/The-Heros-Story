extends SceneTree

const TARGET_POWER: float = 20.38
const POWER_TOLERANCE: float = 0.01

func _init() -> void:
	var wolf = load("res://data/mobs/0002_wolf.tres")
	assert(wolf != null, "Wolf definition must exist.")
	assert(wolf.id == "wolf", "Wolf ID must remain stable.")
	assert(wolf.display_name == "Волк", "Wolf display name must be Russian.")
	assert(wolf.category == 1, "Wolf must be MONSTER.")
	assert(is_equal_approx(wolf.max_hp, 72.55), "Wolf MaxHP must be 72.55.")
	assert(is_equal_approx(wolf.attack, 8.0), "Wolf Attack must be 8.")
	assert(is_equal_approx(wolf.attack_speed, 1.35), "Wolf AttackSpeed must be 1.35.")
	assert(is_equal_approx(wolf.crit_chance, 0.12), "Wolf CritChance must be 12%.")
	assert(is_equal_approx(wolf.crit_damage, 1.50), "Wolf CritDamage must be 150%.")
	assert(wolf.experience_reward == 0, "Calibration Wolf must not grant XP yet.")
	assert(absf(wolf.get_power() - TARGET_POWER) < POWER_TOLERANCE, "Wolf Power must stay approximately 21.40.")

	print("PASS: Wolf definition stays at approximately 20.38 Power (95% of starting HeroPower).")
	quit()
