class_name QuestEvaluator
extends RefCounted

const HeroTraitsScript = preload("res://scripts/hero/hero_traits.gd")

const STANDARD_MIN_POWER_RATIO: float = 0.55
const STANDARD_MAX_POWER_RATIO: float = 0.95
const BRAVE_MIN_POWER_RATIO: float = 0.60
const BRAVE_MAX_POWER_RATIO: float = 1.00
const CAUTIOUS_MIN_POWER_RATIO: float = 0.50
const CAUTIOUS_MAX_POWER_RATIO: float = 0.90
const FIGHT_TICKS_PER_MOB: float = 1.0
const TURN_IN_TICKS: float = 1.0
const SCORE_EPSILON: float = 0.000001

func select_quest(available_quests: Array, hero_power: float, hero_traits: Array[String] = [], guided_quest_id: String = "", divine_guidance_modifier: float = 0.0) -> Dictionary:
	var power_window: Dictionary = get_hard_filter_power_window(hero_power, hero_traits)
	var hard_filter_minimum: float = float(power_window["minimum"])
	var hard_filter_limit: float = float(power_window["maximum"])
	var eligible_quests: Array[Dictionary] = []

	for quest_definition in available_quests:
		if quest_definition == null or quest_definition.mob_definition == null:
			continue

		var mob_power: float = quest_definition.mob_definition.get_power()
		if mob_power + SCORE_EPSILON >= hard_filter_minimum and mob_power <= hard_filter_limit + SCORE_EPSILON:
			eligible_quests.append({
				"quest": quest_definition,
				"mob_power": mob_power,
			})

	if eligible_quests.is_empty():
		return {
			"selected_quest": null,
			"total_count": available_quests.size(),
			"eligible_count": 0,
			"hard_filter_minimum": hard_filter_minimum,
			"hard_filter_limit": hard_filter_limit,
			"weakest_allowed_mob_power": 0.0,
			"evaluations": [],
			"ranked_evaluations": [],
		}

	var weakest_allowed_mob_power: float = eligible_quests[0]["mob_power"]
	var strongest_allowed_mob_power: float = eligible_quests[0]["mob_power"]
	var minimum_reward: int = eligible_quests[0]["quest"].gold_reward
	var maximum_reward: int = eligible_quests[0]["quest"].gold_reward
	for eligible in eligible_quests:
		weakest_allowed_mob_power = minf(weakest_allowed_mob_power, eligible["mob_power"])
		strongest_allowed_mob_power = maxf(strongest_allowed_mob_power, eligible["mob_power"])
		minimum_reward = mini(minimum_reward, eligible["quest"].gold_reward)
		maximum_reward = maxi(maximum_reward, eligible["quest"].gold_reward)

	var evaluations: Array[Dictionary] = []
	var selected_quest = null
	var selected_score: float = -INF

	for eligible in eligible_quests:
		var quest_definition = eligible["quest"]
		var mob_power: float = eligible["mob_power"]

		var relative_recovery_cost: float = 1.0
		if weakest_allowed_mob_power > SCORE_EPSILON:
			relative_recovery_cost = mob_power / weakest_allowed_mob_power

		var estimated_cost_per_mob: float = FIGHT_TICKS_PER_MOB + relative_recovery_cost
		var one_way_travel_ticks: float = get_one_way_travel_ticks(quest_definition)
		var estimated_quest_ticks: float = (
			one_way_travel_ticks
			+ float(quest_definition.mob_count) * estimated_cost_per_mob
			+ one_way_travel_ticks
			+ TURN_IN_TICKS
		)

		var base_attractiveness: float = 0.0
		if estimated_quest_ticks > SCORE_EPSILON:
			base_attractiveness = float(quest_definition.gold_reward) / estimated_quest_ticks

		var courage_modifier: float = 0.0
		if strongest_allowed_mob_power - weakest_allowed_mob_power > SCORE_EPSILON:
			var power_normalized: float = (mob_power - weakest_allowed_mob_power) / (strongest_allowed_mob_power - weakest_allowed_mob_power)
			if hero_traits.has(HeroTraitsScript.BRAVE):
				courage_modifier = -HeroTraitsScript.COURAGE_EXTREME_MODIFIER + 2.0 * HeroTraitsScript.COURAGE_EXTREME_MODIFIER * power_normalized
			elif hero_traits.has(HeroTraitsScript.CAUTIOUS):
				courage_modifier = HeroTraitsScript.COURAGE_EXTREME_MODIFIER - 2.0 * HeroTraitsScript.COURAGE_EXTREME_MODIFIER * power_normalized

		var morality_modifier: float = 0.0
		if hero_traits.has(HeroTraitsScript.DEVIOUS) and quest_definition.mob_definition.category == MobDefinition.Category.HUMANOID:
			morality_modifier = HeroTraitsScript.MORALITY_QUEST_MODIFIER
		elif hero_traits.has(HeroTraitsScript.NOBLE) and quest_definition.mob_definition.category == MobDefinition.Category.MONSTER:
			morality_modifier = HeroTraitsScript.MORALITY_QUEST_MODIFIER

		var greed_modifier: float = 0.0
		if hero_traits.has(HeroTraitsScript.GREEDY) and maximum_reward != minimum_reward:
			greed_modifier = HeroTraitsScript.GREED_MAX_MODIFIER * float(quest_definition.gold_reward - minimum_reward) / float(maximum_reward - minimum_reward)

		var divine_modifier: float = 0.0
		if not guided_quest_id.is_empty() and quest_definition.id == guided_quest_id:
			divine_modifier = divine_guidance_modifier

		var quest_score: float = (
			base_attractiveness
			+ courage_modifier
			+ morality_modifier
			+ greed_modifier
			+ divine_modifier
		)

		var evaluation := {
			"quest": quest_definition,
			"evaluation_order": evaluations.size(),
			"mob_power": mob_power,
			"relative_recovery_cost": relative_recovery_cost,
			"estimated_cost_per_mob": estimated_cost_per_mob,
			"one_way_travel_ticks": one_way_travel_ticks,
			"estimated_quest_ticks": estimated_quest_ticks,
			"base_attractiveness": base_attractiveness,
			"courage_modifier": courage_modifier,
			"morality_modifier": morality_modifier,
			"greed_modifier": greed_modifier,
			"divine_modifier": divine_modifier,
			"quest_score": quest_score,
		}
		evaluations.append(evaluation)

		# Strict highest-QuestScore selection. Equal scores keep the first
		# quest from the stable QuestPool order; there is no roulette.
		if selected_quest == null or quest_score > selected_score + SCORE_EPSILON:
			selected_quest = quest_definition
			selected_score = quest_score

	var ranked_evaluations: Array[Dictionary] = []
	for evaluation in evaluations:
		ranked_evaluations.append(evaluation)
	ranked_evaluations.sort_custom(_evaluation_ranks_before)

	return {
		"selected_quest": selected_quest,
		"total_count": available_quests.size(),
		"eligible_count": eligible_quests.size(),
		"hard_filter_minimum": hard_filter_minimum,
		"hard_filter_limit": hard_filter_limit,
		"weakest_allowed_mob_power": weakest_allowed_mob_power,
		"evaluations": evaluations,
		"ranked_evaluations": ranked_evaluations,
	}

