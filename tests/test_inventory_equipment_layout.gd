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
	var portrait := main_ui.find_child("HeroPortrait", true, false) as TextureRect
	var left_slots := main_ui.find_child("ArmorSlots", true, false) as VBoxContainer
	var right_slots := main_ui.find_child("WeaponAndJewelrySlots", true, false) as VBoxContainer
	if portrait_panel == null or portrait == null or left_slots == null or right_slots == null:
		fail_test("Inventory screen must contain the portrait and both equipment columns.")
		return

	assert(portrait_panel.size == Vector2(320.0, 580.0), "Portrait backing panel must fill the displayed 320x580 portrait area.")
	assert(portrait.texture != null, "Hero portrait texture must load.")
	assert(portrait.texture.get_width() == 441 and portrait.texture.get_height() == 800, "The supplied 441x800 source portrait must remain unchanged.")
	assert(left_slots.get_child_count() == 5, "Armor side must contain five empty slots.")
	assert(right_slots.get_child_count() == 5, "Weapon and jewelry side must contain five empty slots.")
	assert(is_equal_approx(left_slots.size.y, portrait_panel.size.y), "Armor column height must match the portrait.")
	assert(is_equal_approx(right_slots.size.y, portrait_panel.size.y), "Weapon and jewelry column height must match the portrait.")
	for slot in left_slots.get_children() + right_slots.get_children():
		assert(slot.size == Vector2(108.0, 108.0), "Every equipment placeholder must be a 108x108 square.")

	main_ui.free()
	print("PASS: Inventory equipment layout matches the scaled hero portrait.")
	quit()
