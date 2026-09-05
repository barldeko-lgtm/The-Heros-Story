class_name EventSystem
extends RefCounted

const ActivityPlacementFinderScript = preload("res://scripts/world/activity_placement_finder.gd")
const EventDefinitionScript = preload("res://scripts/model/definitions/event_definition.gd")
const EventInstanceScript = preload("res://scripts/model/runtime/event_instance.gd")
const DEFAULT_EVENT_DIRECTORIES := [
	"res://data/events/starting_region",
	"res://data/events/mid_region",
]
const MAX_ACTIVE_EVENTS: int = 5
const FIRST_EVENT_SPAWN_TICK: int = 100
const EVENT_ROTATION_INTERVAL_TICKS: int = 200
const EVENT_COOLDOWN_AFTER_ENGAGE_TICKS: int = 500

var event_definitions: Array[Resource] = []
var active_events: Array = []
var placement_finder = ActivityPlacementFinderScript.new()
var hex_map
var world_state
var placement_random_number_generator: RandomNumberGenerator
var distance_origin_by_region: Dictionary = {}
var current_rotation_tick: int = -1
var current_cycle_definition_ids: Array[String] = []
var cooldown_until_tick_by_definition: Dictionary = {}

func _init(initial_definitions: Array = []) -> void:
	if initial_definitions.is_empty():
		reload_from_directories()
	else:
		set_definitions(initial_definitions)

func set_definitions(definitions: Array) -> void:
	event_definitions.clear()
	for definition in definitions:
		if definition != null:
			assert(definition.get_script() == EventDefinitionScript and definition.validate_definition(), "EventDefinition must be valid before use.")
			event_definitions.append(definition)

func reload_from_directories(event_directories: Array = DEFAULT_EVENT_DIRECTORIES) -> void:
	event_definitions.clear()
	var resource_paths := PackedStringArray()
	for event_directory in event_directories:
		var directory := DirAccess.open(str(event_directory))
		if directory == null:
			continue
		var directory_resource_paths := PackedStringArray()
		directory.list_dir_begin()
		var file_name := directory.get_next()
		while not file_name.is_empty():
			if not directory.current_is_dir() and file_name.get_extension().to_lower() == "tres":
				directory_resource_paths.append("%s/%s" % [event_directory, file_name])
			file_name = directory.get_next()
		directory.list_dir_end()
		directory_resource_paths.sort()
		resource_paths.append_array(directory_resource_paths)

	var seen_ids: Dictionary = {}
	for resource_path in resource_paths:
		var resource: Resource = load(resource_path)
		assert(resource != null, "EventSystem could not load event resource: %s" % resource_path)
		if resource.get_script() != EventDefinitionScript:
			continue
		assert(resource.validate_definition(), "EventDefinition is invalid: %s" % resource_path)
		assert(not seen_ids.has(resource.id), "EventDefinition id must be unique: %s" % resource.id)
		seen_ids[resource.id] = true
		event_definitions.append(resource)

func configure_map_placement(initial_hex_map, initial_world_state, initial_distance_origin_by_region: Dictionary, initial_rng: RandomNumberGenerator, spawn_tick: int = 0) -> bool:
	hex_map = initial_hex_map
	world_state = initial_world_state
	placement_random_number_generator = initial_rng
	distance_origin_by_region = initial_distance_origin_by_region.duplicate()
	if hex_map == null or world_state == null or placement_random_number_generator == null:
		return false
	clear_instances()
	current_rotation_tick = -1
	current_cycle_definition_ids.clear()
	cooldown_until_tick_by_definition.clear()
	spawn_initial_population_if_ready(spawn_tick)
	return true

func spawn_initial_population_if_ready(world_tick: int) -> Array:
	return advance_population(world_tick)["spawned"]

func has_unspawned_initial_population() -> bool:
	if current_rotation_tick < FIRST_EVENT_SPAWN_TICK:
		return not event_definitions.is_empty()
	return has_pending_current_population(current_rotation_tick)

func is_population_rotation_tick(world_tick: int) -> bool:
	return world_tick >= FIRST_EVENT_SPAWN_TICK and (world_tick - FIRST_EVENT_SPAWN_TICK) % EVENT_ROTATION_INTERVAL_TICKS == 0

func get_latest_population_rotation_tick(world_tick: int) -> int:
	if world_tick < FIRST_EVENT_SPAWN_TICK:
		return -1
	var elapsed_ticks: int = world_tick - FIRST_EVENT_SPAWN_TICK
	return FIRST_EVENT_SPAWN_TICK + (elapsed_ticks / EVENT_ROTATION_INTERVAL_TICKS) * EVENT_ROTATION_INTERVAL_TICKS

