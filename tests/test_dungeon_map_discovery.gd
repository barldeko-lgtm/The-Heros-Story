extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")

func _init() -> void:
	call_deferred("run_test")

func run_test() -> void:
	get_root().size = Vector2i(1280, 720)
	test_spawn_and_vision_discovery()
	test_physical_hex_discovery()
	await test_map_visibility_boundary()
	print("PASS: Automatically loaded ordinary dungeons spawn on real hidden map hexes, use translucent unknown markers, and become fully visible after discovery.")
	quit()

func test_spawn_and_vision_discovery() -> void:
	var simulation = SimulationScript.new(7001, null)
	var dungeons: Array = simulation.dungeon_system.get_all_dungeons()
	assert(not dungeons.is_empty(), "At least one automatically loaded ordinary dungeon must spawn in the current slice.")
	var dungeon = find_dungeon(simulation, "abandoned_iron_mines")
	assert(dungeon != null, "The automatically loaded Abandoned Iron Mines dungeon must spawn.")
	assert(dungeon.definition.id == "abandoned_iron_mines", "The first authored dungeon must keep its stable id.")
	assert(dungeon.definition.display_name == "Заброшенные железные шахты", "The first authored dungeon must keep its approved display name.")
	assert(dungeon.has_map_target(), "The dungeon must own one concrete reserved map hex.")
	var dungeon_hex = simulation.hex_map.get_hex(dungeon.target_hex)
	assert(dungeon_hex != null and dungeon_hex.region_id == simulation.hex_map.STARTING_REGION_ID, "The first dungeon must spawn inside Starting Region.")
	assert(dungeon_hex.terrain_id == "hill", "The first dungeon must currently spawn on hill terrain.")
	var distance: int = simulation.hex_map.get_distance_steps(simulation.hex_map.definition.starting_city_center, dungeon.target_hex)
	assert(distance >= 4 and distance <= 7, "The first dungeon must respect its authored four-to-seven-hex placement band.")
	assert(simulation.world_state.get_activity_id_at_hex(dungeon.target_hex) == dungeon.map_activity_id, "The dungeon hex must be protected by its own activity reservation.")
	assert(not dungeon.discovered, "The dungeon must begin unknown to the hero.")
	assert(simulation.dungeon_system.get_discovered_dungeons().is_empty(), "Unknown dungeons must not enter the known-dungeon view.")

	var unknown_before: int = simulation.dungeon_system.get_unknown_dungeons_in_region(simulation.hex_map.STARTING_REGION_ID).size()
	assert(unknown_before >= 1, "Vision test requires at least one unknown dungeon in Starting Region.")
	var energy_before: float = simulation.god_state.energy
	assert(simulation.use_divine_vision(), "Vision must reveal one existing unknown dungeon in the current region.")
	assert(simulation.dungeon_system.get_unknown_dungeons_in_region(simulation.hex_map.STARTING_REGION_ID).size() == unknown_before - 1, "Vision must reveal exactly one existing unknown dungeon without recreating the dungeon population.")
	var vision_discovered_count: int = 0
	for discovered_dungeon in simulation.dungeon_system.get_discovered_dungeons_in_region(simulation.hex_map.STARTING_REGION_ID):
		if discovered_dungeon.discovery_source == "vision":
			vision_discovered_count += 1
	assert(vision_discovered_count == 1, "Exactly one Starting Region dungeon must record Vision as its discovery source.")
	assert(is_equal_approx(simulation.god_state.energy, energy_before - 80.0), "Vision must cost 80 Divine Energy.")
	assert(simulation.god_state.vision_cooldown_ticks == 1500, "Vision must start its 1500-world-tick cooldown.")
	assert(not simulation.use_divine_vision(), "Vision cooldown must prevent an immediate second reveal.")

