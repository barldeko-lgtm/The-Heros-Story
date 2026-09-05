class_name EventInstance
extends RefCounted

const INVALID_TARGET_HEX := Vector2i(-1, -1)

var definition: Resource
var target_hex: Vector2i = INVALID_TARGET_HEX
var map_activity_id: String = ""
var spawn_tick: int = 0
var expire_tick: int = 0
var current_stage_id: String = ""
var engaged: bool = false
var completed: bool = false
var outcome_id: String = ""
var local_flags: Dictionary = {}

func _init(initial_definition: Resource, initial_target_hex: Vector2i, initial_map_activity_id: String, initial_spawn_tick: int) -> void:
	definition = initial_definition
	target_hex = initial_target_hex
	map_activity_id = initial_map_activity_id
	spawn_tick = initial_spawn_tick
	expire_tick = initial_spawn_tick + maxi(1, int(definition.lifetime_ticks))
	current_stage_id = definition.start_stage_id

func has_map_target() -> bool:
	return target_hex != INVALID_TARGET_HEX and not map_activity_id.is_empty()

func is_expired(world_tick: int) -> bool:
	return not engaged and not completed and world_tick >= expire_tick

func engage() -> bool:
	if engaged or completed:
		return false
	engaged = true
	return true

func mark_completed(final_outcome_id: String) -> void:
	completed = true
	outcome_id = final_outcome_id

func clear_map_activity() -> void:
	map_activity_id = ""
