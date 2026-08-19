extends SceneTree

func _init() -> void:
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	assert(simulation_script != null, "Simulation script must exist.")

	var simulation: RefCounted = simulation_script.new()
	simulation.hero_state.hero_name = "Алексей"
	simulation.advance_time(30.0)
	assert(simulation.debug_log.entries[2] == "Тик 3 — Алексей прибыл к цели.", "Narration must record arrival before the separate combat session.")

	simulation.advance_time(1.5)
	assert(contains_entry(simulation.debug_log.entries, "Алексей начинает бой с Гоблин (1/5)."), "Narration must announce the live combat session.")
	assert(contains_entry(simulation.debug_log.entries, "1.29 с — Алексей"), "Narration must write the hero strike when its internal timer elapses.")

	simulation.set_time_scale(100.0)
	simulation.advance_time(0.2)
	assert(contains_entry(simulation.debug_log.entries, "Алексей победил Гоблин в бою 1/5, получил 50 XP."), "Victory narration must include the awarded mob XP.")

	simulation.advance_time(0.1)
	assert(contains_entry(simulation.debug_log.entries, "Алексей восстановил здоровье:"), "Recovery narration must be added on the following world tick.")
	assert(contains_entry(simulation.debug_log.entries, "Готов к следующему бою."), "Full recovery before the next fight must be explicit in the debug log.")

	print("PASS: QuestNarrator writes live combat actions, XP, and recovery events.")
	quit()

func contains_entry(entries: Array[String], text: String) -> bool:
	for entry in entries:
		if entry.contains(text):
			return true
	return false
