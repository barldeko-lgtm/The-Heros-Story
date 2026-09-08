class_name HeroBackground
extends RefCounted

const DATA_PATH := "res://data/hero/starting_background.json"
const ATTRIBUTES: Array[String] = ["strength", "dexterity", "constitution", "intelligence", "wisdom"]
const AXES: Array[String] = ["courage", "morality", "greed", "curiosity"]
var questions: Array = []

func _init() -> void:
	var data = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	assert(data is Array and data.size() == 4, "Starting background requires four authored questions.")
	questions = data

func resolve_answers(answers: Array) -> Dictionary:
	if answers.size() != questions.size():
		return {}
	var attributes: Dictionary = {}
	var personality: Dictionary = {}
	for attribute in ATTRIBUTES:
		attributes[attribute] = 0
	for axis in AXES:
		personality[axis] = 0
	for index in range(questions.size()):
		if not answers[index] is int:
			return {}
		var choice: int = answers[index]
		var options: Array = questions[index].answers
		if choice < 0 or choice >= options.size():
			return {}
		var option: Dictionary = options[choice]
		var attribute: String = option.attribute
		var axis: String = option.axis
		if not attribute.is_empty():
			if not attributes.has(attribute):
				return {}
			attributes[attribute] += 1
		if not axis.is_empty():
			if not personality.has(axis):
				return {}
			personality[axis] += int(option.delta)
	return {"attributes": attributes, "personality": personality}

func apply_to(hero_state, trait_development, answers: Array) -> bool:
	if hero_state == null or trait_development == null or not hero_state.background_answers.is_empty():
		return false
	var result: Dictionary = resolve_answers(answers)
	if result.is_empty():
		return false
	for attribute in ATTRIBUTES:
		hero_state.set(attribute, int(hero_state.get(attribute)) + int(result.attributes[attribute]))
	trait_development.reset_state(hero_state)
	for axis in AXES:
		trait_development.apply_movement(hero_state, axis, int(result.personality[axis]))
	hero_state.background_answers.assign(answers)
	return true
