class_name QuestPool
extends RefCounted

const DEFAULT_QUEST_DIRECTORY: String = "res://data/quests"
const QuestOfferScript = preload("res://scripts/model/runtime/quest_offer.gd")
const QuestEventScript = preload("res://scripts/quests/quest_event.gd")
const HeroStateScript = preload("res://scripts/hero/hero_state.gd")
const ActivityPlacementFinderScript = preload("res://scripts/world/activity_placement_finder.gd")

var available_quests: Array = []
var quest_templates: Array[Resource] = []
var random_number_generator: RandomNumberGenerator
var placement_random_number_generator: RandomNumberGenerator
var placement_hex_map
var placement_world_state
var placement_region_id: String = ""
var placement_distance_origin: Vector2i = Vector2i(-1, -1)
var activity_placement_finder = ActivityPlacementFinderScript.new()
var next_map_activity_sequence: int = 1
var pending_cancelled_offer

func _init(initial_quests: Array = [], initial_rng: RandomNumberGenerator = null) -> void:
	random_number_generator = initial_rng
	if random_number_generator == null:
		random_number_generator = RandomNumberGenerator.new()
		random_number_generator.seed = 1
	if initial_quests.is_empty():
		reload_from_directory()
	else:
		set_available_quests(initial_quests)

func configure_map_placement(initial_hex_map, initial_world_state, region_id: String, distance_origin: Vector2i, initial_placement_rng: RandomNumberGenerator = null) -> bool:
	placement_hex_map = initial_hex_map
	placement_world_state = initial_world_state
	placement_region_id = region_id
	placement_distance_origin = distance_origin
	placement_random_number_generator = initial_placement_rng
	if placement_random_number_generator == null:
		placement_random_number_generator = RandomNumberGenerator.new()
		placement_random_number_generator.seed = 1
	return assign_map_targets_to_current_offers()

func has_map_placement_context() -> bool:
	return placement_hex_map != null and placement_world_state != null and not placement_region_id.is_empty() and placement_hex_map.is_valid_cell(placement_distance_origin)

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
	for existing_offer in available_quests:
		release_offer_map_target(existing_offer)
	available_quests.clear()
	for quest_template in quest_templates:
		available_quests.append(create_offer(quest_template, QuestOfferScript.INVALID_TARGET_HEX, false))
	if has_map_placement_context():
		assert(assign_map_targets_to_current_offers(), "Current quest board could not be placed on unique valid map hexes.")

func replace_offer(completed_or_cancelled_offer) -> void:
	var offer_index := available_quests.find(completed_or_cancelled_offer)
	if offer_index < 0:
		return

	var quest_template: Resource = get_template_by_id(completed_or_cancelled_offer.id)
	if quest_template == null:
		return
	var previous_target: Vector2i = QuestOfferScript.INVALID_TARGET_HEX
	if completed_or_cancelled_offer.has_method("has_map_target") and completed_or_cancelled_offer.has_map_target():
		previous_target = completed_or_cancelled_offer.target_hex
	release_offer_map_target(completed_or_cancelled_offer)
	available_quests[offer_index] = create_offer(quest_template, previous_target)

func handle_quest_event(event, hero_loop_state: String) -> void:
	if event == null:
		return
	if event.event_type == QuestEventScript.HERO_RECOVERED_AFTER_FIGHT and hero_loop_state == HeroStateScript.RETURNING_TO_CITY and event.completed_mob_count >= event.mob_count:
		release_offer_map_target(event.quest_definition)
		return
	if event.event_type == QuestEventScript.HERO_TURNED_IN_QUEST:
		replace_offer(event.quest_definition)
		return
	if event.event_type == QuestEventScript.HERO_DIED:
		release_offer_map_target(event.quest_definition)
		pending_cancelled_offer = event.quest_definition
		return
	if event.event_type == QuestEventScript.HERO_RECOVERING_IN_CITY and hero_loop_state == HeroStateScript.CHOOSING_QUEST and pending_cancelled_offer != null:
		replace_offer(pending_cancelled_offer)
		pending_cancelled_offer = null

func get_template_by_id(quest_id: String) -> Resource:
	for quest_template in quest_templates:
		if quest_template.id == quest_id:
			return quest_template
	return null

