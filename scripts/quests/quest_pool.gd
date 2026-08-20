class_name QuestPool
extends RefCounted

const DEFAULT_QUEST_DIRECTORY: String = "res://data/quests"
const QuestOfferScript = preload("res://scripts/model/runtime/quest_offer.gd")

var available_quests: Array = []
var quest_templates: Array[Resource] = []
var random_number_generator: RandomNumberGenerator

func _init(initial_quests: Array = [], initial_rng: RandomNumberGenerator = null) -> void:
	random_number_generator = initial_rng
	if random_number_generator == null:
		random_number_generator = RandomNumberGenerator.new()
		random_number_generator.seed = 1
	if initial_quests.is_empty():
		reload_from_directory()
	else:
		set_available_quests(initial_quests)

func set_available_quests(quest_definitions: Array) -> void:
	quest_templates.clear()
	available_quests.clear()
	for quest_definition in quest_definitions:
		if quest_definition != null:
			available_quests.append(quest_definition)

func set_quest_templates(template_definitions: Array) -> void:
	quest_templates.clear()
	for template_definition in template_definitions:
		if template_definition != null:
			quest_templates.append(template_definition)
	regenerate_all_offers()

func reload_from_directory(quest_directory: String = DEFAULT_QUEST_DIRECTORY) -> void:
	quest_templates.clear()

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
		quest_templates.append(quest_definition)

	regenerate_all_offers()

func regenerate_all_offers() -> void:
	available_quests.clear()
	for quest_template in quest_templates:
		available_quests.append(create_offer(quest_template))

func replace_offer(completed_or_cancelled_offer) -> void:
	var offer_index := available_quests.find(completed_or_cancelled_offer)
	if offer_index < 0:
		return

	var quest_template: Resource = get_template_by_id(completed_or_cancelled_offer.id)
	if quest_template == null:
		return
	available_quests[offer_index] = create_offer(quest_template)

func get_template_by_id(quest_id: String) -> Resource:
	for quest_template in quest_templates:
		if quest_template.id == quest_id:
			return quest_template
	return null

func create_offer(quest_template: Resource):
	assert(quest_template.mob_count_min >= 1, "Quest mob count minimum must be at least one: %s" % quest_template.id)
	assert(quest_template.mob_count_max >= quest_template.mob_count_min, "Quest mob count range is invalid: %s" % quest_template.id)
	assert(quest_template.distance_km_min >= 1, "Quest distance minimum must be at least one kilometre: %s" % quest_template.id)
	assert(quest_template.distance_km_max >= quest_template.distance_km_min, "Quest distance range is invalid: %s" % quest_template.id)
	assert(quest_template.gold_per_mob_min >= 1, "Quest per-mob gold minimum must be at least one: %s" % quest_template.id)
	assert(quest_template.gold_per_mob_max >= quest_template.gold_per_mob_min, "Quest per-mob gold range is invalid: %s" % quest_template.id)

	return QuestOfferScript.new(
		quest_template,
		random_number_generator.randi_range(quest_template.mob_count_min, quest_template.mob_count_max),
		float(random_number_generator.randi_range(quest_template.distance_km_min, quest_template.distance_km_max)),
		random_number_generator.randi_range(quest_template.gold_per_mob_min, quest_template.gold_per_mob_max),
	)

func get_available_quests() -> Array:
	var result: Array = []
	result.append_array(available_quests)
	return result
