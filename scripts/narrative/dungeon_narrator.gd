class_name DungeonNarrator
extends RefCounted

func describe_combat_started(hero_name: String, dungeon_name: String, mob_definition, encounter_number: int, total_encounters: int, is_boss: bool) -> String:
	var encounter_label := "босс" if is_boss else "бой %d/%d" % [encounter_number, total_encounters]
	return "%s в данже «%s» начинает %s против %s." % [hero_name, dungeon_name, encounter_label, mob_definition.display_name]

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

func describe_fight_won(hero_name: String, mob_definition, experience_reward: int, current_hp: float, max_hp: float, is_boss: bool) -> String:
	if is_boss:
		return "%s победил босса %s, получил %d XP. HP: %.1f / %.1f." % [hero_name, mob_definition.display_name, experience_reward, current_hp, max_hp]
	return "%s победил %s, получил %d XP. HP: %.1f / %.1f." % [hero_name, mob_definition.display_name, experience_reward, current_hp, max_hp]

func describe_between_fights(hero_name: String, current_hp: float, max_hp: float, next_is_boss: bool) -> String:
	var next_text := "Следующий бой — босс." if next_is_boss else "Готовится к следующему бою."
	return "%s провёл 1 тик между боями без лечения: %.1f / %.1f HP. %s" % [hero_name, current_hp, max_hp, next_text]

func describe_death(hero_name: String, dungeon_name: String, mob_definition, respawn_ticks_remaining: int) -> String:
	return "%s погиб в данже «%s» в бою с %s. Возрождение через %d тиков." % [hero_name, dungeon_name, mob_definition.display_name, respawn_ticks_remaining]

func describe_retry_requirement(hero_name: String, dungeon_name: String, attempt_start_power: float, required_power: float, retry_growth: float) -> String:
	return "%s запомнил неудачную попытку данжа «%s»: сила на старте %.2f; повторная попытка не раньше %.2f Power (+%.0f%%)." % [hero_name, dungeon_name, attempt_start_power, required_power, retry_growth * 100.0]

func describe_retry_postponed(hero_name: String, dungeon_name: String, current_power: float, required_power: float) -> String:
	return "%s пока не готов снова идти в данж «%s»: текущая сила %.2f, требуется %.2f Power." % [hero_name, dungeon_name, current_power, required_power]

func describe_waiting_for_resurrection(hero_name: String, respawn_ticks_remaining: int) -> String:
	return "%s мёртв после неудачной попытки данжа. Тиков до возрождения: %d." % [hero_name, respawn_ticks_remaining]

func describe_resurrected(hero_name: String, current_hp: float) -> String:
	return "%s возродился в городе после неудачной попытки данжа с %.1f HP." % [hero_name, current_hp]

func describe_city_recovery(hero_name: String, current_hp: float, max_hp: float, fully_recovered: bool) -> String:
	var message := "%s восстанавливается в городе после данжа: %.1f / %.1f HP." % [hero_name, current_hp, max_hp]
	if fully_recovered:
		message += " Полностью восстановился и вернулся к обычным делам."
	return message

func describe_completed(hero_name: String, dungeon_name: String) -> String:
	return "%s победил босса и полностью прошёл данж «%s». Награда за завершение пока не подключена." % [hero_name, dungeon_name]
