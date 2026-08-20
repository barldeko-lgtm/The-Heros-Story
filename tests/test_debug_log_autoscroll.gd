extends SceneTree

func _init() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var main_ui_script: Script = load("res://scripts/ui/main_ui.gd")
	assert(main_ui_script != null, "Main UI script must exist.")
	var main_ui: Control = main_ui_script.new()
	get_root().add_child(main_ui)
	main_ui.create_narrative_panel()
	await process_frame

	var lines: PackedStringArray = []
	for index in 40:
		lines.append("Запись %d — %s" % [index, "очень длинная строка лога ".repeat(12)])
	main_ui.update_debug_log("\n".join(lines))
	await process_frame
	await process_frame

	var scroll_bar: VScrollBar = main_ui.log_text_edit.get_v_scroll_bar()
	var bottom_value: float = maxf(scroll_bar.min_value, scroll_bar.max_value - scroll_bar.page)
	assert(scroll_bar.value >= bottom_value - 0.01, "Every new log update must scroll the wrapped TextEdit to its actual bottom after layout.")

	main_ui.free()
	print("PASS: Debug log stays pinned to the newest wrapped entry after layout.")
	quit()
