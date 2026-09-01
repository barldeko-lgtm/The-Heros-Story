class_name MapScreen
extends Control

const MapDefinitionResource = preload("res://data/map/prototype_02_map.tres")
const HexMapScript = preload("res://scripts/world/hex_map.gd")
const HexMapImageDecoderScript = preload("res://scripts/world/hex_map_image_decoder.gd")
const MapTileVisualsScript = preload("res://scripts/ui/map_tile_visuals.gd")
const HEX_TILE_SIZE: Vector2 = Vector2(158.0, 140.0)
const HEX_HALF_WIDTH: float = HEX_TILE_SIZE.x * 0.5
const HEX_HALF_HEIGHT: float = HEX_TILE_SIZE.y * 0.5
const HEX_COLUMN_STEP: float = HEX_TILE_SIZE.x * 0.75
const HEX_ROW_STEP: float = HEX_TILE_SIZE.y
const HEX_OUTLINE_COLOR: Color = Color.BLACK
const HEX_OUTLINE_WIDTH: float = 1.0
const HERO_MAP_DRAW_HEIGHT: float = 120.0
const HERO_MAP_DRAW_OFFSET: Vector2 = Vector2(0.0, -5.0)
const QUEST_MAP_DRAW_HEIGHT: float = 65.0
const DUNGEON_MAP_DRAW_HEIGHT: float = 65.0
const QUEST_SELECTED_OUTLINE_COLOR: Color = Color("ff8c00")
const QUEST_SELECTED_OUTLINE_NEAR_OFFSET: float = 2.0
const QUEST_SELECTED_OUTLINE_MIDDLE_OFFSET: float = 4.0
const QUEST_SELECTED_OUTLINE_OUTER_OFFSET: float = 6.0
const QUEST_SELECTED_OUTLINE_NEAR_ALPHA: float = 1.0
const QUEST_SELECTED_OUTLINE_MIDDLE_ALPHA: float = 0.75
const QUEST_SELECTED_OUTLINE_OUTER_ALPHA: float = 0.45
const QUEST_MARKER_RADIUS: float = 13.0
const QUEST_MARKER_INNER_RADIUS: float = 10.0
const QUEST_MARKER_OUTER_COLOR: Color = Color("2d3138")
const QUEST_MARKER_INNER_COLOR: Color = Color("f0c94b")
const QUEST_MARKER_TEXT_COLOR: Color = Color("20242a")
const DUNGEON_MARKER_OUTER_COLOR: Color = Color("3f3448")
const DUNGEON_MARKER_STONE_COLOR: Color = Color("8d785f")
const DUNGEON_MARKER_ENTRANCE_COLOR: Color = Color("17151a")
const DUNGEON_MARKER_TEXT_COLOR: Color = Color("2a202f")
const DUNGEON_UNDISCOVERED_DEBUG_ALPHA: float = 0.40
const MAP_ORIGIN: Vector2 = Vector2.ZERO
const MIN_MAP_ZOOM: float = 0.6
const MAX_MAP_ZOOM: float = 2.0
const MAP_ZOOM_STEP: float = 1.15
const MIN_VISIBLE_MAP_PIXELS: float = 80.0
const MAP_VIEW_TOP: float = 76.0

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

const REGION_DISPLAY_NAMES: Dictionary = {
	"starting_region": "Стартовый регион",
	"mid_region": "Средний регион",
}

const HEX_TAG_DISPLAY_NAMES: Dictionary = {
	"city": "Город",
	"city_center": "Центр города",
	"road": "Дорога",
}

var simulation
var hex_map
var map_definition = MapDefinitionResource
var map_tile_visuals
var hex_centers: Dictionary = {}
var terrain_counts: Dictionary = {}
var last_hero_position: Vector2i = Vector2i(-1, -1)
var last_quest_marker_signature: String = ""
var last_dungeon_marker_signature: String = ""
var hex_tooltip_panel: PanelContainer
var hex_tooltip_label: Label
var map_zoom: float = 1.0
var map_pan_offset: Vector2 = Vector2.ZERO
var map_bounds: Rect2 = Rect2()
var right_mouse_dragging: bool = false

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
	map_tile_visuals = MapTileVisualsScript.new()
	build_draw_cache()
	calculate_map_bounds()
	center_map_on_starting_city()
	create_hex_tooltip()
	mouse_exited.connect(hide_hex_tooltip)
	last_hero_position = get_hero_cell()
	last_quest_marker_signature = get_quest_marker_signature()
	last_dungeon_marker_signature = get_dungeon_marker_signature()
	queue_redraw()

