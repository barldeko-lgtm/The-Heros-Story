extends SceneTree

func _init() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var main_ui_script: Script = load("res://scripts/ui/main_ui.gd")
	assert(main_ui_script != null, "Main UI script must exist.")
	var main_ui: Control = main_ui_script.new()
	get_root().add_child(main_ui)
	await process_frame

	assert(main_ui.simulation.use_combat_buff(), "UI text test must activate the combat blessing.")
	main_ui.update_hero_panel()
	main_ui.god_panel.refresh()

	assert(main_ui.hero_details_label.text.contains("Божественное благословение: +15% физ. урона (5 боёв)"), "Hero panel must describe the +15% Physical Damage blessing.")
	assert(main_ui.god_panel.god_status_label.text.contains("+15% физ. урона"), "God panel must describe the +15% Physical Damage blessing.")
	assert(not main_ui.hero_details_label.text.contains("+3 Attack"), "UI must not retain the obsolete flat Attack description.")

	await process_frame
	await process_frame
	main_ui.free()
	print("PASS: Divine blessing UI displays +15% Physical Damage and no obsolete +3 Attack text.")
	quit()
