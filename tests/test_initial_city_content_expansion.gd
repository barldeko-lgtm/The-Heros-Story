extends SceneTree

const ALL_CONTENT := [
	{"mob_file": "0022_stray_dog.tres", "mob_id": "stray_dog", "quest_file": "0022_stray_dogs_outskirts.tres", "quest_id": "stray_dogs_outskirts", "target_power": 30.0},
	{"mob_file": "0001_goblin.tres", "mob_id": "goblin", "quest_file": "0001_goblin_road_problem.tres", "quest_id": "goblin_road_problem", "target_power": 35.0},
	{"mob_file": "0004_giant_rat.tres", "mob_id": "giant_rat", "quest_file": "0004_granary_rat_problem.tres", "quest_id": "granary_rat_problem", "target_power": 43.0},
	{"mob_file": "0005_wild_boar.tres", "mob_id": "wild_boar", "quest_file": "0005_boars_in_fields.tres", "quest_id": "boars_in_fields", "target_power": 52.0},
	{"mob_file": "0016_experienced_goblin.tres", "mob_id": "experienced_goblin", "quest_file": "0016_brazen_goblins.tres", "quest_id": "brazen_goblins", "target_power": 61.0},
	{"mob_file": "0002_wolf.tres", "mob_id": "wolf", "quest_file": "0002_wolf_hunt.tres", "quest_id": "wolf_hunt", "target_power": 70.0},
	{"mob_file": "0006_bandit.tres", "mob_id": "bandit", "quest_file": "0006_trade_road_ambush.tres", "quest_id": "trade_road_ambush", "target_power": 80.0},
	{"mob_file": "0017_wounded_troll.tres", "mob_id": "wounded_troll", "quest_file": "0017_wounded_troll_by_road.tres", "quest_id": "wounded_troll_by_road", "target_power": 90.0},
	{"mob_file": "0007_giant_spider.tres", "mob_id": "giant_spider", "quest_file": "0007_old_mill_webs.tres", "quest_id": "old_mill_webs", "target_power": 100.0},
	{"mob_file": "0003_bear.tres", "mob_id": "bear", "quest_file": "0003_bear_hunt.tres", "quest_id": "bear_hunt", "target_power": 120.0},
	{"mob_file": "0018_mature_wolf.tres", "mob_id": "mature_wolf", "quest_file": "0018_hungry_pack_leader.tres", "quest_id": "hungry_pack_leader", "target_power": 142.0},
	{"mob_file": "0008_rabid_elk.tres", "mob_id": "rabid_elk", "quest_file": "0008_fearless_elk.tres", "quest_id": "fearless_elk", "target_power": 166.0},
	{"mob_file": "0009_bandit_veteran.tres", "mob_id": "bandit_veteran", "quest_file": "0009_stone_bridge_band.tres", "quest_id": "stone_bridge_band", "target_power": 192.0},
	{"mob_file": "0010_swamp_crocodile.tres", "mob_id": "swamp_crocodile", "quest_file": "0010_swamp_path_predator.tres", "quest_id": "swamp_path_predator", "target_power": 220.0},
	{"mob_file": "0019_young_troll.tres", "mob_id": "young_troll", "quest_file": "0019_tracks_at_forest_edge.tres", "quest_id": "tracks_at_forest_edge", "target_power": 250.0},
	{"mob_file": "0011_young_ogre.tres", "mob_id": "young_ogre", "quest_file": "0011_hill_ogre.tres", "quest_id": "hill_ogre", "target_power": 275.0},
	{"mob_file": "0013_cave_lizard.tres", "mob_id": "cave_lizard", "quest_file": "0013_limestone_cave_tracks.tres", "quest_id": "limestone_cave_tracks", "target_power": 325.0},
	{"mob_file": "0020_experienced_ogre.tres", "mob_id": "experienced_ogre", "quest_file": "0020_ogre_on_high_road.tres", "quest_id": "ogre_on_high_road", "target_power": 380.0},
	{"mob_file": "0012_forest_troll.tres", "mob_id": "forest_troll", "quest_file": "0012_forest_crossing_troll.tres", "quest_id": "forest_crossing_troll", "target_power": 440.0},
	{"mob_file": "0014_mountain_beast.tres", "mob_id": "mountain_beast", "quest_file": "0014_roar_from_stony_slopes.tres", "quest_id": "roar_from_stony_slopes", "target_power": 505.0},
	{"mob_file": "0015_orc_raider.tres", "mob_id": "orc_raider", "quest_file": "0015_campfires_deep_in_forest.tres", "quest_id": "campfires_deep_in_forest", "target_power": 575.0},
	{"mob_file": "0021_orc_veteran.tres", "mob_id": "orc_veteran", "quest_file": "0021_old_raider.tres", "quest_id": "old_raider", "target_power": 650.0},
]