func _process(_delta: float) -> void:
	if simulation == null or simulation.world_state == null:
		return
	var redraw_needed: bool = false
	var current_hero_position: Vector2i = get_hero_cell()
	if current_hero_position != last_hero_position:
		last_hero_position = current_hero_position
		redraw_needed = true
	var current_quest_marker_signature: String = get_quest_marker_signature()
	if current_quest_marker_signature != last_quest_marker_signature:
		last_quest_marker_signature = current_quest_marker_signature
		redraw_needed = true
	var current_dungeon_marker_signature: String = get_dungeon_marker_signature()
	if current_dungeon_marker_signature != last_dungeon_marker_signature:
		last_dungeon_marker_signature = current_dungeon_marker_signature
		redraw_needed = true
	if redraw_needed:
		queue_redraw()

func get_hero_cell() -> Vector2i:
	if simulation != null and simulation.world_state != null:
		return simulation.world_state.hero_position
	return map_definition.starting_city_center

func get_quest_marker_offers() -> Array:
	var result: Array = []
	if simulation == null or simulation.quest_pool == null:
		return result
	for offer in simulation.quest_pool.get_available_quests():
		if offer == null or not offer.has_method("has_map_target") or not offer.has_map_target():
			continue
		if not hex_centers.has(offer.target_hex):
			continue
		result.append(offer)
	return result

func get_quest_marker_signature() -> String:
	var parts := PackedStringArray()
	for offer in get_quest_marker_offers():
		parts.append("%s:%d:%d" % [offer.map_activity_id, offer.target_hex.x, offer.target_hex.y])
	if simulation != null and simulation.hero_state != null:
		var active_quest = simulation.hero_state.active_quest
		if active_quest != null and active_quest.has_method("has_map_target") and active_quest.has_map_target():
			parts.append("selected:%s" % active_quest.map_activity_id)
	parts.sort()
	return "|".join(parts)

func is_selected_quest_offer(offer) -> bool:
	return simulation != null and simulation.hero_state != null and simulation.hero_state.active_quest == offer

func get_discovered_dungeons() -> Array:
	if simulation == null or simulation.dungeon_system == null:
		return []
	return simulation.dungeon_system.get_discovered_dungeons()

func get_dungeon_marker_instances() -> Array:
	if simulation == null or simulation.dungeon_system == null:
		return []
	return simulation.dungeon_system.get_all_dungeons()

func get_dungeon_marker_signature() -> String:
	var parts := PackedStringArray()
	for dungeon_instance in get_dungeon_marker_instances():
		if dungeon_instance == null or not dungeon_instance.has_map_target() or not hex_centers.has(dungeon_instance.target_hex):
			continue
		parts.append("%s:%d:%d:%s" % [dungeon_instance.map_activity_id, dungeon_instance.target_hex.x, dungeon_instance.target_hex.y, str(dungeon_instance.discovered)])
	parts.sort()
	return "|".join(parts)

func get_dungeon_marker_alpha(dungeon_instance) -> float:
	if dungeon_instance != null and dungeon_instance.discovered:
		return 1.0
	return DUNGEON_UNDISCOVERED_DEBUG_ALPHA

func get_discovered_dungeon_at_hex(cell: Vector2i):
	if simulation == null or simulation.dungeon_system == null:
		return null
	return simulation.dungeon_system.get_discovered_dungeon_at_hex(cell)

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
		HEX_COLUMN_STEP * float(cell.x),
		HEX_ROW_STEP * (float(cell.y) + 0.5 * float(cell.x % 2))
	)

