extends Control

const SimulationScript = preload("res://scripts/core/simulation.gd")
const HeroTraitsScript = preload("res://scripts/hero/hero_traits.gd")
const GodStateScript = preload("res://scripts/god/god_state.gd")
const HeroReferenceTexture = preload("res://assets/ui/hero/hero_reference.png")
const ItemQualityOutlineShader = preload("res://assets/shaders/item_quality_outline.gdshader")
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
var main_screen: Control
var inventory_screen: Control
var inventory_button: Button
var inventory_close_button: Button
var hero_chest_overlay: TextureRect
var chest_equipment_slot: PanelContainer
var chest_equipment_icon: TextureRect
var item_tooltip_panel: PanelContainer
var item_tooltip_label: Label
var inventory_slot_controls: Array[PanelContainer] = []
var inventory_item_icons: Array[TextureRect] = []
var quality_outline_materials: Dictionary = {}

func _ready() -> void:
	create_background()
	create_screen_layers()
	create_inventory_equipment_layout()
	create_top_menu()
	create_inventory_close_button()
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
	update_inventory_equipment_display()

func _process(delta: float) -> void:
	simulation.advance_time(delta)
	time_progress_bar.value = simulation.world_clock.tick_progress * 100.0
	tick_counter_label.text = "Тик: %d" % simulation.world_clock.world_tick
	update_hero_panel()
	update_opponent_panel()
	update_combat_statistics_panel()
	update_god_panel()
	update_inventory_equipment_display()

func on_world_tick_completed(_completed_tick: int) -> void:
	update_debug_log(simulation.debug_log.get_text())

func on_debug_log_text_changed(log_text: String) -> void:
	update_debug_log(log_text)

func update_debug_log(log_text: String) -> void:
	log_text_edit.text = log_text
	call_deferred("scroll_debug_log_to_bottom")

func scroll_debug_log_to_bottom() -> void:
	if log_text_edit == null or not is_inside_tree():
		return
	await get_tree().process_frame
	if not is_instance_valid(log_text_edit):
		return
	var scroll_bar: VScrollBar = log_text_edit.get_v_scroll_bar()
	scroll_bar.value = scroll_bar.max_value

func create_background() -> void:
	var background := ColorRect.new()
	background.color = Color("d9dde2")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

func create_screen_layers() -> void:
	main_screen = Control.new()
	main_screen.name = "MainScreen"
	main_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(main_screen)

	inventory_screen = Control.new()
	inventory_screen.name = "InventoryScreen"
	inventory_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inventory_screen.visible = false
	add_child(inventory_screen)

func add_to_main_screen(control: Control) -> void:
	if main_screen != null:
		main_screen.add_child(control)
	else:
		add_child(control)

