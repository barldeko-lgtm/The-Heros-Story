extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var ui = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(ui)
	ui.set_process(false)
	await process_frame
	await process_frame
	var panel = ui.narrative_panel
	var ok: bool = panel.position == Vector2(371, 368) and panel.size == Vector2(624, 326)
	for text_edit in [panel.log_text_edit, panel.diary_text_edit]:
		ok = ok and text_edit.get_theme_font_size("font_size") == 15
	ok = ok and panel.get_rect().end.y <= ui.main_screen.get_node("SpeedControls").position.y - 20
	ok = ok and panel.position.x >= ui.hero_summary_panel.hero_panel.get_rect().end.x + 16
	ok = ok and panel.get_rect().end.x <= ui.opponent_panel.position.x - 16
	ok = ok and panel.position.y >= ui.time_progress_bar.get_global_rect().end.y + 10
	if DisplayServer.get_name() != "headless":
		# Populate the screenshot through real simulation, not synthetic log text.
		for step in 30:
			ui._process(10.0)
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/narrative-space.png")
	await process_frame
	ui.free()
	await process_frame
	print("PASS: larger narrative panel, 15px text, clear of cards and bottom controls" if ok else "FAIL: narrative geometry/font/clearance")
	quit(0 if ok else 1)
