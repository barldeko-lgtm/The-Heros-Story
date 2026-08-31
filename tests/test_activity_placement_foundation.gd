extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const ActivityPlacementFinderScript = preload("res://scripts/world/activity_placement_finder.gd")
const HexDefinitionScript = preload("res://scripts/model/definitions/hex_definition.gd")

func _init() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var simulation = SimulationScript.new(41, null)
	var hex_map = simulation.hex_map
	var world_state = simulation.world_state
	var finder = ActivityPlacementFinderScript.new()
	var start: Vector2i = hex_map.definition.starting_city_center
	var region_id: String = hex_map.STARTING_REGION_ID

	var radius_zero: Array[Vector2i] = hex_map.get_cells_within_radius(start, 0)
	assert(radius_zero == [start], "Radius 0 must contain only the center hex.")
	var radius_one: Array[Vector2i] = hex_map.get_cells_within_radius(start, 1)
	assert(radius_one.size() == 7, "Radius 1 must contain the center plus its six direct neighbors.")
	assert(radius_one.has(start), "Radius 1 must retain its center hex.")
	for neighbor in hex_map.get_neighbors(start):
		assert(radius_one.has(neighbor), "Radius 1 must include every direct neighbor.")

	var single_cell: Array[Vector2i] = [start]
	assert(world_state.reserve_activity("test_single", single_cell), "A free valid hex must be reservable by one activity.")
	assert(world_state.is_hex_occupied(start), "Reserved hex must report occupied.")
	assert(world_state.get_activity_id_at_hex(start) == "test_single", "Occupied hex must expose the reserving activity id.")
	var free_probe: Vector2i = hex_map.get_neighbors(start)[0]
	var overlapping_request: Array[Vector2i] = [start, free_probe]
	assert(not world_state.reserve_activity("test_overlap", overlapping_request), "Reservation must fail if any requested hex is already occupied.")
	assert(not world_state.is_hex_occupied(free_probe), "Failed overlapping reservation must not partially reserve its other cells.")
	assert(world_state.release_activity("test_single"), "Existing activity reservation must be releasable.")
	assert(not world_state.is_hex_occupied(start), "Released hex must become free again.")
	assert(world_state.get_activity_id_at_hex(start).is_empty(), "Released hex must no longer report an activity id.")
	assert(not world_state.release_activity("test_single"), "Releasing the same activity twice must fail cleanly.")

	var distance_candidates: Array[Vector2i] = finder.find_valid_centers(
		hex_map,
		world_state,
		region_id,
		start,
		2,
		3,
		PackedStringArray(),
		PackedStringArray(),
		PackedStringArray([HexDefinitionScript.TAG_CITY]),
		0
	)
	assert(not distance_candidates.is_empty(), "Starting Region must expose non-city placement candidates at distance 2..3.")
	for candidate in distance_candidates:
		var candidate_hex = hex_map.get_hex(candidate)
		var distance: int = hex_map.get_distance_steps(start, candidate)
		assert(candidate_hex.region_id == region_id, "Placement center must stay inside the requested region.")
		assert(distance >= 2 and distance <= 3, "Placement center must obey the inclusive distance range.")
		assert(not candidate_hex.has_tag(HexDefinitionScript.TAG_CITY), "Forbidden tags must reject matching center hexes.")

	var road_candidates: Array[Vector2i] = finder.find_valid_centers(
		hex_map,
		world_state,
		region_id,
		start,
		0,
		hex_map.REGION_RADIUS_STEPS,
		PackedStringArray(),
		PackedStringArray([HexDefinitionScript.TAG_ROAD]),
		PackedStringArray([HexDefinitionScript.TAG_CITY]),
		0
	)
	assert(not road_candidates.is_empty(), "Starting Region must expose at least one non-city road placement candidate.")
	for candidate in road_candidates:
		var candidate_hex = hex_map.get_hex(candidate)
		assert(candidate_hex.has_tag(HexDefinitionScript.TAG_ROAD), "Non-empty allowed tag list must require at least one matching center tag.")
		assert(not candidate_hex.has_tag(HexDefinitionScript.TAG_CITY), "Forbidden city tag must still win over an allowed road tag.")

	var forest_candidates: Array[Vector2i] = finder.find_valid_centers(
		hex_map,
		world_state,
		region_id,
		start,
		1,
		hex_map.REGION_RADIUS_STEPS,
		PackedStringArray(["forest"]),
		PackedStringArray(),
		PackedStringArray([HexDefinitionScript.TAG_CITY]),
		0
	)
	assert(not forest_candidates.is_empty(), "Starting Region must expose at least one non-city forest placement candidate.")
	for candidate in forest_candidates:
		assert(hex_map.get_hex(candidate).terrain_id == "forest", "Allowed terrain ids must filter placement centers by terrain.")

	var radius_one_candidates: Array[Vector2i] = finder.find_valid_centers(
		hex_map,
		world_state,
		region_id,
		start,
		1,
		hex_map.REGION_RADIUS_STEPS,
		PackedStringArray(),
		PackedStringArray(),
		PackedStringArray([HexDefinitionScript.TAG_CITY]),
		1
	)
	assert(not radius_one_candidates.is_empty(), "Starting Region must expose at least one complete free radius-1 activity area.")
	for candidate in radius_one_candidates:
		var area: Array[Vector2i] = hex_map.get_cells_within_radius(candidate, 1)
		assert(area.size() == 7, "Every radius-1 placement candidate must own a complete seven-hex area.")
		for cell in area:
			assert(hex_map.get_hex(cell).region_id == region_id, "Every occupied event hex must remain inside the requested region.")
			assert(not world_state.is_hex_occupied(cell), "Every occupied event hex must be free before placement.")

	var reserved_center: Vector2i = radius_one_candidates[0]
	var reserved_area: Array[Vector2i] = hex_map.get_cells_within_radius(reserved_center, 1)
	assert(world_state.reserve_activity("test_event", reserved_area), "A complete free radius-1 area must reserve atomically.")
	var after_reservation: Array[Vector2i] = finder.find_valid_centers(
		hex_map,
		world_state,
		region_id,
		start,
		1,
		hex_map.REGION_RADIUS_STEPS,
		PackedStringArray(),
		PackedStringArray(),
		PackedStringArray([HexDefinitionScript.TAG_CITY]),
		1
	)
	assert(not after_reservation.has(reserved_center), "An occupied activity area must remove its center from future placement candidates.")
	for candidate in after_reservation:
		for cell in hex_map.get_cells_within_radius(candidate, 1):
			assert(not world_state.is_hex_occupied(cell), "Future placement candidates must not overlap any occupied activity hex.")
	assert(world_state.release_activity("test_event"), "Radius-1 activity reservation must release all seven hexes together.")
	for cell in reserved_area:
		assert(not world_state.is_hex_occupied(cell), "Releasing an activity must free every hex reserved by that activity.")

	var boundary_center := Vector2i(-1, -1)
	for column in range(hex_map.definition.width):
		for row in range(hex_map.definition.height):
			var probe := Vector2i(column, row)
			var probe_hex = hex_map.get_hex(probe)
			if probe_hex == null or probe_hex.region_id != region_id:
				continue
			var probe_area: Array[Vector2i] = hex_map.get_cells_within_radius(probe, 1)
			if probe_area.size() != 7:
				boundary_center = probe
				break
			var crosses_region: bool = false
			for cell in probe_area:
				if hex_map.get_hex(cell).region_id != region_id:
					crosses_region = true
					break
			if crosses_region:
				boundary_center = probe
				break
		if boundary_center != Vector2i(-1, -1):
			break
	assert(boundary_center != Vector2i(-1, -1), "Current authored Starting Region must have at least one radius-1 boundary probe.")
	var all_radius_one_candidates: Array[Vector2i] = finder.find_valid_centers(
		hex_map,
		world_state,
		region_id,
		start,
		0,
		hex_map.REGION_RADIUS_STEPS,
		PackedStringArray(),
		PackedStringArray(),
		PackedStringArray(),
		1
	)
	assert(not all_radius_one_candidates.has(boundary_center), "Radius-1 activity center must be rejected when any occupied hex would leave the region or map.")

	print("PASS: Activity placement foundation enforces radius areas, one activity per hex, atomic reservations, region bounds, distance, terrain, and tag filters.")
	quit()
