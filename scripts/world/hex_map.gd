class_name HexMap
extends RefCounted

const HexDefinitionScript = preload("res://scripts/model/definitions/hex_definition.gd")
const KM_PER_HEX: float = 3.0

var definition
var hexes_by_coordinate: Dictionary = {}

func _init(initial_definition: Resource) -> void:
	definition = initial_definition
	assert(definition != null, "HexMap requires an authored map definition.")
	assert(definition.ensure_layout_loaded(), "HexMap requires a decodable authored map layout.")
	assert(definition.validate_layout(), "HexMap requires a structurally valid authored map layout.")
	build_hex_definitions()

func build_hex_definitions() -> void:
	hexes_by_coordinate.clear()
	for column in range(definition.width):
		for row in range(definition.height):
			var coordinates := Vector2i(column, row)
			var terrain_id: String = normalize_source_terrain_id(definition.get_terrain_id(coordinates))
			hexes_by_coordinate[coordinates] = HexDefinitionScript.new(coordinates, terrain_id)

func normalize_source_terrain_id(source_terrain_id: String) -> String:
	if source_terrain_id == "hero_start":
		return "starting_city"
	return source_terrain_id

func get_hex(cell: Vector2i):
	return hexes_by_coordinate.get(cell)

func get_hex_count() -> int:
	return hexes_by_coordinate.size()

func is_valid_cell(cell: Vector2i) -> bool:
	return get_hex(cell) != null

func get_neighbors(cell: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	if not is_valid_cell(cell):
		return result
	for neighbor in definition.get_neighbors(cell):
		if is_valid_cell(neighbor):
			result.append(neighbor)
	return result

func find_path(start: Vector2i, destination: Vector2i) -> Array[Vector2i]:
	var empty_path: Array[Vector2i] = []
	if not is_valid_cell(start) or not is_valid_cell(destination):
		return empty_path
	if start == destination:
		return [start]

	var frontier: Array[Vector2i] = [start]
	var frontier_index: int = 0
	var came_from: Dictionary = {start: start}

	while frontier_index < frontier.size():
		var current: Vector2i = frontier[frontier_index]
		frontier_index += 1
		for neighbor in get_neighbors(current):
			if came_from.has(neighbor):
				continue
			came_from[neighbor] = current
			if neighbor == destination:
				return build_path(came_from, start, destination)
			frontier.append(neighbor)

	return empty_path

func build_path(came_from: Dictionary, start: Vector2i, destination: Vector2i) -> Array[Vector2i]:
	var reversed_path: Array[Vector2i] = [destination]
	var current: Vector2i = destination
	while current != start:
		current = came_from[current]
		reversed_path.append(current)
	reversed_path.reverse()
	return reversed_path

func get_distance_steps(start: Vector2i, destination: Vector2i) -> int:
	var path: Array[Vector2i] = find_path(start, destination)
	if path.is_empty():
		return -1
	return path.size() - 1

func get_distance_km(start: Vector2i, destination: Vector2i) -> float:
	var distance_steps: int = get_distance_steps(start, destination)
	if distance_steps < 0:
		return -1.0
	return float(distance_steps) * KM_PER_HEX
