class_name HexDefinition
extends RefCounted

const TAG_CITY: String = "city"
const TAG_CITY_CENTER: String = "city_center"
const TAG_ROAD: String = "road"

var coordinates: Vector2i
var terrain_id: String
var region_id: String
var tags: PackedStringArray

func _init(initial_coordinates: Vector2i, initial_terrain_id: String, initial_region_id: String = "", initial_tags: PackedStringArray = PackedStringArray()) -> void:
	coordinates = initial_coordinates
	terrain_id = initial_terrain_id
	region_id = initial_region_id
	tags = initial_tags.duplicate()

func has_tag(tag_id: String) -> bool:
	return tags.has(tag_id)
