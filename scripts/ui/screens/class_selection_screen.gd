extends Control

signal completed
var next_button: Button

func _ready() -> void:
	next_button = Button.new()
	next_button.name = "NextButton"
	next_button.text = "Дальше"
	next_button.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	next_button.offset_left = -166
	next_button.offset_top = -58
	next_button.offset_right = -16
	next_button.offset_bottom = -16
	next_button.pressed.connect(func(): completed.emit())
	add_child(next_button)
