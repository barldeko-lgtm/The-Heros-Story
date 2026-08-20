class_name HeroTraits
extends RefCounted

const COWARD := "coward"
const BRAVE := "brave"
const DISHONORABLE := "dishonorable"
const NOBLE := "noble"
const GREEDY := "greedy"

const ALL: Array[String] = [COWARD, BRAVE, DISHONORABLE, NOBLE, GREEDY]
const STARTING_TRAIT_MIN: int = 1
const STARTING_TRAIT_MAX: int = 2
const COURAGE_EXTREME_MODIFIER: float = 0.30
const MORALITY_QUEST_MODIFIER: float = 0.20
const GREED_MAX_MODIFIER: float = 0.30
const CATEGORY_DAMAGE_MULTIPLIER: float = 1.10

static func roll_starting_traits(random_number_generator: RandomNumberGenerator) -> Array[String]:
	var target_count := random_number_generator.randi_range(STARTING_TRAIT_MIN, STARTING_TRAIT_MAX)
	var candidates: Array[String] = ALL.duplicate()
	var result: Array[String] = []

	while result.size() < target_count and not candidates.is_empty():
		var candidate_index := random_number_generator.randi_range(0, candidates.size() - 1)
		var candidate: String = candidates[candidate_index]
		candidates.remove_at(candidate_index)
		if conflicts_with_any(candidate, result):
			continue
		result.append(candidate)
	return result

static func conflicts_with_any(candidate: String, selected_traits: Array[String]) -> bool:
	return (
		(candidate == COWARD and selected_traits.has(BRAVE))
		or (candidate == BRAVE and selected_traits.has(COWARD))
		or (candidate == DISHONORABLE and selected_traits.has(NOBLE))
		or (candidate == NOBLE and selected_traits.has(DISHONORABLE))
	)

static func get_damage_multiplier(traits: Array[String], mob_category: int) -> float:
	if traits.has(NOBLE) and mob_category == MobDefinition.Category.MONSTER:
		return CATEGORY_DAMAGE_MULTIPLIER
	if traits.has(DISHONORABLE) and mob_category == MobDefinition.Category.HUMANOID:
		return CATEGORY_DAMAGE_MULTIPLIER
	return 1.0

static func get_display_name(trait_id: String) -> String:
	match trait_id:
		COWARD: return "Трусливый"
		BRAVE: return "Храбрый"
		DISHONORABLE: return "Бесчестный"
		NOBLE: return "Благородный"
		GREEDY: return "Жадный"
	return trait_id

static func get_display_names(traits: Array[String]) -> String:
	var names: PackedStringArray = []
	for trait_id in traits:
		names.append(get_display_name(trait_id))
	return ", ".join(names)

static func get_conditional_damage_bonus_text(traits: Array[String]) -> String:
	if traits.has(NOBLE):
		return "+10% урона монстрам"
	if traits.has(DISHONORABLE):
		return "+10% урона гуманоидам"
	return ""
