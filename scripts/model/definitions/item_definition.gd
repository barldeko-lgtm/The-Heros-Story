class_name ItemDefinition
extends Resource

const ItemPowerCalculatorScript = preload("res://scripts/items/item_power_calculator.gd")

const SLOT_CHEST := "chest"
const QUALITY_COMMON: int = 0
const QUALITY_UNCOMMON: int = 1
const QUALITY_RARE: int = 2

@export var id: String
@export var display_name: String
@export_enum("chest", "helmet", "gloves", "pants", "boots", "weapon", "shield", "necklace", "earrings", "ring_1", "ring_2", "belt") var equipment_slot: String = SLOT_CHEST
@export_enum("Обычное", "Необычное", "Редкое") var quality: int = QUALITY_COMMON
@export var icon_texture: Texture2D
@export var hero_overlay_texture: Texture2D
@export var max_hp_bonus: float = 0.0
@export var armor_bonus: int = 0
@export var strength_bonus: int = 0
@export var attack_bonus: float = 0.0
@export var crit_chance_bonus: float = 0.0
@export var crit_damage_bonus: float = 0.0

func get_tooltip_text() -> String:
	var lines: Array[String] = [
		"%s" % display_name,
		"Качество: %s" % get_quality_display_name(),
		"Сила предмета: %.2f" % get_item_power(),
		"",
	]
	if max_hp_bonus != 0.0:
		lines.append("Максимальное здоровье: +%.0f" % max_hp_bonus)
	if armor_bonus != 0:
		lines.append("Броня: +%d" % armor_bonus)
	if strength_bonus != 0:
		lines.append("Сила: +%d" % strength_bonus)
	if attack_bonus != 0.0:
		lines.append("Атака: +%.0f" % attack_bonus)
	if crit_chance_bonus != 0.0:
		lines.append("Шанс крита: +%.0f%%" % (crit_chance_bonus * 100.0))
	if crit_damage_bonus != 0.0:
		lines.append("Сила крита: +%.0f%%" % (crit_damage_bonus * 100.0))
	return "\n".join(lines)

func get_item_power() -> float:
	return ItemPowerCalculatorScript.calculate(self)

func get_quality_display_name() -> String:
	match quality:
		QUALITY_UNCOMMON: return "Необычное"
		QUALITY_RARE: return "Редкое"
	return "Обычное"
