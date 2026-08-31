extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const HexDefinitionScript = preload("res://scripts/model/definitions/hex_definition.gd")

func _init() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var simulation = SimulationScript.new(53, null)
	var hex_map = simulation.hex_map
	var world_state = simulation.world_state
	var start: Vector2i = hex_map.definition.starting_city_center
	var region_id: String = hex_map.STARTING_REGION_ID
	var quest_templates: Array[Resource] = simulation.quest_pool.quest_templates
	var quest_offers: Array = simulation.quest_pool.get_available_quests()

	assert(quest_templates.size() == 13, "Current Starting City content must expose exactly 13 quest templates for placement validation.")
	assert(quest_offers.size() == quest_templates.size(), "Every current Starting City quest template must produce one active board offer.")
	assert(world_state.hero_position == start, "Placing quest offers on the map must not move the hero from Starting City.")

	var placed_centers: Dictionary = {}
	for offer in quest_offers:
		var quest_template: Resource = offer.template
		assert(quest_template.placement_distance_hex_min >= 1, "Quest placement minimum must be at least one hex: %s" % quest_template.id)
		assert(quest_template.placement_distance_hex_max >= quest_template.placement_distance_hex_min, "Quest placement distance range must be valid: %s" % quest_template.id)
		assert(quest_template.placement_distance_hex_max <= hex_map.REGION_RADIUS_STEPS, "Starting City quest placement must remain within the seven-step region radius: %s" % quest_template.id)
		assert(not quest_template.placement_allowed_terrain_ids.is_empty() or not quest_template.placement_allowed_tags.is_empty(), "Every current quest must constrain placement by terrain or semantic tag: %s" % quest_template.id)
		assert(quest_template.placement_forbidden_tags.has(HexDefinitionScript.TAG_CITY), "Current ordinary quests must not reserve city hexes: %s" % quest_template.id)
		assert(offer.has_map_target(), "Every active quest-board offer must own a concrete reserved target hex: %s" % offer.id)
		assert(not placed_centers.has(offer.target_hex), "Two active quest-board offers must never share one target hex.")

		var chosen_hex = hex_map.get_hex(offer.target_hex)
		var chosen_distance: int = hex_map.get_distance_steps(start, offer.target_hex)
		assert(chosen_hex != null and chosen_hex.region_id == region_id, "Quest target must stay inside Starting Region: %s" % offer.id)
		assert(chosen_distance >= quest_template.placement_distance_hex_min and chosen_distance <= quest_template.placement_distance_hex_max, "Quest target must obey its authored hex-distance range: %s" % offer.id)
		if not quest_template.placement_allowed_terrain_ids.is_empty():
			assert(quest_template.placement_allowed_terrain_ids.has(chosen_hex.terrain_id), "Quest target must use an allowed terrain: %s" % offer.id)
		if not quest_template.placement_allowed_tags.is_empty():
			var has_allowed_tag: bool = false
			for tag in quest_template.placement_allowed_tags:
				if chosen_hex.has_tag(tag):
					has_allowed_tag = true
					break
			assert(has_allowed_tag, "Quest target must match at least one allowed tag: %s" % offer.id)
		assert(not chosen_hex.has_tag(HexDefinitionScript.TAG_CITY), "Ordinary quest target must stay outside city hexes: %s" % offer.id)
		assert(world_state.get_activity_id_at_hex(offer.target_hex) == offer.map_activity_id, "Quest target hex must be reserved by that exact QuestOffer activity id.")
		placed_centers[offer.target_hex] = offer.id

	assert(placed_centers.size() == quest_offers.size(), "All active quest-board offers must fit simultaneously on unique Starting Region hexes.")
	assert(world_state.activity_id_by_hex.size() == quest_offers.size(), "Current radius-0 quest board must reserve exactly one hex per offer.")

	var repeated_simulation = SimulationScript.new(53, null)
	var repeated_offers: Array = repeated_simulation.quest_pool.get_available_quests()
	assert(repeated_offers.size() == quest_offers.size(), "Repeated seeded simulation must create the same quest-board size.")
	for index in quest_offers.size():
		assert(repeated_offers[index].id == quest_offers[index].id, "Repeated seeded simulation must keep quest-board order stable.")
		assert(repeated_offers[index].target_hex == quest_offers[index].target_hex, "Quest map placement must be deterministic for the same simulation seed.")

	for probe_seed in [1, 2, 7, 17, 101, 999, 4242, 12345]:
		var probe_simulation = SimulationScript.new(probe_seed, null)
		var probe_offers: Array = probe_simulation.quest_pool.get_available_quests()
		assert(probe_offers.size() == 13, "Every sampled simulation seed must keep all current Starting City board offers.")
		var probe_targets: Dictionary = {}
		for probe_offer in probe_offers:
			assert(probe_offer.has_map_target(), "Every sampled simulation seed must place every board offer on the map.")
			assert(not probe_targets.has(probe_offer.target_hex), "Every sampled simulation seed must keep quest targets unique.")
			probe_targets[probe_offer.target_hex] = true

	print("PASS: All 13 Starting City board offers own valid unique deterministic target hexes across sampled seeds without moving the hero.")
	quit()
