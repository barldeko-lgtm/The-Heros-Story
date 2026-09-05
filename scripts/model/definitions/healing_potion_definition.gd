class_name HealingPotionDefinition
extends Resource

@export var id: String
@export var display_name: String
@export var potion_level: int = 5
@export var healing_amount: float = 0.0
@export var shop_price: int = 0
@export var icon_texture: Texture2D

func get_tooltip_text() -> String:
	return "%s\nУровень: %d\nЛечение: %.0f HP\nЦена: %d золота" % [
		display_name,
		potion_level,
		healing_amount,
		shop_price,
	]
