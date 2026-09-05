extends SceneTree

func _init() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	var simulation = simulation_script.new(17, null)
	assert(simulation.hex_map != null, "Simulation must own the runtime HexMap query layer.")
	assert(simulation.world_state != null, "Simulation must own mutable WorldState.")

	var map_definition = simulation.hex_map.definition
	var start: Vector2i = map_definition.starting_city_center
	var destination: Vector2i = map_definition.mid_city_center
	assert(simulation.hex_map.get_hex_count() == map_definition.width * map_definition.height, "HexMap must create one HexDefinition for every authored map cell.")
	var starting_region_count: int = 0
	var mid_region_count: int = 0
	var no_region_count: int = 0
	var city_tag_count: int = 0
	var city_center_tag_count: int = 0
	var road_tag_count: int = 0
	for column in range(map_definition.width):
		for row in range(map_definition.height):
			var coordinates := Vector2i(column, row)
			var hex_definition = simulation.hex_map.get_hex(coordinates)
			assert(hex_definition != null, "Every authored coordinate must resolve to a HexDefinition.")
			assert(hex_definition.coordinates == coordinates, "HexDefinition must retain its own logical coordinates.")
			var expected_terrain: String = map_definition.get_terrain_id(coordinates)
			if expected_terrain == "hero_start":
				expected_terrain = "starting_city"
			assert(hex_definition.terrain_id == expected_terrain, "HexDefinition terrain must come from the decoded PNG terrain source.")
			var expected_city_tag: bool = expected_terrain == "starting_city" or expected_terrain == "mid_city"
			var expected_city_center_tag: bool = coordinates == start or coordinates == destination
			var expected_road_tag: bool = map_definition.road_path.has(coordinates)
			assert(hex_definition.has_tag("city") == expected_city_tag, "The city tag must describe all and only the fourteen city hexes.")
			assert(hex_definition.has_tag("city_center") == expected_city_center_tag, "The city_center tag must describe only the two authored city centers.")
			assert(hex_definition.has_tag("road") == expected_road_tag, "The road tag must follow the authored ordered road path, including any city-cluster entry cells.")
			if hex_definition.has_tag("city"):
				city_tag_count += 1
			if hex_definition.has_tag("city_center"):
				city_center_tag_count += 1
			if hex_definition.has_tag("road"):
				road_tag_count += 1
			if hex_definition.region_id == simulation.hex_map.STARTING_REGION_ID:
				starting_region_count += 1
				assert(simulation.hex_map.get_distance_steps(start, coordinates) <= simulation.hex_map.REGION_RADIUS_STEPS, "Starting Region hexes must remain within seven steps of Starting City center.")
			elif hex_definition.region_id == simulation.hex_map.MID_REGION_ID:
				mid_region_count += 1
				assert(simulation.hex_map.get_distance_steps(destination, coordinates) <= simulation.hex_map.REGION_RADIUS_STEPS, "Mid Region hexes must remain within seven steps of Mid-Level City center.")
			elif hex_definition.region_id.is_empty():
				no_region_count += 1
				assert(simulation.hex_map.get_distance_steps(start, coordinates) > simulation.hex_map.REGION_RADIUS_STEPS and simulation.hex_map.get_distance_steps(destination, coordinates) > simulation.hex_map.REGION_RADIUS_STEPS, "Unassigned hexes must be outside both seven-step city regions.")
			else:
				assert(false, "HexDefinition must use only an approved region id or no region.")
	assert(starting_region_count == 150, "Starting Region must contain exactly 150 hexes on the current authored map.")
	assert(mid_region_count == 150, "Mid Region must contain exactly 150 hexes on the current authored map.")
	assert(no_region_count == 90, "Exactly 90 peripheral hexes must remain outside both city regions.")
	assert(city_tag_count == 14, "Exactly fourteen hexes must carry the city tag.")
	assert(city_center_tag_count == 2, "Exactly two hexes must carry the city_center tag.")
	assert(road_tag_count == map_definition.road_path.size(), "Road-tagged hexes must match the authored road path exactly.")
	assert(simulation.hex_map.get_hex(Vector2i(12, 5)).region_id == simulation.hex_map.STARTING_REGION_ID, "The left equal-distance boundary hex must belong to Starting Region.")
	assert(simulation.hex_map.get_hex(Vector2i(13, 9)).region_id == simulation.hex_map.MID_REGION_ID, "The right equal-distance boundary hex must belong to Mid Region.")
	assert(simulation.hex_map.get_hex(start).terrain_id == "starting_city", "The technical hero-start source marker must still describe Starting City terrain.")
	assert(simulation.world_state.hero_position == start, "Hero must begin at the authored Starting City center.")

	var path: Array[Vector2i] = simulation.hex_map.find_path(start, destination)
	assert(path.size() > 1, "HexMap must find a route between the two authored city centers.")
	assert(path.front() == start and path.back() == destination, "Route endpoints must match the requested map cells.")
	for index in range(1, path.size()):
		assert(map_definition.are_adjacent(path[index - 1], path[index]), "Every route step must move to one adjacent hex.")

	var distance_steps: int = simulation.hex_map.get_distance_steps(start, destination)
	assert(distance_steps == path.size() - 1, "Hex distance must equal the number of traversed route steps.")
	assert(is_equal_approx(simulation.hex_map.get_distance_km(start, destination), float(distance_steps) * 3.0), "World scale must remain exactly 3 km per traversed hex.")

	var neighbor: Vector2i = simulation.hex_map.get_neighbors(start)[0]
	assert(simulation.world_state.set_hero_position(neighbor), "WorldState must accept a valid map cell as hero position.")
	assert(simulation.world_state.hero_position == neighbor, "WorldState must own the updated hero position.")
	assert(not simulation.world_state.set_hero_position(Vector2i(-1, -1)), "WorldState must reject positions outside the authored map.")
	assert(simulation.world_state.hero_position == neighbor, "Rejected movement must not change hero position.")

	var map_scene: PackedScene = load("res://scenes/ui/screens/map_screen.tscn")
	var map_screen = map_scene.instantiate()
	map_screen.setup(simulation)
	get_root().add_child(map_screen)
	await process_frame
	assert(map_screen.get_hero_cell() == neighbor, "MapScreen must display the hero position from live Simulation state.")
	assert(map_screen.mouse_filter != Control.MOUSE_FILTER_IGNORE, "MapScreen must receive pointer hover for interactive hex inspection.")
	var start_screen_position: Vector2 = map_screen.map_to_screen_position(map_screen.get_hex_center(start))
	var hovered_start_hex = map_screen.get_hex_at_local_position(start_screen_position)
	assert(hovered_start_hex != null and hovered_start_hex.coordinates == start, "Hover lookup at a hex center must return that HexDefinition.")
	var start_tooltip: String = map_screen.get_hex_tooltip_text(hovered_start_hex)
	assert(start_tooltip.contains("(%d, %d)" % [start.x, start.y]), "Debug tooltip must show hovered hex coordinates.")
	assert(start_tooltip.contains("Стартовый город") and start_tooltip.contains("starting_city"), "Debug tooltip must show the hovered hex terrain and raw terrain id.")
	assert(start_tooltip.contains("Стартовый регион") and start_tooltip.contains("starting_region"), "Debug tooltip must show the hovered hex region and raw region id.")
	assert(start_tooltip.contains("Теги:") and start_tooltip.contains("Город [city]") and start_tooltip.contains("Центр города [city_center]"), "Debug tooltip must show current permanent hex tags with readable and raw ids.")
	var hover_event := InputEventMouseMotion.new()
	hover_event.position = start_screen_position
	map_screen._gui_input(hover_event)
	assert(map_screen.hex_tooltip_panel != null and map_screen.hex_tooltip_panel.visible, "Mouse motion over a map hex must show the visible debug tooltip panel.")
	assert(map_screen.hex_tooltip_label.text == start_tooltip, "Visible debug tooltip panel must display the hovered HexDefinition data.")

	var initial_zoom: float = map_screen.map_zoom
	var zoom_event := InputEventMouseButton.new()
	zoom_event.button_index = MOUSE_BUTTON_WHEEL_UP
	zoom_event.pressed = true
	zoom_event.position = start_screen_position
	map_screen._gui_input(zoom_event)
	assert(map_screen.map_zoom > initial_zoom, "Mouse wheel up must zoom the map in.")
	var anchored_start_position: Vector2 = map_screen.map_to_screen_position(map_screen.get_hex_center(start))
	assert(anchored_start_position.distance_to(start_screen_position) < 0.1, "Zoom must remain anchored under the mouse cursor when clamping does not intervene.")
	var hovered_after_zoom = map_screen.get_hex_at_local_position(start_screen_position)
	assert(hovered_after_zoom != null and hovered_after_zoom.coordinates == start, "Hex hover lookup must remain correct after map zoom.")

	var pan_before: Vector2 = map_screen.map_pan_offset
	var right_down := InputEventMouseButton.new()
	right_down.button_index = MOUSE_BUTTON_RIGHT
	right_down.pressed = true
	right_down.position = start_screen_position
	map_screen._gui_input(right_down)
	var drag_event := InputEventMouseMotion.new()
	drag_event.position = start_screen_position + Vector2(70.0, 45.0)
	drag_event.relative = Vector2(70.0, 45.0)
	map_screen._gui_input(drag_event)
	assert(map_screen.map_pan_offset != pan_before, "Dragging with the right mouse button held must pan the map.")
	var right_up := InputEventMouseButton.new()
	right_up.button_index = MOUSE_BUTTON_RIGHT
	right_up.pressed = false
	right_up.position = drag_event.position
	map_screen._gui_input(right_up)
	assert(not map_screen.right_mouse_dragging, "Releasing the right mouse button must end map panning.")
	var moved_start_position: Vector2 = map_screen.map_to_screen_position(map_screen.get_hex_center(start))
	var hovered_after_pan = map_screen.get_hex_at_local_position(moved_start_position)
	assert(hovered_after_pan != null and hovered_after_pan.coordinates == start, "Hex hover lookup must remain correct after map panning.")

	map_screen.set_map_zoom_at_position(100.0, moved_start_position)
	assert(is_equal_approx(map_screen.map_zoom, map_screen.MAX_MAP_ZOOM), "Map zoom must clamp to the approved maximum.")
	map_screen.set_map_zoom_at_position(0.01, moved_start_position)
	assert(is_equal_approx(map_screen.map_zoom, map_screen.MIN_MAP_ZOOM), "Map zoom must clamp to the approved minimum.")

	var outside_event := InputEventMouseMotion.new()
	outside_event.position = Vector2(20.0, 20.0)
	map_screen._gui_input(outside_event)
	assert(not map_screen.hex_tooltip_panel.visible, "Moving away from all hexes must hide the debug tooltip panel.")

	var second_neighbor: Vector2i = simulation.hex_map.get_neighbors(neighbor)[0]
	assert(simulation.world_state.set_hero_position(second_neighbor), "Hero position probe requires another valid cell.")
	await process_frame
	assert(map_screen.get_hero_cell() == second_neighbor, "MapScreen must follow later WorldState position changes.")
	map_screen.free()

	print("PASS: Hex world data, semantic tags, regions, hover inspection, wheel zoom, and right-drag map panning work together.")
	quit()
