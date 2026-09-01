class_name ItemGenerator
extends RefCounted

const ItemInstanceScript = preload("res://scripts/model/runtime/item_instance.gd")
const DefaultBudgetTable = preload("res://data/items/balance/item_modifier_budget_table.tres")
const DefaultStatCostTable = preload("res://data/items/balance/item_modifier_stat_costs.tres")
const DefaultBaseStatTable = preload("res://data/items/balance/item_base_stat_table.tres")

const ARMOR_SLOTS := ["helmet", "chest", "gloves", "pants", "boots"]
const JEWELRY_SLOTS := ["necklace", "earrings", "ring_1", "ring_2"]
const JEWELRY_RESISTANCE_STATS := ["fire_resistance", "cold_resistance", "lightning_resistance"]
const ARMOR_AFFIX_POOL := ["health", "armor", "dodge"]
const WEAPON_AFFIX_POOL := ["damage", "accuracy", "crit_chance_percentage_point", "crit_damage_percentage_point", "attack_speed_percent"]
const SHIELD_AFFIX_POOL := ["accuracy", "crit_chance_percentage_point", "crit_damage_percentage_point", "block", "health"]
const JEWELRY_AFFIX_POOL := ["fire_resistance", "cold_resistance", "lightning_resistance", "health", "dodge", "accuracy", "crit_chance_percentage_point", "crit_damage_percentage_point"]

var budget_table: Resource
var stat_cost_table: Resource
var base_stat_table: Resource

func _init(
	initial_budget_table: Resource = DefaultBudgetTable,
	initial_stat_cost_table: Resource = DefaultStatCostTable,
	initial_base_stat_table: Resource = DefaultBaseStatTable
) -> void:
	budget_table = initial_budget_table
	stat_cost_table = initial_stat_cost_table
	base_stat_table = initial_base_stat_table

func generate(item_definition: Resource, item_level: int, rng, rarity_override: int = -1):
	if item_definition == null or rng == null:
		return null
	var rarity: int = rarity_override if rarity_override >= 0 else int(item_definition.quality)
	var base_stats: Dictionary = create_base_stats(item_definition.equipment_slot, item_level, rng)
	if base_stats.is_empty():
		return null

	var affix_count: int = budget_table.get_affix_count(rarity)
	var nominal_total_budget: float = budget_table.get_nominal_total_budget(item_level, rarity)
	if nominal_total_budget < 0.0:
		return null
	var rolled_total_budget: float = 0.0
	if affix_count > 0:
		var roll_factor: float = lerpf(budget_table.total_budget_roll_min, budget_table.total_budget_roll_max, rng.randf())
		rolled_total_budget = nominal_total_budget * roll_factor

	var affixes: Array = []
	var resolved_stats: Dictionary = base_stats.duplicate(true)
	if affix_count > 0:
		var available_affixes: Array = get_affix_pool(item_definition.equipment_slot)
		if available_affixes.size() < affix_count:
			return null
		var budget_per_affix: float = rolled_total_budget / float(affix_count)
		for affix_index in affix_count:
			var pool_index: int = rng.randi_range(0, available_affixes.size() - 1)
			var stat_id: String = available_affixes.pop_at(pool_index)
			var stat_cost: float = stat_cost_table.get_stat_cost(stat_id)
			if stat_cost <= 0.0:
				return null
			var stat_value: float = budget_per_affix / stat_cost
			affixes.append({
				"stat_id": stat_id,
				"budget": budget_per_affix,
				"value": stat_value,
			})
			apply_affix_to_resolved_stats(resolved_stats, stat_id, stat_value)

	return ItemInstanceScript.new(
		item_definition,
		item_level,
		rarity,
		base_stats,
		affixes,
		rolled_total_budget,
		resolved_stats
	)

func create_base_stats(equipment_slot: String, item_level: int, rng = null) -> Dictionary:
	if ARMOR_SLOTS.has(equipment_slot):
		var armor: float = base_stat_table.get_armor(item_level)
		return {"armor": armor} if armor >= 0.0 else {}
	if equipment_slot == "weapon":
		var damage: float = base_stat_table.get_sword_damage(item_level)
		var attack_speed: float = base_stat_table.get_sword_attack_speed_bonus(item_level)
		return {"attack": damage, "attack_speed": attack_speed} if damage >= 0.0 and attack_speed >= 0.0 else {}
	if equipment_slot == "shield":
		var block: float = base_stat_table.get_shield_block(item_level)
		return {"block": block} if block >= 0.0 else {}
	if JEWELRY_SLOTS.has(equipment_slot):
		if rng == null:
			return {}
		var resistance: float = base_stat_table.get_jewelry_resistance(item_level)
		if resistance < 0.0:
			return {}
		var resistance_stat: String = JEWELRY_RESISTANCE_STATS[rng.randi_range(0, JEWELRY_RESISTANCE_STATS.size() - 1)]
		return {resistance_stat: resistance}
	return {}

func get_affix_pool(equipment_slot: String) -> Array:
	if ARMOR_SLOTS.has(equipment_slot):
		return ARMOR_AFFIX_POOL.duplicate()
	if equipment_slot == "weapon":
		return WEAPON_AFFIX_POOL.duplicate()
	if equipment_slot == "shield":
		return SHIELD_AFFIX_POOL.duplicate()
	if JEWELRY_SLOTS.has(equipment_slot):
		return JEWELRY_AFFIX_POOL.duplicate()
	return []

func apply_affix_to_resolved_stats(resolved_stats: Dictionary, stat_id: String, value: float) -> void:
	var resolved_stat_id: String = stat_id
	var resolved_value: float = value
	match stat_id:
		"health": resolved_stat_id = "max_hp"
		"damage": resolved_stat_id = "attack"
		"crit_chance_percentage_point":
			resolved_stat_id = "crit_chance"
			resolved_value = value / 100.0
		"crit_damage_percentage_point":
			resolved_stat_id = "crit_damage"
			resolved_value = value / 100.0
		"attack_speed_percent":
			resolved_stat_id = "attack_speed"
			resolved_value = value / 100.0
		"cast_speed_percent":
			resolved_stat_id = "cast_speed"
			resolved_value = value / 100.0
		"elemental_resistance": resolved_stat_id = "fire_resistance"
	resolved_stats[resolved_stat_id] = float(resolved_stats.get(resolved_stat_id, 0.0)) + resolved_value
