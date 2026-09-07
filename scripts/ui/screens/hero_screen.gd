extends Control

signal hero_state_changed

const TraitDevelopmentScript = preload("res://scripts/hero/trait_development.gd")
const PRIMARY_ATTRIBUTE_DISPLAY_NAMES := {
	"strength": "Сила",
	"dexterity": "Ловкость",
	"intelligence": "Интеллект",
	"constitution": "Телосложение",
	"wisdom": "Мудрость",
}
var simulation
var attribute_points_label: Label
var attribute_buttons: Dictionary = {}
var personality_axis_bars: Dictionary = {}
var personality_axis_markers: Dictionary = {}
var personality_axis_value_labels: Dictionary = {}

func setup(live_simulation) -> void:
	simulation = live_simulation

func _ready() -> void:
	create_attribute_allocation_panel()
	create_personality_panel()
	refresh()

func refresh() -> void:
	update_attribute_allocation_panel()
	update_personality_panel()

func create_attribute_allocation_panel() -> void:
	var panel := PanelContainer.new()
	panel.name = "AttributeAllocationPanel"
	apply_panel_style(panel)
	panel.position = Vector2(411.0, 108.0)
	panel.size = Vector2(544.0, 360.0)
	add_child(panel)

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

func create_personality_panel() -> void:
	var panel := PanelContainer.new()
	panel.name = "PersonalityAxesPanel"
	apply_panel_style(panel)
	panel.position = Vector2(411.0, 472.0)
	panel.size = Vector2(544.0, 280.0)
	add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 2)
	panel.add_child(content)

	var header := HBoxContainer.new()
	header.custom_minimum_size = Vector2(0.0, 26.0)
	content.add_child(header)

	var title := Label.new()
	title.text = "Черты характера"
	title.add_theme_font_size_override("font_size", 20)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var range_label := Label.new()
	range_label.text = "−100 … +100"
	range_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	range_label.add_theme_font_size_override("font_size", 12)
	range_label.add_theme_color_override("font_color", Color("aeb6c1"))
	header.add_child(range_label)

	create_personality_axis(content, TraitDevelopmentScript.AXIS_COURAGE, "CouragePersonalityAxis", "Осторожный", "Смелый")
	create_personality_axis(content, TraitDevelopmentScript.AXIS_MORALITY, "MoralityPersonalityAxis", "Хитрый", "Благородный")
	create_personality_axis(content, TraitDevelopmentScript.AXIS_GREED, "GreedPersonalityAxis", "Жадный", "Щедрый")
	create_personality_axis(content, TraitDevelopmentScript.AXIS_CURIOSITY, "CuriosityPersonalityAxis", "Консервативный", "Любопытный")

func create_personality_axis(parent: VBoxContainer, axis_id: String, axis_name: String, negative_label: String, positive_label: String) -> void:
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
	negative.add_theme_font_size_override("font_size", 11)
	labels.add_child(negative)

	var positive := Label.new()
	positive.text = positive_label
	positive.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	positive.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	positive.add_theme_font_size_override("font_size", 11)
	labels.add_child(positive)

	var track := Control.new()
	track.name = "AxisTrack"
	track.custom_minimum_size = Vector2(506.0, 35.0)
	row.add_child(track)

	var value_label := Label.new()
	value_label.name = "CurrentValueLabel"
	value_label.position = Vector2(231.0, 0.0)
	value_label.size = Vector2(44.0, 14.0)
	value_label.text = "0"
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.add_theme_font_size_override("font_size", 10)
	value_label.add_theme_color_override("font_color", Color("edf0f4"))
	value_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	track.add_child(value_label)

	var bar := ColorRect.new()
	bar.name = "AxisBar"
	bar.position = Vector2(0.0, 14.0)
	bar.size = Vector2(506.0, 8.0)
	bar.color = Color("15191f")
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	track.add_child(bar)

	for axis_value in [-40, 40, -20, 20]:
		var threshold := ColorRect.new()
		threshold.name = "Threshold%s" % str(axis_value).replace("-", "Minus")
		threshold.position = Vector2(506.0 * (float(axis_value) + 100.0) / 200.0 - 1.0, 0.0)
		threshold.size = Vector2(2.0, 8.0)
		threshold.color = Color("d0a95b")
		threshold.mouse_filter = Control.MOUSE_FILTER_IGNORE
		threshold.visible = abs(axis_value) == TraitDevelopmentScript.ACTIVATION_THRESHOLD
		bar.add_child(threshold)

	var value_marker := ColorRect.new()
	value_marker.name = "ValueMarker"
	value_marker.position = Vector2(251.0, -2.0)
	value_marker.size = Vector2(4.0, 12.0)
	value_marker.color = Color("edf0f4")
	value_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_child(value_marker)

	var center_zero := Label.new()
	center_zero.name = "CenterZeroLabel"
	center_zero.position = Vector2(235.0, 22.0)
	center_zero.size = Vector2(36.0, 13.0)
	center_zero.text = "0"
	center_zero.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_zero.add_theme_font_size_override("font_size", 10)
	center_zero.add_theme_color_override("font_color", Color("aeb6c1"))
	center_zero.mouse_filter = Control.MOUSE_FILTER_IGNORE
	track.add_child(center_zero)

	personality_axis_bars[axis_id] = bar
	personality_axis_markers[axis_id] = value_marker
	personality_axis_value_labels[axis_id] = value_label

func update_personality_panel() -> void:
	for axis_id in personality_axis_bars:
		var bar := personality_axis_bars[axis_id] as ColorRect
		var marker := personality_axis_markers[axis_id] as ColorRect
		var value_label := personality_axis_value_labels[axis_id] as Label
		if bar == null or marker == null or value_label == null:
			continue
		var axis_value: int = clampi(int(simulation.hero_state.personality_axis_values.get(axis_id, 0)), TraitDevelopmentScript.MIN_AXIS_VALUE, TraitDevelopmentScript.MAX_AXIS_VALUE)
		var axis_value_x: float = 506.0 * (float(axis_value) + 100.0) / 200.0
		marker.position.x = axis_value_x - marker.size.x * 0.5
		value_label.text = "0" if axis_value == 0 else "%+d" % axis_value
		value_label.position.x = clampf(axis_value_x - value_label.size.x * 0.5, 0.0, 506.0 - value_label.size.x)
		var active_trait: String = str(simulation.hero_state.personality_traits_by_axis.get(axis_id, ""))
		var threshold_minus_40 := bar.get_node("ThresholdMinus40") as ColorRect
		var threshold_40 := bar.get_node("Threshold40") as ColorRect
		var threshold_minus_20 := bar.get_node("ThresholdMinus20") as ColorRect
		var threshold_20 := bar.get_node("Threshold20") as ColorRect
		var is_neutral: bool = active_trait.is_empty()
		threshold_minus_40.visible = is_neutral
		threshold_40.visible = is_neutral
		threshold_minus_20.visible = not is_neutral and axis_value < 0
		threshold_20.visible = not is_neutral and axis_value > 0

func on_allocate_attribute_pressed(attribute_id: String) -> void:
	if simulation.allocate_primary_attribute(attribute_id):
		hero_state_changed.emit()
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

