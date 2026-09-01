class_name WorldState
extends RefCounted

signal hero_position_changed(cell: Vector2i)

var hex_map
var hero_position: Vector2i
var activity_id_by_hex: Dictionary = {}
var activity_hexes_by_id: Dictionary = {}

func _init(initial_hex_map) -> void:
	hex_map = initial_hex_map
	assert(hex_map != null, "WorldState requires HexMap.")
	hero_position = hex_map.definition.starting_city_center
	assert(hex_map.is_valid_cell(hero_position), "WorldState hero start must be a valid map cell.")

func set_hero_position(cell: Vector2i) -> bool:
	if not hex_map.is_valid_cell(cell):
		return false
	if hero_position == cell:
		return true
	hero_position = cell
	hero_position_changed.emit(cell)
	return true

func is_hex_occupied(cell: Vector2i) -> bool:
	return activity_id_by_hex.has(cell)

func get_activity_id_at_hex(cell: Vector2i) -> String:
	return str(activity_id_by_hex.get(cell, ""))

func reserve_activity(activity_id: String, cells: Array[Vector2i]) -> bool:
	if activity_id.is_empty() or cells.is_empty() or activity_hexes_by_id.has(activity_id):
		return false
	var unique_cells: Array[Vector2i] = []
	var seen_cells: Dictionary = {}
	for cell in cells:
		if seen_cells.has(cell):
			continue
		if not hex_map.is_valid_cell(cell) or is_hex_occupied(cell):
			return false
		seen_cells[cell] = true
		unique_cells.append(cell)
	for cell in unique_cells:
		activity_id_by_hex[cell] = activity_id
	activity_hexes_by_id[activity_id] = unique_cells
	return true

func release_activity(activity_id: String) -> bool:
	if not activity_hexes_by_id.has(activity_id):
		return false
	var cells: Array = activity_hexes_by_id[activity_id]
	for cell in cells:
		if activity_id_by_hex.get(cell, "") == activity_id:
			activity_id_by_hex.erase(cell)
	activity_hexes_by_id.erase(activity_id)
	return true
