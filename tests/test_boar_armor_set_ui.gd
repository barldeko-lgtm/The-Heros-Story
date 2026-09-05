extends SceneTree

const EQUIPPED_ITEMS := {
	"chest": "res://data/items/visual_families/ironward_vanguard/boar_chestplate_rare.tres",
	"helmet": "res://data/items/visual_families/ironward_vanguard/boar_helmet.tres",
	"gloves": "res://data/items/visual_families/ironward_vanguard/boar_gauntlets_uncommon.tres",
	"pants": "res://data/items/visual_families/ironward_vanguard/boar_leggings_rare.tres",
	"boots": "res://data/items/visual_families/ironward_vanguard/boar_boots_uncommon.tres",
}
const ICON_NODES := {
	"chest": "ChestEquipmentIcon",
	"helmet": "HelmetEquipmentIcon",
	"gloves": "GlovesEquipmentIcon",
	"pants": "PantsEquipmentIcon",
	"boots": "BootsEquipmentIcon",
}
const OVERLAY_NODES := {
	"chest": "HeroChestOverlay",
	"helmet": "HeroHelmetOverlay",
	"gloves": "HeroGlovesOverlay",
	"pants": "HeroPantsOverlay",
	"boots": "HeroBootsOverlay",
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
		simulation.receive_item_reward(definition, 1, 10)

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
	assert(tooltip_label.text.contains("Поножи Авангарда Железного Оплота"), "Tooltip must show the correct equipped item name.")
	assert(tooltip_label.text.contains("Качество: Редкое"), "Tooltip must show item quality.")
	assert(tooltip_label.text.contains("Сила предмета: %.2f" % simulation.hero_state.equipment.get_item("pants").get_item_power()), "Tooltip must show the equipped item's universal ItemPower.")

	for slot_id in OVERLAY_NODES:
		var hero_overlay := main_ui.find_child(OVERLAY_NODES[slot_id], true, false) as TextureRect
		var equipped_definition = simulation.hero_state.equipment.get_item(slot_id).definition
		assert(hero_overlay != null and hero_overlay.visible, "Every equipped armor piece must be visible on the hero paper doll.")
		assert(hero_overlay.texture == equipped_definition.hero_overlay_texture, "Every paper-doll layer must use the equipped item's overlay.")

	main_ui.free()
	print("PASS: All five Boar armor slots display icons, quality outlines, and shared tooltips.")
	quit()
