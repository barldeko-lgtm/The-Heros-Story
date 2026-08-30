class_name MapScreen
extends Control

const MapDefinitionResource = preload("res://data/map/prototype_02_map.tres")
const HexMapScript = preload("res://scripts/world/hex_map.gd")
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
	"mid_city": HexMapImageDecoderScript.MID_CITY_COLOR,
}

const TERRAIN_DISPLAY_NAMES: Dictionary = {
	"plains": "Равнины",
	"forest": "Лес",
	"hill": "Холмы",
	"road": "Дорога",
	"starting_city": "Стартовый город",
	"mid_city": "Средний город",
}

var simulation
var hex_map
var map_definition = MapDefinitionResource
var hex_centers: Dictionary = {}
var terrain_counts: Dictionary = {}
var last_hero_position: Vector2i = Vector2i(-1, -1)
var hex_tooltip_panel: PanelContainer
var hex_tooltip_label: Label

func setup(initial_simulation) -> void:
	simulation = initial_simulation
	if simulation != null and simulation.hex_map != null:
		hex_map = simulation.hex_map
		map_definition = hex_map.definition

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	if hex_map == null:
		hex_map = HexMapScript.new(map_definition)
		map_definition = hex_map.definition
	build_draw_cache()
	create_hex_tooltip()
	mouse_exited.connect(hide_hex_tooltip)
	last_hero_position = get_hero_cell()
	queue_redraw()

func _process(_delta: float) -> void:
	if simulation == null or simulation.world_state == null:
		return
	var current_hero_position: Vector2i = get_hero_cell()
	if current_hero_position == last_hero_position:
		return
	last_hero_position = current_hero_position
	queue_redraw()

func get_hero_cell() -> Vector2i:
	if simulation != null and simulation.world_state != null:
		return simulation.world_state.hero_position
	return map_definition.starting_city_center

func build_draw_cache() -> void:
	hex_centers.clear()
	terrain_counts.clear()
	for column in range(map_definition.width):
		for row in range(map_definition.height):
			var cell := Vector2i(column, row)
			hex_centers[cell] = get_hex_center(cell)
			var hex_definition = hex_map.get_hex(cell)
			var terrain_id: String = hex_definition.terrain_id
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

func get_hex_at_local_position(local_position: Vector2):
	for cell in hex_centers:
		var center: Vector2 = hex_centers[cell]
		if Geometry2D.is_point_in_polygon(local_position, get_hex_polygon(center)):
			return hex_map.get_hex(cell)
	return null

func get_hex_tooltip_text(hex_definition) -> String:
	if hex_definition == null:
		return ""
	var terrain_name: String = str(TERRAIN_DISPLAY_NAMES.get(hex_definition.terrain_id, hex_definition.terrain_id))
	return "Координаты: (%d, %d)\nМестность: %s [%s]" % [
		hex_definition.coordinates.x,
		hex_definition.coordinates.y,
		terrain_name,
		hex_definition.terrain_id,
	]

func create_hex_tooltip() -> void:
	hex_tooltip_panel = PanelContainer.new()
	hex_tooltip_panel.name = "HexTooltipPanel"
	hex_tooltip_panel.custom_minimum_size = Vector2(250.0, 72.0)
	hex_tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hex_tooltip_panel.z_index = 100
	var tooltip_style := StyleBoxFlat.new()
	tooltip_style.bg_color = Color("171b21")
	tooltip_style.border_color = Color("aeb8c7")
	tooltip_style.set_border_width_all(2)
	tooltip_style.set_corner_radius_all(8)
	tooltip_style.content_margin_left = 12.0
	tooltip_style.content_margin_right = 12.0
	tooltip_style.content_margin_top = 10.0
	tooltip_style.content_margin_bottom = 10.0
	hex_tooltip_panel.add_theme_stylebox_override("panel", tooltip_style)
	add_child(hex_tooltip_panel)

	hex_tooltip_label = Label.new()
	hex_tooltip_label.name = "HexTooltipLabel"
	hex_tooltip_label.add_theme_font_size_override("font_size", 15)
	hex_tooltip_label.add_theme_color_override("font_color", Color("edf0f4"))
	hex_tooltip_panel.add_child(hex_tooltip_label)
	hex_tooltip_panel.visible = false

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		update_hex_tooltip(event.position)

func update_hex_tooltip(local_position: Vector2) -> void:
	if hex_tooltip_panel == null or hex_tooltip_label == null:
		return
	var hex_definition = get_hex_at_local_position(local_position)
	if hex_definition == null:
		hide_hex_tooltip()
		return
	hex_tooltip_label.text = get_hex_tooltip_text(hex_definition)
	var tooltip_size: Vector2 = hex_tooltip_panel.get_combined_minimum_size()
	hex_tooltip_panel.size = tooltip_size
	var screen_size: Vector2 = size
	var desired_position: Vector2 = local_position + Vector2(16.0, 16.0)
	if desired_position.x + tooltip_size.x > screen_size.x - 12.0:
		desired_position.x = local_position.x - tooltip_size.x - 16.0
	if desired_position.y + tooltip_size.y > screen_size.y - 12.0:
		desired_position.y = local_position.y - tooltip_size.y - 16.0
	desired_position.x = clampf(desired_position.x, 12.0, maxf(12.0, screen_size.x - tooltip_size.x - 12.0))
	desired_position.y = clampf(desired_position.y, 76.0, maxf(76.0, screen_size.y - tooltip_size.y - 12.0))
	hex_tooltip_panel.position = desired_position
	hex_tooltip_panel.visible = true

func hide_hex_tooltip() -> void:
	if hex_tooltip_panel != null:
		hex_tooltip_panel.visible = false

func _draw() -> void:
	draw_rect(Rect2(0.0, 0.0, size.x, size.y), Color("d9dde2"))
	draw_string(ThemeDB.fallback_font, Vector2(32.0, 105.0), "Карта мира", HORIZONTAL_ALIGNMENT_LEFT, 240.0, 25, Color("242a31"))

	for column in range(map_definition.width):
		for row in range(map_definition.height):
			var cell := Vector2i(column, row)
			var center: Vector2 = hex_centers[cell]
			var terrain_id: String = hex_map.get_hex(cell).terrain_id
			draw_colored_polygon(get_hex_polygon(center), TERRAIN_COLORS[terrain_id])
			draw_polyline(get_closed_hex_outline(center), Color("39413d"), 1.25, true)
			draw_terrain_mark(center, terrain_id)

	draw_road()
	draw_hero_marker()
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

func draw_hero_marker() -> void:
	var hero_cell: Vector2i = get_hero_cell()
	if not hex_centers.has(hero_cell):
		return
	var center: Vector2 = hex_centers[hero_cell]
	draw_circle(center, 8.0, Color("f7f3e8"))
	draw_circle(center, 5.0, Color("d53b4f"))
	draw_string(ThemeDB.fallback_font, center + Vector2(-25.0, -13.0), "ГЕРОЙ", HORIZONTAL_ALIGNMENT_CENTER, 50.0, 11, Color("232830"))

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
		"starting_city", "mid_city":
			draw_rect(Rect2(center + Vector2(-7.0, -3.0), Vector2(14.0, 11.0)), Color("ddd0b7"))
			draw_colored_polygon(PackedVector2Array([center + Vector2(-9.0, -3.0), center + Vector2(0.0, -10.0), center + Vector2(9.0, -3.0)]), Color("513f35"))

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
