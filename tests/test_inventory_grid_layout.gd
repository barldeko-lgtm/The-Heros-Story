extends SceneTree

func _init() -> void:
	call_deferred("run_test")

func fail_test(message: String) -> void:
	push_error(message)
	quit(1)

func run_test() -> void:
	var main_ui_script: Script = load("res://scripts/ui/main_ui.gd")
	if main_ui_script == null:
		fail_test("Main UI script must exist.")
		return
	var main_ui = main_ui_script.new()
	get_root().add_child(main_ui)
	await process_frame
	main_ui.inventory_button.pressed.emit()
	await process_frame

	var portrait_panel := main_ui.find_child("HeroPortraitPanel", true, false) as PanelContainer
	var armor_slots := main_ui.find_child("ArmorSlots", true, false) as VBoxContainer
	var weapon_slots := main_ui.find_child("WeaponSlots", true, false) as HBoxContainer
	var jewelry_slots := main_ui.find_child("JewelrySlots", true, false) as VBoxContainer
	var inventory_title := main_ui.find_child("InventoryTitle", true, false) as Label
	var inventory_slots := main_ui.find_child("InventorySlots", true, false) as GridContainer
	if portrait_panel == null or armor_slots == null or weapon_slots == null or jewelry_slots == null or inventory_title == null or inventory_slots == null:
		fail_test("Inventory screen must contain the scaled equipment layout and inventory grid.")
		return

	assert(portrait_panel.size == Vector2(256.0, 464.0), "Hero display must be reduced by exactly 20 percent.")
	assert(armor_slots.size == Vector2(86.0, 464.0), "Armor column must scale with the hero display using whole UI pixels.")
	assert(weapon_slots.size == Vector2(180.0, 86.0), "Two weapon slots must fit below the hero display.")
	assert(jewelry_slots.size == Vector2(86.0, 464.0), "Jewelry column must scale with the hero display using whole UI pixels.")
	for slot in armor_slots.get_children() + weapon_slots.get_children() + jewelry_slots.get_children():
		assert(slot.size == Vector2(86.0, 86.0), "Equipment slots must use the nearest whole-pixel size to a 20 percent reduction.")

	assert(inventory_title.text == "Инвентарь", "Inventory grid must have its title.")
	assert(inventory_slots.columns == 6, "Inventory grid must contain six columns.")
	assert(inventory_slots.get_child_count() == 36, "Inventory grid must contain 6x6 empty slots.")
	for slot in inventory_slots.get_children():
		assert(slot.size == Vector2(82.0, 82.0), "Every inventory placeholder must be an 82x82 square.")

	main_ui.free()
	print("PASS: Inventory screen has scaled equipment and a 6x6 placeholder grid.")
	quit()
