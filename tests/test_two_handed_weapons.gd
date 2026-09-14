extends SceneTree

const ItemGeneratorScript = preload("res://scripts/items/item_generator.gd")
const HeroStateScript = preload("res://scripts/hero/hero_state.gd")
const EquipmentEvaluatorScript = preload("res://scripts/hero/equipment_evaluator.gd")
const ShopSystemScript = preload("res://scripts/economy/shop_system.gd")
const RareSword20 = preload("res://data/items/visual_families/crimson_thornplate/crimson_thornplate_sword_rare.tres")
const RareShield20 = preload("res://data/items/visual_families/crimson_thornplate/crimson_thornplate_shield_rare.tres")
const RareGreatsword20 = preload("res://data/items/visual_families/crimson_thornplate/crimson_thornplate_greatsword_rare.tres")
const RareGreatsword25 = preload("res://data/items/visual_families/gilded_wyrm/gilded_wyrm_greatsword_rare.tres")
const ArdenIlvl25Band = preload("res://data/shops/bands/arden_ilvl25.tres")

class FixedRng:
	func randf() -> float:
		return 0.5
	func randi_range(from: int, _to: int) -> int:
		return from

func _init() -> void:
	var generator = ItemGeneratorScript.new()
	var sword20 = generator.generate(RareSword20, 20, FixedRng.new(), 2)
	var shield20 = generator.generate(RareShield20, 20, FixedRng.new(), 2)
	var greatsword20 = generator.generate(RareGreatsword20, 20, FixedRng.new(), 2)
	var greatsword25 = generator.generate(RareGreatsword25, 25, FixedRng.new(), 2)

	assert(greatsword20 != null and greatsword20.get_base_stat("attack") == 60.0, "ilvl20 two-hander must have +60 base Attack.")
	assert(is_zero_approx(greatsword20.get_base_stat("attack_speed")), "Two-handers must have no base Attack-Speed bonus.")
	assert(greatsword25 != null and greatsword25.get_base_stat("attack") == 80.0, "ilvl25 two-hander must have +80 base Attack.")
	assert(greatsword20.affixes.size() == 2, "Rare two-hander must keep the normal two-affix Rare count.")
	assert(is_equal_approx(greatsword20.rolled_total_modifier_budget, sword20.rolled_total_modifier_budget * 2.0), "Two-hander modifier budget must be exactly doubled at the same ilvl/rarity and roll factor.")

	var hero = HeroStateScript.new("Slayer")
	hero.hero_class_id = "slayer"
	hero.equipment.replace_item_configuration(sword20)
	hero.equipment.replace_item_configuration(shield20)
	var displaced: Array = hero.equipment.replace_item_configuration(greatsword20)
	assert(displaced.size() == 2 and displaced.has(sword20) and displaced.has(shield20), "Equipping a two-hander must displace both one-handed weapon and shield.")
	assert(hero.equipment.get_item("weapon") == greatsword20 and hero.equipment.get_item("shield") == null, "Two-hander must occupy the hand configuration with no shield equipped.")

	displaced = hero.equipment.replace_item_configuration(shield20)
	assert(displaced.size() == 1 and displaced[0] == greatsword20, "Equipping a shield while using a two-hander must displace that two-hander.")
	assert(hero.equipment.get_item("weapon") == null and hero.equipment.get_item("shield") == shield20, "Shield replacement must leave no two-handed weapon equipped.")

	var warrior = HeroStateScript.new("Warrior")
	var evaluator = EquipmentEvaluatorScript.new()
	var evaluation: Dictionary = evaluator.evaluate(warrior, greatsword20)
	assert(not bool(evaluation.get("should_equip", false)) and str(evaluation.get("comparison_mode", "")) == "class_restricted", "Slayer two-handers must not be equippable before the Slayer class is actually granted.")

	var shop = ShopSystemScript.new(null, generator, 1)
	var warrior_white: Array = shop.get_definitions_for_rarity(ArdenIlvl25Band, 0, "warrior")
	var slayer_white: Array = shop.get_definitions_for_rarity(ArdenIlvl25Band, 0, "slayer")
	assert(not contains_definition_id(warrior_white, "gilded_wyrm_greatsword"), "Warrior/Protector shop generation must filter out Slayer-only ilvl25 two-handers.")
	assert(contains_definition_id(slayer_white, "gilded_wyrm_greatsword"), "An actually granted Slayer must be eligible to see the ilvl25 two-hander in Arden shop generation.")

	print("PASS: ilvl20/25 Slayer two-handers use 60/80 base Attack, no base speed, doubled two-affix budget and a real two-handed equipment configuration.")
	quit()

func contains_definition_id(definitions: Array, definition_id: String) -> bool:
	for definition in definitions:
		if definition != null and definition.id == definition_id:
			return true
	return false