func get_hex_polygon(center: Vector2) -> PackedVector2Array:
	return PackedVector2Array([
		center + Vector2(HEX_HALF_WIDTH, 0.0),
		center + Vector2(HEX_HALF_WIDTH * 0.5, -HEX_HALF_HEIGHT),
		center + Vector2(-HEX_HALF_WIDTH * 0.5, -HEX_HALF_HEIGHT),
		center + Vector2(-HEX_HALF_WIDTH, 0.0),
		center + Vector2(-HEX_HALF_WIDTH * 0.5, HEX_HALF_HEIGHT),
		center + Vector2(HEX_HALF_WIDTH * 0.5, HEX_HALF_HEIGHT),
	])

func get_drawn_terrain_count(terrain_id: String) -> int:
	return int(terrain_counts.get(terrain_id, 0))

func calculate_map_bounds() -> void:
	if hex_centers.is_empty():
		map_bounds = Rect2()
		return
	var min_point := Vector2(INF, INF)
	var max_point := Vector2(-INF, -INF)
	for center_variant in hex_centers.values():
		var center: Vector2 = center_variant
		min_point.x = minf(min_point.x, center.x - HEX_HALF_WIDTH)
		min_point.y = minf(min_point.y, center.y - HEX_HALF_HEIGHT)
		max_point.x = maxf(max_point.x, center.x + HEX_HALF_WIDTH)
		max_point.y = maxf(max_point.y, center.y + HEX_HALF_HEIGHT)
	for city_center in [map_definition.starting_city_center, map_definition.mid_city_center]:
		var town_rect: Rect2 = get_city_overlay_rect(city_center)
		min_point.x = minf(min_point.x, town_rect.position.x)
		min_point.y = minf(min_point.y, town_rect.position.y)
		max_point.x = maxf(max_point.x, town_rect.end.x)
		max_point.y = maxf(max_point.y, town_rect.end.y)
	map_bounds = Rect2(min_point, max_point - min_point)

func center_map_on_starting_city() -> void:
	if size == Vector2.ZERO:
		return
	var city_center: Vector2 = get_hex_center(map_definition.starting_city_center)
	var view_center := Vector2(size.x * 0.5, (MAP_VIEW_TOP + size.y) * 0.5)
	map_pan_offset = view_center - city_center * map_zoom
	clamp_map_pan_offset()

func map_to_screen_position(map_position: Vector2) -> Vector2:
	return map_pan_offset + map_position * map_zoom

func screen_to_map_position(screen_position: Vector2) -> Vector2:
	return (screen_position - map_pan_offset) / map_zoom

func get_hex_at_local_position(local_position: Vector2):
	var map_position: Vector2 = screen_to_map_position(local_position)
	for cell in hex_centers:
		var center: Vector2 = hex_centers[cell]
		if Geometry2D.is_point_in_polygon(map_position, get_hex_polygon(center)):
			return hex_map.get_hex(cell)
	return null

func get_hex_tooltip_text(hex_definition) -> String:
	if hex_definition == null:
		return ""
	var terrain_name: String = str(TERRAIN_DISPLAY_NAMES.get(hex_definition.terrain_id, hex_definition.terrain_id))
	var region_name: String = "Нет"
	var region_raw_id: String = "none"
	if not hex_definition.region_id.is_empty():
		region_name = str(REGION_DISPLAY_NAMES.get(hex_definition.region_id, hex_definition.region_id))
		region_raw_id = hex_definition.region_id
	var tooltip_text := "Координаты: (%d, %d)\nМестность: %s [%s]\nРегион: %s [%s]\nТеги: %s" % [
		hex_definition.coordinates.x,
		hex_definition.coordinates.y,
		terrain_name,
		hex_definition.terrain_id,
		region_name,
		region_raw_id,
		get_hex_tags_tooltip_text(hex_definition.tags),
	]
	var dungeon_instance = get_discovered_dungeon_at_hex(hex_definition.coordinates)
	if dungeon_instance != null and dungeon_instance.definition != null:
		tooltip_text += "\nОбъект: %s [данж]" % dungeon_instance.definition.display_name
	return tooltip_text

