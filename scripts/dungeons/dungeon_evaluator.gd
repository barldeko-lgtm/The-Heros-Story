class_name DungeonEvaluator
extends RefCounted

const NO_KILLS_RETRY_GROWTH: float = 0.25
const ORDINARY_PROGRESS_RETRY_GROWTH: float = 0.15
const BOSS_REACHED_RETRY_GROWTH: float = 0.10
const POWER_EPSILON: float = 0.0001

func get_retry_growth(ordinary_encounters_completed: int, reached_boss: bool) -> float:
	if reached_boss:
		return BOSS_REACHED_RETRY_GROWTH
	if ordinary_encounters_completed <= 0:
		return NO_KILLS_RETRY_GROWTH
	return ORDINARY_PROGRESS_RETRY_GROWTH

func get_required_retry_power(attempt_start_power: float, ordinary_encounters_completed: int, reached_boss: bool) -> float:
	var retry_growth: float = get_retry_growth(ordinary_encounters_completed, reached_boss)
	return maxf(0.0, attempt_start_power) * (1.0 + retry_growth)

func evaluate_retry_readiness(dungeon_instance, current_hero_power: float) -> Dictionary:
	if dungeon_instance == null or dungeon_instance.completed:
		return {
			"ready": false,
			"reason": "invalid_or_completed",
			"required_power": 0.0,
			"current_power": current_hero_power,
			"retry_growth": 0.0,
		}
	if not dungeon_instance.has_failed_attempt():
		return {
			"ready": true,
			"reason": "first_attempt",
			"required_power": 0.0,
			"current_power": current_hero_power,
			"retry_growth": 0.0,
		}
	var retry_growth: float = get_retry_growth(dungeon_instance.last_failure_ordinary_encounters_completed, dungeon_instance.last_failure_reached_boss)
	var required_power: float = get_required_retry_power(
		dungeon_instance.last_failed_attempt_start_power,
		dungeon_instance.last_failure_ordinary_encounters_completed,
		dungeon_instance.last_failure_reached_boss
	)
	return {
		"ready": current_hero_power + POWER_EPSILON >= required_power,
		"reason": "retry_power_ready" if current_hero_power + POWER_EPSILON >= required_power else "retry_power_too_low",
		"required_power": required_power,
		"current_power": current_hero_power,
		"retry_growth": retry_growth,
	}
