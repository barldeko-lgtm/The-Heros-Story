extends SceneTree

const ITEM_PATH := "res://data/items/boar_chestplate.tres"

func _init() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	var item_instance_script: Script = load("res://scripts/model/runtime/item_instance.gd")
	var main_ui_script: Script = load("res://scripts/ui/main_ui.gd")
	var item_definition: Resource = load(ITEM_PATH)
	var simulation = simulation_script.new(1)
	assert(simulation.hero_state.equipment.equip_if_empty(item_instance_script.new(item_definition)))
	var main_ui = main_ui_script.new()
	main_ui.simulation = simulation
	get_root().add_child(main_ui)
	await process_frame
	main_ui.inventory_button.pressed.emit()
	await process_frame

	var chest_slot := main_ui.find_child("ChestSlot", true, false) as PanelContainer
	var tooltip_panel := main_ui.find_child("ItemTooltipPanel", true, false) as PanelContainer
	var tooltip_label := main_ui.find_child("ItemTooltipLabel", true, false) as Label
	assert(chest_slot != null and tooltip_panel != null and tooltip_label != null, "Chest slot and custom tooltip controls must exist.")
	assert(not tooltip_panel.visible, "Item tooltip must start hidden.")

	chest_slot.mouse_entered.emit()
	await process_frame
	assert(tooltip_panel.visible, "Hovering the equipped chest slot must show the custom tooltip panel.")
	assert(tooltip_label.text.contains("Кираса Авангарда Железного Оплота"), "Visible tooltip must show the item name.")
	assert(tooltip_label.text.contains("Максимальное здоровье: +20"), "Visible tooltip must show MaxHP.")
	assert(tooltip_label.text.contains("Броня: +10"), "Visible tooltip must show Armor.")
	assert(tooltip_label.text.contains("Сила: +1"), "Visible tooltip must show Strength.")

	chest_slot.mouse_exited.emit()
	await process_frame
	assert(not tooltip_panel.visible, "Leaving the chest slot must hide the tooltip panel.")

	main_ui.free()
	print("PASS: Equipped chest hover shows and hides the visible custom tooltip.")
	quit()
