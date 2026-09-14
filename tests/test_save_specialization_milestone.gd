extends SceneTree

const HeroSpecializationScript = preload("res://scripts/hero/hero_specialization.gd")

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("run")

func check(value: bool, message: String) -> void:
	if not value:
		failures.append(message)
		printerr("FAIL: " + message)

func run() -> void:
	var startup = load("res://scenes/main/startup.tscn").instantiate()
	startup.save_directory = "res://.godot/save-specialization-" + str(Time.get_ticks_usec())
	startup.simulation_seed = 97102
	root.add_child(startup)
	startup.persistence.set_process(false)
	startup.begin_new_game()
	startup.on_background_completed([0, 0, 3, 1])
	startup.class_screen.selected_class_id = "warrior"
	startup.start_game()
	startup.game_ui.set_process(false)

	var controller = startup.persistence
	var simulation = startup.simulation
	var hero = simulation.hero_state
	var initial_auto = controller.store.candidates("auto")[0]
	var initial_restore = controller.SnapshotScript.restore(initial_auto.snapshot)
	check(initial_restore.get("simulation") != null and initial_restore.simulation.hero_state.hero_class_id == "warrior", "initial autosave stores the Warrior before specialization")

	hero.first_specialization_id = HeroSpecializationScript.PROTECTOR_ID
	controller._process(0.0)
	var target_only_auto = controller.store.candidates("auto")[0]
	var target_only_restore = controller.SnapshotScript.restore(target_only_auto.snapshot)
	check(
		target_only_restore.get("simulation") != null \
			and target_only_restore.simulation.hero_state.hero_class_id == "warrior" \
			and target_only_restore.simulation.hero_state.first_specialization_id.is_empty(),
		"choosing only the specialization target must not trigger the gained-specialization autosave"
	)

	var granted_id: String = HeroSpecializationScript.grant_selected_specialization(hero)
	check(granted_id == HeroSpecializationScript.PROTECTOR_ID, "fixture grants the selected Protector specialization")
	simulation.diary_recorder.record_specialization_gained_diary_entry(
		hero.hero_name,
		HeroSpecializationScript.get_class_display_name(granted_id),
		100
	)
	controller._process(0.0)

	var milestone_auto = controller.store.candidates("auto")[0]
	var restored = controller.SnapshotScript.restore(milestone_auto.snapshot)
	check(restored.get("simulation") != null, "specialization milestone autosave restores")
	if restored.get("simulation") != null:
		check(restored.simulation.hero_state.hero_class_id == HeroSpecializationScript.PROTECTOR_ID, "specialization milestone autosave contains the granted class")
		check(restored.simulation.diary.get_text().contains("получил специализацию «Защитник»"), "specialization milestone autosave contains the Diary milestone")

	hero.gold += 1
	controller._process(0.0)
	var no_repeat_auto = controller.store.candidates("auto")[0]
	var no_repeat_restore = controller.SnapshotScript.restore(no_repeat_auto.snapshot)
	check(no_repeat_restore.get("simulation") != null and no_repeat_restore.simulation.hero_state.gold != hero.gold, "the same gained specialization does not autosave again every frame")

	startup.free()
	await process_frame
	print("PASS: gaining the first specialization triggers one restorable autosave and preserves its Diary milestone" if failures.is_empty() else "FAIL: specialization milestone autosave")
	quit(0 if failures.is_empty() else 1)
