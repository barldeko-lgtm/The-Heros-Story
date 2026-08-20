class_name QuestEvent
extends RefCounted

const HERO_SELECTED_QUEST := "HERO_SELECTED_QUEST"
const HERO_TRAVELLING_TO_QUEST := "HERO_TRAVELLING_TO_QUEST"
const HERO_ARRIVED_AT_QUEST := "HERO_ARRIVED_AT_QUEST"
const HERO_WON_FIGHT := "HERO_WON_FIGHT"
const HERO_RECOVERED_AFTER_FIGHT := "HERO_RECOVERED_AFTER_FIGHT"
const HERO_RETURNING_TO_CITY := "HERO_RETURNING_TO_CITY"
const HERO_RETURNED_TO_CITY := "HERO_RETURNED_TO_CITY"
const HERO_TURNED_IN_QUEST := "HERO_TURNED_IN_QUEST"
const HERO_DIED := "HERO_DIED"
const HERO_WAITING_FOR_RESURRECTION := "HERO_WAITING_FOR_RESURRECTION"
const HERO_RESURRECTED := "HERO_RESURRECTED"
const HERO_RECOVERING_IN_CITY := "HERO_RECOVERING_IN_CITY"

var event_type: String
var hero_name: String
var quest_definition
var distance_remaining: int
var gold_reward: int
var combat_result
var completed_mob_count: int
var mob_count: int
var current_hp: float
var max_hp: float
var experience_reward: int
var respawn_ticks_remaining: int

func _init(initial_event_type: String, initial_hero_name: String, initial_quest_definition, initial_distance_remaining: int = 0, initial_gold_reward: int = 0, initial_combat_result = null, initial_completed_mob_count: int = 0, initial_mob_count: int = 0, initial_current_hp: float = 0.0, initial_max_hp: float = 0.0, initial_experience_reward: int = 0, initial_respawn_ticks_remaining: int = 0) -> void:
	event_type = initial_event_type
	hero_name = initial_hero_name
	quest_definition = initial_quest_definition
	distance_remaining = initial_distance_remaining
	gold_reward = initial_gold_reward
	combat_result = initial_combat_result
	completed_mob_count = initial_completed_mob_count
	mob_count = initial_mob_count
	current_hp = initial_current_hp
	max_hp = initial_max_hp
	experience_reward = initial_experience_reward
	respawn_ticks_remaining = initial_respawn_ticks_remaining
