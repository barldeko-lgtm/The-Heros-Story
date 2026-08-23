extends SceneTree

const COMMON_PATH := "res://data/items/boar_chestplate.tres"
const UNCOMMON_PATH := "res://data/items/boar_chestplate_uncommon.tres"
const RARE_PATH := "res://data/items/boar_chestplate_rare.tres"

func _init() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	var main_ui_script: Script = load("res://scripts/ui/main_ui.gd")
	var common: Resource = load(COMMON_PATH)
	var uncommon: Resource = load(UNCOMMON_PATH)
	var rare: Resource = load(RARE_PATH)
	assert(simulation_script != null and main_ui_script != null and common != null and uncommon != null and rare != null, "Quality visual dependencies must load.")

	var simulation = simulation_script.new(1)
	simulation.receive_item_reward(rare, 1)
	simulation.receive_item_reward(uncommon, 2)
	simulation.receive_item_reward(common, 3)
	var main_ui = main_ui_script.new()
	main_ui.simulation = simulation
	get_root().add_child(main_ui)
	await process_frame
	main_ui.inventory_button.pressed.emit()
	await process_frame

	var equipped_icon := main_ui.find_child("ChestEquipmentIcon", true, false) as TextureRect
	var uncommon_icon := main_ui.find_child("InventoryItemIcon01", true, false) as TextureRect
	var common_icon := main_ui.find_child("InventoryItemIcon02", true, false) as TextureRect
	assert(equipped_icon != null and uncommon_icon != null and common_icon != null, "Equipped and inventory item icons must exist.")
	assert(equipped_icon.material is ShaderMaterial, "Rare equipped item must use an outline shader.")
	assert(uncommon_icon.material is ShaderMaterial, "Uncommon inventory item must use an outline shader.")
	assert(common_icon.material == null, "Common item must have no quality outline.")

	var rare_material := equipped_icon.material as ShaderMaterial
	var uncommon_material := uncommon_icon.material as ShaderMaterial
	assert((rare_material.get_shader_parameter("outline_color") as Color).is_equal_approx(Color("4f8dff")), "Rare outline must be blue.")
	assert((uncommon_material.get_shader_parameter("outline_color") as Color).is_equal_approx(Color("55c96f")), "Uncommon outline must be green.")
	assert(is_equal_approx(float(rare_material.get_shader_parameter("middle_alpha")), 0.55), "Second outline pixel must be partially transparent.")
	assert(is_equal_approx(float(rare_material.get_shader_parameter("outer_alpha")), 0.25), "Third outline pixel must be more transparent.")

	var chest_slot := main_ui.find_child("ChestSlot", true, false) as PanelContainer
	var first_inventory_slot := main_ui.find_child("InventorySlot01", true, false) as PanelContainer
	var tooltip_panel := main_ui.find_child("ItemTooltipPanel", true, false) as PanelContainer
	var tooltip_label := main_ui.find_child("ItemTooltipLabel", true, false) as Label
	chest_slot.mouse_entered.emit()
	await process_frame
	assert(tooltip_panel.visible and tooltip_label.text.contains("Редкое"), "Equipped rare tooltip must show quality.")
	chest_slot.mouse_exited.emit()
	first_inventory_slot.mouse_entered.emit()
	await process_frame
	assert(tooltip_panel.visible and tooltip_label.text.contains("Необычное"), "Inventory tooltip must show uncommon quality.")

	main_ui.free()
	print("PASS: Common, uncommon, and rare items display correct soft quality outlines and tooltips.")
	quit()
