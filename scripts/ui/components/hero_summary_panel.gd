extends Control

const HeroTraitsScript = preload("res://scripts/hero/hero_traits.gd")
const DamageResolverScript = preload("res://scripts/combat/damage_resolver.gd")
const HERO_TEXT_CONTENT_WIDTH: float = 288.0

var simulation
var hero_details_label: Label
var pending_attribute_indicator: Label

func setup(live_simulation) -> void:
	simulation = live_simulation

func _ready() -> void:
	create_hero_panel()
	create_pending_attribute_indicator()

func create_hero_panel() -> void:
	var panel := PanelContainer.new()
	apply_panel_style(panel)
	panel.position = Vector2(32.0, 80.0)
	panel.size = Vector2(320.0, 430.0)
	add_child(panel)

	hero_details_label = Label.new()
	hero_details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hero_details_label.add_theme_font_size_override("font_size", 14)
	panel.add_child(hero_details_label)

func create_pending_attribute_indicator() -> void:
	pending_attribute_indicator = Label.new()
	pending_attribute_indicator.name = "PendingAttributeIndicator"
	pending_attribute_indicator.text = "+"
	pending_attribute_indicator.tooltip_text = "Есть нераспределённые очки характеристик"
	pending_attribute_indicator.add_theme_font_size_override("font_size", 20)
	pending_attribute_indicator.add_theme_color_override("font_color", Color("ff3030"))
	pending_attribute_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pending_attribute_indicator.visible = false
	add_child(pending_attribute_indicator)

func update_pending_attribute_indicator() -> void:
	if pending_attribute_indicator == null:
		return
	if simulation.hero_state.pending_primary_attribute_points <= 0:
		pending_attribute_indicator.visible = false
		return

	pending_attribute_indicator.visible = true

	var font: Font = hero_details_label.get_theme_font("font")
	var font_size: int = hero_details_label.get_theme_font_size("font_size")
	var line_height: float = font.get_height(font_size)
	var bonus_line_count: int = 0
	var trait_bonus_text: String = HeroTraitsScript.get_conditional_damage_bonus_text(simulation.get_hero_traits())
	if not trait_bonus_text.is_empty():
		bonus_line_count += 1
	if simulation.get_combat_buff_fights_remaining() > 0:
		bonus_line_count += 1
	var level_line_index: int = 3 + bonus_line_count
	var hero_panel := hero_details_label.get_parent() as Control
	pending_attribute_indicator.position = hero_panel.position + Vector2(286.0, 14.0 + line_height * level_line_index - 2.0)

func update_hero_panel() -> void:
	var hero = simulation.hero_state
	var stats = simulation.base_combat_stats
	var effective_strength: int = hero.strength + hero.equipment.get_strength_bonus()
	var armor: int = int(round(stats.armor))
	var physical_reduction_percent := (1.0 - DamageResolverScript.calculate_physical_taken(stats.armor)) * 100.0
	var active_quest_name: String = "—"
	if hero.active_quest != null:
		active_quest_name = hero.active_quest.display_name
	var current_traits: Array[String] = simulation.get_hero_traits()
	var trait_names: String = HeroTraitsScript.get_display_names(current_traits)
	var bonus_lines: PackedStringArray = []
	var trait_bonus_text: String = HeroTraitsScript.get_conditional_damage_bonus_text(current_traits)
	if not trait_bonus_text.is_empty():
		bonus_lines.append("Бонус черты: %s" % trait_bonus_text)
	var buff_fights: int = simulation.get_combat_buff_fights_remaining()
	if buff_fights > 0:
		bonus_lines.append("Божественное благословение: +15%% физ. урона (%d боёв)" % buff_fights)
	var bonuses_text: String = ""
	if not bonus_lines.is_empty():
		bonuses_text = "\n" + "\n".join(bonus_lines)
	var state_display_name: String = get_state_display_name(hero.loop_state)
	var state_spacer: String = get_state_spacer(state_display_name)
	hero_details_label.text = "%s\nВоин\nЧерты: %s%s\nУровень: %d   XP: %d / %d\nHP: %.1f / %.1f\nЗолото: %d\nСостояние: %s%s\nКвест: %s\nСила: %d\nЛовкость: %d\nИнтеллект: %d\nТелосложение: %d\nМудрость: %d\nФиз. урон: %.0f\nТочность: %.0f\nУклонение: %.0f\nБроня: %d (снижение %.1f%%)\nОгонь / Холод / Молния: %.0f / %.0f / %.0f\nБлок: %.0f\nСкорость атаки: %.2f\nШанс крита: %.0f%%\nКрит. урон: %.0f%%\nСила героя: %.2f\nSeed: %d" % [hero.hero_name, trait_names, bonuses_text, hero.level, hero.experience, hero.experience_to_next_level, simulation.get_current_hero_hp(), stats.max_hp, hero.gold, state_display_name, state_spacer, active_quest_name, effective_strength, hero.dexterity, hero.intelligence, hero.constitution, hero.wisdom, stats.attack, stats.accuracy, stats.dodge, armor, physical_reduction_percent, stats.fire_resistance, stats.cold_resistance, stats.lightning_resistance, stats.block, stats.attack_speed, stats.crit_chance * 100.0, stats.crit_damage * 100.0, simulation.get_hero_power(), simulation.simulation_seed]

