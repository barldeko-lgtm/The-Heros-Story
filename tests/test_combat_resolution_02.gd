extends SceneTree

const CombatStatsScript = preload("res://scripts/model/runtime/combat_stats.gd")
const CombatSessionScript = preload("res://scripts/combat/combat_session.gd")

func _init() -> void:
	var attacker = make_stats()
	attacker.attack = 100.0
	attacker.attack_speed = 1.0
	var armored_target = make_stats()
	armored_target.max_hp = 1000.0
	armored_target.attack_speed = 0.01
	armored_target.armor = 100.0
	var armor_session = CombatSessionScript.new(attacker, armored_target, make_rng(1))
	var armor_actions: Array = armor_session.advance(1.5)
	assert(armor_actions.size() == 1, "The opening hero attack must resolve.")
	assert(armor_actions[0].did_hit, "Zero Dodge must not cause a miss.")
	assert(not armor_actions[0].was_blocked, "Zero Block must not block.")
	assert(is_equal_approx(armor_actions[0].damage, 50.0), "100 Armor must halve a physical combat hit.")

	var evasive_target = make_stats()
	evasive_target.max_hp = 1000.0
	evasive_target.attack_speed = 0.01
	evasive_target.dodge = 1000000.0
	var miss_session = CombatSessionScript.new(attacker, evasive_target, make_rng(find_seed_below(0.50)))
	var miss_actions: Array = miss_session.advance(1.5)
	assert(miss_actions.size() == 1, "A missed attack must still be recorded as one combat action.")
	assert(not miss_actions[0].did_hit, "The deterministic low roll must trigger Dodge at the 50 percent cap.")
	assert(is_equal_approx(miss_actions[0].damage, 0.0), "A missed attack must deal zero damage.")
	assert(not miss_actions[0].is_critical and not miss_actions[0].was_blocked, "A miss must not crit or trigger Block.")

	var blocking_target = make_stats()
	blocking_target.max_hp = 1000.0
	blocking_target.attack_speed = 0.01
	blocking_target.armor = 100.0
	blocking_target.block = 200.0
	var block_session = CombatSessionScript.new(attacker, blocking_target, make_rng(find_seed_below(0.50)))
	var block_actions: Array = block_session.advance(1.5)
	assert(block_actions.size() == 1 and block_actions[0].did_hit, "The block probe must receive a valid hit.")
	assert(block_actions[0].was_blocked, "The deterministic low roll must trigger Block at 50 percent chance.")
	assert(is_equal_approx(block_actions[0].damage, 12.5), "Block must leave 25 percent before 100 Armor halves the remainder.")

	print("PASS: Real combat uses Prototype 0.2 hit, Dodge, Block, and Armor formulas.")
	quit()

func make_stats():
	var stats = CombatStatsScript.new()
	stats.max_hp = 100.0
	stats.attack = 1.0
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

func make_rng(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng

func find_seed_below(threshold: float) -> int:
	for seed_value in range(1, 10000):
		var rng := make_rng(seed_value)
		if rng.randf() < threshold:
			return seed_value
	assert(false, "A deterministic seed below the requested threshold must exist.")
	return 1
