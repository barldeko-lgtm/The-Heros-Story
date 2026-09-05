extends Control

const SimulationScript = preload("res://scripts/core/simulation.gd")
const HeroTraitsScript = preload("res://scripts/hero/hero_traits.gd")
const DamageResolverScript = preload("res://scripts/combat/damage_resolver.gd")
const InventoryScreenScene = preload("res://scenes/ui/screens/inventory_screen.tscn")
const MapScreenScene = preload("res://scenes/ui/screens/map_screen.tscn")
const GodPanelScene = preload("res://scenes/ui/components/god_panel.tscn")
const NarrativePanelScene = preload("res://scenes/ui/components/narrative_panel.tscn")
const HERO_TEXT_CONTENT_WIDTH: float = 288.0
const PRIMARY_ATTRIBUTE_DISPLAY_NAMES := {
	"strength": "Сила",
	"dexterity": "Ловкость",
	"intelligence": "Интеллект",
	"constitution": "Телосложение",
	"wisdom": "Мудрость",
}
var simulation_seed: int = int(Time.get_unix_time_from_system())
var simulation = SimulationScript.new(simulation_seed, null, [], true)
var time_progress_bar: ProgressBar
var tick_counter_label: Label
var hero_details_label: Label
var pending_attribute_indicator: Label
var opponent_details_label: Label
var combat_statistics_label: Label
var attribute_points_label: Label
var attribute_buttons: Dictionary = {}
var speed_buttons: Dictionary = {}
var god_panel: PanelContainer
var narrative_panel: TabContainer
var main_screen: Control
var hero_screen: Control
var inventory_screen: Control
var map_screen: Control
var hero_button: Button
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
	create_pending_attribute_indicator()
	create_attribute_allocation_panel()
	create_decorative_personality_panel()
	create_opponent_panel()
	create_combat_statistics_panel()
	create_god_panel()
	create_tick_indicator()
	create_narrative_panel()
	update_hero_panel()
	update_attribute_allocation_panel()
	update_opponent_panel()
	update_combat_statistics_panel()
	god_panel.refresh()
	inventory_screen.refresh()

func _process(delta: float) -> void:
	simulation.advance_time(delta)
	time_progress_bar.value = simulation.world_clock.tick_progress * 100.0
	tick_counter_label.text = "Тик: %d" % simulation.world_clock.world_tick
	update_hero_panel()
	update_pending_attribute_indicator()
	update_attribute_allocation_panel()
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

	hero_screen = Control.new()
	hero_screen.name = "HeroScreen"
	hero_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hero_screen.visible = false
	add_child(hero_screen)

	inventory_screen = InventoryScreenScene.instantiate()
	inventory_screen.setup(simulation)
	inventory_screen.visible = false
	add_child(inventory_screen)

	map_screen = MapScreenScene.instantiate()
	map_screen.setup(simulation)
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
	top_menu.position = Vector2(371.0, 20.0)
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
		if button_text == "ГЕРОЙ":
			hero_button = button
			hero_button.tooltip_text = "Открыть развитие героя"
			hero_button.pressed.connect(on_hero_button_pressed)
		elif button_text == "ИНВЕНТАРЬ":
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
	inventory_close_button.position = Vector2(1298.0, 20.0)
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

func on_hero_button_pressed() -> void:
	set_active_screen("main" if hero_screen.visible else "hero")

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
	var hero_is_open: bool = screen_id == "hero"
	var inventory_is_open: bool = screen_id == "inventory"
	var map_is_open: bool = screen_id == "map"
	main_screen.visible = not hero_is_open and not inventory_is_open and not map_is_open
	hero_screen.visible = hero_is_open
	inventory_screen.visible = inventory_is_open
	map_screen.visible = map_is_open
	hero_button.text = "НАЗАД" if hero_is_open else "ГЕРОЙ"
	hero_button.tooltip_text = "Вернуться на главный экран" if hero_is_open else "Открыть развитие героя"
	inventory_button.text = "НАЗАД" if inventory_is_open else "ИНВЕНТАРЬ"
	inventory_button.tooltip_text = "Вернуться на главный экран" if inventory_is_open else "Открыть инвентарь"
	map_button.text = "НАЗАД" if map_is_open else "КАРТА"
	map_button.tooltip_text = "Вернуться на главный экран" if map_is_open else "Открыть карту"
	inventory_close_button.visible = hero_is_open or inventory_is_open or map_is_open

func create_speed_controls() -> void:
	var speed_controls := HBoxContainer.new()
	speed_controls.name = "SpeedControls"
	speed_controls.position = Vector2(904.0, 714.0)
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
	hero_details_label.add_theme_font_size_override("font_size", 14)
	panel.add_child(hero_details_label)

