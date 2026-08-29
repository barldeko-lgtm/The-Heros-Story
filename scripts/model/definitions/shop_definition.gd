class_name ShopDefinition
extends Resource

@export var id: String
@export var city_id: String
@export var refresh_interval_ticks: int = 0
@export var item_levels: Array[int] = []
@export var white_listings_per_band: int = 0
@export var uncommon_listings_per_band: int = 0
@export var item_definitions: Array[Resource] = []
