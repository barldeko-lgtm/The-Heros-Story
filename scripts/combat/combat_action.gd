class_name CombatAction
extends RefCounted

var attacker_id: String
var time_seconds: float
var damage: float
var is_critical: bool
var did_hit: bool
var was_blocked: bool
var damage_type: String

func _init(initial_attacker_id: String, initial_time_seconds: float, initial_damage: float, initial_is_critical: bool, initial_did_hit: bool = true, initial_was_blocked: bool = false, initial_damage_type: String = "physical") -> void:
	attacker_id = initial_attacker_id
	time_seconds = initial_time_seconds
	damage = initial_damage
	is_critical = initial_is_critical
	did_hit = initial_did_hit
	was_blocked = initial_was_blocked
	damage_type = initial_damage_type
