class_name QuestRunner
extends RefCounted

const QuestEventScript = preload("res://scripts/quests/quest_event.gd")
const RECOVERY_PERCENT_OF_MAX_HP: float = 0.20
const RESPAWN_DURATION_TICKS: int = 100
const RESURRECTION_HP: float = 1.0

var quest_definition
var travel_system
var city_center: Vector2i = Vector2i(-1, -1)
var travel_ticks_remaining: int = 0
var completed_mob_count: int = 0
var respawn_ticks_remaining: int = 0
var map_travel_active: bool = false

func _init(initial_quest_definition, initial_travel_system = null, initial_city_center: Vector2i = Vector2i(-1, -1)) -> void:
	quest_definition = initial_quest_definition
	travel_system = initial_travel_system
	city_center = initial_city_center

func advance(hero_state, combat_stats: CombatStats = null):
	match hero_state.loop_state:
		HeroState.CHOOSING_QUEST:
			completed_mob_count = 0
			hero_state.active_quest = quest_definition
			map_travel_active = can_use_map_travel()
			if map_travel_active:
				assert(travel_system.begin_travel(quest_definition.target_hex), "Selected map-backed quest must have a valid route to its target.")
				travel_ticks_remaining = travel_system.get_remaining_steps()
			else:
				travel_ticks_remaining = ceili(quest_definition.distance_km)
			hero_state.loop_state = HeroState.TRAVEL_TO_QUEST
			return QuestEventScript.new(QuestEventScript.HERO_SELECTED_QUEST, hero_state.hero_name, quest_definition, travel_ticks_remaining)
		HeroState.TRAVEL_TO_QUEST:
			if map_travel_active:
				return advance_map_travel(hero_state, true)
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
					if map_travel_active:
						assert(travel_system.begin_travel(city_center), "Completed map-backed quest must have a valid route back to its city.")
						travel_ticks_remaining = travel_system.get_remaining_steps()
					else:
						travel_ticks_remaining = ceili(quest_definition.distance_km)
				else:
					hero_state.loop_state = HeroState.DOING_QUEST
			return QuestEventScript.new(QuestEventScript.HERO_RECOVERED_AFTER_FIGHT, hero_state.hero_name, quest_definition, 0, 0, null, completed_mob_count, quest_definition.mob_count, hero_state.current_hp, combat_stats.max_hp)
		HeroState.RETURNING_TO_CITY:
			if map_travel_active:
				return advance_map_travel(hero_state, false)
			travel_ticks_remaining -= 1
			if travel_ticks_remaining <= 0:
				hero_state.loop_state = HeroState.TURNING_IN_QUEST
				return QuestEventScript.new(QuestEventScript.HERO_RETURNED_TO_CITY, hero_state.hero_name, quest_definition)
			return QuestEventScript.new(QuestEventScript.HERO_RETURNING_TO_CITY, hero_state.hero_name, quest_definition, travel_ticks_remaining)
		HeroState.TURNING_IN_QUEST:
			hero_state.gold += quest_definition.gold_reward
			hero_state.active_quest = null
			hero_state.loop_state = HeroState.VISITING_MARKET
			map_travel_active = false
			if travel_system != null:
				travel_system.clear_travel()
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

func can_use_map_travel() -> bool:
	return (
		travel_system != null
		and quest_definition != null
		and quest_definition.has_method("has_map_target")
		and quest_definition.has_map_target()
		and city_center != Vector2i(-1, -1)
	)

func advance_map_travel(hero_state, travelling_to_quest: bool):
	var result: Dictionary = travel_system.advance_one_tick()
	assert(result["moved"] or result["arrived"], "Active map travel must either move one hex or already be at its destination.")
	travel_ticks_remaining = int(result["remaining_steps"])
	if bool(result["arrived"]):
		if travelling_to_quest:
			hero_state.loop_state = HeroState.DOING_QUEST
			return QuestEventScript.new(QuestEventScript.HERO_ARRIVED_AT_QUEST, hero_state.hero_name, quest_definition)
		hero_state.loop_state = HeroState.TURNING_IN_QUEST
		return QuestEventScript.new(QuestEventScript.HERO_RETURNED_TO_CITY, hero_state.hero_name, quest_definition)
	if travelling_to_quest:
		return QuestEventScript.new(QuestEventScript.HERO_TRAVELLING_TO_QUEST, hero_state.hero_name, quest_definition, travel_ticks_remaining)
	return QuestEventScript.new(QuestEventScript.HERO_RETURNING_TO_CITY, hero_state.hero_name, quest_definition, travel_ticks_remaining)

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
		map_travel_active = false
		if travel_system != null:
			travel_system.clear_travel()
		hero_state.active_quest = null
		hero_state.loop_state = HeroState.DEAD_RESPAWNING
		return QuestEventScript.new(QuestEventScript.HERO_DIED, hero_state.hero_name, quest_definition, 0, 0, combat_result, defeated_mobs_before_death, quest_definition.mob_count, hero_state.current_hp, combat_stats.max_hp, 0, respawn_ticks_remaining)
	completed_mob_count += 1
	var experience_reward: int = get_current_mob_experience_reward()
	hero_state.loop_state = HeroState.RECOVERING_AFTER_FIGHT
	return QuestEventScript.new(QuestEventScript.HERO_WON_FIGHT, hero_state.hero_name, quest_definition, 0, 0, combat_result, completed_mob_count, quest_definition.mob_count, hero_state.current_hp, combat_stats.max_hp, experience_reward)

func cancel_for_external_failure(hero_state):
	if hero_state == null:
		return null
	var cancelled_quest = hero_state.active_quest
	completed_mob_count = 0
	travel_ticks_remaining = 0
	map_travel_active = false
	if travel_system != null:
		travel_system.clear_travel()
	hero_state.active_quest = null
	return cancelled_quest
