class_name QuestOffer
extends RefCounted

var template: Resource
var id: String
var display_name: String
var mob_definition: Resource
var mob_count: int
var distance_km: float
const INVALID_TARGET_HEX := Vector2i(-1, -1)

var gold_per_mob: int
var target_hex: Vector2i = INVALID_TARGET_HEX
var map_activity_id: String = ""

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

func has_map_target() -> bool:
	return target_hex != INVALID_TARGET_HEX and not map_activity_id.is_empty()

func assign_map_target(cell: Vector2i, activity_id: String) -> void:
	target_hex = cell
	map_activity_id = activity_id

func clear_map_target() -> void:
	target_hex = INVALID_TARGET_HEX
	map_activity_id = ""
