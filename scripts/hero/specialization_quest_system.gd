class_name SpecializationQuestSystem
extends RefCounted

const HeroSpecializationScript = preload("res://scripts/hero/hero_specialization.gd")
const ProtectorQuest = preload("res://data/quests/specialization/protector_specialization_quest.tres")
const SlayerQuest = preload("res://data/quests/specialization/slayer_specialization_quest.tres")

static func get_definition(specialization_id: String):
	match specialization_id:
		HeroSpecializationScript.PROTECTOR_ID: return ProtectorQuest
		HeroSpecializationScript.SLAYER_ID: return SlayerQuest
	return null

static func find_quest_dungeon(hero_state, dungeon_system):
	if hero_state == null or dungeon_system == null:
		return null
	var quest_definition = get_definition(hero_state.first_specialization_id)
	if quest_definition == null or quest_definition.dungeon_definition == null:
		return null
	var dungeon_id: String = quest_definition.dungeon_definition.id
	for dungeon in dungeon_system.get_all_dungeons():
		if dungeon != null and dungeon.definition != null and dungeon.definition.id == dungeon_id:
			return dungeon
	return null

static func needs_quest_acceptance(hero_state, dungeon_system) -> bool:
	return hero_state != null \
		and hero_state.hero_class_id == HeroSpecializationScript.WARRIOR_ID \
		and HeroSpecializationScript.is_valid_specialization_id(hero_state.first_specialization_id) \
		and find_quest_dungeon(hero_state, dungeon_system) == null

static func objective_is_complete(hero_state, dungeon_system) -> bool:
	if hero_state == null or hero_state.hero_class_id != HeroSpecializationScript.WARRIOR_ID:
		return false
	var dungeon = find_quest_dungeon(hero_state, dungeon_system)
	return dungeon != null and dungeon.completed

static func quest_is_active(hero_state, dungeon_system) -> bool:
	if hero_state == null or hero_state.hero_class_id != HeroSpecializationScript.WARRIOR_ID:
		return false
	var dungeon = find_quest_dungeon(hero_state, dungeon_system)
	return dungeon != null and not dungeon.completed

static func is_specialization_dungeon(dungeon_instance) -> bool:
	if dungeon_instance == null or dungeon_instance.definition == null:
		return false
	var dungeon_id: String = dungeon_instance.definition.id
	return dungeon_id == ProtectorQuest.dungeon_definition.id or dungeon_id == SlayerQuest.dungeon_definition.id

static func is_selected_specialization_dungeon(hero_state, dungeon_instance) -> bool:
	if hero_state == null or dungeon_instance == null or dungeon_instance.definition == null:
		return false
	var quest_definition = get_definition(hero_state.first_specialization_id)
	return quest_definition != null \
		and quest_definition.dungeon_definition != null \
		and dungeon_instance.definition.id == quest_definition.dungeon_definition.id

static func prioritize_candidates(hero_state, dungeon_system, candidates: Array) -> Array:
	var result: Array = candidates.duplicate()
	var specialization_dungeon = find_quest_dungeon(hero_state, dungeon_system)
	if specialization_dungeon == null or specialization_dungeon.completed:
		return result
	var index: int = result.find(specialization_dungeon)
	if index > 0:
		result.remove_at(index)
		result.push_front(specialization_dungeon)
	return result