func create_inventory_equipment_layout() -> void:
	var armor_slots := create_equipment_slot_column("ArmorSlots", [
		"HelmetSlot",
		"ChestSlot",
		"GlovesSlot",
		"PantsSlot",
		"BootsSlot",
	])
	armor_slots.position = Vector2(32.0, 148.0)
	inventory_screen.add_child(armor_slots)

	var portrait_panel := PanelContainer.new()
	portrait_panel.name = "HeroPortraitPanel"
	portrait_panel.position = Vector2(134.4, 148.0)
	portrait_panel.size = Vector2(256.0, 464.0)
	var portrait_panel_style := StyleBoxFlat.new()
	portrait_panel_style.bg_color = Color("171b21")
	portrait_panel_style.border_color = Color("7b8694")
	portrait_panel_style.set_border_width_all(2)
	portrait_panel_style.set_corner_radius_all(12)
	portrait_panel_style.shadow_color = Color(0.0, 0.0, 0.0, 0.30)
	portrait_panel_style.shadow_size = 6
	portrait_panel_style.shadow_offset = Vector2(0.0, 3.0)
	portrait_panel.add_theme_stylebox_override("panel", portrait_panel_style)
	inventory_screen.add_child(portrait_panel)

	var portrait := TextureRect.new()
	portrait.name = "HeroPortrait"
	portrait.texture = HeroReferenceTexture
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_panel.add_child(portrait)

	hero_chest_overlay = TextureRect.new()
	hero_chest_overlay.name = "HeroChestOverlay"
	hero_chest_overlay.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hero_chest_overlay.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hero_chest_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero_chest_overlay.visible = false
	portrait_panel.add_child(hero_chest_overlay)

	var weapon_and_jewelry_slots := create_equipment_slot_column("WeaponAndJewelrySlots", [
		"WeaponSlot1",
		"WeaponSlot2",
		"RingSlot1",
		"RingSlot2",
		"NecklaceSlot",
	])
	weapon_and_jewelry_slots.position = Vector2(406.4, 148.0)
	inventory_screen.add_child(weapon_and_jewelry_slots)

	var inventory_title := Label.new()
	inventory_title.name = "InventoryTitle"
	inventory_title.text = "Инвентарь"
	inventory_title.position = Vector2(680.0, 88.0)
	inventory_title.size = Vector2(532.0, 36.0)
	inventory_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inventory_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	inventory_title.add_theme_font_size_override("font_size", 24)
	inventory_title.add_theme_color_override("font_color", Color("242a31"))
	inventory_screen.add_child(inventory_title)

	var inventory_slots := GridContainer.new()
	inventory_slots.name = "InventorySlots"
	inventory_slots.columns = 6
	inventory_slots.position = Vector2(680.0, 138.0)
	inventory_slots.size = Vector2(532.0, 532.0)
	inventory_slots.add_theme_constant_override("h_separation", 8)
	inventory_slots.add_theme_constant_override("v_separation", 8)
	for slot_index in 36:
		var slot := PanelContainer.new()
		slot.name = "InventorySlot%02d" % (slot_index + 1)
		slot.custom_minimum_size = Vector2(82.0, 82.0)
		var slot_style := StyleBoxFlat.new()
		slot_style.bg_color = Color("252b34")
		slot_style.border_color = Color("8994a2")
		slot_style.set_border_width_all(2)
		slot_style.set_corner_radius_all(9)
		slot_style.shadow_color = Color(0.0, 0.0, 0.0, 0.22)
		slot_style.shadow_size = 3
		slot_style.shadow_offset = Vector2(0.0, 2.0)
		slot.add_theme_stylebox_override("panel", slot_style)
		slot.mouse_entered.connect(show_inventory_item_tooltip.bind(slot_index))
		slot.mouse_exited.connect(hide_item_tooltip)
		var item_icon := TextureRect.new()
		item_icon.name = "InventoryItemIcon%02d" % (slot_index + 1)
		item_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		item_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		item_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		item_icon.visible = false
		slot.add_child(item_icon)
		inventory_slots.add_child(slot)
		inventory_slot_controls.append(slot)
		inventory_item_icons.append(item_icon)
	inventory_screen.add_child(inventory_slots)
	create_inventory_item_tooltip()

func create_inventory_item_tooltip() -> void:
	item_tooltip_panel = PanelContainer.new()
	item_tooltip_panel.name = "ItemTooltipPanel"
	item_tooltip_panel.custom_minimum_size = Vector2(280.0, 120.0)
	item_tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	item_tooltip_panel.z_index = 100
	var tooltip_style := StyleBoxFlat.new()
	tooltip_style.bg_color = Color("171b21")
	tooltip_style.border_color = Color("aeb8c7")
	tooltip_style.set_border_width_all(2)
	tooltip_style.set_corner_radius_all(9)
	tooltip_style.shadow_color = Color(0.0, 0.0, 0.0, 0.4)
	tooltip_style.shadow_size = 5
	tooltip_style.shadow_offset = Vector2(0.0, 3.0)
	tooltip_style.content_margin_left = 14.0
	tooltip_style.content_margin_right = 14.0
	tooltip_style.content_margin_top = 12.0
	tooltip_style.content_margin_bottom = 12.0
	item_tooltip_panel.add_theme_stylebox_override("panel", tooltip_style)
	inventory_screen.add_child(item_tooltip_panel)

	item_tooltip_label = Label.new()
	item_tooltip_label.name = "ItemTooltipLabel"
	item_tooltip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item_tooltip_label.add_theme_font_size_override("font_size", 16)
	item_tooltip_label.add_theme_color_override("font_color", Color("edf0f4"))
	item_tooltip_panel.add_child(item_tooltip_label)
	item_tooltip_panel.visible = false

