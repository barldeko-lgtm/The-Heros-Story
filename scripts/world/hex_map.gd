class_name HexMap
extends RefCounted

const HexDefinitionScript = preload("res://scripts/model/definitions/hex_definition.gd")
const KM_PER_HEX: float = 3.0
const REGION_RADIUS_STEPS: int = 7
const STARTING_REGION_ID: String = "starting_region"
const MID_REGION_ID: String = "mid_region"

var definition
var hexes_by_coordinate: Dictionary = {}
var distance_maps_by_origin: Dictionary = {}

func _init(initial_definition: Resource) -> void:
	definition = initial_definition
	assert(definition != null, "HexMap requires an authored map definition.")
	assert(definition.ensure_layout_loaded(), "HexMap requires a decodable authored map layout.")
	assert(definition.validate_layout(), "HexMap requires a structurally valid authored map layout.")
	build_hex_definitions()

func build_hex_definitions() -> void:
	hexes_by_coordinate.clear()
	distance_maps_by_origin.clear()
	for column in range(definition.width):
		for row in range(definition.height):
			var coordinates := Vector2i(column, row)
			var terrain_id: String = normalize_source_terrain_id(definition.get_terrain_id(coordinates))
			var tags: PackedStringArray = build_tags_for_hex(coordinates, terrain_id)
			hexes_by_coordinate[coordinates] = HexDefinitionScript.new(coordinates, terrain_id, "", tags)
	assign_region_ids()

func normalize_source_terrain_id(source_terrain_id: String) -> String:
	if source_terrain_id == "hero_start":
		return "starting_city"
	return source_terrain_id

func build_tags_for_hex(coordinates: Vector2i, terrain_id: String) -> PackedStringArray:
	var tags := PackedStringArray()
	if terrain_id == "starting_city" or terrain_id == "mid_city":
		tags.append(HexDefinitionScript.TAG_CITY)
	if coordinates == definition.starting_city_center or coordinates == definition.mid_city_center:
		tags.append(HexDefinitionScript.TAG_CITY_CENTER)
	if definition.road_path.has(coordinates):
		tags.append(HexDefinitionScript.TAG_ROAD)
	return tags

func assign_region_ids() -> void:
	var starting_distances: Dictionary = build_distance_map(definition.starting_city_center)
	var mid_distances: Dictionary = build_distance_map(definition.mid_city_center)
	var split_x: float = (float(definition.starting_city_center.x) + float(definition.mid_city_center.x)) * 0.5
	for coordinates in hexes_by_coordinate:
		var hex_definition = hexes_by_coordinate[coordinates]
		var starting_distance: int = int(starting_distances.get(coordinates, -1))
		var mid_distance: int = int(mid_distances.get(coordinates, -1))
		var in_starting_region: bool = starting_distance >= 0 and starting_distance <= REGION_RADIUS_STEPS
		var in_mid_region: bool = mid_distance >= 0 and mid_distance <= REGION_RADIUS_STEPS

		if not in_starting_region and not in_mid_region:
			hex_definition.region_id = ""
		elif in_starting_region and not in_mid_region:
			hex_definition.region_id = STARTING_REGION_ID
		elif in_mid_region and not in_starting_region:
			hex_definition.region_id = MID_REGION_ID
		elif starting_distance < mid_distance:
			hex_definition.region_id = STARTING_REGION_ID
		elif mid_distance < starting_distance:
			hex_definition.region_id = MID_REGION_ID
		else:
			hex_definition.region_id = STARTING_REGION_ID if float(coordinates.x) < split_x else MID_REGION_ID

func build_distance_map(origin: Vector2i) -> Dictionary:
	var distances: Dictionary = {origin: 0}
	var frontier: Array[Vector2i] = [origin]
	var frontier_index: int = 0
	while frontier_index < frontier.size():
		var current: Vector2i = frontier[frontier_index]
		frontier_index += 1
		var next_distance: int = int(distances[current]) + 1
		for neighbor in get_neighbors(current):
			if distances.has(neighbor):
				continue
			distances[neighbor] = next_distance
			frontier.append(neighbor)
	return distances

func get_distance_map(origin: Vector2i) -> Dictionary:
	if not is_valid_cell(origin):
		return {}
	if not distance_maps_by_origin.has(origin):
		distance_maps_by_origin[origin] = build_distance_map(origin)
	return distance_maps_by_origin[origin]

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

func get_cells_within_radius(center: Vector2i, radius: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	if radius < 0 or not is_valid_cell(center):
		return result
	if radius == 0:
		return [center]
	var distances: Dictionary = {center: 0}
	var frontier: Array[Vector2i] = [center]
	var frontier_index: int = 0
	while frontier_index < frontier.size():
		var current: Vector2i = frontier[frontier_index]
		frontier_index += 1
		result.append(current)
		var current_distance: int = int(distances[current])
		if current_distance >= radius:
			continue
		for neighbor in get_neighbors(current):
			if distances.has(neighbor):
				continue
			distances[neighbor] = current_distance + 1
			frontier.append(neighbor)
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
	if not is_valid_cell(start) or not is_valid_cell(destination):
		return -1
	return int(get_distance_map(start).get(destination, -1))

func get_distance_km(start: Vector2i, destination: Vector2i) -> float:
	var distance_steps: int = get_distance_steps(start, destination)
	if distance_steps < 0:
		return -1.0
	return float(distance_steps) * KM_PER_HEX
