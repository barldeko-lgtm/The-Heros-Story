class_name EventRunner
extends RefCounted

const EventStageDefinitionScript = preload("res://scripts/model/definitions/event_stage_definition.gd")
const EventDecisionResolverScript = preload("res://scripts/events/event_decision_resolver.gd")

const RESPAWN_DURATION_TICKS: int = 100
const RESURRECTION_HP: float = 1.0
const CITY_RECOVERY_PERCENT_OF_MAX_HP: float = 0.20

var travel_system
var trait_development
var resolution_rng: RandomNumberGenerator
var decision_resolver = EventDecisionResolverScript.new()
var active_event
var current_stage_ticks_remaining: int = 0
var interrupted_loop_state: String = ""
var had_suspended_travel: bool = false
var respawn_ticks_remaining: int = 0
var failure_recovery_active: bool = false
var failed_event_name: String = ""

func _init(initial_travel_system, initial_trait_development, initial_resolution_rng: RandomNumberGenerator) -> void:
	travel_system = initial_travel_system
	trait_development = initial_trait_development
	resolution_rng = initial_resolution_rng
	assert(travel_system != null, "EventRunner requires TravelSystem.")
	assert(trait_development != null, "EventRunner requires TraitDevelopment.")
	assert(resolution_rng != null, "EventRunner requires a seeded resolution RNG.")

func begin(hero_state, event_instance) -> Dictionary:
	if hero_state == null or event_instance == null or active_event != null:
		return {}
	active_event = event_instance
	interrupted_loop_state = hero_state.loop_state
	had_suspended_travel = travel_system.suspend_travel()
	enter_stage(hero_state, event_instance.definition.start_stage_id)
	return {
		"type": "event_started",
		"event_instance": active_event,
		"stage": get_current_stage(),
		"interrupted_loop_state": interrupted_loop_state,
		"travel_suspended": had_suspended_travel,
	}

func get_current_stage():
	if active_event == null or active_event.definition == null:
		return null
	return active_event.definition.get_stage(active_event.current_stage_id)

func get_current_mob_definition():
	var stage = get_current_stage()
	if stage == null or stage.stage_type != EventStageDefinitionScript.StageType.COMBAT:
		return null
	return stage.mob_definition

func enter_stage(hero_state, stage_id: String) -> void:
	assert(active_event != null and active_event.definition != null, "EventRunner requires an active event before entering a stage.")
	var stage = active_event.definition.get_stage(stage_id)
	assert(stage != null, "Event stage id must exist: %s" % stage_id)
	active_event.current_stage_id = stage_id
	current_stage_ticks_remaining = maxi(1, int(stage.duration_ticks))
	if stage.stage_type == EventStageDefinitionScript.StageType.COMBAT:
		hero_state.loop_state = HeroState.EVENT_COMBAT
	else:
		hero_state.loop_state = HeroState.EVENT_ACTIVE

func advance(hero_state) -> Dictionary:
	if hero_state == null or active_event == null or hero_state.loop_state != HeroState.EVENT_ACTIVE:
		return {}
	var stage = get_current_stage()
	if stage == null or stage.stage_type == EventStageDefinitionScript.StageType.COMBAT:
		return {}

	var stage_started: bool = current_stage_ticks_remaining == maxi(1, int(stage.duration_ticks))
	current_stage_ticks_remaining = maxi(0, current_stage_ticks_remaining - 1)
	if current_stage_ticks_remaining > 0:
		return {
			"type": "stage_progress",
			"event_instance": active_event,
			"stage": stage,
			"stage_started": stage_started,
			"ticks_remaining": current_stage_ticks_remaining,
		}

	match stage.stage_type:
		EventStageDefinitionScript.StageType.SCENE:
			var completed_scene = stage
			enter_stage(hero_state, stage.next_stage_id)
			return {
				"type": "scene_completed",
				"event_instance": active_event,
				"stage": completed_scene,
				"next_stage": get_current_stage(),
			}
		EventStageDefinitionScript.StageType.DECISION:
			return resolve_decision(hero_state, stage)
		EventStageDefinitionScript.StageType.END:
			return {
				"type": "event_completed",
				"event_instance": active_event,
				"stage": stage,
				"outcome_id": stage.outcome_id,
			}
	return {}