func _init() -> void:
	var seen_mob_ids := {}
	var seen_quest_ids := {}
	var previous_power: float = -1.0

	var strength_band_counts := {"lower": 0, "middle": 0, "higher": 0}
	for content_index in ALL_CONTENT.size():
		var content = ALL_CONTENT[content_index]
		var mob = load("res://data/mobs/%s" % content["mob_file"])
		var quest = load("res://data/quests/%s" % content["quest_file"])
		assert(mob != null, "Starting City mob resource must exist: %s" % content["mob_file"])
		assert(quest != null, "Starting City quest resource must exist: %s" % content["quest_file"])
		assert(mob.id == content["mob_id"], "Mob ID must match its approved content entry.")
		assert(quest.id == content["quest_id"], "Quest ID must match its approved content entry.")
		assert(not seen_mob_ids.has(mob.id), "Starting City mob IDs must be unique.")
		assert(not seen_quest_ids.has(quest.id), "Starting City quest IDs must be unique.")
		seen_mob_ids[mob.id] = true
		seen_quest_ids[quest.id] = true

		var mob_power: float = mob.get_power()
		assert(absf(mob_power - float(content["target_power"])) <= 1.0, "Mob Power must stay within 1 point of its approved Starting City curve target: %s target=%.2f actual=%.2f" % [mob.id, content["target_power"], mob_power])
		assert(mob_power > previous_power, "Starting City mobs must remain strictly ordered by the approved Power curve: %s" % mob.id)
		previous_power = mob_power

		assert(quest.mob_definition != null and quest.mob_definition.id == mob.id, "Each quest must reference its matching mob.")
		assert(quest.mob_count_min >= 1 and quest.mob_count_max >= quest.mob_count_min, "Quest mob-count range must be valid: %s" % quest.id)
		assert(quest.distance_km_min >= 1 and quest.distance_km_max >= quest.distance_km_min, "Quest distance range must be valid: %s" % quest.id)
		assert(quest.gold_per_mob_min >= 1 and quest.gold_per_mob_max >= quest.gold_per_mob_min, "Quest gold-per-mob range must be valid: %s" % quest.id)
		var expected_strength_band: String = "lower" if content_index < 8 else ("middle" if content_index < 15 else "higher")
		assert(quest.strength_band == expected_strength_band, "Quest strength bands must follow the approved eight-lower / seven-middle / seven-higher mob-Power grouping: %s" % quest.id)
		strength_band_counts[quest.strength_band] += 1

	assert(seen_mob_ids.size() == 22 and seen_quest_ids.size() == 22, "Starting City must keep exactly 22 tuned mob/quest pairs.")
	assert(strength_band_counts == {"lower": 8, "middle": 7, "higher": 7}, "Starting City must keep the explicit 8/7/7 quest strength-band split.")
	print("PASS: All 22 Starting City mobs follow the approved gradually widening 30-to-650 Power curve and all matching quest tuning ranges remain valid.")
	quit()
