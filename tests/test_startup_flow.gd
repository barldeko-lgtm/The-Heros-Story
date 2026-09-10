extends SceneTree

func _init() -> void:
	call_deferred("run")

func run() -> void:
	var path := "res://scenes/main/startup.tscn"
	if not ResourceLoader.exists(path):
		printerr("FAIL: two-stage startup scene is missing.")
		quit(1)
		return
	assert(ProjectSettings.get_setting("application/run/main_scene") == path)
	root.size = Vector2i(1366, 768)
	var startup = load(path).instantiate()
	startup.simulation_seed = 12345
	startup.save_directory = "res://.godot/startup-test-" + str(Time.get_ticks_usec())
	root.add_child(startup)
	await process_frame
	await process_frame
	assert(startup.simulation == null and startup.game_ui == null)
	assert(startup.start_menu.visible and not startup.background_screen.visible)
	assert(startup.continue_button.disabled)
	startup.new_game_button.pressed.emit()
	await process_frame
	await process_frame
	assert(not startup.start_menu.visible)
	assert(startup.background_screen.visible and not startup.class_screen.visible)
	var screen = startup.background_screen
	assert(startup.get_node("StartupBackground").color == Color("d9dde2"), "Startup uses the main-screen background.")
	assert(screen.next_button.get_theme_stylebox("normal").bg_color == Color("303844"))
	assert(startup.class_screen.next_button.get_theme_stylebox("normal").bg_color == Color("303844"))
	assert(screen.answer_buttons[0][0].get_theme_color("font_color") == Color("edf0f4"))
	var first_question: Control = screen.find_child("Question1", true, false)
	var second_question: Control = screen.find_child("Question2", true, false)
	var third_question: Control = screen.find_child("Question3", true, false)
	assert(screen.answer_buttons[0][0].get_theme_font_size("font_size") == 15, "Questionnaire answers use the requested smaller font.")
	assert(second_question.get_global_rect().position.x - first_question.get_global_rect().end.x >= 36, "Question columns need a clear visual gap.")
	assert(third_question.get_global_rect().position.y - first_question.get_global_rect().end.y >= 24, "Question rows need breathing room.")
	if OS.get_cmdline_user_args().has("--capture-startup"):
		await RenderingServer.frame_post_draw
		var image: Image = root.get_texture().get_image()
		image.save_png("res://.godot/startup-background.png")
	assert(screen.next_button.disabled)
	screen.next_button.pressed.emit()
	assert(startup.background_screen.visible, "Incomplete questionnaire cannot advance.")
	assert(screen.answer_buttons.size() == 4)
	var choices := [0, 0, 3, 1]
	for question in range(4):
		assert(screen.answer_buttons[question].size() == (5 if question == 0 else 4))
		var button: Button = screen.answer_buttons[question][choices[question]]
		await click_control(button)
	assert(not screen.next_button.disabled)
	# Changing a selection replaces it; no hero or gameplay exists yet.
	var alternate: Button = screen.answer_buttons[0][1]
	await click_control(alternate)
	assert(not screen.answer_buttons[0][0].button_pressed)
	assert(screen.selected_answers[0] == 1 and startup.simulation == null)
	var original: Button = screen.answer_buttons[0][0]
	await click_control(original)
	await process_frame
	for group in screen.answer_buttons:
		for button in group:
			assert(button.get_global_rect().size.y > 0)
			assert(screen.find_child("QuestionsScroll", true, false).get_global_rect().encloses(button.get_global_rect()), "Every answer must fit without scrolling at 1366x768.")
	assert(Rect2(Vector2.ZERO, Vector2(1366, 768)).encloses(screen.next_button.get_global_rect()))
	await click_control(screen.next_button)
	await process_frame
	assert(not screen.visible and startup.class_screen.visible)
	assert(startup.class_screen.next_button.disabled)
	startup.start_game()
	assert(startup.simulation == null, "Class choice cannot be bypassed.")
	startup.class_screen.selected_class_id = "mage"
	startup.start_game()
	assert(startup.simulation == null, "Unavailable class cannot create a game.")
	startup.class_screen.selected_class_id = ""
	assert(startup.class_screen.class_buttons.size() == 4)
	for i in range(1, 4):
		assert(startup.class_screen.class_buttons[i].disabled)
		await click_control(startup.class_screen.class_buttons[i])
	assert(startup.class_screen.next_button.disabled)
	await click_control(startup.class_screen.class_buttons[0])
	assert(not startup.class_screen.next_button.disabled)
	assert(Rect2(Vector2.ZERO, Vector2(1366, 768)).encloses(startup.class_screen.next_button.get_global_rect()))
	if OS.get_cmdline_user_args().has("--capture-startup"):
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/startup-class.png")
	assert(startup.simulation == null and startup.game_ui == null, "No simulation before the second Next.")
	await create_timer(0.1).timeout
	assert(startup.simulation == null)
	startup.class_screen.next_button.pressed.emit()
	assert(startup.simulation != null and startup.game_ui != null)
	startup.game_ui.set_process(false)
	var simulation = startup.simulation
	assert(simulation.world_clock.world_tick == 0 and is_zero_approx(simulation.world_clock.tick_progress))
	assert(simulation.hero_state.background_answers == choices)
	assert(simulation.hero_state.strength == 6 and simulation.hero_state.constitution == 6 and simulation.hero_state.intelligence == 6)
	assert(simulation.hero_state.hero_class_id == "warrior")
	assert(simulation.hero_state.pending_primary_attribute_points == 0)
	assert(simulation.trait_development.get_established_traits(simulation.hero_state).is_empty())
	assert(simulation.hero_state.personality_axis_values.courage == 0)
	assert(simulation.hero_state.current_hp == simulation.combat_stats.max_hp)
	assert(simulation.autonomous_quest_choice and simulation.temporary_events_enabled)
	assert(startup.game_ui.simulation == simulation)
	startup.class_screen.next_button.pressed.emit()
	assert(startup.simulation == simulation and simulation.hero_state.strength == 6)
	assert(simulation.hero_state.loop_state == "VISITING_GUILD")
	assert(simulation.diary.get_text().contains("Илье") and simulation.diary.get_text().contains("Дорнвальд"))
	if OS.get_cmdline_user_args().has("--capture-startup"):
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/startup-arrival.png")
	startup.game_ui._process(10.0)
	assert(simulation.world_clock.world_tick == 1)
	assert(simulation.hero_state.active_quest != null)
	startup.queue_free()
	await process_frame
	print("PASS: questionnaire -> Warrior selection -> one correctly initialized live game, without pregame time.")
	quit()

func click_control(control: Control) -> void:
	var position: Vector2 = control.get_global_rect().get_center()
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = position
		event.global_position = position
		Input.parse_input_event(event)
		await process_frame
