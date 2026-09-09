class_name NarrativePanel
extends TabContainer

const MainButtonStyle = preload("res://scripts/ui/main_screen_button_style.gd")

var simulation
var log_text_edit: TextEdit
var diary_text_edit: TextEdit
var last_rendered_log_text: String = ""
var last_rendered_diary_text: String = ""

func setup(simulation_reference) -> void:
	simulation = simulation_reference
	if is_node_ready():
		connect_sources()
		refresh()

func _ready() -> void:
	apply_tabs_style()
	create_tabs()
	connect_sources()
	refresh()

func connect_sources() -> void:
	if simulation == null:
		return
	if not simulation.world_clock.tick_completed.is_connected(on_world_tick_completed):
		simulation.world_clock.tick_completed.connect(on_world_tick_completed)
	if not simulation.debug_log.text_changed.is_connected(on_debug_log_text_changed):
		simulation.debug_log.text_changed.connect(on_debug_log_text_changed)
	if not simulation.diary.text_changed.is_connected(on_diary_text_changed):
		simulation.diary.text_changed.connect(on_diary_text_changed)

func apply_tabs_style() -> void:
	var tabs_panel_style := StyleBoxFlat.new()
	tabs_panel_style.bg_color = Color("232830")
	tabs_panel_style.border_color = Color("495462")
	tabs_panel_style.set_border_width_all(1)
	# Keep the previous two-pixel inset despite the thinner visual border.
	tabs_panel_style.set_content_margin_all(2.0)
	tabs_panel_style.set_corner_radius_all(10)
	add_theme_stylebox_override("panel", tabs_panel_style)
	# TabContainer forwards its own theme to the internal TabBar.
	add_theme_font_size_override("font_size", 16)
	MainButtonStyle.apply_tabs(self)

func create_tabs() -> void:
	log_text_edit = create_read_only_text_edit()
	log_text_edit.name = "Лог"
	add_child(log_text_edit)

	diary_text_edit = create_read_only_text_edit()
	diary_text_edit.name = "Дневник"
	diary_text_edit.placeholder_text = "Пока записей нет."
	add_child(diary_text_edit)

func refresh() -> void:
	if simulation == null or log_text_edit == null or diary_text_edit == null:
		return
	update_debug_log(simulation.debug_log.get_text())
	update_diary(simulation.diary.get_text())

func on_world_tick_completed(_completed_tick: int) -> void:
	refresh()

func on_debug_log_text_changed(log_text: String) -> void:
	update_debug_log(log_text)

func on_diary_text_changed(diary_text: String) -> void:
	update_diary(diary_text)

func update_debug_log(log_text: String) -> void:
	if log_text_edit == null:
		return
	if log_text == last_rendered_log_text:
		return
	last_rendered_log_text = log_text
	log_text_edit.text = log_text
	var scroll_bar: VScrollBar = log_text_edit.get_v_scroll_bar()
	scroll_bar.value = scroll_bar.max_value
	call_deferred("scroll_debug_log_to_bottom")

func update_diary(diary_text: String) -> void:
	if diary_text_edit == null:
		return
	if diary_text == last_rendered_diary_text:
		return
	last_rendered_diary_text = diary_text
	diary_text_edit.text = diary_text
	var scroll_bar: VScrollBar = diary_text_edit.get_v_scroll_bar()
	scroll_bar.value = scroll_bar.max_value
	call_deferred("scroll_diary_to_bottom")

func scroll_debug_log_to_bottom() -> void:
	if log_text_edit == null or not is_inside_tree():
		return
	await get_tree().process_frame
	if not is_instance_valid(log_text_edit):
		return
	var scroll_bar: VScrollBar = log_text_edit.get_v_scroll_bar()
	scroll_bar.value = scroll_bar.max_value

func scroll_diary_to_bottom() -> void:
	if diary_text_edit == null or not is_inside_tree():
		return
	await get_tree().process_frame
	if not is_instance_valid(diary_text_edit):
		return
	var scroll_bar: VScrollBar = diary_text_edit.get_v_scroll_bar()
	scroll_bar.value = scroll_bar.max_value

func create_read_only_text_edit() -> TextEdit:
	var text_edit := TextEdit.new()
	text_edit.editable = false
	text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	text_edit.add_theme_font_size_override("font_size", 15)
	text_edit.add_theme_color_override("font_readonly_color", Color("e1e5ea"))
	var text_style := StyleBoxFlat.new()
	text_style.bg_color = Color("171b21")
	text_style.border_color = Color("586371")
	text_style.set_border_width_all(1)
	text_style.set_corner_radius_all(8)
	text_style.content_margin_left = 10.0
	text_style.content_margin_right = 10.0
	text_style.content_margin_top = 8.0
	text_style.content_margin_bottom = 8.0
	text_edit.add_theme_stylebox_override("read_only", text_style)
	return text_edit
