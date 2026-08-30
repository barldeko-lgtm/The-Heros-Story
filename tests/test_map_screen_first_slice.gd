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
	var hover_event := InputEventMouseMotion.new()
	hover_event.position = main_ui.map_screen.get_hex_center(map_definition.starting_city_center)
	get_root().push_input(hover_event, true)
	await process_frame
	assert(main_ui.map_screen.hex_tooltip_panel.visible, "Real viewport mouse motion over an open MapScreen hex must show the debug tooltip panel.")
	assert(main_ui.map_screen.hex_tooltip_label.text.contains("Стартовый город"), "Open MapScreen hover tooltip must display live hex terrain data.")
	main_ui.inventory_close_button.pressed.emit()
	assert(main_ui.main_screen.visible and not main_ui.map_screen.visible, "Close button must return from MapScreen to the main screen.")

	await process_frame
	await process_frame
	main_ui.free()
	print("PASS: Authored 20x15 hex map, two seven-hex cities, terrain, road, and Map menu navigation work.")
	quit()
