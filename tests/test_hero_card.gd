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
	ui.set_time_scale(0.0)
	await process_frame
	await process_frame
	var card = ui.hero_summary_panel
	if card.get("hp_bar") == null:
		print("FAIL: structured hero card is missing")
		ui.free()
		quit(1)
		return
	var hero = ui.simulation.hero_state
	check(card.hero_panel.position == Vector2(32, 80) and card.hero_panel.size == Vector2(320, 640), "Card stays in left column and within viewport")
	check(card.hero_name_label.text == hero.hero_name, "Name header uses live hero")
	check(card.hero_name_label.get_theme_font_size("font_size") == 22, "Name has clear hierarchy")
	check(card.hp_bar.value == ui.simulation.get_current_hero_hp() and card.hp_bar.max_value == ui.simulation.base_combat_stats.max_hp, "HP bar uses real current and max HP")
	check(card.xp_bar.value == hero.experience and card.xp_bar.max_value == hero.experience_to_next_level, "XP bar uses real progress")
	var old_hp: float = hero.current_hp
	hero.current_hp = old_hp * 0.5
	hero.pending_primary_attribute_points = 1
	ui.update_hero_panel()
	check(card.hp_bar.value == hero.current_hp and card.hp_text.text.contains("%.1f" % hero.current_hp), "HP numbers and bar refresh together")
	check(card.pending_attribute_indicator.visible, "Pending points remain visible beside level")
	var tick: int = ui.simulation.world_clock.world_tick
	var rng_state = ui.simulation.seeded_rng.get_rng().state
	ui.update_hero_panel()
	check(tick == ui.simulation.world_clock.world_tick and rng_state == ui.simulation.seeded_rng.get_rng().state, "Card does not advance gameplay")
	var text: String = card.hero_details_label.get_parsed_text()
	for caption in ["Сила", "Ловкость", "Интеллект", "Телосложение", "Мудрость", "Физ. урон", "Точность", "Уклонение", "Броня", "Огонь / Холод / Молния", "Блок", "Скорость атаки", "Шанс крита", "Крит. урон", "Сила героя", "Seed"]:
		check(text.contains(caption), "Existing detail retained: %s" % caption)
	check(card.details_scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED, "No horizontal scroll")
	ui.simulation.hero_state.loop_state = HeroState.DUNGEON_BETWEEN_FIGHTS
	ui.update_hero_panel()
	check(card.activity_label.text.contains("готовится к следующему бою"), "Long activity remains available")
	await process_frame
	await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/hero-card.png")
	ui.set_active_screen("hero")
	check(not card.is_visible_in_tree(), "Card hides on other screens")
	hero.pending_primary_attribute_points = 0
	ui.set_active_screen("main")
	check(not card.pending_attribute_indicator.visible, "Return refreshes spent points")
	await process_frame
	await process_frame
	ui.free()
	await process_frame
	print("PASS: hero card layout, live HP/XP, all details, points, navigation and read-only rendering" if failures.is_empty() else "FAIL: %s" % [failures])
	quit(0 if failures.is_empty() else 1)
