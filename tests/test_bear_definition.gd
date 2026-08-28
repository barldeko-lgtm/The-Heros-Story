extends SceneTree

func _init() -> void:
	var wolf = load("res://data/mobs/0002_wolf.tres")
	var bear = load("res://data/mobs/0003_bear.tres")

	assert(wolf != null, "Wolf definition must exist for progression comparison.")
	assert(bear != null, "Bear definition must exist.")
	assert(bear.id == "bear", "Bear ID must remain stable.")
	assert(bear.display_name == "Медведь", "Bear display name must be Russian.")
	assert(bear.category == MobDefinition.Category.MONSTER, "Bear must be classified as MONSTER.")

	assert_valid_mob_stats(bear)
	assert(bear.experience_reward >= 0, "Bear XP reward must not be negative.")
	assert(bear.gold_reward >= 0, "Bear auxiliary gold reward must not be negative.")
	assert(bear.get_power() > wolf.get_power(), "Bear must remain stronger than the Wolf in the current progression.")

	print("PASS: Bear definition keeps valid combat data and remains above Wolf in progression.")
	quit()

func assert_valid_mob_stats(mob) -> void:
	assert(mob.max_hp > 0.0, "Mob MaxHP must be positive.")
	assert(mob.attack > 0.0, "Mob Attack must be positive.")
	assert(mob.attack_speed > 0.0, "Mob AttackSpeed must be positive.")
	assert(mob.crit_chance >= 0.0 and mob.crit_chance <= 1.0, "Mob CritChance must stay between 0 and 1.")
	assert(mob.crit_damage >= 1.0, "Mob CritDamage must be at least 1.0.")
	assert(mob.accuracy >= 0.0 and mob.dodge >= 0.0 and mob.armor >= 0.0, "Mob Accuracy, Dodge, and Armor must not be negative.")
	assert(mob.fire_resistance >= 0.0 and mob.cold_resistance >= 0.0 and mob.lightning_resistance >= 0.0, "Mob Resistances must not be negative.")
	assert(mob.block >= 0.0, "Mob Block must not be negative.")
