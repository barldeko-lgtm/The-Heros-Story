extends SceneTree

var failures: int = 0

func check(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL: " + label)

func _init() -> void:
	call_deferred("run")

func run() -> void:
	var ui = load("res://scripts/ui/main_ui.gd").new()
	root.add_child(ui)
	ui.set_process(false)
	ui.map_screen.set_process(false)
	ui.simulation.set_time_scale(0.0)
	await process_frame

	ui.attribute_points_label.text = "hidden hero sentinel"
	ui.inventory_screen.chest_equipment_icon.texture = null
	ui.map_screen.last_hero_position = Vector2i(-999, -999)
	ui._process(0.0)
	ui.map_screen._process(0.0)
	check(ui.attribute_points_label.text == "hidden hero sentinel", "Main screen must not refresh hidden hero panel")
	check(ui.inventory_screen.chest_equipment_icon.texture == null, "Main screen must not refresh hidden inventory")
	check(ui.map_screen.last_hero_position == Vector2i(-999, -999), "Hidden map must skip polling")

	ui.attribute_points_label.text = "hidden hero sentinel"
	ui.set_active_screen("hero")
	check(ui.attribute_points_label.text != "hidden hero sentinel", "Opening hero refreshes immediately")
	ui.hero_details_label.text = "hidden main sentinel"
	ui.god_panel.god_energy_label.text = "hidden god sentinel"
	ui.attribute_points_label.text = "visible hero sentinel"
	ui._process(0.0)
	check(ui.attribute_points_label.text != "visible hero sentinel", "Visible hero continues refreshing")
	check(ui.hero_details_label.text == "hidden main sentinel", "Hero screen skips hidden main panel")
	check(ui.god_panel.god_energy_label.text == "hidden god sentinel", "Hero screen skips hidden god panel")

	ui.inventory_screen.chest_equipment_icon.texture = null
	ui.set_active_screen("inventory")
	check(ui.inventory_screen.chest_equipment_icon.texture != null, "Opening inventory refreshes immediately")
	ui.inventory_screen.chest_equipment_icon.texture = null
	ui._process(0.0)
	check(ui.inventory_screen.chest_equipment_icon.texture != null, "Visible inventory continues refreshing")

	ui.map_screen.last_hero_position = Vector2i(-999, -999)
	ui.set_active_screen("map")
	check(ui.map_screen.last_hero_position == ui.simulation.world_state.hero_position, "Opening map refreshes immediately")
	ui.simulation.set_time_scale(1.0)
	var progress_before: float = ui.simulation.world_clock.tick_progress
	ui._process(0.1)
	check(ui.simulation.world_clock.tick_progress > progress_before, "Simulation advances while main screen is hidden")
	ui.simulation.set_time_scale(0.0)
	ui.hero_details_label.text = "hidden main sentinel"
	ui.god_panel.god_energy_label.text = "hidden god sentinel"
	ui.close_secondary_screen()
	check(ui.hero_details_label.text != "hidden main sentinel", "Returning to main refreshes immediately")
	check(ui.god_panel.god_energy_label.text != "hidden god sentinel", "Returning to main refreshes god controls immediately")

	await process_frame
	ui.queue_free()
	await process_frame
	print("Hidden screen refresh: %d failures" % failures)
	quit(1 if failures > 0 else 0)
