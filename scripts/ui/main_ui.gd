extends Control

const WorldClockScript = preload("res://scripts/core/world_clock.gd")
const HeroNameRepositoryScript = preload("res://scripts/core/hero_name_repository.gd")
const HeroStateScript = preload("res://scripts/hero/hero_state.gd")

var world_clock = WorldClockScript.new()
var time_progress_bar: ProgressBar
var tick_counter_label: Label

func _ready() -> void:
	create_background()
	create_hero_panel()
	create_tick_indicator()

func _process(delta: float) -> void:
	world_clock.advance_time(delta)
	time_progress_bar.value = world_clock.tick_progress * 100.0
	tick_counter_label.text = "Тик: %d" % world_clock.world_tick

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

func add_info_label(container: VBoxContainer, text: String, font_size: int = 16) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	container.add_child(label)
