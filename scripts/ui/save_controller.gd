extends Node

const StoreScript = preload("res://scripts/core/save_store.gd")
const SnapshotScript = preload("res://scripts/core/simulation_snapshot.gd")
const MainUIScript = preload("res://scripts/ui/main_ui.gd")
const AUTOSAVE_SECONDS := 600.0
var store = StoreScript.new()
var elapsed: float = 0.0
var host: Control
var ui: Control
var completed_dungeons: int = 0
var status_label: Label
var pending_quit: bool = false

func _ready() -> void:
	host = get_parent()
	process_priority = 10 # All snapshots happen after the current UI/simulation step.
	get_tree().auto_accept_quit = false
	refresh_continue()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		request_exit()

func request_exit() -> void:
	if pending_quit:
		return
	pending_quit = true
	if is_instance_valid(ui):
		var result := save_slot("auto")
		if result.has("error"):
			pending_quit = false
			if ui.mini_mode.active:
				ui.mini_mode.exit_mini_mode()
			ui.open_game_menu()
			show_message("Не удалось сохранить перед выходом. Игра остаётся открытой.\n" + str(result.error), ui.game_menu)
			return
	get_tree().quit()

func refresh_continue() -> void:
	var available := latest_candidates()
	host.continue_button.disabled = available.is_empty()
	host.continue_button.tooltip_text = "Продолжить последнее сохранение" if not available.is_empty() else "Нет доступных сохранений"
	host.start_hint.text = describe(available[0]) if not available.is_empty() else "Начните новую историю героя"

func latest_candidates() -> Array[Dictionary]:
	var all: Array[Dictionary] = []
	for slot in ["manual", "auto"]:
		all.append_array(store.candidates(slot))
	all.sort_custom(func(a, b): return a.metadata.saved_at > b.metadata.saved_at)
	return all

func describe(data: Dictionary) -> String:
	var meta: Dictionary = data.metadata
	var date := Time.get_datetime_string_from_unix_time(int(meta.saved_at / 1000), true)
	return "%s · ур. %d\n%s · %s UTC%s" % [meta.hero, meta.level, "Ручное" if meta.slot == "manual" else "Автосохранение", date, " (резервная копия)" if data.get("backup", false) else ""]

func request_new_game() -> void:
	host.begin_new_game()

func confirm_new_game(create_game: Callable) -> void:
	if store.candidates("auto").is_empty():
		create_game.call()
		return
	var dialog := ConfirmationDialog.new()
	dialog.title = "Новая история"
	dialog.dialog_text = "Автосохранение прежнего героя будет заменено.\nРучное сохранение останется. Начать новую игру?"
	dialog.confirmed.connect(create_game)
	present(dialog, host)

func attach_game(game: Control, fresh: bool) -> void:
	ui = game
	elapsed = 0.0
	completed_dungeons = dungeon_count()
	ui.save_requested.connect(request_manual_save)
	ui.load_requested.connect(request_load)
	status_label = Label.new()
	status_label.name = "SaveStatus"
	status_label.position = Vector2(371, 742)
	status_label.add_theme_font_size_override("font_size", 12)
	status_label.add_theme_color_override("font_color", Color("c1cad5"))
	ui.main_screen.add_child(status_label)
	if fresh:
		var result := save_slot("auto")
		if result.has("error"):
			ui.open_game_menu()
			show_message(str(result.error), ui.game_menu)

func dungeon_count() -> int:
	if not is_instance_valid(ui) or ui.simulation.dungeon_system == null:
		return 0
	var total := 0
	for instance in ui.simulation.dungeon_system.dungeon_instances:
		if instance.completed:
			total += 1
	return total

func _process(delta: float) -> void:
	if not is_instance_valid(ui):
		return
	elapsed += delta
	var count := dungeon_count()
	if elapsed >= AUTOSAVE_SECONDS or count > completed_dungeons:
		completed_dungeons = count
		elapsed = 0.0 # Failed writes retry next interval, never every frame.
		var result := save_slot("auto")
		if result.has("error"):
			status_label.text = "Ошибка автосохранения — откройте меню"
			status_label.tooltip_text = str(result.error)

