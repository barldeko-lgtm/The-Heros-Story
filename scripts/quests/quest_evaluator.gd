class_name QuestEvaluator
extends RefCounted

const HARD_FILTER_RATIO: float = 0.95
const FIGHT_TICKS_PER_MOB: float = 1.0
const TURN_IN_TICKS: float = 1.0
const SCORE_EPSILON: float = 0.000001

func select_quest(available_quests: Array, hero_power: float) -> Dictionary:
	var hard_filter_limit: float = maxf(0.0, hero_power) * HARD_FILTER_RATIO
	var eligible_quests: Array[Dictionary] = []

	for quest_definition in available_quests:
		if quest_definition == null or quest_definition.mob_definition == null:
			continue

		var mob_power: float = quest_definition.mob_definition.get_power()
		if mob_power <= hard_filter_limit + SCORE_EPSILON:
			eligible_quests.append({
				"quest": quest_definition,
				"mob_power": mob_power,
			})

	if eligible_quests.is_empty():
		return {
			"selected_quest": null,
			"total_count": available_quests.size(),
			"eligible_count": 0,
			"hard_filter_limit": hard_filter_limit,
			"weakest_allowed_mob_power": 0.0,
			"evaluations": [],
		}

	var weakest_allowed_mob_power: float = eligible_quests[0]["mob_power"]
	for eligible in eligible_quests:
		weakest_allowed_mob_power = minf(weakest_allowed_mob_power, eligible["mob_power"])

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
		var estimated_quest_ticks: float = (
			quest_definition.distance_km
			+ float(quest_definition.mob_count) * estimated_cost_per_mob
			+ quest_definition.distance_km
			+ TURN_IN_TICKS
		)

		var base_attractiveness: float = 0.0
		if estimated_quest_ticks > SCORE_EPSILON:
			base_attractiveness = float(quest_definition.gold_reward) / estimated_quest_ticks

		# Personality and divine modifiers are intentionally zero until
		# their own Prototype 0 slices are implemented.
		var courage_modifier: float = 0.0
		var morality_modifier: float = 0.0
		var greed_modifier: float = 0.0
		var divine_modifier: float = 0.0

		var quest_score: float = (
			base_attractiveness
			+ courage_modifier
			+ morality_modifier
			+ greed_modifier
			+ divine_modifier
		)

		var evaluation := {
			"quest": quest_definition,
			"mob_power": mob_power,
			"relative_recovery_cost": relative_recovery_cost,
			"estimated_cost_per_mob": estimated_cost_per_mob,
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

	return {
		"selected_quest": selected_quest,
		"total_count": available_quests.size(),
		"eligible_count": eligible_quests.size(),
		"hard_filter_limit": hard_filter_limit,
		"weakest_allowed_mob_power": weakest_allowed_mob_power,
		"evaluations": evaluations,
	}
