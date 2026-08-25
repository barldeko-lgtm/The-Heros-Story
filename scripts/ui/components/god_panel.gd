class_name GodPanel
extends PanelContainer

signal hero_state_changed

const GodStateScript = preload("res://scripts/god/god_state.gd")

var simulation
var god_energy_bar: ProgressBar
var god_energy_label: Label
var god_status_label: Label
var divine_healing_button: Button
var combat_buff_button: Button
var instant_resurrection_button: Button

func setup(simulation_reference) -> void:
	simulation = simulation_reference
	if is_node_ready():
		refresh()

func _ready() -> void:
	apply_panel_style(self)
	create_content()
	refresh()

func create_content() -> void:
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 7)
	add_child(content)

	var title := Label.new()
	title.text = "Влияние божества"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	content.add_child(title)

	god_energy_label = Label.new()
	god_energy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(god_energy_label)

	god_energy_bar = ProgressBar.new()
	god_energy_bar.name = "GodEnergyBar"
	god_energy_bar.max_value = GodStateScript.MAX_ENERGY
	god_energy_bar.show_percentage = false
	god_energy_bar.custom_minimum_size = Vector2(480.0, 28.0)
	apply_progress_bar_style(god_energy_bar, Color("8fa8c1"))
	content.add_child(god_energy_bar)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 6)
	content.add_child(buttons)

	divine_healing_button = Button.new()
	divine_healing_button.name = "DivineHealingButton"
	divine_healing_button.custom_minimum_size = Vector2(156.0, 58.0)
	apply_secondary_button_style(divine_healing_button)
	divine_healing_button.pressed.connect(on_divine_healing_pressed)
	buttons.add_child(divine_healing_button)

	combat_buff_button = Button.new()
	combat_buff_button.name = "CombatBuffButton"
	combat_buff_button.custom_minimum_size = Vector2(156.0, 58.0)
	apply_secondary_button_style(combat_buff_button)
	combat_buff_button.pressed.connect(on_combat_buff_pressed)
	buttons.add_child(combat_buff_button)

	instant_resurrection_button = Button.new()
	instant_resurrection_button.name = "InstantResurrectionButton"
	instant_resurrection_button.custom_minimum_size = Vector2(156.0, 58.0)
	apply_secondary_button_style(instant_resurrection_button)
	instant_resurrection_button.pressed.connect(on_instant_resurrection_pressed)
	buttons.add_child(instant_resurrection_button)

	god_status_label = Label.new()
	god_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	god_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(god_status_label)

func refresh() -> void:
	if simulation == null or god_energy_bar == null:
		return
	var god = simulation.god_state
	god_energy_bar.value = god.energy
	god_energy_label.text = "Энергия: %.1f / %.0f" % [god.energy, GodStateScript.MAX_ENERGY]

	var hero_is_dead: bool = simulation.hero_state.loop_state == HeroState.DEAD_RESPAWNING
	var hero_is_full_hp: bool = simulation.get_current_hero_hp() >= simulation.combat_stats.max_hp
	divine_healing_button.disabled = hero_is_dead or hero_is_full_hp or god.healing_cooldown_ticks > 0 or god.energy < GodStateScript.HEALING_COST
	divine_healing_button.text = "Лечение\n10 энергии"
	if god.healing_cooldown_ticks > 0:
		divine_healing_button.text = "Лечение\nКД: %d" % god.healing_cooldown_ticks

	var combat_buff_fights_remaining: int = simulation.get_combat_buff_fights_remaining()
	combat_buff_button.disabled = combat_buff_fights_remaining > 0 or god.combat_buff_cooldown_ticks > 0 or god.energy < GodStateScript.COMBAT_BUFF_COST
	combat_buff_button.text = "Благословение\n10 энергии"
	if combat_buff_fights_remaining > 0:
		combat_buff_button.text = "Благословение\nБоёв: %d | КД: %d" % [combat_buff_fights_remaining, god.combat_buff_cooldown_ticks]
	elif god.combat_buff_cooldown_ticks > 0:
		combat_buff_button.text = "Благословение\nКД: %d" % god.combat_buff_cooldown_ticks

	var resurrection_cost: float = god.get_resurrection_cost(simulation.quest_runner.respawn_ticks_remaining)
	instant_resurrection_button.disabled = not hero_is_dead or simulation.quest_runner.respawn_ticks_remaining <= 0 or god.energy < resurrection_cost
	instant_resurrection_button.text = "Воскрешение\n%.1f энергии" % resurrection_cost

	if combat_buff_fights_remaining > 0:
		god_status_label.text = "Активно: +3 атаки | Боёв: %d | КД: %d" % [combat_buff_fights_remaining, god.combat_buff_cooldown_ticks]
	else:
		god_status_label.text = "Лечение разрешено и во время боя."

func on_divine_healing_pressed() -> void:
	if simulation.use_divine_healing():
		hero_state_changed.emit()
	refresh()

func on_combat_buff_pressed() -> void:
	if simulation.use_combat_buff():
		hero_state_changed.emit()
	refresh()

func on_instant_resurrection_pressed() -> void:
	if simulation.use_instant_resurrection():
		hero_state_changed.emit()
	refresh()

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