func get_hex_tags_tooltip_text(tags: PackedStringArray) -> String:
	if tags.is_empty():
		return "Нет [none]"
	var display_tags := PackedStringArray()
	for tag_id in tags:
		var display_name: String = str(HEX_TAG_DISPLAY_NAMES.get(tag_id, tag_id))
		display_tags.append("%s [%s]" % [display_name, tag_id])
	return ", ".join(display_tags)

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
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			set_map_zoom_at_position(map_zoom * MAP_ZOOM_STEP, event.position)
			accept_event()
			return
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			set_map_zoom_at_position(map_zoom / MAP_ZOOM_STEP, event.position)
			accept_event()
			return
		if event.button_index == MOUSE_BUTTON_RIGHT:
			right_mouse_dragging = event.pressed
			if right_mouse_dragging:
				hide_hex_tooltip()
			else:
				update_hex_tooltip(event.position)
			accept_event()
			return
	if event is InputEventMouseMotion:
		if right_mouse_dragging:
			map_pan_offset += event.relative
			clamp_map_pan_offset()
			hide_hex_tooltip()
			queue_redraw()
			accept_event()
			return
		update_hex_tooltip(event.position)

func set_map_zoom_at_position(target_zoom: float, cursor_position: Vector2) -> void:
	var new_zoom: float = clampf(target_zoom, MIN_MAP_ZOOM, MAX_MAP_ZOOM)
	if is_equal_approx(new_zoom, map_zoom):
		return
	var map_position_under_cursor: Vector2 = screen_to_map_position(cursor_position)
	map_zoom = new_zoom
	map_pan_offset = cursor_position - map_position_under_cursor * map_zoom
	clamp_map_pan_offset()
	queue_redraw()
	update_hex_tooltip(cursor_position)

func clamp_map_pan_offset() -> void:
	if map_bounds.size == Vector2.ZERO or size == Vector2.ZERO:
		return
	var min_pan_x: float = MIN_VISIBLE_MAP_PIXELS - map_bounds.end.x * map_zoom
	var max_pan_x: float = size.x - MIN_VISIBLE_MAP_PIXELS - map_bounds.position.x * map_zoom
	var min_pan_y: float = MAP_VIEW_TOP + MIN_VISIBLE_MAP_PIXELS - map_bounds.end.y * map_zoom
	var max_pan_y: float = size.y - MIN_VISIBLE_MAP_PIXELS - map_bounds.position.y * map_zoom
	map_pan_offset.x = clampf(map_pan_offset.x, min_pan_x, max_pan_x)
	map_pan_offset.y = clampf(map_pan_offset.y, min_pan_y, max_pan_y)

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

	draw_set_transform(map_pan_offset, 0.0, Vector2(map_zoom, map_zoom))
	for column in range(map_definition.width):
		for row in range(map_definition.height):
			var cell := Vector2i(column, row)
			var center: Vector2 = hex_centers[cell]
			var terrain_id: String = hex_map.get_hex(cell).terrain_id
			draw_hex_visual(cell, center, terrain_id)

	draw_road()
	draw_city_overlay(map_definition.starting_city_center)
	draw_city_overlay(map_definition.mid_city_center)
	draw_quest_markers()
	draw_dungeon_markers()
	draw_hero_marker()
	draw_city_label(map_definition.starting_city_center, "СТАРТОВЫЙ ГОРОД", Color("3d2e22"), Vector2(-72.0, 68.0))
	draw_city_label(map_definition.mid_city_center, "СРЕДНИЙ ГОРОД", Color("302a40"), Vector2(-65.0, -58.0))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_legend()

func draw_hex_visual(cell: Vector2i, center: Vector2, terrain_id: String) -> void:
	var terrain_texture: Texture2D = map_tile_visuals.get_texture(terrain_id, cell)
	if terrain_texture != null:
		var tile_rect := Rect2(center - HEX_TILE_SIZE * 0.5, HEX_TILE_SIZE)
		draw_texture_rect(terrain_texture, tile_rect, false)
	if terrain_id != "starting_city" and terrain_id != "mid_city":
		draw_polyline(get_closed_hex_outline(center), HEX_OUTLINE_COLOR, HEX_OUTLINE_WIDTH, true)

func get_terrain_visual_variant_count(terrain_id: String) -> int:
	return map_tile_visuals.get_variant_count(terrain_id)

func get_terrain_visual_texture(terrain_id: String, cell: Vector2i):
	return map_tile_visuals.get_texture(terrain_id, cell)

func get_city_visual_texture() -> Texture2D:
	return map_tile_visuals.get_town_texture()

