extends SceneTree

const HeroTraitsScript = preload("res://scripts/hero/hero_traits.gd")

func _init() -> void:
	var main_ui_script: Script = load("res://scripts/ui/main_ui.gd")
	assert(main_ui_script != null, "Main UI script must exist.")
	var main_ui: Control = main_ui_script.new()
	assert(main_ui.simulation.get_current_combat_results().is_empty(), "Developer UI must tolerate startup before the first autonomous quest is selected.")
	main_ui.create_hero_panel()
	main_ui.create_god_panel()
	main_ui.simulation.hero_state.traits.clear()
	main_ui.simulation.hero_state.traits.append(HeroTraitsScript.NOBLE)
	main_ui.update_hero_panel()
	main_ui.update_god_panel()

	assert(main_ui.god_panel != null, "God panel must be created above the narrative log.")
	assert(main_ui.god_panel.position.y + main_ui.god_panel.size.y <= 335.0, "God panel must remain above the world-tick indicator and log.")
	assert(is_equal_approx(main_ui.god_energy_bar.max_value, 100.0), "God energy bar maximum must be 100.")
	assert(is_equal_approx(main_ui.god_energy_bar.value, 100.0), "God energy bar must display current starting energy.")
	assert(main_ui.instant_resurrection_button.disabled, "Resurrection button must be disabled while the hero is alive.")
	assert(main_ui.divine_healing_button.disabled, "Healing button must be disabled at full HP.")
	assert(not main_ui.combat_buff_button.disabled, "Combat buff button must be available with full energy and no cooldown.")
	assert(main_ui.simulation.use_combat_buff(), "God UI test must activate the combat buff.")
	main_ui.update_hero_panel()
	main_ui.update_god_panel()
	assert(main_ui.combat_buff_button.text.contains("Боёв: 5"), "Active buff button must show remaining fights.")
	assert(main_ui.combat_buff_button.text.contains("КД: 120"), "Active buff button must show cooldown counting from activation.")
	assert(main_ui.hero_details_label.text.contains("Атака: %.0f" % main_ui.simulation.base_combat_stats.attack), "Hero UI must keep displaying base Attack while buffed.")
	assert(main_ui.hero_details_label.text.contains("Божественное благословение: +3 Attack (5 боёв)"), "Hero UI must display the temporary +3 Attack separately.")
	assert(main_ui.hero_details_label.text.contains("Бонус черты: +10% урона монстрам"), "Hero UI must explain Noble's conditional damage bonus separately.")

	main_ui.simulation.hero_state.current_hp = 1.0
	main_ui.update_god_panel()
	assert(not main_ui.divine_healing_button.disabled, "Healing button must become available for an injured hero.")

	main_ui.simulation.hero_state.loop_state = HeroState.DEAD_RESPAWNING
	main_ui.simulation.hero_state.current_hp = 0.0
	main_ui.simulation.quest_runner.respawn_ticks_remaining = 20
	main_ui.update_god_panel()
	assert(main_ui.divine_healing_button.disabled, "Healing button must be disabled while the hero is dead.")
	assert(not main_ui.instant_resurrection_button.disabled, "Resurrection button must become available after death when affordable.")
	assert(main_ui.instant_resurrection_button.text.contains("10"), "Resurrection button must display its current dynamic energy cost.")

	main_ui.free()
	print("PASS: God UI shows energy and correctly gates healing, buff, and resurrection controls.")
	quit()
