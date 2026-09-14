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
const SHIELD_BASH_ID := "shield_bash"
const CRIPPLING_BLOWS_ID := "crippling_blows"
const MAX_RAGE: int = 100
const NORMAL_HIT_RAGE: int = 5
const CRITICAL_HIT_RAGE: int = 7
const RECEIVED_HIT_RAGE: int = 3
const POWER_STRIKE_RAGE_COST: int = 30
const POWER_STRIKE_COOLDOWN_SECONDS: float = 10.0
const MAX_SKILL_LEVEL: int = 10
const POWER_STRIKE_MIN_MULTIPLIER: float = 1.5
const POWER_STRIKE_MAX_MULTIPLIER: float = 2.5
const POWER_STRIKE_WISDOM_COEFFICIENT: float = 2.5
const BATTLE_GUARD_HP_THRESHOLD: float = 0.80
const BATTLE_GUARD_DURATION_SECONDS: float = 10.0
const BATTLE_GUARD_COOLDOWN_SECONDS: float = 60.0
const BATTLE_GUARD_MIN_REDUCTION: float = 0.25
const BATTLE_GUARD_MAX_REDUCTION: float = 0.45
const BATTLE_GUARD_WISDOM_COEFFICIENT: float = 0.30
const SHIELD_BASH_RAGE_COST: int = 15
const SHIELD_BASH_COOLDOWN_SECONDS: float = 60.0
const SHIELD_BASH_MIN_STUN_SECONDS: float = 5.0
const SHIELD_BASH_MAX_STUN_SECONDS: float = 7.0
const SHIELD_BASH_WISDOM_COEFFICIENT: float = 2.0
const CRIPPLING_BLOWS_RAGE_COST: int = 15
const CRIPPLING_BLOWS_COOLDOWN_SECONDS: float = 60.0
const CRIPPLING_BLOWS_BASE_DAMAGE_MULTIPLIER: float = 0.75
const CRIPPLING_BLOWS_RANK_DAMAGE_MULTIPLIER_BONUS: float = 0.005
const CRIPPLING_BLOWS_WISDOM_DAMAGE_COEFFICIENT: float = 0.03
const CRIPPLING_BLOWS_DURATION_SECONDS: float = 10.0
const CRIPPLING_BLOWS_MIN_ATTACK_SPEED_REDUCTION: float = 0.25
const CRIPPLING_BLOWS_MAX_ATTACK_SPEED_REDUCTION: float = 0.40
const CRIPPLING_BLOWS_WISDOM_COEFFICIENT: float = 0.15
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
var shield_bash_skill_level: int = 0
var shield_bash_ready_time: float = 0.0
var crippling_blows_skill_level: int = 0
var crippling_blows_ready_time: float = 0.0
var hero_has_shield: bool = false
var crippling_slow_active_until: float = 0.0
var crippling_slow_reduction: float = 0.0

func _init(initial_hero_stats: CombatStats, initial_mob_stats: CombatStats, initial_random_number_generator: RandomNumberGenerator = null, initial_hero_damage_multiplier: float = 1.0, initial_power_strike_skill_level: int = 0, initial_hero_wisdom: int = BASE_WISDOM, initial_battle_guard_skill_level: int = 0, initial_shield_bash_skill_level: int = 0, initial_crippling_blows_skill_level: int = 0, initial_hero_has_shield: bool = false) -> void:
	assert(initial_hero_stats.attack_speed > 0.0, "Hero attack speed must be positive.")
	assert(initial_mob_stats.attack_speed > 0.0, "Mob attack speed must be positive.")
	hero_stats = initial_hero_stats
	mob_stats = initial_mob_stats
	hero_damage_multiplier = initial_hero_damage_multiplier
	assert(hero_damage_multiplier > 0.0, "Hero damage multiplier must be positive.")
	assert(initial_power_strike_skill_level >= 0 and initial_power_strike_skill_level <= MAX_SKILL_LEVEL, "Power Strike Skill Level must be between 0 and 10.")
	assert(initial_battle_guard_skill_level >= 0 and initial_battle_guard_skill_level <= MAX_SKILL_LEVEL, "Battle Guard Skill Level must be between 0 and 10.")
	assert(initial_shield_bash_skill_level >= 0 and initial_shield_bash_skill_level <= MAX_SKILL_LEVEL, "Shield Bash Skill Level must be between 0 and 10.")
	assert(initial_crippling_blows_skill_level >= 0 and initial_crippling_blows_skill_level <= MAX_SKILL_LEVEL, "Crippling Blows Skill Level must be between 0 and 10.")
	power_strike_skill_level = initial_power_strike_skill_level
	hero_wisdom = initial_hero_wisdom
	battle_guard_skill_level = initial_battle_guard_skill_level
	shield_bash_skill_level = initial_shield_bash_skill_level
	crippling_blows_skill_level = initial_crippling_blows_skill_level
	hero_has_shield = initial_hero_has_shield
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

