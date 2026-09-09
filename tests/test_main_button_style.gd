extends SceneTree

var failures: Array[String] = []
func _initialize() -> void:
	call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
		push_error(message)

func run() -> void:
	var ui = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(ui)
	ui.set_process(false)
	await process_frame
	await process_frame
	var controls: Array = ui.get_node("TopMenu").get_children()
	controls.append(ui.get_node("MiniModeButton"))
	controls.append_array(ui.speed_buttons.values())
	controls.append_array([ui.god_panel.divine_healing_button, ui.god_panel.combat_buff_button, ui.god_panel.instant_resurrection_button, ui.god_panel.vision_button])
	for button in controls:
		var normal: StyleBoxFlat = button.get_theme_stylebox("normal")
		check(normal.bg_color == Color("2b3440") and normal.border_color == Color("526174"), "Shared normal palette: %s" % button.text)
		check(normal.border_width_left == 1 and normal.corner_radius_top_left == 6 and normal.shadow_size == 0, "Shared light frame: %s" % button.text)
		check(normal.content_margin_left == 14.0 and normal.content_margin_top == 8.0, "Existing content margins: %s" % button.text)
		check(button.get_theme_color("font_disabled_color") == Color("929eae"), "Disabled labels remain readable")
		var focus: StyleBoxFlat = button.get_theme_stylebox("focus")
		check(focus.bg_color.a == 0.0, "Keyboard focus must not hide active fill")
		check(button.get_theme_stylebox("hover_pressed").bg_color == Color("49637f"), "Selected speed remains distinct under mouse")
	var tabs: TabBar = ui.narrative_panel.get_tab_bar()
	check(tabs.get_theme_stylebox("tab_selected").bg_color == ui.speed_buttons[1.0].get_theme_stylebox("pressed").bg_color, "Tabs and speed use the same selected state")
	check(tabs.get_theme_stylebox("tab_unselected").bg_color == ui.hero_button.get_theme_stylebox("normal").bg_color, "Tabs and buttons share resting state")
	check(ui.speed_buttons[1.0].button_pressed, "Default speed selection unchanged")
	ui.speed_buttons[5.0].pressed.emit()
	for speed in ui.speed_buttons:
		check(ui.speed_buttons[speed].button_pressed == (speed == 5.0), "Only chosen speed stays selected")
	ui.hero_button.pressed.emit()
	check(ui.hero_screen.visible and ui.hero_button.text == "НАЗАД", "Navigation behavior unchanged")
	check(ui.hero_button.get_theme_stylebox("normal").bg_color == Color("3b536c"), "Current navigation entry is highlighted")
	ui.hero_button.pressed.emit()
	check(ui.main_screen.visible and ui.hero_button.get_theme_stylebox("normal").bg_color == Color("2b3440"), "Navigation highlight clears on return")
	ui.narrative_panel.current_tab = 1
	check(ui.narrative_panel.diary_text_edit.is_visible_in_tree() and not ui.narrative_panel.log_text_edit.is_visible_in_tree(), "Diary tab still switches content")
	ui.narrative_panel.current_tab = 0
	check(ui.mini_mode.expand_button.get_theme_stylebox("normal").corner_radius_top_left == 3, "Mini window style unchanged")
	check(ui.god_panel.divine_healing_button.disabled, "Full-health healing stays disabled")
	await process_frame
	await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/main-button-style.png")
	ui.free()
	await process_frame
	print("PASS: unified button/tab states, speed selection, navigation, disabled controls, mini isolation" if failures.is_empty() else "FAIL: %s" % [failures])
	quit(0 if failures.is_empty() else 1)
