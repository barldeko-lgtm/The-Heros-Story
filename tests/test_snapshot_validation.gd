extends SceneTree

const SimulationSnapshot = preload("res://scripts/core/simulation_snapshot.gd")
const SimulationScript = preload("res://scripts/core/simulation.gd")
var failures := 0

func _init() -> void:
	var captured := fixture()
	assert_missing_property_is_rejected(captured)
	assert_invalid(captured, func(snapshot): snapshot.erase("root"), "missing envelope root")
	assert_invalid(captured, func(snapshot): snapshot.erase("version"), "missing envelope version")
	assert_invalid(captured, func(snapshot): snapshot["nodes"][0]["properties"]["world_clock"] = null, "null required clock")
	assert_invalid(captured, func(snapshot): snapshot["nodes"][0]["properties"]["world_clock"] = snapshot["nodes"][0]["properties"]["hero_state"], "wrong object class for clock")
	assert_invalid(captured, func(snapshot): snapshot["version"] = [], "malformed envelope version")
	assert_invalid(captured, func(snapshot): snapshot["root"] = {"ref": "zero"}, "non-integer root reference")
	assert_invalid(captured, func(snapshot): snapshot["nodes"][0]["properties"]["not_a_simulation_property"] = 1, "unknown object property")
	assert_invalid(captured, func(snapshot): snapshot["nodes"][0].erase("properties"), "missing object properties")
	assert_invalid(captured, func(snapshot): snapshot["nodes"][0]["properties"]["time_scale"] = {"array": "not an array"}, "malformed encoded array")
	assert_invalid(captured, func(snapshot): snapshot["nodes"][0]["properties"]["time_scale"] = {"vector2i": [1]}, "malformed encoded vector")
	assert_invalid(captured, func(snapshot): snapshot["nodes"][0]["properties"]["time_scale"] = {"unknown": 1}, "unknown encoded container")
	assert_invalid(captured, func(snapshot): snapshot["nodes"][0]["properties"]["world_clock"] = {"ref": 999999}, "out-of-range reference")
	assert_invalid(captured, func(snapshot): snapshot["nodes"][0]["properties"]["world_clock"] = {"ref": "invalid"}, "non-integer reference")
	var hero_id: int = captured.nodes[0].properties.hero_state.ref
	assert_invalid(captured, func(snapshot): snapshot.nodes[hero_id].properties.active_effects = {"array": [1]}, "wrong typed-array element")
	assert_invalid(captured, func(snapshot): snapshot.nodes[hero_id].properties.background_answers = {"array": ["bad"]}, "wrong background answer type")
	var rng_id := find_rng_node(captured)
	assert(rng_id >= 0, "Fixture must contain a RNG node.")
	assert_invalid(captured, func(snapshot): snapshot["nodes"][rng_id]["seed"] = "invalid", "malformed RNG seed")
	assert_invalid(captured, func(snapshot): snapshot["nodes"][rng_id]["state"] = [], "malformed RNG state")
	assert_invalid(captured, func(snapshot): snapshot["nodes"][0]["properties"]["time_scale"] = "fast", "wrong scalar property type")
	assert_invalid(captured, func(snapshot): snapshot["nodes"][0]["properties"]["world_clock"] = true, "wrong untyped reference property type")
	if failures == 0:
		print("PASS: Simulation snapshot rejects malformed state before restore.")
	quit(0 if failures == 0 else 1)

func fixture() -> Dictionary:
	var simulation = SimulationScript.new(24680)
	advance_until_combat(simulation)
	var captured: Dictionary = SimulationSnapshot.capture(simulation)
	assert(str(captured.get("error", "")).is_empty(), "Fixture capture must succeed.")
	return captured

func assert_missing_property_is_rejected(captured: Dictionary) -> void:
	var legacy: Dictionary = captured.duplicate(true)
	legacy["nodes"][0]["properties"].erase("time_scale")
	var result: Dictionary = SimulationSnapshot.restore(legacy)
	if result.get("simulation") != null or str(result.get("error", "")).is_empty():
		printerr("FAIL: missing serialized property must be rejected, not replaced with constructor defaults")
		failures += 1

func assert_invalid(captured: Dictionary, mutate: Callable, label: String) -> void:
	var malformed: Dictionary = captured.duplicate(true)
	mutate.call(malformed)
	var result: Dictionary = SimulationSnapshot.restore(malformed)
	if result.get("simulation") != null or str(result.get("error", "")).is_empty():
		failures += 1
		printerr("FAIL: %s must reject with an error" % label)

func find_rng_node(captured: Dictionary) -> int:
	for index in captured["nodes"].size():
		if captured["nodes"][index] is Dictionary and captured["nodes"][index].get("type") == "rng":
			return index
	return -1

func advance_until_combat(simulation) -> void:
	var guard := 0
	while simulation.active_combat_session == null and guard < 20:
		simulation.advance_time(10.0)
		guard += 1
