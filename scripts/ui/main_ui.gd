extends Control

const WorldClockScript = preload("res://scripts/core/world_clock.gd")
const HeroNameRepositoryScript = preload("res://scripts/core/hero_name_repository.gd")
const HeroStateScript = preload("res://scripts/hero/hero_state.gd")
const DebugLogScript = preload("res://scripts/narrative/debug_log.gd")
const DiaryScript = preload("res://scripts/narrative/diary.gd")

var world_clock = WorldClockScript.new()
var debug_log = DebugLogScript.new()
var diary = DiaryScript.new()
var time_progress_bar: ProgressBar
var tick_counter_label: Label
var log_text_edit: TextEdit

func _ready() -> void:
	create_background()
	create_hero_panel()
	create_tick_indicator()
	create_narrative_panel()
	world_clock.tick_completed.connect(on_world_tick_completed)

func _process(delta: float) -> void:
	world_clock.advance_time(delta)
	time_progress_bar.value = world_clock.tick_progress * 100.0
	tick_counter_label.text = "Тик: %d" % world_clock.world_tick

func on_world_tick_completed(completed_tick: int) -> void:
	debug_log.record_tick(completed_tick)
	log_text_edit.text = debug_log.get_text()
	log_text_edit.scroll_vertical = log_text_edit.get_line_count()

func create_background() -> void:
	var background := ColorRect.new()
	background.color = Color("1a1c25")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

func create_hero_panel() -> void:
	var name_repository = HeroNameRepositoryScript.new()
	var hero = HeroStateScript.new(name_repository.get_random_name())

	var panel := PanelContainer.new()
	panel.position = Vector2(32.0, 32.0)
	panel.size = Vector2(300.0, 420.0)
	add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	panel.add_child(content)

	add_info_label(content, hero.hero_name, 26)
	add_info_label(content, hero.hero_class, 20)
	add_info_label(content, "Уровень: %d   XP: %d / %d" % [hero.level, hero.experience, hero.experience_to_next_level])
	add_info_label(content, "HP: %.0f / %.0f" % [hero.current_hp, hero.max_hp])
	add_info_label(content, "Сила: %d" % hero.strength)
	add_info_label(content, "Ловкость: %d" % hero.agility)
	add_info_label(content, "Интеллект: %d" % hero.intelligence)
	add_info_label(content, "Атака: %.0f" % hero.attack)
	add_info_label(content, "Скорость атаки: %.2f" % hero.attack_speed)
	add_info_label(content, "Шанс крита: %.0f%%" % (hero.crit_chance * 100.0))
	add_info_label(content, "Крит. урон: %.0f%%" % (hero.crit_damage * 100.0))
	add_info_label(content, "Сила героя: %.2f" % hero.hero_power)

func create_tick_indicator() -> void:
	var indicator := HBoxContainer.new()
	indicator.position = Vector2(410.0, 335.0)
	indicator.size = Vector2(580.0, 44.0)
	indicator.add_theme_constant_override("separation", 16)
	add_child(indicator)

	time_progress_bar = ProgressBar.new()
	time_progress_bar.custom_minimum_size = Vector2(440.0, 36.0)
	time_progress_bar.max_value = 100.0
	time_progress_bar.show_percentage = false
	indicator.add_child(time_progress_bar)

	tick_counter_label = Label.new()
	tick_counter_label.custom_minimum_size = Vector2(120.0, 36.0)
	tick_counter_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tick_counter_label.add_theme_font_size_override("font_size", 22)
	tick_counter_label.text = "Тик: 0"
	indicator.add_child(tick_counter_label)

func create_narrative_panel() -> void:
	var tabs := TabContainer.new()
	tabs.position = Vector2(410.0, 400.0)
	tabs.size = Vector2(700.0, 250.0)
	add_child(tabs)

	log_text_edit = create_read_only_text_edit()
	log_text_edit.name = "Лог"
	tabs.add_child(log_text_edit)

	var diary_text_edit := create_read_only_text_edit()
	diary_text_edit.name = "Дневник"
	diary_text_edit.placeholder_text = "Пока записей нет."
	diary_text_edit.text = diary.get_text()
	tabs.add_child(diary_text_edit)

func create_read_only_text_edit() -> TextEdit:
	var text_edit := TextEdit.new()
	text_edit.editable = false
	text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	text_edit.add_theme_font_size_override("font_size", 16)
	return text_edit

func add_info_label(container: VBoxContainer, text: String, font_size: int = 16) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	container.add_child(label)
