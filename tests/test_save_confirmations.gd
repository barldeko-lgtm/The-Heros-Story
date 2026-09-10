extends SceneTree

const Store = preload("res://scripts/core/save_store.gd")
const Snapshot = preload("res://scripts/core/simulation_snapshot.gd")
const Sim = preload("res://scripts/core/simulation.gd")
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("run")

func check(value: bool, message: String) -> void:
	if not value:
		failures.append(message)
		printerr("FAIL: " + message)

func settle() -> void:
	await process_frame
	await process_frame
	await process_frame

func modal(parent: Node) -> AcceptDialog:
	for child in parent.get_children():
		if child is AcceptDialog and child.visible and not child.is_queued_for_deletion():
			return child
	return null

func dismiss(parent: Node) -> void:
	var dialog := modal(parent)
	if dialog != null:
		dialog.hide()
		dialog.canceled.emit()

func run() -> void:
	var directory := "res://.godot/save-confirmations-" + str(Time.get_ticks_usec())
	var store = Store.new(directory)
	var original = Sim.new(24680)
	original.hero_state.gold = 321
	check(not store.write_slot("manual", Snapshot.capture(original), "Original", 1).has("error"), "manual fixture written")
	var manual_stamp = store.candidates("manual")[0].metadata.saved_at
	var startup = load("res://scenes/main/startup.tscn").instantiate()
	startup.save_directory = directory
	root.add_child(startup)
	startup.persistence.set_process(false)
	await settle()
	startup.new_game_button.pressed.emit()
	check(modal(startup) == null and startup.background_screen.visible, "manual-only history does not ask for auto replacement")
	startup.on_background_completed([0, 0, 3, 1])
	startup.class_screen.selected_class_id = "warrior"
	startup.start_game()
	check(startup.game_ui != null and modal(startup) == null, "manual-only history allows creation directly")
	if startup.game_ui == null:
		startup.free()
		quit(1)
		return
	startup.game_ui.set_process(false)
	check(store.candidates("manual")[0].metadata.saved_at == manual_stamp, "creation preserves manual slot")
	var controller = startup.persistence
	startup.game_ui.open_game_menu()
	startup.simulation.hero_state.gold = 654
	controller.request_manual_save()
	var dialog := modal(startup.game_ui.game_menu)
	check(dialog is ConfirmationDialog, "manual overwrite asks")
	check(store.candidates("manual")[0].metadata.saved_at == manual_stamp, "no write before confirmation")
	dismiss(startup.game_ui.game_menu)
	await settle()
	check(store.candidates("manual")[0].metadata.saved_at == manual_stamp, "cancel preserves manual")
	controller.request_manual_save()
	dialog = modal(startup.game_ui.game_menu)
	if dialog != null:
		dialog.hide()
		dialog.confirmed.emit()
	await settle()
	check(Snapshot.restore(store.candidates("manual")[0].snapshot).simulation.hero_state.gold == 654, "confirmed manual saves current state")
	dismiss(startup.game_ui.game_menu)
	await settle()
	startup.simulation.hero_state.gold = 999
	var previous = startup.simulation
	controller.request_load()
	dialog = modal(startup.game_ui.game_menu)
	if dialog != null:
		var button = dialog.find_child("manual", true, false)
		check(button is Button, "manual picker button exists")
		if button is Button:
			button.pressed.emit()
	await settle()
	dialog = modal(startup.game_ui.game_menu)
	check(dialog is ConfirmationDialog and startup.simulation == previous, "picker asks before replacing running state")
	if dialog != null:
		dialog.hide()
		dialog.confirmed.emit()
	startup.game_ui.set_process(false)
	await settle()
	check(startup.simulation != previous and startup.simulation.hero_state.gold == 654, "actual picker confirmation loads manual")
	check(startup.game_ui.hero_summary_panel.gold_label.text.contains("654"), "picker refreshes rendered gold")
	# A checksum-valid but invalid latest graph must fall back to the prior copy.
	check(not store.write_slot("manual", {"invalid": true}, "Broken", 1).has("error"), "malformed primary fixture written")
	controller.load_candidates(store.candidates("manual"))
	startup.game_ui.set_process(false)
	await settle()
	check(startup.simulation.hero_state.gold == 654, "invalid primary restores previous valid graph")
	var fallback_notice := modal(startup.game_ui.game_menu)
	check(fallback_notice != null and fallback_notice.dialog_text.contains("резервная"), "backup recovery is disclosed")
	dismiss(startup.game_ui.game_menu)
	await settle()
	# A normal file cannot be a save directory: exercise failure without quitting.
	controller.store = Store.new(store.slot_path("manual"))
	controller.request_exit()
	check(not controller.pending_quit and startup.game_ui.game_menu.visible, "failed exit save cancels quit and pauses game")
	check(modal(startup.game_ui.game_menu) != null, "failed exit explains error")
	startup.free()
	await settle()
	# Existing auto slot: cancellation keeps class selection; acceptance creates once.
	startup = load("res://scenes/main/startup.tscn").instantiate()
	startup.save_directory = directory
	root.add_child(startup)
	startup.persistence.set_process(false)
	await settle()
	var auto_stamp = store.candidates("auto")[0].metadata.saved_at
	startup.new_game_button.pressed.emit()
	startup.on_background_completed([0, 0, 3, 1])
	startup.class_screen.selected_class_id = "warrior"
	startup.class_screen.completed.emit()
	check(modal(startup) is ConfirmationDialog and startup.simulation == null, "class completion asks before replacement")
	dismiss(startup)
	await settle()
	check(startup.class_screen.visible and store.candidates("auto")[0].metadata.saved_at == auto_stamp, "cancel stays at class screen without writing")
	startup.class_screen.completed.emit()
	dialog = modal(startup)
	if dialog != null:
		dialog.hide()
		dialog.confirmed.emit()
	check(startup.game_ui != null, "retry confirmation creates game")
	if startup.game_ui != null:
		startup.game_ui.set_process(false)
	check(store.candidates("auto")[0].metadata.saved_at > auto_stamp, "accepted new game replaces auto")
	check(Snapshot.restore(store.candidates("manual")[1].snapshot).simulation.hero_state.gold == 654, "new history preserves manual content")
	startup.free()
	await settle()
	print("PASS: new-game/manual/load confirmations, cancellation, slot preservation and failed-close safety" if failures.is_empty() else "FAIL: save confirmations")
	quit(0 if failures.is_empty() else 1)
