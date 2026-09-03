class_name ShopDefinition
extends Resource

@export var id: String
@export var city_id: String
@export var refresh_interval_ticks: int = 0
@export var stock_bands: Array[Resource] = []
@export var healing_potion_definitions: Array[Resource] = []
