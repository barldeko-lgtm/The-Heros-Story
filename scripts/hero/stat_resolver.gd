class_name StatResolver
extends RefCounted

const CombatStatsScript = preload("res://scripts/model/runtime/combat_stats.gd")
const HeroProgressionScript = preload("res://scripts/hero/hero_progression.gd")
const DAMAGE_REDUCTION_PER_ARMOR_POINT: float = 0.005
const MAX_DAMAGE_REDUCTION: float = 0.95

var hero_progression = HeroProgressionScript.new()

func resolve(hero_state, include_temporary_effects: bool = true) -> RefCounted:
	var combat_stats = CombatStatsScript.new()
	var equipment_strength: int = hero_state.equipment.get_strength_bonus()
	var effective_strength: int = hero_state.strength + equipment_strength
	combat_stats.max_hp = hero_progression.BASE_MAX_HP + hero_progression.get_level_hp_bonus(hero_state.level) + effective_strength * 5.0 + hero_state.equipment.get_max_hp_bonus()
	combat_stats.attack = hero_progression.BASE_ATTACK + effective_strength
	combat_stats.attack_speed = hero_progression.BASE_ATTACK_SPEED + hero_state.agility * 0.01
	combat_stats.crit_chance = hero_progression.BASE_CRIT_CHANCE + hero_state.agility * 0.01
	combat_stats.crit_damage = hero_progression.BASE_CRIT_DAMAGE + hero_state.agility * 0.03
	combat_stats.damage_reduction = clampf(hero_state.equipment.get_armor_bonus() * DAMAGE_REDUCTION_PER_ARMOR_POINT, 0.0, MAX_DAMAGE_REDUCTION)
	if include_temporary_effects:
		for effect in hero_state.active_effects:
			combat_stats.attack += float(effect.get("attack_bonus", 0.0))
	return combat_stats