func resolve_decision(hero_state, stage) -> Dictionary:
	if stage.selection_rule == EventStageDefinitionScript.RULE_HIGHEST_PRIMARY_ATTRIBUTE:
		var resolution: Dictionary = decision_resolver.resolve_highest_primary_attribute(hero_state, stage.options, resolution_rng)
		assert(not resolution.is_empty(), "Highest-primary-attribute event decision must resolve to one authored option.")
		var selected_option = resolution["selected_option"]
		var personality_change: Dictionary = {}
		if not selected_option.personality_axis_id.is_empty() and selected_option.personality_delta != 0:
			personality_change = trait_development.apply_movement(hero_state, selected_option.personality_axis_id, selected_option.personality_delta)
		enter_stage(hero_state, selected_option.next_stage_id)
		resolution["type"] = "formative_decision"
		resolution["event_instance"] = active_event
		resolution["stage"] = stage
		resolution["personality_change"] = personality_change
		resolution["next_stage"] = get_current_stage()
		return resolution

	if stage.selection_rule == EventStageDefinitionScript.RULE_TRAIT_PRESENT:
		var trait_present: bool = trait_development.has_trait(hero_state, stage.checked_trait_id)
		var next_stage_id: String = stage.trait_present_stage_id if trait_present else stage.trait_absent_stage_id
		enter_stage(hero_state, next_stage_id)
		return {
			"type": "expressive_trait_check",
			"event_instance": active_event,
			"stage": stage,
			"checked_trait_id": stage.checked_trait_id,
			"trait_present": trait_present,
			"next_stage": get_current_stage(),
		}
	return {}

func complete_combat(hero_state, combat_stats: CombatStats, combat_result) -> Dictionary:
	if hero_state == null or combat_stats == null or combat_result == null or active_event == null:
		return {}
	var stage = get_current_stage()
	if stage == null or stage.stage_type != EventStageDefinitionScript.StageType.COMBAT:
		return {}
	hero_state.current_hp = maxf(0.0, combat_result.hero_remaining_hp)
	if not combat_result.hero_won:
		failed_event_name = active_event.definition.display_name
		failure_recovery_active = true
		respawn_ticks_remaining = RESPAWN_DURATION_TICKS
		travel_system.clear_travel()
		hero_state.loop_state = HeroState.DEAD_RESPAWNING
		return {
			"type": "died",
			"event_instance": active_event,
			"stage": stage,
			"current_hp": hero_state.current_hp,
			"max_hp": combat_stats.max_hp,
			"respawn_ticks_remaining": respawn_ticks_remaining,
		}

	var completed_stage = stage
	enter_stage(hero_state, stage.combat_victory_stage_id)
	return {
		"type": "combat_won",
		"event_instance": active_event,
		"stage": completed_stage,
		"next_stage": get_current_stage(),
		"current_hp": hero_state.current_hp,
		"max_hp": combat_stats.max_hp,
	}

func finish_success(hero_state) -> bool:
	if hero_state == null or active_event == null:
		return false
	var restored_state: String = interrupted_loop_state
	var should_resume_travel: bool = had_suspended_travel
	active_event = null
	current_stage_ticks_remaining = 0
	interrupted_loop_state = ""
	had_suspended_travel = false
	if should_resume_travel:
		assert(travel_system.resume_suspended_travel(), "Interrupted event travel must resume toward the original destination.")
	hero_state.loop_state = restored_state
	return true

func finalize_failure() -> void:
	active_event = null
	current_stage_ticks_remaining = 0
	interrupted_loop_state = ""
	had_suspended_travel = false

func advance_respawn(hero_state, combat_stats: CombatStats) -> Dictionary:
	if hero_state == null or combat_stats == null or not failure_recovery_active or hero_state.loop_state != HeroState.DEAD_RESPAWNING:
		return {}
	respawn_ticks_remaining = maxi(0, respawn_ticks_remaining - 1)
	if respawn_ticks_remaining <= 0:
		hero_state.current_hp = minf(RESURRECTION_HP, combat_stats.max_hp)
		hero_state.loop_state = HeroState.RECOVERING_IN_CITY
		return {
			"type": "resurrected",
			"event_name": failed_event_name,
			"current_hp": hero_state.current_hp,
			"respawn_ticks_remaining": 0,
		}
	return {
		"type": "waiting",
		"event_name": failed_event_name,
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
		"event_name": failed_event_name,
		"current_hp": hero_state.current_hp,
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
		failed_event_name = ""
	return {
		"type": "city_recovery",
		"current_hp": hero_state.current_hp,
		"max_hp": combat_stats.max_hp,
		"fully_recovered": fully_recovered,
	}

func owns_respawn_state() -> bool:
	return failure_recovery_active
