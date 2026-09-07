extends SceneTree

var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		printerr("FAIL: " + message)

func _init() -> void:
	call_deferred("run")

func run() -> void:
	if not ResourceLoader.exists("res://scenes/ui/components/hero_summary_panel.tscn"):
		printerr("FAIL: Hero summary has not been extracted")
		quit(1)
		return
	root.size = Vector2i(1366, 768)
	var ui = load("res://scripts/ui/main_ui.gd").new()
	root.add_child(ui)
	ui.set_process(false)
	ui.simulation.set_time_scale(0.0)
	await process_frame
	await process_frame
	var summary = ui.hero_summary_panel
	check(summary.simulation == ui.simulation, "Summary uses existing live simulation")
	check(ui.hero_details_label == summary.hero_details_label and ui.pending_attribute_indicator == summary.pending_attribute_indicator, "Compatibility references expose live controls")
	var panel = ui.hero_details_label.get_parent()
	check(panel is PanelContainer and panel.position == Vector2(32, 80) and panel.size.x == 320, "Panel geometry and label parent preserved")
	check(panel.global_position == Vector2(32, 80), "Wrapper does not shift panel")
	check(ui.hero_details_label.get_theme_font_size("font_size") == 14 and ui.hero_details_label.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART, "Text layout preserved")
	check(ui.hero_details_label.text.contains("Состояние: Выбирает квест\n\nКвест:"), "Short state reserves blank line")
	ui.simulation.hero_state.loop_state = HeroState.DUNGEON_BETWEEN_FIGHTS
	ui.update_hero_panel()
	check(ui.hero_details_label.text.contains("Состояние: В данже — готовится к следующему бою\nКвест:"), "Long state keeps existing spacing")
	check(not ui.pending_attribute_indicator.visible, "Plus initially hidden")
	ui.simulation.hero_state.pending_primary_attribute_points = 1
	ui.update_pending_attribute_indicator()
	var indicator = ui.pending_attribute_indicator
	check(indicator.name == "PendingAttributeIndicator" and indicator.visible and indicator.text == "+" and indicator.get_theme_color("font_color") == Color("ff3030"), "Plus appearance preserved")
	check(indicator.tooltip_text == "Есть нераспределённые очки характеристик" and indicator.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Tooltip and input behavior preserved")
	var lines: int = 3
	if not load("res://scripts/hero/hero_traits.gd").get_conditional_damage_bonus_text(ui.simulation.get_hero_traits()).is_empty():
		lines += 1
	if ui.simulation.get_combat_buff_fights_remaining() > 0:
		lines += 1
	var font: Font = ui.hero_details_label.get_theme_font("font")
	var expected = panel.global_position + Vector2(286, 14 + font.get_height(14) * lines - 2)
	check(indicator.global_position.is_equal_approx(expected), "Plus follows exact level-line geometry")
	var tick: int = ui.simulation.world_clock.world_tick
	var rng_state = ui.simulation.seeded_rng.get_rng().state
	var gold: int = ui.simulation.hero_state.gold
	ui.update_hero_panel()
	ui.update_pending_attribute_indicator()
	check(tick == ui.simulation.world_clock.world_tick and rng_state == ui.simulation.seeded_rng.get_rng().state and gold == ui.simulation.hero_state.gold, "Presentation does not advance gameplay")
	ui.set_active_screen("hero")
	check(not summary.is_visible_in_tree() and not indicator.is_visible_in_tree(), "Summary and plus hide with main screen")
	ui.hero_details_label.text = "hidden sentinel"
	ui.refresh_visible_screen()
	check(ui.hero_details_label.text == "hidden sentinel", "Hidden summary does not refresh")
	ui.close_secondary_screen()
	check(summary.is_visible_in_tree() and ui.hero_details_label.text != "hidden sentinel", "Return refreshes summary")
	ui.simulation.hero_state.pending_primary_attribute_points = 0
	ui.update_pending_attribute_indicator()
	check(not indicator.visible, "Spent points hide plus")
	await process_frame
	ui.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: Hero summary preserves text spacing, geometry, plus, navigation and read-only presentation")
	quit(0 if failures == 0 else 1)
