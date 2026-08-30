class_name MapScreen
extends Control

const MapDefinitionResource = preload("res://data/map/prototype_02_map.tres")
const HexMapImageDecoderScript = preload("res://scripts/world/hex_map_image_decoder.gd")
const HEX_RADIUS: float = 20.5
const HEX_HEIGHT: float = 35.507
const MAP_ORIGIN: Vector2 = Vector2(330.0, 120.0)

const TERRAIN_COLORS: Dictionary = {
	"plains": HexMapImageDecoderScript.PLAINS_COLOR,
	"forest": HexMapImageDecoderScript.FOREST_COLOR,
	"hill": HexMapImageDecoderScript.HILL_COLOR,
	"road": HexMapImageDecoderScript.ROAD_COLOR,
	"starting_city": HexMapImageDecoderScript.STARTING_CITY_COLOR,
	"hero_start": HexMapImageDecoderScript.HERO_START_COLOR,
	"mid_city": HexMapImageDecoderScript.MID_CITY_COLOR,
}

var map_definition = MapDefinitionResource
var hex_centers: Dictionary = {}
var terrain_counts: Dictionary = {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var decoded_layout: Dictionary = map_definition.reload_from_image()
	if not decoded_layout["succeeded"]:
		push_error("Map PNG could not be decoded: %s" % decoded_layout["errors"])
		return
	build_draw_cache()
	queue_redraw()

func build_draw_cache() -> void:
	hex_centers.clear()
	terrain_counts.clear()
	for column in range(map_definition.width):
		for row in range(map_definition.height):
			var cell := Vector2i(column, row)
			hex_centers[cell] = get_hex_center(cell)
			var terrain_id: String = map_definition.get_terrain_id(cell)
			terrain_counts[terrain_id] = int(terrain_counts.get(terrain_id, 0)) + 1

func get_hex_center(cell: Vector2i) -> Vector2:
	return MAP_ORIGIN + Vector2(
		HEX_RADIUS * 1.5 * float(cell.x),
		HEX_HEIGHT * (float(cell.y) + 0.5 * float(cell.x % 2))
	)

func get_hex_polygon(center: Vector2) -> PackedVector2Array:
	var points := PackedVector2Array()
	for corner_index in range(6):
		var angle: float = deg_to_rad(60.0 * float(corner_index))
		points.append(center + Vector2(cos(angle), sin(angle)) * HEX_RADIUS)
	return points

func get_drawn_terrain_count(terrain_id: String) -> int:
	return int(terrain_counts.get(terrain_id, 0))

func _draw() -> void:
	draw_rect(Rect2(0.0, 0.0, size.x, size.y), Color("d9dde2"))
	draw_string(ThemeDB.fallback_font, Vector2(32.0, 105.0), "Карта мира", HORIZONTAL_ALIGNMENT_LEFT, 240.0, 25, Color("242a31"))

	for column in range(map_definition.width):
		for row in range(map_definition.height):
			var cell := Vector2i(column, row)
			var center: Vector2 = hex_centers[cell]
			var terrain_id: String = map_definition.get_terrain_id(cell)
			draw_colored_polygon(get_hex_polygon(center), TERRAIN_COLORS[terrain_id])
			draw_polyline(get_closed_hex_outline(center), Color("39413d"), 1.25, true)
			draw_terrain_mark(center, terrain_id)

	draw_road()
	draw_city_label(map_definition.starting_city_center, "СТАРТОВЫЙ ГОРОД", Color("3d2e22"), Vector2(-72.0, 68.0))
	draw_city_label(map_definition.mid_city_center, "СРЕДНИЙ ГОРОД", Color("302a40"), Vector2(-65.0, -58.0))
	draw_legend()

func get_closed_hex_outline(center: Vector2) -> PackedVector2Array:
	var outline: PackedVector2Array = get_hex_polygon(center)
	outline.append(outline[0])
	return outline

func draw_road() -> void:
	var route_points := PackedVector2Array()
	for road_cell in map_definition.road_path:
		route_points.append(hex_centers[road_cell])
	draw_polyline(route_points, Color("5f4b32"), 10.0, true)
	draw_polyline(route_points, Color("d6bd7a"), 6.0, true)

func draw_terrain_mark(center: Vector2, terrain_id: String) -> void:
	match terrain_id:
		"plains", "road":
			draw_line(center + Vector2(-5.0, 5.0), center + Vector2(-1.0, -1.0), Color("657547"), 1.5)
			draw_line(center + Vector2(2.0, 6.0), center + Vector2(6.0, 0.0), Color("657547"), 1.5)
		"forest":
			draw_colored_polygon(PackedVector2Array([center + Vector2(0.0, -9.0), center + Vector2(-7.0, 5.0), center + Vector2(7.0, 5.0)]), Color("25482f"))
			draw_line(center + Vector2(0.0, 4.0), center + Vector2(0.0, 9.0), Color("493625"), 2.0)
		"hill":
			draw_arc(center + Vector2(-4.0, 5.0), 8.0, PI, TAU, 14, Color("66513c"), 2.0)
			draw_arc(center + Vector2(6.0, 7.0), 6.0, PI, TAU, 12, Color("66513c"), 2.0)
		"starting_city", "hero_start", "mid_city":
			draw_rect(Rect2(center + Vector2(-7.0, -3.0), Vector2(14.0, 11.0)), Color("ddd0b7"))
			draw_colored_polygon(PackedVector2Array([center + Vector2(-9.0, -3.0), center + Vector2(0.0, -10.0), center + Vector2(9.0, -3.0)]), Color("513f35"))
			if terrain_id == "hero_start":
				draw_circle(center + Vector2(0.0, 3.0), 3.0, Color("e04b5a"))

func draw_city_label(city_center: Vector2i, label_text: String, label_color: Color, offset: Vector2) -> void:
	var position: Vector2 = hex_centers[city_center] + offset
	draw_string(ThemeDB.fallback_font, position, label_text, HORIZONTAL_ALIGNMENT_CENTER, 145.0, 14, label_color)

func draw_legend() -> void:
	var panel_rect := Rect2(980.0, 132.0, 260.0, 292.0)
	draw_style_box(create_legend_style(), panel_rect)
	draw_string(ThemeDB.fallback_font, Vector2(1004.0, 168.0), "УСЛОВНЫЕ ОБОЗНАЧЕНИЯ", HORIZONTAL_ALIGNMENT_LEFT, 230.0, 15, Color("edf0f4"))
	var entries: Array[Dictionary] = [
		{"id": "plains", "text": "Равнины"},
		{"id": "forest", "text": "Лес"},
		{"id": "hill", "text": "Холмы"},
		{"id": "road", "text": "Дорога"},
		{"id": "starting_city", "text": "Стартовый город"},
		{"id": "hero_start", "text": "Старт героя"},
		{"id": "mid_city", "text": "Средний город"},
	]
	for index in range(entries.size()):
		var entry: Dictionary = entries[index]
		var entry_y: float = 198.0 + float(index) * 34.0
		draw_rect(Rect2(1005.0, entry_y - 16.0, 26.0, 22.0), TERRAIN_COLORS[entry["id"]])
		draw_rect(Rect2(1005.0, entry_y - 16.0, 26.0, 22.0), Color("aeb8c7"), false, 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(1043.0, entry_y + 1.0), entry["text"], HORIZONTAL_ALIGNMENT_LEFT, 170.0, 16, Color("edf0f4"))

func create_legend_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("232830")
	style.border_color = Color("7b8694")
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.30)
	style.shadow_size = 6
	style.shadow_offset = Vector2(0.0, 3.0)
	return style
