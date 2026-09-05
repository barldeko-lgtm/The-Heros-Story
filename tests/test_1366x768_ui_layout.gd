extends SceneTree

const TraitDevelopmentScript = preload("res://scripts/hero/trait_development.gd")

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
	var attribute_panel := main_ui.find_child("AttributeAllocationPanel", true, false) as PanelContainer
	var personality_panel := main_ui.find_child("PersonalityAxesPanel", true, false) as PanelContainer
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
	if not require(attribute_panel != null and attribute_panel.get_rect().end.y <= float(TARGET_SIZE.y) - 16.0, "Primary-attribute allocation controls must fit inside the dedicated Hero screen at 1366x768."):
		return
		if not require(personality_panel != null and personality_panel.get_rect().end.y <= float(TARGET_SIZE.y) - 16.0, "Live personality axes must fit inside the dedicated Hero screen at 1366x768."):
			return
		var personality_axes := {
			"CouragePersonalityAxis": TraitDevelopmentScript.AXIS_COURAGE,
			"MoralityPersonalityAxis": TraitDevelopmentScript.AXIS_MORALITY,
			"GreedPersonalityAxis": TraitDevelopmentScript.AXIS_GREED,
			"CuriosityPersonalityAxis": TraitDevelopmentScript.AXIS_CURIOSITY,
		}
		for axis_name in personality_axes:
			var axis := personality_panel.find_child(axis_name, true, false)
			var marker := axis.find_child("ValueMarker", true, false) as ColorRect if axis != null else null
			var bar := axis.find_child("AxisBar", true, false) as ColorRect if axis != null else null
			var value_label := axis.find_child("CurrentValueLabel", true, false) as Label if axis != null else null
			var center_zero := axis.find_child("CenterZeroLabel", true, false) as Label if axis != null else null
			if not require(axis != null and marker != null and bar != null and value_label != null and center_zero != null, "Each live personality axis must expose its marker, floating current value, bar, and fixed center zero."):
				return
			var axis_id: String = personality_axes[axis_name]
			var axis_value: int = int(main_ui.simulation.hero_state.personality_axis_values[axis_id])
			var expected_marker_x: float = 506.0 * (float(axis_value) + 100.0) / 200.0 - 2.0
			if not require(is_equal_approx(marker.position.x, expected_marker_x), "Each personality marker must reflect the live hidden axis value."):
				return
			var expected_value_text: String = "0" if axis_value == 0 else "%+d" % axis_value
			var expected_value_x: float = clampf(506.0 * (float(axis_value) + 100.0) / 200.0 - value_label.size.x * 0.5, 0.0, 506.0 - value_label.size.x)
			if not require(value_label.text == expected_value_text and is_equal_approx(value_label.position.x, expected_value_x), "The debug value label must show the live axis number and follow the marker horizontally."):
				return
			if not require(value_label.position.y + value_label.size.y <= bar.position.y and center_zero.text == "0" and center_zero.position.y >= bar.position.y + bar.size.y, "The live number must stay above the bar while the fixed zero sits below it."):
				return
			var threshold_minus_40 := axis.find_child("ThresholdMinus40", true, false) as ColorRect
			var threshold_40 := axis.find_child("Threshold40", true, false) as ColorRect
			var threshold_minus_20 := axis.find_child("ThresholdMinus20", true, false) as ColorRect
			var threshold_20 := axis.find_child("Threshold20", true, false) as ColorRect
			var active_trait: String = str(main_ui.simulation.hero_state.personality_traits_by_axis[axis_id])
			if active_trait.is_empty():
				if not require(threshold_minus_40.visible and threshold_40.visible and not threshold_minus_20.visible and not threshold_20.visible, "Neutral personality axes must show only the ±40 activation thresholds."):
					return
			elif axis_value < 0:
				if not require(not threshold_minus_40.visible and not threshold_40.visible and threshold_minus_20.visible and not threshold_20.visible, "An active negative trait must show only its -20 return-to-neutral threshold."):
					return
			else:
				if not require(not threshold_minus_40.visible and not threshold_40.visible and not threshold_minus_20.visible and threshold_20.visible, "An active positive trait must show only its +20 return-to-neutral threshold."):
					return
		var courage_axis := personality_panel.find_child("CouragePersonalityAxis", true, false)
		main_ui.simulation.hero_state.personality_axis_values[TraitDevelopmentScript.AXIS_COURAGE] = 35
		main_ui.simulation.hero_state.personality_traits_by_axis[TraitDevelopmentScript.AXIS_COURAGE] = ""
		main_ui.update_personality_panel()
		var courage_value_label := courage_axis.find_child("CurrentValueLabel", true, false) as Label
		if not require(courage_value_label.text == "+35", "The floating debug label must update when formative movement changes a live axis value."):
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
	if not require(main_ui.pending_attribute_indicator != null and not main_ui.pending_attribute_indicator.visible, "Pending-attribute indicator must stay hidden while there are no free points."):
		return
	main_ui.simulation.hero_state.pending_primary_attribute_points = 4
	main_ui.update_pending_attribute_indicator()
	if not require(main_ui.pending_attribute_indicator.visible and main_ui.pending_attribute_indicator.text == "+" and main_ui.pending_attribute_indicator.get_theme_color("font_color") == Color("ff3030"), "Free primary-attribute points must show a steady red plus beside the level row."):
		return
	main_ui.simulation.hero_state.pending_primary_attribute_points = 0
	main_ui.update_pending_attribute_indicator()
	if not require(not main_ui.pending_attribute_indicator.visible, "Pending-attribute indicator must disappear after all free points are spent."):
		return
	main_ui.simulation.hero_state.loop_state = HeroState.DUNGEON_BETWEEN_FIGHTS
	main_ui.update_hero_panel()
	if not require(main_ui.hero_details_label.text.contains("Состояние: В данже — готовится к следующему бою\nКвест:"), "A wrapped hero state must consume the reserved second line instead of shifting later rows."):
		return
	main_ui.simulation.hero_state.pending_primary_attribute_points = 1
	main_ui.set_active_screen("hero")
	if not require(main_ui.hero_screen.visible and not main_ui.main_screen.visible, "The existing Hero menu button flow must expose the player-facing development screen without replacing Simulation."):
		return
	main_ui.update_attribute_allocation_panel()
	var strength_button := main_ui.find_child("StrengthAttributeButton", true, false) as Button
	if not require(strength_button != null and not strength_button.disabled, "A pending player point must enable the attribute-allocation buttons outside combat."):
		return
	strength_button.pressed.emit()
	if not require(main_ui.simulation.hero_state.strength == 6 and main_ui.simulation.hero_state.pending_primary_attribute_points == 0, "The UI must route a Strength allocation through Simulation and consume exactly one pending point."):
		return

	main_ui.free()
	print("PASS: 1366x768 keeps the original UI scale and separates the main-screen panels.")
	quit()
