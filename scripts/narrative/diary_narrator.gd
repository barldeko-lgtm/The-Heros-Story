class_name DiaryNarrator
extends RefCounted

const QuestEventScript = preload("res://scripts/quests/quest_event.gd")
const DefaultOrdinaryQuestDiaryText = preload("res://data/narrative/quests/ordinary_quest_diary.tres")
const DefaultDeathDiaryText = preload("res://data/narrative/death_diary.tres")
const DefaultResurrectionDiaryText = preload("res://data/narrative/resurrection_diary.tres")
const DefaultEquipmentAcquisitionDiaryText = preload("res://data/narrative/equipment_acquisition_diary.tres")
const DefaultDungeonDiaryText = preload("res://data/narrative/dungeon_diary.tres")

const DEATH_ACTIVITY_QUEST := "quest"
const DEATH_ACTIVITY_DUNGEON := "dungeon"
const DEATH_ACTIVITY_EVENT := "event"
const RESURRECTION_NATURAL := "natural"
const RESURRECTION_DIVINE := "divine"
const EQUIPMENT_RARITY_RARE := 2
const EQUIPMENT_RARITY_EPIC := 3

var narrative_rng: RandomNumberGenerator

func _init(initial_narrative_rng: RandomNumberGenerator) -> void:
	narrative_rng = initial_narrative_rng

func describe_new_game_arrival(hero_name: String) -> String:
	return "%s добрался до небольшого городка. Здесь начинается его жизнь искателя приключений. Помня об Илье и данном себе обещании, он направился в гильдию авантюристов за первым заданием." % hero_name

func describe_quest_event(event) -> String:
	if event == null or event.quest_definition == null:
		return ""
	var text_definition = get_quest_text_definition(event.quest_definition)
	match event.event_type:
		QuestEventScript.HERO_SELECTED_QUEST:
			return format_quest_text(select_variant(text_definition.selected_variants), event)
		QuestEventScript.HERO_TURNED_IN_QUEST:
			return format_quest_text(select_variant(text_definition.completed_variants), event)
		QuestEventScript.HERO_DIED:
			var mob_name: String = ""
			if event.quest_definition.mob_definition != null:
				mob_name = event.quest_definition.mob_definition.display_name
			return describe_death(event.hero_name, mob_name, DEATH_ACTIVITY_QUEST, event.quest_definition.display_name)
		QuestEventScript.HERO_RESURRECTED:
			return describe_resurrection(event.hero_name, RESURRECTION_NATURAL)
	return ""

func describe_death(hero_name: String, killer_name: String, activity_type: String, activity_name: String) -> String:
	if hero_name.is_empty() or killer_name.is_empty() or activity_name.is_empty():
		return ""
	var activity_text: String = format_death_activity(activity_type, activity_name)
	if activity_text.is_empty():
		return ""
	return format_text(
		select_variant(DefaultDeathDiaryText.variants),
		{
			"hero": hero_name,
			"killer": killer_name,
			"activity": activity_text,
		}
	)

func format_death_activity(activity_type: String, activity_name: String) -> String:
	match activity_type:
		DEATH_ACTIVITY_QUEST:
			return "задания «%s»" % activity_name
		DEATH_ACTIVITY_DUNGEON:
			return "прохождения данжа «%s»" % activity_name
		DEATH_ACTIVITY_EVENT:
			return "события «%s»" % activity_name
	return ""

func describe_resurrection(hero_name: String, resurrection_type: String) -> String:
	if hero_name.is_empty():
		return ""
	var variants: PackedStringArray
	match resurrection_type:
		RESURRECTION_NATURAL:
			variants = DefaultResurrectionDiaryText.natural_variants
		RESURRECTION_DIVINE:
			variants = DefaultResurrectionDiaryText.divine_variants
		_:
			return ""
	return format_text(select_variant(variants), {"hero": hero_name})

