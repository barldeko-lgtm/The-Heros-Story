extends SceneTree

func _init() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var main_ui_script: Script = load("res://scripts/ui/main_ui.gd")
	assert(main_ui_script != null, "Main UI script must exist.")
	var main_ui = main_ui_script.new()
	get_root().add_child(main_ui)
	await process_frame

	assert(main_ui.main_screen.visible, "Main screen must be visible at startup.")
	assert(not main_ui.inventory_screen.visible, "Inventory screen must be hidden at startup.")
	assert(main_ui.inventory_button.text == "ИНВЕНТАРЬ", "Top menu must show the Inventory label on the main screen.")
	assert(not main_ui.inventory_close_button.visible, "Inventory close button must be hidden on the main screen.")

	main_ui.inventory_button.pressed.emit()
	assert(not main_ui.main_screen.visible, "Opening Inventory must hide the main screen content.")
	assert(main_ui.inventory_screen.visible, "Opening Inventory must show the empty inventory screen.")
	assert(main_ui.inventory_button.text == "НАЗАД", "Inventory button must become Back while Inventory is open.")
	assert(main_ui.inventory_close_button.visible, "Inventory close button must be visible while Inventory is open.")

	main_ui.simulation.set_time_scale(1.0)
	var tick_before: int = main_ui.simulation.world_clock.world_tick
	main_ui._process(10.1)
	assert(main_ui.simulation.world_clock.world_tick > tick_before, "Simulation must keep advancing while Inventory is open.")

	main_ui.inventory_close_button.pressed.emit()
	assert(main_ui.main_screen.visible, "Close button must restore the main screen.")
	assert(not main_ui.inventory_screen.visible, "Close button must hide the inventory screen.")
	assert(main_ui.inventory_button.text == "ИНВЕНТАРЬ", "Returning must restore the Inventory label.")

	main_ui.inventory_button.pressed.emit()
	main_ui.inventory_button.pressed.emit()
	assert(main_ui.main_screen.visible, "Back button must return to the main screen.")
	assert(not main_ui.inventory_screen.visible, "Back button must close Inventory.")

	main_ui.free()
	print("PASS: Inventory screen navigation preserves the running simulation.")
	quit()
