extends Control

signal completed

var selected_class_id: String = ""
var class_buttons: Array[Button] = []
var next_button: Button
var selection_status: Label

func _ready() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "top", "right"]:
		margin.add_theme_constant_override("margin_" + side, 32)
	margin.add_theme_constant_override("margin_bottom", 74)
	add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	margin.add_child(layout)

	var heading := Label.new()
	heading.name = "Heading"
	heading.text = "У кого ты будешь учиться?"
	heading.add_theme_color_override("font_color", Color("303844"))
	heading.add_theme_font_size_override("font_size", 28)
	layout.add_child(heading)

	var body_panel := PanelContainer.new()
	body_panel.name = "BodyPanel"
	body_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("232830")
	panel_style.border_color = Color("7b8694")
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(12)
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		panel_style.set_content_margin(side, 20)
	body_panel.add_theme_stylebox_override("panel", panel_style)
	layout.add_child(body_panel)

	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	body_panel.add_child(body)

	var narrative := Label.new()
	narrative.name = "Narrative"
	narrative.text = "Вы с Ильёй выросли вместе. Однажды на вас напали чудовища. Ты выжил. Илья — нет. Теперь ты хочешь стать искателем приключений, пройти обучение и отомстить за друга."
	narrative.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	narrative.add_theme_color_override("font_color", Color("edf0f4"))
	narrative.add_theme_font_size_override("font_size", 18)
	body.add_child(narrative)

	var prompt := Label.new()
	prompt.text = "Выбери наставника для первого шага на этом пути."
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt.add_theme_color_override("font_color", Color("edf0f4"))
	prompt.add_theme_font_size_override("font_size", 16)
	body.add_child(prompt)

	var options := GridContainer.new()
	options.columns = 2
	options.add_theme_constant_override("h_separation", 14)
	options.add_theme_constant_override("v_separation", 12)
	options.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(options)
	create_class_button(options, "Воин — опытный боец", "warrior", false)
	create_class_button(options, "Лучник — следопыт\nПока недоступно", "archer", true)
	create_class_button(options, "Маг — наставник тайных искусств\nПока недоступно", "mage", true)
	create_class_button(options, "Ассасин — мастер скрытного боя\nПока недоступно", "assassin", true)

	selection_status = Label.new()
	selection_status.name = "SelectionStatus"
	selection_status.text = "Выбери наставника, чтобы продолжить."
	selection_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	selection_status.add_theme_color_override("font_color", Color("edf0f4"))
	selection_status.add_theme_font_size_override("font_size", 16)
	body.add_child(selection_status)

	next_button = Button.new()
	next_button.name = "NextButton"
	next_button.text = "Дальше"
	next_button.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	next_button.offset_left = -166
	next_button.offset_top = -58
	next_button.offset_right = -16
	next_button.offset_bottom = -16
	next_button.disabled = true
	next_button.pressed.connect(_complete_selection)
	add_child(next_button)

func create_class_button(parent: GridContainer, title: String, class_id: String, unavailable: bool) -> void:
	var button := Button.new()
	button.name = "%sButton" % class_id.capitalize()
	button.text = title
	button.custom_minimum_size = Vector2(0, 58)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 18)
	button.disabled = unavailable
	if unavailable:
		button.tooltip_text = "Пока недоступно"
	else:
		button.pressed.connect(select_class.bind(class_id))
	parent.add_child(button)
	class_buttons.append(button)

func select_class(class_id: String) -> void:
	if class_id != "warrior":
		return
	selected_class_id = class_id
	next_button.disabled = false
	selection_status.text = "Обучение у воина завершено. Ты готов начать путь мести."

func _complete_selection() -> void:
	if selected_class_id != "warrior":
		return
	completed.emit()
