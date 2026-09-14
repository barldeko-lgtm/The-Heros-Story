extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const Snapshot = preload("res://scripts/core/simulation_snapshot.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var quest = load("res://data/quests/0002_wolf_hunt.tres").duplicate(true)
	var dying = SimulationScript.new(9165, quest)
	dying.hero_state.loop_state = HeroState.DOING_QUEST
	dying.hero_state.active_quest = dying.quest_runner.quest_definition
	dying.hero_state.current_hp = 1.0
	dying.quest_runner.quest_definition.mob_definition.attack = 500.0
	dying.start_combat()
	dying.advance_active_combat(10.0)
	assert(dying.hero_state.loop_state == HeroState.DEAD_RESPAWNING)
	assert(dying.downtime_ticks.dead == 0, "The lethal fight is a combat tick, not a dead tick.")
	dying.set_time_scale(0.0)
	dying.advance_time(1000.0)
	assert(dying.downtime_ticks.dead == 0)
	dying.set_time_scale(1.0)
	for index in 100:
		dying.advance_time(10.0)
	assert(dying.downtime_ticks.dead == 100, "Include the final resurrection countdown tick.")
	assert(dying.hero_state.loop_state != HeroState.DEAD_RESPAWNING)
	dying.advance_time(10.0)
	assert(dying.downtime_ticks.dead == 100, "City healing is not death time.")
	var idle = SimulationScript.new(9170, null)
	idle.quest_pool.available_quests.clear()
	idle.hero_state.loop_state = HeroState.CHOOSING_QUEST
	idle.advance_time(30.0)
	assert(idle.downtime_ticks.no_quest == 3)
	idle.set_time_scale(2.0)
	idle.advance_time(10.0)
	assert(idle.downtime_ticks.no_quest == 5 and idle.world_clock.world_tick == 5)
	idle.set_time_scale(0.0)
	idle.advance_time(100.0)
	assert(idle.downtime_ticks.no_quest == 5)
	var saved: Dictionary = Snapshot.capture(idle)
	var restored: Dictionary = Snapshot.restore(saved)
	assert(restored.error.is_empty() and restored.simulation.downtime_ticks == idle.downtime_ticks)
	var legacy: Dictionary = saved.duplicate(true)
	legacy.version = 5
	for node in legacy.nodes:
		if node.get("script", "") == "res://scripts/core/simulation.gd":
			node.properties.erase("downtime_ticks")
	var migrated: Dictionary = Snapshot.restore(legacy)
	assert(migrated.error.is_empty())
	assert(migrated.simulation.downtime_ticks.start_tick == 5 and migrated.simulation.downtime_ticks.no_quest == 0)
	var ui = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(ui)
	ui.set_process(false)
	await process_frame
	ui.statistics_button.pressed.emit()
	assert(ui.downtime_label.text.contains("0.0%"))
	ui.simulation.world_clock.world_tick = 200
	ui.simulation.downtime_ticks = {"dead": 100, "no_quest": 20, "start_tick": 0}
	ui.refresh_visible_screen()
	assert(ui.downtime_label.text.contains("100 тиков (50.0%)"))
	assert(ui.downtime_label.text.contains("20 тиков (10.0%)"))
	await process_frame
	await process_frame
	assert(not ui.downtime_label.get_parent().get_global_rect().intersects(ui.equipment_origin_label.get_parent().get_global_rect()))
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/downtime-statistics.png")
	await process_frame
	await process_frame
	await process_frame
	ui.free()
	print("PASS: Death tick boundaries, recovery excluded, no-quest waits, pause/speed, persistence and percentage UI.")
	quit()
