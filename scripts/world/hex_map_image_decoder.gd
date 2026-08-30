class_name HexMapImageDecoder
extends RefCounted

const PLAINS_COLOR: Color = Color8(158, 173, 120, 255)
const FOREST_COLOR: Color = Color8(79, 116, 83, 255)
const HILL_COLOR: Color = Color8(154, 129, 96, 255)
const ROAD_COLOR: Color = Color8(214, 189, 122, 255)
const STARTING_CITY_COLOR: Color = Color8(136, 114, 88, 255)
const HERO_START_COLOR: Color = Color8(224, 75, 90, 255)
const MID_CITY_COLOR: Color = Color8(113, 105, 133, 255)

func decode(layout_texture: Texture2D, map_definition) -> Dictionary:
	var result: Dictionary = {
		"succeeded": false,
		"errors": PackedStringArray(),
		"terrain_by_cell": {},
		"counts": {},
		"starting_city_center": Vector2i(-1, -1),
		"mid_city_center": Vector2i(-1, -1),
		"road_path": [],
		"forest_cells": [],
		"hill_cells": [],
	}
	var errors: PackedStringArray = result["errors"]
	if layout_texture == null:
		errors.append("Map layout texture is missing.")
		return result
	var image: Image = layout_texture.get_image()
	if image == null or image.is_empty():
		errors.append("Map layout texture could not be decoded as an image.")
		return result

	var terrain_by_cell: Dictionary = result["terrain_by_cell"]
	var counts: Dictionary = result["counts"]
	var hero_start_cells: Array[Vector2i] = []
	var starting_city_cells: Array[Vector2i] = []
	var mid_city_cells: Array[Vector2i] = []
	var road_cells: Array[Vector2i] = []
	var forest_cells: Array[Vector2i] = []
	var hill_cells: Array[Vector2i] = []

	for column in range(map_definition.width):
		for row in range(map_definition.height):
			var cell := Vector2i(column, row)
			var source_pixel: Vector2i = map_definition.get_source_pixel(cell)
			if source_pixel.x < 0 or source_pixel.x >= image.get_width() or source_pixel.y < 0 or source_pixel.y >= image.get_height():
				errors.append("Hex (%d, %d) samples outside the PNG at pixel (%d, %d)." % [cell.x, cell.y, source_pixel.x, source_pixel.y])
				continue
			var sampled_color: Color = image.get_pixelv(source_pixel)
			var terrain_id: String = get_terrain_id_for_color(sampled_color)
			if terrain_id.is_empty():
				errors.append("Unknown color at hex (%d, %d): #%s." % [cell.x, cell.y, sampled_color.to_html(true)])
				continue
			terrain_by_cell[cell] = terrain_id
			counts[terrain_id] = int(counts.get(terrain_id, 0)) + 1
			match terrain_id:
				"hero_start": hero_start_cells.append(cell)
				"starting_city": starting_city_cells.append(cell)
				"mid_city": mid_city_cells.append(cell)
				"road": road_cells.append(cell)
				"forest": forest_cells.append(cell)
				"hill": hill_cells.append(cell)

	if not errors.is_empty():
		return result
	if hero_start_cells.size() != 1:
		errors.append("Expected exactly one hero-start hex, found %d." % hero_start_cells.size())
		return result
	var starting_city_center: Vector2i = hero_start_cells[0]
	var complete_starting_city: Array[Vector2i] = starting_city_cells.duplicate()
	complete_starting_city.append(starting_city_center)
	if not matches_city_cluster(complete_starting_city, starting_city_center, map_definition):
		errors.append("Hero-start hex (%d, %d) must be surrounded by exactly six Starting City hexes." % [starting_city_center.x, starting_city_center.y])
		return result

	var mid_city_center: Vector2i = find_city_center(mid_city_cells, map_definition)
	if mid_city_cells.size() != 7 or mid_city_center == Vector2i(-1, -1):
		errors.append("Mid-Level City must be one connected seven-hex cluster with a unique center.")
		return result

	var ordered_road: Array[Vector2i] = build_ordered_road(road_cells, complete_starting_city, mid_city_cells, map_definition, errors)
	if not errors.is_empty():
		return result

	result["starting_city_center"] = starting_city_center
	result["mid_city_center"] = mid_city_center
	result["road_path"] = ordered_road
	result["forest_cells"] = forest_cells
	result["hill_cells"] = hill_cells
	result["succeeded"] = true
	return result

