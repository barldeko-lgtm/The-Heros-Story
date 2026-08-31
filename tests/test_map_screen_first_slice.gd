extends SceneTree

func _init() -> void:
	call_deferred("run_test")

func run_test() -> void:
	get_root().size = Vector2i(1280, 720)
	var map_definition = load("res://data/map/prototype_02_map.tres")
	assert(map_definition != null, "Prototype 0.2 authored map definition must exist.")
	var decoded_layout: Dictionary = map_definition.reload_from_image()
	assert(decoded_layout["succeeded"], "Editable PNG map layout must decode before the authored map is inspected.")
	assert(map_definition.width == 20 and map_definition.height == 15, "Map must be exactly 20 by 15 hexes.")
	assert(map_definition.get_city_cells(map_definition.starting_city_center).size() == 7, "Starting City must occupy seven connected hexes.")
	assert(map_definition.get_city_cells(map_definition.mid_city_center).size() == 7, "Mid-Level City must occupy seven connected hexes.")
	assert(not map_definition.forest_cells.is_empty() and not map_definition.hill_cells.is_empty(), "Map must contain authored forest and hill regions around the cities.")
	assert(map_definition.validate_layout(), "Authored map cells, city clusters, terrain, and the single road must form a valid layout.")

	var map_scene: PackedScene = load("res://scenes/ui/screens/map_screen.tscn")
	assert(map_scene != null, "Dedicated MapScreen scene must exist.")
	var map_screen = map_scene.instantiate()
	get_root().add_child(map_screen)
	await process_frame
	assert(map_screen.hex_centers.size() == map_definition.width * map_definition.height, "MapScreen must draw every authored hex.")
	assert(map_screen.get_drawn_terrain_count("forest") == map_definition.forest_cells.size(), "MapScreen must preserve authored forest hexes.")
	assert(map_screen.get_drawn_terrain_count("hill") == map_definition.hill_cells.size(), "MapScreen must preserve authored hill hexes.")
	assert(is_equal_approx(map_screen.HEX_OUTLINE_WIDTH, 1.0), "Every hex outline must use a 1-pixel base width before camera zoom is applied.")
	assert(map_screen.HEX_OUTLINE_COLOR == Color.BLACK, "Every hex outline must be black.")
	for terrain_id in ["plains", "forest", "hill"]:
		assert(map_screen.get_terrain_visual_variant_count(terrain_id) == 3, "Each normal biome must expose exactly three visual sprite slots.")
		for variant_probe in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]:
			var terrain_texture: Texture2D = map_screen.get_terrain_visual_texture(terrain_id, variant_probe)
			assert(terrain_texture != null and terrain_texture.get_size() == Vector2(158.0, 140.0), "Biome sprites must remain exactly 158 by 140 pixels at base zoom.")
	var expected_visual_paths: Dictionary = {
		"plains": ["res://assets/map/biomes/plains.png", "res://assets/map/biomes/plains2.png", "res://assets/map/biomes/plains3.png"],
		"forest": ["res://assets/map/biomes/forest.png", "res://assets/map/biomes/forest2.png", "res://assets/map/biomes/forest3.png"],
		"hill": ["res://assets/map/biomes/hills.png", "res://assets/map/biomes/hills2.png", "res://assets/map/biomes/hills3.png"],
	}
	for terrain_id in expected_visual_paths:
		for variant_index in range(3):
			var probe_coordinates := Vector2i(variant_index, 0)
			var terrain_texture: Texture2D = map_screen.get_terrain_visual_texture(terrain_id, probe_coordinates)
			assert(terrain_texture.resource_path == expected_visual_paths[terrain_id][variant_index], "Each biome visual slot must use the matching project PNG file.")
	assert(map_screen.get_terrain_visual_variant_count("road") == 3, "Road cells must temporarily reuse the plains visual slots until road rendering is revisited.")
	for city_terrain_id in ["starting_city", "mid_city"]:
		var city_base_texture: Texture2D = map_screen.get_terrain_visual_texture(city_terrain_id, map_definition.starting_city_center)
		assert(city_base_texture != null and city_base_texture.resource_path.begins_with("res://assets/map/biomes/plains"), "City hexes must use plains sprites beneath the full town overlay.")
	var town_texture: Texture2D = map_screen.get_city_visual_texture()
	assert(town_texture != null and town_texture.resource_path == "res://assets/map/biomes/town1.png", "Both city clusters must use the supplied town1 PNG overlay.")
	assert(town_texture.get_size() == Vector2(418.0, 440.0), "Town overlay must remain exactly 418 by 440 pixels at base zoom.")
	for city_center in [map_definition.starting_city_center, map_definition.mid_city_center]:
		var town_rect: Rect2 = map_screen.get_city_overlay_rect(city_center)
		assert(town_rect.size == Vector2(418.0, 440.0), "Each city overlay must render at the supplied texture size without scaling.")
		assert(is_equal_approx(town_rect.get_center().x, map_screen.get_hex_center(city_center).x), "Town overlay must be centered horizontally on its city center hex.")
		var city_cluster_bottom: float = -INF
		for city_cell in map_definition.get_city_cells(city_center):
			city_cluster_bottom = maxf(city_cluster_bottom, map_screen.hex_centers[city_cell].y + map_screen.HEX_HALF_HEIGHT)
		assert(is_equal_approx(town_rect.end.y, city_cluster_bottom), "Town overlay bottom edge must align to the bottom edge of the seven-hex city cluster.")
	var hero_texture: Texture2D = map_screen.get_hero_visual_texture()
	assert(hero_texture != null, "MapScreen must use the permanent supplied hero map sprite.")
	assert(hero_texture.resource_path == map_screen.map_tile_visuals.HERO_MAP_PATH, "Hero map visual must use the permanent character asset path.")
	assert(hero_texture.get_size().y > map_screen.HERO_MAP_DRAW_HEIGHT, "The hero source sprite must retain more resolution than its normal on-map draw height.")
	var hero_rect: Rect2 = map_screen.get_hero_visual_rect()
	assert(is_equal_approx(hero_rect.size.y, 120.0), "Hero must render 120 pixels tall at base map zoom.")
	assert(hero_rect.size.x < map_screen.HEX_TILE_SIZE.x and hero_rect.size.y < map_screen.HEX_TILE_SIZE.y, "Hero map visual must fit inside one 158 by 140 hex footprint at base zoom.")
	var expected_hero_center: Vector2 = map_screen.get_hex_center(map_definition.starting_city_center) + Vector2(0.0, -5.0)
	assert(hero_rect.get_center().distance_to(expected_hero_center) < 0.01, "Hero map visual must remain centered horizontally and sit 5 pixels above the hero hex center.")
	assert(map_screen.map_tile_visuals.get_variant_index(Vector2i(0, 0)) == 0, "Visual variant selection must be deterministic by hex coordinates.")
	assert(map_screen.map_tile_visuals.get_variant_index(Vector2i(1, 0)) == 1, "Visual variant selection must expose the second slot deterministically.")
	assert(map_screen.map_tile_visuals.get_variant_index(Vector2i(2, 0)) == 2, "Visual variant selection must expose the third slot deterministically.")
	assert(map_screen.get_hex_center(Vector2i(1, 0)) - map_screen.get_hex_center(Vector2i(0, 0)) == Vector2(118.5, 70.0), "Flat-top sprite geometry must use the unscaled 158 by 140 tile footprint.")
	assert(map_screen.get_hex_center(Vector2i(0, 1)) - map_screen.get_hex_center(Vector2i(0, 0)) == Vector2(0.0, 140.0), "Hex rows must use the full unscaled 140-pixel sprite height.")
	assert(map_screen.map_bounds.size.x > 2300.0 and map_screen.map_bounds.size.y > 2000.0, "The visual map must grow to the new full-size sprite footprint.")
	map_screen.free()

	var main_scene: PackedScene = load("res://scenes/main/main.tscn")
	var main_ui: Control = main_scene.instantiate()
	get_root().add_child(main_ui)
	await process_frame
	assert(main_ui.map_screen != null and not main_ui.map_screen.visible, "Map screen must start hidden.")
	main_ui.map_button.pressed.emit()
	assert(main_ui.map_screen.visible and not main_ui.main_screen.visible, "Map button must open MapScreen and hide main developer content.")
	assert(main_ui.map_button.text == "НАЗАД", "Map button must become Back while the map is open.")
	assert(main_ui.inventory_close_button.visible, "Shared red close button must be available on MapScreen.")
	var board_offers: Array = main_ui.simulation.quest_pool.get_available_quests()
	var marker_offers: Array = main_ui.map_screen.get_quest_marker_offers()
	assert(marker_offers.size() == board_offers.size(), "Every active quest-board offer with a reserved target must have a map marker.")
	var quest_texture: Texture2D = main_ui.map_screen.get_quest_visual_texture()
	assert(quest_texture != null, "Quest map markers must use the supplied quest activity sprite.")
	assert(quest_texture.resource_path == main_ui.map_screen.map_tile_visuals.QUEST_MAP_PATH, "Quest map visual must use the permanent activity asset path.")
	assert(quest_texture.get_size() == Vector2(426.0, 400.0), "Quest source sprite must retain its supplied 426 by 400 resolution.")
	var quest_outline_mask: Texture2D = main_ui.map_screen.get_quest_outline_mask_texture()
	assert(quest_outline_mask != null and quest_outline_mask.get_size() == quest_texture.get_size(), "Selected quest highlight must have an alpha-mask texture matching the quest sprite.")
	var source_image: Image = quest_texture.get_image()
	var mask_image: Image = quest_outline_mask.get_image()
	var dark_opaque_pixel_found: bool = false
	for y in range(source_image.get_height()):
		if dark_opaque_pixel_found:
			break
		for x in range(source_image.get_width()):
			var source_pixel: Color = source_image.get_pixel(x, y)
			if source_pixel.a > 0.5 and maxf(source_pixel.r, maxf(source_pixel.g, source_pixel.b)) < 0.25:
				var mask_pixel: Color = mask_image.get_pixel(x, y)
				assert(mask_pixel.r > 0.99 and mask_pixel.g > 0.99 and mask_pixel.b > 0.99, "Quest outline mask must replace dark source RGB with white so yellow modulation stays truly yellow.")
				assert(absf(mask_pixel.a - source_pixel.a) < 0.01, "Quest outline mask must preserve the source alpha silhouette.")
				dark_opaque_pixel_found = true
				break
	assert(dark_opaque_pixel_found, "Quest sprite must contain a dark opaque pixel for alpha-mask outline regression coverage.")
	for offer in marker_offers:
		assert(offer.has_map_target() and main_ui.map_screen.hex_centers.has(offer.target_hex), "Quest map marker must resolve to the offer's concrete target hex.")
		var quest_rect: Rect2 = main_ui.map_screen.get_quest_marker_rect(offer)
		assert(is_equal_approx(quest_rect.size.y, 65.0), "Quest sprite must render 65 pixels tall at base map zoom.")
		assert(absf(quest_rect.size.x - 69.225) < 0.02, "Quest sprite must preserve its supplied aspect ratio at roughly half-hex size.")
		assert(quest_rect.get_center().distance_to(main_ui.map_screen.get_hex_center(offer.target_hex)) < 0.01, "Quest sprite must remain centered on its target hex.")
	var marker_signature_before_selection: String = main_ui.map_screen.get_quest_marker_signature()
	assert(not marker_signature_before_selection.contains("selected:"), "Quest markers must start without a selected-quest highlight before the hero chooses an offer.")
	main_ui.simulation.advance_time(10.0)
	await process_frame
	var selected_offer = main_ui.simulation.hero_state.active_quest
	assert(selected_offer != null and selected_offer.has_map_target(), "Autonomous quest selection must produce one map-backed selected offer for highlight validation.")
	assert(main_ui.map_screen.is_selected_quest_offer(selected_offer), "The hero's active QuestOffer must qualify for the selected-quest map highlight.")
	assert(main_ui.map_screen.get_quest_marker_signature().contains("selected:%s" % selected_offer.map_activity_id), "Selecting a quest must change the map marker signature so the highlight redraws immediately.")
	assert(main_ui.map_screen.QUEST_SELECTED_OUTLINE_COLOR.is_equal_approx(Color("ffe45c")), "Selected quest outline must use the bright yellow color.")
	assert(main_ui.map_screen.QUEST_SELECTED_OUTLINE_MIDDLE_ALPHA > 0.55 and main_ui.map_screen.QUEST_SELECTED_OUTLINE_OUTER_ALPHA > 0.25, "Selected quest outline must be brighter than the item-rarity middle and outer glow bands.")
	for offer in marker_offers:
		if offer != selected_offer:
			assert(not main_ui.map_screen.is_selected_quest_offer(offer), "Unselected quest markers must not receive the selected-quest highlight.")
	var start_screen_position: Vector2 = main_ui.map_screen.map_to_screen_position(main_ui.map_screen.get_hex_center(map_definition.starting_city_center))
	var hover_event := InputEventMouseMotion.new()
	hover_event.position = start_screen_position
	get_root().push_input(hover_event, true)
	await process_frame
	assert(main_ui.map_screen.hex_tooltip_panel.visible, "Real viewport mouse motion over an open MapScreen hex must show the debug tooltip panel.")
	assert(main_ui.map_screen.hex_tooltip_label.text.contains("Стартовый город"), "Open MapScreen hover tooltip must display live hex terrain data.")

	var zoom_before: float = main_ui.map_screen.map_zoom
	var wheel_event := InputEventMouseButton.new()
	wheel_event.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel_event.pressed = true
	wheel_event.position = start_screen_position
	get_root().push_input(wheel_event, true)
	await process_frame
	assert(main_ui.map_screen.map_zoom > zoom_before, "Real viewport mouse wheel input over MapScreen must zoom the map.")

	var pan_before: Vector2 = main_ui.map_screen.map_pan_offset
	var right_down := InputEventMouseButton.new()
	right_down.button_index = MOUSE_BUTTON_RIGHT
	right_down.pressed = true
	right_down.position = start_screen_position
	get_root().push_input(right_down, true)
	var drag_event := InputEventMouseMotion.new()
	drag_event.position = start_screen_position + Vector2(60.0, 40.0)
	drag_event.relative = Vector2(60.0, 40.0)
	get_root().push_input(drag_event, true)
	var right_up := InputEventMouseButton.new()
	right_up.button_index = MOUSE_BUTTON_RIGHT
	right_up.pressed = false
	right_up.position = drag_event.position
	get_root().push_input(right_up, true)
	await process_frame
	assert(main_ui.map_screen.map_pan_offset != pan_before, "Real viewport right-button drag over MapScreen must pan the map.")

	main_ui.inventory_close_button.pressed.emit()
	assert(main_ui.main_screen.visible and not main_ui.map_screen.visible, "Close button must return from MapScreen to the main screen.")

	await process_frame
	await process_frame
	main_ui.free()
	print("PASS: Authored map, navigation, real hover, wheel zoom, and right-button panning work through the live UI.")
	quit()
