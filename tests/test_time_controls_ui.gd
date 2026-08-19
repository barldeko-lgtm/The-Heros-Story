extends SceneTree

func _init() -> void:
	var main_ui_script: Script = load("res://scripts/ui/main_ui.gd")
	assert(main_ui_script != null, "Main UI script must exist.")

	var main_ui: Control = main_ui_script.new()
	main_ui.create_speed_controls()

	var speed_controls: HBoxContainer = main_ui.get_child(0)
	var expected_speeds := ["×0", "×1", "×2", "×5", "×10", "×20", "×100"]
	var actual_speeds: Array[String] = []
	for button in speed_controls.get_children():
		actual_speeds.append(button.text)
	assert(actual_speeds == expected_speeds, "Developer controls must expose pause, x1, x2, x5, x10, x20, and x100.")

	main_ui.set_time_scale(0.0)
	main_ui.simulation.advance_time(10.0)
	assert(main_ui.simulation.world_clock.world_tick == 0, "Pause must prevent world ticks from advancing.")
	assert(main_ui.speed_buttons[0.0].button_pressed, "Pause button must remain selected while paused.")

	main_ui.set_time_scale(100.0)
	main_ui.simulation.advance_time(0.1)
	assert(main_ui.simulation.world_clock.world_tick == 1, "At x100 speed, 0.1 real seconds must advance one world tick.")
	assert(main_ui.speed_buttons[100.0].button_pressed, "x100 button must remain selected at x100 speed.")

	main_ui.free()
	print("PASS: Time controls expose pause and x100 speed.")
	quit()
