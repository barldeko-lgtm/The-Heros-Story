extends SceneTree

const MOB_CONTENT := [
	{"file": "0101_ogre_veteran.tres", "id": "ogre_veteran", "power": 300.0},
	{"file": "0102_hardened_orc_raider.tres", "id": "hardened_orc_raider", "power": 314.0},
	{"file": "0103_mature_forest_troll.tres", "id": "mature_forest_troll", "power": 329.0},
	{"file": "0104_veteran_bandit.tres", "id": "veteran_bandit", "power": 345.0},
	{"file": "0105_old_mountain_beast.tres", "id": "old_mountain_beast", "power": 361.0},
	{"file": "0106_warg_pack_leader.tres", "id": "warg_pack_leader", "power": 378.0},
	{"file": "0107_orc_berserker.tres", "id": "orc_berserker", "power": 396.0},
	{"file": "0108_hardened_mercenary.tres", "id": "hardened_mercenary", "power": 415.0},
	{"file": "0109_stone_troll.tres", "id": "stone_troll", "power": 435.0},
	{"file": "0110_fire_salamander.tres", "id": "fire_salamander", "power": 456.0, "damage_type": "fire", "attack": 143.6},
	{"file": "0111_storm_shaman.tres", "id": "storm_shaman", "power": 478.0, "damage_type": "lightning", "attack": 165.6},
	{"file": "0112_cave_ogre.tres", "id": "cave_ogre", "power": 500.0},
	{"file": "0113_road_bandit_chief.tres", "id": "road_bandit_chief", "power": 523.0},
	{"file": "0114_ice_monitor_lizard.tres", "id": "ice_monitor_lizard", "power": 547.0, "damage_type": "cold", "attack": 142.8},
	{"file": "0115_orc_guard.tres", "id": "orc_guard", "power": 572.0},
	{"file": "0116_battle_mage_mercenary.tres", "id": "battle_mage_mercenary", "power": 598.0, "damage_type": "fire", "attack": 172.0},
	{"file": "0117_stone_golem.tres", "id": "stone_golem", "power": 624.0},
	{"file": "0118_orc_shaman.tres", "id": "orc_shaman", "power": 651.0, "damage_type": "lightning", "attack": 210.8},
	{"file": "0119_fire_elemental.tres", "id": "fire_elemental", "power": 679.0, "damage_type": "fire", "attack": 210.0},
	{"file": "0120_storm_lizard.tres", "id": "storm_lizard", "power": 708.0, "damage_type": "lightning", "attack": 188.8},
	{"file": "0121_troll_veteran.tres", "id": "troll_veteran", "power": 738.0},
	{"file": "0122_black_knight.tres", "id": "black_knight", "power": 769.0},
	{"file": "0123_ice_elemental.tres", "id": "ice_elemental", "power": 801.0, "damage_type": "cold", "attack": 216.8},
	{"file": "0124_orc_warlord.tres", "id": "orc_warlord", "power": 833.0},
	{"file": "0125_ogre_destroyer.tres", "id": "ogre_destroyer", "power": 866.0},
	{"file": "0126_stone_colossus.tres", "id": "stone_colossus", "power": 900.0},
]

func _init() -> void:
	var seen_ids := {}
	var seen_profiles := {}
	var previous_physical_power: float = -1.0

	for index in MOB_CONTENT.size():
		var content: Dictionary = MOB_CONTENT[index]
		var mob = load("res://data/mobs/mid_region/%s" % content["file"])
		assert(mob != null, "Arden mob resource must exist: %s" % content["file"])
		assert(mob.id == content["id"], "Arden mob id must match its numbered resource.")
		assert(not seen_ids.has(mob.id), "Arden mob ids must be unique: %s" % mob.id)
		seen_ids[mob.id] = true

		var profile := "%s|%s|%s|%s|%s|%s|%s|%s" % [mob.max_hp, mob.attack, mob.attack_speed, mob.accuracy, mob.dodge, mob.armor, mob.block, mob.crit_chance]
		assert(not seen_profiles.has(profile), "Every Arden mob must have a distinct combat-stat profile: %s" % mob.id)
		seen_profiles[profile] = true

		var mob_power: float = mob.get_power()
		var expected_damage_type: String = str(content.get("damage_type", "physical"))
		assert(mob.attack_damage_type == expected_damage_type, "Arden mob must use its approved ordinary-attack damage type: %s" % mob.id)
		if expected_damage_type == "physical":
			assert(absf(mob_power - float(content["power"])) <= 1.0, "Physical Arden mob Power must stay within 1 point of its approved baseline curve: %s target=%.2f actual=%.2f" % [mob.id, content["power"], mob_power])
			assert(mob_power > previous_physical_power, "Physical Arden baseline Power points must remain ascending: %s" % mob.id)
			previous_physical_power = mob_power
		else:
			assert(is_equal_approx(mob.attack, float(content["attack"])), "Elemental Arden mobs must use the approved temporary 20 percent lower raw attack: %s" % mob.id)
			var physical_baseline_power: float = load("res://scripts/combat/power_calculator.gd").new().calculate(mob.get_combat_stats())
			assert(absf(mob_power - physical_baseline_power * sqrt(1.20)) <= 0.01, "Elemental Arden mob Power must value its offense 20 percent higher inside the shared formula: %s" % mob.id)

		if index < 5:
			assert(mob.equipment_drop_table != null and mob.equipment_drop_table.item_level == 10, "The five transition mobs must keep ilvl 10 equipment drops: %s" % mob.id)

	assert(seen_ids.size() == 26 and seen_profiles.size() == 26, "Arden must contain exactly 26 distinct approved ordinary mob profiles.")
	print("PASS: Arden keeps its physical baseline curve while elemental mobs use 20 percent lower raw attack and 20 percent higher offense weighting in Power.")
	quit()
