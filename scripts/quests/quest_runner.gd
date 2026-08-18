class_name QuestRunner
extends RefCounted

const QuestEventScript = preload("res://scripts/quests/quest_event.gd")

var quest_definition: Resource
var travel_ticks_remaining: int = 0

func _init(initial_quest_definition: Resource) -> void:
	quest_definition = initial_quest_definition

func advance(hero_state):
	match hero_state.loop_state:
		HeroState.CHOOSING_QUEST:
			hero_state.active_quest = quest_definition
			travel_ticks_remaining = ceili(quest_definition.distance_km)
			hero_state.loop_state = HeroState.TRAVEL_TO_QUEST
			return QuestEventScript.new(QuestEventScript.HERO_SELECTED_QUEST, hero_state.hero_name, quest_definition, travel_ticks_remaining)
		HeroState.TRAVEL_TO_QUEST:
			travel_ticks_remaining -= 1
			if travel_ticks_remaining <= 0:
				hero_state.loop_state = HeroState.DOING_QUEST
				return QuestEventScript.new(QuestEventScript.HERO_ARRIVED_AT_QUEST, hero_state.hero_name, quest_definition)
			return QuestEventScript.new(QuestEventScript.HERO_TRAVELLING_TO_QUEST, hero_state.hero_name, quest_definition, travel_ticks_remaining)
		HeroState.DOING_QUEST:
			hero_state.loop_state = HeroState.RETURNING_TO_CITY
			travel_ticks_remaining = ceili(quest_definition.distance_km)
			return QuestEventScript.new(QuestEventScript.HERO_COMPLETED_QUEST, hero_state.hero_name, quest_definition, travel_ticks_remaining)
		HeroState.RETURNING_TO_CITY:
			travel_ticks_remaining -= 1
			if travel_ticks_remaining <= 0:
				hero_state.loop_state = HeroState.TURNING_IN_QUEST
				return QuestEventScript.new(QuestEventScript.HERO_RETURNED_TO_CITY, hero_state.hero_name, quest_definition)
			return QuestEventScript.new(QuestEventScript.HERO_RETURNING_TO_CITY, hero_state.hero_name, quest_definition, travel_ticks_remaining)
		HeroState.TURNING_IN_QUEST:
			hero_state.gold += quest_definition.gold_reward
			hero_state.active_quest = null
			hero_state.loop_state = HeroState.CHOOSING_QUEST
			return QuestEventScript.new(QuestEventScript.HERO_TURNED_IN_QUEST, hero_state.hero_name, quest_definition, 0, quest_definition.gold_reward)
	return null
