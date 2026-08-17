extends Control

const SimulationScript = preload("res://scripts/core/simulation.gd")

var simulation = SimulationScript.new()
var time_progress_bar: ProgressBar
var tick_counter_label: Label
var hero_details_label: Label
var log_text_edit: TextEdit

func _ready() -> void:
	create_background()
	create_hero_panel()
	create_tick_indicator()
	create_narrative_panel()
	simulation.world_clock.tick_completed.connect(on_world_tick_completed)
	update_hero_panel()

func _process(delta: float) -> void:
	simulation.advance_time(delta)
	time_progress_bar.value = simulation.world_clock.tick_progress * 100.0
	tick_counter_label.text = "Тик: %d" % simulation.world_clock.world_tick
	update_hero_panel()

func on_world_tick_completed(_completed_tick: int) -> void:
	log_text_edit.text = simulation.debug_log.get_text()
	log_text_edit.scroll_vertical = log_text_edit.get_line_count()

func create_background() -> void:
	var background := ColorRect.new()
	background.color = Color("1a1c25")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

func create_hero_panel() -> void:
	var panel := PanelContainer.new()
	panel.position = Vector2(32.0, 32.0)
	panel.size = Vector2(320.0, 430.0)
	add_child(panel)

	hero_details_label = Label.new()
	hero_details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hero_details_label.add_theme_font_size_override("font_size", 16)
	panel.add_child(hero_details_label)

func update_hero_panel() -> void:
	var hero = simulation.hero_state
	var stats = simulation.combat_stats
	hero_details_label.text = "%s\nВоин\n\nУровень: %d   XP: %d / %d\nHP: %.0f / %.0f\n\nСила: %d\nЛовкость: %d\nИнтеллект: %d\n\nАтака: %.0f\nСкорость атаки: %.2f\nШанс крита: %.0f%%\nКрит. урон: %.0f%%\nСила героя: %.2f" % [hero.hero_name, hero.level, hero.experience, hero.experience_to_next_level, hero.current_hp, stats.max_hp, hero.strength, hero.agility, hero.intelligence, stats.attack, stats.attack_speed, stats.crit_chance * 100.0, stats.crit_damage * 100.0, simulation.get_hero_power()]

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
	diary_text_edit.text = simulation.diary.get_text()
	tabs.add_child(diary_text_edit)

func create_read_only_text_edit() -> TextEdit:
	var text_edit := TextEdit.new()
	text_edit.editable = false
	text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	text_edit.add_theme_font_size_override("font_size", 16)
	return text_edit
