extends SceneTree

var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		printerr("FAIL: " + message)

func _init() -> void:
	call_deferred("run")

func run() -> void:
	if not ResourceLoader.exists("res://scenes/ui/screens/hero_screen.tscn"):
		printerr("FAIL: Hero screen has not been extracted")
		quit(1)
		return
	root.size = Vector2i(1366, 768)
	var ui = load("res://scripts/ui/main_ui.gd").new()
	root.add_child(ui)
	ui.set_process(false)
	ui.simulation.set_time_scale(0.0)
	await process_frame
	await process_frame
	check(ui.hero_screen.simulation == ui.simulation, "Screen uses the same simulation")
	check(not ui.hero_screen.visible and ui.main_screen.visible, "Startup navigation unchanged")
	check(ui.attribute_buttons == ui.hero_screen.attribute_buttons, "Compatibility controls reference live screen")
	ui.on_hero_button_pressed()
	await process_frame
	check(ui.hero_screen.visible and ui.hero_button.text == "НАЗАД" and ui.inventory_close_button.visible, "Hero navigation unchanged")
	var panel = ui.hero_screen.get_node("AttributeAllocationPanel")
	var skills = ui.hero_screen.get_node("SkillsPanel")
	var personality = ui.hero_screen.get_node("PersonalityAxesPanel")
	check(panel.position == Vector2(411, 108) and panel.size == Vector2(544, 360), "Attribute panel geometry preserved")
	check(skills.position == Vector2(973, 108) and skills.size == Vector2(300, 150), "Skill panel fits beside hero development without moving existing panels")
	check(personality.position == Vector2(411, 472) and personality.size == Vector2(544, 280), "Personality panel geometry preserved")
	var hero = ui.simulation.hero_state
	var power_strike_label := skills.find_child("PowerStrikeLevelLabel", true, false) as Label
	var battle_guard_label := skills.find_child("BattleGuardLevelLabel", true, false) as Label
	check(power_strike_label != null and power_strike_label.text == "Мощный удар: не изучен", "Locked Power Strike is shown clearly")
	check(battle_guard_label != null and battle_guard_label.text == "Боевой заслон: не изучен", "Locked Battle Guard is shown clearly")
	hero.power_strike_skill_level = 3
	hero.battle_guard_skill_level = 2
	ui.hero_screen.refresh()
	check(power_strike_label.text == "Мощный удар: ур. 3 / 10", "Power Strike level refreshes from HeroState")
	check(battle_guard_label.text == "Боевой заслон: ур. 2 / 10", "Battle Guard level refreshes from HeroState")
	hero.personality_axis_values["courage"] = 35
	hero.personality_traits_by_axis["courage"] = ""
	ui.update_personality_panel()
	check(ui.personality_axis_value_labels["courage"].text == "+35", "Axis refresh uses live values")
	check(is_equal_approx(ui.personality_axis_markers["courage"].position.x, 506.0 * 135.0 / 200.0 - 2.0), "Marker geometry preserved")
	check(ui.personality_axis_bars["courage"].get_node("Threshold40").visible, "Neutral activation marker preserved")
	var strength: int = hero.strength
	hero.pending_primary_attribute_points = 1
	ui.update_attribute_allocation_panel()
	check(not ui.attribute_buttons["strength"].disabled, "Allocation enabled with a point")
	ui.attribute_buttons["strength"].pressed.emit()
	check(hero.strength == strength + 1 and hero.pending_primary_attribute_points == 0, "Click routes allocation through Simulation")
	check(ui.attribute_buttons["strength"].disabled and ui.hero_details_label.get_parsed_text().contains("Сила:%d" % (hero.strength + hero.equipment.get_strength_bonus())), "Allocation refreshes screen and main summary")
	var tick: int = ui.simulation.world_clock.world_tick
	var gold: int = hero.gold
	var rng_state = ui.simulation.seeded_rng.get_rng().state
	ui.hero_screen.refresh()
	check(tick == ui.simulation.world_clock.world_tick and gold == hero.gold and rng_state == ui.simulation.seeded_rng.get_rng().state, "Refresh cannot advance gameplay")
	ui.close_secondary_screen()
	ui.attribute_points_label.text = "hidden sentinel"
	ui.refresh_visible_screen()
	check(ui.attribute_points_label.text == "hidden sentinel", "Hidden screen does not refresh")
	ui.on_hero_button_pressed()
	check(ui.attribute_points_label.text != "hidden sentinel", "Reopening refreshes immediately")
	ui.on_hero_button_pressed()
	check(ui.main_screen.visible and not ui.hero_screen.visible and not ui.inventory_close_button.visible, "Back navigation unchanged")
	await process_frame
	ui.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: Hero screen extraction preserves ownership, geometry, navigation, allocation and visibility refresh")
	quit(0 if failures == 0 else 1)
