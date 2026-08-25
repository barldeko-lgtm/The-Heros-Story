extends SceneTree

const QUALITY_SUFFIXES := ["", "_uncommon", "_rare"]
const SWORD_STATS := [
	[3.0, 0.05, 0.10],
	[4.0, 0.07, 0.15],
	[5.0, 0.10, 0.20],
]
const SHIELD_STATS := [
	[10.0, 20],
	[15.0, 25],
	[20.0, 30],
]
const EXPECTED_ITEM_POWER := {
	"weapon": [0.751913469, 0.941639433, 1.124755364],
	"shield": [1.808545188, 2.373817840, 2.876901451],
}

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
			assert(is_equal_approx(definition.get_item_power(), EXPECTED_ITEM_POWER[slot_id][quality]), "Sword and shield ItemPower must use the shared Power formula.")
			if slot_id == "weapon":
				assert(is_equal_approx(definition.attack_bonus, SWORD_STATS[quality][0]), "Sword Attack must match the approved quality stats.")
				assert(is_equal_approx(definition.crit_chance_bonus, SWORD_STATS[quality][1]), "Sword CritChance must match the approved quality stats.")
				assert(is_equal_approx(definition.crit_damage_bonus, SWORD_STATS[quality][2]), "Sword CritDamage must match the approved quality stats.")
				assert(definition.get_tooltip_text().contains("Атака: +%d" % int(SWORD_STATS[quality][0])), "Sword tooltip must show Attack.")
				assert(definition.get_tooltip_text().contains("Шанс крита: +%d%%" % int(SWORD_STATS[quality][1] * 100.0)), "Sword tooltip must show CritChance.")
				assert(definition.get_tooltip_text().contains("Сила крита: +%d%%" % int(SWORD_STATS[quality][2] * 100.0)), "Sword tooltip must show CritDamage.")
			else:
				assert(is_equal_approx(definition.max_hp_bonus, SHIELD_STATS[quality][0]), "Shield MaxHP must match the approved quality stats.")
				assert(definition.armor_bonus == SHIELD_STATS[quality][1], "Shield Armor must match the approved quality stats.")
			if quality == 2:
				rare_items[slot_id] = definition

	var quest_rewards := {
		"res://data/quests/0007_old_mill_webs.tres": "weapon",
		"res://data/quests/0008_fearless_elk.tres": "shield",
	}
	for quest_path in quest_rewards:
		var quest: Resource = load(quest_path)
		assert(quest.item_reward_pool.size() == 3, "Each assigned quest must expose three equal-quality rewards.")
		for quality in 3:
			assert(quest.item_reward_pool[quality].equipment_slot == quest_rewards[quest_path], "Quest pool must contain its assigned item family.")
			assert(quest.item_reward_pool[quality].quality == quality, "Quest pool must be ordered Common/Uncommon/Rare.")

	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	var simulation = simulation_script.new(1)
	simulation.receive_item_reward(rare_items["weapon"], 1)
	simulation.receive_item_reward(rare_items["shield"], 2)
	assert(is_equal_approx(simulation.base_combat_stats.max_hp, 130.0), "Rare shield must add 20 MaxHP to the starting hero.")
	assert(is_equal_approx(simulation.base_combat_stats.attack, 12.0), "Rare sword must add 5 Attack to the starting hero.")
	assert(is_equal_approx(simulation.base_combat_stats.crit_chance, 0.22), "Rare sword must add 10 percentage points of CritChance.")
	assert(is_equal_approx(simulation.base_combat_stats.crit_damage, 1.76), "Rare sword must add 20 percentage points of CritDamage.")
	assert(is_equal_approx(simulation.base_combat_stats.damage_reduction, 0.15), "Rare shield must add 30 Armor.")

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
	print("PASS: Boar sword and shield qualities, stats, rewards, equipment, and UI work end-to-end.")
	quit()
