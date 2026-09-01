extends SceneTree

const TARGET_SIZE := Vector2i(1366, 768)
const SIDE_MARGIN := 32.0
const PANEL_GAP := 24.0

func _init() -> void:
	call_deferred("run_test")

func require(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error(message)
	quit(1)
	return false

func run_test() -> void:
	if not require(int(ProjectSettings.get_setting("display/window/size/viewport_width")) == TARGET_SIZE.x, "Base viewport width must be 1366 so the UI is not scaled up."):
		return
	if not require(int(ProjectSettings.get_setting("display/window/size/viewport_height")) == TARGET_SIZE.y, "Base viewport height must be 768 so the UI is not scaled up."):
		return
	if not require(int(ProjectSettings.get_setting("display/window/size/window_width_override")) == TARGET_SIZE.x, "Window width must open at 1366."):
		return
	if not require(int(ProjectSettings.get_setting("display/window/size/window_height_override")) == TARGET_SIZE.y, "Window height must open at 768."):
		return

	get_root().size = TARGET_SIZE
	var main_ui_script: Script = load("res://scripts/ui/main_ui.gd")
	var main_ui = main_ui_script.new()
	get_root().add_child(main_ui)
	await process_frame
	await process_frame

	var hero_panel := main_ui.hero_details_label.get_parent() as PanelContainer
	var opponent_panel := main_ui.opponent_details_label.get_parent() as PanelContainer
	var statistics_panel := main_ui.combat_statistics_label.get_parent() as PanelContainer
	var speed_controls := main_ui.find_child("SpeedControls", true, false) as HBoxContainer
	var top_menu := main_ui.find_child("TopMenu", true, false) as HBoxContainer
	var hero_rect: Rect2 = hero_panel.get_rect()
	var god_rect: Rect2 = main_ui.god_panel.get_rect()
	var opponent_rect: Rect2 = opponent_panel.get_rect()
	var statistics_rect: Rect2 = statistics_panel.get_rect()
	print("LAYOUT hero=%s god=%s opponent=%s statistics=%s speed=%s top=%s" % [hero_rect, god_rect, opponent_rect, statistics_rect, speed_controls.get_rect(), top_menu.get_rect()])

	if not require(hero_rect.size.x == 320.0 and hero_rect.end.y <= float(TARGET_SIZE.y) - 16.0, "Hero panel must keep its width and fit inside the taller viewport."):
		return
	if not require(opponent_rect.size == Vector2(320.0, 400.0), "Opponent panel must keep its original size."):
		return
	if not require(is_equal_approx(opponent_rect.end.x, float(TARGET_SIZE.x) - SIDE_MARGIN), "Right panels must keep a 32px screen margin."):
		return
	if not require(opponent_rect.position.x - god_rect.end.x >= PANEL_GAP, "God panel must not overlap the opponent panel."):
		return
	if not require(main_ui.narrative_panel.size.x == main_ui.god_panel.size.x, "Log panel must match the full width of the divine-skill panel."):
		return
	if not require(speed_controls.position.y - statistics_rect.end.y >= 32.0, "Combat statistics must stay clear of speed controls."):
		return
	if not require(absf(top_menu.get_rect().get_center().x - float(TARGET_SIZE.x) * 0.5) <= 1.0, "Top menu must remain centered in the wider viewport."):
		return
	if not require(main_ui.hero_details_label.text.contains("Состояние: Выбирает квест\n\nКвест:"), "A one-line hero state must reserve one blank line before the quest row."):
		return
	main_ui.simulation.hero_state.loop_state = HeroState.DUNGEON_BETWEEN_FIGHTS
	main_ui.update_hero_panel()
	if not require(main_ui.hero_details_label.text.contains("Состояние: В данже — готовится к следующему бою\nКвест:"), "A wrapped hero state must consume the reserved second line instead of shifting later rows."):
		return

	main_ui.free()
	print("PASS: 1366x768 keeps the original UI scale and separates the main-screen panels.")
	quit()
