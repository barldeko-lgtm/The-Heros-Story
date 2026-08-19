extends SceneTree

func _init() -> void:
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	assert(simulation_script != null, "Simulation script must exist.")

	var simulation: RefCounted = simulation_script.new()
	for _frame in 3000:
		simulation.advance_time(1.0 / 60.0)

	assert(simulation.world_clock.world_tick >= 3, "The frame-step probe must reach the first combat.")
	assert(simulation.hero_state.experience >= 50, "Frame-step simulation must exit combat instead of hanging.")
	print("PASS: Frame-step simulation reaches and exits combat without hanging.")
	quit()