func create_pending_attribute_indicator() -> void:
	pending_attribute_indicator = Label.new()
	pending_attribute_indicator.name = "PendingAttributeIndicator"
	pending_attribute_indicator.text = "+"
	pending_attribute_indicator.tooltip_text = "Есть нераспределённые очки характеристик"
	pending_attribute_indicator.add_theme_font_size_override("font_size", 20)
	pending_attribute_indicator.add_theme_color_override("font_color", Color("ff3030"))
	pending_attribute_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pending_attribute_indicator.visible = false
	add_to_main_screen(pending_attribute_indicator)

func update_pending_attribute_indicator() -> void:
	if pending_attribute_indicator == null:
		return
	if simulation.hero_state.pending_primary_attribute_points <= 0:
		pending_attribute_indicator.visible = false
		return

	pending_attribute_indicator.visible = true

	var font: Font = hero_details_label.get_theme_font("font")
	var font_size: int = hero_details_label.get_theme_font_size("font_size")
	var line_height: float = font.get_height(font_size)
	var bonus_line_count: int = 0
	var trait_bonus_text: String = HeroTraitsScript.get_conditional_damage_bonus_text(simulation.hero_state.traits)
	if not trait_bonus_text.is_empty():
		bonus_line_count += 1
	if simulation.get_combat_buff_fights_remaining() > 0:
		bonus_line_count += 1
	var level_line_index: int = 3 + bonus_line_count
	var hero_panel := hero_details_label.get_parent() as Control
	pending_attribute_indicator.position = hero_panel.position + Vector2(286.0, 14.0 + line_height * level_line_index - 2.0)

func create_attribute_allocation_panel() -> void:
	var panel := PanelContainer.new()
	panel.name = "AttributeAllocationPanel"
	apply_panel_style(panel)
	panel.position = Vector2(411.0, 108.0)
	panel.size = Vector2(544.0, 360.0)
	hero_screen.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	panel.add_child(content)

	var title := Label.new()
	title.text = "Развитие героя"
	title.add_theme_font_size_override("font_size", 24)
	content.add_child(title)

	attribute_points_label = Label.new()
	attribute_points_label.name = "AttributePointsLabel"
	attribute_points_label.add_theme_font_size_override("font_size", 18)
	content.add_child(attribute_points_label)

	for attribute_id in PRIMARY_ATTRIBUTE_DISPLAY_NAMES:
		var button := Button.new()
		button.name = "%sAttributeButton" % attribute_id.capitalize()
		button.custom_minimum_size = Vector2(506.0, 42.0)
		button.add_theme_font_size_override("font_size", 16)
		apply_secondary_button_style(button)
		button.pressed.connect(on_allocate_attribute_pressed.bind(attribute_id))
		content.add_child(button)
		attribute_buttons[attribute_id] = button

func create_decorative_personality_panel() -> void:
	var panel := PanelContainer.new()
	panel.name = "PersonalityAxesPanel"
	apply_panel_style(panel)
	panel.position = Vector2(411.0, 480.0)
	panel.size = Vector2(544.0, 244.0)
	hero_screen.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 5)
	panel.add_child(content)

	var title := Label.new()
	title.text = "Черты характера"
	title.add_theme_font_size_override("font_size", 20)
	content.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Скрытые шкалы: −100   ·   0   ·   +100"
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.add_theme_color_override("font_color", Color("aeb6c1"))
	content.add_child(subtitle)

	create_decorative_personality_axis(content, "CouragePersonalityAxis", "Осторожный", "Смелый")
	create_decorative_personality_axis(content, "MoralityPersonalityAxis", "Хитрый", "Благородный")
	create_decorative_personality_axis(content, "GreedPersonalityAxis", "Жадный", "Щедрый")
	create_decorative_personality_axis(content, "CuriosityPersonalityAxis", "Консервативный", "Любопытный")

func create_decorative_personality_axis(parent: VBoxContainer, axis_name: String, negative_label: String, positive_label: String) -> void:
	var row := VBoxContainer.new()
	row.name = axis_name
	row.add_theme_constant_override("separation", 1)
	parent.add_child(row)

	var labels := HBoxContainer.new()
	labels.custom_minimum_size = Vector2(0.0, 17.0)
	row.add_child(labels)

	var negative := Label.new()
	negative.text = negative_label
	negative.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	negative.add_theme_font_size_override("font_size", 12)
	labels.add_child(negative)

	var neutral := Label.new()
	neutral.text = "0"
	neutral.custom_minimum_size = Vector2(36.0, 0.0)
	neutral.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	neutral.add_theme_font_size_override("font_size", 12)
	labels.add_child(neutral)

	var positive := Label.new()
	positive.text = positive_label
	positive.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	positive.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	positive.add_theme_font_size_override("font_size", 12)
	labels.add_child(positive)

	var bar := ColorRect.new()
	bar.name = "AxisBar"
	bar.custom_minimum_size = Vector2(506.0, 8.0)
	bar.color = Color("15191f")
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(bar)

	for axis_value in [-40, 40]:
		var threshold := ColorRect.new()
		threshold.name = "Threshold%s" % str(axis_value).replace("-", "Minus")
		threshold.position = Vector2(506.0 * (float(axis_value) + 100.0) / 200.0 - 1.0, 0.0)
		threshold.size = Vector2(2.0, 8.0)
		threshold.color = Color("d0a95b")
		threshold.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.add_child(threshold)

	var neutral_marker := ColorRect.new()
	neutral_marker.name = "NeutralMarker"
	neutral_marker.position = Vector2(251.0, -2.0)
	neutral_marker.size = Vector2(4.0, 12.0)
	neutral_marker.color = Color("edf0f4")
	neutral_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_child(neutral_marker)

