class_name MapTileVisuals
extends RefCounted

const TILE_SIZE := Vector2i(158, 140)
const VARIANT_COUNT: int = 3

const PLAINS_01: Texture2D = preload("res://assets/map/biomes/plains.png")
const PLAINS_02: Texture2D = preload("res://assets/map/biomes/plains2.png")
const PLAINS_03: Texture2D = preload("res://assets/map/biomes/plains3.png")
const FOREST_01: Texture2D = preload("res://assets/map/biomes/forest.png")
const FOREST_02: Texture2D = preload("res://assets/map/biomes/forest2.png")
const FOREST_03: Texture2D = preload("res://assets/map/biomes/forest3.png")
const HILLS_01: Texture2D = preload("res://assets/map/biomes/hills.png")
const HILLS_02: Texture2D = preload("res://assets/map/biomes/hills2.png")
const HILLS_03: Texture2D = preload("res://assets/map/biomes/hills3.png")
const TOWN_01: Texture2D = preload("res://assets/map/biomes/town1.png")
const TOWN_SIZE := Vector2i(418, 440)
const HERO_MAP_PATH: String = "res://assets/map/characters/hero_map.png"
const QUEST_MAP_PATH: String = "res://assets/map/activities/quest.png"

var terrain_variants: Dictionary = {
	"plains": [PLAINS_01, PLAINS_02, PLAINS_03],
	"forest": [FOREST_01, FOREST_02, FOREST_03],
	"hill": [HILLS_01, HILLS_02, HILLS_03],
}
var hero_map_texture: Texture2D
var quest_map_texture: Texture2D

func _init() -> void:
	for terrain_id in terrain_variants:
		var variants: Array = terrain_variants[terrain_id]
		assert(variants.size() == VARIANT_COUNT, "Each normal biome must expose exactly three visual variants.")
		for texture_variant in variants:
			assert(texture_variant != null, "Biome visual variants must load from project PNG files.")
			assert(texture_variant.get_size() == Vector2(TILE_SIZE), "Biome visual variants must remain exactly 158 by 140 pixels.")
	assert(TOWN_01 != null, "Town visual must load from the project PNG file.")
	assert(TOWN_01.get_size() == Vector2(TOWN_SIZE), "Town visual must remain exactly 418 by 440 pixels.")
	hero_map_texture = load_optional_texture(HERO_MAP_PATH)
	quest_map_texture = load_optional_texture(QUEST_MAP_PATH)

func get_variant_count(terrain_id: String) -> int:
	var visual_terrain_id: String = normalize_visual_terrain_id(terrain_id)
	if not terrain_variants.has(visual_terrain_id):
		return 0
	return terrain_variants[visual_terrain_id].size()

func get_variant_index(coordinates: Vector2i) -> int:
	return posmod(coordinates.x * 31 + coordinates.y * 17, VARIANT_COUNT)

func get_texture(terrain_id: String, coordinates: Vector2i):
	var visual_terrain_id: String = normalize_visual_terrain_id(terrain_id)
	if not terrain_variants.has(visual_terrain_id):
		return null
	return terrain_variants[visual_terrain_id][get_variant_index(coordinates)]

func get_town_texture() -> Texture2D:
	return TOWN_01

func get_hero_map_texture() -> Texture2D:
	return hero_map_texture

func get_quest_map_texture() -> Texture2D:
	return quest_map_texture

func load_optional_texture(resource_path: String) -> Texture2D:
	if not ResourceLoader.exists(resource_path):
		return null
	var resource = load(resource_path)
	return resource as Texture2D

func normalize_visual_terrain_id(terrain_id: String) -> String:
	if terrain_id == "road" or terrain_id == "starting_city" or terrain_id == "mid_city":
		return "plains"
	return terrain_id
