class_name QuestNarrator
extends RefCounted

const QuestEventScript = preload("res://scripts/quests/quest_event.gd")

func describe(event) -> String:
	match event.event_type:
		QuestEventScript.HERO_SELECTED_QUEST:
			return "%s выбрал квест «%s»." % [event.hero_name, event.quest_definition.display_name]
		QuestEventScript.HERO_TRAVELLING_TO_QUEST:
			return "%s идёт к цели. Осталось: %d гекс." % [event.hero_name, event.distance_remaining]
		QuestEventScript.HERO_ARRIVED_AT_QUEST:
			return "%s прибыл к цели." % event.hero_name
		QuestEventScript.HERO_WON_FIGHT:
			return "%s победил %s в бою %d/%d, получил %d XP. HP: %.1f / %.1f." % [event.hero_name, event.quest_definition.mob_definition.display_name, event.completed_mob_count, event.mob_count, event.experience_reward, event.current_hp, event.max_hp]
		QuestEventScript.HERO_RECOVERED_AFTER_FIGHT:
			return describe_recovery(event)
		QuestEventScript.HERO_RETURNING_TO_CITY:
			return "%s возвращается в город. Осталось: %d гекс." % [event.hero_name, event.distance_remaining]
		QuestEventScript.HERO_RETURNED_TO_CITY:
			return "%s вернулся в город." % event.hero_name
		QuestEventScript.HERO_TURNED_IN_QUEST:
			return "%s сдал квест «%s» и получил %d золота." % [event.hero_name, event.quest_definition.display_name, event.gold_reward]
		QuestEventScript.HERO_DIED:
			return "%s погиб в бою с %s. Квест «%s» отменён. Возрождение через %d тиков." % [event.hero_name, event.quest_definition.mob_definition.display_name, event.quest_definition.display_name, event.respawn_ticks_remaining]
		QuestEventScript.HERO_WAITING_FOR_RESURRECTION:
			return "%s мёртв. Тиков до возрождения: %d." % [event.hero_name, event.respawn_ticks_remaining]
		QuestEventScript.HERO_RESURRECTED:
			return "%s возродился в городе с %.1f HP." % [event.hero_name, event.current_hp]
		QuestEventScript.HERO_RECOVERING_IN_CITY:
			return describe_city_recovery(event)
	return ""

func describe_quest_selection(event, selection_result: Dictionary) -> String:
	if event == null or event.quest_definition == null:
		return ""
	var ranked_evaluations: Array = selection_result.get("ranked_evaluations", [])
	if ranked_evaluations.is_empty():
		return describe(event)

	var selected_quest_id: String = str(event.quest_definition.id)
	var lines := PackedStringArray()
	lines.append("%s выбрал квест «%s»." % [event.hero_name, event.quest_definition.display_name])
	var top_count: int = mini(3, ranked_evaluations.size())
	lines.append("Топ-%d из %d подходящих:" % [top_count, int(selection_result.get("eligible_count", ranked_evaluations.size()))])

	var selected_evaluation: Dictionary = {}
	for index in range(top_count):
		var evaluation: Dictionary = ranked_evaluations[index]
		var quest = evaluation.get("quest")
		if quest == null:
			continue
		var is_selected: bool = str(quest.id) == selected_quest_id
		var selected_suffix: String = " ← выбран" if is_selected else ""
		lines.append("%d. «%s» — QuestScore %.2f%s" % [index + 1, quest.display_name, float(evaluation.get("quest_score", 0.0)), selected_suffix])
		if is_selected:
			selected_evaluation = evaluation

	if selected_evaluation.is_empty():
		for evaluation in ranked_evaluations:
			var quest = evaluation.get("quest")
			if quest != null and str(quest.id) == selected_quest_id:
				selected_evaluation = evaluation
				break

	if not selected_evaluation.is_empty():
		lines.append(
			"Расчёт выбранного: база %.2f | Смелость/Осторожность %s | Хитрость/Благородство %s | Жадность %s | Бог %s | итог %.2f." % [
				float(selected_evaluation.get("base_attractiveness", 0.0)),
				format_signed_modifier(float(selected_evaluation.get("courage_modifier", 0.0))),
				format_signed_modifier(float(selected_evaluation.get("morality_modifier", 0.0))),
				format_signed_modifier(float(selected_evaluation.get("greed_modifier", 0.0))),
				format_signed_modifier(float(selected_evaluation.get("divine_modifier", 0.0))),
				float(selected_evaluation.get("quest_score", 0.0)),
			]
		)
	return "\n".join(lines)

func format_signed_modifier(value: float) -> String:
	if value >= 0.0:
		return "+%.2f" % value
	return "-%.2f" % absf(value)

func describe_combat_started(hero_name: String, quest_definition, mob_number: int, mob_count: int) -> String:
	return "%s начинает бой с %s (%d/%d)." % [hero_name, quest_definition.mob_definition.display_name, mob_number, mob_count]

func describe_combat_action(action, hero_name: String, quest_definition) -> String:
	var attacker_name: String = hero_name if action.attacker_id == "hero" else quest_definition.mob_definition.display_name
	if action.action_id == "battle_guard":
		return "%.2f с — %s применил «Боевой заслон»." % [action.time_seconds, attacker_name]
	if not action.did_hit:
		return "%.2f с — %s промахнулся." % [action.time_seconds, attacker_name]
	var critical_text := " критическим ударом" if action.is_critical else ""
	var block_text := " Удар был заблокирован." if action.was_blocked else ""
	if action.action_id == "power_strike":
		return "%.2f с — %s применил «Мощный удар»%s и нанёс %.2f урона.%s" % [action.time_seconds, attacker_name, critical_text, action.damage, block_text]
	return "%.2f с — %s%s нанёс %.2f урона.%s" % [action.time_seconds, attacker_name, critical_text, action.damage, block_text]

func describe_recovery(event) -> String:
	var message := "%s восстановил здоровье: %.1f / %.1f." % [event.hero_name, event.current_hp, event.max_hp]
	if is_equal_approx(event.current_hp, event.max_hp):
		if event.completed_mob_count >= event.mob_count:
			message += " Все противники побеждены; он идёт в город."
		else:
			message += " Готов к следующему бою."
	return message

func describe_city_recovery(event) -> String:
	var message := "%s восстанавливается в городе: %.1f / %.1f HP." % [event.hero_name, event.current_hp, event.max_hp]
	if is_equal_approx(event.current_hp, event.max_hp):
		message += " Полностью восстановился и снова готов выбирать квест."
	return message