func test_physical_hex_discovery() -> void:
	var simulation = SimulationScript.new(7002, null)
	var dungeon = find_dungeon(simulation, "abandoned_iron_mines")
	assert(dungeon != null, "Physical-discovery test requires the automatically loaded Abandoned Iron Mines dungeon.")
	assert(not dungeon.discovered, "Physical-discovery test dungeon must begin unknown.")
	var energy_before: float = simulation.god_state.energy
	assert(simulation.world_state.set_hero_position(dungeon.target_hex), "The hero must be able to physically enter the dungeon hex even though the dungeon reserves it as an activity.")
	assert(dungeon.discovered and dungeon.discovery_source == "hero_entered_hex", "Entering the exact dungeon hex must discover it immediately.")
	assert(is_equal_approx(simulation.god_state.energy, energy_before), "Physical discovery must not spend Divine Energy.")

func test_map_visibility_boundary() -> void:
	var simulation = SimulationScript.new(7003, null)
	var dungeon = find_dungeon(simulation, "abandoned_iron_mines")
	assert(dungeon != null, "Map visibility test requires the automatically loaded Abandoned Iron Mines dungeon.")
	var map_scene: PackedScene = load("res://scenes/ui/screens/map_screen.tscn")
	var map_screen = map_scene.instantiate()
	map_screen.setup(simulation)
	get_root().add_child(map_screen)
	await process_frame

	assert(map_screen.get_discovered_dungeons().is_empty(), "Unknown dungeon must remain absent from the hero's discovered-dungeon view.")
	assert(map_screen.get_dungeon_marker_instances().size() == simulation.dungeon_system.get_all_dungeons().size(), "Debug MapScreen must receive every active ordinary dungeon for marker rendering.")
	var dungeon_texture: Texture2D = map_screen.get_dungeon_visual_texture()
	assert(dungeon_texture != null, "Dungeon markers must use the supplied dungeon activity sprite.")
	assert(dungeon_texture.resource_path == map_screen.map_tile_visuals.DUNGEON_MAP_PATH, "Dungeon visual must use assets/map/activities/dungeon.png.")
	assert(dungeon_texture.get_size() == Vector2(440.0, 400.0), "Dungeon source sprite must retain its supplied 440 by 400 resolution.")
	var dungeon_rect: Rect2 = map_screen.get_dungeon_marker_rect(dungeon)
	assert(is_equal_approx(dungeon_rect.size.y, 65.0), "Dungeon sprite must render 65 pixels tall at base map zoom, matching the quest marker height.")
	assert(is_equal_approx(dungeon_rect.size.x, 71.5), "Dungeon sprite must preserve its 440:400 aspect ratio at 65 pixels tall.")
	assert(dungeon_rect.get_center().distance_to(map_screen.get_hex_center(dungeon.target_hex)) < 0.01, "Dungeon sprite must remain centered on its real target hex.")
	assert(is_equal_approx(map_screen.get_dungeon_marker_alpha(dungeon), 0.40), "Unknown dungeon debug marker must render at 40 percent opacity.")
	var marker_signature_before_discovery: String = map_screen.get_dungeon_marker_signature()
	assert(marker_signature_before_discovery.contains(dungeon.map_activity_id), "Debug dungeon marker signature must include the existing unknown dungeon.")
	assert(not map_screen.get_hex_tooltip_text(simulation.hex_map.get_hex(dungeon.target_hex)).contains(dungeon.definition.display_name), "Unknown dungeon identity must not leak through the hex tooltip.")

	assert(simulation.world_state.set_hero_position(dungeon.target_hex), "Map visibility test must be able to discover the selected dungeon by entering its real hex.")
	await process_frame
	assert(map_screen.get_discovered_dungeons().has(dungeon), "The physically discovered dungeon must become available to MapScreen.")
	assert(is_equal_approx(map_screen.get_dungeon_marker_alpha(dungeon), 1.0), "Discovered dungeon marker must become fully opaque.")
	assert(map_screen.get_dungeon_marker_signature() != marker_signature_before_discovery, "Discovery must change the map marker signature so the opacity redraws immediately.")
	assert(map_screen.get_hex_tooltip_text(simulation.hex_map.get_hex(dungeon.target_hex)).contains(dungeon.definition.display_name), "A discovered dungeon hex tooltip must show its dungeon name.")
	map_screen.free()

func find_dungeon(simulation, dungeon_id: String):
	for dungeon in simulation.dungeon_system.get_all_dungeons():
		if dungeon != null and dungeon.definition != null and dungeon.definition.id == dungeon_id:
			return dungeon
	return null
