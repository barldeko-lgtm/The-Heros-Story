class_name CombatAction
extends RefCounted

var attacker_id: String
var time_seconds: float
var damage: float
var is_critical: bool
var did_hit: bool
var was_blocked: bool
var damage_type: String
var action_id: String

func _init(initial_attacker_id: String, initial_time_seconds: float, initial_damage: float, initial_is_critical: bool, initial_did_hit: bool = true, initial_was_blocked: bool = false, initial_damage_type: String = "physical", initial_action_id: String = "normal_attack") -> void:
	attacker_id = initial_attacker_id
	time_seconds = initial_time_seconds
	damage = initial_damage
	is_critical = initial_is_critical
	did_hit = initial_did_hit
	was_blocked = initial_was_blocked
	damage_type = initial_damage_type
	action_id = initial_action_id
