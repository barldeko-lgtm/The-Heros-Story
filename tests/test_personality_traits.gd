extends SceneTree

const HeroTraitsScript = preload("res://scripts/hero/hero_traits.gd")
const SimulationScript = preload("res://scripts/core/simulation.gd")
const QuestEvaluatorScript = preload("res://scripts/quests/quest_evaluator.gd")
const MobDefinitionScript = preload("res://scripts/model/definitions/mob_definition.gd")
const QuestDefinitionScript = preload("res://scripts/model/definitions/quest_definition.gd")
const QuestOfferScript = preload("res://scripts/model/runtime/quest_offer.gd")

func _init() -> void:
	var first_rng := RandomNumberGenerator.new()
	first_rng.seed = 12345
	var second_rng := RandomNumberGenerator.new()
	second_rng.seed = 12345
	var first_traits: Array[String] = HeroTraitsScript.roll_starting_traits(first_rng)
	var second_traits: Array[String] = HeroTraitsScript.roll_starting_traits(second_rng)
	assert(first_traits == second_traits, "The same seed must reproduce starting traits.")
	assert(first_traits.size() >= 1 and first_traits.size() <= 2, "A starting hero must receive one or two traits.")
	assert(not (first_traits.has(HeroTraitsScript.COWARD) and first_traits.has(HeroTraitsScript.BRAVE)), "Coward and Brave must be mutually exclusive.")
	assert(not (first_traits.has(HeroTraitsScript.DISHONORABLE) and first_traits.has(HeroTraitsScript.NOBLE)), "Dishonorable and Noble must be mutually exclusive.")
	var first_simulation = SimulationScript.new(777, null)
	var second_simulation = SimulationScript.new(777, null)
	assert(first_simulation.hero_state.traits == second_simulation.hero_state.traits, "Simulation must assign reproducible starting traits from its shared seed.")
	assert(first_simulation.hero_state.traits.size() >= 1 and first_simulation.hero_state.traits.size() <= 2, "Simulation must expose one or two starting traits on HeroState.")

	var evaluator = QuestEvaluatorScript.new()
	var quests := [
		make_quest("weak", 60.0, 10, MobDefinitionScript.Category.HUMANOID),
		make_quest("middle", 75.0, 20, MobDefinitionScript.Category.MONSTER),
		make_quest("strong", 90.0, 30, MobDefinitionScript.Category.MONSTER),
	]
	var result: Dictionary = evaluator.select_quest(quests, 100.0, [HeroTraitsScript.BRAVE, HeroTraitsScript.NOBLE, HeroTraitsScript.GREEDY])
	var by_id := {}
	for evaluation in result["evaluations"]:
		by_id[evaluation["quest"].id] = evaluation

	assert(is_equal_approx(by_id["weak"]["courage_modifier"], -0.30), "Brave must dislike the weakest eligible enemy by 0.30.")
	assert(is_equal_approx(by_id["strong"]["courage_modifier"], 0.30), "Brave must prefer the strongest eligible enemy by 0.30.")
	assert(is_equal_approx(by_id["weak"]["morality_modifier"], 0.0), "Noble must not gain QuestScore against Humanoids.")
	assert(is_equal_approx(by_id["strong"]["morality_modifier"], 0.20), "Noble must gain 0.20 QuestScore against Monsters.")
	assert(is_equal_approx(by_id["weak"]["greed_modifier"], 0.0), "Greedy must not gain a modifier for the lowest reward.")
	assert(is_equal_approx(by_id["strong"]["greed_modifier"], 0.30), "Greedy must gain 0.30 for the highest reward.")

	var coward_result: Dictionary = evaluator.select_quest(quests, 100.0, [HeroTraitsScript.COWARD])
	var coward_by_id := {}
	for evaluation in coward_result["evaluations"]:
		coward_by_id[evaluation["quest"].id] = evaluation
	assert(is_equal_approx(coward_by_id["weak"]["courage_modifier"], 0.30), "Coward must prefer the weakest eligible enemy by 0.30.")
	assert(is_equal_approx(coward_by_id["strong"]["courage_modifier"], -0.30), "Coward must dislike the strongest eligible enemy by 0.30.")

	var too_weak_for_brave = make_quest("too_weak_for_brave", 55.0, 10, MobDefinitionScript.Category.MONSTER)
	var brave_edge = make_quest("brave_edge", 98.0, 10, MobDefinitionScript.Category.MONSTER)
	var brave_filter: Dictionary = evaluator.select_quest([too_weak_for_brave, brave_edge], 100.0, [HeroTraitsScript.BRAVE])
	assert(is_equal_approx(brave_filter["hard_filter_minimum"], 60.0) and is_equal_approx(brave_filter["hard_filter_limit"], 100.0), "Brave must use the 60%-100% Power window.")
	assert(brave_filter["eligible_count"] == 1 and brave_filter["selected_quest"].id == "brave_edge", "Brave must outgrow Power 55 while still accepting Power 98 at HeroPower 100.")

	var cautious_edge = make_quest("cautious_edge", 52.0, 10, MobDefinitionScript.Category.MONSTER)
	var too_strong_for_cautious = make_quest("too_strong_for_cautious", 92.0, 10, MobDefinitionScript.Category.MONSTER)
	var cautious_filter: Dictionary = evaluator.select_quest([cautious_edge, too_strong_for_cautious], 100.0, [HeroTraitsScript.COWARD])
	assert(is_equal_approx(cautious_filter["hard_filter_minimum"], 50.0) and is_equal_approx(cautious_filter["hard_filter_limit"], 90.0), "Current Coward trait must use the Scope's Cautious 50%-90% Power window.")
	assert(cautious_filter["eligible_count"] == 1 and cautious_filter["selected_quest"].id == "cautious_edge", "Cautious/Coward must retain weaker work longer and reject Power 92 at HeroPower 100.")

	print("PASS: Starting traits, QuestScore personality modifiers, and Brave/Cautious Hard Filter windows follow the approved formulas.")
	quit()

func make_quest(quest_id: String, target_power: float, reward: int, category: int):
	var mob = MobDefinitionScript.new()
	mob.id = "mob_" + quest_id
	mob.display_name = mob.id
	mob.category = category
	mob.max_hp = target_power * target_power
	mob.attack = 1.0
	mob.attack_speed = 2.0
	mob.crit_chance = 0.0
	mob.crit_damage = 1.5


	var template = QuestDefinitionScript.new()
	template.id = quest_id
	template.display_name = quest_id
	template.mob_definition = mob
	return QuestOfferScript.new(template, 1, 1.0, reward)
