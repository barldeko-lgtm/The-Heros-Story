extends SceneTree

func _init() -> void:
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	var wolf = load("res://data/mobs/0002_wolf.tres")
	assert(simulation_script != null, "Simulation script must exist.")
	assert(wolf != null, "Wolf definition must exist.")

	var simulation: RefCounted = simulation_script.new(12345)
	var line_1: String = simulation.record_combat_result(wolf, true)
	var line_2: String = simulation.record_combat_result(wolf, false)
	var line_3: String = simulation.record_combat_result(wolf, true)

	var stats: Dictionary = simulation.get_combat_results("wolf")
	assert(stats["total"] == 3, "Combat statistics must count all fights.")
	assert(stats["wins"] == 2, "Combat statistics must count hero wins.")
	assert(stats["losses"] == 1, "Combat statistics must count hero losses.")
	assert(line_1.contains("1 боёв"), "First summary must show one fight.")
	assert(line_2.contains("winrate 50.0%"), "One win and one loss must show 50% winrate.")
	assert(line_3.contains("побед 2"), "Third summary must show two wins.")

	print("PASS: Combat statistics count fights, wins, losses, and winrate.")
	quit()