func create_offer(quest_template: Resource, excluded_target: Vector2i = QuestOfferScript.INVALID_TARGET_HEX, place_on_map: bool = true):
	assert(quest_template.mob_count_min >= 1, "Quest mob count minimum must be at least one: %s" % quest_template.id)
	assert(quest_template.mob_count_max >= quest_template.mob_count_min, "Quest mob count range is invalid: %s" % quest_template.id)
	assert(quest_template.distance_km_min >= 1, "Quest distance minimum must be at least one kilometre: %s" % quest_template.id)
	assert(quest_template.distance_km_max >= quest_template.distance_km_min, "Quest distance range is invalid: %s" % quest_template.id)
	assert(quest_template.gold_per_mob_min >= 1, "Quest per-mob gold minimum must be at least one: %s" % quest_template.id)
	assert(quest_template.gold_per_mob_max >= quest_template.gold_per_mob_min, "Quest per-mob gold range is invalid: %s" % quest_template.id)

	var offer = QuestOfferScript.new(
		quest_template,
		random_number_generator.randi_range(quest_template.mob_count_min, quest_template.mob_count_max),
		float(random_number_generator.randi_range(quest_template.distance_km_min, quest_template.distance_km_max)),
		random_number_generator.randi_range(quest_template.gold_per_mob_min, quest_template.gold_per_mob_max),
	)
	if place_on_map and has_map_placement_context():
		assert(place_offer_on_map(offer, excluded_target), "Quest offer could not be placed on the current map: %s" % quest_template.id)
	return offer

func assign_map_targets_to_current_offers() -> bool:
	if not has_map_placement_context():
		return false
	var pending_offers: Array = []
	for offer in available_quests:
		if offer != null and offer.has_method("has_map_target") and not offer.has_map_target():
			pending_offers.append(offer)
	var assigned_offers: Array = []
	while not pending_offers.is_empty():
		var selected_offer
		var selected_candidates: Array[Vector2i] = []
		for offer in pending_offers:
			var candidates: Array[Vector2i] = get_offer_map_candidates(offer)
			if candidates.is_empty():
				for assigned_offer in assigned_offers:
					release_offer_map_target(assigned_offer)
				return false
			if selected_offer == null or candidates.size() < selected_candidates.size():
				selected_offer = offer
				selected_candidates = candidates
		var selected_index: int = placement_random_number_generator.randi_range(0, selected_candidates.size() - 1)
		if not reserve_offer_target(selected_offer, selected_candidates[selected_index]):
			for assigned_offer in assigned_offers:
				release_offer_map_target(assigned_offer)
			return false
		assigned_offers.append(selected_offer)
		pending_offers.erase(selected_offer)
	return true

func get_offer_map_candidates(offer, excluded_target: Vector2i = QuestOfferScript.INVALID_TARGET_HEX) -> Array[Vector2i]:
	var candidates: Array[Vector2i] = activity_placement_finder.find_valid_centers(
		placement_hex_map,
		placement_world_state,
		placement_region_id,
		placement_distance_origin,
		offer.template.placement_distance_hex_min,
		offer.template.placement_distance_hex_max,
		offer.template.placement_allowed_terrain_ids,
		offer.template.placement_allowed_tags,
		offer.template.placement_forbidden_tags,
		0
	)
	if excluded_target != QuestOfferScript.INVALID_TARGET_HEX and candidates.size() > 1:
		candidates.erase(excluded_target)
	return candidates

func place_offer_on_map(offer, excluded_target: Vector2i = QuestOfferScript.INVALID_TARGET_HEX) -> bool:
	var candidates: Array[Vector2i] = get_offer_map_candidates(offer, excluded_target)
	if candidates.is_empty():
		return false
	var selected_index: int = placement_random_number_generator.randi_range(0, candidates.size() - 1)
	return reserve_offer_target(offer, candidates[selected_index])

func reserve_offer_target(offer, target_hex: Vector2i) -> bool:
	var activity_id: String = "quest_offer:%s:%d" % [offer.id, next_map_activity_sequence]
	var footprint: Array[Vector2i] = [target_hex]
	if not placement_world_state.reserve_activity(activity_id, footprint):
		return false
	var distance_steps: int = placement_hex_map.get_distance_steps(placement_distance_origin, target_hex)
	assert(distance_steps >= 0, "Quest target must have a valid route from its city center.")
	next_map_activity_sequence += 1
	offer.assign_map_target(target_hex, activity_id, distance_steps)
	return true

func release_offer_map_target(offer) -> bool:
	if offer == null or not offer.has_method("has_map_target") or not offer.has_map_target():
		return false
	var activity_id: String = offer.map_activity_id
	var released: bool = placement_world_state != null and placement_world_state.release_activity(activity_id)
	offer.clear_map_target()
	return released

func get_available_quests() -> Array:
	var result: Array = []
	result.append_array(available_quests)
	return result
