class_name DamageResolver
extends RefCounted

const DAMAGE_TYPE_PHYSICAL := "physical"
const DAMAGE_TYPE_FIRE := "fire"
const DAMAGE_TYPE_COLD := "cold"
const DAMAGE_TYPE_LIGHTNING := "lightning"
const DODGE_CHANCE_CAP: float = 0.50
const ELEMENTAL_REDUCTION_CAP: float = 0.75
const BLOCK_CHANCE_CAP: float = 0.50
const BLOCK_RATING_CONSTANT: float = 200.0
const BLOCKED_DAMAGE_MULTIPLIER: float = 0.25

static func calculate_dodge_chance(accuracy: float, dodge: float) -> float:
	var safe_accuracy := maxf(0.0, accuracy)
	var safe_dodge := maxf(0.0, dodge)
	return minf(safe_dodge / (safe_dodge + safe_accuracy + 100.0), DODGE_CHANCE_CAP)

static func calculate_hit_chance(accuracy: float, dodge: float) -> float:
	return 1.0 - calculate_dodge_chance(accuracy, dodge)

static func calculate_physical_taken(armor: float) -> float:
	return 100.0 / (100.0 + maxf(0.0, armor))

static func calculate_elemental_taken(resistance: float) -> float:
	var uncapped_taken := 100.0 / (100.0 + maxf(0.0, resistance))
	return maxf(uncapped_taken, 1.0 - ELEMENTAL_REDUCTION_CAP)

static func calculate_block_chance(block: float) -> float:
	var safe_block := maxf(0.0, block)
	if safe_block <= 0.0:
		return 0.0
	return minf(safe_block / (safe_block + BLOCK_RATING_CONSTANT), BLOCK_CHANCE_CAP)

static func calculate_block_multiplier(block: float) -> float:
	return 1.0 - (1.0 - BLOCKED_DAMAGE_MULTIPLIER) * calculate_block_chance(block)

static func calculate_mitigated_damage(raw_damage: float, damage_type: String, armor: float, resistance: float, was_blocked: bool) -> float:
	var remaining_damage := maxf(0.0, raw_damage)
	if was_blocked:
		remaining_damage *= BLOCKED_DAMAGE_MULTIPLIER
	if damage_type == DAMAGE_TYPE_PHYSICAL:
		return remaining_damage * calculate_physical_taken(armor)
	assert(
		damage_type == DAMAGE_TYPE_FIRE or damage_type == DAMAGE_TYPE_COLD or damage_type == DAMAGE_TYPE_LIGHTNING,
		"Unsupported direct damage type: %s" % damage_type
	)
	return remaining_damage * calculate_elemental_taken(resistance)
