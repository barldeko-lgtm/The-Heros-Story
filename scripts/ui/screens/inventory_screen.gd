class_name InventoryScreen
extends Control

const HeroReferenceTexture = preload("res://assets/hero/hero_reference.png")
const ItemQualityOutlineShader = preload("res://assets/shaders/item_quality_outline.gdshader")
const HERO_OVERLAY_DRAW_ORDER: Array[String] = ["pants", "boots", "chest", "gloves", "helmet"]

var simulation
var hero_chest_overlay: TextureRect
var hero_equipment_overlays: Dictionary = {}
var chest_equipment_slot: PanelContainer
var chest_equipment_icon: TextureRect
var item_tooltip_panel: PanelContainer
var item_tooltip_label: Label
var inventory_slot_controls: Array[PanelContainer] = []
var inventory_item_icons: Array[TextureRect] = []
var equipment_slot_controls: Dictionary = {}
var equipment_item_icons: Dictionary = {}
var quality_outline_materials: Dictionary = {}

func setup(simulation_reference) -> void:
	simulation = simulation_reference
	if is_node_ready():
		refresh()

func _ready() -> void:
	create_inventory_equipment_layout()
	refresh()

func refresh() -> void:
	if simulation == null:
		return
	update_inventory_equipment_display()

func create_inventory_equipment_layout() -> void:
	var armor_slots := create_equipment_slot_column("ArmorSlots", [
		"HelmetSlot",
		"ChestSlot",
		"GlovesSlot",
		"PantsSlot",
		"BootsSlot",
	])
	armor_slots.position = Vector2(32.0, 148.0)
	add_child(armor_slots)

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
	add_child(portrait_panel)

	var portrait := TextureRect.new()
	portrait.name = "HeroPortrait"
	portrait.texture = HeroReferenceTexture
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_panel.add_child(portrait)

	for equipment_slot_id in HERO_OVERLAY_DRAW_ORDER:
		var hero_overlay := TextureRect.new()
		hero_overlay.name = get_hero_overlay_node_name(equipment_slot_id)
		hero_overlay.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		hero_overlay.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hero_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hero_overlay.visible = false
		portrait_panel.add_child(hero_overlay)
		hero_equipment_overlays[equipment_slot_id] = hero_overlay
	hero_chest_overlay = hero_equipment_overlays["chest"]

	var weapon_slots := create_equipment_slot_row("WeaponSlots", [
		"WeaponSlot1",
		"WeaponSlot2",
	])
	weapon_slots.position = Vector2(172.4, 620.0)
	add_child(weapon_slots)

	var jewelry_slots := create_equipment_slot_column("JewelrySlots", [
		"NecklaceSlot",
		"EarringsSlot",
		"RingSlot1",
		"RingSlot2",
		"BeltSlot",
	])
	jewelry_slots.position = Vector2(406.4, 148.0)
	add_child(jewelry_slots)

	var inventory_title := Label.new()
	inventory_title.name = "InventoryTitle"
	inventory_title.text = "Инвентарь"
	inventory_title.position = Vector2(680.0, 88.0)
	inventory_title.size = Vector2(532.0, 36.0)
	inventory_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inventory_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	inventory_title.add_theme_font_size_override("font_size", 24)
	inventory_title.add_theme_color_override("font_color", Color("242a31"))
	add_child(inventory_title)

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
	add_child(inventory_slots)
	create_inventory_item_tooltip()

func create_inventory_item_tooltip() -> void:
	item_tooltip_panel = PanelContainer.new()
	item_tooltip_panel.name = "ItemTooltipPanel"
	item_tooltip_panel.custom_minimum_size = Vector2(300.0, 180.0)
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
	add_child(item_tooltip_panel)

	item_tooltip_label = Label.new()
	item_tooltip_label.name = "ItemTooltipLabel"
	item_tooltip_label.custom_minimum_size = Vector2(272.0, 0.0)
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
		column.add_child(create_equipment_slot(slot_name))
	return column

func create_equipment_slot_row(row_name: String, slot_names: Array[String]) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = row_name
	row.size = Vector2(180.0, 86.0)
	row.add_theme_constant_override("separation", 8)
	for slot_name in slot_names:
		row.add_child(create_equipment_slot(slot_name))
	return row

func create_equipment_slot(slot_name: String) -> PanelContainer:
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
	var equipment_slot_id: String = get_equipment_slot_id(slot_name)
	if not equipment_slot_id.is_empty():
		var item_icon := TextureRect.new()
		item_icon.name = get_equipment_icon_node_name(equipment_slot_id)
		item_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		item_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		item_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		item_icon.visible = false
		slot.mouse_entered.connect(show_equipped_item_tooltip.bind(equipment_slot_id))
		slot.mouse_exited.connect(hide_item_tooltip)
		slot.add_child(item_icon)
		equipment_slot_controls[equipment_slot_id] = slot
		equipment_item_icons[equipment_slot_id] = item_icon
		if equipment_slot_id == "chest":
			chest_equipment_slot = slot
			chest_equipment_icon = item_icon
	return slot

