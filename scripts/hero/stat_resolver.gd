class_name StatResolver
extends RefCounted

const CombatStatsScript = preload("res://scripts/model/runtime/combat_stats.gd")
const HeroProgressionScript = preload("res://scripts/hero/hero_progression.gd")

var hero_progression = HeroProgressionScript.new()

func resolve(hero_state, include_temporary_effects: bool = true) -> RefCounted:
	var combat_stats = CombatStatsScript.new()
	combat_stats.max_hp = hero_progression.BASE_MAX_HP + hero_progression.get_level_hp_bonus(hero_state.level) + hero_state.strength * 5.0
	combat_stats.attack = hero_progression.BASE_ATTACK + hero_state.strength
	combat_stats.attack_speed = hero_progression.BASE_ATTACK_SPEED + hero_state.agility * 0.01
	combat_stats.crit_chance = hero_progression.BASE_CRIT_CHANCE + hero_state.agility * 0.01
	combat_stats.crit_damage = hero_progression.BASE_CRIT_DAMAGE + hero_state.agility * 0.03
	combat_stats.damage_reduction = 0.0
	if include_temporary_effects:
		for effect in hero_state.active_effects:
			combat_stats.attack += float(effect.get("attack_bonus", 0.0))
	return combat_stats
