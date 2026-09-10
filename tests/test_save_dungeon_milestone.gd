extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("run")

func check(value: bool, message: String) -> void:
	if not value:
		failures.append(message)
		printerr("FAIL: " + message)

func run() -> void:
	var startup = load("res://scenes/main/startup.tscn").instantiate()
	startup.save_directory = "res://.godot/save-dungeon-" + str(Time.get_ticks_usec())
	startup.simulation_seed = 97101
	root.add_child(startup)
	startup.persistence.set_process(false)
	startup.begin_new_game()
	startup.on_background_completed([0, 0, 3, 1])
	startup.class_screen.selected_class_id = "warrior"
	startup.start_game()
	startup.game_ui.set_process(false)
	var simulation = startup.simulation
	simulation.hero_state.strength = 100
	simulation.hero_state.constitution = 200
	var belt_rng := RandomNumberGenerator.new()
	belt_rng.seed = 8100
	var belt = simulation.item_generator.generate(load("res://data/items/visual_families/ironward_vanguard/ironward_belt.tres"), 5, belt_rng)
	simulation.hero_state.equipment.replace_item(belt)
	simulation.hero_state.inventory.add_healing_potion(5)
	simulation.hero_state.prepared_healing_potion_levels = [5]
	simulation.refresh_combat_stats()
	simulation.hero_state.current_hp = simulation.combat_stats.max_hp
	var dungeon = simulation.dungeon_system.get_all_dungeons()[0]
	check(dungeon.discover("save milestone fixture"), "real dungeon discovered")
	check(simulation.world_state.set_hero_position(dungeon.target_hex), "hero at entrance")
	check(simulation.dungeon_runner.begin_trip(simulation.hero_state, dungeon, simulation.get_hero_power()), "domain trip begins")
	check(bool(simulation.dungeon_runner.advance(simulation.hero_state).get("arrived", false)), "domain arrival")
	check(simulation.dungeon_runner.enter(simulation.hero_state), "domain entrance")
	simulation.start_dungeon_combat()
	var controller = startup.persistence
	var before = controller.store.candidates("auto")[0].metadata.saved_at
	controller._process(0.0)
	check(controller.store.candidates("auto")[0].metadata.saved_at == before, "entering a dungeon does not autosave")
	var steps := 0
	while not dungeon.completed and steps < 300:
		simulation.advance_time(10.0)
		controller._process(0.0)
		steps += 1
	check(dungeon.completed, "real fights complete dungeon within bounded fixture")
	var saved = controller.store.candidates("auto")[0]
	check(saved.metadata.saved_at > before, "real completion triggers autosave without timer")
	var restored = controller.SnapshotScript.restore(saved.snapshot)
	check(restored.get("simulation") != null, "milestone save restores")
	if restored.get("simulation") != null:
		var matched := false
		for instance in restored.simulation.dungeon_system.get_all_dungeons():
			if instance.definition.id == dungeon.definition.id:
				matched = instance.completed
		check(matched, "saved dungeon completion survives load")
	controller._process(0.0)
	check(controller.store.candidates("auto")[0].metadata.saved_at == saved.metadata.saved_at, "same completion does not resave every frame")
	startup.free()
	await process_frame
	print("PASS: real dungeon completion triggers one restorable milestone autosave" if failures.is_empty() else "FAIL: dungeon autosave")
	quit(0 if failures.is_empty() else 1)
