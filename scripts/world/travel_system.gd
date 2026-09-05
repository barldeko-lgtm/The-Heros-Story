class_name TravelSystem
extends RefCounted

const INVALID_DESTINATION := Vector2i(-1, -1)

var hex_map
var world_state
var active_route: Array[Vector2i] = []
var route_index: int = 0
var destination: Vector2i = INVALID_DESTINATION
var suspended_destination: Vector2i = INVALID_DESTINATION

func _init(initial_hex_map, initial_world_state) -> void:
	hex_map = initial_hex_map
	world_state = initial_world_state
	assert(hex_map != null, "TravelSystem requires HexMap.")
	assert(world_state != null, "TravelSystem requires WorldState.")

func begin_travel(target: Vector2i) -> bool:
	clear_travel()
	return begin_active_route(target)

func begin_detour(target: Vector2i) -> bool:
	clear_active_route()
	return begin_active_route(target)

func begin_active_route(target: Vector2i) -> bool:
	if not hex_map.is_valid_cell(target):
		return false
	var route: Array[Vector2i] = hex_map.find_path(world_state.hero_position, target)
	if route.is_empty():
		return false
	active_route = route
	route_index = 0
	destination = target
	return true

func clear_active_route() -> void:
	active_route.clear()
	route_index = 0
	destination = INVALID_DESTINATION

func clear_travel() -> void:
	clear_active_route()
	suspended_destination = INVALID_DESTINATION

func suspend_travel() -> bool:
	if not is_travelling():
		return false
	suspended_destination = destination
	clear_active_route()
	return true

func has_suspended_travel() -> bool:
	return suspended_destination != INVALID_DESTINATION

func resume_suspended_travel() -> bool:
	if not has_suspended_travel():
		return false
	var target: Vector2i = suspended_destination
	suspended_destination = INVALID_DESTINATION
	return begin_travel(target)

func has_route() -> bool:
	return not active_route.is_empty()

func is_travelling() -> bool:
	return has_route() and route_index < active_route.size() - 1

func get_remaining_steps() -> int:
	if not has_route():
		return 0
	return maxi(0, active_route.size() - 1 - route_index)

func get_route() -> Array[Vector2i]:
	return active_route.duplicate()

func advance_one_tick() -> Dictionary:
	if not has_route():
		return {
			"moved": false,
			"arrived": false,
			"remaining_steps": 0,
			"position": world_state.hero_position,
		}
	if route_index >= active_route.size() - 1:
		return {
			"moved": false,
			"arrived": true,
			"remaining_steps": 0,
			"position": world_state.hero_position,
		}

	route_index += 1
	var next_position: Vector2i = active_route[route_index]
	var _assert_set_hero_position_ok_1: bool = world_state.set_hero_position(next_position)
	assert(_assert_set_hero_position_ok_1, "TravelSystem route must contain only valid map cells.")
	var arrived: bool = route_index >= active_route.size() - 1
	return {
		"moved": true,
		"arrived": arrived,
		"remaining_steps": get_remaining_steps(),
		"position": world_state.hero_position,
	}
