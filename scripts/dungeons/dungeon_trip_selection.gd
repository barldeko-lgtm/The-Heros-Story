extends RefCounted

# One synchronous selection pass, never persisted or given Simulation.
# Lazy evaluation preserves candidate order and retries after a failed trip start.
var candidates: Array
var hero_state
var hero_power: float
var evaluator
var potion_preparation
var potion_definitions: Array
var next_index: int = 0
var power_block: Dictionary = {}
var potion_block: Dictionary = {}

func _init(known_candidates: Array, hero, power: float, readiness_evaluator, preparation_system, definitions: Array) -> void:
	candidates = known_candidates
	hero_state = hero
	hero_power = power
	evaluator = readiness_evaluator
	potion_preparation = preparation_system
	potion_definitions = definitions

static func find_power_ready(known_candidates: Array, power: float, readiness_evaluator):
	for candidate in known_candidates:
		if bool(readiness_evaluator.evaluate_retry_readiness(candidate, power).get("ready", false)):
			return candidate
	return null

func select_next() -> Dictionary:
	while next_index < candidates.size():
		var candidate = candidates[next_index]
		next_index += 1
		var readiness: Dictionary = evaluator.evaluate_retry_readiness(candidate, hero_power)
		if not bool(readiness.get("ready", false)):
			if power_block.is_empty() and str(readiness.get("reason", "")) == "retry_power_too_low":
				power_block = {"dungeon": candidate, "readiness": readiness, "kind": "power"}
			continue
		var plan: Dictionary = potion_preparation.get_full_loadout_plan(hero_state, potion_definitions)
		if not bool(plan.get("can_prepare", false)):
			if potion_block.is_empty():
				potion_block = {"dungeon": candidate, "plan": plan, "kind": "potions"}
			continue
		return {"dungeon": candidate, "plan": plan}
	return {}

func get_blocked_reason() -> Dictionary:
	# Historical explanation priority, not a preference over a ready candidate.
	return power_block if not power_block.is_empty() else potion_block
