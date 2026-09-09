extends RefCounted

# Shared only by the main-screen menu, actions, speeds and narrative tabs.
# Keep font sizes, content margins and all input/gameplay behavior at callers.
const COLORS := {
	"normal": [Color("2b3440"), Color("526174")],
	"hover": [Color("394758"), Color("849ab4")],
	"pressed": [Color("3b536c"), Color("a6bed6")],
	"hover_pressed": [Color("49637f"), Color("c2d4e6")],
	"disabled": [Color("262d36"), Color("414c5c")],
	"focus": [Color.TRANSPARENT, Color("c2d4e6")],
}

static func make_style(state: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = COLORS[state][0]
	style.border_color = COLORS[state][1]
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.shadow_size = 0
	style.content_margin_left = 14.0
	style.content_margin_right = 14.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	return style

static func apply_button(button: Button) -> void:
	button.add_theme_color_override("font_color", Color("edf0f4"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_color_override("font_hover_pressed_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", Color("929eae"))
	for state in COLORS:
		button.add_theme_stylebox_override(state, make_style(state))

static func set_navigation_selected(button: Button, selected: bool) -> void:
	# Highlight current destination without changing Button.toggle_mode or signals.
	button.add_theme_stylebox_override("normal", make_style("pressed" if selected else "normal"))
	button.add_theme_stylebox_override("hover", make_style("hover_pressed" if selected else "hover"))

static func apply_tabs(tabs: TabContainer) -> void:
	tabs.add_theme_color_override("font_selected_color", Color.WHITE)
	tabs.add_theme_color_override("font_unselected_color", Color("b7c3d1"))
	tabs.add_theme_color_override("font_hovered_color", Color.WHITE)
	tabs.add_theme_color_override("font_disabled_color", Color("929eae"))
	tabs.add_theme_stylebox_override("tab_selected", make_style("pressed"))
	tabs.add_theme_stylebox_override("tab_unselected", make_style("normal"))
	tabs.add_theme_stylebox_override("tab_hovered", make_style("hover"))
	tabs.add_theme_stylebox_override("tab_disabled", make_style("disabled"))
	tabs.add_theme_stylebox_override("tab_focus", make_style("focus"))
