extends SceneTree

func _init() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var main_ui_script: Script = load("res://scripts/ui/main_ui.gd")
	assert(main_ui_script != null, "Main UI script must load.")
	var main_ui = main_ui_script.new()
	get_root().add_child(main_ui)
	await process_frame
	main_ui.inventory_button.pressed.emit()
	await process_frame

	var armor_slots := main_ui.find_child("ArmorSlots", true, false) as VBoxContainer
	var portrait_panel := main_ui.find_child("HeroPortraitPanel", true, false) as PanelContainer
	var weapon_slots := main_ui.find_child("WeaponSlots", true, false) as HBoxContainer
	var jewelry_slots := main_ui.find_child("JewelrySlots", true, false) as VBoxContainer
	assert(armor_slots != null and portrait_panel != null and weapon_slots != null and jewelry_slots != null, "Inventory must have separate armor, portrait, weapon, and jewelry blocks.")

	assert(armor_slots.position == Vector2(32.0, 148.0), "Armor must remain left of the hero.")
	assert(portrait_panel.position == Vector2(134.4, 148.0), "Hero portrait must keep its current position.")
	assert(weapon_slots.position == Vector2(172.4, 620.0), "Weapon slots must be centered directly below the hero portrait.")
	assert(jewelry_slots.position == Vector2(406.4, 148.0), "Jewelry must occupy the column right of the hero.")

	assert(weapon_slots.get_child_count() == 2, "Weapon row must contain main-hand and off-hand slots.")
	assert(weapon_slots.get_child(0).name == "WeaponSlot1", "Main-hand must be the left weapon slot.")
	assert(weapon_slots.get_child(1).name == "WeaponSlot2", "Off-hand must be the right weapon slot.")
	assert(weapon_slots.get_child(0).position.x < weapon_slots.get_child(1).position.x, "Main-hand must render left of off-hand.")

	var jewelry_order := ["NecklaceSlot", "EarringsSlot", "RingSlot1", "RingSlot2", "BeltSlot"]
	assert(jewelry_slots.get_child_count() == jewelry_order.size(), "Jewelry column must contain necklace, earrings, two rings, and belt.")
	for index in jewelry_order.size():
		assert(jewelry_slots.get_child(index).name == jewelry_order[index], "Jewelry slots must follow the approved top-to-bottom order.")

	var all_slots: Array = armor_slots.get_children() + weapon_slots.get_children() + jewelry_slots.get_children()
	assert(all_slots.size() == 12, "Equipment screen must contain twelve slots in total.")
	for slot in all_slots:
		assert(slot.size == Vector2(86.0, 86.0), "Every equipment slot must remain 86x86 pixels.")

	assert(main_ui.get_equipment_slot_id("NecklaceSlot") == "necklace", "Necklace slot must have a stable equipment id.")
	assert(main_ui.get_equipment_slot_id("EarringsSlot") == "earrings", "Earrings slot must have a stable equipment id.")
	assert(main_ui.get_equipment_slot_id("RingSlot1") == "ring_1", "First ring slot must have a stable equipment id.")
	assert(main_ui.get_equipment_slot_id("RingSlot2") == "ring_2", "Second ring slot must have a stable equipment id.")
	assert(main_ui.get_equipment_slot_id("BeltSlot") == "belt", "Belt slot must have a stable equipment id.")

	main_ui.free()
	print("PASS: Equipment screen uses the approved 5 armor + 2 weapon + 5 jewelry layout.")
	quit()
