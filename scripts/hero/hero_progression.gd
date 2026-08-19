class_name HeroProgression
extends RefCounted

const BASE_MAX_HP: float = 100.0
const BASE_ATTACK: float = 5.0
const BASE_ATTACK_SPEED: float = 1.10
const BASE_CRIT_CHANCE: float = 0.10
const BASE_CRIT_DAMAGE: float = 1.50

const DIRECT_MAX_HP_PER_LEVEL: float = 20.0
const STRENGTH_PER_LEVEL: int = 4
const AGILITY_PER_LEVEL: int = 1

func get_level_hp_bonus(level: int) -> float:
	return float(maxi(0, level - 1)) * DIRECT_MAX_HP_PER_LEVEL

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
	hero_state.strength += STRENGTH_PER_LEVEL
	hero_state.agility += AGILITY_PER_LEVEL