func save_slot(slot: String) -> Dictionary:
	if not is_instance_valid(ui):
		return {"error": "Игра ещё не начата"}
	var snapshot: Dictionary = SnapshotScript.capture(ui.simulation)
	if snapshot.has("error"):
		return snapshot
	var result: Dictionary = store.write_slot(slot, snapshot, ui.simulation.hero_state.hero_name, ui.simulation.hero_state.level)
	if result.has("error"):
		status_label.text = "Ошибка сохранения"
		status_label.tooltip_text = str(result.error)
	else:
		status_label.text = "Ручное сохранение записано" if slot == "manual" else "Автосохранение записано"
		status_label.tooltip_text = ""
	return result

func request_manual_save() -> void:
	if not store.candidates("manual").is_empty():
		var dialog := ConfirmationDialog.new()
		dialog.title = "Перезаписать ручное сохранение?"
		dialog.dialog_text = "Предыдущее ручное сохранение будет заменено."
		dialog.confirmed.connect(perform_manual_save)
		present(dialog, ui.game_menu)
	else:
		perform_manual_save()

func perform_manual_save() -> void:
	var result := save_slot("manual")
	show_message(str(result.error) if result.has("error") else "Ручное сохранение записано.", ui.game_menu)

func request_load() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "Загрузить игру"
	dialog.ok_button_text = "Отмена"
	dialog.min_size = Vector2i(460, 260)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	for slot in ["manual", "auto"]:
		var candidates: Array[Dictionary] = store.candidates(slot)
		var button := Button.new()
		button.name = slot
		button.text = describe(candidates[0]) if not candidates.is_empty() else ("Ручное" if slot == "manual" else "Автосохранение") + " — нет исправного файла"
		button.disabled = candidates.is_empty()
		button.custom_minimum_size = Vector2(420, 64)
		MainUIScript.MainButtonStyle.apply_button(button)
		button.pressed.connect(func():
			dialog.hide()
			dialog.queue_free()
			confirm_load(slot)
		)
		content.add_child(button)
	dialog.add_child(content)
	present(dialog, ui.game_menu)

func confirm_load(slot: String) -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = "Загрузить сохранение?"
	dialog.dialog_text = "Несохранённый прогресс будет потерян."
	dialog.confirmed.connect(func(): load_candidates(store.candidates(slot)))
	present(dialog, ui.game_menu)

func continue_game() -> void:
	load_candidates(latest_candidates())

func load_candidates(candidates: Array[Dictionary]) -> void:
	var last_error := "Нет исправного сохранения"
	for candidate in candidates:
		var result: Dictionary = SnapshotScript.restore(candidate.snapshot)
		if result.get("simulation") == null:
			last_error = str(result.get("error", last_error))
			continue
		var old_ui = ui
		if is_instance_valid(old_ui):
			if old_ui.mini_mode.active:
				old_ui.mini_mode.exit_mini_mode()
			old_ui.set_process(false)
			old_ui.hide()
			old_ui.queue_free()
		host.start_menu.hide()
		host.start_backdrop.hide()
		host.background_screen.hide()
		host.class_screen.hide()
		host.simulation = result.simulation
		host.game_ui = MainUIScript.new(result.simulation)
		host.game_ui.name = "MainUI"
		host.game_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		host.add_child(host.game_ui)
		attach_game(host.game_ui, false)
		if candidate.get("backup", false):
			ui.open_game_menu()
			show_message("Основной файл недоступен. Загружена резервная копия.", ui.game_menu)
		return
	show_message("Загрузка не выполнена. Текущая игра не изменена.\n" + last_error, ui.game_menu if is_instance_valid(ui) else host)

func show_message(message: String, parent: Node) -> void:
	if parent == null:
		if is_instance_valid(ui):
			ui.open_game_menu()
			parent = ui.game_menu
		else:
			parent = host
	var dialog := AcceptDialog.new()
	dialog.title = "Сохранения"
	dialog.dialog_text = message
	present(dialog, parent)

func present(dialog: AcceptDialog, parent: Node) -> void:
	# A parent Window can have only one exclusive child at a time.
	for child in parent.get_children():
		if child is AcceptDialog and child.visible:
			child.hide()
			child.queue_free()
	parent.add_child(dialog)
	dialog.exclusive = true
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered()
