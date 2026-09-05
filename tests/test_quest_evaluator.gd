extends SceneTree

const QuestEvaluatorScript = preload("res://scripts/quests/quest_evaluator.gd")
const MobDefinitionScript = preload("res://scripts/model/definitions/mob_definition.gd")
const QuestDefinitionScript = preload("res://scripts/model/definitions/quest_definition.gd")
const QuestOfferScript = preload("res://scripts/model/runtime/quest_offer.gd")

func _init() -> void:
	var evaluator = QuestEvaluatorScript.new()

	var quest_50 = make_quest("power_50", 50.0, 100, 2.0, 2)
	var quest_60 = make_quest("power_60", 60.0, 100, 2.0, 2)
	var quest_80 = make_quest("power_80", 80.0, 120, 2.0, 2)
	var quest_96 = make_quest("power_96", 96.0, 1000, 1.0, 1)

	var result: Dictionary = evaluator.select_quest(
		[quest_50, quest_60, quest_80, quest_96],
		100.0
	)

	assert(is_equal_approx(result["hard_filter_minimum"], 55.0), "Standard Hard Filter minimum must be 55% of HeroPower.")
	assert(is_equal_approx(result["hard_filter_limit"], 95.0), "Standard Hard Filter maximum must be 95% of HeroPower.")
	assert(result["eligible_count"] == 2, "Power 50 must be outgrown and Power 96 must be too dangerous when HeroPower is 100.")
	assert(is_equal_approx(result["weakest_allowed_mob_power"], 60.0), "Weakest allowed mob must define recovery factor 1.")

	var by_id := {}
	for evaluation in result["evaluations"]:
		by_id[evaluation["quest"].id] = evaluation

	assert(not by_id.has("power_50") and not by_id.has("power_96"), "Filtered quests must not participate in QuestScore.")
	assert(is_equal_approx(by_id["power_60"]["relative_recovery_cost"], 1.0), "Weakest allowed quest must have recovery factor 1.")
	assert(is_equal_approx(by_id["power_80"]["relative_recovery_cost"], 80.0 / 60.0), "Power 80 must normalize against the weakest allowed Power 60 mob.")
	assert(is_equal_approx(by_id["power_60"]["estimated_cost_per_mob"], 2.0), "Weakest mob must cost 1 fight tick + 1 recovery unit.")
	assert(is_equal_approx(by_id["power_80"]["estimated_cost_per_mob"], 1.0 + 80.0 / 60.0), "Stronger mob estimated cost must include normalized recovery.")
	assert(result["selected_quest"].id == "power_80", "Highest valid QuestScore must win while both lower- and upper-filtered quests stay excluded.")
	assert(result["ranked_evaluations"].size() == result["evaluations"].size(), "QuestEvaluator must expose the same eligible evaluations in ranked debug order.")
	assert(result["ranked_evaluations"][0]["quest"].id == result["selected_quest"].id, "Ranked evaluations must put the strict QuestScore winner first.")

	var map_backed_quest = make_quest("map_backed", 60.0, 100, 99.0, 2)
	map_backed_quest.assign_map_target(Vector2i(5, 5), "test_map_target", 3)
	var map_result: Dictionary = evaluator.select_quest([map_backed_quest], 100.0)
	var map_evaluation: Dictionary = map_result["evaluations"][0]
	assert(is_equal_approx(map_evaluation["one_way_travel_ticks"], 3.0), "Map-backed QuestScore must use real route steps instead of legacy abstract distance.")
	assert(is_equal_approx(map_evaluation["estimated_quest_ticks"], 11.0), "Map-backed quest estimate must count three real travel ticks each way.")

	print("PASS: QuestEvaluator applies the standard 55%-95% Hard Filter window and uses real route steps for map-backed quest travel cost.")
	quit()

func make_quest(quest_id: String, target_power: float, reward: int, distance: float, mob_count: int):
	var mob = MobDefinitionScript.new()
	mob.id = "mob_" + quest_id
	mob.display_name = mob.id
	# With Attack=1, AttackSpeed=2, CritChance=0:
	# DPS=1, so Power=sqrt(MaxHP). This gives exact target Power.
	mob.max_hp = target_power * target_power
	mob.attack = 1.0
	mob.attack_speed = 2.0
	mob.crit_chance = 0.0
	mob.crit_damage = 1.5


	var template = QuestDefinitionScript.new()
	template.id = quest_id
	template.display_name = quest_id
	template.mob_definition = mob
	return QuestOfferScript.new(template, mob_count, distance, int(reward / mob_count))
