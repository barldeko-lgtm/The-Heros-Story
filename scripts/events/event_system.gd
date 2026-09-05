class_name EventSystem
extends RefCounted

const ActivityPlacementFinderScript = preload("res://scripts/world/activity_placement_finder.gd")
const EventDefinitionScript = preload("res://scripts/model/definitions/event_definition.gd")
const EventInstanceScript = preload("res://scripts/model/runtime/event_instance.gd")
const DEFAULT_EVENT_DIRECTORIES := [
	"res://data/events/starting_region",
	"res://data/events/mid_region",
]
const MAX_ACTIVE_EVENTS: int = 4
const FIRST_EVENT_SPAWN_TICK: int = 100

var event_definitions: Array[Resource] = []
var active_events: Array = []
var placement_finder = ActivityPlacementFinderScript.new()
var hex_map
var world_state
var placement_random_number_generator: RandomNumberGenerator
var distance_origin_by_region: Dictionary = {}
var spawned_definition_ids: Dictionary = {}

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
	spawned_definition_ids.clear()
	spawn_initial_population_if_ready(spawn_tick)
	return true

func spawn_initial_population_if_ready(world_tick: int) -> Array:
	var spawned_events: Array = []
	if world_tick < FIRST_EVENT_SPAWN_TICK:
		return spawned_events
	if hex_map == null or world_state == null or placement_random_number_generator == null:
		return spawned_events
	for definition in event_definitions:
		if active_events.size() >= MAX_ACTIVE_EVENTS:
			break
		if spawned_definition_ids.has(definition.id):
			continue
		if not distance_origin_by_region.has(definition.region_id):
			continue
		if not spawn_definition(definition, distance_origin_by_region[definition.region_id], world_tick):
			continue
		spawned_definition_ids[definition.id] = true
		spawned_events.append(active_events[active_events.size() - 1])
	return spawned_events

func has_unspawned_initial_population() -> bool:
	for definition in event_definitions:
		if distance_origin_by_region.has(definition.region_id) and not spawned_definition_ids.has(definition.id):
			return true
	return false

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
	var target_hex: Vector2i = valid_centers[placement_random_number_generator.randi_range(0, valid_centers.size() - 1)]
	var activity_id := "event:%s" % definition.id
	var footprint: Array[Vector2i] = hex_map.get_cells_within_radius(target_hex, definition.placement_radius)
	if not world_state.reserve_activity(activity_id, footprint):
		return false
	active_events.append(EventInstanceScript.new(definition, target_hex, activity_id, spawn_tick))
	return true

func clear_instances() -> void:
	if world_state != null:
		for instance in active_events:
			if instance != null and not instance.map_activity_id.is_empty():
				world_state.release_activity(instance.map_activity_id)
	active_events.clear()

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

func engage(instance) -> bool:
	return instance != null and active_events.has(instance) and instance.engage()

func complete_instance(instance, outcome_id: String) -> bool:
	if instance == null or not active_events.has(instance):
		return false
	instance.mark_completed(outcome_id)
	if world_state != null and not instance.map_activity_id.is_empty():
		world_state.release_activity(instance.map_activity_id)
	instance.clear_map_activity()
	active_events.erase(instance)
	return true

func advance_world_tick(world_tick: int) -> Array:
	var expired: Array = []
	for instance in active_events.duplicate():
		if instance == null or not instance.is_expired(world_tick):
			continue
		if world_state != null and not instance.map_activity_id.is_empty():
			world_state.release_activity(instance.map_activity_id)
		instance.clear_map_activity()
		active_events.erase(instance)
		expired.append(instance)
	return expired
