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
	var hovered_start_hex = map_screen.get_hex_at_local_position(map_screen.get_hex_center(start))
	assert(hovered_start_hex != null and hovered_start_hex.coordinates == start, "Hover lookup at a hex center must return that HexDefinition.")
	var start_tooltip: String = map_screen.get_hex_tooltip_text(hovered_start_hex)
	assert(start_tooltip.contains("(%d, %d)" % [start.x, start.y]), "Debug tooltip must show hovered hex coordinates.")
	assert(start_tooltip.contains("Стартовый город") and start_tooltip.contains("starting_city"), "Debug tooltip must show the hovered hex terrain and raw terrain id.")
	var hover_event := InputEventMouseMotion.new()
	hover_event.position = map_screen.get_hex_center(start)
	map_screen._gui_input(hover_event)
	assert(map_screen.hex_tooltip_panel != null and map_screen.hex_tooltip_panel.visible, "Mouse motion over a map hex must show the visible debug tooltip panel.")
	assert(map_screen.hex_tooltip_label.text == start_tooltip, "Visible debug tooltip panel must display the hovered HexDefinition data.")
	var outside_event := InputEventMouseMotion.new()
	outside_event.position = Vector2(20.0, 20.0)
	map_screen._gui_input(outside_event)
	assert(not map_screen.hex_tooltip_panel.visible, "Moving away from all hexes must hide the debug tooltip panel.")

	var second_neighbor: Vector2i = simulation.hex_map.get_neighbors(neighbor)[0]
	assert(simulation.world_state.set_hero_position(second_neighbor), "Hero position probe requires another valid cell.")
	await process_frame
	assert(map_screen.get_hero_cell() == second_neighbor, "MapScreen must follow later WorldState position changes.")
	map_screen.free()

	print("PASS: Every map cell is a coordinate+terrain HexDefinition, routes remain valid, and MapScreen exposes interactive debug hex tooltips.")
	quit()
