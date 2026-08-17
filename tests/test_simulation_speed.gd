extends SceneTree

func _init() -> void:
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	assert(simulation_script != null, "Simulation script must exist.")

	var simulation: RefCounted = simulation_script.new()
	assert(is_equal_approx(simulation.time_scale, 1.0), "Simulation must start at x1 speed.")

	simulation.set_time_scale(5.0)
	simulation.advance_time(2.0)
	assert(simulation.world_clock.world_tick == 1, "At x5 speed, two real seconds must advance one world tick.")

	simulation.set_time_scale(20.0)
	simulation.advance_time(0.5)
	assert(simulation.world_clock.world_tick == 2, "At x20 speed, half a real second must advance one world tick.")

	print("PASS: Simulation speed multipliers accelerate world ticks.")
	quit()
