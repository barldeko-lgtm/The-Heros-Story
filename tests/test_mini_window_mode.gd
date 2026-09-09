extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func run() -> void:
	var ui = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(ui)
	ui.set_process(false)
	await process_frame
	var controller = ui.get_node_or_null("MiniWindowMode")
	if controller == null:
		print("FAIL: MiniWindowMode is missing")
		ui.free()
		quit(1)
		return
	ui.set_active_screen("hero")
	var original_size := root.size
	var original_position := root.position
	var original_scale := root.content_scale_size
	var original_top := root.always_on_top
	var original_min := root.min_size
	var original_borderless := root.borderless
	var original_resize := root.unresizable
	var same_simulation = ui.simulation
	ui.get_node("MiniModeButton").pressed.emit()
	await process_frame
	check(controller.active, "Mini mode must activate from its button")
	check(controller.panel.visible, "Mini panel must be visible")
	check(not ui.hero_screen.visible, "Ordinary UI must be hidden")
	check(controller.panel.get_child_count() == 3, "Mini panel must contain only status, pending points and Expand")
	check(controller.expand_button.text.is_empty() and controller.expand_button.icon != null, "Expand must be icon-only")
	check(controller.expand_button.size == Vector2(28, 28), "Expand must be a compact square")
	check(root.content_scale_size == Vector2i.ZERO, "Mini UI must not inherit full-game stretch")
	if DisplayServer.get_name() != "headless":
		await create_timer(0.2).timeout
		check(root.size == Vector2i(240, 40), "Native mini window size")
		check(root.always_on_top, "Native mini window stays on top")
		check(root.borderless, "Mini window must have no OS title bar")
		if "--capture-mini" in OS.get_cmdline_user_args():
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://.godot/mini-window.png")
	controller.enter_mini_mode()
	var old_tick: int = ui.simulation.world_clock.world_tick
	ui._process(10.0)
	check(ui.simulation.world_clock.world_tick > old_tick, "Simulation must continue in mini mode")
	controller.expand_button.pressed.emit()
	await process_frame
	check(not controller.active and not controller.panel.visible, "Expand must exit mini mode")
	check(ui.hero_screen.visible and not ui.main_screen.visible, "Previously selected screen must return")
	check(ui.simulation == same_simulation, "Simulation must not be recreated")
	check(root.content_scale_size == original_scale, "Game stretch must be restored")
	check(root.min_size == original_min and root.unresizable == original_resize, "Window constraints must restore")
	if DisplayServer.get_name() != "headless":
		await create_timer(0.2).timeout
		check(root.size == original_size and root.position == original_position, "Window geometry must restore")
		check(root.always_on_top == original_top, "Topmost flag must restore")
		check(root.borderless == original_borderless, "Original OS frame must restore")
	controller.exit_mini_mode()
	if DisplayServer.get_name() != "headless":
		for target in [Vector2i(100, 120), Vector2i(180, 160)]:
			controller.enter_mini_mode()
			root.position = target
			await create_timer(0.1).timeout
			check(root.position == target, "Native mini window must move to test position")
			controller.exit_mini_mode()
			await create_timer(0.1).timeout
			check(root.position == original_position, "Moving mini must not change normal position")
			controller.enter_mini_mode()
			await create_timer(0.1).timeout
			check(root.position == target, "Mini mode must remember its latest position")
			controller.exit_mini_mode()
	controller.enter_mini_mode()
	controller.exit_mini_mode()
	check(ui.hero_screen.visible, "Repeated switching must retain selected screen")
	await process_frame
	await process_frame
	ui.free()
	await process_frame
	print("PASS: mini window enter/expand, blank contents, simulation, restoration, repeated switching" if failures.is_empty() else "FAIL: %s" % [failures])
	quit(0 if failures.is_empty() else 1)
