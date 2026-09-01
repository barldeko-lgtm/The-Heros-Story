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
@export var ordinary_mob_definition: Resource
@export_range(3, 5, 1) var ordinary_encounter_count: int = 3
@export var boss_mob_definition: Resource
@export var completion_gold_reward: int = 0
@export var completion_equipment_source: Resource
@export_range(0.0, 1.0, 0.01) var completion_epic_chance: float = 0.0
