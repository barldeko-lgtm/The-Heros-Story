class_name HeroNameRepository
extends RefCounted

const NAMES_PATH: String = "res://data/hero_names_ru.txt"

var random_number_generator: RandomNumberGenerator = RandomNumberGenerator.new()

func _init() -> void:
	random_number_generator.randomize()

func load_names() -> Array[String]:
	var names: Array[String] = []
	var file_content: String = FileAccess.get_file_as_string(NAMES_PATH)

	for line in file_content.split("\n"):
		var hero_name: String = line.strip_edges()
		if not hero_name.is_empty():
			names.append(hero_name)

	return names

func get_random_name() -> String:
	var names: Array[String] = load_names()
	if names.is_empty():
		return "Безымянный"
	return names[random_number_generator.randi_range(0, names.size() - 1)]
