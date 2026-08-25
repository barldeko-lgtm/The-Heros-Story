extends SceneTree

func _init() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	var main_ui_script: Script = load("res://scripts/ui/main_ui.gd")
	var rare_boots: Resource = load("res://data/items/visual_families/ironward_vanguard/boar_boots_rare.tres")
	assert(simulation_script != null and main_ui_script != null and rare_boots != null, "UI regression dependencies must load.")

	var simulation = simulation_script.new(1)
	simulation.receive_item_reward(rare_boots, 1)
	var main_ui = main_ui_script.new()
	main_ui.simulation = simulation
	get_root().add_child(main_ui)
	await process_frame

	var opponent_panel := main_ui.opponent_details_label.get_parent() as PanelContainer
	var statistics_panel := main_ui.combat_statistics_label.get_parent() as PanelContainer
	var speed_controls := main_ui.find_child("SpeedControls", true, false) as HBoxContainer
	assert(opponent_panel.size.y <= 400.0, "Opponent panel must be slightly shorter than the old 430px draft.")
	var statistics_bottom: float = statistics_panel.position.y + statistics_panel.size.y
	assert(speed_controls.position.y - statistics_bottom >= 32.0, "Combat statistics must keep a visible shadow-safe gap above speed buttons.")

	main_ui.inventory_button.pressed.emit()
	await process_frame
	var boots_slot := main_ui.find_child("BootsSlot", true, false) as PanelContainer
	var tooltip_panel := main_ui.find_child("ItemTooltipPanel", true, false) as PanelContainer
	boots_slot.mouse_entered.emit()
	await process_frame
	assert(tooltip_panel.visible, "Boots hover must show tooltip.")
	var tooltip_rect: Rect2 = tooltip_panel.get_rect()
	var screen_size: Vector2 = main_ui.get_viewport_rect().size
	assert(tooltip_rect.position.x >= 12.0 and tooltip_rect.end.x <= screen_size.x - 12.0, "Tooltip must remain fully inside horizontal screen bounds.")
	assert(tooltip_rect.position.y >= 76.0 and tooltip_rect.end.y <= screen_size.y - 12.0, "Boots tooltip must remain fully inside vertical screen bounds.")

	main_ui.free()
	print("PASS: Right-side panels do not overlap speed controls and boots tooltip stays on-screen.")
	quit()