func needs_population_placement_priority(world_tick: int) -> bool:
	if world_tick < FIRST_EVENT_SPAWN_TICK:
		return false
	var latest_rotation_tick: int = get_latest_population_rotation_tick(world_tick)
	if current_rotation_tick < latest_rotation_tick:
		return true
	return has_pending_current_population(world_tick)

func advance_population(world_tick: int) -> Dictionary:
	var result := {
		"rotated_out": [],
		"spawned": [],
	}
	if world_tick < FIRST_EVENT_SPAWN_TICK:
		return result
	if hex_map == null or world_state == null or placement_random_number_generator == null:
		return result

	var latest_rotation_tick: int = get_latest_population_rotation_tick(world_tick)
	if current_rotation_tick < latest_rotation_tick:
		result["rotated_out"] = begin_population_rotation(latest_rotation_tick)
	result["spawned"] = spawn_current_population_if_ready(world_tick)
	return result

func begin_population_rotation(rotation_tick: int) -> Array:
	var rotated_out: Array = []
	for instance in active_events.duplicate():
		if instance == null or instance.engaged:
			continue
		release_instance_reservations(instance)
		active_events.erase(instance)
		rotated_out.append(instance)

	current_rotation_tick = rotation_tick
	current_cycle_definition_ids.clear()
	var occupied_definition_ids: Dictionary = {}
	for instance in active_events:
		if instance != null and instance.definition != null:
			occupied_definition_ids[instance.definition.id] = true

	var candidates: Array[Resource] = []
	for definition in event_definitions:
		if not distance_origin_by_region.has(definition.region_id):
			continue
		if occupied_definition_ids.has(definition.id):
			continue
		if is_definition_on_cooldown(definition.id, rotation_tick):
			continue
		candidates.append(definition)

	var available_slots: int = maxi(0, MAX_ACTIVE_EVENTS - active_events.size())
	while current_cycle_definition_ids.size() < available_slots and not candidates.is_empty():
		var candidate_index: int = placement_random_number_generator.randi_range(0, candidates.size() - 1)
		var definition: Resource = candidates[candidate_index]
		candidates.remove_at(candidate_index)
		current_cycle_definition_ids.append(definition.id)
	return rotated_out

func spawn_current_population_if_ready(world_tick: int) -> Array:
	var spawned_events: Array = []
	for definition_id in current_cycle_definition_ids:
		if active_events.size() >= MAX_ACTIVE_EVENTS:
			break
		if is_definition_active(definition_id) or is_definition_on_cooldown(definition_id, world_tick):
			continue
		var definition = get_definition_by_id(definition_id)
		if definition == null or not distance_origin_by_region.has(definition.region_id):
			continue
		if not spawn_definition(definition, distance_origin_by_region[definition.region_id], world_tick):
			continue
		spawned_events.append(active_events[active_events.size() - 1])
	return spawned_events

func has_pending_current_population(world_tick: int) -> bool:
	for definition_id in current_cycle_definition_ids:
		if is_definition_active(definition_id) or is_definition_on_cooldown(definition_id, world_tick):
			continue
		return true
	return false

func get_definition_by_id(definition_id: String):
	for definition in event_definitions:
		if definition != null and definition.id == definition_id:
			return definition
	return null

func is_definition_active(definition_id: String) -> bool:
	for instance in active_events:
		if instance != null and instance.definition != null and instance.definition.id == definition_id:
			return true
	return false

func is_definition_on_cooldown(definition_id: String, world_tick: int) -> bool:
	return world_tick < int(cooldown_until_tick_by_definition.get(definition_id, 0))

func get_definition_cooldown_until_tick(definition_id: String) -> int:
	return int(cooldown_until_tick_by_definition.get(definition_id, 0))

func spawn_definition(definition: Resource, distance_origin: Vector2i, spawn_tick: int) -> bool:
	var valid_centers: Array[Vector2i] = placement_finder.find_valid_centers(
		hex_map,
		world_state,
		definition.region_id,
		distance_origin,
		definition.placement_distance_hex_min,
		definition.placement_distance_hex_max,
		definition.placement_allowed_terrain_ids,
		definition.placement_allowed_tags,
		definition.placement_forbidden_tags,
		definition.placement_radius
	)
	if valid_centers.is_empty():
		return false
	while not valid_centers.is_empty():
		var target_index: int = placement_random_number_generator.randi_range(0, valid_centers.size() - 1)
		var target_hex: Vector2i = valid_centers[target_index]
		valid_centers.remove_at(target_index)
		if try_spawn_definition_at(definition, target_hex, distance_origin, spawn_tick):
			return true
	return false

