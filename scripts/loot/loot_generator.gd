class_name LootGenerator
extends RefCounted

const COMMON_CHANCE: float = 0.70
const UNCOMMON_CHANCE: float = 0.25
const RARE_CHANCE: float = 0.05
const RARITY_RARE: int = 2
const RARITY_EPIC: int = 3

func roll_mob_equipment(mob_definition: Resource, rng, hero_class_id: String = ""):
	if mob_definition == null or rng == null:
		return null
	var drop_table: Resource = mob_definition.equipment_drop_table
	if drop_table == null:
		return null

	var drop_chance: float = clampf(drop_table.drop_chance, 0.0, 1.0)
	if drop_chance <= 0.0 or rng.randf() >= drop_chance:
		return null

	var common_items: Array[Resource] = get_eligible_items(drop_table.common_items, hero_class_id)
	var uncommon_items: Array[Resource] = get_eligible_items(drop_table.uncommon_items, hero_class_id)
	var rare_items: Array[Resource] = get_eligible_items(drop_table.rare_items, hero_class_id)
	var slot_count: int = mini(
		common_items.size(),
		mini(uncommon_items.size(), rare_items.size())
	)
	if slot_count <= 0:
		return null

	var slot_index: int = rng.randi_range(0, slot_count - 1)
	var rarity_roll: float = rng.randf()
	var selected_pool: Array[Resource] = common_items
	if rarity_roll >= COMMON_CHANCE + UNCOMMON_CHANCE:
		selected_pool = rare_items
	elif rarity_roll >= COMMON_CHANCE:
		selected_pool = uncommon_items
	return selected_pool[slot_index]

func roll_dungeon_completion_equipment(dungeon_definition: Resource, rng, hero_class_id: String = "") -> Dictionary:
	if dungeon_definition == null or rng == null or dungeon_definition.completion_equipment_source == null:
		return {}
	var source: Resource = dungeon_definition.completion_equipment_source
	var rare_items: Array[Resource] = get_eligible_items(source.rare_items, hero_class_id)
	if rare_items.is_empty() or source.item_level <= 0:
		return {}
	var slot_index: int = rng.randi_range(0, rare_items.size() - 1)
	var epic_chance: float = clampf(dungeon_definition.completion_epic_chance, 0.0, 1.0)
	var rarity: int = RARITY_EPIC if rng.randf() < epic_chance else RARITY_RARE
	return {
		"item_definition": rare_items[slot_index],
		"item_level": int(source.item_level),
		"rarity": rarity,
	}

func get_eligible_items(items: Array[Resource], hero_class_id: String) -> Array[Resource]:
	var eligible_items: Array[Resource] = []
	for item_definition in items:
		if item_definition == null:
			continue
		if item_definition.has_method("can_be_equipped_by_class") and not item_definition.can_be_equipped_by_class(hero_class_id):
			continue
		if hero_class_id == "slayer":
			if item_definition.equipment_slot == "shield":
				continue
			var is_two_handed_weapon: bool = item_definition.has_method("is_two_handed_weapon") and item_definition.is_two_handed_weapon()
			if item_definition.equipment_slot == "weapon" and not is_two_handed_weapon:
				continue
		eligible_items.append(item_definition)
	return eligible_items
