class_name CombatResult
extends RefCounted

var hero_won: bool
var hero_remaining_hp: float
var mob_remaining_hp: float
var duration_seconds: float
var actions: Array = []

func _init(initial_hero_won: bool, initial_hero_remaining_hp: float, initial_mob_remaining_hp: float, initial_duration_seconds: float, initial_actions: Array) -> void:
	hero_won = initial_hero_won
	hero_remaining_hp = initial_hero_remaining_hp
	mob_remaining_hp = initial_mob_remaining_hp
	duration_seconds = initial_duration_seconds
	actions = initial_actions
