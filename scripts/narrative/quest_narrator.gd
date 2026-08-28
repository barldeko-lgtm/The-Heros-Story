class_name QuestNarrator
extends RefCounted

const QuestEventScript = preload("res://scripts/quests/quest_event.gd")

func describe(event) -> String:
	match event.event_type:
		QuestEventScript.HERO_SELECTED_QUEST:
			return "%s выбрал квест «%s»." % [event.hero_name, event.quest_definition.display_name]
		QuestEventScript.HERO_TRAVELLING_TO_QUEST:
			return "%s идёт к цели. Осталось: %d км." % [event.hero_name, event.distance_remaining]
		QuestEventScript.HERO_ARRIVED_AT_QUEST:
			return "%s прибыл к цели." % event.hero_name
		QuestEventScript.HERO_WON_FIGHT:
			return "%s победил %s в бою %d/%d, получил %d XP. HP: %.1f / %.1f." % [event.hero_name, event.quest_definition.mob_definition.display_name, event.completed_mob_count, event.mob_count, event.experience_reward, event.current_hp, event.max_hp]
		QuestEventScript.HERO_RECOVERED_AFTER_FIGHT:
			return describe_recovery(event)
		QuestEventScript.HERO_RETURNING_TO_CITY:
			return "%s возвращается в город. Осталось: %d км." % [event.hero_name, event.distance_remaining]
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

func describe_combat_started(hero_name: String, quest_definition, mob_number: int, mob_count: int) -> String:
	return "%s начинает бой с %s (%d/%d)." % [hero_name, quest_definition.mob_definition.display_name, mob_number, mob_count]

func describe_combat_action(action, hero_name: String, quest_definition) -> String:
	var attacker_name: String = hero_name if action.attacker_id == "hero" else quest_definition.mob_definition.display_name
	if not action.did_hit:
		return "%.2f с — %s промахнулся." % [action.time_seconds, attacker_name]
	var critical_text := " критическим ударом" if action.is_critical else ""
	var block_text := " Удар был заблокирован." if action.was_blocked else ""
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
