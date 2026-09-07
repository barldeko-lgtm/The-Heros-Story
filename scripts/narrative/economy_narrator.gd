class_name EconomyNarrator
extends RefCounted

# Formats completed economic facts only; never chooses or executes purchases.
func describe_stock_refreshed() -> String:
	return "Магазин: ассортимент обновлён."

func describe_market_sale(hero_name: String, result: Dictionary) -> String:
	if result["sold_count"] > 0:
		return "Рынок: продано предметов: %d, получено +%d золота." % [result["sold_count"], result["gold_gained"]]
	return "%s посетил рынок, но продавать было нечего." % hero_name

func describe_no_purchase(hero_name: String) -> String:
	return "%s осмотрел магазин, но достаточно выгодных покупок не нашёл." % hero_name

func describe_purchase_failed(hero_name: String) -> String:
	return "%s не смог завершить выбранную покупку." % hero_name

func describe_purchase(hero_name: String, result: Dictionary, best_purchase: Dictionary) -> String:
	var purchased_item = result["item_instance"]
	var log_text: String
	if str(best_purchase.get("comparison_mode", "")) == "belt_utility":
		log_text = "%s купил «%s» (%s, ilvl %d) за %d золота; пояс теперь поддерживает до %.0f HP лечения." % [
			hero_name,
			purchased_item.definition.display_name,
			purchased_item.get_quality_display_name(),
			purchased_item.item_level,
			result["price_paid"],
			float(best_purchase.get("candidate_belt_healing", 0.0)),
		]
	else:
		log_text = "%s купил «%s» (%s, ilvl %d) за %d золота; сила героя +%.2f." % [
			hero_name,
			purchased_item.definition.display_name,
			purchased_item.get_quality_display_name(),
			purchased_item.item_level,
			result["price_paid"],
			result["power_gain"],
		]
	if result["replaced_item"] != null:
		log_text += " Старый предмет «%s» сразу продан за %d золота." % [result["replaced_item"].definition.display_name, result["replaced_item_sale_value"]]
	return log_text

func describe_stock(listings: Array) -> String:
	var white_slots: Array[String] = []
	var green_slots: Array[String] = []
	for listing in listings:
		var item_instance = listing.get("item_instance")
		if item_instance == null or item_instance.definition == null:
			continue
		var slot_name: String = get_shop_slot_debug_name(item_instance.definition.equipment_slot)
		if item_instance.rarity == 1:
			green_slots.append(slot_name)
		else:
			white_slots.append(slot_name)
	var white_text: String = ", ".join(white_slots) if not white_slots.is_empty() else "нет"
	var green_text: String = ", ".join(green_slots) if not green_slots.is_empty() else "нет"
	return "Магазин: белые — %s; зелёные — %s." % [white_text, green_text]

func get_shop_slot_debug_name(equipment_slot: String) -> String:
	match equipment_slot:
		"helmet": return "шлем"
		"chest": return "нагрудник"
		"gloves": return "перчатки"
		"pants": return "штаны"
		"boots": return "сапоги"
		"weapon": return "меч"
		"shield": return "щит"
		"necklace": return "ожерелье"
		"earrings": return "серьги"
		"ring_1": return "кольцо 1"
		"ring_2": return "кольцо 2"
		"belt": return "пояс"
	return equipment_slot

