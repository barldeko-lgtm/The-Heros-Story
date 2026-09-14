class_name HeroSpecialization
extends RefCounted

const HeroTraitsScript = preload("res://scripts/hero/hero_traits.gd")

const WARRIOR_ID := "warrior"
const PROTECTOR_ID := "protector"
const SLAYER_ID := "slayer"
const DECISION_LEVEL: int = 20
const DECISION_WINDOW_TICKS: int = 180
const PERSONALITY_MODIFIER: float = 0.05
const DIVINE_MODIFIER: float = 0.15
const TIE_RNG_SEED_OFFSET: int = 1_100_003
const SCORE_EPSILON: float = 0.000001

static func get_class_display_name(class_id: String) -> String:
	match class_id:
		PROTECTOR_ID: return "Защитник"
		SLAYER_ID: return "Истребитель"
	return "Воин"

static func is_valid_specialization_id(specialization_id: String) -> bool:
	return specialization_id == PROTECTOR_ID or specialization_id == SLAYER_ID

static func get_score_state(hero_state) -> Dictionary:
	var slayer_raw: float = float(hero_state.strength + hero_state.dexterity)
	var protector_raw: float = float(hero_state.constitution + hero_state.wisdom)
	var total_raw: float = slayer_raw + protector_raw
	var slayer_base: float = 0.5 if total_raw <= SCORE_EPSILON else slayer_raw / total_raw
	var protector_base: float = 0.5 if total_raw <= SCORE_EPSILON else protector_raw / total_raw

	var courage_trait: String = get_courage_trait_for_scoring(hero_state)
	var slayer_trait_modifier: float = PERSONALITY_MODIFIER if courage_trait == HeroTraitsScript.BRAVE else 0.0
	var protector_trait_modifier: float = PERSONALITY_MODIFIER if courage_trait == HeroTraitsScript.CAUTIOUS else 0.0
	var slayer_divine_modifier: float = DIVINE_MODIFIER if hero_state.specialization_guidance_id == SLAYER_ID else 0.0
	var protector_divine_modifier: float = DIVINE_MODIFIER if hero_state.specialization_guidance_id == PROTECTOR_ID else 0.0

	return {
		"slayer_raw": slayer_raw,
		"protector_raw": protector_raw,
		"slayer_base": slayer_base,
		"protector_base": protector_base,
		"courage_trait": courage_trait,
		"trait_is_frozen": hero_state.specialization_decision_start_tick >= 0,
		"slayer_trait_modifier": slayer_trait_modifier,
		"protector_trait_modifier": protector_trait_modifier,
		"slayer_divine_modifier": slayer_divine_modifier,
		"protector_divine_modifier": protector_divine_modifier,
		"slayer_score": slayer_base + slayer_trait_modifier + slayer_divine_modifier,
		"protector_score": protector_base + protector_trait_modifier + protector_divine_modifier,
	}

static func get_courage_trait_for_scoring(hero_state) -> String:
	if hero_state.specialization_decision_start_tick >= 0:
		return hero_state.specialization_courage_trait_snapshot
	var current_trait: String = str(hero_state.personality_traits_by_axis.get("courage", ""))
	return current_trait if current_trait == HeroTraitsScript.BRAVE or current_trait == HeroTraitsScript.CAUTIOUS else ""

static func start_if_needed(hero_state, current_tick: int) -> bool:
	if hero_state == null or hero_state.level < DECISION_LEVEL:
		return false
	if hero_state.hero_class_id != WARRIOR_ID or not hero_state.first_specialization_id.is_empty():
		return false
	if hero_state.specialization_decision_start_tick >= 0:
		return false

	var courage_trait: String = str(hero_state.personality_traits_by_axis.get("courage", ""))
	if courage_trait != HeroTraitsScript.BRAVE and courage_trait != HeroTraitsScript.CAUTIOUS:
		courage_trait = ""
	hero_state.specialization_decision_active = true
	hero_state.specialization_decision_start_tick = current_tick
	hero_state.specialization_decision_ticks_remaining = DECISION_WINDOW_TICKS
	hero_state.specialization_courage_trait_snapshot = courage_trait
	return true

