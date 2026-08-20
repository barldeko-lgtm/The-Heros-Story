extends SceneTree

const HeroTraitsScript = preload("res://scripts/hero/hero_traits.gd")
const MobDefinitionScript = preload("res://scripts/model/definitions/mob_definition.gd")
const CombatSimulatorScript = preload("res://scripts/combat/combat_simulator.gd")
const CombatStatsScript = preload("res://scripts/model/runtime/combat_stats.gd")

func _init() -> void:
	assert(is_equal_approx(HeroTraitsScript.get_damage_multiplier([HeroTraitsScript.NOBLE], MobDefinitionScript.Category.MONSTER), 1.10), "Noble must deal 10% more damage to Monsters.")
	assert(is_equal_approx(HeroTraitsScript.get_damage_multiplier([HeroTraitsScript.NOBLE], MobDefinitionScript.Category.HUMANOID), 1.0), "Noble must not gain damage against Humanoids.")
	assert(is_equal_approx(HeroTraitsScript.get_damage_multiplier([HeroTraitsScript.DISHONORABLE], MobDefinitionScript.Category.HUMANOID), 1.10), "Dishonorable must deal 10% more damage to Humanoids.")
	assert(is_equal_approx(HeroTraitsScript.get_damage_multiplier([HeroTraitsScript.DISHONORABLE], MobDefinitionScript.Category.MONSTER), 1.0), "Dishonorable must not gain damage against Monsters.")

	var hero_stats = CombatStatsScript.new()
	hero_stats.max_hp = 100.0
	hero_stats.attack = 10.0
	hero_stats.attack_speed = 1.0
	hero_stats.crit_chance = 0.0

	var mob_stats = CombatStatsScript.new()
	mob_stats.max_hp = 100.0
	mob_stats.attack = 1.0
	mob_stats.attack_speed = 1.0
	mob_stats.crit_chance = 0.0

	var session = CombatSimulatorScript.new().create_session(hero_stats, mob_stats, null, 1.10)
	var actions = session.advance(1.5)
	assert(actions.size() == 1 and actions[0].attacker_id == "hero", "The first deterministic action must be the hero strike.")
	assert(is_equal_approx(actions[0].damage, 11.0), "The doubled trait multiplier must affect actual combat damage.")

	print("PASS: Noble and Dishonorable category bonuses apply 10% actual combat damage.")
	quit()
