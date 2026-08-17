class_name MobDefinition
extends Resource

enum Category {
	HUMANOID,
	MONSTER,
}

const CombatStatsScript = preload("res://scripts/model/runtime/combat_stats.gd")
const PowerCalculatorScript = preload("res://scripts/combat/power_calculator.gd")

@export var id: String
@export var display_name: String
@export var category: Category = Category.MONSTER
@export var max_hp: float = 1.0
@export var attack: float = 1.0
@export var attack_speed: float = 1.0
@export var crit_chance: float = 0.0
@export var crit_damage: float = 1.50
@export var damage_reduction: float = 0.0
@export var experience_reward: int = 0
@export var gold_reward: int = 0

func get_combat_stats() -> RefCounted:
	var combat_stats = CombatStatsScript.new()
	combat_stats.max_hp = max_hp
	combat_stats.attack = attack
	combat_stats.attack_speed = attack_speed
	combat_stats.crit_chance = crit_chance
	combat_stats.crit_damage = crit_damage
	combat_stats.damage_reduction = damage_reduction
	return combat_stats

func get_power() -> float:
	var power_calculator = PowerCalculatorScript.new()
	return power_calculator.calculate(get_combat_stats())
