class_name WorldClock
extends RefCounted

signal tick_completed(world_tick: int)

const TICK_DURATION_SECONDS: float = 10.0

var world_tick: int = 0
var elapsed_seconds: float = 0.0

var tick_progress: float:
	get:
		return elapsed_seconds / TICK_DURATION_SECONDS

func advance_time(delta_seconds: float) -> void:
	elapsed_seconds += maxf(0.0, delta_seconds)

	while elapsed_seconds + 0.000001 >= TICK_DURATION_SECONDS:
		elapsed_seconds -= TICK_DURATION_SECONDS
		if is_zero_approx(elapsed_seconds):
			elapsed_seconds = 0.0
		complete_tick()

func complete_tick() -> void:
	world_tick += 1
	tick_completed.emit(world_tick)
