extends Control

const HeroTraitsScript = preload("res://scripts/hero/hero_traits.gd")
const DamageResolverScript = preload("res://scripts/combat/damage_resolver.gd")

var simulation
var hero_panel: PanelContainer
var hero_name_label: Label
var subtitle_label: Label
var level_label: Label
var gold_label: Label
var hp_bar: ProgressBar
var xp_bar: ProgressBar
var hp_text: Label
var xp_text: Label
var activity_label: Label
var quest_label: Label
var details_scroll: ScrollContainer
var hero_details_label: RichTextLabel
var pending_attribute_indicator: Label

func setup(live_simulation) -> void:
	simulation = live_simulation

func _ready() -> void:
	create_hero_panel()

func make_label(font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func create_hero_panel() -> void:
	hero_panel = PanelContainer.new()
	apply_panel_style(hero_panel)
	hero_panel.position = Vector2(32, 80)
	hero_panel.size = Vector2(320, 640)
	add_child(hero_panel)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 6)
	hero_panel.add_child(layout)
	hero_name_label = make_label(22, Color("edf0f4"))
	hero_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(hero_name_label)
	subtitle_label = make_label(13, Color("aeb8c6"))
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(subtitle_label)
	var level_row := HBoxContainer.new()
	level_row.add_theme_constant_override("separation", 6)
	layout.add_child(level_row)
	level_label = make_label(14, Color("edf0f4"))
	level_row.add_child(level_label)
	pending_attribute_indicator = make_label(20, Color("ff3030"))
	pending_attribute_indicator.name = "PendingAttributeIndicator"
	pending_attribute_indicator.text = "+"
	pending_attribute_indicator.tooltip_text = "Есть нераспределённые очки характеристик"
	pending_attribute_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pending_attribute_indicator.hide()
	level_row.add_child(pending_attribute_indicator)
	gold_label = make_label(14, Color("d9bd7d"))
	gold_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	level_row.add_child(gold_label)
	hp_bar = create_resource_bar(layout, Color("a64e59"))
	hp_text = add_bar_text(hp_bar)
	xp_bar = create_resource_bar(layout, Color("577fa3"))
	xp_text = add_bar_text(xp_bar)
	activity_label = make_label(14, Color("d9bd7d"))
	activity_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(activity_label)
	quest_label = make_label(13, Color("c1cad5"))
	quest_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(quest_label)
	details_scroll = ScrollContainer.new()
	details_scroll.name = "HeroDetailsScroll"
	details_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	details_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(details_scroll)
	hero_details_label = RichTextLabel.new()
	hero_details_label.name = "HeroDetails"
	hero_details_label.bbcode_enabled = true
	hero_details_label.fit_content = true
	hero_details_label.scroll_active = false
	hero_details_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hero_details_label.add_theme_font_size_override("normal_font_size", 13)
	hero_details_label.add_theme_constant_override("table_h_separation", 6)
	hero_details_label.add_theme_constant_override("table_v_separation", 0)
	details_scroll.add_child(hero_details_label)

