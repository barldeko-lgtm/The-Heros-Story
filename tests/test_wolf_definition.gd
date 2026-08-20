extends SceneTree

func _init() -> void:
	var goblin = load("res://data/mobs/0001_goblin.tres")
	var wolf = load("res://data/mobs/0002_wolf.tres")

	assert(goblin != null, "Goblin definition must exist for progression comparison.")
	assert(wolf != null, "Wolf definition must exist.")
	assert(wolf.id == "wolf", "Wolf ID must remain stable.")
	assert(wolf.display_name == "Волк", "Wolf display name must be Russian.")
	assert(wolf.category == MobDefinition.Category.MONSTER, "Wolf must be classified as MONSTER.")

	assert_valid_mob_stats(wolf)
	assert(wolf.experience_reward >= 0, "Wolf XP reward must not be negative.")
	assert(wolf.gold_reward >= 0, "Wolf auxiliary gold reward must not be negative.")
	assert(wolf.get_power() > goblin.get_power(), "Wolf must remain stronger than the Goblin in the current progression.")

	print("PASS: Wolf definition keeps valid combat data and remains above Goblin in progression.")
	quit()

func assert_valid_mob_stats(mob) -> void:
	assert(mob.max_hp > 0.0, "Mob MaxHP must be positive.")
	assert(mob.attack > 0.0, "Mob Attack must be positive.")
	assert(mob.attack_speed > 0.0, "Mob AttackSpeed must be positive.")
	assert(mob.crit_chance >= 0.0 and mob.crit_chance <= 1.0, "Mob CritChance must stay between 0 and 1.")
	assert(mob.crit_damage >= 1.0, "Mob CritDamage must be at least 1.0.")
	assert(mob.damage_reduction >= 0.0 and mob.damage_reduction < 1.0, "Mob DamageReduction must stay in [0, 1).")
