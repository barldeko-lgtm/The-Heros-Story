class_name SpecializationQuestNarrator
extends RefCounted

static func describe_path_decided(hero_name: String, specialization_name: String) -> String:
	return "%s решил, кем хочет стать: %s. После следующего возвращения с задания он поговорит с тренером воинов." % [hero_name, specialization_name]

static func describe_quest_accepted(hero_name: String, quest_definition, dungeon_instance) -> String:
	return "%s поговорил с тренером воинов и получил специализационное задание «%s». Место испытания известно: «%s»." % [hero_name, quest_definition.display_name, dungeon_instance.definition.display_name]

static func describe_trial_completed(hero_name: String, dungeon_name: String) -> String:
	return "%s прошёл испытание в «%s» и возвращается к тренеру воинов завершить специализационное задание." % [hero_name, dungeon_name]

static func describe_quest_completed(hero_name: String, specialization_name: String, gold_reward: int, free_points: int, catchup_points: int, directed_stat_name: String) -> String:
	var catchup_text := ""
	if catchup_points > 0:
		catchup_text = " Получено +%d %s за уже пройденные уровни после 20-го." % [catchup_points, directed_stat_name]
	return "%s завершил обучение у тренера и стал: %s. Награда: %d золота и +%d свободных очков характеристик.%s" % [hero_name, specialization_name, gold_reward, free_points, catchup_text]
