extends SceneTree

const HexMapScript = preload("res://scripts/world/hex_map.gd")
const WorldStateScript = preload("res://scripts/world/world_state.gd")
const TravelSystemScript = preload("res://scripts/world/travel_system.gd")
const MapDefinition = preload("res://data/map/prototype_02_map.tres")

func _init() -> void:
	var hex_map = HexMapScript.new(MapDefinition)
	var world_state = WorldStateScript.new(hex_map)
	var travel = TravelSystemScript.new(hex_map, world_state)
	var local_cells: Array[Vector2i] = hex_map.get_cells_within_radius(world_state.hero_position, 3)
	var original_destination: Vector2i = local_cells[local_cells.size() - 1]

	assert(travel.begin_travel(original_destination))
	assert(travel.advance_one_tick()["moved"])
	assert(travel.suspend_travel(), "An in-progress route must be suspendable by a temporary event.")
	assert(travel.has_suspended_travel())
	assert(not travel.has_route())

	var detour_position: Vector2i = hex_map.get_neighbors(world_state.hero_position)[0]
	assert(world_state.set_hero_position(detour_position))
	assert(travel.resume_suspended_travel(), "Resumption must build a fresh route from the hero's new position.")
	var resumed_route: Array[Vector2i] = travel.get_route()
	assert(resumed_route[0] == detour_position)
	assert(resumed_route[resumed_route.size() - 1] == original_destination)
	assert(travel.destination == original_destination)

	print("PASS: Temporary-event travel suspension resumes toward the old destination from the new hero hex.")
	quit()
