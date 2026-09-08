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

func on_background_completed(answers: Array) -> void:
	if not background_answers.is_empty() or HeroBackgroundScript.new().resolve_answers(answers).is_empty():
		return
	background_answers = answers.duplicate()
	background_screen.hide()
	class_screen.show()
	class_screen.next_button.grab_focus()

func start_game() -> void:
	if simulation != null or background_answers.is_empty() or not class_screen.visible:
		return
	# No simulation exists during either setup screen; bonuses apply only here.
	simulation = SimulationScript.new(simulation_seed, null, [], true, background_answers)
	class_screen.hide()
	game_ui = MainUIScript.new(simulation)
	game_ui.name = "MainUI"
	game_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(game_ui)
