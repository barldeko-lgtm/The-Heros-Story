extends SceneTree
var failures: Array[String] = []
func check(value: bool, message: String) -> void:
	if not value:
		failures.append(message)
		printerr("FAIL: " + message)
func _initialize() -> void:
	call_deferred("run")
func settle() -> void:
	await process_frame
	await process_frame
	await process_frame
func run() -> void:
	var directory := "res://.godot/save-ui-test-" + str(Time.get_ticks_usec())
	var startup = load("res://scenes/main/startup.tscn").instantiate()
	startup.save_directory = directory
	startup.simulation_seed = 12345
	root.add_child(startup)
	await settle()
	check(startup.continue_button.disabled, "no continue without a save")
	startup.new_game_button.pressed.emit()
	startup.on_background_completed([0, 0, 3, 1])
	startup.class_screen.selected_class_id = "warrior"
	startup.start_game()
	startup.game_ui.set_process(false)
	startup.persistence.set_process(false)
	await settle()
	var controller = startup.persistence
	var store = controller.store
	check(not store.candidates("auto").is_empty(), "initial auto save")
	check(store.candidates("manual").is_empty(), "new game never writes manual")
	startup.game_ui.open_game_menu()
	var buttons: Array = []
	for child in startup.game_ui.game_menu.get_children():
		if child is VBoxContainer:
			for button in child.get_children():
				if button is Button:
					buttons.append(button)
	check(buttons.size() == 2 and not buttons[0].disabled and not buttons[1].disabled, "menu actions enabled")
	startup.simulation.hero_state.gold = 123
	buttons[0].pressed.emit()
	await settle()
	check(not store.candidates("manual").is_empty(), "save button writes manual slot")
	# Close the informational modal before continuing UI interactions.
	for child in startup.game_ui.game_menu.get_children():
		if child is AcceptDialog:
			child.hide()
			child.queue_free()
	await settle()
	buttons[1].pressed.emit()
	await settle()
	var slot_dialog: AcceptDialog
	for child in startup.game_ui.game_menu.get_children():
		if child is AcceptDialog and child.visible:
			slot_dialog = child
	check(slot_dialog != null, "load button opens slot picker")
	if slot_dialog != null:
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://.godot/save-slot-picker.png")
		var picker_buttons: Array = []
		for child in slot_dialog.get_children():
			if child is VBoxContainer:
				for button in child.get_children():
					if button is Button:
						picker_buttons.append(button)
		check(picker_buttons.size() == 2 and not picker_buttons[0].disabled and not picker_buttons[1].disabled, "both populated slots selectable")
		picker_buttons[0].pressed.emit()
		await settle()
		for child in startup.game_ui.game_menu.get_children():
			if child is ConfirmationDialog:
				child.canceled.emit()
	await settle()
	var old_sim = startup.simulation
	old_sim.hero_state.gold = 456
	controller.elapsed = 599.0
	controller._process(1.1)
	check(not store.candidates("auto").is_empty(), "real-time auto interval")
	print("RESTORE manual: ", controller.SnapshotScript.restore(store.candidates("manual")[0].snapshot).get("error", "OK"))
	controller.load_candidates(store.candidates("manual"))
	startup.game_ui.set_process(false)
	await settle()
	check(startup.simulation.hero_state.gold == 123 and startup.simulation != old_sim, "load replaces graph, not stale UI")
	check(startup.game_ui.simulation == startup.simulation, "new UI owns loaded model")
	check(startup.simulation.hero_state.background_answers == [0, 0, 3, 1], "typed background answers survive load")
	check(startup.simulation.diary.get_text() == old_sim.diary.get_text(), "existing diary survives load")
	check(startup.simulation.debug_log.get_text() == old_sim.debug_log.get_text(), "existing log survives load")
	check(startup.game_ui.hero_summary_panel.gold_label.text.contains("123"), "loaded gold is rendered")
	controller.load_candidates(store.candidates("auto"))
	startup.game_ui.set_process(false)
	await settle()
	check(startup.simulation.hero_state.gold == 456, "slots remain independent")
	var before = startup.simulation
	var invalid_candidates: Array[Dictionary] = [{"snapshot": {"invalid": true}}]
	controller.load_candidates(invalid_candidates)
	check(startup.simulation == before, "bad snapshot cannot replace running game")
	await settle()
	startup.free()
	await settle()
	# A fresh startup discovers disk files and Continue reconstructs the latest game.
	startup = load("res://scenes/main/startup.tscn").instantiate()
	startup.save_directory = directory
	root.add_child(startup)
	startup.persistence.set_process(false)
	await settle()
	check(not startup.continue_button.disabled, "continue finds disk saves")
	var saved_stamp = startup.persistence.store.candidates("auto")[0].metadata.saved_at
	startup.new_game_button.pressed.emit()
	await settle()
	check(startup.background_screen.visible, "new game opens questionnaire before overwrite confirmation")
	startup.on_background_completed([0, 0, 3, 1])
	startup.class_screen.selected_class_id = "warrior"
	startup.start_game()
	await settle()
	var confirmation: ConfirmationDialog
	for child in startup.get_children():
		if child is ConfirmationDialog:
			confirmation = child
	check(confirmation != null and confirmation.visible and startup.class_screen.visible and startup.simulation == null, "new game asks after questionnaire before creating replacement")
	if confirmation != null:
		confirmation.canceled.emit()
	await settle()
	check(startup.persistence.store.candidates("auto")[0].metadata.saved_at == saved_stamp, "cancel leaves save untouched")
	startup.continue_button.pressed.emit()
	if startup.game_ui == null:
		printerr("FAIL: Continue did not create a game UI")
		startup.free()
		quit(1)
		return
	startup.game_ui.set_process(false)
	await settle()
	check(startup.simulation.hero_state.gold == 456, "continue chooses latest auto")
	check(not startup.start_menu.visible and startup.game_ui.visible, "continue opens game")
	await settle()
	startup.free()
	await settle()
	print("PASS: real menu save, independent slots, timer auto, detached load, corruption safety and fresh Continue" if failures.is_empty() else "FAIL: persistence UI")
	quit(0 if failures.is_empty() else 1)
