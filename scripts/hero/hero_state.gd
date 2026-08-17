class_name HeroState
extends RefCounted

signal state_changed

var hero_name: String
var hero_class_id: String = "warrior"
var level: int = 1
var experience: int = 0
var experience_to_next_level: int = 1000
var strength: int = 2
var agility: int = 2
var intelligence: int = 2
var current_hp: float = 0.0
var gold: int = 0
var traits: Array[String] = []
var loop_state: String = "CHOOSING_QUEST"
var active_quest
var active_effects: Array[Dictionary] = []

func _init(initial_name: String) -> void:
	hero_name = initial_name
