class_name ItemInstance
extends RefCounted

const ItemPowerCalculatorScript = preload("res://scripts/items/item_power_calculator.gd")
const ItemPriceCalculatorScript = preload("res://scripts/economy/item_price_calculator.gd")
const BeltPotionRulesScript = preload("res://scripts/items/belt_potion_rules.gd")

var definition: Resource
var item_level: int
var rarity: int
var rolled_total_modifier_budget: float
var affixes: Array = []
var base_stats: Dictionary = {}
var resolved_stats: Dictionary = {}

func _init(
	initial_definition: Resource,
	initial_item_level: int = 0,
	initial_rarity: int = -1,
	initial_base_stats: Dictionary = {},
	initial_affixes: Array = [],
	initial_rolled_total_modifier_budget: float = 0.0,
	initial_resolved_stats: Dictionary = {}
) -> void:
	assert(initial_definition != null, "ItemInstance requires an ItemDefinition.")
	definition = initial_definition
	item_level = initial_item_level
	rarity = initial_rarity if initial_rarity >= 0 else int(initial_definition.quality)
	base_stats = initial_base_stats.duplicate(true)
	affixes = initial_affixes.duplicate(true)
	rolled_total_modifier_budget = initial_rolled_total_modifier_budget
	resolved_stats = initial_resolved_stats.duplicate(true)

func get_stat_bonus(stat_id: String) -> float:
	return float(resolved_stats.get(stat_id, 0.0))

func get_item_power() -> float:
	return ItemPowerCalculatorScript.calculate(self)

func get_quality_display_name() -> String:
	match rarity:
		1: return "Необычное"
		2: return "Редкое"
		3: return "Эпическое"
	return "Обычное"

func get_tooltip_text() -> String:
	var lines: Array[String] = [
		definition.display_name,
		"Качество: %s" % get_quality_display_name(),
		"Уровень предмета: %d" % item_level,
		"Сила предмета: %.2f" % get_item_power(),
	]
	var price_calculator = ItemPriceCalculatorScript.new()
	var shop_value: int = price_calculator.get_reference_shop_value_for_item(self)
	var sell_price: int = price_calculator.get_sell_price_for_item(self)
	if shop_value >= 0:
		lines.append("Магазинная стоимость: %d" % shop_value)
	if sell_price >= 0:
		lines.append("Цена продажи: %d" % sell_price)
	if not is_zero_approx(rolled_total_modifier_budget):
		lines.append("Бюджет модификаторов: %.2f" % rolled_total_modifier_budget)
	lines.append("")
	append_base_stat_lines(lines)
	if definition.equipment_slot == "belt":
		var belt_rules = BeltPotionRulesScript.new()
		lines.append("Слоты зелий: %d" % belt_rules.get_capacity(self))
		lines.append("Макс. уровень зелья: %d" % belt_rules.get_max_potion_level(self))
		lines.append("Потенциальный запас лечения: %.0f HP" % belt_rules.get_potential_healing(self))
	if not affixes.is_empty():
		lines.append("")
		lines.append("Модификаторы:")
		for affix in affixes:
			lines.append(format_affix_line(affix))
	return "\n".join(lines)

func append_base_stat_lines(lines: Array[String]) -> void:
	if get_base_stat("max_hp") != 0.0:
		lines.append("Базовое здоровье: +%.2f" % get_base_stat("max_hp"))
	if get_base_stat("armor") != 0.0:
		lines.append("Базовая броня: +%.2f" % get_base_stat("armor"))
	if get_base_stat("attack") != 0.0:
		lines.append("Базовый урон: +%.2f" % get_base_stat("attack"))
	if get_base_stat("attack_speed") != 0.0:
		lines.append("Базовая скорость атаки: +%.2f" % get_base_stat("attack_speed"))
	if get_base_stat("block") != 0.0:
		lines.append("Базовый блок: +%.2f" % get_base_stat("block"))
	if get_base_stat("fire_resistance") != 0.0:
		lines.append("Базовое сопротивление огню: +%.2f" % get_base_stat("fire_resistance"))
	if get_base_stat("cold_resistance") != 0.0:
		lines.append("Базовое сопротивление холоду: +%.2f" % get_base_stat("cold_resistance"))
	if get_base_stat("lightning_resistance") != 0.0:
		lines.append("Базовое сопротивление молнии: +%.2f" % get_base_stat("lightning_resistance"))

func get_base_stat(stat_id: String) -> float:
	return float(base_stats.get(stat_id, 0.0))

func format_affix_line(affix: Dictionary) -> String:
	var stat_id: String = affix.get("stat_id", "")
	var value: float = float(affix.get("value", 0.0))
	match stat_id:
		"health": return "Здоровье: +%.2f" % value
		"armor": return "Броня: +%.2f" % value
		"dodge": return "Уклонение: +%.2f" % value
		"accuracy": return "Точность: +%.2f" % value
		"damage": return "Урон: +%.2f" % value
		"crit_chance_percentage_point": return "Шанс крита: +%.2f%%" % value
		"crit_damage_percentage_point": return "Сила крита: +%.2f%%" % value
		"attack_speed_percent": return "Скорость атаки: +%.2f%%" % value
		"cast_speed_percent": return "Скорость применения: +%.2f%%" % value
		"elemental_resistance": return "Сопротивление стихии: +%.2f" % value
		"fire_resistance": return "Сопротивление огню: +%.2f" % value
		"cold_resistance": return "Сопротивление холоду: +%.2f" % value
		"lightning_resistance": return "Сопротивление молнии: +%.2f" % value
		"block": return "Блок: +%.2f" % value
	return "%s: +%.2f" % [stat_id, value]
