class_name DungeonDefinition
extends Resource

@export var id: String
@export var display_name: String
@export var region_id: String
@export var placement_distance_hex_min: int = 0
@export var placement_distance_hex_max: int = 0
@export var placement_allowed_terrain_ids: PackedStringArray = PackedStringArray()
@export var placement_allowed_tags: PackedStringArray = PackedStringArray()
@export var placement_forbidden_tags: PackedStringArray = PackedStringArray()
@export var placement_radius: int = 0
