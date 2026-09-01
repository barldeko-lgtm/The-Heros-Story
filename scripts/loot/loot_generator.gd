class_name LootGenerator
extends RefCounted

const COMMON_CHANCE: float = 0.70
const UNCOMMON_CHANCE: float = 0.25
const RARE_CHANCE: float = 0.05
const RARITY_RARE: int = 2
const RARITY_EPIC: int = 3

func roll_mob_equipment(mob_definition: Resource, rng):
	if mob_definition == null or rng == null:
		return null
	var drop_table: Resource = mob_definition.equipment_drop_table
	if drop_table == null:
		return null

	var drop_chance: float = clampf(drop_table.drop_chance, 0.0, 1.0)
	if drop_chance <= 0.0 or rng.randf() >= drop_chance:
		return null

	var slot_count: int = mini(
		drop_table.common_items.size(),
		mini(drop_table.uncommon_items.size(), drop_table.rare_items.size())
	)
	if slot_count <= 0:
		return null

	var slot_index: int = rng.randi_range(0, slot_count - 1)
	var rarity_roll: float = rng.randf()
	var selected_pool: Array[Resource] = drop_table.common_items
	if rarity_roll >= COMMON_CHANCE + UNCOMMON_CHANCE:
		selected_pool = drop_table.rare_items
	elif rarity_roll >= COMMON_CHANCE:
		selected_pool = drop_table.uncommon_items
	return selected_pool[slot_index]

func roll_dungeon_completion_equipment(dungeon_definition: Resource, rng) -> Dictionary:
	if dungeon_definition == null or rng == null or dungeon_definition.completion_equipment_source == null:
		return {}
	var source: Resource = dungeon_definition.completion_equipment_source
	if source.rare_items.is_empty() or source.item_level <= 0:
		return {}
	var slot_index: int = rng.randi_range(0, source.rare_items.size() - 1)
	var epic_chance: float = clampf(dungeon_definition.completion_epic_chance, 0.0, 1.0)
	var rarity: int = RARITY_EPIC if rng.randf() < epic_chance else RARITY_RARE
	return {
		"item_definition": source.rare_items[slot_index],
		"item_level": int(source.item_level),
		"rarity": rarity,
	}
