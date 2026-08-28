extends SceneTree

const CombatStatsScript = preload("res://scripts/model/runtime/combat_stats.gd")
const CombatSessionScript = preload("res://scripts/combat/combat_session.gd")

func _init() -> void:
	var hero_stats = CombatStatsScript.new()
	hero_stats.max_hp = 100.0
	hero_stats.attack = 1.0
	hero_stats.attack_speed = 0.1
	hero_stats.crit_chance = 0.0
	hero_stats.crit_damage = 1.5
	hero_stats.armor = 100.0

	var mob_stats = CombatStatsScript.new()
	mob_stats.max_hp = 100.0
	mob_stats.attack = 10.0
	mob_stats.attack_speed = 1.0
	mob_stats.crit_chance = 0.0
	mob_stats.crit_damage = 1.5

	var session = CombatSessionScript.new(hero_stats, mob_stats)
	var actions: Array = session.advance(2.0)
	assert(actions.size() == 1 and actions[0].attacker_id == "mob", "The first resolved action must be the mob attack.")
	assert(is_equal_approx(actions[0].damage, 5.0), "100 Armor must reduce a 10-damage physical hit to 5.")
	assert(is_equal_approx(session.hero_remaining_hp, 95.0), "Mitigated incoming damage must be applied to live hero HP.")

	print("PASS: Armor damage reduction affects real combat damage.")
	quit()
