class_name QuestEvent
extends RefCounted

const HERO_SELECTED_QUEST := "HERO_SELECTED_QUEST"
const HERO_TRAVELLING_TO_QUEST := "HERO_TRAVELLING_TO_QUEST"
const HERO_ARRIVED_AT_QUEST := "HERO_ARRIVED_AT_QUEST"
const HERO_COMPLETED_QUEST := "HERO_COMPLETED_QUEST"
const HERO_RETURNING_TO_CITY := "HERO_RETURNING_TO_CITY"
const HERO_RETURNED_TO_CITY := "HERO_RETURNED_TO_CITY"
const HERO_TURNED_IN_QUEST := "HERO_TURNED_IN_QUEST"

var event_type: String
var hero_name: String
var quest_definition: Resource
var distance_remaining: int
var gold_reward: int

func _init(initial_event_type: String, initial_hero_name: String, initial_quest_definition: Resource, initial_distance_remaining: int = 0, initial_gold_reward: int = 0) -> void:
	event_type = initial_event_type
	hero_name = initial_hero_name
	quest_definition = initial_quest_definition
	distance_remaining = initial_distance_remaining
	gold_reward = initial_gold_reward