func create_equipment_slot_column(column_name: String, slot_names: Array[String]) -> VBoxContainer:
	var column := VBoxContainer.new()
	column.name = column_name
	column.size = Vector2(86.0, 464.0)
	column.add_theme_constant_override("separation", 8)
	for slot_name in slot_names:
		var slot := PanelContainer.new()
		slot.name = slot_name
		slot.custom_minimum_size = Vector2(86.0, 86.0)
		var slot_style := StyleBoxFlat.new()
		slot_style.bg_color = Color("252b34")
		slot_style.border_color = Color("8994a2")
		slot_style.set_border_width_all(2)
		slot_style.set_corner_radius_all(10)
		slot_style.shadow_color = Color(0.0, 0.0, 0.0, 0.25)
		slot_style.shadow_size = 3
		slot_style.shadow_offset = Vector2(0.0, 2.0)
		slot.add_theme_stylebox_override("panel", slot_style)
		if slot_name == "ChestSlot":
			chest_equipment_slot = slot
			chest_equipment_slot.mouse_entered.connect(show_chest_item_tooltip)
			chest_equipment_slot.mouse_exited.connect(hide_item_tooltip)
			chest_equipment_icon = TextureRect.new()
			chest_equipment_icon.name = "ChestEquipmentIcon"
			chest_equipment_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			chest_equipment_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			chest_equipment_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			chest_equipment_icon.visible = false
			slot.add_child(chest_equipment_icon)
		column.add_child(slot)
	return column

func update_inventory_equipment_display() -> void:
	if chest_equipment_slot == null or chest_equipment_icon == null or hero_chest_overlay == null:
		return
	var equipped_chest = simulation.hero_state.equipment.get_item("chest")
	if equipped_chest == null:
		chest_equipment_icon.texture = null
		chest_equipment_icon.material = null
		chest_equipment_icon.visible = false
		hide_item_tooltip()
		hero_chest_overlay.texture = null
		hero_chest_overlay.visible = false
	else:
		var item_definition = equipped_chest.definition
		chest_equipment_icon.texture = item_definition.icon_texture
		chest_equipment_icon.material = get_quality_outline_material(item_definition.quality)
		chest_equipment_icon.visible = true
		hero_chest_overlay.texture = item_definition.hero_overlay_texture
		hero_chest_overlay.visible = true

	var inventory_items: Array = simulation.hero_state.inventory.get_items()
	for slot_index in inventory_item_icons.size():
		var item_icon: TextureRect = inventory_item_icons[slot_index]
		if slot_index >= inventory_items.size():
			item_icon.texture = null
			item_icon.material = null
			item_icon.visible = false
			continue
		var inventory_definition = inventory_items[slot_index].definition
		item_icon.texture = inventory_definition.icon_texture
		item_icon.material = get_quality_outline_material(inventory_definition.quality)
		item_icon.visible = true

func get_quality_outline_material(quality: int):
	if quality <= 0:
		return null
	if quality_outline_materials.has(quality):
		return quality_outline_materials[quality]
	var material := ShaderMaterial.new()
	material.shader = ItemQualityOutlineShader
	material.set_shader_parameter("outline_color", Color("55c96f") if quality == 1 else Color("4f8dff"))
	material.set_shader_parameter("source_pixels_per_screen_pixel", 3.6)
	material.set_shader_parameter("middle_alpha", 0.55)
	material.set_shader_parameter("outer_alpha", 0.25)
	quality_outline_materials[quality] = material
	return material