func get_terrain_id_for_color(color: Color) -> String:
	if color == PLAINS_COLOR:
		return "plains"
	if color == FOREST_COLOR:
		return "forest"
	if color == HILL_COLOR:
		return "hill"
	if color == ROAD_COLOR:
		return "road"
	if color == STARTING_CITY_COLOR:
		return "starting_city"
	if color == HERO_START_COLOR:
		return "hero_start"
	if color == MID_CITY_COLOR:
		return "mid_city"
	return ""

func matches_city_cluster(city_cells: Array[Vector2i], center: Vector2i, map_definition) -> bool:
	if city_cells.size() != 7:
		return false
	var expected_cells: Array[Vector2i] = map_definition.get_city_cells(center)
	for expected_cell in expected_cells:
		if not city_cells.has(expected_cell):
			return false
	return true

func find_city_center(city_cells: Array[Vector2i], map_definition) -> Vector2i:
	var possible_centers: Array[Vector2i] = []
	for candidate in city_cells:
		if matches_city_cluster(city_cells, candidate, map_definition):
			possible_centers.append(candidate)
	if possible_centers.size() == 1:
		return possible_centers[0]
	return Vector2i(-1, -1)

func build_ordered_road(road_cells: Array[Vector2i], starting_city_cells: Array[Vector2i], mid_city_cells: Array[Vector2i], map_definition, errors: PackedStringArray) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	if road_cells.is_empty():
		errors.append("The PNG must contain a road between the two cities.")
		return result
	var starting_endpoints: Array[Vector2i] = find_road_cells_touching_city(road_cells, starting_city_cells, map_definition)
	var mid_endpoints: Array[Vector2i] = find_road_cells_touching_city(road_cells, mid_city_cells, map_definition)
	if starting_endpoints.size() != 1 or mid_endpoints.size() != 1:
		errors.append("Road must touch each city through exactly one road endpoint.")
		return result

	var start_road: Vector2i = starting_endpoints[0]
	var end_road: Vector2i = mid_endpoints[0]
	var ordered_road_cells: Array[Vector2i] = []
	var visited: Dictionary = {}
	var previous := Vector2i(-999, -999)
	var current: Vector2i = start_road
	while true:
		ordered_road_cells.append(current)
		visited[current] = true
		if current == end_road:
			break
		var next_candidates: Array[Vector2i] = []
		for neighbor in map_definition.get_neighbors(current):
			if road_cells.has(neighbor) and neighbor != previous and not visited.has(neighbor):
				next_candidates.append(neighbor)
		if next_candidates.size() != 1:
			errors.append("Road is disconnected or branches at hex (%d, %d)." % [current.x, current.y])
			return []
		previous = current
		current = next_candidates[0]
	if visited.size() != road_cells.size():
		errors.append("Road contains disconnected cells outside the city-to-city path.")
		return []

	var start_entry: Vector2i = choose_city_entry(start_road, starting_city_cells, map_definition)
	var mid_entry: Vector2i = choose_city_entry(end_road, mid_city_cells, map_definition)
	result.append(start_entry)
	result.append_array(ordered_road_cells)
	result.append(mid_entry)
	return result

func find_road_cells_touching_city(road_cells: Array[Vector2i], city_cells: Array[Vector2i], map_definition) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for road_cell in road_cells:
		for neighbor in map_definition.get_neighbors(road_cell):
			if city_cells.has(neighbor):
				result.append(road_cell)
				break
	return result

func choose_city_entry(road_cell: Vector2i, city_cells: Array[Vector2i], map_definition) -> Vector2i:
	var candidates: Array[Vector2i] = []
	for neighbor in map_definition.get_neighbors(road_cell):
		if city_cells.has(neighbor):
			candidates.append(neighbor)
	candidates.sort_custom(func(first: Vector2i, second: Vector2i) -> bool:
		if first.x == second.x:
			return first.y < second.y
		return first.x < second.x
	)
	return candidates[0]
