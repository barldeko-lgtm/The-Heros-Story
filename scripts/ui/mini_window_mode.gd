extends Node

# Presentation only: keep MainUI processing the same Simulation while hidden.
const MINI_SIZE := Vector2i(240, 40)
var active: bool = false
var panel: Panel
var expand_button: Button
var status_label: Label
var pending_points_indicator: Label
var _window: Window
var _ui: Control
var _saved_window: Dictionary = {}
var _saved_visibility: Dictionary = {}
var _mini_position := Vector2i.ZERO
var _has_mini_position: bool = false

func _ready() -> void:
	_ui = get_parent()
	_window = get_window()
	panel = Panel.new()
	panel.name = "MiniPanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("d9dde2")
	panel.add_theme_stylebox_override("panel", style)
	panel.hide()
	panel.gui_input.connect(_on_panel_gui_input)
	_ui.add_child(panel)
	expand_button = Button.new()
	expand_button.tooltip_text = "Развернуть"
	expand_button.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	expand_button.offset_left = -34.0
	expand_button.offset_right = -6.0
	expand_button.offset_top = -14.0
	expand_button.offset_bottom = 14.0
	var icon_image := Image.new()
	icon_image.load_svg_from_string('<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16"><path d="M9 2h5v5M14 2L9 7M7 14H2V9M2 14l5-5" fill="none" stroke="#edf0f4" stroke-width="1.5" stroke-linejoin="round"/></svg>')
	expand_button.icon = ImageTexture.create_from_image(icon_image)
	_ui.apply_secondary_button_style(expand_button)
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var button_style: StyleBoxFlat = expand_button.get_theme_stylebox(state).duplicate()
		button_style.set_content_margin_all(4.0)
		button_style.set_corner_radius_all(3)
		button_style.shadow_size = 0
		expand_button.add_theme_stylebox_override(state, button_style)
	expand_button.pressed.connect(exit_mini_mode)
	panel.add_child(expand_button)
	status_label = Label.new()
	status_label.name = "MiniStatus"
	status_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	status_label.offset_left = 8.0
	status_label.offset_right = -60.0
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_outline_color", Color.BLACK)
	status_label.add_theme_constant_override("outline_size", 2)
	panel.add_child(status_label)
	pending_points_indicator = Label.new()
	pending_points_indicator.name = "PendingPoints"
	pending_points_indicator.text = "+"
	pending_points_indicator.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	pending_points_indicator.offset_left = -56.0
	pending_points_indicator.offset_right = -38.0
	pending_points_indicator.offset_top = -14.0
	pending_points_indicator.offset_bottom = 14.0
	pending_points_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pending_points_indicator.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pending_points_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pending_points_indicator.add_theme_font_size_override("font_size", 20)
	pending_points_indicator.add_theme_color_override("font_color", Color("ff3030"))
	pending_points_indicator.add_theme_color_override("font_outline_color", Color.BLACK)
	pending_points_indicator.add_theme_constant_override("outline_size", 2)
	pending_points_indicator.hide()
	panel.add_child(pending_points_indicator)

# UI grouping only; never infer combat from HP or change gameplay state.
static func resolve_status(loop_state: String, in_combat: bool, combat_context: String) -> Dictionary:
	var caption := "Делает квест"
	var color := Color("303844")
	if loop_state == HeroState.DEAD_RESPAWNING:
		return {"text": "Мёртв", "color": Color("ff4545")}
	if in_combat:
		caption = "В бою"
		if combat_context == "dungeon":
			caption = "Данж: бой"
		elif combat_context == "event":
			caption = "Событие: бой"
		return {"text": caption, "color": Color("ff9e38")}
	match loop_state:
		HeroState.VISITING_GUILD, HeroState.VISITING_MARKET, HeroState.SHOPPING, HeroState.PREPARING_DUNGEON, HeroState.ARRIVED_IN_CITY:
			caption = "В городе"
		HeroState.RECOVERING_AFTER_FIGHT, HeroState.RECOVERING_IN_CITY:
			caption = "Восстанавливается"
		HeroState.TRAVEL_TO_CITY:
			caption = "Переезжает"
		HeroState.RETURNING_TO_CITY, HeroState.DUNGEON_RETURNING_TO_CITY:
			caption = "Возвращается"
		HeroState.TRAVEL_TO_DUNGEON:
			caption = "Идёт в данж"
			color = Color("ffd34d")
		HeroState.AT_DUNGEON_ENTRANCE, HeroState.DOING_DUNGEON, HeroState.DUNGEON_BETWEEN_FIGHTS, HeroState.DUNGEON_COMPLETED:
			caption = "В данже"
			color = Color("ff9e38")
		HeroState.EVENT_ACTIVE, HeroState.EVENT_COMBAT:
			caption = "В событии"
			color = Color("ffd34d")
	return {"text": caption, "color": color}

func refresh_status() -> void:
	if not active:
		return
	var simulation = _ui.simulation
	pending_points_indicator.visible = simulation.hero_state.pending_primary_attribute_points > 0
	var status := resolve_status(simulation.hero_state.loop_state, simulation.active_combat_session != null, simulation.active_combat_context)
	if status_label.text != status.text:
		status_label.text = status.text
	if status_label.get_theme_color("font_color") != status.color:
		status_label.add_theme_color_override("font_color", status.color)

func _on_panel_gui_input(event: InputEvent) -> void:
	if active and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if DisplayServer.has_feature(DisplayServer.FEATURE_WINDOW_DRAG):
			DisplayServer.window_start_drag(_window.get_window_id())

func enter_mini_mode() -> void:
	if active:
		return
	_saved_window = {
		"mode": _window.mode,
		"size": _window.size,
		"position": _window.position,
		"min_size": _window.min_size,
		"max_size": _window.max_size,
		"content_scale_size": _window.content_scale_size,
		"always_on_top": _window.always_on_top,
		"unresizable": _window.unresizable,
		"borderless": _window.borderless,
	}
	_saved_visibility.clear()
	for child in _ui.get_children():
		if child is CanvasItem and child != panel:
			_saved_visibility[child] = child.visible
			child.hide()
	active = true
	_window.mode = Window.MODE_WINDOWED
	_window.min_size = Vector2i.ZERO
	_window.max_size = Vector2i.ZERO
	_window.content_scale_size = Vector2i.ZERO
	_window.unresizable = true
	_window.always_on_top = true
	_window.borderless = true
	_window.size = MINI_SIZE
	if _has_mini_position:
		_window.position = _mini_position
	refresh_status()
	panel.show()
	expand_button.grab_focus()

func exit_mini_mode() -> void:
	if not active:
		return
	_mini_position = _window.position
	_has_mini_position = true
	panel.hide()
	_window.always_on_top = _saved_window.always_on_top
	_window.unresizable = _saved_window.unresizable
	_window.borderless = _saved_window.borderless
	_window.min_size = _saved_window.min_size
	_window.max_size = _saved_window.max_size
	_window.content_scale_size = _saved_window.content_scale_size
	_window.size = _saved_window.size
	_window.position = _saved_window.position
	_window.mode = _saved_window.mode
	for control in _saved_visibility:
		if is_instance_valid(control):
			control.visible = _saved_visibility[control]
	_saved_visibility.clear()
	active = false
	_ui.refresh_visible_screen()
	if _ui.map_screen.is_visible_in_tree():
		_ui.map_screen.refresh()

func _exit_tree() -> void:
	# Do not leave the application window tiny if MainUI is removed.
	if active:
		exit_mini_mode()
