class_name ItemNarrator
extends RefCounted

# Describes already resolved reward routing; never generates or equips items.
func describe_received(hero_name: String, item_instance, equipped: bool) -> String:
	if equipped:
		return "%s получил «%s» (%s, ilvl %d) и надел предмет." % [hero_name, item_instance.definition.display_name, item_instance.get_quality_display_name(), item_instance.item_level]
	return "%s получил «%s» (%s, ilvl %d) и убрал предмет в инвентарь." % [hero_name, item_instance.definition.display_name, item_instance.get_quality_display_name(), item_instance.item_level]

func describe_overflow(dropped_instance) -> String:
	return "Инвентарь переполнен: самый старый предмет «%s» (%s) выпал." % [dropped_instance.definition.display_name, dropped_instance.get_quality_display_name()]
