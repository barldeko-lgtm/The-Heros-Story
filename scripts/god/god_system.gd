class_name GodSystem
extends RefCounted

const HeroStateScript = preload("res://scripts/hero/hero_state.gd")

var god_state

func _init(initial_god_state) -> void:
	god_state = initial_god_state

func use_instant_resurrection(hero_state, quest_runner, combat_stats) -> Dictionary:
	var result: Dictionary = {
		"succeeded": false,
		"event": null,
	}
	if hero_state == null or quest_runner == null or combat_stats == null:
		return result
	if hero_state.loop_state != HeroStateScript.DEAD_RESPAWNING:
		return result
	if not god_state.try_spend_resurrection(quest_runner.respawn_ticks_remaining):
		return result
	var event = quest_runner.force_resurrection(hero_state, combat_stats)
	result["event"] = event
	result["succeeded"] = event != null
	return result

func use_divine_healing(hero_state, combat_stats, active_combat_session) -> bool:
	if hero_state == null or combat_stats == null:
		return false
	if hero_state.loop_state == HeroStateScript.DEAD_RESPAWNING:
		return false
	var current_hp: float = hero_state.current_hp
	if active_combat_session != null:
		current_hp = active_combat_session.hero_remaining_hp
	if current_hp >= combat_stats.max_hp or not god_state.try_activate_healing():
		return false
	var healed_hp: float = minf(combat_stats.max_hp, current_hp + combat_stats.max_hp * 0.50)
	if active_combat_session != null:
		active_combat_session.hero_remaining_hp = healed_hp
	else:
		hero_state.current_hp = healed_hp
	return true

func use_combat_buff(hero_state) -> bool:
	if hero_state == null:
		return false
	if not god_state.try_activate_combat_buff(get_combat_buff_fights_remaining(hero_state) > 0):
		return false
	hero_state.active_effects.append({
		"id": god_state.COMBAT_BUFF_EFFECT_ID,
		"physical_damage_multiplier": god_state.COMBAT_BUFF_PHYSICAL_DAMAGE_MULTIPLIER,
		"fights_remaining": god_state.COMBAT_BUFF_FIGHTS,
	})
	return true

func get_combat_buff_fights_remaining(hero_state) -> int:
	var effect_index := get_combat_buff_effect_index(hero_state)
	if effect_index < 0:
		return 0
	return int(hero_state.active_effects[effect_index].get("fights_remaining", 0))

func consume_combat_buff_fight(hero_state) -> bool:
	var effect_index := get_combat_buff_effect_index(hero_state)
	if effect_index < 0:
		return false
	var effect: Dictionary = hero_state.active_effects[effect_index]
	effect["fights_remaining"] = maxi(0, int(effect.get("fights_remaining", 0)) - 1)
	if effect["fights_remaining"] <= 0:
		hero_state.active_effects.remove_at(effect_index)
	else:
		hero_state.active_effects[effect_index] = effect
	return true

func guide_hero_to_quest(quest_id: String, autonomous_quest_choice: bool, available_quests: Array) -> bool:
	if not autonomous_quest_choice:
		return false
	for quest in available_quests:
		if quest != null and quest.id == quest_id:
			return god_state.try_set_quest_guidance(quest_id)
	return false

func get_combat_buff_effect_index(hero_state) -> int:
	if hero_state == null:
		return -1
	for index in hero_state.active_effects.size():
		if hero_state.active_effects[index].get("id", "") == god_state.COMBAT_BUFF_EFFECT_ID:
			return index
	return -1
