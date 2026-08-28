extends SceneTree

const QuestPoolScript = preload("res://scripts/quests/quest_pool.gd")
const QuestDefinitionScript = preload("res://scripts/model/definitions/quest_definition.gd")
const MobDefinitionScript = preload("res://scripts/model/definitions/mob_definition.gd")

func _init() -> void:
	var first_rng := RandomNumberGenerator.new()
	first_rng.seed = 4242
	var first_pool = QuestPoolScript.new([make_template("placeholder_first")], first_rng)
	first_pool.set_quest_templates([make_template("wolves"), make_template("bears")])

	var first_offers: Array = first_pool.get_available_quests()
	assert(first_offers.size() == 2, "Each quest template must create one current tavern offer.")
	assert_offer_is_valid(first_offers[0])
	assert_offer_is_valid(first_offers[1])
	assert(first_offers[0].gold_reward == first_offers[0].mob_count * first_offers[0].gold_per_mob, "Total quest gold must equal the rolled per-mob reward times the rolled mob count.")

	var second_rng := RandomNumberGenerator.new()
	second_rng.seed = 4242
	var second_pool = QuestPoolScript.new([make_template("placeholder_second")], second_rng)
	second_pool.set_quest_templates([make_template("wolves"), make_template("bears")])
	var second_offers: Array = second_pool.get_available_quests()
	assert_offers_match(first_offers, second_offers)

	var unchanged_offer = first_offers[1]
	var previous_offer = first_offers[0]
	first_pool.replace_offer(previous_offer)
	var replaced_offers: Array = first_pool.get_available_quests()
	assert(replaced_offers[0] != previous_offer, "Only the completed or cancelled offer must be regenerated.")
	assert(replaced_offers[1] == unchanged_offer, "Unaccepted tavern offers must remain unchanged.")
	assert_offer_is_valid(replaced_offers[0])

	print("PASS: Seeded quest offers roll integer ranges and replace only the accepted quest.")
	quit()

func make_template(quest_id: String) -> Resource:
	var mob = MobDefinitionScript.new()
	mob.id = "mob_" + quest_id
	mob.display_name = mob.id
	mob.max_hp = 25.0
	mob.attack = 2.0
	mob.attack_speed = 1.0
	mob.crit_chance = 0.0
	mob.crit_damage = 1.5


	var template = QuestDefinitionScript.new()
	template.id = quest_id
	template.display_name = quest_id
	template.mob_definition = mob
	template.mob_count_min = 4
	template.mob_count_max = 6
	template.distance_km_min = 2
	template.distance_km_max = 4
	template.gold_per_mob_min = 10
	template.gold_per_mob_max = 12
	return template

func assert_offer_is_valid(offer) -> void:
	assert(offer.mob_count >= 4 and offer.mob_count <= 6, "Rolled mob count must stay inside its inclusive template range.")
	assert(offer.distance_km >= 2.0 and offer.distance_km <= 4.0, "Rolled distance must stay inside its inclusive template range.")
	assert(offer.gold_per_mob >= 10 and offer.gold_per_mob <= 12, "Rolled per-mob reward must stay inside its inclusive template range.")
	assert(offer.gold_reward == offer.mob_count * offer.gold_per_mob, "Offer reward must be calculated from its own count and per-mob reward.")

func assert_offers_match(left_offers: Array, right_offers: Array) -> void:
	assert(left_offers.size() == right_offers.size(), "The same seed must produce the same number of offers.")
	for index in left_offers.size():
		var left = left_offers[index]
		var right = right_offers[index]
		assert(left.id == right.id, "The same seed must keep offer order stable.")
		assert(left.mob_count == right.mob_count, "The same seed must reproduce mob counts.")
		assert(is_equal_approx(left.distance_km, right.distance_km), "The same seed must reproduce distances.")
		assert(left.gold_per_mob == right.gold_per_mob, "The same seed must reproduce per-mob rewards.")
		assert(left.gold_reward == right.gold_reward, "The same seed must reproduce total rewards.")
