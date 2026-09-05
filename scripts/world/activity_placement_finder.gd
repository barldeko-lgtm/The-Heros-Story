class_name ActivityPlacementFinder
extends RefCounted

func find_valid_centers(
	hex_map,
	world_state,
	region_id: String,
	distance_origin: Vector2i,
	min_distance: int,
	max_distance: int,
	allowed_terrain_ids: PackedStringArray = PackedStringArray(),
	allowed_tags: PackedStringArray = PackedStringArray(),
	forbidden_tags: PackedStringArray = PackedStringArray(),
	radius: int = 0
) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	if hex_map == null or world_state == null:
		return result
	if region_id.is_empty() or min_distance < 0 or max_distance < min_distance or radius < 0:
		return result
	if not hex_map.is_valid_cell(distance_origin):
		return result

	var expected_area_size: int = get_complete_radius_cell_count(radius)
	var distance_map: Dictionary = hex_map.get_distance_map(distance_origin)
	for column in range(hex_map.definition.width):
		for row in range(hex_map.definition.height):
			var center := Vector2i(column, row)
			var hex_definition = hex_map.get_hex(center)
			if hex_definition == null or hex_definition.region_id != region_id:
				continue
			var distance: int = int(distance_map.get(center, -1))
			if distance < min_distance or distance > max_distance:
				continue
			if not matches_allowed_terrain(hex_definition, allowed_terrain_ids):
				continue
			if not matches_allowed_tags(hex_definition, allowed_tags):
				continue
			if has_forbidden_tag(hex_definition, forbidden_tags):
				continue

			var occupied_cells: Array[Vector2i] = hex_map.get_cells_within_radius(center, radius)
			if occupied_cells.size() != expected_area_size:
				continue
			if not area_is_available(occupied_cells, region_id, hex_map, world_state):
				continue
			result.append(center)
	return result

func matches_allowed_terrain(hex_definition, allowed_terrain_ids: PackedStringArray) -> bool:
	if allowed_terrain_ids.is_empty():
		return true
	return allowed_terrain_ids.has(hex_definition.terrain_id)

func matches_allowed_tags(hex_definition, allowed_tags: PackedStringArray) -> bool:
	if allowed_tags.is_empty():
		return true
	for tag in allowed_tags:
		if hex_definition.has_tag(tag):
			return true
	return false

func has_forbidden_tag(hex_definition, forbidden_tags: PackedStringArray) -> bool:
	for tag in forbidden_tags:
		if hex_definition.has_tag(tag):
			return true
	return false

func area_is_available(cells: Array[Vector2i], region_id: String, hex_map, world_state) -> bool:
	for cell in cells:
		var hex_definition = hex_map.get_hex(cell)
		if hex_definition == null or hex_definition.region_id != region_id:
			return false
		if world_state.is_hex_occupied(cell):
			return false
	return true

func get_complete_radius_cell_count(radius: int) -> int:
	return 1 + 3 * radius * (radius + 1)
