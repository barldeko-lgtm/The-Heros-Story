extends SceneTree

const HexMapScript = preload("res://scripts/world/hex_map.gd")
const WorldStateScript = preload("res://scripts/world/world_state.gd")
const TravelSystemScript = preload("res://scripts/world/travel_system.gd")
const MapDefinition = preload("res://data/map/prototype_02_map.tres")

func _init() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var hex_map = HexMapScript.new(MapDefinition)
	var world_state = WorldStateScript.new(hex_map)
	var travel_system = TravelSystemScript.new(hex_map, world_state)
	var start: Vector2i = world_state.hero_position
	var destination := Vector2i(-1, -1)
	for column in range(hex_map.definition.width):
		for row in range(hex_map.definition.height):
			var probe := Vector2i(column, row)
			if hex_map.get_distance_steps(start, probe) == 4:
				destination = probe
				break
		if destination != Vector2i(-1, -1):
			break
	assert(destination != Vector2i(-1, -1), "TravelSystem test requires a valid destination four steps from Starting City.")

	var expected_route: Array[Vector2i] = hex_map.find_path(start, destination)
	assert(expected_route.size() == 5, "Four-step route must contain start plus four destination steps.")
	assert(travel_system.begin_travel(destination), "TravelSystem must start a route to a valid destination.")
	assert(world_state.hero_position == start, "Starting travel must not teleport the hero before a world tick occurs.")
	assert(travel_system.get_remaining_steps() == 4, "TravelSystem must expose the exact remaining route length in hex steps.")
	assert(travel_system.get_route() == expected_route, "TravelSystem must use HexMap's deterministic shortest route.")

	for step_index in range(1, expected_route.size()):
		var previous_position: Vector2i = world_state.hero_position
		var result: Dictionary = travel_system.advance_one_tick()
		assert(result["moved"], "Each active travel tick must move the hero exactly once.")
		assert(world_state.hero_position == expected_route[step_index], "Each travel tick must advance to the next stored route cell.")
		assert(hex_map.get_neighbors(previous_position).has(world_state.hero_position), "Each travel move must enter a directly adjacent hex.")
		assert(int(result["remaining_steps"]) == expected_route.size() - 1 - step_index, "Remaining travel steps must decrease by exactly one per world tick.")
		assert(bool(result["arrived"]) == (step_index == expected_route.size() - 1), "TravelSystem must report arrival only on the destination step.")

	assert(world_state.hero_position == destination, "Hero must finish travel on the requested destination hex.")
	assert(travel_system.get_remaining_steps() == 0, "Arrived travel must have zero remaining steps.")
	assert(not travel_system.is_travelling(), "Arrived route must no longer report active movement.")
	assert(not travel_system.begin_travel(Vector2i(-1, -1)), "TravelSystem must reject destinations outside the authored map.")
	assert(world_state.hero_position == destination, "Rejected travel must not change hero position.")

	print("PASS: TravelSystem moves the hero exactly one adjacent hex per world tick along the deterministic route.")
	quit()
