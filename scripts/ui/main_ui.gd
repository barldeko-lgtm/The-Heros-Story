extends Control

const SimulationScript = preload("res://scripts/core/simulation.gd")
const HeroTraitsScript = preload("res://scripts/hero/hero_traits.gd")
const DamageResolverScript = preload("res://scripts/combat/damage_resolver.gd")
const InventoryScreenScene = preload("res://scenes/ui/screens/inventory_screen.tscn")
const MapScreenScene = preload("res://scenes/ui/screens/map_screen.tscn")
const GodPanelScene = preload("res://scenes/ui/components/god_panel.tscn")
const NarrativePanelScene = preload("res://scenes/ui/components/narrative_panel.tscn")
var simulation_seed: int = int(Time.get_unix_time_from_system())
var simulation = SimulationScript.new(simulation_seed, null)
var time_progress_bar: ProgressBar
var tick_counter_label: Label
var hero_details_label: Label
var opponent_details_label: Label
var combat_statistics_label: Label
var speed_buttons: Dictionary = {}
var god_panel: PanelContainer
var narrative_panel: TabContainer
var main_screen: Control
var inventory_screen: Control
var map_screen: Control
var inventory_button: Button
var map_button: Button
var inventory_close_button: Button

func _ready() -> void:
	create_background()
	create_screen_layers()
	create_top_menu()
	create_inventory_close_button()
	create_speed_controls()
	create_hero_panel()
	create_opponent_panel()
	create_combat_statistics_panel()
	create_god_panel()
	create_tick_indicator()
	create_narrative_panel()
	update_hero_panel()
	update_opponent_panel()
	update_combat_statistics_panel()
	god_panel.refresh()
	inventory_screen.refresh()

func _process(delta: float) -> void:
	simulation.advance_time(delta)
	time_progress_bar.value = simulation.world_clock.tick_progress * 100.0
	tick_counter_label.text = "Тик: %d" % simulation.world_clock.world_tick
	update_hero_panel()
	update_opponent_panel()
	update_combat_statistics_panel()
	god_panel.refresh()
	inventory_screen.refresh()
func create_background() -> void:
	var background := ColorRect.new()
	background.color = Color("d9dde2")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

func create_screen_layers() -> void:
	main_screen = Control.new()
	main_screen.name = "MainScreen"
	main_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(main_screen)

	inventory_screen = InventoryScreenScene.instantiate()
	inventory_screen.setup(simulation)
	inventory_screen.visible = false
	add_child(inventory_screen)

	map_screen = MapScreenScene.instantiate()
	map_screen.visible = false
	add_child(map_screen)

func add_to_main_screen(control: Control) -> void:
	if main_screen != null:
		main_screen.add_child(control)
	else:
		add_child(control)

func apply_panel_style(panel: PanelContainer) -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("232830")
	panel_style.border_color = Color("7b8694")
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(12)
	panel_style.shadow_color = Color(0.0, 0.0, 0.0, 0.30)
	panel_style.shadow_size = 6
	panel_style.shadow_offset = Vector2(0.0, 3.0)
	panel_style.content_margin_left = 16.0
	panel_style.content_margin_right = 16.0
	panel_style.content_margin_top = 14.0
	panel_style.content_margin_bottom = 14.0
	panel.add_theme_stylebox_override("panel", panel_style)

func create_menu_button_style(background_color: Color, border_color: Color, shadow_size: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background_color
	style.border_color = border_color
	style.set_border_width_all(2)
	style.set_corner_radius_all(9)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.35)
	style.shadow_size = shadow_size
	style.shadow_offset = Vector2(0.0, 2.0)
	style.content_margin_left = 14.0
	style.content_margin_right = 14.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	return style