func show_chest_item_tooltip() -> void:
	var equipped_chest = simulation.hero_state.equipment.get_item("chest")
	show_item_tooltip(equipped_chest)

func show_inventory_item_tooltip(slot_index: int) -> void:
	var inventory_items: Array = simulation.hero_state.inventory.get_items()
	if slot_index < 0 or slot_index >= inventory_items.size():
		hide_item_tooltip()
		return
	show_item_tooltip(inventory_items[slot_index])

func show_item_tooltip(item_instance) -> void:
	if item_instance == null or item_tooltip_panel == null:
		return
	item_tooltip_label.text = item_instance.definition.get_tooltip_text()
	var desired_position: Vector2 = inventory_screen.get_local_mouse_position() + Vector2(16.0, 16.0)
	desired_position.x = clampf(desired_position.x, 12.0, 988.0)
	desired_position.y = clampf(desired_position.y, 76.0, 570.0)
	item_tooltip_panel.position = desired_position
	item_tooltip_panel.visible = true

func hide_item_tooltip() -> void:
	if item_tooltip_panel != null:
		item_tooltip_panel.visible = false

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

func create_menu_button_style(background_color: Color, border_color: Color, shadow_size: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background_color
	style.border_color = border_color
	style.set_border_width_all(2)
	style.set_corner_radius_all(9)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.35)
	style.shadow_size = shadow_size
	style.shadow_offset = Vector2(0.0, 2.0)
	style.content_margin_left = 14.0
	style.content_margin_right = 14.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	return style

