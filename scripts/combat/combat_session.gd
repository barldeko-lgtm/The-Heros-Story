class_name CombatSession
extends RefCounted

const CombatActionScript = preload("res://scripts/combat/combat_action.gd")
const CombatResultScript = preload("res://scripts/combat/combat_result.gd")
const DamageResolverScript = preload("res://scripts/combat/damage_resolver.gd")
const HERO_OPENING_ADVANTAGE_SECONDS: float = 0.5
const TIME_EPSILON: float = 0.000001
const FALLBACK_SEED: int = 1
const NORMAL_ATTACK_ID := "normal_attack"
const POWER_STRIKE_ID := "power_strike"
const BATTLE_GUARD_ID := "battle_guard"
const MAX_RAGE: int = 100
const NORMAL_HIT_RAGE: int = 5
const CRITICAL_HIT_RAGE: int = 7
const RECEIVED_HIT_RAGE: int = 3
const POWER_STRIKE_RAGE_COST: int = 30
const POWER_STRIKE_COOLDOWN_SECONDS: float = 10.0
const POWER_STRIKE_BASE_MULTIPLIER: float = 1.5
const POWER_STRIKE_WISDOM_COEFFICIENT: float = 2.0
const BATTLE_GUARD_HP_THRESHOLD: float = 0.75
const BATTLE_GUARD_DURATION_SECONDS: float = 10.0
const BATTLE_GUARD_COOLDOWN_SECONDS: float = 60.0
const BATTLE_GUARD_BASE_REDUCTION: float = 0.25
const BATTLE_GUARD_WISDOM_COEFFICIENT: float = 0.15
const BASE_WISDOM: int = 5

var hero_stats: CombatStats
var mob_stats: CombatStats
var random_number_generator: RandomNumberGenerator
var hero_damage_multiplier: float = 1.0
var hero_remaining_hp: float
var mob_remaining_hp: float
var hero_attack_interval: float
var mob_attack_interval: float
var hero_next_attack_time: float
var mob_next_attack_time: float
var elapsed_seconds: float = 0.0
var is_finished: bool = false
var actions: Array = []
var rage: int = 0
var power_strike_skill_level: int = 0
var hero_wisdom: int = BASE_WISDOM
var power_strike_ready_time: float = 0.0
var battle_guard_skill_level: int = 0
var battle_guard_active_until: float = 0.0
var battle_guard_ready_time: float = 0.0

func _init(initial_hero_stats: CombatStats, initial_mob_stats: CombatStats, initial_random_number_generator: RandomNumberGenerator = null, initial_hero_damage_multiplier: float = 1.0, initial_power_strike_skill_level: int = 0, initial_hero_wisdom: int = BASE_WISDOM, initial_battle_guard_skill_level: int = 0) -> void:
	assert(initial_hero_stats.attack_speed > 0.0, "Hero attack speed must be positive.")
	assert(initial_mob_stats.attack_speed > 0.0, "Mob attack speed must be positive.")
	hero_stats = initial_hero_stats
	mob_stats = initial_mob_stats
	hero_damage_multiplier = initial_hero_damage_multiplier
	assert(hero_damage_multiplier > 0.0, "Hero damage multiplier must be positive.")
	assert(initial_power_strike_skill_level == 0 or initial_power_strike_skill_level == 1, "The current slice supports only locked or Skill Level 1 Power Strike.")
	assert(initial_battle_guard_skill_level == 0 or initial_battle_guard_skill_level == 1, "The current slice supports only locked or Skill Level 1 Battle Guard.")
	power_strike_skill_level = initial_power_strike_skill_level
	hero_wisdom = initial_hero_wisdom
	battle_guard_skill_level = initial_battle_guard_skill_level
	random_number_generator = initial_random_number_generator
	if random_number_generator == null:
		random_number_generator = RandomNumberGenerator.new()
		random_number_generator.seed = FALLBACK_SEED
	hero_remaining_hp = hero_stats.max_hp
	mob_remaining_hp = mob_stats.max_hp
	hero_attack_interval = 2.0 / hero_stats.attack_speed
	mob_attack_interval = 2.0 / mob_stats.attack_speed
	hero_next_attack_time = maxf(0.0, hero_attack_interval - HERO_OPENING_ADVANTAGE_SECONDS)
	mob_next_attack_time = mob_attack_interval

