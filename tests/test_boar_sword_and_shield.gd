extends SceneTree

const QUALITY_SUFFIXES := ["", "_uncommon", "_rare"]

func _init() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var rare_items: Dictionary = {}
	for family_data in [
		["weapon", "boar_sword", "Меч Авангарда Железного Оплота"],
		["shield", "boar_shield", "Щит Авангарда Железного Оплота"],
	]:
		var slot_id: String = family_data[0]
		var family_name: String = family_data[1]
		var display_name: String = family_data[2]
		for quality in 3:
			var item_path := "res://data/items/visual_families/ironward_vanguard/%s%s.tres" % [family_name, QUALITY_SUFFIXES[quality]]
			assert(ResourceLoader.exists(item_path), "Every sword/shield quality definition must exist: %s" % item_path)
			var definition: Resource = load(item_path)
			assert(definition != null, "Every sword/shield quality definition must load.")
			assert(definition.display_name == display_name, "Every quality must keep the family display name.")
			assert(definition.equipment_slot == slot_id, "Every definition must use its dedicated equipment slot.")
			assert(definition.quality == quality, "Every definition must match its resource quality.")
			assert(definition.icon_texture != null, "Every sword/shield definition must have an icon.")
			if quality == 2:
				rare_items[slot_id] = definition


	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	var simulation = simulation_script.new(1)
	var starting_hp: float = simulation.base_combat_stats.max_hp
	var starting_attack: float = simulation.base_combat_stats.attack
	var starting_block: float = simulation.base_combat_stats.block
	simulation.receive_item_reward(rare_items["weapon"], 1, 20)
	simulation.receive_item_reward(rare_items["shield"], 2, 20)
	var sword_instance = simulation.hero_state.equipment.get_item("weapon")
	var shield_instance = simulation.hero_state.equipment.get_item("shield")
	assert(sword_instance.item_level == 20 and sword_instance.affixes.size() == 2, "Rare sword must be generated at ilvl 20 with two affixes.")
	assert(shield_instance.item_level == 20 and shield_instance.affixes.size() == 2, "Rare shield must be generated at ilvl 20 with two affixes.")
	assert(sword_instance.get_base_stat("attack") == 17.0 and sword_instance.get_base_stat("attack_speed") == 0.10, "ilvl 20 sword must use its current inherent stats.")
	assert(shield_instance.get_base_stat("block") == 17.0, "ilvl 20 shield must use its current inherent Block.")
	assert(is_equal_approx(simulation.base_combat_stats.max_hp, starting_hp + sword_instance.get_stat_bonus("max_hp") + shield_instance.get_stat_bonus("max_hp")), "Generated Health must resolve from both items.")
	assert(is_equal_approx(simulation.base_combat_stats.attack, starting_attack + sword_instance.get_stat_bonus("attack") + shield_instance.get_stat_bonus("attack")), "Generated sword Damage must resolve through Equipment.")
	assert(is_equal_approx(simulation.base_combat_stats.block, starting_block + sword_instance.get_stat_bonus("block") + shield_instance.get_stat_bonus("block")), "Generated shield Block must resolve through Equipment.")

	var main_ui_script: Script = load("res://scripts/ui/main_ui.gd")
	var main_ui = main_ui_script.new()
	main_ui.simulation = simulation
	get_root().add_child(main_ui)
	await process_frame
	main_ui.inventory_button.pressed.emit()
	await process_frame
	for slot_data in [
		["WeaponSlot1", "WeaponEquipmentIcon", "weapon"],
		["WeaponSlot2", "ShieldEquipmentIcon", "shield"],
	]:
		var slot := main_ui.find_child(slot_data[0], true, false) as PanelContainer
		var icon := main_ui.find_child(slot_data[1], true, false) as TextureRect
		assert(slot != null and icon != null and icon.visible and icon.texture != null, "Sword and shield slots must display equipped icons.")
		assert(icon.material is ShaderMaterial, "Rare sword and shield must use the blue quality outline.")
		assert(simulation.hero_state.equipment.get_item(slot_data[2]) != null, "Each new equipment slot must contain its item.")

	main_ui.free()
	print("PASS: Boar sword and shield generate ilvl 20 instance stats and remain visible in UI.")
	quit()
