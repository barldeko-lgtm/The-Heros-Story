class_name WorldState
extends RefCounted

var hex_map
var hero_position: Vector2i

func _init(initial_hex_map) -> void:
	hex_map = initial_hex_map
	assert(hex_map != null, "WorldState requires HexMap.")
	hero_position = hex_map.definition.starting_city_center
	assert(hex_map.is_valid_cell(hero_position), "WorldState hero start must be a valid map cell.")

func set_hero_position(cell: Vector2i) -> bool:
	if not hex_map.is_valid_cell(cell):
		return false
	hero_position = cell
	return true
