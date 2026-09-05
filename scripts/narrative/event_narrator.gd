class_name EventNarrator
extends RefCounted

func describe_spawn(event_instance) -> String:
	return "Событие мира «%s» появилось около гекса (%d, %d)." % [
		event_instance.definition.display_name,
		event_instance.target_hex.x,
		event_instance.target_hex.y,
	]

func describe_expired(event_instance) -> String:
	return "Событие мира «%s» исчезло, так и не встретившись герою." % event_instance.definition.display_name

func describe_rotated_out(event_instance) -> String:
	return "Событие мира «%s» ушло с карты при плановой смене событий." % event_instance.definition.display_name

func describe_started(event_instance) -> String:
	return "СОБЫТИЕ «%s»: герой попал в область события; прежний маршрут временно приостановлен." % event_instance.definition.display_name

func describe_stage(event_instance, stage, ticks_remaining: int = 0) -> String:
	if not stage.scene_text.is_empty():
		return "СОБЫТИЕ «%s»: %s" % [event_instance.definition.display_name, stage.scene_text]
	return "СОБЫТИЕ «%s»: этап %s; осталось тиков этапа: %d." % [event_instance.definition.display_name, stage.id, ticks_remaining]

func describe_formative_decision(result: Dictionary) -> String:
	var event_instance = result["event_instance"]
	var option = result["selected_option"]
	var values: Dictionary = result["compared_values"]
	var parts := PackedStringArray()
	for attribute_id in values:
		parts.append("%s=%d" % [attribute_id, int(values[attribute_id])])
	parts.sort()
	var tie_text := "; точное равенство разрешено seeded RNG" if bool(result.get("tie_broken", false)) else ""
	var personality_text := ""
	var change: Dictionary = result.get("personality_change", {})
	if not change.is_empty():
		personality_text = "; %s %+d (%d → %d)" % [change["axis_id"], change["delta"], change["previous_value"], change["new_value"]]
	return "СОБЫТИЕ «%s»: formative-выбор [%s] → %s%s%s." % [event_instance.definition.display_name, ", ".join(parts), option.id, tie_text, personality_text]

func describe_trait_check(result: Dictionary) -> String:
	var event_instance = result["event_instance"]
	return "СОБЫТИЕ «%s»: expressive-проверка %s → %s." % [
		event_instance.definition.display_name,
		result["checked_trait_id"],
		"особая ветка" if bool(result["trait_present"]) else "стандартная ветка",
	]

func describe_travel(result: Dictionary) -> String:
	var event_instance = result["event_instance"]
	var stage = result["stage"]
	var action_text: String = stage.scene_text if not stage.scene_text.is_empty() else "Герой следует к временной цели события."
	if str(result.get("type", "")) == "travel_completed":
		return "СОБЫТИЕ «%s»: %s Герой прибыл; путь события завершён." % [event_instance.definition.display_name, action_text]
	return "СОБЫТИЕ «%s»: %s Осталось гексов: %d." % [event_instance.definition.display_name, action_text, int(result.get("remaining_steps", 0))]

func describe_combat_started(hero_name: String, event_name: String, mob_definition) -> String:
	return "СОБЫТИЕ «%s»: %s начинает бой с %s." % [event_name, hero_name, mob_definition.display_name]

func describe_combat_action(action, hero_name: String, mob_definition) -> String:
	var attacker_name: String = hero_name if action.attacker_id == "hero" else mob_definition.display_name
	if action.action_id == "battle_guard":
		return "%.2f с — %s применил «Боевой заслон»." % [action.time_seconds, attacker_name]
	if not action.did_hit:
		return "%.2f с — %s промахнулся." % [action.time_seconds, attacker_name]
	var critical_text := " критическим ударом" if action.is_critical else ""
	var block_text := " Удар был заблокирован." if action.was_blocked else ""
	if action.action_id == "power_strike":
		return "%.2f с — %s применил «Мощный удар»%s и нанёс %.2f урона.%s" % [action.time_seconds, attacker_name, critical_text, action.damage, block_text]
	return "%.2f с — %s%s нанёс %.2f урона.%s" % [action.time_seconds, attacker_name, critical_text, action.damage, block_text]

func describe_fight_won(hero_name: String, event_name: String, mob_definition, experience_reward: int, current_hp: float, max_hp: float) -> String:
	return "СОБЫТИЕ «%s»: %s победил %s, получил %d XP. HP: %.1f / %.1f." % [event_name, hero_name, mob_definition.display_name, experience_reward, current_hp, max_hp]

func describe_completed(hero_name: String, event_name: String, stage) -> String:
	var reward_parts := PackedStringArray()
	if stage.gold_reward > 0:
		reward_parts.append("+%d золота" % stage.gold_reward)
	if stage.equipment_reward_source != null:
		reward_parts.append("предмет экипировки")
	var rewards := "без материальной награды" if reward_parts.is_empty() else ", ".join(reward_parts)
	return "СОБЫТИЕ «%s»: %s завершил исход %s — %s." % [event_name, hero_name, stage.outcome_id, rewards]

func describe_death(hero_name: String, event_name: String, mob_definition, respawn_ticks_remaining: int) -> String:
	return "СОБЫТИЕ «%s»: %s погиб в бою с %s. Прежнее приключение прервано. Возрождение через %d тиков." % [event_name, hero_name, mob_definition.display_name, respawn_ticks_remaining]

func describe_waiting_for_resurrection(hero_name: String, event_name: String, respawn_ticks_remaining: int) -> String:
	return "%s мёртв после события «%s». Тиков до возрождения: %d." % [hero_name, event_name, respawn_ticks_remaining]

func describe_resurrected(hero_name: String, event_name: String, current_hp: float) -> String:
	return "%s возродился в городе после события «%s» с %.1f HP." % [hero_name, event_name, current_hp]

func describe_city_recovery(hero_name: String, current_hp: float, max_hp: float, fully_recovered: bool) -> String:
	var message := "%s восстанавливается в городе после события: %.1f / %.1f HP." % [hero_name, current_hp, max_hp]
	if fully_recovered:
		message += " Полностью восстановился и вернулся к обычным делам."
	return message
