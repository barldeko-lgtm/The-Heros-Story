extends SceneTree

const ItemGeneratorScript = preload("res://scripts/items/item_generator.gd")
const ItemPriceCalculatorScript = preload("res://scripts/economy/item_price_calculator.gd")
const LootGeneratorScript = preload("res://scripts/loot/loot_generator.gd")
const SimulationScript = preload("res://scripts/core/simulation.gd")
const HeroStateScript = preload("res://scripts/hero/hero_state.gd")
const EquipmentEvaluatorScript = preload("res://scripts/hero/equipment_evaluator.gd")
const ShopSystemScript = preload("res://scripts/economy/shop_system.gd")
const RareSword20 = preload("res://data/items/visual_families/crimson_thornplate/crimson_thornplate_sword_rare.tres")
const RareShield20 = preload("res://data/items/visual_families/crimson_thornplate/crimson_thornplate_shield_rare.tres")
const CommonGreatsword20 = preload("res://data/items/visual_families/crimson_thornplate/crimson_thornplate_greatsword.tres")
const UncommonGreatsword20 = preload("res://data/items/visual_families/crimson_thornplate/crimson_thornplate_greatsword_uncommon.tres")
const RareGreatsword20 = preload("res://data/items/visual_families/crimson_thornplate/crimson_thornplate_greatsword_rare.tres")
const CommonGreatsword25 = preload("res://data/items/visual_families/gilded_wyrm/gilded_wyrm_greatsword.tres")
const UncommonGreatsword25 = preload("res://data/items/visual_families/gilded_wyrm/gilded_wyrm_greatsword_uncommon.tres")
const RareGreatsword25 = preload("res://data/items/visual_families/gilded_wyrm/gilded_wyrm_greatsword_rare.tres")
const ArdenIlvl20Band = preload("res://data/shops/bands/arden_ilvl20.tres")
const ArdenIlvl25Band = preload("res://data/shops/bands/arden_ilvl25.tres")
const CrimsonDropSource = preload("res://data/loot/crimson_thornplate_ilvl20_drop_table.tres")
const GildedDropSource = preload("res://data/loot/gilded_wyrm_ilvl25_drop_table.tres")

class FixedRng:
	func randf() -> float:
		return 0.5
	func randi_range(from: int, _to: int) -> int:
		return from

class LastSlotRng:
	var float_values: Array[float]

	func _init(initial_float_values: Array[float]) -> void:
		float_values = initial_float_values.duplicate()

	func randf() -> float:
		return float_values.pop_front()

	func randi_range(_from: int, to: int) -> int:
		return to

class MobFixture extends Resource:
	var equipment_drop_table: Resource

class DungeonFixture extends Resource:
	var completion_equipment_source: Resource
	var completion_epic_chance: float = 0.25

func _init() -> void:
	var generator = ItemGeneratorScript.new()
	var sword20 = generator.generate(RareSword20, 20, FixedRng.new(), 2)
	var shield20 = generator.generate(RareShield20, 20, FixedRng.new(), 2)
	var greatsword20 = generator.generate(RareGreatsword20, 20, FixedRng.new(), 2)
	var greatsword25 = generator.generate(RareGreatsword25, 25, FixedRng.new(), 2)

	assert(greatsword20 != null and greatsword20.get_base_stat("attack") == 60.0, "ilvl20 two-hander must have +60 base Attack.")
	assert(is_zero_approx(greatsword20.get_base_stat("attack_speed")), "Two-handers must have no base Attack-Speed bonus.")
	assert(greatsword25 != null and greatsword25.get_base_stat("attack") == 80.0, "ilvl25 two-hander must have +80 base Attack.")
	assert(RareGreatsword20.icon_texture.resource_path == "res://assets/items/icons/crimson_thornplate/crimson_thornplate_greatsword.png", "ilvl20 two-hander must use its supplied icon.")
	assert(RareGreatsword25.icon_texture.resource_path == "res://assets/items/icons/gilded_wyrm/gilded_wyrm_greatsword.png", "ilvl25 two-hander must use its supplied icon.")
	assert(RareGreatsword20.hero_overlay_texture == null and RareGreatsword25.hero_overlay_texture == null, "Slayer two-handers must remain icon-only.")
	assert(greatsword20.affixes.size() == 2, "Rare two-hander must keep the normal two-affix Rare count.")
	assert(is_equal_approx(greatsword20.rolled_total_modifier_budget, sword20.rolled_total_modifier_budget * 2.0), "Two-hander modifier budget must be exactly doubled at the same ilvl/rarity and roll factor.")
	assert_price_matrix(generator)

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

	assert_shop_filtering(generator)
	assert_drop_filtering()
	assert_buffered_quest_drop_filtering()

	print("PASS: ilvl20/25 Slayer two-handers use approved stats, prices, icons, hand configuration, and pre-roll Slayer-only shop/mob/dungeon gating.")
	quit()

func contains_definition_id(definitions: Array, definition_id: String) -> bool:
	for definition in definitions:
		if definition != null and definition.id == definition_id:
			return true
	return false

