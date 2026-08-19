extends SceneTree

func _init() -> void:
	var seeded_rng_script: Script = load("res://scripts/core/seeded_rng.gd")
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	assert(seeded_rng_script != null, "SeededRng script must exist.")
	assert(simulation_script != null, "Simulation script must exist.")

	var first_rng = seeded_rng_script.new(424242).get_rng()
	var second_rng = seeded_rng_script.new(424242).get_rng()
	for _index in 16:
		assert(first_rng.randi() == second_rng.randi(), "Equal seeds must reproduce the same random sequence.")

	var first_simulation: RefCounted = simulation_script.new(987654)
	var second_simulation: RefCounted = simulation_script.new(987654)
	assert(first_simulation.hero_state.hero_name == second_simulation.hero_state.hero_name, "Equal simulation seeds must reproduce the hero name.")

	first_simulation.advance_time(30.0)
	second_simulation.advance_time(30.0)
	first_simulation.set_time_scale(100.0)
	second_simulation.set_time_scale(100.0)
	first_simulation.advance_time(0.2)
	second_simulation.advance_time(0.2)

	assert(first_simulation.hero_state.current_hp == second_simulation.hero_state.current_hp, "Equal seeds must reproduce combat outcomes.")
	assert(first_simulation.debug_log.get_text() == second_simulation.debug_log.get_text(), "Equal seeds and equal simulation steps must reproduce the same current log.")

	print("PASS: The current simulation randomness is reproducible from one shared seed.")
	quit()
