extends Control

const SimulationScript = preload("res://scripts/core/simulation.gd")
const HeroTraitsScript = preload("res://scripts/hero/hero_traits.gd")
const GodStateScript = preload("res://scripts/god/god_state.gd")
var simulation_seed: int = int(Time.get_unix_time_from_system())
var simulation = SimulationScript.new(simulation_seed, null)
var time_progress_bar: ProgressBar
var tick_counter_label: Label
var hero_details_label: Label
var opponent_details_label: Label
var combat_statistics_label: Label
var log_text_edit: TextEdit
var speed_buttons: Dictionary = {}
var god_panel: PanelContainer
var god_energy_bar: ProgressBar
var god_energy_label: Label
var god_status_label: Label
var divine_healing_button: Button
var combat_buff_button: Button
var instant_resurrection_button: Button

func _ready() -> void:
	create_background()
	create_speed_controls()
	create_hero_panel()
	create_opponent_panel()
	create_combat_statistics_panel()
	create_god_panel()
	create_tick_indicator()
	create_narrative_panel()
	simulation.world_clock.tick_completed.connect(on_world_tick_completed)
	simulation.debug_log.text_changed.connect(on_debug_log_text_changed)
	update_hero_panel()
	update_opponent_panel()
	update_combat_statistics_panel()
	update_god_panel()

func _process(delta: float) -> void:
	simulation.advance_time(delta)
	time_progress_bar.value = simulation.world_clock.tick_progress * 100.0
	tick_counter_label.text = "Тик: %d" % simulation.world_clock.world_tick
	update_hero_panel()
	update_opponent_panel()
	update_combat_statistics_panel()
	update_god_panel()

func on_world_tick_completed(_completed_tick: int) -> void:
	update_debug_log(simulation.debug_log.get_text())

func on_debug_log_text_changed(log_text: String) -> void:
	update_debug_log(log_text)

func update_debug_log(log_text: String) -> void:
	log_text_edit.text = log_text
	log_text_edit.scroll_vertical = log_text_edit.get_line_count()

func create_background() -> void:
	var background := ColorRect.new()
	background.color = Color("1a1c25")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

func create_speed_controls() -> void:
	var speed_controls := HBoxContainer.new()
	speed_controls.position = Vector2(820.0, 24.0)
	speed_controls.size = Vector2(430.0, 38.0)
	speed_controls.add_theme_constant_override("separation", 6)
	add_child(speed_controls)

	for speed in [0, 1, 2, 5, 10, 20, 100]:
		var button := Button.new()
		button.text = "×%d" % speed
		button.toggle_mode = true
		button.button_pressed = speed == 1
		button.pressed.connect(set_time_scale.bind(float(speed)))
		speed_controls.add_child(button)
		speed_buttons[float(speed)] = button

func set_time_scale(new_time_scale: float) -> void:
	simulation.set_time_scale(new_time_scale)
	for speed in speed_buttons:
		speed_buttons[speed].button_pressed = is_equal_approx(speed, new_time_scale)

func create_hero_panel() -> void:
	var panel := PanelContainer.new()
	panel.position = Vector2(32.0, 80.0)
	panel.size = Vector2(320.0, 430.0)
	add_child(panel)

	hero_details_label = Label.new()
	hero_details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hero_details_label.add_theme_font_size_override("font_size", 16)
	panel.add_child(hero_details_label)

func create_opponent_panel() -> void:
	var panel := PanelContainer.new()
	panel.position = Vector2(928.0, 80.0)
	panel.size = Vector2(320.0, 430.0)
	add_child(panel)

	opponent_details_label = Label.new()
	opponent_details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	opponent_details_label.add_theme_font_size_override("font_size", 16)
	panel.add_child(opponent_details_label)

func update_opponent_panel() -> void:
	if simulation.active_combat_session == null:
		opponent_details_label.text = "Противник\n\nСейчас боя нет."
		return

	var stats = simulation.get_current_opponent_stats()
	opponent_details_label.text = "%s\n\nHP: %.1f / %.1f\n\nАтака: %.1f\nСкорость атаки: %.2f\nШанс крита: %.0f%%\nКрит. урон: %.0f%%\nСила противника: %.2f" % [
		simulation.get_current_opponent_name(),
		simulation.get_current_opponent_hp(),
		stats.max_hp,
		stats.attack,
		stats.attack_speed,
		stats.crit_chance * 100.0,
		stats.crit_damage * 100.0,
		simulation.get_current_opponent_power()
	]

