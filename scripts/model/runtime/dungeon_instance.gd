class_name DungeonInstance
extends RefCounted

const INVALID_TARGET_HEX := Vector2i(-1, -1)

var definition: Resource
var target_hex: Vector2i = INVALID_TARGET_HEX
var map_activity_id: String = ""
var discovered: bool = false
var discovery_source: String = ""

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
