class_name CombatAction
extends RefCounted

var attacker_id: String
var time_seconds: float
var damage: float
var is_critical: bool

func _init(initial_attacker_id: String, initial_time_seconds: float, initial_damage: float, initial_is_critical: bool) -> void:
	attacker_id = initial_attacker_id
	time_seconds = initial_time_seconds
	damage = initial_damage
	is_critical = initial_is_critical
