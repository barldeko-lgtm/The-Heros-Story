extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var startup = load("res://scenes/main/startup.tscn").instantiate()
	startup.save_directory = "res://.godot/menu-test-" + str(Time.get_ticks_usec())
	root.add_child(startup)
	await process_frame
	await process_frame
	var ok: bool = startup.start_menu.visible and startup.continue_button.disabled and startup.simulation == null
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/start-menu.png")
	startup.free()
	var ui = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(ui)
	ui.set_process(false)
	await process_frame
	await process_frame
	for button in ui.get_node("TopMenu").get_children():
		if button.text == "МЕНЮ":
			button.pressed.emit()
	await process_frame
	ok = ok and ui.game_menu.visible
	var captions: Array = []
	for child in ui.game_menu.get_children():
		if child is VBoxContainer:
			for button in child.get_children():
				if button is Button:
					captions.append(button.text)
					ok = ok and button.disabled
	ok = ok and captions == ["Сохранить", "Загрузить"]
	var tick = ui.simulation.world_clock.world_tick
	ui._process(30.0)
	ok = ok and ui.simulation.world_clock.world_tick == tick
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/game-menu.png")
	ui.game_menu.hide()
	ui._process(30.0)
	ok = ok and ui.simulation.world_clock.world_tick > tick
	await process_frame
	await process_frame
	await process_frame
	ui.free()
	await process_frame
	print("PASS: start menu, disabled persistence actions, game menu pause/resume" if ok else "FAIL: menu shell")
	quit(0 if ok else 1)
