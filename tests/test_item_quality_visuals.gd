extends SceneTree

const COMMON_PATH := "res://data/items/visual_families/ironward_vanguard/boar_chestplate.tres"
const UNCOMMON_PATH := "res://data/items/visual_families/ironward_vanguard/boar_chestplate_uncommon.tres"
const RARE_PATH := "res://data/items/visual_families/ironward_vanguard/boar_chestplate_rare.tres"

class ScriptedRng:
	var float_values: Array[float] = []
	var int_values: Array[int] = []

	func _init(initial_float_values: Array[float] = [], initial_int_values: Array[int] = []) -> void:
		float_values = initial_float_values.duplicate()
		int_values = initial_int_values.duplicate()

	func randf() -> float:
		assert(not float_values.is_empty(), "Scripted RNG ran out of float values.")
		return float_values.pop_front()

	func randi_range(from: int, to: int) -> int:
		assert(not int_values.is_empty(), "Scripted RNG ran out of integer values.")
		var value: int = int_values.pop_front()
		assert(value >= from and value <= to, "Scripted integer roll must stay inside the requested range.")
		return value

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
	simulation.receive_item_reward(rare, 1, 20, ScriptedRng.new([0.5], [0, 0, 0]), 3)
	simulation.receive_item_reward(rare, 2, 20, ScriptedRng.new([0.5], [0, 0]), 2)
	simulation.receive_item_reward(uncommon, 3, 20, ScriptedRng.new([0.5], [0]))
	simulation.receive_item_reward(common, 4, 20, ScriptedRng.new())
	var main_ui = main_ui_script.new()
	main_ui.simulation = simulation
	get_root().add_child(main_ui)
	await process_frame
	main_ui.inventory_button.pressed.emit()
	await process_frame

	var equipped_icon := main_ui.find_child("ChestEquipmentIcon", true, false) as TextureRect
	var rare_icon := main_ui.find_child("InventoryItemIcon01", true, false) as TextureRect
	var uncommon_icon := main_ui.find_child("InventoryItemIcon02", true, false) as TextureRect
	var common_icon := main_ui.find_child("InventoryItemIcon03", true, false) as TextureRect
	assert(equipped_icon != null and rare_icon != null and uncommon_icon != null and common_icon != null, "Equipped and inventory item icons must exist.")
	assert(equipped_icon.material is ShaderMaterial, "Epic equipped item must use an outline shader.")
	assert(rare_icon.material is ShaderMaterial, "Rare inventory item must use an outline shader.")
	assert(uncommon_icon.material is ShaderMaterial, "Uncommon inventory item must use an outline shader.")
	assert(common_icon.material == null, "Common item must have no quality outline.")

	var epic_material := equipped_icon.material as ShaderMaterial
	var rare_material := rare_icon.material as ShaderMaterial
	var uncommon_material := uncommon_icon.material as ShaderMaterial
	assert((epic_material.get_shader_parameter("outline_color") as Color).is_equal_approx(Color("a855f7")), "Epic outline must be purple.")
	assert((rare_material.get_shader_parameter("outline_color") as Color).is_equal_approx(Color("4f8dff")), "Rare outline must be blue.")
	assert((uncommon_material.get_shader_parameter("outline_color") as Color).is_equal_approx(Color("55c96f")), "Uncommon outline must be green.")
	assert(is_equal_approx(float(epic_material.get_shader_parameter("middle_alpha")), 0.55), "Second outline pixel must be partially transparent.")
	assert(is_equal_approx(float(epic_material.get_shader_parameter("outer_alpha")), 0.25), "Third outline pixel must be more transparent.")

	var chest_slot := main_ui.find_child("ChestSlot", true, false) as PanelContainer
	var first_inventory_slot := main_ui.find_child("InventorySlot01", true, false) as PanelContainer
	var tooltip_panel := main_ui.find_child("ItemTooltipPanel", true, false) as PanelContainer
	var tooltip_label := main_ui.find_child("ItemTooltipLabel", true, false) as Label
	chest_slot.mouse_entered.emit()
	await process_frame
	assert(tooltip_panel.visible and tooltip_label.text.contains("Эпическое"), "Equipped epic tooltip must show its ItemInstance rarity.")
	chest_slot.mouse_exited.emit()
	first_inventory_slot.mouse_entered.emit()
	await process_frame
	assert(tooltip_panel.visible and tooltip_label.text.contains("Редкое"), "Inventory tooltip must show rare quality.")

	main_ui.free()
	print("PASS: Common, uncommon, rare, and epic ItemInstances display correct quality outlines and tooltips.")
	quit()