func advance(delta_seconds: float, mob_damage_type: String = DamageResolverScript.DAMAGE_TYPE_PHYSICAL) -> Array:
	if is_finished:
		return []

	var resolved_actions: Array = []
	var target_time := elapsed_seconds + maxf(0.0, delta_seconds)
	while not is_finished:
		var next_action_time := minf(hero_next_attack_time, mob_next_attack_time)
		if has_active_crippling_slow():
			next_action_time = minf(next_action_time, crippling_slow_active_until)
		if next_action_time > target_time + TIME_EPSILON:
			break
		elapsed_seconds = next_action_time
		if crippling_slow_reduction > 0.0 and elapsed_seconds + TIME_EPSILON >= crippling_slow_active_until:
			expire_crippling_slow()
			continue
		try_activate_battle_guard(resolved_actions)
		var hero_attacks_now := is_equal_approx(hero_next_attack_time, next_action_time)
		var mob_attacks_now := is_equal_approx(mob_next_attack_time, next_action_time)
		var hero_damage := 0.0
		var mob_damage := 0.0

		if hero_attacks_now:
			if can_use_shield_bash():
				rage -= SHIELD_BASH_RAGE_COST
				shield_bash_ready_time = elapsed_seconds + SHIELD_BASH_COOLDOWN_SECONDS
				var stun_duration := get_shield_bash_stun_duration()
				mob_next_attack_time += stun_duration
				mob_attacks_now = false
				var shield_bash = CombatActionScript.new("hero", elapsed_seconds, 0.0, false, true, false, DamageResolverScript.DAMAGE_TYPE_PHYSICAL, SHIELD_BASH_ID)
				actions.append(shield_bash)
				resolved_actions.append(shield_bash)
			elif can_use_crippling_blows():
				rage -= CRIPPLING_BLOWS_RAGE_COST
				crippling_blows_ready_time = elapsed_seconds + CRIPPLING_BLOWS_COOLDOWN_SECONDS
				var crippling_damage_multiplier := get_crippling_blows_damage_multiplier()
				var crippling_hit_one = create_hit("hero", hero_stats, mob_stats, hero_damage_multiplier * crippling_damage_multiplier, false, CRIPPLING_BLOWS_ID)
				var crippling_hit_two = create_hit("hero", hero_stats, mob_stats, hero_damage_multiplier * crippling_damage_multiplier, false, CRIPPLING_BLOWS_ID)
				for crippling_hit in [crippling_hit_one, crippling_hit_two]:
					crippling_hit.time_seconds = elapsed_seconds
					actions.append(crippling_hit)
					resolved_actions.append(crippling_hit)
					hero_damage += crippling_hit.damage
				if crippling_hit_one.did_hit or crippling_hit_two.did_hit:
					apply_crippling_slow(get_crippling_blows_attack_speed_reduction())
			else:
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
			var mob_hit = create_hit("mob", mob_stats, hero_stats, 1.0, false, NORMAL_ATTACK_ID, mob_damage_type)
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

