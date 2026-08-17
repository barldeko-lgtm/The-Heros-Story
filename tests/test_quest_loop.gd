extends SceneTree

func _init() -> void:
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	assert(simulation_script != null, "Simulation script must exist.")

	var simulation: RefCounted = simulation_script.new()
	for _tick in 7:
		simulation.advance_time(10.0)

	assert(simulation.hero_state.loop_state == "CHOOSING_QUEST", "Hero must return to quest selection after turning in the quest.")
	assert(simulation.hero_state.gold == 20, "Hero must receive 20 gold only after quest turn-in.")

	var expected_log := [
		"Тик 1 — Герой выбрал квест «Проблема у восточной дороги».",
		"Тик 2 — Герой идёт к цели. Осталось: 1 км.",
		"Тик 3 — Герой прибыл к цели.",
		"Тик 4 — Герой выполнил задание «Проблема у восточной дороги». Бой будет добавлен позже.",
		"Тик 5 — Герой возвращается в город. Осталось: 1 км.",
		"Тик 6 — Герой вернулся в город.",
		"Тик 7 — Герой сдал квест «Проблема у восточной дороги» и получил 20 золота.",
	]
	assert(simulation.debug_log.entries == expected_log, "Quest loop must produce the approved sequence of log entries.")

	print("PASS: Quest loop travels, completes the placeholder quest, returns, and grants gold.")
	quit()
