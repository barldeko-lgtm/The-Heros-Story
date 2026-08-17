extends SceneTree

func _init() -> void:
	var goblin = load("res://data/mobs/0001_goblin.tres")
	assert(goblin != null, "Goblin definition must exist.")
	assert(goblin.id == "goblin", "Goblin ID must remain stable and semantic.")
	assert(goblin.display_name == "Гоблин", "Goblin display name must be Russian.")
	assert(goblin.category == 0, "Goblin must be classified as HUMANOID.")
	assert(is_equal_approx(goblin.max_hp, 50.0), "Goblin max HP must be 50.")
	assert(is_equal_approx(goblin.attack, 3.0), "Goblin attack must be 3.")
	assert(is_equal_approx(goblin.attack_speed, 1.0), "Goblin attack speed must be 1.0.")
	assert(is_equal_approx(goblin.crit_chance, 0.05), "Goblin crit chance must be 5%.")
	assert(is_equal_approx(goblin.crit_damage, 1.50), "Goblin crit damage must be 150%.")
	assert(goblin.experience_reward == 50, "Goblin XP reward must be 50.")
	assert(goblin.gold_reward == 2, "Goblin future gold reward must be 2.")
	assert(is_equal_approx(goblin.damage_reduction, 0.0), "Goblin damage reduction must be 0.")
	assert(goblin.get_power() < 21.45, "Goblin power must be below starting HeroPower.")

	print("PASS: Goblin definition contains approved stats and automatic power.")
	quit()