func get_equipment_slot_id(slot_node_name: String) -> String:
	match slot_node_name:
		"HelmetSlot": return "helmet"
		"ChestSlot": return "chest"
		"GlovesSlot": return "gloves"
		"PantsSlot": return "pants"
		"BootsSlot": return "boots"
		"WeaponSlot1": return "weapon"
		"WeaponSlot2": return "shield"
		"NecklaceSlot": return "necklace"
		"EarringsSlot": return "earrings"
		"RingSlot1": return "ring_1"
		"RingSlot2": return "ring_2"
		"BeltSlot": return "belt"
	return ""

func get_equipment_icon_node_name(slot_id: String) -> String:
	match slot_id:
		"helmet": return "HelmetEquipmentIcon"
		"chest": return "ChestEquipmentIcon"
		"gloves": return "GlovesEquipmentIcon"
		"pants": return "PantsEquipmentIcon"
		"boots": return "BootsEquipmentIcon"
		"weapon": return "WeaponEquipmentIcon"
		"shield": return "ShieldEquipmentIcon"
		"necklace": return "NecklaceEquipmentIcon"
		"earrings": return "EarringsEquipmentIcon"
		"ring_1": return "Ring1EquipmentIcon"
		"ring_2": return "Ring2EquipmentIcon"
		"belt": return "BeltEquipmentIcon"
	return "EquipmentIcon"

func get_hero_overlay_node_name(slot_id: String) -> String:
	match slot_id:
		"helmet": return "HeroHelmetOverlay"
		"chest": return "HeroChestOverlay"
		"gloves": return "HeroGlovesOverlay"
		"pants": return "HeroPantsOverlay"
		"boots": return "HeroBootsOverlay"
	return "HeroEquipmentOverlay"

func update_inventory_equipment_display() -> void:
	if equipment_item_icons.is_empty() or hero_equipment_overlays.is_empty():
		return
	for equipment_slot_id in equipment_item_icons:
		var equipment_icon: TextureRect = equipment_item_icons[equipment_slot_id]
		var equipped_item = simulation.hero_state.equipment.get_item(equipment_slot_id)
		if equipped_item == null:
			equipment_icon.texture = null
			equipment_icon.material = null
			equipment_icon.visible = false
			continue
		var equipment_definition = equipped_item.definition
		equipment_icon.texture = equipment_definition.icon_texture
		equipment_icon.material = get_quality_outline_material(equipment_definition.quality)
		equipment_icon.visible = true

	for equipment_slot_id in hero_equipment_overlays:
		var hero_overlay: TextureRect = hero_equipment_overlays[equipment_slot_id]
		var equipped_item = simulation.hero_state.equipment.get_item(equipment_slot_id)
		if equipped_item == null or equipped_item.definition.hero_overlay_texture == null:
			hero_overlay.texture = null
			hero_overlay.visible = false
			continue
		hero_overlay.texture = equipped_item.definition.hero_overlay_texture
		hero_overlay.visible = true

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

func show_equipped_item_tooltip(slot_id: String) -> void:
	show_item_tooltip(simulation.hero_state.equipment.get_item(slot_id))

func show_chest_item_tooltip() -> void:
	show_equipped_item_tooltip("chest")

func show_inventory_item_tooltip(slot_index: int) -> void:
	var inventory_items: Array = simulation.hero_state.inventory.get_items()
	if slot_index < 0 or slot_index >= inventory_items.size():
		hide_item_tooltip()
		return
	show_item_tooltip(inventory_items[slot_index])

func show_item_tooltip(item_instance) -> void:
	if item_instance == null or item_tooltip_panel == null:
		return
	item_tooltip_label.text = item_instance.get_tooltip_text()
	var tooltip_size: Vector2 = item_tooltip_panel.get_combined_minimum_size()
	item_tooltip_panel.size = tooltip_size
	var screen_size: Vector2 = get_viewport_rect().size
	var mouse_position: Vector2 = get_local_mouse_position()
	var desired_position: Vector2 = mouse_position + Vector2(16.0, 16.0)
	if desired_position.x + tooltip_size.x > screen_size.x - 12.0:
		desired_position.x = mouse_position.x - tooltip_size.x - 16.0
	if desired_position.y + tooltip_size.y > screen_size.y - 12.0:
		desired_position.y = mouse_position.y - tooltip_size.y - 16.0
	desired_position.x = clampf(desired_position.x, 12.0, screen_size.x - tooltip_size.x - 12.0)
	desired_position.y = clampf(desired_position.y, 76.0, screen_size.y - tooltip_size.y - 12.0)
	item_tooltip_panel.position = desired_position
	item_tooltip_panel.visible = true

func hide_item_tooltip() -> void:
	if item_tooltip_panel != null:
		item_tooltip_panel.visible = false

