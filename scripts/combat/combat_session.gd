class_name CombatSession
extends RefCounted

const CombatActionScript = preload("res://scripts/combat/combat_action.gd")
const CombatResultScript = preload("res://scripts/combat/combat_result.gd")
const HERO_OPENING_ADVANTAGE_SECONDS: float = 0.5
const TIME_EPSILON: float = 0.000001

var hero_stats: CombatStats
var mob_stats: CombatStats
var random_number_generator: RandomNumberGenerator
var hero_remaining_hp: float
var mob_remaining_hp: float
var hero_attack_interval: float
var mob_attack_interval: float
var hero_next_attack_time: float
var mob_next_attack_time: float
var elapsed_seconds: float = 0.0
var is_finished: bool = false
var actions: Array = []

func _init(initial_hero_stats: CombatStats, initial_mob_stats: CombatStats, initial_random_number_generator: RandomNumberGenerator = null) -> void:
	assert(initial_hero_stats.attack_speed > 0.0, "Hero attack speed must be positive.")
	assert(initial_mob_stats.attack_speed > 0.0, "Mob attack speed must be positive.")
	hero_stats = initial_hero_stats
	mob_stats = initial_mob_stats
	random_number_generator = initial_random_number_generator
	if random_number_generator == null:
		random_number_generator = RandomNumberGenerator.new()
		random_number_generator.randomize()
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
		var hero_attacks_now := is_equal_approx(hero_next_attack_time, next_action_time)
		var mob_attacks_now := is_equal_approx(mob_next_attack_time, next_action_time)
		var hero_damage := 0.0
		var mob_damage := 0.0

		if hero_attacks_now:
			var hero_hit = create_hit("hero", hero_stats)
			hero_hit.time_seconds = elapsed_seconds
			actions.append(hero_hit)
			resolved_actions.append(hero_hit)
			hero_damage = hero_hit.damage
			hero_next_attack_time += hero_attack_interval
		if mob_attacks_now:
			var mob_hit = create_hit("mob", mob_stats)
			mob_hit.time_seconds = elapsed_seconds
			actions.append(mob_hit)
			resolved_actions.append(mob_hit)
			mob_damage = mob_hit.damage
			mob_next_attack_time += mob_attack_interval

		mob_remaining_hp -= hero_damage
		hero_remaining_hp -= mob_damage
		is_finished = hero_remaining_hp <= 0.0 or mob_remaining_hp <= 0.0

	if not is_finished:
		elapsed_seconds = target_time
	return resolved_actions

func get_result():
	return CombatResultScript.new(hero_remaining_hp > 0.0, hero_remaining_hp, mob_remaining_hp, elapsed_seconds, actions)

func create_hit(attacker_id: String, combat_stats: CombatStats):
	var is_critical := combat_stats.crit_chance > 0.0 and random_number_generator.randf() < combat_stats.crit_chance
	var damage := combat_stats.attack
	if is_critical:
		damage *= combat_stats.crit_damage
	return CombatActionScript.new(attacker_id, 0.0, damage, is_critical)
