extends SceneTree

const QUALITY_SUFFIXES := ["", "_uncommon", "_rare"]
const ITEM_FAMILIES := {
	"boar_chestplate": ["Кираса Авангарда Железного Оплота", ""],
	"boar_helmet": ["Шлем Авангарда Железного Оплота", "res://assets/items/boar_set/ironward_vanguard_helmet.png"],
	"boar_gauntlets": ["Рукавицы Авангарда Железного Оплота", "res://assets/items/boar_set/ironward_vanguard_gauntlets.png"],
	"boar_leggings": ["Поножи Авангарда Железного Оплота", "res://assets/items/boar_set/ironward_vanguard_leggings.png"],
	"boar_boots": ["Сапоги Авангарда Железного Оплота", "res://assets/items/boar_set/ironward_vanguard_boots.png"],
	"boar_sword": ["Меч Авангарда Железного Оплота", ""],
	"boar_shield": ["Щит Авангарда Железного Оплота", ""],
}

func _init() -> void:
	for family_name in ITEM_FAMILIES:
		var expected_name: String = ITEM_FAMILIES[family_name][0]
		var expected_icon_path: String = ITEM_FAMILIES[family_name][1]
		for quality in 3:
			var item_path := "res://data/items/%s%s.tres" % [family_name, QUALITY_SUFFIXES[quality]]
			var definition: Resource = load(item_path)
			assert(definition != null, "Every Ironward Vanguard item definition must load.")
			assert(definition.display_name == expected_name, "Every quality must use the localized Ironward Vanguard item name.")
			if not expected_icon_path.is_empty():
				assert(definition.icon_texture != null, "Every supplied armor icon must load.")
				assert(definition.icon_texture.resource_path == expected_icon_path, "Every supplied armor family must use its mapped PNG filename.")
				assert(definition.icon_texture.get_width() == 300 and definition.icon_texture.get_height() == 300, "Supplied armor icons must preserve their original 300x300 dimensions.")
				assert(definition.hero_overlay_texture == null, "New armor icons must remain inventory/equipment icons only.")

	print("PASS: Ironward Vanguard names and four supplied armor icons are wired across all qualities.")
	quit()