func get_city_overlay_rect(city_center: Vector2i) -> Rect2:
	var town_texture: Texture2D = get_city_visual_texture()
	if town_texture == null or not hex_centers.has(city_center):
		return Rect2()
	var cluster_bottom: float = -INF
	for city_cell in map_definition.get_city_cells(city_center):
		if hex_centers.has(city_cell):
			cluster_bottom = maxf(cluster_bottom, hex_centers[city_cell].y + HEX_HALF_HEIGHT)
	var town_size: Vector2 = town_texture.get_size()
	var center: Vector2 = hex_centers[city_center]
	return Rect2(Vector2(center.x - town_size.x * 0.5, cluster_bottom - town_size.y), town_size)

func draw_city_overlay(city_center: Vector2i) -> void:
	var town_texture: Texture2D = get_city_visual_texture()
	if town_texture == null:
		return
	draw_texture_rect(town_texture, get_city_overlay_rect(city_center), false)

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

func get_hero_visual_texture() -> Texture2D:
	return map_tile_visuals.get_hero_map_texture()

func get_quest_visual_texture() -> Texture2D:
	return map_tile_visuals.get_quest_map_texture()

func get_quest_outline_mask_texture() -> Texture2D:
	return map_tile_visuals.get_quest_outline_mask_texture()

func get_dungeon_visual_texture() -> Texture2D:
	return map_tile_visuals.get_dungeon_map_texture()

func get_hero_visual_rect() -> Rect2:
	var hero_texture: Texture2D = get_hero_visual_texture()
	var hero_cell: Vector2i = get_hero_cell()
	if hero_texture == null or not hex_centers.has(hero_cell):
		return Rect2()
	var source_size: Vector2 = hero_texture.get_size()
	if source_size.y <= 0.0:
		return Rect2()
	var draw_scale: float = HERO_MAP_DRAW_HEIGHT / source_size.y
	var draw_size: Vector2 = source_size * draw_scale
	return Rect2(hex_centers[hero_cell] + HERO_MAP_DRAW_OFFSET - draw_size * 0.5, draw_size)

func get_quest_marker_rect(offer) -> Rect2:
	var quest_texture: Texture2D = get_quest_visual_texture()
	if quest_texture == null or offer == null or not offer.has_method("has_map_target") or not offer.has_map_target() or not hex_centers.has(offer.target_hex):
		return Rect2()
	var source_size: Vector2 = quest_texture.get_size()
	if source_size.y <= 0.0:
		return Rect2()
	var draw_scale: float = QUEST_MAP_DRAW_HEIGHT / source_size.y
	var draw_size: Vector2 = source_size * draw_scale
	return Rect2(hex_centers[offer.target_hex] - draw_size * 0.5, draw_size)

func get_dungeon_marker_rect(dungeon_instance) -> Rect2:
	var dungeon_texture: Texture2D = get_dungeon_visual_texture()
	if dungeon_texture == null or dungeon_instance == null or not dungeon_instance.has_map_target() or not hex_centers.has(dungeon_instance.target_hex):
		return Rect2()
	var source_size: Vector2 = dungeon_texture.get_size()
	if source_size.y <= 0.0:
		return Rect2()
	var draw_scale: float = DUNGEON_MAP_DRAW_HEIGHT / source_size.y
	var draw_size: Vector2 = source_size * draw_scale
	return Rect2(hex_centers[dungeon_instance.target_hex] - draw_size * 0.5, draw_size)

func draw_quest_markers() -> void:
	var quest_texture: Texture2D = get_quest_visual_texture()
	var quest_outline_mask: Texture2D = get_quest_outline_mask_texture()
	for offer in get_quest_marker_offers():
		if quest_texture != null:
			var marker_rect: Rect2 = get_quest_marker_rect(offer)
			if is_selected_quest_offer(offer) and quest_outline_mask != null:
				draw_selected_quest_outline(quest_outline_mask, marker_rect)
			draw_texture_rect(quest_texture, marker_rect, false)
			continue
		var center: Vector2 = hex_centers[offer.target_hex]
		if is_selected_quest_offer(offer):
			draw_circle(center, QUEST_MARKER_RADIUS + 5.0, Color(QUEST_SELECTED_OUTLINE_COLOR, 0.75))
		draw_circle(center, QUEST_MARKER_RADIUS, QUEST_MARKER_OUTER_COLOR)
		draw_circle(center, QUEST_MARKER_INNER_RADIUS, QUEST_MARKER_INNER_COLOR)
		draw_string(ThemeDB.fallback_font, center + Vector2(-7.0, 7.0), "!", HORIZONTAL_ALIGNMENT_CENTER, 14.0, 18, QUEST_MARKER_TEXT_COLOR)

