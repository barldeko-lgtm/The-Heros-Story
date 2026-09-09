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
	var panel = ui.god_panel
	var detail = panel.vision_button.get_node_or_null("ActionDetail")
	if detail == null:
		print("FAIL: separate divine-action details are missing")
		ui.free()
		quit(1)
		return
	check(panel.position == Vector2(423, 80) and panel.size == Vector2(544, 235), "God panel outer geometry unchanged")
	check(panel.god_energy_label.get_parent().get_child(0).text == "Влияние божества", "Energy shares header with title")
	check(panel.god_energy_bar.value == ui.simulation.god_state.energy, "Energy bar remains live")
	for button in [panel.divine_healing_button, panel.combat_buff_button, panel.instant_resurrection_button, panel.vision_button]:
		var info: Label = button.get_node("ActionDetail")
		check(not button.text.contains("\n") and info.get_theme_font_size("font_size") == 12, "Action name and smaller detail are separate")
		check(info.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Detail does not intercept button clicks")
		check(button.get_global_rect().end.x <= panel.get_global_rect().end.x - 16, "Action stays inside panel")
	check(detail.text.contains("80"), "Vision cost is retained")
	check(panel.god_status_label.get_theme_font_size("font_size") == 13, "Footer is secondary text")
	check(panel.god_status_label.get_theme_color("font_color") == Color("96a3b5"), "Idle hint is muted")
	ui.simulation.god_state.energy = 100.0
	panel.combat_buff_button.pressed.emit()
	check(panel.combat_buff_button.disabled, "Active blessing still disables repeat use")
	check(panel.combat_buff_button.get_node("ActionDetail").text.contains("Боёв: 5"), "Remaining fights retained")
	check(panel.god_status_label.get_theme_color("font_color") == Color("d9bd7d"), "Active effect is distinct from idle hint")
	await process_frame
	await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/god-panel-polish.png")
	ui.free()
	await process_frame
	print("PASS: divine panel hierarchy, geometry, secondary details and real blessing action" if failures.is_empty() else "FAIL: %s" % [failures])
	quit(0 if failures.is_empty() else 1)
