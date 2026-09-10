class_name HeroProgression
extends RefCounted

const BASE_MAX_HP: float = 100.0
const BASE_ATTACK: float = 5.0
const BASE_ATTACK_SPEED: float = 1.10
const BASE_CRIT_CHANCE: float = 0.10
const BASE_CRIT_DAMAGE: float = 1.50
const BASE_FIRE_RESISTANCE: float = 10.0
const BASE_COLD_RESISTANCE: float = 10.0
const BASE_LIGHTNING_RESISTANCE: float = 10.0

const FIXED_WARRIOR_STRENGTH_PER_LEVEL: int = 1
const PLAYER_PRIMARY_ATTRIBUTE_POINTS_PER_LEVEL: int = 4
const BASE_EXPERIENCE_TO_NEXT_LEVEL: int = 500
const LEVEL_2_EXPERIENCE_TO_NEXT_LEVEL: int = 1000
const LEVEL_3_EXPERIENCE_TO_NEXT_LEVEL: int = 1600
const LEVEL_4_EXPERIENCE_TO_NEXT_LEVEL: int = 2300
const EXPERIENCE_INCREASE_THROUGH_LEVEL_13: int = 800
const EXPERIENCE_INCREASE_AFTER_LEVEL_13: int = 1000
const LATE_EXPERIENCE_START_LEVEL: int = 13
const POWER_STRIKE_UNLOCK_LEVEL: int = 5
const BATTLE_GUARD_UNLOCK_LEVEL: int = 10
const MAX_SKILL_LEVEL: int = 10
const SKILL_LEVEL_INTERVAL: int = 5
const POWER_STRIKE_SKILL_ID := "power_strike"
const BATTLE_GUARD_SKILL_ID := "battle_guard"
const PRIMARY_ATTRIBUTE_IDS := ["strength", "dexterity", "intelligence", "constitution", "wisdom"]

func get_experience_required_for_next_level(current_level: int) -> int:
	if current_level <= 1:
		return BASE_EXPERIENCE_TO_NEXT_LEVEL
	if current_level == 2:
		return LEVEL_2_EXPERIENCE_TO_NEXT_LEVEL
	if current_level == 3:
		return LEVEL_3_EXPERIENCE_TO_NEXT_LEVEL
	if current_level == 4:
		return LEVEL_4_EXPERIENCE_TO_NEXT_LEVEL
	if current_level <= LATE_EXPERIENCE_START_LEVEL:
		return LEVEL_4_EXPERIENCE_TO_NEXT_LEVEL + (current_level - 4) * EXPERIENCE_INCREASE_THROUGH_LEVEL_13
	var level_13_requirement: int = LEVEL_4_EXPERIENCE_TO_NEXT_LEVEL + (LATE_EXPERIENCE_START_LEVEL - 4) * EXPERIENCE_INCREASE_THROUGH_LEVEL_13
	return level_13_requirement + (current_level - LATE_EXPERIENCE_START_LEVEL) * EXPERIENCE_INCREASE_AFTER_LEVEL_13

func add_experience(hero_state, experience_amount: int) -> int:
	assert(experience_amount >= 0, "Experience reward must not be negative.")
	assert(hero_state.experience_to_next_level > 0, "Experience required for the next level must be positive.")

	hero_state.experience += experience_amount
	var levels_gained := 0
	while hero_state.experience >= hero_state.experience_to_next_level:
		hero_state.experience -= hero_state.experience_to_next_level
		apply_level_up(hero_state)
		levels_gained += 1
	return levels_gained

func apply_level_up(hero_state) -> void:
	hero_state.level += 1
	hero_state.experience_to_next_level = get_experience_required_for_next_level(hero_state.level)
	hero_state.strength += FIXED_WARRIOR_STRENGTH_PER_LEVEL
	hero_state.pending_primary_attribute_points += PLAYER_PRIMARY_ATTRIBUTE_POINTS_PER_LEVEL
	if hero_state.level >= POWER_STRIKE_UNLOCK_LEVEL and hero_state.power_strike_skill_level == 0:
		hero_state.power_strike_skill_level = 1
	if hero_state.level >= BATTLE_GUARD_UNLOCK_LEVEL and hero_state.battle_guard_skill_level == 0:
		hero_state.battle_guard_skill_level = 1

func get_max_unlocked_skill_level(skill_id: String, hero_level: int) -> int:
	var unlock_level: int = get_skill_unlock_level(skill_id)
	if unlock_level <= 0 or hero_level < unlock_level:
		return 0
	var additional_ranks: int = floori(float(hero_level - unlock_level) / float(SKILL_LEVEL_INTERVAL))
	return mini(MAX_SKILL_LEVEL, 1 + additional_ranks)

func get_skill_unlock_level(skill_id: String) -> int:
	match skill_id:
		POWER_STRIKE_SKILL_ID: return POWER_STRIKE_UNLOCK_LEVEL
		BATTLE_GUARD_SKILL_ID: return BATTLE_GUARD_UNLOCK_LEVEL
	return -1

func allocate_primary_attribute(hero_state, attribute_id: String) -> bool:
	if hero_state.pending_primary_attribute_points <= 0:
		return false
	if not PRIMARY_ATTRIBUTE_IDS.has(attribute_id):
		return false

	match attribute_id:
		"strength": hero_state.strength += 1
		"dexterity": hero_state.dexterity += 1
		"intelligence": hero_state.intelligence += 1
		"constitution": hero_state.constitution += 1
		"wisdom": hero_state.wisdom += 1

	hero_state.pending_primary_attribute_points -= 1
	return true