func assert_price_matrix(generator) -> void:
	var price_calculator = ItemPriceCalculatorScript.new()
	var definitions := [CommonGreatsword20, UncommonGreatsword20, RareGreatsword20, CommonGreatsword25, UncommonGreatsword25, RareGreatsword25]
	var levels := [20, 20, 20, 25, 25, 25]
	var rarities := [0, 1, 2, 0, 1, 2]
	var prices := [4350, 13050, 39150, 6850, 20550, 61650]
	var sell_prices := [435, 1305, 3915, 685, 2055, 6165]
	for index in definitions.size():
		var item = generator.generate(definitions[index], levels[index], FixedRng.new(), rarities[index])
		assert(item != null and price_calculator.get_reference_shop_value_for_item(item) == prices[index], "Each Slayer two-hander rarity must use its approved approximately 1.9x price rounded to 50 Gold.")
		assert(price_calculator.get_sell_price_for_item(item) == sell_prices[index], "Slayer two-hander resale must remain exactly 10 percent of its approved reference price.")

func assert_shop_filtering(generator) -> void:
	var shop = ShopSystemScript.new(null, generator, 1)
	for band_and_ids in [
		[ArdenIlvl20Band, "crimson_thornplate_greatsword", "crimson_thornplate_greatsword_uncommon"],
		[ArdenIlvl25Band, "gilded_wyrm_greatsword", "gilded_wyrm_greatsword_uncommon"],
	]:
		var band = band_and_ids[0]
		for rarity in [0, 1]:
			var expected_id: String = band_and_ids[rarity + 1]
			assert(not contains_definition_id(shop.get_definitions_for_rarity(band, rarity, "warrior"), expected_id), "Warrior/Protector shop generation must exclude Slayer-only two-handers.")
			assert(contains_definition_id(shop.get_definitions_for_rarity(band, rarity, "slayer"), expected_id), "An actually granted Slayer must be eligible for ilvl20/25 two-handers in Arden shops.")

func assert_drop_filtering() -> void:
	var loot_generator = LootGeneratorScript.new()
	for source_and_id in [
		[CrimsonDropSource, "crimson_thornplate_greatsword", "crimson_thornplate_greatsword_rare"],
		[GildedDropSource, "gilded_wyrm_greatsword", "gilded_wyrm_greatsword_rare"],
	]:
		var source = source_and_id[0]
		for pool in [source.common_items, source.uncommon_items, source.rare_items]:
			var slayer_items: Array[Resource] = loot_generator.get_eligible_items(pool, "slayer")
			assert(slayer_items.size() == 6, "Slayer drop pools must contain five armor pieces plus one two-hander.")
			for definition in slayer_items:
				assert(definition.equipment_slot != "shield", "Slayer drop pools must exclude shields.")
				assert(definition.equipment_slot != "weapon" or definition.is_two_handed_weapon(), "Slayer drop pools must exclude one-handed weapons.")

			var protector_items: Array[Resource] = loot_generator.get_eligible_items(pool, "protector")
			assert(protector_items.size() == 7, "Protector drop pools must retain five armor pieces, one-handed weapon, and shield.")
			for definition in protector_items:
				assert(not definition.is_two_handed_weapon(), "Protector drop pools must exclude Slayer two-handers.")
		var mob := MobFixture.new()
		mob.equipment_drop_table = source
		var warrior_drop = loot_generator.roll_mob_equipment(mob, LastSlotRng.new([0.0, 0.0]), "warrior")
		var slayer_drop = loot_generator.roll_mob_equipment(mob, LastSlotRng.new([0.0, 0.0]), "slayer")
		assert(warrior_drop != null and not warrior_drop.is_two_handed_weapon(), "A non-Slayer mob drop roll must exclude class-restricted two-handers before slot selection.")
		assert(slayer_drop != null and slayer_drop.id == source_and_id[1], "A Slayer mob drop roll must include the level-appropriate two-hander.")

		var dungeon := DungeonFixture.new()
		dungeon.completion_equipment_source = source
		var warrior_reward: Dictionary = loot_generator.roll_dungeon_completion_equipment(dungeon, LastSlotRng.new([0.5]), "warrior")
		var slayer_reward: Dictionary = loot_generator.roll_dungeon_completion_equipment(dungeon, LastSlotRng.new([0.5]), "slayer")
		assert(not warrior_reward.is_empty() and not warrior_reward.item_definition.is_two_handed_weapon(), "A non-Slayer dungeon reward must remain guaranteed while excluding two-handers.")
		assert(not slayer_reward.is_empty() and slayer_reward.item_definition.id == source_and_id[2], "A Slayer ordinary-dungeon reward must include the level-appropriate two-hander.")

func assert_buffered_quest_drop_filtering() -> void:
	var mob: Resource = load("res://data/mobs/mid_region/0110_fire_salamander.tres")
	var warrior_simulation = SimulationScript.new(4101, null)
	warrior_simulation.hero_state.hero_class_id = "warrior"
	var warrior_drop: Dictionary = warrior_simulation.collect_mob_equipment_drop(mob, LastSlotRng.new([0.0, 0.0]))
	assert(warrior_drop.item_definition != null and not warrior_drop.item_definition.is_two_handed_weapon(), "Buffered ordinary quest drops must exclude Slayer weapons before the class is granted.")

	var slayer_simulation = SimulationScript.new(4102, null)
	slayer_simulation.hero_state.hero_class_id = "slayer"
	var slayer_drop: Dictionary = slayer_simulation.collect_mob_equipment_drop(mob, LastSlotRng.new([0.0, 0.0]))
	assert(slayer_drop.item_definition != null and slayer_drop.item_definition.id == "crimson_thornplate_greatsword", "Buffered ordinary quest drops must receive the granted Slayer class before slot selection.")