func advance(delta_seconds: float) -> Array:
	if is_finished:
		return []

	var resolved_actions: Array = []
	var target_time := elapsed_seconds + maxf(0.0, delta_seconds)
	while not is_finished:
		var next_action_time := minf(hero_next_attack_time, mob_next_attack_time)
		if next_action_time > target_time + TIME_EPSILON:
			break
		elapsed_seconds = next_action_time
		try_activate_battle_guard(resolved_actions)
		var hero_attacks_now := is_equal_approx(hero_next_attack_time, next_action_time)
		var mob_attacks_now := is_equal_approx(mob_next_attack_time, next_action_time)
		var hero_damage := 0.0
		var mob_damage := 0.0

		if hero_attacks_now:
			var uses_power_strike := can_use_power_strike()
			var attack_multiplier := hero_damage_multiplier
			var action_id := NORMAL_ATTACK_ID
			if uses_power_strike:
				rage -= POWER_STRIKE_RAGE_COST
				power_strike_ready_time = elapsed_seconds + POWER_STRIKE_COOLDOWN_SECONDS
				attack_multiplier *= get_power_strike_multiplier()
				action_id = POWER_STRIKE_ID
			var hero_hit = create_hit("hero", hero_stats, mob_stats, attack_multiplier, uses_power_strike, action_id)
			hero_hit.time_seconds = elapsed_seconds
			actions.append(hero_hit)
			resolved_actions.append(hero_hit)
			hero_damage = hero_hit.damage
			if not uses_power_strike and hero_hit.did_hit:
				add_rage(CRITICAL_HIT_RAGE if hero_hit.is_critical else NORMAL_HIT_RAGE)
			hero_next_attack_time += hero_attack_interval
		if mob_attacks_now:
			var mob_hit = create_hit("mob", mob_stats, hero_stats)
			if mob_hit.did_hit and is_battle_guard_active():
				mob_hit.damage *= get_battle_guard_multiplier()
			mob_hit.time_seconds = elapsed_seconds
			actions.append(mob_hit)
			resolved_actions.append(mob_hit)
			mob_damage = mob_hit.damage
			if mob_hit.did_hit:
				add_rage(RECEIVED_HIT_RAGE)
			mob_next_attack_time += mob_attack_interval

		mob_remaining_hp -= hero_damage
		hero_remaining_hp -= mob_damage
		is_finished = hero_remaining_hp <= 0.0 or mob_remaining_hp <= 0.0
		if not is_finished:
			try_activate_battle_guard(resolved_actions)

	if not is_finished:
		elapsed_seconds = target_time
	return resolved_actions

func get_result():
	return CombatResultScript.new(hero_remaining_hp > 0.0, hero_remaining_hp, mob_remaining_hp, elapsed_seconds, actions)

func create_hit(attacker_id: String, attacker_stats: CombatStats, target_stats: CombatStats, damage_multiplier: float = 1.0, guaranteed_hit: bool = false, action_id: String = NORMAL_ATTACK_ID):
	var dodge_chance := DamageResolverScript.calculate_dodge_chance(attacker_stats.accuracy, target_stats.dodge)
	if not guaranteed_hit and dodge_chance > 0.0 and random_number_generator.randf() < dodge_chance:
		return CombatActionScript.new(attacker_id, 0.0, 0.0, false, false, false, DamageResolverScript.DAMAGE_TYPE_PHYSICAL, action_id)
	var is_critical := attacker_stats.crit_chance > 0.0 and random_number_generator.randf() < attacker_stats.crit_chance
	var damage := attacker_stats.attack
	if is_critical:
		damage *= attacker_stats.crit_damage
	damage *= damage_multiplier
	var block_chance := DamageResolverScript.calculate_block_chance(target_stats.block)
	var was_blocked := block_chance > 0.0 and random_number_generator.randf() < block_chance
	damage = DamageResolverScript.calculate_mitigated_damage(
		damage,
		DamageResolverScript.DAMAGE_TYPE_PHYSICAL,
		target_stats.armor,
		0.0,
		was_blocked
	)
	return CombatActionScript.new(attacker_id, 0.0, damage, is_critical, true, was_blocked, DamageResolverScript.DAMAGE_TYPE_PHYSICAL, action_id)

func can_use_power_strike() -> bool:
	return power_strike_skill_level == 1 and rage >= POWER_STRIKE_RAGE_COST and elapsed_seconds + TIME_EPSILON >= power_strike_ready_time

func get_power_strike_multiplier() -> float:
	var effective_wisdom := maxi(0, hero_wisdom - BASE_WISDOM)
	var wisdom_factor := float(effective_wisdom) / float(effective_wisdom + 100)
	return POWER_STRIKE_BASE_MULTIPLIER + POWER_STRIKE_WISDOM_COEFFICIENT * wisdom_factor

func add_rage(amount: int) -> void:
	rage = mini(MAX_RAGE, rage + amount)

func is_battle_guard_active() -> bool:
	return battle_guard_skill_level == 1 and elapsed_seconds < battle_guard_active_until - TIME_EPSILON

func get_battle_guard_multiplier() -> float:
	var effective_wisdom := maxi(0, hero_wisdom - BASE_WISDOM)
	var wisdom_factor := float(effective_wisdom) / float(effective_wisdom + 100)
	var damage_reduction := BATTLE_GUARD_BASE_REDUCTION + BATTLE_GUARD_WISDOM_COEFFICIENT * wisdom_factor
	return 1.0 - damage_reduction

func try_activate_battle_guard(resolved_actions: Array) -> void:
	if battle_guard_skill_level != 1 or is_battle_guard_active():
		return
	if elapsed_seconds + TIME_EPSILON < battle_guard_ready_time:
		return
	if hero_remaining_hp > hero_stats.max_hp * BATTLE_GUARD_HP_THRESHOLD + TIME_EPSILON:
		return
	battle_guard_active_until = elapsed_seconds + BATTLE_GUARD_DURATION_SECONDS
	battle_guard_ready_time = elapsed_seconds + BATTLE_GUARD_COOLDOWN_SECONDS
	var activation = CombatActionScript.new("hero", elapsed_seconds, 0.0, false, true, false, DamageResolverScript.DAMAGE_TYPE_PHYSICAL, BATTLE_GUARD_ID)
	actions.append(activation)
	resolved_actions.append(activation)
