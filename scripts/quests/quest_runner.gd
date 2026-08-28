class_name QuestRunner
extends RefCounted

const QuestEventScript = preload("res://scripts/quests/quest_event.gd")
const RECOVERY_PERCENT_OF_MAX_HP: float = 0.20
const RESPAWN_DURATION_TICKS: int = 100
const RESURRECTION_HP: float = 1.0

var quest_definition
var travel_ticks_remaining: int = 0
var completed_mob_count: int = 0
var respawn_ticks_remaining: int = 0

func _init(initial_quest_definition) -> void:
	quest_definition = initial_quest_definition

func advance(hero_state, combat_stats: CombatStats = null):
	match hero_state.loop_state:
		HeroState.CHOOSING_QUEST:
			completed_mob_count = 0
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
		HeroState.RECOVERING_AFTER_FIGHT:
			assert(combat_stats != null, "Quest recovery requires resolved hero CombatStats.")
			hero_state.current_hp = minf(combat_stats.max_hp, hero_state.current_hp + combat_stats.max_hp * RECOVERY_PERCENT_OF_MAX_HP)
			if is_equal_approx(hero_state.current_hp, combat_stats.max_hp):
				hero_state.current_hp = combat_stats.max_hp
				if completed_mob_count >= quest_definition.mob_count:
					hero_state.loop_state = HeroState.RETURNING_TO_CITY
					travel_ticks_remaining = ceili(quest_definition.distance_km)
				else:
					hero_state.loop_state = HeroState.DOING_QUEST
			return QuestEventScript.new(QuestEventScript.HERO_RECOVERED_AFTER_FIGHT, hero_state.hero_name, quest_definition, 0, 0, null, completed_mob_count, quest_definition.mob_count, hero_state.current_hp, combat_stats.max_hp)
		HeroState.RETURNING_TO_CITY:
			travel_ticks_remaining -= 1
			if travel_ticks_remaining <= 0:
				hero_state.loop_state = HeroState.TURNING_IN_QUEST
				return QuestEventScript.new(QuestEventScript.HERO_RETURNED_TO_CITY, hero_state.hero_name, quest_definition)
			return QuestEventScript.new(QuestEventScript.HERO_RETURNING_TO_CITY, hero_state.hero_name, quest_definition, travel_ticks_remaining)
		HeroState.TURNING_IN_QUEST:
			hero_state.gold += quest_definition.gold_reward
			hero_state.active_quest = null
			hero_state.loop_state = HeroState.VISITING_MARKET
			return QuestEventScript.new(QuestEventScript.HERO_TURNED_IN_QUEST, hero_state.hero_name, quest_definition, 0, quest_definition.gold_reward)
		HeroState.DEAD_RESPAWNING:
			respawn_ticks_remaining -= 1
			if respawn_ticks_remaining <= 0:
				assert(combat_stats != null, "Resurrection requires resolved hero CombatStats.")
				respawn_ticks_remaining = 0
				hero_state.current_hp = minf(RESURRECTION_HP, combat_stats.max_hp)
				hero_state.loop_state = HeroState.RECOVERING_IN_CITY
				return QuestEventScript.new(QuestEventScript.HERO_RESURRECTED, hero_state.hero_name, quest_definition, 0, 0, null, 0, 0, hero_state.current_hp, combat_stats.max_hp)
			return QuestEventScript.new(QuestEventScript.HERO_WAITING_FOR_RESURRECTION, hero_state.hero_name, quest_definition, 0, 0, null, 0, 0, hero_state.current_hp, combat_stats.max_hp, 0, respawn_ticks_remaining)
		HeroState.RECOVERING_IN_CITY:
			assert(combat_stats != null, "City recovery requires resolved hero CombatStats.")
			hero_state.current_hp = minf(combat_stats.max_hp, hero_state.current_hp + combat_stats.max_hp * RECOVERY_PERCENT_OF_MAX_HP)
			if is_equal_approx(hero_state.current_hp, combat_stats.max_hp):
				hero_state.current_hp = combat_stats.max_hp
				hero_state.loop_state = HeroState.CHOOSING_QUEST
			return QuestEventScript.new(QuestEventScript.HERO_RECOVERING_IN_CITY, hero_state.hero_name, quest_definition, 0, 0, null, 0, 0, hero_state.current_hp, combat_stats.max_hp)
	return null

func get_current_mob_stats():
	return quest_definition.mob_definition.get_combat_stats()

func get_current_mob_experience_reward() -> int:
	return quest_definition.mob_definition.experience_reward

func get_next_mob_number() -> int:
	return completed_mob_count + 1

func force_resurrection(hero_state, combat_stats: CombatStats):
	if hero_state.loop_state != HeroState.DEAD_RESPAWNING:
		return null
	respawn_ticks_remaining = 0
	hero_state.current_hp = minf(RESURRECTION_HP, combat_stats.max_hp)
	hero_state.loop_state = HeroState.RECOVERING_IN_CITY
	return QuestEventScript.new(QuestEventScript.HERO_RESURRECTED, hero_state.hero_name, quest_definition, 0, 0, null, 0, 0, hero_state.current_hp, combat_stats.max_hp)

func complete_fight(hero_state, combat_stats: CombatStats, combat_result):
	hero_state.current_hp = maxf(0.0, combat_result.hero_remaining_hp)
	if not combat_result.hero_won:
		var defeated_mobs_before_death: int = completed_mob_count
		respawn_ticks_remaining = RESPAWN_DURATION_TICKS
		completed_mob_count = 0
		travel_ticks_remaining = 0
		hero_state.active_quest = null
		hero_state.loop_state = HeroState.DEAD_RESPAWNING
		return QuestEventScript.new(QuestEventScript.HERO_DIED, hero_state.hero_name, quest_definition, 0, 0, combat_result, defeated_mobs_before_death, quest_definition.mob_count, hero_state.current_hp, combat_stats.max_hp, 0, respawn_ticks_remaining)
	completed_mob_count += 1
	var experience_reward: int = get_current_mob_experience_reward()
	hero_state.loop_state = HeroState.RECOVERING_AFTER_FIGHT
	return QuestEventScript.new(QuestEventScript.HERO_WON_FIGHT, hero_state.hero_name, quest_definition, 0, 0, combat_result, completed_mob_count, quest_definition.mob_count, hero_state.current_hp, combat_stats.max_hp, experience_reward)
