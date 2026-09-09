extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var ui = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(ui)
	ui.set_process(false)
	await process_frame
	await process_frame
	var ok: bool = not ui.opponent_hp_bar.visible
	for style_name in ["background", "fill"]:
		var actual = ui.opponent_hp_bar.get_theme_stylebox(style_name)
		var expected = ui.hero_summary_panel.hp_bar.get_theme_stylebox(style_name)
		ok = ok and actual.bg_color == expected.bg_color
		ok = ok and actual.border_width_left == 0 and actual.border_width_top == 0
		ok = ok and actual.corner_radius_top_left == expected.corner_radius_top_left
	ok = ok and ui.opponent_hp_bar.custom_minimum_size == ui.hero_summary_panel.hp_bar.custom_minimum_size
	ui.simulation.combat_results_by_mob.clear()
	ui.update_combat_statistics_panel()
	ok = ok and ui.combat_statistics_label.text.contains("Всего: 0") and ui.combat_statistics_label.text.contains("Победы: 0.0%")
	ui.simulation.combat_results_by_mob["test_a"] = {"display_name": "Тест A", "total": 3, "wins": 2, "losses": 1}
	ui.simulation.combat_results_by_mob["test_b"] = {"display_name": "Тест B", "total": 2, "wins": 1, "losses": 1}
	ui.update_combat_statistics_panel()
	ok = ok and ui.combat_statistics_label.text.contains("Всего: 5 · Побед: 3 · Поражений: 2") and ui.combat_statistics_label.text.contains("Победы: 60.0%")
	ui.simulation.combat_results_by_mob.clear()
	for step in 2000:
		ui._process(0.2)
		if ui.simulation.active_combat_session != null:
			break
	ok = ok and ui.simulation.active_combat_session != null
	if ui.simulation.active_combat_session != null:
		ui.update_opponent_panel()
		ok = ok and ui.opponent_hp_bar.visible
		ok = ok and is_equal_approx(ui.opponent_hp_bar.value, ui.simulation.get_current_opponent_hp())
		ok = ok and is_equal_approx(ui.opponent_hp_bar.max_value, ui.simulation.get_current_opponent_stats().max_hp)
		var tick = ui.simulation.world_clock.world_tick
		var hp = ui.simulation.get_current_opponent_hp()
		ui.update_opponent_panel()
		ok = ok and tick == ui.simulation.world_clock.world_tick and hp == ui.simulation.get_current_opponent_hp()
		ui.opponent_name_label.text = "Очень длинное имя противника для проверки переноса"
		await process_frame
		await process_frame
		ok = ok and ui.opponent_panel.size == Vector2(320, 280)
		ok = ok and ui.opponent_details_label.get_global_rect().end.y <= ui.opponent_panel.get_global_rect().end.y
		ok = ok and ui.combat_statistics_label.get_parent().position == Vector2(1014, 380)
		ui.update_opponent_panel()
		if DisplayServer.get_name() != "headless":
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://.godot/opponent-card.png")
		for step in 2000:
			ui._process(0.2)
			if ui.simulation.active_combat_session == null:
				break
		ui.update_opponent_panel()
		ok = ok and not ui.opponent_hp_bar.visible and not ui.opponent_details_label.visible
	await process_frame
	await process_frame
	await process_frame
	ui.free()
	await process_frame
	print("PASS: compact opponent card, live HP, read-only refresh, long name and no-combat state" if ok else "FAIL: opponent card")
	quit(0 if ok else 1)
