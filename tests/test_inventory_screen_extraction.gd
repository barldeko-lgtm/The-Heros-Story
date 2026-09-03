extends SceneTree

const INVENTORY_SCENE_PATH := "res://scenes/ui/screens/inventory_screen.tscn"
const INVENTORY_SCRIPT_PATH := "res://scripts/ui/screens/inventory_screen.gd"

func _init() -> void:
	call_deferred("run_test")

func fail_test(message: String) -> void:
	push_error(message)
	quit(1)

func run_test() -> void:
	if not ResourceLoader.exists(INVENTORY_SCENE_PATH):
		fail_test("Inventory screen must be extracted into its target scene.")
		return
	if not ResourceLoader.exists(INVENTORY_SCRIPT_PATH):
		fail_test("Inventory screen must have its own target script.")
		return

	var main_ui_script: Script = load("res://scripts/ui/main_ui.gd")
	if main_ui_script == null:
		fail_test("Main UI must still load after InventoryScreen extraction.")
		return
	var main_ui = main_ui_script.new()
	get_root().add_child(main_ui)
	await process_frame

	var inventory_screen := main_ui.inventory_screen as Control
	if inventory_screen == null:
		fail_test("MainUI must instantiate and expose InventoryScreen.")
		return
	assert(inventory_screen.get_script().resource_path == INVENTORY_SCRIPT_PATH, "InventoryScreen must own its extracted presentation script.")
	assert(not inventory_screen.visible, "InventoryScreen must remain hidden at startup.")
	assert(inventory_screen.find_child("HeroPortraitPanel", true, false) != null, "Extracted InventoryScreen must retain the hero paper doll.")
	assert(inventory_screen.find_child("InventorySlots", true, false) != null, "Extracted InventoryScreen must retain the 6x6 item grid.")
	assert(inventory_screen.find_child("ItemTooltipPanel", true, false) != null, "Extracted InventoryScreen must retain the shared tooltip.")
	assert(inventory_screen.find_child("HeroHelmetOverlay", true, false) != null, "Extracted InventoryScreen must retain armor overlay nodes.")

	var portrait_panel := inventory_screen.find_child("HeroPortraitPanel", true, false) as PanelContainer
	var armor_slots := inventory_screen.find_child("ArmorSlots", true, false) as VBoxContainer
	var weapon_slots := inventory_screen.find_child("WeaponSlots", true, false) as HBoxContainer
	var jewelry_slots := inventory_screen.find_child("JewelrySlots", true, false) as VBoxContainer
	var inventory_slots := inventory_screen.find_child("InventorySlots", true, false) as GridContainer
	assert(portrait_panel.position == Vector2(134.4, 148.0) and portrait_panel.size == Vector2(256.0, 464.0), "Extracted hero portrait geometry must remain unchanged.")
	assert(armor_slots.position == Vector2(32.0, 148.0), "Extracted armor-column position must remain unchanged.")
	assert(weapon_slots.position == Vector2(172.4, 620.0), "Extracted weapon-row position must remain unchanged.")
	assert(jewelry_slots.position == Vector2(406.4, 148.0), "Extracted jewelry-column position must remain unchanged.")
	assert(inventory_slots.position == Vector2(680.0, 138.0) and inventory_slots.columns == 6 and inventory_slots.get_child_count() == 36, "Extracted inventory grid geometry must remain unchanged.")

	main_ui.inventory_button.pressed.emit()
	assert(inventory_screen.visible and not main_ui.main_screen.visible, "MainUI navigation must still open the extracted InventoryScreen.")

	var chest_definition: Resource = load("res://data/items/visual_families/ironwake_sentinel/ironwake_sentinel_chestplate.tres")
	assert(chest_definition != null, "Focused inventory item must load.")
	main_ui.simulation.receive_item_reward(chest_definition, 1)
	inventory_screen.refresh()
	var chest_icon := inventory_screen.find_child("ChestEquipmentIcon", true, false) as TextureRect
	var chest_overlay := inventory_screen.find_child("HeroChestOverlay", true, false) as TextureRect
	var chest_slot := inventory_screen.find_child("ChestSlot", true, false) as PanelContainer
	var tooltip_panel := inventory_screen.find_child("ItemTooltipPanel", true, false) as PanelContainer
	assert(chest_icon != null and chest_icon.visible and chest_icon.texture == chest_definition.icon_texture, "Extracted InventoryScreen must refresh equipped icons.")
	assert(chest_overlay != null and chest_overlay.visible and chest_overlay.texture == chest_definition.hero_overlay_texture, "Extracted InventoryScreen must refresh paper-doll overlays.")
	chest_slot.mouse_entered.emit()
	await process_frame
	assert(tooltip_panel.visible, "Extracted InventoryScreen must retain equipped-item hover tooltips.")

	main_ui.inventory_close_button.pressed.emit()
	assert(not inventory_screen.visible and main_ui.main_screen.visible, "MainUI navigation must still close the extracted InventoryScreen.")
	await process_frame

	main_ui.free()
	print("PASS: MainUI delegates inventory presentation to the extracted InventoryScreen without changing navigation contracts.")
	quit()
