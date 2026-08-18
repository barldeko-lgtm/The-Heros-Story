class_name QuestNarrator
extends RefCounted

const QuestEventScript = preload("res://scripts/quests/quest_event.gd")

func describe(event) -> String:
	match event.event_type:
		QuestEventScript.HERO_SELECTED_QUEST:
			return "%s выбрал квест «%s»." % [event.hero_name, event.quest_definition.display_name]
		QuestEventScript.HERO_TRAVELLING_TO_QUEST:
			return "%s идёт к цели. Осталось: %d км." % [event.hero_name, event.distance_remaining]
		QuestEventScript.HERO_ARRIVED_AT_QUEST:
			return "%s прибыл к цели." % event.hero_name
		QuestEventScript.HERO_COMPLETED_QUEST:
			return "%s выполнил задание «%s». Бой будет добавлен позже." % [event.hero_name, event.quest_definition.display_name]
		QuestEventScript.HERO_RETURNING_TO_CITY:
			return "%s возвращается в город. Осталось: %d км." % [event.hero_name, event.distance_remaining]
		QuestEventScript.HERO_RETURNED_TO_CITY:
			return "%s вернулся в город." % event.hero_name
		QuestEventScript.HERO_TURNED_IN_QUEST:
			return "%s сдал квест «%s» и получил %d золота." % [event.hero_name, event.quest_definition.display_name, event.gold_reward]
	return ""