func create_combat_statistics_panel() -> void:
	var panel := PanelContainer.new()
	panel.position = Vector2(928.0, 530.0)
	panel.size = Vector2(320.0, 120.0)
	add_child(panel)

	combat_statistics_label = Label.new()
	combat_statistics_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	combat_statistics_label.add_theme_font_size_override("font_size", 15)
	panel.add_child(combat_statistics_label)

func update_combat_statistics_panel() -> void:
	var stats: Dictionary = simulation.get_current_combat_results()
	if stats.is_empty():
		combat_statistics_label.text = "Статистика боёв\n\nПока боёв нет."
		return

	var total: int = stats["total"]
	var wins: int = stats["wins"]
	var losses: int = stats["losses"]
	var win_rate: float = 100.0 * float(wins) / float(total)
	combat_statistics_label.text = "Статистика боёв — %s\nБои: %d\nПобеды: %d\nПоражения: %d\nWinrate: %.1f%%" % [
		stats["display_name"],
		total,
		wins,
		losses,
		win_rate,
	]

func update_hero_panel() -> void:
	var hero = simulation.hero_state
	var stats = simulation.combat_stats
	var active_quest_name: String = "—"
	if hero.active_quest != null:
		active_quest_name = hero.active_quest.display_name
	var trait_names: String = HeroTraitsScript.get_display_names(hero.traits)
	hero_details_label.text = "%s\nВоин\nЧерты: %s\n\nУровень: %d   XP: %d / %d\nHP: %.1f / %.1f\nЗолото: %d\nСостояние: %s\nКвест: %s\n\nСила: %d\nЛовкость: %d\nИнтеллект: %d\n\nАтака: %.0f\nСкорость атаки: %.2f\nШанс крита: %.0f%%\nКрит. урон: %.0f%%\nСила героя: %.2f\nSeed: %d" % [hero.hero_name, trait_names, hero.level, hero.experience, hero.experience_to_next_level, simulation.get_current_hero_hp(), stats.max_hp, hero.gold, get_state_display_name(hero.loop_state), active_quest_name, hero.strength, hero.agility, hero.intelligence, stats.attack, stats.attack_speed, stats.crit_chance * 100.0, stats.crit_damage * 100.0, simulation.get_hero_power(), simulation.simulation_seed]

func get_state_display_name(loop_state: String) -> String:
	match loop_state:
		HeroState.CHOOSING_QUEST: return "Выбирает квест"
		HeroState.TRAVEL_TO_QUEST: return "Идёт к цели"
		HeroState.DOING_QUEST: return "Выполняет квест"
		HeroState.RECOVERING_AFTER_FIGHT: return "Восстанавливается после боя"
		HeroState.RETURNING_TO_CITY: return "Возвращается в город"
		HeroState.TURNING_IN_QUEST: return "Сдаёт квест"
		HeroState.DEAD_RESPAWNING: return "Мёртв — тиков до возрождения: %d" % simulation.quest_runner.respawn_ticks_remaining
		HeroState.RECOVERING_IN_CITY: return "Восстанавливается в городе"
	return loop_state

func create_god_panel() -> void:
	god_panel = PanelContainer.new()
	god_panel.name = "GodPanel"
	god_panel.position = Vector2(380.0, 80.0)
	god_panel.size = Vector2(520.0, 235.0)
	add_child(god_panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 7)
	god_panel.add_child(content)

	var title := Label.new()
	title.text = "Влияние божества"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	content.add_child(title)

	god_energy_label = Label.new()
	god_energy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(god_energy_label)

	god_energy_bar = ProgressBar.new()
	god_energy_bar.name = "GodEnergyBar"
	god_energy_bar.max_value = GodStateScript.MAX_ENERGY
	god_energy_bar.show_percentage = false
	god_energy_bar.custom_minimum_size = Vector2(480.0, 28.0)
	content.add_child(god_energy_bar)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 6)
	content.add_child(buttons)

	divine_healing_button = Button.new()
	divine_healing_button.name = "DivineHealingButton"
	divine_healing_button.custom_minimum_size = Vector2(160.0, 58.0)
	divine_healing_button.pressed.connect(on_divine_healing_pressed)
	buttons.add_child(divine_healing_button)

	combat_buff_button = Button.new()
	combat_buff_button.name = "CombatBuffButton"
	combat_buff_button.custom_minimum_size = Vector2(160.0, 58.0)
	combat_buff_button.pressed.connect(on_combat_buff_pressed)
	buttons.add_child(combat_buff_button)

	instant_resurrection_button = Button.new()
	instant_resurrection_button.name = "InstantResurrectionButton"
	instant_resurrection_button.custom_minimum_size = Vector2(160.0, 58.0)
	instant_resurrection_button.pressed.connect(on_instant_resurrection_pressed)
	buttons.add_child(instant_resurrection_button)

	god_status_label = Label.new()
	god_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	god_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(god_status_label)

