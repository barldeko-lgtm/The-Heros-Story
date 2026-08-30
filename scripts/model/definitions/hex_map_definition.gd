class_name HexMapDefinition
extends Resource

const HexMapImageDecoderScript = preload("res://scripts/world/hex_map_image_decoder.gd")

@export var width: int = 20
@export var height: int = 15
@export var layout_texture: Texture2D
@export var source_hex_radius: float = 20.0
@export var source_origin: Vector2 = Vector2(22.0, 22.0)

var starting_city_center: Vector2i = Vector2i(-1, -1)
var mid_city_center: Vector2i = Vector2i(-1, -1)
var road_path: Array[Vector2i] = []
var forest_cells: Array[Vector2i] = []
var hill_cells: Array[Vector2i] = []
var terrain_by_cell: Dictionary = {}
var decoded_counts: Dictionary = {}
var last_decode_errors: PackedStringArray = []
var layout_is_loaded: bool = false

func reload_from_image() -> Dictionary:
	var decoder = HexMapImageDecoderScript.new()
	var result: Dictionary = decoder.decode(layout_texture, self)
	last_decode_errors = result["errors"]
	layout_is_loaded = bool(result["succeeded"])
	if not layout_is_loaded:
		terrain_by_cell.clear()
		decoded_counts.clear()
		starting_city_center = Vector2i(-1, -1)
		mid_city_center = Vector2i(-1, -1)
		road_path.clear()
		forest_cells.clear()
		hill_cells.clear()
		return result
	terrain_by_cell = result["terrain_by_cell"]
	decoded_counts = result["counts"]
	starting_city_center = result["starting_city_center"]
	mid_city_center = result["mid_city_center"]
	road_path.assign(result["road_path"])
	forest_cells.assign(result["forest_cells"])
	hill_cells.assign(result["hill_cells"])
	return result

func ensure_layout_loaded() -> bool:
	if not layout_is_loaded:
		reload_from_image()
	return layout_is_loaded

func get_source_pixel(cell: Vector2i) -> Vector2i:
	var source_hex_height: float = sqrt(3.0) * source_hex_radius
	return Vector2i(
		roundi(source_origin.x + source_hex_radius * 1.5 * float(cell.x)),
		roundi(source_origin.y + source_hex_height * (float(cell.y) + 0.5 * float(cell.x % 2)))
	)

func get_neighbors(cell: Vector2i) -> Array[Vector2i]:
	var offsets: Array[Vector2i]
	if cell.x % 2 == 0:
		offsets = [
			Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
			Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(0, 1),
		]
	else:
		offsets = [
			Vector2i(1, 1), Vector2i(1, 0), Vector2i(0, -1),
			Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1),
		]
	var result: Array[Vector2i] = []
	for offset in offsets:
		result.append(cell + offset)
	return result

func get_city_cells(center: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = [center]
	result.append_array(get_neighbors(center))
	return result

func is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < width and cell.y >= 0 and cell.y < height

func are_adjacent(first: Vector2i, second: Vector2i) -> bool:
	return get_neighbors(first).has(second)

func get_terrain_id(cell: Vector2i) -> String:
	if not ensure_layout_loaded():
		return ""
	return str(terrain_by_cell.get(cell, ""))

func validate_layout() -> bool:
	if not ensure_layout_loaded() or width <= 0 or height <= 0:
		return false
	if terrain_by_cell.size() != width * height:
		return false
	var starting_city_cells: Array[Vector2i] = get_city_cells(starting_city_center)
	var mid_city_cells: Array[Vector2i] = get_city_cells(mid_city_center)
	if starting_city_cells.size() != 7 or mid_city_cells.size() != 7:
		return false

	var claimed_cells: Dictionary = {}
	for city_cell in starting_city_cells + mid_city_cells:
		if not is_inside(city_cell) or claimed_cells.has(city_cell):
			return false
		claimed_cells[city_cell] = true
	if get_terrain_id(starting_city_center) != "hero_start":
		return false
	for starting_city_cell in starting_city_cells:
		if starting_city_cell != starting_city_center and get_terrain_id(starting_city_cell) != "starting_city":
			return false
	for mid_city_cell in mid_city_cells:
		if get_terrain_id(mid_city_cell) != "mid_city":
			return false

	if road_path.size() < 3:
		return false
	if not starting_city_cells.has(road_path.front()) or not mid_city_cells.has(road_path.back()):
		return false
	for path_index in range(road_path.size()):
		var road_cell: Vector2i = road_path[path_index]
		if not is_inside(road_cell):
			return false
		if path_index > 0 and not are_adjacent(road_path[path_index - 1], road_cell):
			return false
		if path_index > 0 and path_index < road_path.size() - 1 and get_terrain_id(road_cell) != "road":
			return false

	for terrain_cell in forest_cells:
		if not is_inside(terrain_cell) or get_terrain_id(terrain_cell) != "forest":
			return false
	for terrain_cell in hill_cells:
		if not is_inside(terrain_cell) or get_terrain_id(terrain_cell) != "hill":
			return false
	return true