func get_state_spacer(state_display_name: String) -> String:
	var font: Font = hero_details_label.get_theme_font("font")
	var font_size: int = hero_details_label.get_theme_font_size("font_size")
	var state_line_width: float = font.get_string_size("Состояние: %s" % state_display_name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	return "\n" if state_line_width <= HERO_TEXT_CONTENT_WIDTH else ""

func get_state_display_name(loop_state: String) -> String:
	match loop_state:
		HeroState.VISITING_GUILD: return "Идёт в гильдию"
		HeroState.CHOOSING_QUEST: return "Выбирает квест"
		HeroState.TRAVEL_TO_QUEST: return "Идёт к цели"
		HeroState.DOING_QUEST: return "Выполняет квест"
		HeroState.RECOVERING_AFTER_FIGHT: return "Восстанавливается после боя"
		HeroState.REVIEWING_QUEST_LOOT: return "Разбирает найденную добычу"
		HeroState.RETURNING_TO_CITY: return "Возвращается в город"
		HeroState.TURNING_IN_QUEST: return "Сдаёт квест"
		HeroState.VISITING_MARKET: return "На рынке — продаёт ненужный шмот"
		HeroState.SHOPPING: return "В магазине — выбирает покупку"
		HeroState.TRAVEL_TO_DUNGEON: return "Идёт к данжу"
		HeroState.AT_DUNGEON_ENTRANCE: return "У входа в данж"
		HeroState.DOING_DUNGEON: return "В данже — бой"
		HeroState.DUNGEON_BETWEEN_FIGHTS: return "В данже — готовится к следующему бою"
		HeroState.DUNGEON_COMPLETED: return "Данж пройден"
		HeroState.DUNGEON_RETURNING_TO_CITY: return "Возвращается в город после данжа"
		HeroState.DEAD_RESPAWNING: return "Мёртв — тиков до возрождения: %d" % simulation.get_respawn_ticks_remaining()
		HeroState.RECOVERING_IN_CITY: return "Восстанавливается в городе"
	return loop_state

func apply_panel_style(panel: PanelContainer) -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("232830")
	panel_style.border_color = Color("7b8694")
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(12)
	panel_style.shadow_color = Color(0.0, 0.0, 0.0, 0.30)
	panel_style.shadow_size = 6
	panel_style.shadow_offset = Vector2(0.0, 3.0)
	panel_style.content_margin_left = 16.0
	panel_style.content_margin_right = 16.0
	panel_style.content_margin_top = 14.0
	panel_style.content_margin_bottom = 14.0
	panel.add_theme_stylebox_override("panel", panel_style)
