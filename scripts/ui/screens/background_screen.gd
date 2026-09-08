extends Control

signal completed(answers: Array)
const HeroBackgroundScript = preload("res://scripts/hero/hero_background.gd")
var background = HeroBackgroundScript.new()
var selected_answers: Array = [-1, -1, -1, -1]
var answer_buttons: Array = []
var next_button: Button
var submitted: bool = false

func _ready() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	add_child(margin)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 8)
	margin.add_child(layout)
	var heading := Label.new()
	heading.text = "Прошлое героя"
	heading.add_theme_color_override("font_color", Color("303844"))
	heading.add_theme_font_size_override("font_size", 19)
	layout.add_child(heading)
	var scroll := ScrollContainer.new()
	scroll.name = "QuestionsScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	layout.add_child(scroll)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 40)
	grid.add_theme_constant_override("v_separation", 28)
	scroll.add_child(grid)
	for index in range(background.questions.size()):
		create_question(grid, index)
	var footer := HBoxContainer.new()
	layout.add_child(footer)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(spacer)
	next_button = Button.new()
	next_button.name = "NextButton"
	next_button.text = "Дальше"
	next_button.custom_minimum_size = Vector2(150, 42)
	next_button.disabled = true
	next_button.pressed.connect(submit)
	footer.add_child(next_button)

func create_question(parent: Container, index: int) -> void:
	var question: Dictionary = background.questions[index]
	var box := VBoxContainer.new()
	box.name = "Question%d" % (index + 1)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 4)
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("232830")
	panel_style.border_color = Color("7b8694")
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(12)
	# Small insets keep text clear of the matching panel border.
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		panel_style.set_content_margin(side, 4)
	panel.add_theme_stylebox_override("panel", panel_style)
	parent.add_child(panel)
	panel.add_child(box)
	var title := Label.new()
	title.text = question.title
	title.add_theme_font_size_override("font_size", 17)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(title)
	var prompt := Label.new()
	prompt.text = question.text
	prompt.add_theme_font_size_override("font_size", 15)
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(prompt)
	var group := ButtonGroup.new()
	var buttons: Array = []
	for option_index in range(question.answers.size()):
		var option: Dictionary = question.answers[option_index]
		var button := CheckBox.new()
		button.name = "Answer%d" % (option_index + 1)
		button.text = "%s  [%s]" % [option.text, option.bonus]
		button.button_group = group
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.add_theme_font_size_override("font_size", 15)
		var compact_style := StyleBoxEmpty.new()
		compact_style.content_margin_left = 4
		compact_style.content_margin_right = 4
		compact_style.content_margin_top = 1
		compact_style.content_margin_bottom = 1
		for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
			button.add_theme_stylebox_override(state, compact_style)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(select_answer.bind(index, option_index))
		box.add_child(button)
		buttons.append(button)
	answer_buttons.append(buttons)

func select_answer(question_index: int, option_index: int) -> void:
	if submitted:
		return
	selected_answers[question_index] = option_index
	next_button.disabled = background.resolve_answers(selected_answers).is_empty()

func submit() -> void:
	if submitted or background.resolve_answers(selected_answers).is_empty():
		return
	submitted = true
	next_button.disabled = true
	completed.emit(selected_answers.duplicate())
