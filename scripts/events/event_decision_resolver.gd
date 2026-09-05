class_name EventDecisionResolver
extends RefCounted

const ALLOWED_WARRIOR_ATTRIBUTES := ["strength", "dexterity", "constitution", "wisdom"]

func resolve_highest_primary_attribute(hero_state, options: Array[Resource], rng: RandomNumberGenerator) -> Dictionary:
	if hero_state == null or rng == null or options.is_empty() or options.size() > 3:
		return {}

	var highest_value: int = -2147483648
	var winning_options: Array[Resource] = []
	var compared_values: Dictionary = {}
	for option in options:
		if option == null or not ALLOWED_WARRIOR_ATTRIBUTES.has(option.driver_attribute):
			return {}
		var attribute_value: int = int(hero_state.get(option.driver_attribute))
		compared_values[option.driver_attribute] = attribute_value
		if attribute_value > highest_value:
			highest_value = attribute_value
			winning_options = [option]
		elif attribute_value == highest_value:
			winning_options.append(option)

	if winning_options.is_empty():
		return {}
	var selected_option: Resource = winning_options[0]
	var tie_broken: bool = winning_options.size() > 1
	if tie_broken:
		selected_option = winning_options[rng.randi_range(0, winning_options.size() - 1)]
	return {
		"selected_option": selected_option,
		"compared_values": compared_values,
		"highest_value": highest_value,
		"tie_broken": tie_broken,
	}
