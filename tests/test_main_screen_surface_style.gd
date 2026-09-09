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
	await process_frame
	var background: ColorRect = ui.get_child(0)
	check(background.color == Color("191e26"), "Main background must be muted dark blue-gray")
	for panel in [ui.hero_summary_panel.hero_panel, ui.god_panel, ui.opponent_panel, ui.combat_statistics_label.get_parent()]:
		var style: StyleBoxFlat = panel.get_theme_stylebox("panel")
		check(style.bg_color == Color("232830"), "Panel fill stays unchanged")
		check(style.border_color == Color("495462") and style.border_width_left == 1, "Subtle one-pixel panel border")
		check(style.shadow_size == 2 and is_equal_approx(style.shadow_color.a, 0.15), "Soft panel shadow")
		check(style.content_margin_left == 16.0 and style.content_margin_top == 14.0, "Panel content margins stay unchanged")
	var log_style: StyleBoxFlat = ui.narrative_panel.get_theme_stylebox("panel")
	check(log_style.border_width_left == 1 and log_style.border_color == Color("495462"), "Log outer panel border matches cards")
	check(log_style.get_content_margin(SIDE_LEFT) == 2.0, "Log layout margin stays unchanged")
	check(ui.tick_counter_label.get_theme_color("font_color") == Color("b6c0cc"), "Tick label stays readable on dark background")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/main-surface-style.png")
	for screen in ["hero", "inventory", "map"]:
		ui.set_active_screen(screen)
		check(background.color == Color("d9dde2"), "Other screen background stays unchanged: %s" % screen)
	ui.set_active_screen("main")
	check(background.color == Color("191e26"), "Return to main restores dark background")
	ui.mini_mode.enter_mini_mode()
	check(ui.mini_mode.panel.get_theme_stylebox("panel").bg_color == Color("d9dde2"), "Mini window stays unchanged")
	ui.mini_mode.exit_mini_mode()
	await process_frame
	await process_frame
	ui.free()
	await process_frame
	print("PASS: main surfaces, panel margins, readable tick text, other screens and mini isolation" if failures.is_empty() else "FAIL: %s" % [failures])
	quit(0 if failures.is_empty() else 1)