func _evaluation_ranks_before(left: Dictionary, right: Dictionary) -> bool:
	var left_score: float = float(left.get("quest_score", -INF))
	var right_score: float = float(right.get("quest_score", -INF))
	if absf(left_score - right_score) <= SCORE_EPSILON:
		return int(left.get("evaluation_order", 0)) < int(right.get("evaluation_order", 0))
	return left_score > right_score

func get_hard_filter_power_window(hero_power: float, hero_traits: Array[String]) -> Dictionary:
	var minimum_ratio: float = STANDARD_MIN_POWER_RATIO
	var maximum_ratio: float = STANDARD_MAX_POWER_RATIO
	if hero_traits.has(HeroTraitsScript.BRAVE):
		minimum_ratio = BRAVE_MIN_POWER_RATIO
		maximum_ratio = BRAVE_MAX_POWER_RATIO
	elif hero_traits.has(HeroTraitsScript.CAUTIOUS):
		minimum_ratio = CAUTIOUS_MIN_POWER_RATIO
		maximum_ratio = CAUTIOUS_MAX_POWER_RATIO
	var safe_hero_power: float = maxf(0.0, hero_power)
	return {
		"minimum": safe_hero_power * minimum_ratio,
		"maximum": safe_hero_power * maximum_ratio,
		"minimum_ratio": minimum_ratio,
		"maximum_ratio": maximum_ratio,
	}

func get_one_way_travel_ticks(quest_offer) -> float:
	if quest_offer != null and quest_offer.has_method("has_map_target") and quest_offer.has_map_target() and quest_offer.map_distance_steps >= 0:
		return float(quest_offer.map_distance_steps)
	return maxf(0.0, quest_offer.distance_km)
