class_name DungeonSystem
extends RefCounted

const ActivityPlacementFinderScript = preload("res://scripts/world/activity_placement_finder.gd")
const DungeonInstanceScript = preload("res://scripts/model/runtime/dungeon_instance.gd")

var dungeon_definitions: Array[Resource] = []
var dungeon_instances: Array = []
var placement_finder = ActivityPlacementFinderScript.new()
var hex_map
var world_state
var placement_random_number_generator: RandomNumberGenerator

func _init(initial_definitions: Array = []) -> void:
	for definition in initial_definitions:
		if definition != null:
			dungeon_definitions.append(definition)

func configure_map_placement(initial_hex_map, initial_world_state, distance_origin_by_region: Dictionary, initial_rng: RandomNumberGenerator) -> bool:
	hex_map = initial_hex_map
	world_state = initial_world_state
	placement_random_number_generator = initial_rng
	if hex_map == null or world_state == null or placement_random_number_generator == null:
		return false

	clear_instances()
	for definition in dungeon_definitions:
		if not distance_origin_by_region.has(definition.region_id):
			clear_instances()
			return false
		var distance_origin: Vector2i = distance_origin_by_region[definition.region_id]
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
			clear_instances()
			return false
		var target_hex: Vector2i = valid_centers[placement_random_number_generator.randi_range(0, valid_centers.size() - 1)]
		var activity_id := "dungeon:%s" % definition.id
		var footprint: Array[Vector2i] = hex_map.get_cells_within_radius(target_hex, definition.placement_radius)
		if not world_state.reserve_activity(activity_id, footprint):
			clear_instances()
			return false
		dungeon_instances.append(DungeonInstanceScript.new(definition, target_hex, activity_id))
	return true

func clear_instances() -> void:
	if world_state != null:
		for instance in dungeon_instances:
			if instance != null and not instance.map_activity_id.is_empty():
				world_state.release_activity(instance.map_activity_id)
	dungeon_instances.clear()

func get_all_dungeons() -> Array:
	return dungeon_instances.duplicate()

func get_discovered_dungeons() -> Array:
	var result: Array = []
	for instance in dungeon_instances:
		if instance != null and instance.discovered and not instance.completed and instance.has_map_target():
			result.append(instance)
	return result

func get_discovered_dungeons_in_region(region_id: String) -> Array:
	var result: Array = []
	for instance in dungeon_instances:
		if instance == null or not instance.discovered or instance.completed or instance.definition == null:
			continue
		if instance.definition.region_id == region_id:
			result.append(instance)
	return result

func get_unknown_dungeons_in_region(region_id: String) -> Array:
	var result: Array = []
	for instance in dungeon_instances:
		if instance == null or instance.discovered or instance.definition == null:
			continue
		if instance.definition.region_id == region_id:
			result.append(instance)
	return result

func discover_at_hex(cell: Vector2i, source: String = "hero_entered_hex") -> Array:
	var discovered_now: Array = []
	for instance in dungeon_instances:
		if instance == null or instance.discovered or instance.target_hex != cell:
			continue
		if instance.discover(source):
			discovered_now.append(instance)
	return discovered_now

func reveal_random_unknown_in_region(region_id: String, rng: RandomNumberGenerator, source: String = "vision"):
	if rng == null:
		return null
	var candidates: Array = get_unknown_dungeons_in_region(region_id)
	if candidates.is_empty():
		return null
	var selected = candidates[rng.randi_range(0, candidates.size() - 1)]
	if not selected.discover(source):
		return null
	return selected

func get_discovered_dungeon_at_hex(cell: Vector2i):
	for instance in dungeon_instances:
		if instance != null and instance.discovered and not instance.completed and instance.has_map_target() and instance.target_hex == cell:
			return instance
	return null

func remove_completed_dungeon_from_map(instance) -> bool:
	if instance == null or not instance.completed:
		return false
	if instance.map_activity_id.is_empty():
		return true
	if world_state == null or not world_state.release_activity(instance.map_activity_id):
		return false
	instance.clear_map_activity()
	return true
