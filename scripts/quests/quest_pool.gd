class_name QuestPool
extends RefCounted

const DEFAULT_QUEST_DIRECTORY: String = "res://data/quests"
const QuestOfferScript = preload("res://scripts/model/runtime/quest_offer.gd")
const QuestEventScript = preload("res://scripts/quests/quest_event.gd")
const HeroStateScript = preload("res://scripts/hero/hero_state.gd")
const ActivityPlacementFinderScript = preload("res://scripts/world/activity_placement_finder.gd")
const BOARD_REFRESH_INTERVAL_TICKS: int = 50
const COMPLETED_TEMPLATE_COOLDOWN_TICKS: int = 50
const STRENGTH_BANDS: Array[String] = ["lower", "middle", "higher"]

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
var active_taken_offer
var template_cooldown_until_tick: Dictionary = {}
var last_board_refresh_tick: int = 0

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
	for existing_offer in available_quests:
		release_offer_map_target(existing_offer)
	quest_templates.clear()
	available_quests.clear()
	active_taken_offer = null
	template_cooldown_until_tick.clear()
	last_board_refresh_tick = 0
	for template_definition in template_definitions:
		if template_definition != null:
			assert(STRENGTH_BANDS.has(str(template_definition.strength_band)), "Quest template has an invalid strength band: %s" % template_definition.id)
			quest_templates.append(template_definition)
	refresh_board(0)

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
		assert(STRENGTH_BANDS.has(str(quest_definition.strength_band)), "Quest must use a valid strength band: %s" % quest_path)
		quest_templates.append(quest_definition)

	refresh_board(0)

func refresh_board(current_tick: int) -> bool:
	release_available_offer_map_targets()
	available_quests.clear()
	for strength_band in STRENGTH_BANDS:
		var eligible_templates: Array = get_eligible_templates_for_band(strength_band, current_tick)
		for quest_template in eligible_templates:
			available_quests.append(create_offer(quest_template, QuestOfferScript.INVALID_TARGET_HEX, false))
	if has_map_placement_context():
		var _assert_assign_map_targets_to_current_offers_ok_1: bool = assign_map_targets_to_current_offers()
		assert(_assert_assign_map_targets_to_current_offers_ok_1, "Current quest board could not be placed on unique valid map hexes.")
	last_board_refresh_tick = current_tick
	return true

func release_available_offer_map_targets() -> void:
	for existing_offer in available_quests:
		release_offer_map_target(existing_offer)

func advance_world_tick(completed_tick: int) -> bool:
	if quest_templates.is_empty() or completed_tick <= 0:
		return false
	if completed_tick % BOARD_REFRESH_INTERVAL_TICKS != 0 or completed_tick == last_board_refresh_tick:
		return false
	return refresh_board(completed_tick)

func get_eligible_templates_for_band(strength_band: String, current_tick: int) -> Array:
	var result: Array = []
	for quest_template in quest_templates:
		if str(quest_template.strength_band) != strength_band:
			continue
		if active_taken_offer != null and active_taken_offer.id == quest_template.id:
			continue
		if current_tick < int(template_cooldown_until_tick.get(quest_template.id, 0)):
			continue
		result.append(quest_template)
	return result

func take_offer(offer) -> bool:
	var offer_index: int = available_quests.find(offer)
	if offer_index < 0:
		return false
	available_quests.remove_at(offer_index)
	active_taken_offer = offer
	return true

func mark_template_completed(offer, completed_tick: int) -> void:
	if offer == null:
		return
	template_cooldown_until_tick[offer.id] = completed_tick + COMPLETED_TEMPLATE_COOLDOWN_TICKS
	if active_taken_offer == offer:
		active_taken_offer = null

func cancel_taken_offer(offer) -> void:
	if offer == null:
		return
	release_offer_map_target(offer)
	if active_taken_offer == offer:
		active_taken_offer = null

func handle_quest_event(event, hero_loop_state: String, completed_tick: int = 0) -> void:
	if event == null:
		return
	if event.event_type == QuestEventScript.HERO_SELECTED_QUEST:
		var _assert_take_offer_ok_2: bool = take_offer(event.quest_definition)
		assert(_assert_take_offer_ok_2, "Selected autonomous quest must be removed from the active board until the next global refresh.")
		return
	if event.event_type == QuestEventScript.HERO_RECOVERED_AFTER_FIGHT and hero_loop_state == HeroStateScript.RETURNING_TO_CITY and event.completed_mob_count >= event.mob_count:
		release_offer_map_target(event.quest_definition)
		return
	if event.event_type == QuestEventScript.HERO_TURNED_IN_QUEST:
		mark_template_completed(event.quest_definition, completed_tick)
		return
	if event.event_type == QuestEventScript.HERO_DIED:
		release_offer_map_target(event.quest_definition)
		if active_taken_offer == event.quest_definition:
			active_taken_offer = null

func get_template_by_id(quest_id: String) -> Resource:
	for quest_template in quest_templates:
		if quest_template.id == quest_id:
			return quest_template
	return null

func get_template_cooldown_until_tick(quest_id: String) -> int:
	return int(template_cooldown_until_tick.get(quest_id, 0))

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
		var _assert_place_offer_on_map_ok_3: bool = place_offer_on_map(offer, excluded_target)
		assert(_assert_place_offer_on_map_ok_3, "Quest offer could not be placed on the current map: %s" % quest_template.id)
	return offer

func assign_map_targets_to_current_offers() -> bool:
	if not has_map_placement_context():
		return false
	var pending_offers: Array = []
	for offer in available_quests:
		if offer != null and offer.has_method("has_map_target") and not offer.has_map_target():
			pending_offers.append(offer)
	var candidates_by_offer: Dictionary = {}
	for offer in pending_offers:
		var candidates: Array[Vector2i] = get_offer_map_candidates(offer)
		candidates_by_offer[offer] = candidates
	var assigned_offers: Array = []
	while not pending_offers.is_empty():
		var unplaceable_offers: Array = []
		for offer in pending_offers:
			if candidates_by_offer[offer].is_empty():
				unplaceable_offers.append(offer)
		for offer in unplaceable_offers:
			pending_offers.erase(offer)
			candidates_by_offer.erase(offer)
			available_quests.erase(offer)
		if pending_offers.is_empty():
			break
		var selected_offer
		var selected_candidates: Array[Vector2i] = []
		for offer in pending_offers:
			var candidates: Array[Vector2i] = candidates_by_offer[offer]
			if selected_offer == null or candidates.size() < selected_candidates.size():
				selected_offer = offer
				selected_candidates = candidates
		var selected_index: int = placement_random_number_generator.randi_range(0, selected_candidates.size() - 1)
		if not reserve_offer_target(selected_offer, selected_candidates[selected_index]):
			for assigned_offer in assigned_offers:
				release_offer_map_target(assigned_offer)
			return false
		var reserved_target: Vector2i = selected_candidates[selected_index]
		assigned_offers.append(selected_offer)
		pending_offers.erase(selected_offer)
		candidates_by_offer.erase(selected_offer)
		for remaining_offer in pending_offers:
			var remaining_candidates: Array[Vector2i] = candidates_by_offer[remaining_offer]
			remaining_candidates.erase(reserved_target)
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
