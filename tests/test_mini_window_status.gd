extends SceneTree

const MiniMode = preload("res://scripts/ui/mini_window_mode.gd")
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
	var mini = ui.get_node("MiniWindowMode")
	if not mini.has_method("resolve_status"):
		print("FAIL: mini status mapping is missing")
		ui.free()
		quit(1)
		return
	var groups := {
		"Делает квест": [HeroState.CHOOSING_QUEST, HeroState.TRAVEL_TO_QUEST, HeroState.DOING_QUEST, HeroState.REVIEWING_QUEST_LOOT, HeroState.TURNING_IN_QUEST],
		"В городе": [HeroState.VISITING_GUILD, HeroState.VISITING_MARKET, HeroState.SHOPPING, HeroState.PREPARING_DUNGEON, HeroState.ARRIVED_IN_CITY],
		"Восстанавливается": [HeroState.RECOVERING_AFTER_FIGHT, HeroState.RECOVERING_IN_CITY],
		"Переезжает": [HeroState.TRAVEL_TO_CITY],
		"Возвращается": [HeroState.RETURNING_TO_CITY, HeroState.DUNGEON_RETURNING_TO_CITY],
		"Идёт в данж": [HeroState.TRAVEL_TO_DUNGEON],
		"В данже": [HeroState.AT_DUNGEON_ENTRANCE, HeroState.DOING_DUNGEON, HeroState.DUNGEON_BETWEEN_FIGHTS, HeroState.DUNGEON_COMPLETED],
		"В событии": [HeroState.EVENT_ACTIVE, HeroState.EVENT_COMBAT],
		"Мёртв": [HeroState.DEAD_RESPAWNING],
	}
	ui.set_time_scale(0.0)
	mini.enter_mini_mode()
	var indicator = mini.panel.get_node_or_null("PendingPoints")
	if indicator == null:
		print("FAIL: mini pending-points indicator is missing")
		mini.exit_mini_mode()
		ui.free()
		quit(1)
		return
	for points in [0, 4, 1, 0]:
		ui.simulation.hero_state.pending_primary_attribute_points = points
		ui._process(0.0)
		check(indicator.visible == (points > 0), "Plus visibility must follow unspent points: %d" % points)
	check(indicator.text == "+" and indicator.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Plus is a non-interactive indicator")
	check(indicator.get_rect().end.x <= mini.expand_button.get_rect().position.x, "Plus must not overlap Expand")
	ui.simulation.hero_state.pending_primary_attribute_points = 1
	mini.exit_mini_mode()
	mini.enter_mini_mode()
	check(indicator.visible, "Re-entry must refresh unspent points")
	for caption in groups:
		for state in groups[caption]:
			ui.simulation.hero_state.loop_state = state
			ui._process(0.1)
			check(mini.status_label.text == caption, "Live mini status at x0: %s" % state)
			var font: Font = mini.status_label.get_theme_font("font")
			var width := font.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
			check(width + 4.0 <= mini.status_label.size.x, "Caption fits: %s" % caption)
		var expected_color := Color("303844")
		if caption in ["Идёт в данж", "В событии"]:
			expected_color = Color("ffd34d")
		elif caption == "В данже":
			expected_color = Color("ff9e38")
		elif caption == "Мёртв":
			expected_color = Color("ff4545")
		check(mini.status_label.get_theme_color("font_color") == expected_color, "Status color: %s" % caption)
	for context in ["quest", "dungeon", "event"]:
		var expected: String = {"quest": "В бою", "dungeon": "Данж: бой", "event": "Событие: бой"}[context]
		var status: Dictionary = mini.resolve_status(HeroState.DOING_QUEST, true, context)
		check(status.text == expected and status.color == Color("ff9e38"), "Combat uses real owner: %s" % context)
		check(mini.resolve_status(HeroState.DEAD_RESPAWNING, true, context).text == "Мёртв", "Death has priority")
		var mob: Resource = load("res://data/quests/0001_goblin_road_problem.tres").mob_definition
		ui.simulation.hero_state.loop_state = HeroState.DOING_QUEST
		ui.simulation.start_combat_session(mob, context, ui.simulation.hero_state.current_hp)
		ui._process(0.0)
		check(mini.status_label.text == expected, "Real CombatSession reaches mini UI: %s" % context)
	ui.simulation.active_combat_session = null
	check(mini.status_label.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Text must not block background dragging")
	check(mini.status_label.get_theme_color("font_outline_color") == Color.BLACK, "Black outline")
	check(mini.status_label.get_theme_constant("outline_size") == 2, "Visible outline thickness")
	ui.simulation.hero_state.loop_state = HeroState.RECOVERING_IN_CITY
	ui._process(0.0)
	await process_frame
	if DisplayServer.get_name() != "headless" and "--capture-mini" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/mini-status.png")
	mini.exit_mini_mode()
	await process_frame
	await process_frame
	ui.free()
	await process_frame
	print("PASS: all mini status groups, combat contexts, death priority, x0, colors, outline and text fit" if failures.is_empty() else "FAIL: %s" % [failures])
	quit(0 if failures.is_empty() else 1)
