extends SceneTree

const EQUIPPED_ITEMS := {
	"chest": "res://data/items/boar_chestplate_rare.tres",
	"helmet": "res://data/items/boar_helmet.tres",
	"gloves": "res://data/items/boar_gauntlets_uncommon.tres",
	"pants": "res://data/items/boar_leggings_rare.tres",
	"boots": "res://data/items/boar_boots_uncommon.tres",
}
const ICON_NODES := {
	"chest": "ChestEquipmentIcon",
	"helmet": "HelmetEquipmentIcon",
	"gloves": "GlovesEquipmentIcon",
	"pants": "PantsEquipmentIcon",
	"boots": "BootsEquipmentIcon",
}

func _init() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	var main_ui_script: Script = load("res://scripts/ui/main_ui.gd")
	var simulation = simulation_script.new(1)
	for slot_id in EQUIPPED_ITEMS:
		var definition: Resource = load(EQUIPPED_ITEMS[slot_id])
		assert(definition != null, "Every equipped test definition must load.")
		simulation.receive_item_reward(definition, 1)

	var main_ui = main_ui_script.new()
	main_ui.simulation = simulation
	get_root().add_child(main_ui)
	await process_frame
	main_ui.inventory_button.pressed.emit()
	await process_frame

	for slot_id in ICON_NODES:
		var icon := main_ui.find_child(ICON_NODES[slot_id], true, false) as TextureRect
		assert(icon != null and icon.visible and icon.texture != null, "Every equipped Boar armor slot must display its icon.")
		var quality: int = simulation.hero_state.equipment.get_item(slot_id).definition.quality
		if quality == 0:
			assert(icon.material == null, "Common equipped armor must have no outline.")
		else:
			assert(icon.material is ShaderMaterial, "Uncommon and Rare equipped armor must use quality outline.")

	var pants_slot := main_ui.find_child("PantsSlot", true, false) as PanelContainer
	var tooltip_panel := main_ui.find_child("ItemTooltipPanel", true, false) as PanelContainer
	var tooltip_label := main_ui.find_child("ItemTooltipLabel", true, false) as Label
	pants_slot.mouse_entered.emit()
	await process_frame
	assert(tooltip_panel.visible, "Hovering any equipped armor slot must show tooltip.")
	assert(tooltip_label.text.contains("Поножи Вепря"), "Tooltip must show the correct equipped item name.")
	assert(tooltip_label.text.contains("Качество: Редкое"), "Tooltip must show item quality.")
	assert(tooltip_label.text.contains("Сила предмета: 10.18"), "Tooltip must show universal ItemPower.")

	var hero_overlay := main_ui.find_child("HeroChestOverlay", true, false) as TextureRect
	assert(hero_overlay.visible, "Existing chestplate overlay must remain visible.")
	assert(simulation.hero_state.equipment.get_item("helmet").definition.hero_overlay_texture == null, "New armor pieces must remain icon-only.")

	main_ui.free()
	print("PASS: All five Boar armor slots display icons, quality outlines, and shared tooltips.")
	quit()
