class_name StatResolver
extends RefCounted

const CombatStatsScript = preload("res://scripts/model/runtime/combat_stats.gd")
const HeroProgressionScript = preload("res://scripts/hero/hero_progression.gd")
const PHYSICAL_DAMAGE_PER_STRENGTH: float = 2.0
const CRIT_DAMAGE_PER_STRENGTH: float = 0.05
const ACCURACY_PER_DEXTERITY: float = 10.0
const DODGE_PER_DEXTERITY: float = 2.0
const CRIT_CHANCE_PER_DEXTERITY: float = 0.03
const MAX_HP_PER_CONSTITUTION: float = 20.0
const ARMOR_PER_CONSTITUTION: float = 1.0

var hero_progression = HeroProgressionScript.new()

func resolve(hero_state, include_temporary_effects: bool = true) -> RefCounted:
	var combat_stats = CombatStatsScript.new()
	var equipment_strength: int = hero_state.equipment.get_strength_bonus()
	var effective_strength: int = hero_state.strength + equipment_strength
	combat_stats.max_hp = hero_progression.BASE_MAX_HP + hero_state.constitution * MAX_HP_PER_CONSTITUTION + hero_state.equipment.get_max_hp_bonus()
	combat_stats.attack = hero_progression.BASE_ATTACK + effective_strength * PHYSICAL_DAMAGE_PER_STRENGTH + hero_state.equipment.get_attack_bonus()
	combat_stats.attack_speed = hero_progression.BASE_ATTACK_SPEED
	combat_stats.accuracy = hero_state.dexterity * ACCURACY_PER_DEXTERITY
	combat_stats.dodge = hero_state.dexterity * DODGE_PER_DEXTERITY
	combat_stats.armor = hero_state.constitution * ARMOR_PER_CONSTITUTION + hero_state.equipment.get_armor_bonus()
	combat_stats.crit_chance = hero_progression.BASE_CRIT_CHANCE + hero_state.dexterity * CRIT_CHANCE_PER_DEXTERITY + hero_state.equipment.get_crit_chance_bonus()
	combat_stats.crit_damage = hero_progression.BASE_CRIT_DAMAGE + effective_strength * CRIT_DAMAGE_PER_STRENGTH + hero_state.equipment.get_crit_damage_bonus()
	if include_temporary_effects:
		for effect in hero_state.active_effects:
			combat_stats.attack += float(effect.get("attack_bonus", 0.0))
	return combat_stats