func create_hit(attacker_id: String, attacker_stats: CombatStats, target_stats: CombatStats, damage_multiplier: float = 1.0, guaranteed_hit: bool = false, action_id: String = NORMAL_ATTACK_ID, damage_type: String = DamageResolverScript.DAMAGE_TYPE_PHYSICAL):
	var dodge_chance := DamageResolverScript.calculate_dodge_chance(attacker_stats.accuracy, target_stats.dodge)
	if not guaranteed_hit and dodge_chance > 0.0 and random_number_generator.randf() < dodge_chance:
		return CombatActionScript.new(attacker_id, 0.0, 0.0, false, false, false, damage_type, action_id)
	var is_critical := attacker_stats.crit_chance > 0.0 and random_number_generator.randf() < attacker_stats.crit_chance
	var damage := attacker_stats.attack
	if is_critical:
		damage *= attacker_stats.crit_damage
	damage *= damage_multiplier
	var block_chance := DamageResolverScript.calculate_block_chance(target_stats.block)
	var was_blocked := block_chance > 0.0 and random_number_generator.randf() < block_chance
	damage = DamageResolverScript.calculate_mitigated_damage(
		damage,
		damage_type,
		target_stats.armor,
		get_matching_resistance(target_stats, damage_type),
		was_blocked
	)
	return CombatActionScript.new(attacker_id, 0.0, damage, is_critical, true, was_blocked, damage_type, action_id)

func get_matching_resistance(target_stats: CombatStats, damage_type: String) -> float:
	match damage_type:
		DamageResolverScript.DAMAGE_TYPE_FIRE:
			return target_stats.fire_resistance
		DamageResolverScript.DAMAGE_TYPE_COLD:
			return target_stats.cold_resistance
		DamageResolverScript.DAMAGE_TYPE_LIGHTNING:
			return target_stats.lightning_resistance
	return 0.0

func can_use_power_strike() -> bool:
	return power_strike_skill_level > 0 and rage >= POWER_STRIKE_RAGE_COST and elapsed_seconds + TIME_EPSILON >= power_strike_ready_time

func can_use_shield_bash() -> bool:
	return shield_bash_skill_level > 0 and hero_has_shield and rage >= SHIELD_BASH_RAGE_COST and elapsed_seconds + TIME_EPSILON >= shield_bash_ready_time

func can_use_crippling_blows() -> bool:
	return crippling_blows_skill_level > 0 and rage >= CRIPPLING_BLOWS_RAGE_COST and elapsed_seconds + TIME_EPSILON >= crippling_blows_ready_time

func get_wisdom_factor() -> float:
	var effective_wisdom := maxi(0, hero_wisdom - BASE_WISDOM)
	return float(effective_wisdom) / float(effective_wisdom + 100)

func get_specialization_wisdom_factor() -> float:
	var effective_wisdom := maxi(0, hero_wisdom)
	return float(effective_wisdom) / float(effective_wisdom + 100)

func get_shield_bash_stun_duration() -> float:
	assert(shield_bash_skill_level > 0, "Shield Bash duration requires the learned specialization skill.")
	var skill_progress := float(shield_bash_skill_level - 1) / float(MAX_SKILL_LEVEL - 1)
	var base_stun_duration := lerpf(SHIELD_BASH_MIN_STUN_SECONDS, SHIELD_BASH_MAX_STUN_SECONDS, skill_progress)
	return base_stun_duration + SHIELD_BASH_WISDOM_COEFFICIENT * get_specialization_wisdom_factor()

func get_crippling_blows_attack_speed_reduction() -> float:
	assert(crippling_blows_skill_level > 0, "Crippling Blows reduction requires the learned specialization skill.")
	var skill_progress := float(crippling_blows_skill_level - 1) / float(MAX_SKILL_LEVEL - 1)
	var base_reduction := lerpf(CRIPPLING_BLOWS_MIN_ATTACK_SPEED_REDUCTION, CRIPPLING_BLOWS_MAX_ATTACK_SPEED_REDUCTION, skill_progress)
	return base_reduction + CRIPPLING_BLOWS_WISDOM_COEFFICIENT * get_specialization_wisdom_factor()

