class_name HexDefinition
extends RefCounted

var coordinates: Vector2i
var terrain_id: String
var region_id: String

func _init(initial_coordinates: Vector2i, initial_terrain_id: String, initial_region_id: String = "") -> void:
	coordinates = initial_coordinates
	terrain_id = initial_terrain_id
	region_id = initial_region_id
