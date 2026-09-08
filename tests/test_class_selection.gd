extends SceneTree

const ClassSelectionScene = preload("res://scenes/ui/screens/class_selection_screen.tscn")
const TARGET_RECT := Rect2(Vector2.ZERO, Vector2(1366, 768))

func _init() -> void:
	call_deferred("run")

func run() -> void:
	root.size = Vector2i(1366, 768)
	var screen = ClassSelectionScene.instantiate()
	root.add_child(screen)
	await process_frame
	await process_frame

	assert(screen.selected_class_id.is_empty(), "No class is selected initially.")
	assert(screen.class_buttons.size() == 4, "The screen exposes all four class options.")
	assert(screen.class_buttons[0].text.contains("Воин") and screen.class_buttons[0].text.contains("опытный боец") and not screen.class_buttons[0].disabled)
	assert(screen.class_buttons[1].text.contains("Лучник") and screen.class_buttons[1].text.contains("следопыт") and screen.class_buttons[1].text.contains("Пока недоступно") and screen.class_buttons[1].disabled)
	assert(screen.class_buttons[2].text.contains("Маг") and screen.class_buttons[2].text.contains("наставник тайных искусств") and screen.class_buttons[2].text.contains("Пока недоступно") and screen.class_buttons[2].disabled)
	assert(screen.class_buttons[3].text.contains("Ассасин") and screen.class_buttons[3].text.contains("мастер скрытного боя") and screen.class_buttons[3].text.contains("Пока недоступно") and screen.class_buttons[3].disabled)
	assert(screen.next_button.disabled, "Next stays disabled until Warrior is explicitly selected.")
	assert(screen.find_child("Narrative", true, false).text.contains("Вы с Ильёй выросли вместе") and screen.find_child("Narrative", true, false).text.contains("Ты выжил. Илья — нет") and screen.find_child("Narrative", true, false).text.contains("отомстить"))
	assert(screen.find_child("Heading", true, false).text == "У кого ты будешь учиться?")
	assert(screen.find_child("BodyPanel", true, false).get_theme_stylebox("panel").bg_color == Color("232830"))
	assert(screen.find_child("BodyPanel", true, false).get_theme_stylebox("panel").border_color == Color("7b8694"))
	assert(screen.find_child("Heading", true, false).get_theme_color("font_color") == Color("303844"))
	assert(TARGET_RECT.encloses(screen.next_button.get_global_rect()), "Next fits at the bottom-right at 1366x768.")
	assert(screen.next_button.offset_left == -166 and screen.next_button.offset_top == -58 and screen.next_button.offset_right == -16 and screen.next_button.offset_bottom == -16)
	for button in screen.class_buttons:
		assert(TARGET_RECT.encloses(button.get_global_rect()), "Every class option fits without scrolling at 1366x768.")

	var completed_count := [0]
	screen.completed.connect(func() -> void: completed_count[0] += 1)
	screen.next_button.pressed.emit()
	assert(completed_count[0] == 0, "Disabled Next cannot complete selection.")
	screen.class_buttons[0].pressed.emit()
	assert(screen.selected_class_id == "warrior")
	assert(not screen.next_button.disabled)
	assert(screen.find_child("SelectionStatus", true, false).text.to_lower().contains("обучение"))
	screen.next_button.pressed.emit()
	assert(completed_count[0] == 1, "Next emits the existing argument-free completion signal after selection.")

	screen.queue_free()
	await process_frame
	print("PASS: class selection narrative, only Warrior availability, and explicit completion flow.")
	quit()
