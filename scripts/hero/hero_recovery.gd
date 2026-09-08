class_name HeroRecovery
extends RefCounted

const RESPAWN_DURATION_TICKS: int = 100
const RESURRECTION_HP: float = 1.0
const CITY_RECOVERY_PERCENT_OF_MAX_HP: float = 0.20

# Runners retain their timer, activity context, guards and result payloads.
static func advance_respawn(hero_state, combat_stats: CombatStats, ticks_remaining: int) -> int:
	var remaining: int = maxi(0, ticks_remaining - 1)
	if remaining == 0:
		resurrect(hero_state, combat_stats)
	return remaining

static func resurrect(hero_state, combat_stats: CombatStats) -> void:
	assert(combat_stats != null, "Resurrection requires resolved hero CombatStats.")
	hero_state.current_hp = minf(RESURRECTION_HP, combat_stats.max_hp)
	hero_state.loop_state = HeroState.RECOVERING_IN_CITY

static func advance_city_recovery(hero_state, combat_stats: CombatStats) -> bool:
	assert(combat_stats != null, "City recovery requires resolved hero CombatStats.")
	hero_state.current_hp = minf(combat_stats.max_hp, hero_state.current_hp + combat_stats.max_hp * CITY_RECOVERY_PERCENT_OF_MAX_HP)
	var fully_recovered: bool = is_equal_approx(hero_state.current_hp, combat_stats.max_hp)
	if fully_recovered:
		hero_state.current_hp = combat_stats.max_hp
		hero_state.loop_state = HeroState.CHOOSING_QUEST
	return fully_recovered
