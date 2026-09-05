extends SceneTree

func _init() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var main_ui_script: Script = load("res://scripts/ui/main_ui.gd")
	assert(main_ui_script != null, "Main UI script must exist.")
	var main_ui: Control = main_ui_script.new()
	get_root().add_child(main_ui)
	await process_frame

	var narrative_panel = main_ui.narrative_panel
	assert(narrative_panel != null, "MainUI must instantiate the extracted NarrativePanel.")
	var lines: PackedStringArray = []
	for index in 40:
		lines.append("Запись %d — %s" % [index, "очень длинная строка лога ".repeat(12)])
	var first_text := "\n".join(lines)
	narrative_panel.update_debug_log(first_text)
	await process_frame
	await process_frame

	var scroll_bar: VScrollBar = narrative_panel.log_text_edit.get_v_scroll_bar()
	var bottom_value: float = maxf(scroll_bar.min_value, scroll_bar.max_value - scroll_bar.page)
	assert(scroll_bar.value >= bottom_value - 0.01, "Every new log update must scroll the wrapped TextEdit to its actual bottom after layout.")

	var previous_scroll_value: float = scroll_bar.value
	narrative_panel.update_debug_log(first_text)
	assert(is_equal_approx(scroll_bar.value, previous_scroll_value), "Re-rendering identical debug-log text must not reset the scroll position.")

	lines.append("Самая новая запись")
	narrative_panel.update_debug_log("\n".join(lines))
	assert(scroll_bar.value >= previous_scroll_value - 0.01, "A real new log entry must remain pinned near the current bottom immediately instead of visibly jumping to the top.")
	await process_frame
	await process_frame
	bottom_value = maxf(scroll_bar.min_value, scroll_bar.max_value - scroll_bar.page)
	assert(scroll_bar.value >= bottom_value - 0.01, "A real new log entry must settle at the actual wrapped bottom after layout.")

	await process_frame
	main_ui.free()
	print("PASS: Debug log stays pinned to newest entries without redundant top-to-bottom jumps.")
	quit()
