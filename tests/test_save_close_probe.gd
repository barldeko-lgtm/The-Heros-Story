extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var directory := "res://.godot/save-close-test"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--directory="):
			directory = argument.trim_prefix("--directory=")
	if OS.get_cmdline_user_args().has("--verify"):
		var store = preload("res://scripts/core/save_store.gd").new(directory)
		var candidate = store.candidates("auto")
		var ok: bool = not candidate.is_empty()
		if ok:
			var result = preload("res://scripts/core/simulation_snapshot.gd").restore(candidate[0].snapshot)
			ok = result.get("simulation") != null and result.simulation.hero_state.gold == 987
		print("PASS: normal exit persisted latest state, restored in separate process" if ok else "FAIL: exit save")
		quit(0 if ok else 1)
		return
	var startup = load("res://scenes/main/startup.tscn").instantiate()
	startup.save_directory = directory
	root.add_child(startup)
	await process_frame
	startup.begin_new_game()
	startup.on_background_completed([0, 0, 3, 1])
	startup.class_screen.selected_class_id = "warrior"
	startup.start_game()
	startup.game_ui.set_process(false)
	startup.simulation.hero_state.gold = 987
	startup.persistence.request_exit()