func get_crippling_blows_damage_multiplier() -> float:
	assert(crippling_blows_skill_level > 0, "Crippling Blows damage multiplier requires the learned specialization skill.")
	var rank_bonus := float(crippling_blows_skill_level - 1) * CRIPPLING_BLOWS_RANK_DAMAGE_MULTIPLIER_BONUS
	var wisdom_bonus := CRIPPLING_BLOWS_WISDOM_DAMAGE_COEFFICIENT * get_specialization_wisdom_factor()
	return CRIPPLING_BLOWS_BASE_DAMAGE_MULTIPLIER + rank_bonus + wisdom_bonus

func has_active_crippling_slow() -> bool:
	return crippling_slow_reduction > 0.0 and crippling_slow_active_until > elapsed_seconds

func apply_crippling_slow(reduction: float) -> void:
	var clamped_reduction := clampf(reduction, 0.0, 0.95)
	if clamped_reduction <= 0.0:
		return
	if has_active_crippling_slow():
		expire_crippling_slow()
	var base_interval: float = 2.0 / mob_stats.attack_speed
	var slowed_interval: float = base_interval / (1.0 - clamped_reduction)
	rescale_mob_attack_progress(mob_attack_interval, slowed_interval)
	mob_attack_interval = slowed_interval
	crippling_slow_reduction = clamped_reduction
	crippling_slow_active_until = elapsed_seconds + CRIPPLING_BLOWS_DURATION_SECONDS

func expire_crippling_slow() -> void:
	if crippling_slow_reduction <= 0.0:
		crippling_slow_active_until = 0.0
		return
	var base_interval: float = 2.0 / mob_stats.attack_speed
	rescale_mob_attack_progress(mob_attack_interval, base_interval)
	mob_attack_interval = base_interval
	crippling_slow_reduction = 0.0
	crippling_slow_active_until = 0.0

func rescale_mob_attack_progress(old_interval: float, new_interval: float) -> void:
	if old_interval <= TIME_EPSILON or new_interval <= TIME_EPSILON:
		return
	var remaining: float = maxf(0.0, mob_next_attack_time - elapsed_seconds)
	var progress: float = clampf(1.0 - remaining / old_interval, 0.0, 1.0)
	mob_next_attack_time = elapsed_seconds + new_interval * (1.0 - progress)

func get_power_strike_multiplier() -> float:
	assert(power_strike_skill_level > 0 and power_strike_skill_level <= MAX_SKILL_LEVEL, "Power Strike multiplier requires a learned Skill Level from 1 to 10.")
	var wisdom_factor := get_wisdom_factor()
	var skill_progress := float(power_strike_skill_level - 1) / float(MAX_SKILL_LEVEL - 1)
	var skill_multiplier := lerpf(POWER_STRIKE_MIN_MULTIPLIER, POWER_STRIKE_MAX_MULTIPLIER, skill_progress)
	return skill_multiplier + POWER_STRIKE_WISDOM_COEFFICIENT * wisdom_factor

func add_rage(amount: int) -> void:
	rage = mini(MAX_RAGE, rage + amount)

func is_battle_guard_active() -> bool:
	return battle_guard_skill_level > 0 and elapsed_seconds < battle_guard_active_until - TIME_EPSILON

func get_battle_guard_multiplier() -> float:
	assert(battle_guard_skill_level > 0 and battle_guard_skill_level <= MAX_SKILL_LEVEL, "Battle Guard multiplier requires a learned Skill Level from 1 to 10.")
	var wisdom_factor := get_wisdom_factor()
	var skill_progress := float(battle_guard_skill_level - 1) / float(MAX_SKILL_LEVEL - 1)
	var base_reduction := lerpf(BATTLE_GUARD_MIN_REDUCTION, BATTLE_GUARD_MAX_REDUCTION, skill_progress)
	var damage_reduction := base_reduction + BATTLE_GUARD_WISDOM_COEFFICIENT * wisdom_factor
	return 1.0 - damage_reduction

func try_activate_battle_guard(resolved_actions: Array) -> void:
	if battle_guard_skill_level <= 0 or is_battle_guard_active():
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
