extends SceneTree

func _init() -> void:
	var goblin = load("res://data/mobs/0001_goblin.tres")
	assert(goblin != null, "Goblin definition must exist.")
	assert(goblin.id == "goblin", "Goblin ID must remain stable and semantic.")
	assert(goblin.display_name == "Гоблин", "Goblin display name must be Russian.")
	assert(goblin.category == MobDefinition.Category.HUMANOID, "Goblin must be classified as HUMANOID.")

	assert_valid_mob_stats(goblin)
	assert(goblin.experience_reward >= 0, "Goblin XP reward must not be negative.")
	assert(goblin.gold_reward >= 0, "Goblin auxiliary gold reward must not be negative.")
	assert(goblin.get_power() > 0.0, "Goblin Power must be positive.")

	print("PASS: Goblin definition keeps its stable identity and valid combat data.")
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