func update_god_panel() -> void:
	if god_panel == null:
		return
	var god = simulation.god_state
	god_energy_bar.value = god.energy
	god_energy_label.text = "Энергия: %.1f / %.0f" % [god.energy, GodStateScript.MAX_ENERGY]

	var hero_is_dead: bool = simulation.hero_state.loop_state == HeroState.DEAD_RESPAWNING
	var hero_is_full_hp: bool = simulation.get_current_hero_hp() >= simulation.combat_stats.max_hp
	divine_healing_button.disabled = hero_is_dead or hero_is_full_hp or god.healing_cooldown_ticks > 0 or god.energy < GodStateScript.HEALING_COST
	divine_healing_button.text = "Лечение\n10 энергии"
	if god.healing_cooldown_ticks > 0:
		divine_healing_button.text = "Лечение\nКД: %d" % god.healing_cooldown_ticks

	combat_buff_button.disabled = god.combat_buff_fights_remaining > 0 or god.combat_buff_cooldown_ticks > 0 or god.energy < GodStateScript.COMBAT_BUFF_COST
	combat_buff_button.text = "Благословение\n10 энергии"
	if god.combat_buff_fights_remaining > 0:
		combat_buff_button.text = "Благословение\nБоёв: %d" % god.combat_buff_fights_remaining
	elif god.combat_buff_cooldown_ticks > 0:
		combat_buff_button.text = "Благословение\nКД: %d" % god.combat_buff_cooldown_ticks

	var resurrection_cost: float = god.get_resurrection_cost(simulation.quest_runner.respawn_ticks_remaining)
	instant_resurrection_button.disabled = not hero_is_dead or simulation.quest_runner.respawn_ticks_remaining <= 0 or god.energy < resurrection_cost
	instant_resurrection_button.text = "Воскрешение\n%.1f энергии" % resurrection_cost

	if god.combat_buff_fights_remaining > 0:
		god_status_label.text = "Активно: +3 атаки, осталось боёв: %d" % god.combat_buff_fights_remaining
	else:
		god_status_label.text = "Лечение разрешено и во время боя."

func on_divine_healing_pressed() -> void:
	simulation.use_divine_healing()
	update_hero_panel()
	update_god_panel()

func on_combat_buff_pressed() -> void:
	simulation.use_combat_buff()
	update_god_panel()

func on_instant_resurrection_pressed() -> void:
	simulation.use_instant_resurrection()
	update_hero_panel()
	update_god_panel()

func create_tick_indicator() -> void:
	var indicator := HBoxContainer.new()
	indicator.position = Vector2(380.0, 335.0)
	indicator.size = Vector2(520.0, 44.0)
	indicator.add_theme_constant_override("separation", 16)
	add_child(indicator)

	time_progress_bar = ProgressBar.new()
	time_progress_bar.custom_minimum_size = Vector2(390.0, 36.0)
	time_progress_bar.max_value = 100.0
	time_progress_bar.show_percentage = false
	indicator.add_child(time_progress_bar)

	tick_counter_label = Label.new()
	tick_counter_label.custom_minimum_size = Vector2(110.0, 36.0)
	tick_counter_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tick_counter_label.add_theme_font_size_override("font_size", 22)
	tick_counter_label.text = "Тик: 0"
	indicator.add_child(tick_counter_label)

func create_narrative_panel() -> void:
	var tabs := TabContainer.new()
	tabs.position = Vector2(380.0, 400.0)
	tabs.size = Vector2(520.0, 250.0)
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
