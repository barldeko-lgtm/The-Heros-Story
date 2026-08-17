class_name PowerCalculator
extends RefCounted

func calculate(combat_stats) -> float:
	var effective_hp: float = combat_stats.max_hp / (1.0 - combat_stats.damage_reduction)
	var crit_modifier: float = 1.0 + combat_stats.crit_chance * (combat_stats.crit_damage - 1.0)
	var expected_dps: float = combat_stats.attack * (combat_stats.attack_speed / 2.0) * crit_modifier
	return sqrt(effective_hp * expected_dps)