func apply_secondary_button_style(button: Button) -> void:
	button.add_theme_color_override("font_color", Color("edf0f4"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", Color("858b94"))
	button.add_theme_stylebox_override("normal", create_menu_button_style(Color("303844"), Color("707d8e"), 2))
	button.add_theme_stylebox_override("hover", create_menu_button_style(Color("414c5b"), Color("b3bdca"), 3))
	button.add_theme_stylebox_override("pressed", create_menu_button_style(Color("20262e"), Color("d5dbe3"), 1))
	button.add_theme_stylebox_override("focus", create_menu_button_style(Color("414c5b"), Color("d5dbe3"), 2))
	button.add_theme_stylebox_override("disabled", create_menu_button_style(Color("292e35"), Color("4d5560"), 0))

func apply_progress_bar_style(progress_bar: ProgressBar, fill_color: Color) -> void:
	var background_style := StyleBoxFlat.new()
	background_style.bg_color = Color("15191f")
	background_style.border_color = Color("687382")
	background_style.set_border_width_all(2)
	background_style.set_corner_radius_all(8)
	progress_bar.add_theme_stylebox_override("background", background_style)

	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = fill_color
	fill_style.border_color = Color("d5dbe3")
	fill_style.set_border_width_all(1)
	fill_style.set_corner_radius_all(7)
	progress_bar.add_theme_stylebox_override("fill", fill_style)

func create_top_menu() -> void:
	var top_menu := HBoxContainer.new()
	top_menu.name = "TopMenu"
	top_menu.position = Vector2(328.0, 20.0)
	top_menu.add_theme_constant_override("separation", 8)
	add_child(top_menu)

	for button_text in ["ГЕРОЙ", "ИНВЕНТАРЬ", "КАРТА", "МЕНЮ"]:
		var button := Button.new()
		button.text = button_text
		button.tooltip_text = "Раздел пока не реализован"
		button.custom_minimum_size = Vector2(150.0, 42.0)
		button.add_theme_font_size_override("font_size", 18)
		button.add_theme_color_override("font_color", Color("f4f4f4"))
		button.add_theme_color_override("font_hover_color", Color.WHITE)
		button.add_theme_color_override("font_pressed_color", Color.WHITE)
		button.add_theme_stylebox_override("normal", create_menu_button_style(Color("303744"), Color("697586"), 3))
		button.add_theme_stylebox_override("hover", create_menu_button_style(Color("414b5c"), Color("aeb8c7"), 4))
		button.add_theme_stylebox_override("pressed", create_menu_button_style(Color("202630"), Color("d8dee8"), 1))
		button.add_theme_stylebox_override("focus", create_menu_button_style(Color("414b5c"), Color("d8dee8"), 3))
		top_menu.add_child(button)
		if button_text == "ИНВЕНТАРЬ":
			inventory_button = button
			inventory_button.tooltip_text = "Открыть инвентарь"
			inventory_button.pressed.connect(on_inventory_button_pressed)

func create_inventory_close_button() -> void:
	inventory_close_button = Button.new()
	inventory_close_button.name = "InventoryCloseButton"
	inventory_close_button.text = "✕"
	inventory_close_button.position = Vector2(1212.0, 20.0)
	inventory_close_button.size = Vector2(44.0, 44.0)
	inventory_close_button.tooltip_text = "Вернуться на главный экран"
	inventory_close_button.add_theme_font_size_override("font_size", 22)
	inventory_close_button.add_theme_color_override("font_color", Color.WHITE)
	inventory_close_button.add_theme_color_override("font_hover_color", Color.WHITE)
	inventory_close_button.add_theme_color_override("font_pressed_color", Color.WHITE)
	inventory_close_button.add_theme_stylebox_override("normal", create_menu_button_style(Color("842e36"), Color("c76870"), 3))
	inventory_close_button.add_theme_stylebox_override("hover", create_menu_button_style(Color("a83b45"), Color("f0a1a7"), 4))
	inventory_close_button.add_theme_stylebox_override("pressed", create_menu_button_style(Color("612128"), Color("ffd1d4"), 1))
	inventory_close_button.add_theme_stylebox_override("focus", create_menu_button_style(Color("a83b45"), Color("ffd1d4"), 3))
	inventory_close_button.pressed.connect(close_inventory_screen)
	inventory_close_button.visible = false
	add_child(inventory_close_button)

func on_inventory_button_pressed() -> void:
	set_inventory_screen_open(not inventory_screen.visible)

func close_inventory_screen() -> void:
	set_inventory_screen_open(false)

func set_inventory_screen_open(is_open: bool) -> void:
	main_screen.visible = not is_open
	inventory_screen.visible = is_open
	inventory_button.text = "НАЗАД" if is_open else "ИНВЕНТАРЬ"
	inventory_button.tooltip_text = "Вернуться на главный экран" if is_open else "Открыть инвентарь"
	inventory_close_button.visible = is_open

func create_speed_controls() -> void:
	var speed_controls := HBoxContainer.new()
	speed_controls.name = "SpeedControls"
	speed_controls.position = Vector2(818.0, 666.0)
	speed_controls.size = Vector2(430.0, 38.0)
	speed_controls.add_theme_constant_override("separation", 6)
	add_to_main_screen(speed_controls)

	for speed in [0, 1, 2, 5, 10, 20, 100]:
		var button := Button.new()
		button.text = "×%d" % speed
		button.toggle_mode = true
		button.button_pressed = speed == 1
		button.custom_minimum_size = Vector2(52.0, 38.0)
		button.add_theme_font_size_override("font_size", 15)
		apply_secondary_button_style(button)
		button.pressed.connect(set_time_scale.bind(float(speed)))
		speed_controls.add_child(button)
		speed_buttons[float(speed)] = button

func set_time_scale(new_time_scale: float) -> void:
	simulation.set_time_scale(new_time_scale)
	for speed in speed_buttons:
		speed_buttons[speed].button_pressed = is_equal_approx(speed, new_time_scale)

func create_hero_panel() -> void:
	var panel := PanelContainer.new()
	apply_panel_style(panel)
	panel.position = Vector2(32.0, 80.0)
	panel.size = Vector2(320.0, 430.0)
	add_to_main_screen(panel)

	hero_details_label = Label.new()
	hero_details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hero_details_label.add_theme_font_size_override("font_size", 16)
	panel.add_child(hero_details_label)

func create_opponent_panel() -> void:
	var panel := PanelContainer.new()
	apply_panel_style(panel)
	panel.position = Vector2(928.0, 80.0)
	panel.size = Vector2(320.0, 430.0)
	add_to_main_screen(panel)

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
	apply_panel_style(panel)
	panel.position = Vector2(928.0, 530.0)
	panel.size = Vector2(320.0, 120.0)
	add_to_main_screen(panel)

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
	var stats = simulation.base_combat_stats
	var effective_strength: int = hero.strength + hero.equipment.get_strength_bonus()
	var armor: int = hero.equipment.get_armor_bonus()
	var active_quest_name: String = "—"
	if hero.active_quest != null:
		active_quest_name = hero.active_quest.display_name
	var trait_names: String = HeroTraitsScript.get_display_names(hero.traits)
	var bonus_lines: PackedStringArray = []
	var trait_bonus_text: String = HeroTraitsScript.get_conditional_damage_bonus_text(hero.traits)
	if not trait_bonus_text.is_empty():
		bonus_lines.append("Бонус черты: %s" % trait_bonus_text)
	var buff_fights: int = simulation.get_combat_buff_fights_remaining()
	if buff_fights > 0:
		bonus_lines.append("Божественное благословение: +3 Attack (%d боёв)" % buff_fights)
	var bonuses_text: String = ""
	if not bonus_lines.is_empty():
		bonuses_text = "\n" + "\n".join(bonus_lines)
	hero_details_label.text = "%s\nВоин\nЧерты: %s%s\n\nУровень: %d   XP: %d / %d\nHP: %.1f / %.1f\nЗолото: %d\nСостояние: %s\nКвест: %s\n\nСила: %d\nЛовкость: %d\nИнтеллект: %d\n\nАтака: %.0f\nБроня: %d (снижение %.0f%%)\nСкорость атаки: %.2f\nШанс крита: %.0f%%\nКрит. урон: %.0f%%\nСила героя: %.2f\nSeed: %d" % [hero.hero_name, trait_names, bonuses_text, hero.level, hero.experience, hero.experience_to_next_level, simulation.get_current_hero_hp(), stats.max_hp, hero.gold, get_state_display_name(hero.loop_state), active_quest_name, effective_strength, hero.agility, hero.intelligence, stats.attack, armor, stats.damage_reduction * 100.0, stats.attack_speed, stats.crit_chance * 100.0, stats.crit_damage * 100.0, simulation.get_hero_power(), simulation.simulation_seed]

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
	apply_panel_style(god_panel)
	god_panel.name = "GodPanel"
	god_panel.position = Vector2(380.0, 80.0)
	god_panel.size = Vector2(520.0, 235.0)
	add_to_main_screen(god_panel)

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
	apply_progress_bar_style(god_energy_bar, Color("8fa8c1"))
	content.add_child(god_energy_bar)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 6)
	content.add_child(buttons)

	divine_healing_button = Button.new()
	divine_healing_button.name = "DivineHealingButton"
	divine_healing_button.custom_minimum_size = Vector2(156.0, 58.0)
	apply_secondary_button_style(divine_healing_button)
	divine_healing_button.pressed.connect(on_divine_healing_pressed)
	buttons.add_child(divine_healing_button)

	combat_buff_button = Button.new()
	combat_buff_button.name = "CombatBuffButton"
	combat_buff_button.custom_minimum_size = Vector2(156.0, 58.0)
	apply_secondary_button_style(combat_buff_button)
	combat_buff_button.pressed.connect(on_combat_buff_pressed)
	buttons.add_child(combat_buff_button)

	instant_resurrection_button = Button.new()
	instant_resurrection_button.name = "InstantResurrectionButton"
	instant_resurrection_button.custom_minimum_size = Vector2(156.0, 58.0)
	apply_secondary_button_style(instant_resurrection_button)
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

	var combat_buff_fights_remaining: int = simulation.get_combat_buff_fights_remaining()
	combat_buff_button.disabled = combat_buff_fights_remaining > 0 or god.combat_buff_cooldown_ticks > 0 or god.energy < GodStateScript.COMBAT_BUFF_COST
	combat_buff_button.text = "Благословение\n10 энергии"
	if combat_buff_fights_remaining > 0:
		combat_buff_button.text = "Благословение\nБоёв: %d | КД: %d" % [combat_buff_fights_remaining, god.combat_buff_cooldown_ticks]
	elif god.combat_buff_cooldown_ticks > 0:
		combat_buff_button.text = "Благословение\nКД: %d" % god.combat_buff_cooldown_ticks

	var resurrection_cost: float = god.get_resurrection_cost(simulation.quest_runner.respawn_ticks_remaining)
	instant_resurrection_button.disabled = not hero_is_dead or simulation.quest_runner.respawn_ticks_remaining <= 0 or god.energy < resurrection_cost
	instant_resurrection_button.text = "Воскрешение\n%.1f энергии" % resurrection_cost

	if combat_buff_fights_remaining > 0:
		god_status_label.text = "Активно: +3 атаки | Боёв: %d | КД: %d" % [combat_buff_fights_remaining, god.combat_buff_cooldown_ticks]
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
	add_to_main_screen(indicator)

	time_progress_bar = ProgressBar.new()
	time_progress_bar.custom_minimum_size = Vector2(390.0, 36.0)
	time_progress_bar.max_value = 100.0
	time_progress_bar.show_percentage = false
	apply_progress_bar_style(time_progress_bar, Color("9ca9b8"))
	indicator.add_child(time_progress_bar)

	tick_counter_label = Label.new()
	tick_counter_label.custom_minimum_size = Vector2(110.0, 36.0)
	tick_counter_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tick_counter_label.add_theme_font_size_override("font_size", 22)
	tick_counter_label.add_theme_color_override("font_color", Color("242a31"))
	tick_counter_label.text = "Тик: 0"
	indicator.add_child(tick_counter_label)

func create_narrative_panel() -> void:
	var tabs := TabContainer.new()
	tabs.position = Vector2(380.0, 400.0)
	tabs.size = Vector2(520.0, 250.0)
	var tabs_panel_style := StyleBoxFlat.new()
	tabs_panel_style.bg_color = Color("232830")
	tabs_panel_style.border_color = Color("7b8694")
	tabs_panel_style.set_border_width_all(2)
	tabs_panel_style.set_corner_radius_all(10)
	tabs.add_theme_stylebox_override("panel", tabs_panel_style)
	var tab_bar := tabs.get_tab_bar()
	tab_bar.add_theme_font_size_override("font_size", 16)
	tab_bar.add_theme_color_override("font_selected_color", Color.WHITE)
	tab_bar.add_theme_color_override("font_unselected_color", Color("aeb5bf"))
	tab_bar.add_theme_stylebox_override("tab_selected", create_menu_button_style(Color("3d4653"), Color("bdc6d1"), 1))
	tab_bar.add_theme_stylebox_override("tab_unselected", create_menu_button_style(Color("272d35"), Color("626d7b"), 0))
	tab_bar.add_theme_stylebox_override("tab_hovered", create_menu_button_style(Color("343d49"), Color("929dab"), 1))
	add_to_main_screen(tabs)

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
	text_edit.add_theme_color_override("font_readonly_color", Color("e1e5ea"))
	var text_style := StyleBoxFlat.new()
	text_style.bg_color = Color("171b21")
	text_style.border_color = Color("586371")
	text_style.set_border_width_all(1)
	text_style.set_corner_radius_all(8)
	text_style.content_margin_left = 10.0
	text_style.content_margin_right = 10.0
	text_style.content_margin_top = 8.0
	text_style.content_margin_bottom = 8.0
	text_edit.add_theme_stylebox_override("read_only", text_style)
	return text_edit
