class_name ItemDefinition
extends Resource

const ItemPowerCalculatorScript = preload("res://scripts/items/item_power_calculator.gd")

const SLOT_CHEST := "chest"
const QUALITY_COMMON: int = 0
const QUALITY_UNCOMMON: int = 1
const QUALITY_RARE: int = 2

@export var id: String
@export var display_name: String
@export_enum("chest", "helmet", "gloves", "pants", "boots") var equipment_slot: String = SLOT_CHEST
@export_enum("Обычное", "Необычное", "Редкое") var quality: int = QUALITY_COMMON
@export var icon_texture: Texture2D
@export var hero_overlay_texture: Texture2D
@export var max_hp_bonus: float = 0.0
@export var armor_bonus: int = 0
@export var strength_bonus: int = 0

func get_tooltip_text() -> String:
	return "%s\nКачество: %s\nСила предмета: %.2f\n\nМаксимальное здоровье: +%.0f\nБроня: +%d\nСила: +%d" % [
		display_name,
		get_quality_display_name(),
		get_item_power(),
		max_hp_bonus,
		armor_bonus,
		strength_bonus,
	]

func get_item_power() -> float:
	return ItemPowerCalculatorScript.calculate(self)

func get_quality_display_name() -> String:
	match quality:
		QUALITY_UNCOMMON: return "Необычное"
		QUALITY_RARE: return "Редкое"
	return "Обычное"
