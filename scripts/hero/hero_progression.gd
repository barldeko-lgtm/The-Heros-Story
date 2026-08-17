class_name HeroProgression
extends RefCounted

const BASE_MAX_HP: float = 100.0
const BASE_ATTACK: float = 5.0
const BASE_ATTACK_SPEED: float = 1.10
const BASE_CRIT_CHANCE: float = 0.10
const BASE_CRIT_DAMAGE: float = 1.50

func get_level_hp_bonus(level: int) -> float:
	return float(maxi(0, level - 1) * 20)
