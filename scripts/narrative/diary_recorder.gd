class_name DiaryRecorder
extends RefCounted

const QuestEventScript = preload("res://scripts/quests/quest_event.gd")
const MIN_DIARY_EQUIPMENT_RARITY: int = 2

# Records supplied facts only. No Simulation reference or gameplay ownership.
var diary
var diary_narrator
var active_quest_diary_entry_id: int = -1

func _init(target_diary) -> void:
	diary = target_diary

func record_quest_diary_event(event, event_tick: int) -> void:
	if diary_narrator == null:
		return
	var diary_text: String = diary_narrator.describe_quest_event(event)
	if event.event_type == QuestEventScript.HERO_SELECTED_QUEST:
		clear_active_quest_diary_entry()
		if not diary_text.is_empty():
			active_quest_diary_entry_id = diary.add_temporary_entry(event_tick, diary_text)
		return
	if event.event_type == QuestEventScript.HERO_TURNED_IN_QUEST or event.event_type == QuestEventScript.HERO_DIED:
		clear_active_quest_diary_entry()
	if not diary_text.is_empty():
		diary.add_entry(event_tick, diary_text)

func clear_active_quest_diary_entry() -> void:
	if active_quest_diary_entry_id <= 0:
		return
	diary.remove_entry(active_quest_diary_entry_id)
	active_quest_diary_entry_id = -1

func record_death_diary_entry(hero_name: String, killer_name: String, activity_type: String, activity_name: String, event_tick: int) -> void:
	if diary_narrator == null:
		return
	var diary_text: String = diary_narrator.describe_death(hero_name, killer_name, activity_type, activity_name)
	if not diary_text.is_empty():
		diary.add_entry(event_tick, diary_text)

func record_resurrection_diary_entry(hero_name: String, resurrection_type: String, event_tick: int) -> void:
	if diary_narrator == null:
		return
	var diary_text: String = diary_narrator.describe_resurrection(hero_name, resurrection_type)
	if not diary_text.is_empty():
		diary.add_entry(event_tick, diary_text)

func record_event_completed_diary_entry(end_stage, completed_tick: int) -> void:
	if diary_narrator == null or end_stage == null:
		return
	var diary_text: String = diary_narrator.describe_event_completed(end_stage)
	if not diary_text.is_empty():
		diary.add_entry(completed_tick, diary_text)

func record_equipment_acquisition_diary_entry(hero_name: String, item_instance, completed_tick: int) -> void:
	if diary_narrator == null or item_instance == null or item_instance.definition == null:
		return
	if int(item_instance.rarity) < MIN_DIARY_EQUIPMENT_RARITY:
		return
	var diary_text: String = diary_narrator.describe_equipment_acquisition(
		hero_name,
		item_instance.definition.display_name,
		int(item_instance.rarity)
	)
	if not diary_text.is_empty():
		diary.add_entry(completed_tick, diary_text)

func record_dungeon_attempt_started_diary_entry(hero_name: String, dungeon_instance, completed_tick: int) -> void:
	if diary_narrator == null or dungeon_instance == null or dungeon_instance.definition == null:
		return
	var diary_text: String = diary_narrator.describe_dungeon_attempt_started(hero_name, dungeon_instance.definition.display_name)
	if not diary_text.is_empty():
		diary.add_entry(completed_tick, diary_text)

func record_dungeon_potion_purchase_diary_entry(hero_name: String, dungeon_instance, preparation: Dictionary, completed_tick: int) -> void:
	if diary_narrator == null or dungeon_instance == null or dungeon_instance.definition == null:
		return
	var potion_count: int = 0
	for count in preparation.get("purchase_counts", {}).values():
		potion_count += int(count)
	if potion_count <= 0:
		return
	var diary_text: String = diary_narrator.describe_dungeon_potions_bought(hero_name, dungeon_instance.definition.display_name, potion_count)
	if not diary_text.is_empty():
		diary.add_entry(completed_tick, diary_text)

func record_dungeon_completed_diary_entry(hero_name: String, dungeon_definition: Resource, gold_reward: int, reward_item, completed_tick: int) -> void:
	if diary_narrator == null or dungeon_definition == null or reward_item == null or reward_item.definition == null:
		return
	var diary_text: String = diary_narrator.describe_dungeon_completed(
		hero_name,
		dungeon_definition.display_name,
		gold_reward,
		reward_item.definition.display_name,
		int(reward_item.rarity)
	)
	if not diary_text.is_empty():
		diary.add_entry(completed_tick, diary_text)

func record_dungeon_discovered(hero_name: String, dungeon_instance, event_tick: int) -> void:
	if diary_narrator == null or dungeon_instance == null or dungeon_instance.definition == null:
		return
	var diary_text: String = diary_narrator.describe_dungeon_discovered(hero_name, dungeon_instance.definition.display_name)
	if not diary_text.is_empty():
		diary.add_entry(event_tick, diary_text)
