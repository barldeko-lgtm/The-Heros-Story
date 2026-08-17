class_name HeroState
extends RefCounted

var hero_name: String
var hero_class: String = "Воин"
var level: int = 1
var experience: int = 0
var experience_to_next_level: int = 1000
var strength: int = 2
var agility: int = 2
var intelligence: int = 2
var current_hp: float = 110.0
var max_hp: float = 110.0
var attack: float = 7.0
var attack_speed: float = 1.12
var crit_chance: float = 0.12
var crit_damage: float = 1.56
var hero_power: float = 21.45

func _init(initial_name: String) -> void:
	hero_name = initial_name