func on_allocate_attribute_pressed(attribute_id: String) -> void:
	if simulation.allocate_primary_attribute(attribute_id):
		update_hero_panel()
		update_attribute_allocation_panel()

func update_attribute_allocation_panel() -> void:
	if attribute_points_label == null:
		return
	var pending_points: int = simulation.hero_state.pending_primary_attribute_points
	var in_combat: bool = simulation.active_combat_session != null
	attribute_points_label.text = "Нераспределённые очки: %d%s" % [pending_points, " (после боя)" if in_combat and pending_points > 0 else ""]
	for attribute_id in attribute_buttons:
		var current_value: int = int(simulation.hero_state.get(attribute_id))
		attribute_buttons[attribute_id].text = "+1 %s   (сейчас %d)" % [PRIMARY_ATTRIBUTE_DISPLAY_NAMES[attribute_id], current_value]
		attribute_buttons[attribute_id].disabled = pending_points <= 0 or in_combat

func create_opponent_panel() -> void:
	var panel := PanelContainer.new()
	apply_panel_style(panel)
	panel.position = Vector2(1014.0, 80.0)
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
	panel.position = Vector2(1014.0, 500.0)
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
	var state_display_name: String = get_state_display_name(hero.loop_state)
	var state_spacer: String = get_state_spacer(state_display_name)
	hero_details_label.text = "%s\nВоин\nЧерты: %s%s\nУровень: %d   XP: %d / %d\nHP: %.1f / %.1f\nЗолото: %d\nСостояние: %s%s\nКвест: %s\nСила: %d\nЛовкость: %d\nИнтеллект: %d\nТелосложение: %d\nМудрость: %d\nФиз. урон: %.0f\nТочность: %.0f\nУклонение: %.0f\nБроня: %d (снижение %.1f%%)\nОгонь / Холод / Молния: %.0f / %.0f / %.0f\nБлок: %.0f\nСкорость атаки: %.2f\nШанс крита: %.0f%%\nКрит. урон: %.0f%%\nСила героя: %.2f\nSeed: %d" % [hero.hero_name, trait_names, bonuses_text, hero.level, hero.experience, hero.experience_to_next_level, simulation.get_current_hero_hp(), stats.max_hp, hero.gold, state_display_name, state_spacer, active_quest_name, effective_strength, hero.dexterity, hero.intelligence, hero.constitution, hero.wisdom, stats.attack, stats.accuracy, stats.dodge, armor, physical_reduction_percent, stats.fire_resistance, stats.cold_resistance, stats.lightning_resistance, stats.block, stats.attack_speed, stats.crit_chance * 100.0, stats.crit_damage * 100.0, simulation.get_hero_power(), simulation.simulation_seed]

func get_state_spacer(state_display_name: String) -> String:
	var font: Font = hero_details_label.get_theme_font("font")
	var font_size: int = hero_details_label.get_theme_font_size("font_size")
	var state_line_width: float = font.get_string_size("Состояние: %s" % state_display_name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	return "\n" if state_line_width <= HERO_TEXT_CONTENT_WIDTH else ""

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
		HeroState.TRAVEL_TO_DUNGEON: return "Идёт к данжу"
		HeroState.AT_DUNGEON_ENTRANCE: return "У входа в данж"
		HeroState.DOING_DUNGEON: return "В данже — бой"
		HeroState.DUNGEON_BETWEEN_FIGHTS: return "В данже — готовится к следующему бою"
		HeroState.DUNGEON_COMPLETED: return "Данж пройден"
		HeroState.DUNGEON_RETURNING_TO_CITY: return "Возвращается в город после данжа"
		HeroState.DEAD_RESPAWNING: return "Мёртв — тиков до возрождения: %d" % simulation.get_respawn_ticks_remaining()
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
	indicator.position = Vector2(423.0, 335.0)
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
