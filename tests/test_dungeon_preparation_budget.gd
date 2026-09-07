extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const POLICY_PATH := "res://scripts/economy/dungeon_preparation_budget.gd"
var failures: int = 0

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + message)

func _init() -> void:
	if not FileAccess.file_exists(POLICY_PATH):
		printerr("FAIL: dungeon preparation budget policy has not been extracted")
		quit(1)
		return
	var simulation = SimulationScript.new(9104, null)
	var policy = load(POLICY_PATH).new()
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var common = load("res://data/items/visual_families/ironward_vanguard/ironward_belt.tres")
	var uncommon = load("res://data/items/visual_families/ironward_vanguard/ironward_belt_uncommon.tres")
	var belt = simulation.item_generator.generate(common, 5, rng)
	var upgrade = simulation.item_generator.generate(uncommon, 5, rng)
	simulation.hero_state.equipment.replace_item(belt)
	simulation.refresh_combat_stats()
	simulation.shop_system.listings = [{"item_instance": upgrade}]
	var price: int = simulation.shop_system.item_price_calculator.get_reference_shop_value_for_item(upgrade)
	simulation.hero_state.gold = price + 100
	check(simulation.get_equipment_purchase_gold_budget() == price + 100, "Unknown dungeons must not reserve Gold")
	check(simulation.get_equipment_purchase_listings_with_dungeon_prep_safety()[0]["item_instance"] == upgrade, "Unknown dungeons must not block Belt shopping")
	var dungeon = simulation.dungeon_system.get_all_dungeons()[0]
	dungeon.discover("test")
	check(simulation.get_ready_dungeon_potion_plan().get("dungeon") == dungeon, "Plan must preserve the real dungeon context")
	check(simulation.get_equipment_purchase_gold_budget() == price, "Reserve the current Belt's missing potion cost")
	check(simulation.get_equipment_purchase_listings_with_dungeon_prep_safety()[0]["item_instance"] == null, "Reject a Belt leaving insufficient Gold for its new capacity")
	simulation.hero_state.gold = price + 200
	check(simulation.get_equipment_purchase_listings_with_dungeon_prep_safety()[0]["item_instance"] == upgrade, "Allow exact full-loadout affordability")
	simulation.hero_state.gold = price + 199
	check(simulation.get_equipment_purchase_listings_with_dungeon_prep_safety()[0]["item_instance"] == null, "Reject one Gold below full-loadout affordability")
	simulation.hero_state.inventory.add_healing_potion(5, 2)
	simulation.hero_state.gold = price
	check(simulation.get_equipment_purchase_gold_budget() == price, "Owned potions must not reserve a second purchase")
	check(simulation.get_equipment_purchase_listings_with_dungeon_prep_safety()[0]["item_instance"] == upgrade, "Owned potions count toward a candidate Belt loadout")
	check(simulation.hero_state.equipment.get_item("belt") == belt, "Evaluation must not equip the candidate")
	check(simulation.shop_system.get_listings()[0]["item_instance"] == upgrade, "Filtering must not mutate real shop stock")
	check(simulation.hero_state.gold == price and simulation.hero_state.inventory.get_healing_potion_count(5) == 2, "Evaluation must not spend Gold or consume potions")
	check(simulation.hero_state.prepared_healing_potion_levels.is_empty(), "Budget evaluation must not prepare slots")
	check(simulation.world_clock.world_tick == 0, "Budget evaluation must not advance time")
	check(policy.get_equipment_gold_budget(90, {}) == 90, "No plan means no reserve")
	check(policy.get_equipment_gold_budget(90, {"can_prepare": false, "purchase_cost": 100}) == 90, "An impossible plan preserves existing budget behaviour")
	dungeon.record_failed_attempt(simulation.get_hero_power() * 10.0, 0, false)
	check(simulation.get_ready_dungeon_potion_plan().is_empty(), "Power-blocked dungeon must not create a preparation plan")
	if failures == 0:
		print("PASS: extracted dungeon preparation budget preserves affordability, owned potions, context and read-only evaluation")
	quit(0 if failures == 0 else 1)
