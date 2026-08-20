class_name QuestOffer
extends RefCounted

var template: Resource
var id: String
var display_name: String
var mob_definition: Resource
var mob_count: int
var distance_km: float
var gold_per_mob: int

var gold_reward: int:
	get:
		return mob_count * gold_per_mob

func _init(initial_template: Resource, initial_mob_count: int, initial_distance_km: float, initial_gold_per_mob: int) -> void:
	template = initial_template
	id = template.id
	display_name = template.display_name
	mob_definition = template.mob_definition
	mob_count = initial_mob_count
	distance_km = initial_distance_km
	gold_per_mob = initial_gold_per_mob