static func can_apply_guidance(hero_state, specialization_id: String) -> bool:
	return (
		hero_state != null
		and hero_state.specialization_decision_active
		and hero_state.first_specialization_id.is_empty()
		and hero_state.specialization_guidance_id.is_empty()
		and is_valid_specialization_id(specialization_id)
	)

static func apply_guidance_and_resolve(hero_state, specialization_id: String, simulation_seed: int, decision_tick: int) -> String:
	if not can_apply_guidance(hero_state, specialization_id):
		return ""
	hero_state.specialization_guidance_id = specialization_id
	return resolve(hero_state, simulation_seed, decision_tick)

static func advance_world_tick(hero_state, completed_tick: int, simulation_seed: int) -> String:
	if hero_state == null or not hero_state.specialization_decision_active:
		return ""
	# The tick that granted Level 20 opens a full 180-tick window and does not consume one of those ticks itself.
	if completed_tick <= hero_state.specialization_decision_start_tick:
		return ""
	hero_state.specialization_decision_ticks_remaining = maxi(0, hero_state.specialization_decision_ticks_remaining - 1)
	if hero_state.specialization_decision_ticks_remaining > 0:
		return ""
	return resolve(hero_state, simulation_seed, completed_tick)

static func resolve(hero_state, simulation_seed: int, decision_tick: int) -> String:
	if hero_state == null or not hero_state.specialization_decision_active or not hero_state.first_specialization_id.is_empty():
		return ""
	var scores: Dictionary = get_score_state(hero_state)
	var protector_score: float = float(scores["protector_score"])
	var slayer_score: float = float(scores["slayer_score"])
	var result: String
	if protector_score > slayer_score + SCORE_EPSILON:
		result = PROTECTOR_ID
	elif slayer_score > protector_score + SCORE_EPSILON:
		result = SLAYER_ID
	else:
		var rng := RandomNumberGenerator.new()
		rng.seed = simulation_seed + TIE_RNG_SEED_OFFSET + hero_state.specialization_decision_start_tick * 7919
		result = PROTECTOR_ID if rng.randi_range(0, 1) == 0 else SLAYER_ID

	hero_state.specialization_final_protector_base = float(scores["protector_base"])
	hero_state.specialization_final_slayer_base = float(scores["slayer_base"])
	hero_state.specialization_final_protector_score = protector_score
	hero_state.specialization_final_slayer_score = slayer_score
	hero_state.first_specialization_id = result
	hero_state.specialization_decision_active = false
	hero_state.specialization_decision_ticks_remaining = 0
	hero_state.state_changed.emit()
	return result

static func grant_selected_specialization(hero_state) -> String:
	if hero_state == null or hero_state.hero_class_id != WARRIOR_ID:
		return ""
	var specialization_id: String = str(hero_state.first_specialization_id)
	if not is_valid_specialization_id(specialization_id):
		return ""
	hero_state.hero_class_id = specialization_id
	hero_state.state_changed.emit()
	return specialization_id

static func get_debug_state(hero_state) -> Dictionary:
	var scores: Dictionary = get_score_state(hero_state)
	scores["decision_level"] = DECISION_LEVEL
	scores["decision_active"] = hero_state.specialization_decision_active
	scores["decision_started"] = hero_state.specialization_decision_start_tick >= 0
	scores["ticks_remaining"] = hero_state.specialization_decision_ticks_remaining
	scores["guidance_id"] = hero_state.specialization_guidance_id
	scores["specialization_id"] = hero_state.first_specialization_id
	scores["pending_primary_attribute_points"] = hero_state.pending_primary_attribute_points
	if not hero_state.first_specialization_id.is_empty():
		scores["protector_base"] = hero_state.specialization_final_protector_base
		scores["slayer_base"] = hero_state.specialization_final_slayer_base
		scores["protector_score"] = hero_state.specialization_final_protector_score
		scores["slayer_score"] = hero_state.specialization_final_slayer_score
	scores["difference"] = absf(float(scores["protector_score"]) - float(scores["slayer_score"]))
	return scores
