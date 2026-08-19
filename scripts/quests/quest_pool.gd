class_name QuestPool
extends RefCounted

const DEFAULT_QUEST_DIRECTORY: String = "res://data/quests"

var available_quests: Array[Resource] = []

func _init(initial_quests: Array = []) -> void:
	if initial_quests.is_empty():
		reload_from_directory()
	else:
		set_available_quests(initial_quests)

func set_available_quests(quest_definitions: Array) -> void:
	available_quests.clear()
	for quest_definition in quest_definitions:
		if quest_definition != null:
			available_quests.append(quest_definition)

func reload_from_directory(quest_directory: String = DEFAULT_QUEST_DIRECTORY) -> void:
	available_quests.clear()

	var directory := DirAccess.open(quest_directory)
	assert(directory != null, "QuestPool could not open quest directory: %s" % quest_directory)

	var file_names := PackedStringArray()
	directory.list_dir_begin()
	var file_name := directory.get_next()
	while not file_name.is_empty():
		if not directory.current_is_dir() and file_name.get_extension().to_lower() == "tres":
			file_names.append(file_name)
		file_name = directory.get_next()
	directory.list_dir_end()

	file_names.sort()

	for quest_file_name in file_names:
		var quest_path: String = "%s/%s" % [quest_directory, quest_file_name]
		var quest_definition: Resource = load(quest_path)
		assert(quest_definition != null, "QuestPool could not load quest: %s" % quest_path)
		assert(quest_definition.mob_definition != null, "Quest must reference a mob: %s" % quest_path)
		available_quests.append(quest_definition)

func get_available_quests() -> Array[Resource]:
	var result: Array[Resource] = []
	result.append_array(available_quests)
	return result
