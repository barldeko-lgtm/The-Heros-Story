extends Control

const BackgroundScreenScene = preload("res://scenes/ui/screens/background_screen.tscn")
const ClassScreenScene = preload("res://scenes/ui/screens/class_selection_screen.tscn")
const HeroBackgroundScript = preload("res://scripts/hero/hero_background.gd")
const SimulationScript = preload("res://scripts/core/simulation.gd")
const MainUIScript = preload("res://scripts/ui/main_ui.gd")

var simulation_seed: int = int(Time.get_unix_time_from_system())
var background_screen: Control
var class_screen: Control
var game_ui: Control
var simulation = null
var background_answers: Array = []
var start_menu: CenterContainer
var new_game_button: Button
var continue_button: Button
var start_backdrop: ColorRect
var start_hint: Label
var persistence: Node
var save_directory: String = "user://saves"

func _ready() -> void:
	var backdrop := ColorRect.new()
	backdrop.name = "StartupBackground"
	backdrop.color = Color("d9dde2")
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	var setup_theme: Theme = create_setup_theme()
	background_screen = BackgroundScreenScene.instantiate()
	background_screen.theme = setup_theme
	background_screen.completed.connect(on_background_completed)
	add_child(background_screen)
	class_screen = ClassScreenScene.instantiate()
	class_screen.theme = setup_theme
	class_screen.visible = false
	class_screen.completed.connect(start_game)
	add_child(class_screen)
	background_screen.hide()
	create_start_menu()
	persistence = preload("res://scripts/ui/save_controller.gd").new()
	persistence.store = preload("res://scripts/core/save_store.gd").new(save_directory)
	add_child(persistence)
	continue_button.pressed.connect(persistence.continue_game)

# Scoped to the two setup screens: never changes the existing game UI theme.
# Palette and Next styles match MainUI's background and secondary buttons.
func create_setup_theme() -> Theme:
	var result := Theme.new()
	result.set_color("font_color", "Label", Color("edf0f4"))
	for control_type in ["Button", "CheckBox"]:
		result.set_color("font_color", control_type, Color("edf0f4"))
		result.set_color("font_hover_color", control_type, Color.WHITE)
		result.set_color("font_pressed_color", control_type, Color.WHITE)
		result.set_color("font_hover_pressed_color", control_type, Color.WHITE)
		result.set_color("font_disabled_color", control_type, Color("858b94"))
	var states := {
		"normal": ["303844", "707d8e", 2],
		"hover": ["414c5b", "b3bdca", 3],
		"pressed": ["20262e", "d5dbe3", 1],
		"focus": ["414c5b", "d5dbe3", 2],
		"disabled": ["292e35", "4d5560", 0],
	}
	for state in states:
		var values: Array = states[state]
		var style := StyleBoxFlat.new()
		style.bg_color = Color(values[0])
		style.border_color = Color(values[1])
		style.set_border_width_all(2)
		style.set_corner_radius_all(9)
		style.shadow_color = Color(0.0, 0.0, 0.0, 0.35)
		style.shadow_size = int(values[2])
		style.shadow_offset = Vector2(0.0, 2.0)
		style.content_margin_left = 14
		style.content_margin_right = 14
		style.content_margin_top = 8
		style.content_margin_bottom = 8
		result.set_stylebox(state, "Button", style)
	for checked in [false, true]:
		var dot: String = '<circle cx="8" cy="8" r="3" fill="#edf0f4"/>' if checked else ""
		var svg: String = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"><circle cx="8" cy="8" r="6" fill="#303844" stroke="#7b8694" stroke-width="2"/>%s</svg>' % dot
		var image := Image.new()
		image.load_svg_from_string(svg)
		result.set_icon("radio_checked" if checked else "radio_unchecked", "CheckBox", ImageTexture.create_from_image(image))
	return result

func create_start_menu() -> void:
	start_menu = CenterContainer.new()
	start_menu.name = "StartMenu"
	start_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var backdrop := ColorRect.new()
	start_backdrop = backdrop
	backdrop.color = Color("191e26")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	add_child(start_menu)
	var content := VBoxContainer.new()
	content.custom_minimum_size.x = 320
	content.add_theme_constant_override("separation", 16)
	start_menu.add_child(content)
	var title := Label.new()
	title.text = "The Hero’s Story"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	content.add_child(title)
	new_game_button = Button.new()
	new_game_button.text = "Новая игра"
	continue_button = Button.new()
	continue_button.text = "Продолжить"
	continue_button.disabled = true
	continue_button.tooltip_text = "Загрузка сохранений пока не подключена"
	for button in [new_game_button, continue_button]:
		button.custom_minimum_size.y = 48
		MainUIScript.MainButtonStyle.apply_button(button)
		content.add_child(button)
	var hint := Label.new()
	start_hint = hint
	hint.text = "Сохранение и загрузка пока недоступны"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color("9eabbc"))
	content.add_child(hint)
	new_game_button.pressed.connect(func(): persistence.request_new_game())
	new_game_button.grab_focus()

func begin_new_game() -> void:
	start_menu.hide()
	start_backdrop.hide()
	background_screen.show()

func on_background_completed(answers: Array) -> void:
	if not background_answers.is_empty() or HeroBackgroundScript.new().resolve_answers(answers).is_empty():
		return
	background_answers = answers.duplicate()
	background_screen.hide()
	class_screen.show()
	class_screen.class_buttons[0].grab_focus()

func start_game() -> void:
	if simulation != null or background_answers.is_empty() or not class_screen.visible:
		return
	if class_screen.selected_class_id != "warrior":
		return
	persistence.confirm_new_game(create_game)

func create_game() -> void:
	if simulation != null or not class_screen.visible:
		return
	# No simulation exists during either setup screen; bonuses apply only here.
	simulation = SimulationScript.new(simulation_seed, null, [], true, background_answers)
	class_screen.hide()
	game_ui = MainUIScript.new(simulation)
	game_ui.name = "MainUI"
	game_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(game_ui)
	persistence.attach_game(game_ui, true)