func apply_secondary_button_style(button: Button) -> void:
	button.add_theme_color_override("font_color", Color("edf0f4"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", Color("858b94"))
	button.add_theme_stylebox_override("normal", create_menu_button_style(Color("303844"), Color("707d8e"), 2))
	button.add_theme_stylebox_override("hover", create_menu_button_style(Color("414c5b"), Color("b3bdca"), 3))
	button.add_theme_stylebox_override("pressed", create_menu_button_style(Color("20262e"), Color("d5dbe3"), 1))
	button.add_theme_stylebox_override("focus", create_menu_button_style(Color("414c5b"), Color("d5dbe3"), 2))
	button.add_theme_stylebox_override("disabled", create_menu_button_style(Color("292e35"), Color("4d5560"), 0))

func apply_progress_bar_style(progress_bar: ProgressBar, fill_color: Color) -> void:
	var background_style := StyleBoxFlat.new()
	background_style.bg_color = Color("15191f")
	background_style.border_color = Color("687382")
	background_style.set_border_width_all(2)
	background_style.set_corner_radius_all(8)
	progress_bar.add_theme_stylebox_override("background", background_style)

	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = fill_color
	fill_style.border_color = Color("d5dbe3")
	fill_style.set_border_width_all(1)
	fill_style.set_corner_radius_all(7)
	progress_bar.add_theme_stylebox_override("fill", fill_style)

func create_top_menu() -> void:
	var top_menu := HBoxContainer.new()
	top_menu.name = "TopMenu"
	top_menu.position = Vector2(328.0, 20.0)
	top_menu.add_theme_constant_override("separation", 8)
	add_child(top_menu)

	for button_text in ["ГЕРОЙ", "ИНВЕНТАРЬ", "КАРТА", "МЕНЮ"]:
		var button := Button.new()
		button.text = button_text
		button.tooltip_text = "Раздел пока не реализован"
		button.custom_minimum_size = Vector2(150.0, 42.0)
		button.add_theme_font_size_override("font_size", 18)
		button.add_theme_color_override("font_color", Color("f4f4f4"))
		button.add_theme_color_override("font_hover_color", Color.WHITE)
		button.add_theme_color_override("font_pressed_color", Color.WHITE)
		button.add_theme_stylebox_override("normal", create_menu_button_style(Color("303744"), Color("697586"), 3))
		button.add_theme_stylebox_override("hover", create_menu_button_style(Color("414b5c"), Color("aeb8c7"), 4))
		button.add_theme_stylebox_override("pressed", create_menu_button_style(Color("202630"), Color("d8dee8"), 1))
		button.add_theme_stylebox_override("focus", create_menu_button_style(Color("414b5c"), Color("d8dee8"), 3))
		top_menu.add_child(button)
		if button_text == "ИНВЕНТАРЬ":
			inventory_button = button
			inventory_button.tooltip_text = "Открыть инвентарь"
			inventory_button.pressed.connect(on_inventory_button_pressed)
		elif button_text == "КАРТА":
			map_button = button
			map_button.tooltip_text = "Открыть карту"
			map_button.pressed.connect(on_map_button_pressed)

func create_inventory_close_button() -> void:
	inventory_close_button = Button.new()
	inventory_close_button.name = "InventoryCloseButton"
	inventory_close_button.text = "✕"
	inventory_close_button.position = Vector2(1212.0, 20.0)
	inventory_close_button.size = Vector2(44.0, 44.0)
	inventory_close_button.tooltip_text = "Вернуться на главный экран"
	inventory_close_button.add_theme_font_size_override("font_size", 22)
	inventory_close_button.add_theme_color_override("font_color", Color.WHITE)
	inventory_close_button.add_theme_color_override("font_hover_color", Color.WHITE)
	inventory_close_button.add_theme_color_override("font_pressed_color", Color.WHITE)
	inventory_close_button.add_theme_stylebox_override("normal", create_menu_button_style(Color("842e36"), Color("c76870"), 3))
	inventory_close_button.add_theme_stylebox_override("hover", create_menu_button_style(Color("a83b45"), Color("f0a1a7"), 4))
	inventory_close_button.add_theme_stylebox_override("pressed", create_menu_button_style(Color("612128"), Color("ffd1d4"), 1))
	inventory_close_button.add_theme_stylebox_override("focus", create_menu_button_style(Color("a83b45"), Color("ffd1d4"), 3))
	inventory_close_button.pressed.connect(close_secondary_screen)
	inventory_close_button.visible = false
	add_child(inventory_close_button)

func on_inventory_button_pressed() -> void:
	set_inventory_screen_open(not inventory_screen.visible)

func on_map_button_pressed() -> void:
	set_map_screen_open(not map_screen.visible)

func close_inventory_screen() -> void:
	close_secondary_screen()

func close_secondary_screen() -> void:
	set_active_screen("main")

func set_inventory_screen_open(is_open: bool) -> void:
	set_active_screen("inventory" if is_open else "main")

func set_map_screen_open(is_open: bool) -> void:
	set_active_screen("map" if is_open else "main")

func set_active_screen(screen_id: String) -> void:
	var inventory_is_open: bool = screen_id == "inventory"
	var map_is_open: bool = screen_id == "map"
	main_screen.visible = not inventory_is_open and not map_is_open
	inventory_screen.visible = inventory_is_open
	map_screen.visible = map_is_open
	inventory_button.text = "НАЗАД" if inventory_is_open else "ИНВЕНТАРЬ"
	inventory_button.tooltip_text = "Вернуться на главный экран" if inventory_is_open else "Открыть инвентарь"
	map_button.text = "НАЗАД" if map_is_open else "КАРТА"
	map_button.tooltip_text = "Вернуться на главный экран" if map_is_open else "Открыть карту"
	inventory_close_button.visible = inventory_is_open or map_is_open

func create_speed_controls() -> void:
	var speed_controls := HBoxContainer.new()
	speed_controls.name = "SpeedControls"
	speed_controls.position = Vector2(818.0, 666.0)
	speed_controls.size = Vector2(430.0, 38.0)
	speed_controls.add_theme_constant_override("separation", 6)
	add_to_main_screen(speed_controls)

	for speed in [0, 1, 2, 5, 10, 20, 100]:
		var button := Button.new()
		button.text = "×%d" % speed
		button.toggle_mode = true
		button.button_pressed = speed == 1
		button.custom_minimum_size = Vector2(52.0, 38.0)
		button.add_theme_font_size_override("font_size", 15)
		apply_secondary_button_style(button)
		button.pressed.connect(set_time_scale.bind(float(speed)))
		speed_controls.add_child(button)
		speed_buttons[float(speed)] = button

func set_time_scale(new_time_scale: float) -> void:
	simulation.set_time_scale(new_time_scale)
	for speed in speed_buttons:
		speed_buttons[speed].button_pressed = is_equal_approx(speed, new_time_scale)

func create_hero_panel() -> void:
	var panel := PanelContainer.new()
	apply_panel_style(panel)
	panel.position = Vector2(32.0, 80.0)
	panel.size = Vector2(320.0, 430.0)
	add_to_main_screen(panel)

	hero_details_label = Label.new()
	hero_details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hero_details_label.add_theme_font_size_override("font_size", 16)
	panel.add_child(hero_details_label)

func create_opponent_panel() -> void:
	var panel := PanelContainer.new()
	apply_panel_style(panel)
	panel.position = Vector2(928.0, 80.0)
	panel.size = Vector2(320.0, 400.0)
	add_to_main_screen(panel)

	opponent_details_label = Label.new()
	opponent_details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	opponent_details_label.add_theme_font_size_override("font_size", 16)
	panel.add_child(opponent_details_label)

func update_opponent_panel() -> void:
	if simulation.active_combat_session == null:
		opponent_details_label.text = "Противник\n\nСейчас боя нет."
		return

	var stats = simulation.get_current_opponent_stats()
	opponent_details_label.text = "%s\n\nHP: %.1f / %.1f\n\nАтака: %.1f\nСкорость атаки: %.2f\nШанс крита: %.0f%%\nКрит. урон: %.0f%%\nСила противника: %.2f" % [
		simulation.get_current_opponent_name(),
		simulation.get_current_opponent_hp(),
		stats.max_hp,
		stats.attack,
		stats.attack_speed,
		stats.crit_chance * 100.0,
		stats.crit_damage * 100.0,
		simulation.get_current_opponent_power()
	]

func create_combat_statistics_panel() -> void:
	var panel := PanelContainer.new()
	apply_panel_style(panel)
	panel.position = Vector2(928.0, 500.0)
	panel.size = Vector2(320.0, 120.0)
	add_to_main_screen(panel)

	combat_statistics_label = Label.new()
	combat_statistics_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	combat_statistics_label.add_theme_font_size_override("font_size", 15)
	panel.add_child(combat_statistics_label)

func update_combat_statistics_panel() -> void:
	var stats: Dictionary = simulation.get_current_combat_results()
	if stats.is_empty():
		combat_statistics_label.text = "Статистика боёв\n\nПока боёв нет."
		return

	var total: int = stats["total"]
	var wins: int = stats["wins"]
	var losses: int = stats["losses"]
	var win_rate: float = 100.0 * float(wins) / float(total)
	combat_statistics_label.text = "Статистика боёв — %s\nБои: %d\nПобеды: %d\nПоражения: %d\nWinrate: %.1f%%" % [
		stats["display_name"],
		total,
		wins,
		losses,
		win_rate,
	]

func update_hero_panel() -> void:
	var hero = simulation.hero_state
	var stats = simulation.base_combat_stats
	var effective_strength: int = hero.strength + hero.equipment.get_strength_bonus()
	var armor: int = int(round(stats.armor))
	var physical_reduction_percent := (1.0 - DamageResolverScript.calculate_physical_taken(stats.armor)) * 100.0
	var active_quest_name: String = "—"
	if hero.active_quest != null:
		active_quest_name = hero.active_quest.display_name
	var trait_names: String = HeroTraitsScript.get_display_names(hero.traits)
	var bonus_lines: PackedStringArray = []
	var trait_bonus_text: String = HeroTraitsScript.get_conditional_damage_bonus_text(hero.traits)
	if not trait_bonus_text.is_empty():
		bonus_lines.append("Бонус черты: %s" % trait_bonus_text)
	var buff_fights: int = simulation.get_combat_buff_fights_remaining()
	if buff_fights > 0:
		bonus_lines.append("Божественное благословение: +15%% физ. урона (%d боёв)" % buff_fights)
	var bonuses_text: String = ""
	if not bonus_lines.is_empty():
		bonuses_text = "\n" + "\n".join(bonus_lines)
	hero_details_label.text = "%s\nВоин\nЧерты: %s%s\n\nУровень: %d   XP: %d / %d\nHP: %.1f / %.1f\nЗолото: %d\nСостояние: %s\nКвест: %s\n\nСила: %d\nЛовкость: %d\nИнтеллект: %d\nТелосложение: %d\nМудрость: %d\n\nФиз. урон: %.0f\nТочность: %.0f\nУклонение: %.0f\nБроня: %d (снижение %.1f%%)\nОгонь / Холод / Молния: %.0f / %.0f / %.0f\nБлок: %.0f\nСкорость атаки: %.2f\nШанс крита: %.0f%%\nКрит. урон: %.0f%%\nСила героя: %.2f\nSeed: %d" % [hero.hero_name, trait_names, bonuses_text, hero.level, hero.experience, hero.experience_to_next_level, simulation.get_current_hero_hp(), stats.max_hp, hero.gold, get_state_display_name(hero.loop_state), active_quest_name, effective_strength, hero.dexterity, hero.intelligence, hero.constitution, hero.wisdom, stats.attack, stats.accuracy, stats.dodge, armor, physical_reduction_percent, stats.fire_resistance, stats.cold_resistance, stats.lightning_resistance, stats.block, stats.attack_speed, stats.crit_chance * 100.0, stats.crit_damage * 100.0, simulation.get_hero_power(), simulation.simulation_seed]

func get_state_display_name(loop_state: String) -> String:
	match loop_state:
		HeroState.CHOOSING_QUEST: return "Выбирает квест"
		HeroState.TRAVEL_TO_QUEST: return "Идёт к цели"
		HeroState.DOING_QUEST: return "Выполняет квест"
		HeroState.RECOVERING_AFTER_FIGHT: return "Восстанавливается после боя"
		HeroState.RETURNING_TO_CITY: return "Возвращается в город"
		HeroState.TURNING_IN_QUEST: return "Сдаёт квест"
		HeroState.VISITING_MARKET: return "На рынке — продаёт ненужный шмот"
		HeroState.SHOPPING: return "В магазине — выбирает покупку"
		HeroState.DEAD_RESPAWNING: return "Мёртв — тиков до возрождения: %d" % simulation.quest_runner.respawn_ticks_remaining
		HeroState.RECOVERING_IN_CITY: return "Восстанавливается в городе"
	return loop_state

func create_god_panel() -> void:
	if god_panel != null:
		return
	god_panel = GodPanelScene.instantiate()
	god_panel.setup(simulation)
	god_panel.hero_state_changed.connect(update_hero_panel)
	add_to_main_screen(god_panel)

func create_tick_indicator() -> void:
	var indicator := HBoxContainer.new()
	indicator.position = Vector2(380.0, 335.0)
	indicator.size = Vector2(520.0, 44.0)
	indicator.add_theme_constant_override("separation", 16)
	add_to_main_screen(indicator)

	time_progress_bar = ProgressBar.new()
	time_progress_bar.custom_minimum_size = Vector2(390.0, 36.0)
	time_progress_bar.max_value = 100.0
	time_progress_bar.show_percentage = false
	apply_progress_bar_style(time_progress_bar, Color("9ca9b8"))
	indicator.add_child(time_progress_bar)

	tick_counter_label = Label.new()
	tick_counter_label.custom_minimum_size = Vector2(110.0, 36.0)
	tick_counter_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tick_counter_label.add_theme_font_size_override("font_size", 22)
	tick_counter_label.add_theme_color_override("font_color", Color("242a31"))
	tick_counter_label.text = "Тик: 0"
	indicator.add_child(tick_counter_label)

func create_narrative_panel() -> void:
	if narrative_panel != null:
		return
	narrative_panel = NarrativePanelScene.instantiate()
	narrative_panel.setup(simulation)
	add_to_main_screen(narrative_panel)
