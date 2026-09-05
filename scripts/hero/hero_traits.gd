class_name HeroTraits
extends RefCounted

const CAUTIOUS := "cautious"
const BRAVE := "brave"
const DEVIOUS := "devious"
const NOBLE := "noble"
const GREEDY := "greedy"
const GENEROUS := "generous"
const CURIOUS := "curious"
const CONSERVATIVE := "conservative"

const ALL: Array[String] = [CAUTIOUS, BRAVE, DEVIOUS, NOBLE, GREEDY, GENEROUS, CURIOUS, CONSERVATIVE]
const STARTING_ROLLABLE: Array[String] = [CAUTIOUS, BRAVE, DEVIOUS, NOBLE, GREEDY]
const STARTING_TRAIT_MIN: int = 1
const STARTING_TRAIT_MAX: int = 2
const COURAGE_EXTREME_MODIFIER: float = 0.30
const MORALITY_QUEST_MODIFIER: float = 0.20
const GREED_MAX_MODIFIER: float = 0.30
const CATEGORY_DAMAGE_MULTIPLIER: float = 1.10

static func roll_starting_traits(random_number_generator: RandomNumberGenerator) -> Array[String]:
	var target_count := random_number_generator.randi_range(STARTING_TRAIT_MIN, STARTING_TRAIT_MAX)
	var candidates: Array[String] = STARTING_ROLLABLE.duplicate()
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
		(candidate == CAUTIOUS and selected_traits.has(BRAVE))
		or (candidate == BRAVE and selected_traits.has(CAUTIOUS))
		or (candidate == DEVIOUS and selected_traits.has(NOBLE))
		or (candidate == NOBLE and selected_traits.has(DEVIOUS))
		or (candidate == GREEDY and selected_traits.has(GENEROUS))
		or (candidate == GENEROUS and selected_traits.has(GREEDY))
		or (candidate == CURIOUS and selected_traits.has(CONSERVATIVE))
		or (candidate == CONSERVATIVE and selected_traits.has(CURIOUS))
	)

static func get_damage_multiplier(traits: Array[String], mob_category: int) -> float:
	if traits.has(NOBLE) and mob_category == MobDefinition.Category.MONSTER:
		return CATEGORY_DAMAGE_MULTIPLIER
	if traits.has(DEVIOUS) and mob_category == MobDefinition.Category.HUMANOID:
		return CATEGORY_DAMAGE_MULTIPLIER
	return 1.0

static func get_display_name(trait_id: String) -> String:
	match trait_id:
		CAUTIOUS: return "Осторожный"
		BRAVE: return "Смелый"
		DEVIOUS: return "Хитрый"
		NOBLE: return "Благородный"
		GREEDY: return "Жадный"
		GENEROUS: return "Щедрый"
		CURIOUS: return "Любопытный"
		CONSERVATIVE: return "Консервативный"
	return trait_id

static func get_display_names(traits: Array[String]) -> String:
	var names: PackedStringArray = []
	for trait_id in traits:
		names.append(get_display_name(trait_id))
	return ", ".join(names)

static func get_conditional_damage_bonus_text(traits: Array[String]) -> String:
	if traits.has(NOBLE):
		return "+10% урона монстрам"
	if traits.has(DEVIOUS):
		return "+10% урона гуманоидам"
	return ""