func try_spawn_definition_at(definition: Resource, target_hex: Vector2i, distance_origin: Vector2i, spawn_tick: int) -> bool:
	var footprint: Array[Vector2i] = hex_map.get_cells_within_radius(target_hex, definition.placement_radius)
	var secondary_target_hex: Vector2i = EventInstanceScript.INVALID_TARGET_HEX
	var secondary_activity_id: String = ""
	if definition.secondary_target_enabled:
		secondary_target_hex = choose_secondary_target(definition, target_hex, distance_origin, footprint)
		if secondary_target_hex == EventInstanceScript.INVALID_TARGET_HEX:
			return false

	var activity_id := "event:%s" % definition.id
	if not world_state.reserve_activity(activity_id, footprint):
		return false
	if definition.secondary_target_enabled:
		secondary_activity_id = "event:%s:secondary" % definition.id
		var secondary_footprint: Array[Vector2i] = hex_map.get_cells_within_radius(secondary_target_hex, definition.secondary_target_radius)
		if not world_state.reserve_activity(secondary_activity_id, secondary_footprint):
			world_state.release_activity(activity_id)
			return false

	active_events.append(EventInstanceScript.new(definition, target_hex, activity_id, spawn_tick, secondary_target_hex, secondary_activity_id))
	return true

func choose_secondary_target(definition: Resource, event_target_hex: Vector2i, distance_origin: Vector2i, event_footprint: Array[Vector2i]) -> Vector2i:
	var candidates: Array[Vector2i] = placement_finder.find_valid_centers(
		hex_map,
		world_state,
		definition.region_id,
		distance_origin,
		definition.secondary_target_distance_hex_min,
		definition.secondary_target_distance_hex_max,
		definition.secondary_target_allowed_terrain_ids,
		definition.secondary_target_allowed_tags,
		definition.secondary_target_forbidden_tags,
		definition.secondary_target_radius
	)
	var event_distance_from_region_origin: int = hex_map.get_distance_steps(distance_origin, event_target_hex)
	var filtered_candidates: Array[Vector2i] = []
	for candidate in candidates:
		var distance_from_event: int = hex_map.get_distance_steps(event_target_hex, candidate)
		if distance_from_event < definition.secondary_target_distance_from_event_hex_min or distance_from_event > definition.secondary_target_distance_from_event_hex_max:
			continue
		if definition.secondary_target_must_be_farther_from_region_origin:
			var candidate_distance_from_region_origin: int = hex_map.get_distance_steps(distance_origin, candidate)
			if candidate_distance_from_region_origin <= event_distance_from_region_origin:
				continue
		var overlaps_event: bool = false
		for secondary_cell in hex_map.get_cells_within_radius(candidate, definition.secondary_target_radius):
			if event_footprint.has(secondary_cell):
				overlaps_event = true
				break
		if overlaps_event:
			continue
		filtered_candidates.append(candidate)
	if filtered_candidates.is_empty():
		return EventInstanceScript.INVALID_TARGET_HEX
	return filtered_candidates[placement_random_number_generator.randi_range(0, filtered_candidates.size() - 1)]

func clear_instances() -> void:
	if world_state != null:
		for instance in active_events:
			release_instance_reservations(instance)
	active_events.clear()

func release_instance_reservations(instance) -> void:
	if instance == null or world_state == null:
		return
	if not instance.map_activity_id.is_empty():
		world_state.release_activity(instance.map_activity_id)
		instance.clear_map_activity()
	if not instance.secondary_map_activity_id.is_empty():
		world_state.release_activity(instance.secondary_map_activity_id)
		instance.clear_secondary_map_activity()

func get_active_events() -> Array:
	return active_events.duplicate()

func find_encounter_at_hex(cell: Vector2i):
	if hex_map == null:
		return null
	for instance in active_events:
		if instance == null or instance.engaged or instance.completed or not instance.has_map_target():
			continue
		var activation_cells: Array[Vector2i] = hex_map.get_cells_within_radius(instance.target_hex, instance.definition.activation_radius)
		if activation_cells.has(cell):
			return instance
	return null

func engage(instance, world_tick: int = 0) -> bool:
	if instance == null or not active_events.has(instance) or not instance.engage():
		return false
	var cooldown_until_tick: int = world_tick + EVENT_COOLDOWN_AFTER_ENGAGE_TICKS
	cooldown_until_tick_by_definition[instance.definition.id] = maxi(
		get_definition_cooldown_until_tick(instance.definition.id),
		cooldown_until_tick
	)
	return true

func complete_instance(instance, outcome_id: String) -> bool:
	if instance == null or not active_events.has(instance):
		return false
	instance.mark_completed(outcome_id)
	release_instance_reservations(instance)
	active_events.erase(instance)
	return true

func advance_world_tick(world_tick: int) -> Array:
	var expired: Array = []
	for instance in active_events.duplicate():
		if instance == null or not instance.is_expired(world_tick):
			continue
		release_instance_reservations(instance)
		active_events.erase(instance)
		expired.append(instance)
	return expired
