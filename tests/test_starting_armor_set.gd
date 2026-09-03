extends SceneTree

const STARTING_ITEMS := {
	"chest": "res://data/items/starting_equipment/worn_shirt.tres",
	"pants": "res://data/items/starting_equipment/worn_pants.tres",
	"boots": "res://data/items/starting_equipment/worn_boots.tres",
}
const ICON_NODES := {
	"chest": "ChestEquipmentIcon",
	"pants": "PantsEquipmentIcon",
	"boots": "BootsEquipmentIcon",
}
const OVERLAY_NODES := {
	"chest": "HeroChestOverlay",
	"pants": "HeroPantsOverlay",
	"boots": "HeroBootsOverlay",
}

func _init() -> void:
	call_deferred("run_test")

func require(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error(message)
	quit(1)
	return false

func run_test() -> void:
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	var main_ui_script: Script = load("res://scripts/ui/main_ui.gd")
	var price_calculator_script: Script = load("res://scripts/economy/item_price_calculator.gd")
	if not require(simulation_script != null and main_ui_script != null and price_calculator_script != null, "Starting-equipment test requires the live Simulation, UI, and price calculator."):
		return

	var definitions: Dictionary = {}
	for slot_id in STARTING_ITEMS:
		var definition: Resource = load(STARTING_ITEMS[slot_id])
		if not require(definition != null, "Starting armor definition must load for slot %s." % slot_id):
			return
		definitions[slot_id] = definition
		if not require(definition.equipment_slot == slot_id, "Starting armor must use its intended equipment slot: %s." % slot_id):
			return
		if not require(definition.quality == 0, "Every starting armor piece must be Common/White."):
			return
		if not require(definition.icon_texture != null and definition.icon_texture.get_size() == Vector2(300, 300), "Every starting armor icon must preserve its supplied 300x300 canvas."):
			return
		if not require(definition.hero_overlay_texture != null and definition.hero_overlay_texture.get_size() == Vector2(441, 800), "Every starting armor overlay must preserve its supplied 441x800 hero canvas."):
			return

	var simulation = simulation_script.new(1)
	for slot_id in STARTING_ITEMS:
		var item = simulation.hero_state.equipment.get_item(slot_id)
		if not require(item != null and item.definition == definitions[slot_id], "A new hero must start with the approved armor equipped in %s." % slot_id):
			return
		if not require(item.item_level == 1 and item.rarity == 0 and item.affixes.is_empty(), "Starting armor must be fixed Common ilvl 1 gear without random affixes."):
			return
		if not require(is_equal_approx(item.get_stat_bonus("armor"), 1.0), "Each starting armor piece must grant exactly +1 Armor."):
			return
		if not require(price_calculator_script.new().get_sell_price_for_item(item) == 1, "Each starting armor piece must sell for exactly 1 Gold."):
			return
		if not require(item.get_tooltip_text().contains("Цена продажи: 1"), "Starting armor tooltip must show its 1 Gold sell price."):
			return
	if not require(is_equal_approx(simulation.hero_state.equipment.get_armor_bonus(), 3.0), "The full three-piece starting set must grant +3 Armor total."):
		return
	if not require(is_equal_approx(simulation.base_combat_stats.armor, 8.0), "Starting Constitution 5 plus the three pieces must resolve to 8 Armor."):
		return

	var main_ui = main_ui_script.new()
	main_ui.simulation = simulation
	get_root().add_child(main_ui)
	await process_frame
	main_ui.inventory_button.pressed.emit()
	await process_frame
	for slot_id in STARTING_ITEMS:
		var icon := main_ui.find_child(ICON_NODES[slot_id], true, false) as TextureRect
		var overlay := main_ui.find_child(OVERLAY_NODES[slot_id], true, false) as TextureRect
		if not require(icon != null and icon.visible and icon.texture == definitions[slot_id].icon_texture, "Inventory must display the equipped starting icon for %s." % slot_id):
			main_ui.free()
			return
		if not require(icon.material == null, "Common starting armor must not receive a rarity outline."):
			main_ui.free()
			return
		if not require(overlay != null and overlay.visible and overlay.texture == definitions[slot_id].hero_overlay_texture, "Paper doll must display the equipped starting overlay for %s." % slot_id):
			main_ui.free()
			return
	main_ui.free()

	var upgrade_result: Dictionary = simulation.receive_item_reward(load("res://data/items/visual_families/rustchain_initiate/rustchain_initiate_chestplate.tres"), 1, 1)
	if not require(bool(upgrade_result.get("equipped", false)), "A stronger found chest item must replace the worn starting shirt through normal equipment evaluation."):
		return
	if not require(simulation.hero_state.inventory.get_items().size() == 1 and simulation.hero_state.inventory.get_items()[0].definition == definitions["chest"], "The replaced starting shirt must enter Inventory normally."):
		return
	simulation.hero_state.loop_state = "VISITING_MARKET"
	var sale_result: Dictionary = simulation.advance_market_sale_tick(2)
	if not require(sale_result["sold_count"] == 1 and sale_result["gold_gained"] == 1, "The replaced starting shirt must sell for exactly 1 Gold on the normal market tick."):
		return

	print("PASS: New heroes wear three fixed +1 Armor pieces that render, upgrade normally, and sell for 1 Gold each.")
	quit()
