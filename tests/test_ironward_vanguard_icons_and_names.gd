extends SceneTree

const QUALITY_SUFFIXES := ["", "_uncommon", "_rare"]
const ITEM_FAMILIES := {
	"boar_chestplate": ["Кираса Авангарда Железного Оплота", "", "res://assets/items/overlays/ironward_vanguard/boar_chestplate_overlay.png"],
	"boar_helmet": ["Шлем Авангарда Железного Оплота", "res://assets/items/icons/ironward_vanguard/ironward_vanguard_helmet.png", "res://assets/items/overlays/ironward_vanguard/ironward_vanguard_helmet_overlay.png"],
	"boar_gauntlets": ["Рукавицы Авангарда Железного Оплота", "res://assets/items/icons/ironward_vanguard/ironward_vanguard_gauntlets.png", "res://assets/items/overlays/ironward_vanguard/ironward_vanguard_gloves_overlay.png"],
	"boar_leggings": ["Поножи Авангарда Железного Оплота", "res://assets/items/icons/ironward_vanguard/ironward_vanguard_leggings.png", "res://assets/items/overlays/ironward_vanguard/ironward_vanguard_pants_overlay.png"],
	"boar_boots": ["Сапоги Авангарда Железного Оплота", "res://assets/items/icons/ironward_vanguard/ironward_vanguard_boots.png", "res://assets/items/overlays/ironward_vanguard/ironward_vanguard_boots_overlay.png"],
	"boar_sword": ["Меч Авангарда Железного Оплота", "", ""],
	"boar_shield": ["Щит Авангарда Железного Оплота", "", ""],
}

func _init() -> void:
	for family_name in ITEM_FAMILIES:
		var expected_name: String = ITEM_FAMILIES[family_name][0]
		var expected_icon_path: String = ITEM_FAMILIES[family_name][1]
		var expected_overlay_path: String = ITEM_FAMILIES[family_name][2]
		for quality in 3:
			var item_path := "res://data/items/visual_families/ironward_vanguard/%s%s.tres" % [family_name, QUALITY_SUFFIXES[quality]]
			var definition: Resource = load(item_path)
			assert(definition != null, "Every Ironward Vanguard item definition must load.")
			assert(definition.display_name == expected_name, "Every quality must use the localized Ironward Vanguard item name.")
			if not expected_icon_path.is_empty():
				assert(definition.icon_texture != null, "Every supplied armor icon must load.")
				assert(definition.icon_texture.resource_path == expected_icon_path, "Every supplied armor family must use its mapped PNG filename.")
				assert(definition.icon_texture.get_width() == 300 and definition.icon_texture.get_height() == 300, "Supplied armor icons must preserve their original 300x300 dimensions.")
			if not expected_overlay_path.is_empty():
				assert(definition.hero_overlay_texture != null, "Every visible armor family must provide a hero overlay.")
				assert(definition.hero_overlay_texture.resource_path == expected_overlay_path, "Every visible armor family must use its mapped overlay filename.")
				assert(definition.hero_overlay_texture.get_width() == 441 and definition.hero_overlay_texture.get_height() == 800, "Every hero overlay must preserve its original 441x800 canvas.")

	print("PASS: Ironward Vanguard names, icons, and paper-doll overlays are wired across all qualities.")
	quit()
