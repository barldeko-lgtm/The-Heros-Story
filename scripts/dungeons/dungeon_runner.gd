class_name DungeonRunner
extends RefCounted

const BETWEEN_FIGHT_PREPARATION_TICKS: int = 1
const RESPAWN_DURATION_TICKS: int = 100
const RESURRECTION_HP: float = 1.0
const CITY_RECOVERY_PERCENT_OF_MAX_HP: float = 0.20

var travel_system
var active_dungeon
var ordinary_encounters_completed: int = 0
var boss_defeated: bool = false
var between_fight_ticks_remaining: int = 0
var respawn_ticks_remaining: int = 0
var failure_recovery_active: bool = false
var attempt_start_power: float = 0.0

func _init(initial_travel_system) -> void:
	travel_system = initial_travel_system
	assert(travel_system != null, "DungeonRunner requires TravelSystem.")

func begin_trip(hero_state, dungeon_instance, current_hero_power: float) -> bool:
	if hero_state == null or dungeon_instance == null:
		return false
	if not dungeon_instance.discovered or dungeon_instance.completed or not dungeon_instance.has_map_target():
		return false
	if not travel_system.begin_travel(dungeon_instance.target_hex):
		return false
	active_dungeon = dungeon_instance
	ordinary_encounters_completed = 0
	boss_defeated = false
	between_fight_ticks_remaining = 0
	respawn_ticks_remaining = 0
	failure_recovery_active = false
	attempt_start_power = maxf(0.0, current_hero_power)
	hero_state.loop_state = HeroState.TRAVEL_TO_DUNGEON
	return true

func advance(hero_state) -> Dictionary:
	if hero_state == null or hero_state.loop_state != HeroState.TRAVEL_TO_DUNGEON or active_dungeon == null:
		return {}
	var result: Dictionary = travel_system.advance_one_tick()
	assert(result["moved"] or result["arrived"], "Active dungeon travel must either move one hex or already be at its destination.")
	if bool(result["arrived"]):
		hero_state.loop_state = HeroState.AT_DUNGEON_ENTRANCE
	return result

func enter(hero_state) -> bool:
	if hero_state == null or active_dungeon == null:
		return false
	if hero_state.loop_state != HeroState.AT_DUNGEON_ENTRANCE:
		return false
	if get_current_mob_definition() == null:
		return false
	hero_state.loop_state = HeroState.DOING_DUNGEON
	return true

func get_current_mob_definition():
	if active_dungeon == null or active_dungeon.definition == null or boss_defeated:
		return null
	var definition = active_dungeon.definition
	if ordinary_encounters_completed < definition.ordinary_encounter_count:
		return definition.ordinary_mob_definition
	return definition.boss_mob_definition

func get_total_encounter_count() -> int:
	if active_dungeon == null or active_dungeon.definition == null:
		return 0
	return active_dungeon.definition.ordinary_encounter_count + 1

func get_current_encounter_number() -> int:
	if active_dungeon == null:
		return 0
	return ordinary_encounters_completed + 1

func current_encounter_is_boss() -> bool:
	if active_dungeon == null or active_dungeon.definition == null:
		return false
	return ordinary_encounters_completed >= active_dungeon.definition.ordinary_encounter_count and not boss_defeated

func complete_fight(hero_state, combat_stats: CombatStats, combat_result) -> Dictionary:
	if hero_state == null or combat_stats == null or combat_result == null or active_dungeon == null:
		return {}
	var fought_mob = get_current_mob_definition()
	if fought_mob == null:
		return {}
	var was_boss: bool = current_encounter_is_boss()
	hero_state.current_hp = maxf(0.0, combat_result.hero_remaining_hp)

	if not combat_result.hero_won:
		respawn_ticks_remaining = RESPAWN_DURATION_TICKS
		between_fight_ticks_remaining = 0
		failure_recovery_active = true
		travel_system.clear_travel()
		hero_state.loop_state = HeroState.DEAD_RESPAWNING
		return {
			"type": "died",
			"mob_definition": fought_mob,
			"was_boss": was_boss,
			"ordinary_encounters_completed": ordinary_encounters_completed,
			"current_hp": hero_state.current_hp,
			"max_hp": combat_stats.max_hp,
			"respawn_ticks_remaining": respawn_ticks_remaining,
			"attempt_start_power": attempt_start_power,
		}

	if was_boss:
		boss_defeated = true
		active_dungeon.mark_completed()
		hero_state.loop_state = HeroState.DUNGEON_COMPLETED
		return {
			"type": "completed",
			"mob_definition": fought_mob,
			"was_boss": true,
			"ordinary_encounters_completed": ordinary_encounters_completed,
			"current_hp": hero_state.current_hp,
			"max_hp": combat_stats.max_hp,
		}

	ordinary_encounters_completed += 1
	between_fight_ticks_remaining = BETWEEN_FIGHT_PREPARATION_TICKS
	hero_state.loop_state = HeroState.DUNGEON_BETWEEN_FIGHTS
	return {
		"type": "won_ordinary",
		"mob_definition": fought_mob,
		"was_boss": false,
		"ordinary_encounters_completed": ordinary_encounters_completed,
		"current_hp": hero_state.current_hp,
		"max_hp": combat_stats.max_hp,
		"between_fight_ticks_remaining": between_fight_ticks_remaining,
		"next_is_boss": ordinary_encounters_completed >= active_dungeon.definition.ordinary_encounter_count,
	}

