class_name EquipmentDropTableDefinition
extends Resource

@export_range(0.0, 1.0, 0.001) var drop_chance: float = 0.0
@export var item_level: int = 1
@export var common_items: Array[Resource] = []
@export var uncommon_items: Array[Resource] = []
@export var rare_items: Array[Resource] = []
