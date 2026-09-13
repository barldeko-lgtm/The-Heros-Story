extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var ui = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(ui)
	ui.set_process(false)
	await process_frame
	await process_frame
	var panel: Control = ui.combat_statistics_label.get_parent()
	assert(panel.get_parent() == ui.statistics_screen and not panel.is_visible_in_tree())
	assert(ui.opponent_panel.get_parent() == ui.main_screen)
	assert(ui.opponent_panel.position == Vector2(1014, 80))
	ui.statistics_button.pressed.emit()
	assert(ui.statistics_screen.visible and not ui.main_screen.visible)
	assert(panel.is_visible_in_tree() and ui.inventory_close_button.visible)
	assert(ui.combat_statistics_label.text.contains("Всего: 0"))
	ui.simulation.combat_results_by_mob["fixture"] = {"display_name": "Тест", "total": 5, "wins": 3, "losses": 2}
	ui.refresh_visible_screen()
	assert(ui.combat_statistics_label.text.contains("Всего: 5 · Побед: 3 · Поражений: 2"))
	assert(ui.combat_statistics_label.text.contains("60.0%"))
	var tick: int = ui.simulation.world_clock.world_tick
	ui._process(10.0)
	assert(ui.simulation.world_clock.world_tick > tick, "Statistics must not pause simulation.")
	await process_frame
	assert(not ui.statistics_button.get_global_rect().intersects(ui.get_node("TopMenu").get_global_rect()))
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/statistics-screen.png")
	for screen in ["hero", "inventory", "map", "main"]:
		ui.set_active_screen(screen)
		assert(not ui.statistics_screen.visible)
		ui.statistics_button.pressed.emit()
		assert(ui.statistics_screen.visible and not ui.hero_screen.visible and not ui.inventory_screen.visible and not ui.map_screen.visible)
	ui.inventory_close_button.pressed.emit()
	assert(ui.main_screen.visible and not panel.is_visible_in_tree())
	ui.statistics_button.pressed.emit()
	ui.statistics_button.pressed.emit()
	assert(ui.main_screen.visible)
	if DisplayServer.get_name() != "headless":
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/statistics-main-screen.png")
	await process_frame
	await process_frame
	await process_frame
	ui.free()
	print("PASS: Statistics navigation, moved card, live counters, continuing simulation and unchanged opponent/header geometry.")
	quit()