func describe_equipment_acquisition(hero_name: String, item_name: String, rarity: int) -> String:
	if hero_name.is_empty() or item_name.is_empty():
		return ""
	var variants: PackedStringArray
	match rarity:
		EQUIPMENT_RARITY_RARE:
			variants = DefaultEquipmentAcquisitionDiaryText.rare_variants
		EQUIPMENT_RARITY_EPIC:
			variants = DefaultEquipmentAcquisitionDiaryText.epic_variants
		_:
			return ""
	return format_text(select_variant(variants), {
		"hero": hero_name,
		"item": item_name,
	})

func describe_dungeon_discovered(hero_name: String, dungeon_name: String) -> String:
	return format_dungeon_text(DefaultDungeonDiaryText.discovered_variants, hero_name, dungeon_name)

func describe_dungeon_attempt_started(hero_name: String, dungeon_name: String) -> String:
	return format_dungeon_text(DefaultDungeonDiaryText.attempt_started_variants, hero_name, dungeon_name)

func describe_dungeon_potions_bought(hero_name: String, dungeon_name: String, potion_count: int) -> String:
	if potion_count <= 0:
		return ""
	return format_dungeon_text(
		DefaultDungeonDiaryText.potions_bought_variants,
		hero_name,
		dungeon_name,
		{"count": str(potion_count)}
	)

func describe_dungeon_completed(hero_name: String, dungeon_name: String, gold_reward: int, item_name: String, item_rarity: int) -> String:
	if item_name.is_empty():
		return ""
	var rarity_text: String = get_equipment_rarity_adjective(item_rarity)
	if rarity_text.is_empty():
		return ""
	return format_dungeon_text(
		DefaultDungeonDiaryText.completed_variants,
		hero_name,
		dungeon_name,
		{
			"gold": str(gold_reward),
			"item": item_name,
			"rarity": rarity_text,
		}
	)

func describe_event_completed(end_stage) -> String:
	if end_stage == null:
		return ""
	return str(end_stage.diary_text).strip_edges()

func format_dungeon_text(variants: PackedStringArray, hero_name: String, dungeon_name: String, extra_replacements: Dictionary = {}) -> String:
	if hero_name.is_empty() or dungeon_name.is_empty():
		return ""
	var replacements: Dictionary = {
		"hero": hero_name,
		"dungeon": dungeon_name,
	}
	for key in extra_replacements:
		replacements[key] = extra_replacements[key]
	return format_text(select_variant(variants), replacements)

func get_equipment_rarity_adjective(rarity: int) -> String:
	match rarity:
		EQUIPMENT_RARITY_RARE:
			return "редкий"
		EQUIPMENT_RARITY_EPIC:
			return "эпический"
	return ""

func get_quest_text_definition(quest_definition):
	var template = quest_definition.get("template")
	if template == null:
		template = quest_definition
	var authored_text = template.get("diary_text") if template != null else null
	return authored_text if authored_text != null else DefaultOrdinaryQuestDiaryText

func select_variant(variants: PackedStringArray) -> String:
	if variants.is_empty():
		return ""
	if variants.size() == 1 or narrative_rng == null:
		return variants[0]
	return variants[narrative_rng.randi_range(0, variants.size() - 1)]

func format_quest_text(template_text: String, event) -> String:
	if template_text.is_empty():
		return ""
	var quest = event.quest_definition
	var mob_name: String = ""
	if quest.mob_definition != null:
		mob_name = quest.mob_definition.display_name
	var replacements := {
		"hero": event.hero_name,
		"quest": quest.display_name,
		"mob": mob_name,
		"gold": str(event.gold_reward),
		"completed_mobs": str(event.completed_mob_count),
		"total_mobs": str(event.mob_count),
	}
	return format_text(template_text, replacements)

func format_text(template_text: String, replacements: Dictionary) -> String:
	var result: String = template_text
	for placeholder in replacements:
		result = result.replace("{%s}" % placeholder, str(replacements[placeholder]))
	return result
