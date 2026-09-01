class_name DungeonInstance
extends RefCounted

const INVALID_TARGET_HEX := Vector2i(-1, -1)

var definition: Resource
var target_hex: Vector2i = INVALID_TARGET_HEX
var map_activity_id: String = ""
var discovered: bool = false
var discovery_source: String = ""
var completed: bool = false
var failed_attempt_count: int = 0
var last_failed_attempt_start_power: float = 0.0
var last_failure_ordinary_encounters_completed: int = 0
var last_failure_reached_boss: bool = false

func _init(initial_definition: Resource, initial_target_hex: Vector2i, initial_map_activity_id: String) -> void:
	definition = initial_definition
	target_hex = initial_target_hex
	map_activity_id = initial_map_activity_id

func has_map_target() -> bool:
	return target_hex != INVALID_TARGET_HEX and not map_activity_id.is_empty()

func discover(source: String) -> bool:
	if discovered:
		return false
	discovered = true
	discovery_source = source
	return true

func has_failed_attempt() -> bool:
	return failed_attempt_count > 0

func record_failed_attempt(attempt_start_power: float, ordinary_encounters_completed: int, reached_boss: bool) -> void:
	failed_attempt_count += 1
	last_failed_attempt_start_power = maxf(0.0, attempt_start_power)
	last_failure_ordinary_encounters_completed = maxi(0, ordinary_encounters_completed)
	last_failure_reached_boss = reached_boss

func mark_completed() -> void:
	completed = true

func clear_map_activity() -> void:
	map_activity_id = ""
