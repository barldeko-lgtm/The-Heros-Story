extends SceneTree

func _init() -> void:
	var clock_script: Script = load("res://scripts/core/world_clock.gd")
	assert(clock_script != null, "WorldClock script must exist.")

	var clock: RefCounted = clock_script.new()
	assert(clock.world_tick == 0, "A new WorldClock must start at tick 0.")

	clock.advance_time(9.9)
	assert(clock.world_tick == 0, "WorldClock must not advance before ten seconds elapse.")
	assert(is_equal_approx(clock.tick_progress, 0.99), "Tick progress must represent elapsed time.")

	clock.advance_time(0.1)
	assert(clock.world_tick == 1, "WorldClock must advance after ten seconds elapse.")
	assert(is_zero_approx(clock.tick_progress), "Tick progress must reset after a completed tick.")

	print("PASS: WorldClock advances every ten seconds and resets progress.")
	quit()
