class_name QuestRunner
extends RefCounted

var quest_definition: Resource
var travel_ticks_remaining: int = 0

func _init(initial_quest_definition: Resource) -> void:
	quest_definition = initial_quest_definition

func advance(hero_state) -> String:
	match hero_state.loop_state:
		"CHOOSING_QUEST":
			hero_state.active_quest = quest_definition
			travel_ticks_remaining = ceili(quest_definition.distance_km)
			hero_state.loop_state = "TRAVEL_TO_QUEST"
			return "Герой выбрал квест «%s»." % quest_definition.display_name
		"TRAVEL_TO_QUEST":
			travel_ticks_remaining -= 1
			if travel_ticks_remaining <= 0:
				hero_state.loop_state = "DOING_QUEST"
				return "Герой прибыл к цели."
			return "Герой идёт к цели. Осталось: %d км." % travel_ticks_remaining
		"DOING_QUEST":
			hero_state.loop_state = "RETURNING_TO_CITY"
			travel_ticks_remaining = ceili(quest_definition.distance_km)
			return "Герой выполнил задание «%s». Бой будет добавлен позже." % quest_definition.display_name
		"RETURNING_TO_CITY":
			travel_ticks_remaining -= 1
			if travel_ticks_remaining <= 0:
				hero_state.loop_state = "TURNING_IN_QUEST"
				return "Герой вернулся в город."
			return "Герой возвращается в город. Осталось: %d км." % travel_ticks_remaining
		"TURNING_IN_QUEST":
			hero_state.gold += quest_definition.gold_reward
			hero_state.active_quest = null
			hero_state.loop_state = "CHOOSING_QUEST"
			return "Герой сдал квест «%s» и получил %d золота." % [quest_definition.display_name, quest_definition.gold_reward]
	return ""
