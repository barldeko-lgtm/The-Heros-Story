class_name TraitDevelopment
extends RefCounted

const HeroTraitsScript = preload("res://scripts/hero/hero_traits.gd")

const AXIS_COURAGE := "courage"
const AXIS_MORALITY := "morality"
const AXIS_GREED := "greed"
const AXIS_CURIOSITY := "curiosity"
const AXIS_ORDER: Array[String] = [AXIS_COURAGE, AXIS_MORALITY, AXIS_GREED, AXIS_CURIOSITY]

const TRAIT_BRAVE := HeroTraitsScript.BRAVE
const TRAIT_CAUTIOUS := HeroTraitsScript.CAUTIOUS
const TRAIT_NOBLE := HeroTraitsScript.NOBLE
const TRAIT_DEVIOUS := HeroTraitsScript.DEVIOUS
const TRAIT_GREEDY := HeroTraitsScript.GREEDY
const TRAIT_GENEROUS := HeroTraitsScript.GENEROUS
const TRAIT_CURIOUS := HeroTraitsScript.CURIOUS
const TRAIT_CONSERVATIVE := HeroTraitsScript.CONSERVATIVE

const MIN_AXIS_VALUE: int = -100
const MAX_AXIS_VALUE: int = 100
const ACTIVATION_THRESHOLD: int = 40
const RETURN_TO_NEUTRAL_THRESHOLD: int = 20

const POSITIVE_TRAIT_BY_AXIS := {
	AXIS_COURAGE: TRAIT_BRAVE,
	AXIS_MORALITY: TRAIT_NOBLE,
	AXIS_GREED: TRAIT_GENEROUS,
	AXIS_CURIOSITY: TRAIT_CURIOUS,
}

const NEGATIVE_TRAIT_BY_AXIS := {
	AXIS_COURAGE: TRAIT_CAUTIOUS,
	AXIS_MORALITY: TRAIT_DEVIOUS,
	AXIS_GREED: TRAIT_GREEDY,
	AXIS_CURIOSITY: TRAIT_CONSERVATIVE,
}

func ensure_state(hero_state) -> void:
	if hero_state == null:
		return
	for axis_id in POSITIVE_TRAIT_BY_AXIS:
		if not hero_state.personality_axis_values.has(axis_id):
			hero_state.personality_axis_values[axis_id] = 0
		if not hero_state.personality_traits_by_axis.has(axis_id):
			hero_state.personality_traits_by_axis[axis_id] = ""

func reset_state(hero_state) -> void:
	ensure_state(hero_state)
	if hero_state == null:
		return
	for axis_id in AXIS_ORDER:
		hero_state.personality_axis_values[axis_id] = 0
		hero_state.personality_traits_by_axis[axis_id] = ""

func apply_starting_traits(hero_state, starting_traits: Array) -> void:
	reset_state(hero_state)
	if hero_state == null:
		return
	for axis_id in AXIS_ORDER:
		var positive_trait: String = str(POSITIVE_TRAIT_BY_AXIS[axis_id])
		var negative_trait: String = str(NEGATIVE_TRAIT_BY_AXIS[axis_id])
		if starting_traits.has(positive_trait):
			apply_movement(hero_state, axis_id, ACTIVATION_THRESHOLD)
		elif starting_traits.has(negative_trait):
			apply_movement(hero_state, axis_id, -ACTIVATION_THRESHOLD)

func apply_movement(hero_state, axis_id: String, delta: int) -> Dictionary:
	ensure_state(hero_state)
	if hero_state == null or not POSITIVE_TRAIT_BY_AXIS.has(axis_id) or delta == 0:
		return {}

	var previous_value: int = int(hero_state.personality_axis_values.get(axis_id, 0))
	var previous_trait: String = str(hero_state.personality_traits_by_axis.get(axis_id, ""))
	var new_value: int = clampi(previous_value + delta, MIN_AXIS_VALUE, MAX_AXIS_VALUE)
	hero_state.personality_axis_values[axis_id] = new_value

	var new_trait: String = previous_trait
	var positive_trait: String = str(POSITIVE_TRAIT_BY_AXIS[axis_id])
	var negative_trait: String = str(NEGATIVE_TRAIT_BY_AXIS[axis_id])
	if previous_trait.is_empty():
		if new_value >= ACTIVATION_THRESHOLD:
			new_trait = positive_trait
		elif new_value <= -ACTIVATION_THRESHOLD:
			new_trait = negative_trait
	elif previous_trait == positive_trait:
		if new_value <= RETURN_TO_NEUTRAL_THRESHOLD:
			new_trait = ""
	elif previous_trait == negative_trait:
		if new_value >= -RETURN_TO_NEUTRAL_THRESHOLD:
			new_trait = ""
	else:
		new_trait = ""

	hero_state.personality_traits_by_axis[axis_id] = new_trait
	return {
		"axis_id": axis_id,
		"delta": delta,
		"previous_value": previous_value,
		"new_value": new_value,
		"previous_trait": previous_trait,
		"new_trait": new_trait,
	}

func get_axis_value(hero_state, axis_id: String) -> int:
	ensure_state(hero_state)
	return 0 if hero_state == null else int(hero_state.personality_axis_values.get(axis_id, 0))

func get_established_trait(hero_state, axis_id: String) -> String:
	ensure_state(hero_state)
	return "" if hero_state == null else str(hero_state.personality_traits_by_axis.get(axis_id, ""))

func get_established_traits(hero_state) -> Array[String]:
	ensure_state(hero_state)
	var result: Array[String] = []
	if hero_state == null:
		return result
	for axis_id in AXIS_ORDER:
		var trait_id: String = str(hero_state.personality_traits_by_axis.get(axis_id, ""))
		if not trait_id.is_empty():
			result.append(trait_id)
	return result

func has_trait(hero_state, trait_id: String) -> bool:
	ensure_state(hero_state)
	if hero_state == null or trait_id.is_empty():
		return false
	for current_trait in hero_state.personality_traits_by_axis.values():
		if str(current_trait) == trait_id:
			return true
	return false
