extends SceneTree

const GOD_SCENE_PATH := "res://scenes/ui/components/god_panel.tscn"
const GOD_SCRIPT_PATH := "res://scripts/ui/components/god_panel.gd"
const NARRATIVE_SCENE_PATH := "res://scenes/ui/components/narrative_panel.tscn"
const NARRATIVE_SCRIPT_PATH := "res://scripts/ui/components/narrative_panel.gd"

func _init() -> void:
	call_deferred("run_test")

func fail_test(message: String) -> void:
	push_error(message)
	quit(1)

func run_test() -> void:
	for path in [GOD_SCENE_PATH, GOD_SCRIPT_PATH, NARRATIVE_SCENE_PATH, NARRATIVE_SCRIPT_PATH]:
		if not ResourceLoader.exists(path):
			fail_test("Extracted UI component is missing: %s" % path)
			return

	var main_ui_script: Script = load("res://scripts/ui/main_ui.gd")
	if main_ui_script == null:
		fail_test("Main UI must still load after component extraction.")
		return
	var main_ui = main_ui_script.new()
	get_root().add_child(main_ui)
	await process_frame

	var god_panel = main_ui.god_panel
	var narrative_panel = main_ui.narrative_panel
	if god_panel == null or narrative_panel == null:
		fail_test("MainUI must instantiate both extracted components.")
		return
	assert(god_panel.get_script().resource_path == GOD_SCRIPT_PATH, "GodPanel must own its extracted presentation script.")
	assert(narrative_panel.get_script().resource_path == NARRATIVE_SCRIPT_PATH, "NarrativePanel must own its extracted presentation script.")
	assert(god_panel.position == Vector2(380.0, 80.0) and god_panel.size == Vector2(520.0, 235.0), "GodPanel geometry must remain unchanged.")
	assert(narrative_panel.position == Vector2(380.0, 400.0) and narrative_panel.size == Vector2(520.0, 250.0), "NarrativePanel geometry must remain unchanged.")

	assert(is_equal_approx(god_panel.god_energy_bar.max_value, 100.0), "Extracted GodPanel must retain the energy scale.")
	assert(god_panel.divine_healing_button.disabled, "Healing must remain disabled at full HP.")
	assert(not god_panel.combat_buff_button.disabled, "Combat blessing must remain available at startup.")
	god_panel.combat_buff_button.pressed.emit()
	assert(main_ui.simulation.get_combat_buff_fights_remaining() == 5, "Extracted GodPanel must still send blessing commands through Simulation.")
	assert(god_panel.combat_buff_button.text.contains("Боёв: 5"), "Extracted GodPanel must refresh blessing status immediately.")

	var log_text_edit := narrative_panel.log_text_edit as TextEdit
	assert(log_text_edit != null and narrative_panel.find_child("Дневник", true, false) != null, "NarrativePanel must retain Log and Diary tabs.")
	var lines: PackedStringArray = []
	for index in 40:
		lines.append("Запись %d — %s" % [index, "длинная строка журнала ".repeat(12)])
	narrative_panel.update_debug_log("\n".join(lines))
	await process_frame
	await process_frame
	var scroll_bar: VScrollBar = log_text_edit.get_v_scroll_bar()
	var bottom_value: float = maxf(scroll_bar.min_value, scroll_bar.max_value - scroll_bar.page)
	assert(scroll_bar.value >= bottom_value - 0.01, "Extracted NarrativePanel must keep wrapped log output pinned to the bottom.")

	await process_frame
	main_ui.free()
	print("PASS: MainUI delegates god controls and narrative log presentation to dedicated components.")
	quit()