func draw_dungeon_markers() -> void:
	var dungeon_texture: Texture2D = get_dungeon_visual_texture()
	for dungeon_instance in get_dungeon_marker_instances():
		if dungeon_instance == null or not dungeon_instance.has_map_target() or not hex_centers.has(dungeon_instance.target_hex):
			continue
		var marker_alpha: float = get_dungeon_marker_alpha(dungeon_instance)
		if dungeon_texture != null:
			draw_texture_rect(dungeon_texture, get_dungeon_marker_rect(dungeon_instance), false, Color(1.0, 1.0, 1.0, marker_alpha))
			continue
		var center: Vector2 = hex_centers[dungeon_instance.target_hex]
		draw_circle(center, 24.0, Color(DUNGEON_MARKER_OUTER_COLOR, marker_alpha))
		draw_circle(center, 19.0, Color(DUNGEON_MARKER_STONE_COLOR, marker_alpha))
		draw_rect(Rect2(center + Vector2(-12.0, 1.0), Vector2(24.0, 17.0)), Color(DUNGEON_MARKER_STONE_COLOR, marker_alpha))
		draw_circle(center + Vector2(0.0, 3.0), 10.0, Color(DUNGEON_MARKER_ENTRANCE_COLOR, marker_alpha))
		draw_rect(Rect2(center + Vector2(-10.0, 3.0), Vector2(20.0, 15.0)), Color(DUNGEON_MARKER_ENTRANCE_COLOR, marker_alpha))
		draw_string(ThemeDB.fallback_font, center + Vector2(-27.0, 39.0), "ДАНЖ", HORIZONTAL_ALIGNMENT_CENTER, 54.0, 11, Color(DUNGEON_MARKER_TEXT_COLOR, marker_alpha))

func draw_selected_quest_outline(outline_mask_texture: Texture2D, marker_rect: Rect2) -> void:
	draw_quest_outline_layer(outline_mask_texture, marker_rect, QUEST_SELECTED_OUTLINE_OUTER_OFFSET, QUEST_SELECTED_OUTLINE_OUTER_ALPHA)
	draw_quest_outline_layer(outline_mask_texture, marker_rect, QUEST_SELECTED_OUTLINE_MIDDLE_OFFSET, QUEST_SELECTED_OUTLINE_MIDDLE_ALPHA)
	draw_quest_outline_layer(outline_mask_texture, marker_rect, QUEST_SELECTED_OUTLINE_NEAR_OFFSET, QUEST_SELECTED_OUTLINE_NEAR_ALPHA)

func draw_quest_outline_layer(outline_mask_texture: Texture2D, marker_rect: Rect2, offset_distance: float, alpha: float) -> void:
	var layer_color := Color(QUEST_SELECTED_OUTLINE_COLOR, alpha)
	for x in [-1, 0, 1]:
		for y in [-1, 0, 1]:
			if x == 0 and y == 0:
				continue
			var offset := Vector2(float(x), float(y)) * offset_distance
			draw_texture_rect(outline_mask_texture, Rect2(marker_rect.position + offset, marker_rect.size), false, layer_color)

func draw_hero_marker() -> void:
	var hero_cell: Vector2i = get_hero_cell()
	if not hex_centers.has(hero_cell):
		return
	var hero_texture: Texture2D = get_hero_visual_texture()
	if hero_texture != null:
		draw_texture_rect(hero_texture, get_hero_visual_rect(), false)
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
			draw_rect(Rect2(center + Vector2(-22.0, -10.0), Vector2(44.0, 34.0)), Color("ddd0b7"))
			draw_colored_polygon(PackedVector2Array([center + Vector2(-29.0, -10.0), center + Vector2(0.0, -32.0), center + Vector2(29.0, -10.0)]), Color("513f35"))

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
