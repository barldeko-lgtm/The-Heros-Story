extends SceneTree

const EQUIPPED_ITEMS := {
	"chest": "res://data/items/visual_families/ironward_vanguard/boar_chestplate.tres",
	"helmet": "res://data/items/visual_families/ironward_vanguard/boar_helmet.tres",
	"gloves": "res://data/items/visual_families/ironward_vanguard/boar_gauntlets.tres",
	"pants": "res://data/items/visual_families/ironward_vanguard/boar_leggings.tres",
	"boots": "res://data/items/visual_families/ironward_vanguard/boar_boots.tres",
}
const OVERLAY_NODES := {
	"chest": "HeroChestOverlay",
	"helmet": "HeroHelmetOverlay",
	"gloves": "HeroGlovesOverlay",
	"pants": "HeroPantsOverlay",
	"boots": "HeroBootsOverlay",
}
const DRAW_ORDER := ["pants", "boots", "chest", "gloves", "helmet"]

func _init() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	var main_ui_script: Script = load("res://scripts/ui/main_ui.gd")
	assert(simulation_script != null and main_ui_script != null, "Paper-doll dependencies must load.")

	var simulation = simulation_script.new(1)
	for slot_id in EQUIPPED_ITEMS:
		var definition: Resource = load(EQUIPPED_ITEMS[slot_id])
		assert(definition != null and definition.hero_overlay_texture != null, "Every armor definition must provide an overlay.")
		simulation.receive_item_reward(definition, 1, 20)

	var main_ui = main_ui_script.new()
	main_ui.simulation = simulation
	get_root().add_child(main_ui)
	await process_frame
	main_ui.inventory_button.pressed.emit()
	await process_frame

	var portrait := main_ui.find_child("HeroPortrait", true, false) as TextureRect
	assert(portrait != null and portrait.size.x > 0.0 and portrait.size.y > 0.0, "The displayed hero portrait must have runtime geometry.")
	var previous_draw_index := -1
	for slot_id in DRAW_ORDER:
		var overlay := main_ui.find_child(OVERLAY_NODES[slot_id], true, false) as TextureRect
		var definition = simulation.hero_state.equipment.get_item(slot_id).definition
		assert(overlay != null and overlay.visible, "Every equipped armor overlay must be visible.")
		assert(overlay.texture == definition.hero_overlay_texture, "Every overlay node must use its equipped item texture.")
		assert(overlay.texture.get_width() == 441 and overlay.texture.get_height() == 800, "Every overlay must retain the shared 441x800 canvas.")
		assert(overlay.size == portrait.size, "Every overlay must fill the same runtime rectangle as the base hero portrait.")
		assert(overlay.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Every overlay must use the same centered aspect-preserving stretch mode as the hero portrait.")
		assert(overlay.get_index() > previous_draw_index, "Armor overlays must keep the approved back-to-front draw order.")
		previous_draw_index = overlay.get_index()

	main_ui.free()
	print("PASS: Five Ironward Vanguard armor overlays render on the hero paper doll in stable draw order.")
	quit()