func create_resource_bar(parent: Control, fill: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size.y = 20.0
	bar.show_percentage = false
	var track := StyleBoxFlat.new()
	track.bg_color = Color("161b22")
	track.set_corner_radius_all(4)
	var filled := StyleBoxFlat.new()
	filled.bg_color = fill
	filled.set_corner_radius_all(4)
	bar.add_theme_stylebox_override("background", track)
	bar.add_theme_stylebox_override("fill", filled)
	parent.add_child(bar)
	return bar

func add_bar_text(bar: ProgressBar) -> Label:
	var label := make_label(12, Color("f3f5f7"))
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_color_override("font_outline_color", Color("161b22"))
	label.add_theme_constant_override("outline_size", 2)
	bar.add_child(label)
	return label

func update_pending_attribute_indicator() -> void:
	if pending_attribute_indicator != null:
		pending_attribute_indicator.visible = simulation.hero_state.pending_primary_attribute_points > 0

func detail_row(caption: String, value: String) -> String:
	return "[cell expand=1][color=#9eabbc]%s:[/color][/cell][cell][color=#edf0f4]%s[/color][/cell]" % [caption, value]

func section_title(caption: String) -> String:
	return "[color=#8192a8][font_size=12]%s[/font_size][/color]\n" % caption

func update_hero_panel() -> void:
	var hero = simulation.hero_state
	var stats = simulation.base_combat_stats
	hero_name_label.text = hero.hero_name
	subtitle_label.text = "Воин · Черты: %s" % HeroTraitsScript.get_display_names(simulation.get_hero_traits())
	level_label.text = "Уровень %d" % hero.level
	gold_label.text = "Золото: %d" % hero.gold
	hp_bar.max_value = stats.max_hp
	hp_bar.value = simulation.get_current_hero_hp()
	hp_text.text = "HP: %.1f / %.1f" % [simulation.get_current_hero_hp(), stats.max_hp]
	xp_bar.max_value = hero.experience_to_next_level
	xp_bar.value = hero.experience
	xp_text.text = "XP: %d / %d" % [hero.experience, hero.experience_to_next_level]
	activity_label.text = get_state_display_name(hero.loop_state)
	quest_label.text = "Квест: %s" % (hero.active_quest.display_name if hero.active_quest != null else "—")
	var text := section_title("ХАРАКТЕРИСТИКИ") + "[table=2]"
	for entry in [["Сила", hero.strength + hero.equipment.get_strength_bonus()], ["Ловкость", hero.dexterity], ["Интеллект", hero.intelligence], ["Телосложение", hero.constitution], ["Мудрость", hero.wisdom]]:
		text += detail_row(entry[0], str(entry[1]))
	text += "[/table]\n" + section_title("БОЕВЫЕ ПОКАЗАТЕЛИ") + "[table=2]"
	var armor := int(round(stats.armor))
	var reduction: float = (1.0 - DamageResolverScript.calculate_physical_taken(stats.armor)) * 100.0
	for entry in [["Физ. урон", "%.0f" % stats.attack], ["Точность", "%.0f" % stats.accuracy], ["Уклонение", "%.0f" % stats.dodge], ["Броня", "%d (−%.1f%%)" % [armor, reduction]], ["Блок", "%.0f" % stats.block], ["Скорость атаки", "%.2f" % stats.attack_speed], ["Шанс крита", "%.0f%%" % (stats.crit_chance * 100.0)], ["Крит. урон", "%.0f%%" % (stats.crit_damage * 100.0)], ["Сила героя", "%.2f" % simulation.get_hero_power()]]:
		text += detail_row(entry[0], entry[1])
	text += "[/table]\n" + section_title("СОПРОТИВЛЕНИЯ")
	text += "[color=#9eabbc]Огонь / Холод / Молния:[/color] [color=#edf0f4]%.0f%% / %.0f%% / %.0f%%[/color]\n" % [stats.fire_resistance, stats.cold_resistance, stats.lightning_resistance]
	var trait_bonus: String = HeroTraitsScript.get_conditional_damage_bonus_text(simulation.get_hero_traits())
	if not trait_bonus.is_empty():
		text += "\n[color=#d9bd7d]Бонус черты: %s[/color]\n" % trait_bonus
	var buff_fights: int = simulation.get_combat_buff_fights_remaining()
	if buff_fights > 0:
		text += "\n[color=#d9bd7d]Божественное благословение: +15%% физ. урона (%d боёв)[/color]\n" % buff_fights
	text += "\n[color=#8192a8]Seed: %d[/color]" % simulation.simulation_seed
	if hero_details_label.text != text:
		hero_details_label.text = text
	update_pending_attribute_indicator()

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
		HeroState.TRAVEL_TO_CITY: return "Переезжает в другой город"
		HeroState.ARRIVED_IN_CITY: return "В новом городе"
		HeroState.DEAD_RESPAWNING: return "Мёртв — тиков до возрождения: %d" % simulation.get_respawn_ticks_remaining()
		HeroState.RECOVERING_IN_CITY: return "Восстанавливается в городе"
	return loop_state

func apply_panel_style(panel: PanelContainer) -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("232830")
	panel_style.border_color = Color("495462")
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(12)
	panel_style.shadow_color = Color(0.0, 0.0, 0.0, 0.15)
	panel_style.shadow_size = 2
	panel_style.shadow_offset = Vector2(0.0, 1.0)
	panel_style.content_margin_left = 16.0
	panel_style.content_margin_right = 16.0
	panel_style.content_margin_top = 14.0
	panel_style.content_margin_bottom = 14.0
	panel.add_theme_stylebox_override("panel", panel_style)