func advance_between_fights(hero_state) -> Dictionary:
	if hero_state == null or hero_state.loop_state != HeroState.DUNGEON_BETWEEN_FIGHTS or active_dungeon == null:
		return {}
	between_fight_ticks_remaining = maxi(0, between_fight_ticks_remaining - 1)
	var next_is_boss: bool = ordinary_encounters_completed >= active_dungeon.definition.ordinary_encounter_count
	if between_fight_ticks_remaining <= 0:
		hero_state.loop_state = HeroState.DOING_DUNGEON
	return {
		"between_fight_ticks_remaining": between_fight_ticks_remaining,
		"next_is_boss": next_is_boss,
		"current_hp": hero_state.current_hp,
	}

func begin_return_to_city(hero_state, city_center: Vector2i) -> bool:
	if hero_state == null or active_dungeon == null or not active_dungeon.completed:
		return false
	if hero_state.loop_state != HeroState.DUNGEON_COMPLETED:
		return false
	if not travel_system.begin_travel(city_center):
		return false
	hero_state.loop_state = HeroState.DUNGEON_RETURNING_TO_CITY
	return true

func advance_return_to_city(hero_state) -> Dictionary:
	if hero_state == null or hero_state.loop_state != HeroState.DUNGEON_RETURNING_TO_CITY or active_dungeon == null:
		return {}
	var result: Dictionary = travel_system.advance_one_tick()
	assert(result["moved"] or result["arrived"], "Active dungeon return travel must either move one hex or already be at the city.")
	if bool(result["arrived"]):
		hero_state.loop_state = HeroState.VISITING_MARKET
		clear()
	return result

func advance_respawn(hero_state, combat_stats: CombatStats) -> Dictionary:
	if hero_state == null or combat_stats == null or not failure_recovery_active or hero_state.loop_state != HeroState.DEAD_RESPAWNING:
		return {}
	respawn_ticks_remaining = maxi(0, respawn_ticks_remaining - 1)
	if respawn_ticks_remaining <= 0:
		hero_state.current_hp = minf(RESURRECTION_HP, combat_stats.max_hp)
		hero_state.loop_state = HeroState.RECOVERING_IN_CITY
		return {
			"type": "resurrected",
			"current_hp": hero_state.current_hp,
			"max_hp": combat_stats.max_hp,
			"respawn_ticks_remaining": 0,
		}
	return {
		"type": "waiting",
		"respawn_ticks_remaining": respawn_ticks_remaining,
	}

func force_resurrection(hero_state, combat_stats: CombatStats):
	if hero_state == null or combat_stats == null or not failure_recovery_active or hero_state.loop_state != HeroState.DEAD_RESPAWNING:
		return null
	respawn_ticks_remaining = 0
	hero_state.current_hp = minf(RESURRECTION_HP, combat_stats.max_hp)
	hero_state.loop_state = HeroState.RECOVERING_IN_CITY
	return {
		"type": "resurrected",
		"current_hp": hero_state.current_hp,
		"max_hp": combat_stats.max_hp,
		"respawn_ticks_remaining": 0,
	}

func advance_city_recovery(hero_state, combat_stats: CombatStats) -> Dictionary:
	if hero_state == null or combat_stats == null or not failure_recovery_active or hero_state.loop_state != HeroState.RECOVERING_IN_CITY:
		return {}
	hero_state.current_hp = minf(combat_stats.max_hp, hero_state.current_hp + combat_stats.max_hp * CITY_RECOVERY_PERCENT_OF_MAX_HP)
	var fully_recovered: bool = is_equal_approx(hero_state.current_hp, combat_stats.max_hp)
	if fully_recovered:
		hero_state.current_hp = combat_stats.max_hp
		hero_state.loop_state = HeroState.CHOOSING_QUEST
		failure_recovery_active = false
	return {
		"type": "city_recovery",
		"current_hp": hero_state.current_hp,
		"max_hp": combat_stats.max_hp,
		"fully_recovered": fully_recovered,
	}

func owns_respawn_state() -> bool:
	return failure_recovery_active

func cancel_for_external_failure():
	var cancelled_dungeon = active_dungeon
	clear()
	return cancelled_dungeon

func clear() -> void:
	active_dungeon = null
	ordinary_encounters_completed = 0
	boss_defeated = false
	between_fight_ticks_remaining = 0
	respawn_ticks_remaining = 0
	failure_recovery_active = false
	attempt_start_power = 0.0
	travel_system.clear_travel()
