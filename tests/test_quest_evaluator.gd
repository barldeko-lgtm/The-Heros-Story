extends SceneTree

const QuestEvaluatorScript = preload("res://scripts/quests/quest_evaluator.gd")
const MobDefinitionScript = preload("res://scripts/model/definitions/mob_definition.gd")
const QuestDefinitionScript = preload("res://scripts/model/definitions/quest_definition.gd")
const QuestOfferScript = preload("res://scripts/model/runtime/quest_offer.gd")

func _init() -> void:
	var evaluator = QuestEvaluatorScript.new()

	var quest_20 = make_quest("power_20", 20.0, 100, 2.0, 2)
	var quest_30 = make_quest("power_30", 30.0, 120, 2.0, 2)
	var quest_45 = make_quest("power_45", 45.0, 100, 2.0, 2)
	var quest_48 = make_quest("power_48", 48.0, 1000, 1.0, 1)

	var result: Dictionary = evaluator.select_quest(
		[quest_20, quest_30, quest_45, quest_48],
		50.0
	)

	assert(is_equal_approx(result["hard_filter_limit"], 47.5), "Hard Filter must be 95% of HeroPower.")
	assert(result["eligible_count"] == 3, "Power 48 must be rejected when HeroPower is 50.")
	assert(is_equal_approx(result["weakest_allowed_mob_power"], 20.0), "Weakest allowed mob must define recovery factor 1.")

	var by_id := {}
	for evaluation in result["evaluations"]:
		by_id[evaluation["quest"].id] = evaluation

	assert(is_equal_approx(by_id["power_20"]["relative_recovery_cost"], 1.0), "Weakest allowed quest must have recovery factor 1.")
	assert(is_equal_approx(by_id["power_30"]["relative_recovery_cost"], 1.5), "Power 30 / Power 20 must produce recovery factor 1.5.")
	assert(is_equal_approx(by_id["power_45"]["relative_recovery_cost"], 2.25), "Power 45 / Power 20 must produce recovery factor 2.25.")

	assert(is_equal_approx(by_id["power_20"]["estimated_cost_per_mob"], 2.0), "Weakest mob must cost 1 fight tick + 1 recovery unit.")
	assert(is_equal_approx(by_id["power_30"]["estimated_cost_per_mob"], 2.5), "Power 30 mob cost must be 2.5 estimated ticks.")
	assert(is_equal_approx(by_id["power_45"]["estimated_cost_per_mob"], 3.25), "Power 45 mob cost must be 3.25 estimated ticks.")

	assert(is_equal_approx(by_id["power_20"]["estimated_quest_ticks"], 9.0), "Power 20 quest estimate must include travel, mobs, and turn-in.")
	assert(is_equal_approx(by_id["power_30"]["estimated_quest_ticks"], 10.0), "Power 30 quest estimate must include relative recovery cost.")
	assert(is_equal_approx(by_id["power_45"]["estimated_quest_ticks"], 11.5), "Power 45 quest estimate must include relative recovery cost.")

	assert(result["selected_quest"].id == "power_30", "Highest QuestScore must win; filtered huge reward must not participate.")

	print("PASS: QuestEvaluator applies 95% Hard Filter and relative-cost QuestScore.")
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
