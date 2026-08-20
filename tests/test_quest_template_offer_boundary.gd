extends SceneTree

const QuestDefinitionScript = preload("res://scripts/model/definitions/quest_definition.gd")
const QuestOfferScript = preload("res://scripts/model/runtime/quest_offer.gd")

func _init() -> void:
	var template = QuestDefinitionScript.new()
	template.id = "wolves"
	template.display_name = "Волки"
	template.mob_count_min = 4
	template.mob_count_max = 6
	template.distance_km_min = 2
	template.distance_km_max = 4
	template.gold_per_mob_min = 12
	template.gold_per_mob_max = 14

	assert(not has_property(template, "mob_count"), "A quest template must not store a rolled mob count.")
	assert(not has_property(template, "distance_km"), "A quest template must not store a rolled distance.")
	assert(not has_property(template, "gold_per_mob"), "A quest template must not store a rolled per-mob reward.")
	assert(not has_property(template, "gold_reward"), "A quest template must not store a total quest reward.")

	var offer = QuestOfferScript.new(template, 5, 3, 15)
	assert(offer.mob_count == 5, "A runtime offer must own its rolled mob count.")
	assert(is_equal_approx(offer.distance_km, 3.0), "A runtime offer must own its rolled distance.")
	assert(offer.gold_per_mob == 15, "A runtime offer must own its rolled per-mob reward.")
	assert(offer.gold_reward == 75, "Runtime total reward must be derived from rolled count and per-mob reward.")

	print("PASS: Quest templates contain only ranges and offers derive their total reward.")
	quit()

func has_property(object: Object, property_name: String) -> bool:
	for property_info in object.get_property_list():
		if property_info.name == property_name:
			return true
	return false
