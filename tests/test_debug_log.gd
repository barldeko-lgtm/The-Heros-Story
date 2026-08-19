extends SceneTree

func _init() -> void:
	var debug_log_script: Script = load("res://scripts/narrative/debug_log.gd")
	assert(debug_log_script != null, "DebugLog script must exist.")

	var debug_log: RefCounted = debug_log_script.new()
	debug_log.record_tick(1)
	debug_log.record_tick(2)
	assert(debug_log.get_text() == "Тик 1\nТик 2", "DebugLog must append completed ticks in order.")

	var rolling_log: RefCounted = debug_log_script.new()
	for tick in range(1, 102):
		rolling_log.record_tick(tick)

	assert(not rolling_log.get_text().contains("Тик 1\n"), "Tick 1 must fall outside the last-100-tick window.")
	assert(rolling_log.get_text().begins_with("Тик 2"), "The oldest retained normal tick must be tick 2.")
	assert(rolling_log.get_text().ends_with("Тик 101"), "The newest retained tick must be tick 101.")

	var combat_log: RefCounted = debug_log_script.new()
	for tick in range(1, 101):
		combat_log.record_tick(tick)

	for hit_index in range(25):
		combat_log.record_combat_event("тестовый удар %d" % hit_index, 101)

	assert(combat_log.entries.size() == 124, "Many lines from one fight must count as one world tick, not as 25 separate ticks.")
	assert(combat_log.get_text().contains("тестовый удар 24"), "All lines from the current combat tick must remain visible.")

	combat_log.record_tick(200)
	assert(combat_log.get_text().contains("тестовый удар 24"), "Combat tick 101 must still be visible when tick 200 is the newest tick.")

	combat_log.record_tick(201)
	assert(not combat_log.get_text().contains("тестовый удар"), "Combat tick 101 must disappear only when it becomes older than the 100-tick window.")

	print("PASS: DebugLog retains the last 100 world ticks and counts one fight as one tick.")
	quit()
