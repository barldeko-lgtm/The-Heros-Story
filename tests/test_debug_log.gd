extends SceneTree

func _init() -> void:
	var debug_log_script: Script = load("res://scripts/narrative/debug_log.gd")
	assert(debug_log_script != null, "DebugLog script must exist.")

	var debug_log: RefCounted = debug_log_script.new()
	debug_log.record_tick(1)
	debug_log.record_tick(2)
	assert(debug_log.get_text() == "Тик 1\nТик 2", "DebugLog must append one Russian line for each completed tick.")

	print("PASS: DebugLog records completed ticks in order.")
	quit()
