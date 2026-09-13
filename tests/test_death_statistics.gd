extends SceneTree

const Summary = preload("res://scripts/combat/death_statistics.gd")
const Snapshot = preload("res://scripts/core/simulation_snapshot.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	# Exercise the real lethal-combat commit path, not only direct record calls.
	var quest = load("res://data/quests/0002_wolf_hunt.tres").duplicate(true)
	var lethal = load("res://scripts/core/simulation.gd").new(9165, quest)
	lethal.hero_state.loop_state = HeroState.DOING_QUEST
	lethal.hero_state.active_quest = lethal.quest_runner.quest_definition
	lethal.hero_state.current_hp = 1.0
	lethal.quest_runner.quest_definition.mob_definition.attack = 500.0
	lethal.start_combat()
	lethal.advance_active_combat(10.0)
	assert(Summary.summarize(lethal.combat_results_by_mob).quest == 1)
	lethal.advance_time(0.1)
	assert(Summary.summarize(lethal.combat_results_by_mob).total == 1)
	var ui = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(ui)
	ui.set_process(false)
	await process_frame
	var simulation = ui.simulation
	ui.statistics_button.pressed.emit()
	assert(ui.death_statistics_label.text.contains("Пока никто"))
	assert(not ui.death_statistics_label.text.contains("Без данных"))
	var mob = load("res://data/mobs/0006_bandit.tres")
	for activity in ["quest", "dungeon", "event", "event"]:
		simulation.record_combat_result(mob, false, activity)
	simulation.record_combat_result(mob, true, "quest")
	var summary: Dictionary = Summary.summarize(simulation.combat_results_by_mob)
	assert(summary.total == 4 and summary.quest == 1 and summary.dungeon == 1 and summary.event == 2)
	assert(summary.killer_deaths == 4 and summary.killer_name == mob.display_name)
	# Older records have losses but no activity breakdown. Never invent their context.
	simulation.combat_results_by_mob["aaa_legacy"] = {"display_name": "Старый противник", "total": 4, "wins": 0, "losses": 4}
	summary = Summary.summarize(simulation.combat_results_by_mob)
	assert(summary.total == 8 and summary.unknown == 4)
	assert(summary.killer_name == "Старый противник", "Ties use stable mob ID order.")
	var reordered: Dictionary = {}
	var keys: Array = simulation.combat_results_by_mob.keys()
	keys.reverse()
	for key in keys:
		reordered[key] = simulation.combat_results_by_mob[key]
	assert(Summary.summarize(reordered) == summary)
	var restored: Dictionary = Snapshot.restore(Snapshot.capture(simulation))
	assert(restored.get("error", "").is_empty())
	assert(Summary.summarize(restored.simulation.combat_results_by_mob) == summary)
	ui.refresh_visible_screen()
	assert(ui.death_statistics_label.text.contains("Без данных об активности: 4"))
	assert(ui.death_statistics_label.text.contains("В событиях: 2"))
	await process_frame
	await process_frame
	assert(not ui.death_statistics_label.get_parent().get_global_rect().intersects(ui.combat_statistics_label.get_parent().get_global_rect()))
	assert(ui.death_statistics_label.size.y <= ui.death_statistics_label.get_parent().size.y)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/death-statistics.png")
	await process_frame
	await process_frame
	await process_frame
	ui.free()
	print("PASS: Activity deaths, wins excluded, stable top killer, legacy unknowns, persistence and statistics UI.")
	quit()
