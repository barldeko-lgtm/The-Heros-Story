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

func resolve(hero_state, include_temporary_effects: bool = true, equipment_override = null) -> RefCounted:
	var combat_stats = CombatStatsScript.new()
	var equipment = equipment_override if equipment_override != null else hero_state.equipment
	var equipment_strength: int = equipment.get_strength_bonus()
	var effective_strength: int = hero_state.strength + equipment_strength
	combat_stats.max_hp = hero_progression.BASE_MAX_HP + hero_state.constitution * MAX_HP_PER_CONSTITUTION + equipment.get_max_hp_bonus()
	combat_stats.attack = hero_progression.BASE_ATTACK + effective_strength * PHYSICAL_DAMAGE_PER_STRENGTH + equipment.get_attack_bonus()
	combat_stats.attack_speed = hero_progression.BASE_ATTACK_SPEED + equipment.get_attack_speed_bonus()
	combat_stats.accuracy = hero_state.dexterity * ACCURACY_PER_DEXTERITY + equipment.get_accuracy_bonus()
	combat_stats.dodge = hero_state.dexterity * DODGE_PER_DEXTERITY + equipment.get_dodge_bonus()
	combat_stats.armor = hero_state.constitution * ARMOR_PER_CONSTITUTION + equipment.get_armor_bonus()
	combat_stats.fire_resistance = equipment.get_fire_resistance_bonus()
	combat_stats.cold_resistance = equipment.get_cold_resistance_bonus()
	combat_stats.lightning_resistance = equipment.get_lightning_resistance_bonus()
	combat_stats.block = equipment.get_block_bonus()
	combat_stats.crit_chance = hero_progression.BASE_CRIT_CHANCE + hero_state.dexterity * CRIT_CHANCE_PER_DEXTERITY + equipment.get_crit_chance_bonus()
	combat_stats.crit_damage = hero_progression.BASE_CRIT_DAMAGE + effective_strength * CRIT_DAMAGE_PER_STRENGTH + equipment.get_crit_damage_bonus()
	if include_temporary_effects:
		var physical_damage_multiplier: float = 1.0
		for effect in hero_state.active_effects:
			combat_stats.attack += float(effect.get("attack_bonus", 0.0))
			physical_damage_multiplier *= float(effect.get("physical_damage_multiplier", 1.0))
		combat_stats.attack *= physical_damage_multiplier
	return combat_stats
