extends SceneTree

const ALL_CONTENT := [
	{"mob_file": "0001_goblin.tres", "mob_id": "goblin", "quest_file": "0001_goblin_road_problem.tres", "quest_id": "goblin_road_problem", "power_min": 34.5, "power_max": 35.5},
	{"mob_file": "0004_giant_rat.tres", "mob_id": "giant_rat", "quest_file": "0004_granary_rat_problem.tres", "quest_id": "granary_rat_problem", "power_min": 42.0, "power_max": 44.0},
	{"mob_file": "0005_wild_boar.tres", "mob_id": "wild_boar", "quest_file": "0005_boars_in_fields.tres", "quest_id": "boars_in_fields", "power_min": 52.0, "power_max": 54.0},
	{"mob_file": "0002_wolf.tres", "mob_id": "wolf", "quest_file": "0002_wolf_hunt.tres", "quest_id": "wolf_hunt", "power_min": 64.0, "power_max": 66.5},
	{"mob_file": "0006_bandit.tres", "mob_id": "bandit", "quest_file": "0006_trade_road_ambush.tres", "quest_id": "trade_road_ambush", "power_min": 79.0, "power_max": 81.0},
	{"mob_file": "0007_giant_spider.tres", "mob_id": "giant_spider", "quest_file": "0007_old_mill_webs.tres", "quest_id": "old_mill_webs", "power_min": 97.0, "power_max": 99.0},
	{"mob_file": "0003_bear.tres", "mob_id": "bear", "quest_file": "0003_bear_hunt.tres", "quest_id": "bear_hunt", "power_min": 119.0, "power_max": 121.0},
	{"mob_file": "0008_rabid_elk.tres", "mob_id": "rabid_elk", "quest_file": "0008_fearless_elk.tres", "quest_id": "fearless_elk", "power_min": 146.0, "power_max": 148.5},
	{"mob_file": "0009_bandit_veteran.tres", "mob_id": "bandit_veteran", "quest_file": "0009_stone_bridge_band.tres", "quest_id": "stone_bridge_band", "power_min": 179.0, "power_max": 181.5},
	{"mob_file": "0010_swamp_crocodile.tres", "mob_id": "swamp_crocodile", "quest_file": "0010_swamp_path_predator.tres", "quest_id": "swamp_path_predator", "power_min": 218.0, "power_max": 221.0},
	{"mob_file": "0011_young_ogre.tres", "mob_id": "young_ogre", "quest_file": "0011_hill_ogre.tres", "quest_id": "hill_ogre", "power_min": 269.0, "power_max": 272.0},
	{"mob_file": "0013_cave_lizard.tres", "mob_id": "cave_lizard", "quest_file": "0013_limestone_cave_tracks.tres", "quest_id": "limestone_cave_tracks", "power_min": 329.0, "power_max": 332.0},
	{"mob_file": "0012_forest_troll.tres", "mob_id": "forest_troll", "quest_file": "0012_forest_crossing_troll.tres", "quest_id": "forest_crossing_troll", "power_min": 404.0, "power_max": 407.0},
	{"mob_file": "0014_mountain_beast.tres", "mob_id": "mountain_beast", "quest_file": "0014_roar_from_stony_slopes.tres", "quest_id": "roar_from_stony_slopes", "power_min": 493.0, "power_max": 496.0},
	{"mob_file": "0015_orc_raider.tres", "mob_id": "orc_raider", "quest_file": "0015_campfires_deep_in_forest.tres", "quest_id": "campfires_deep_in_forest", "power_min": 599.0, "power_max": 601.0},
]

func _init() -> void:
	var seen_mob_ids := {}
	var seen_quest_ids := {}
	var previous_power: float = -1.0

	for content in ALL_CONTENT:
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
		assert(mob_power >= content["power_min"] and mob_power <= content["power_max"], "Mob Power must stay inside its approved Starting City progression band: %s (%.2f)" % [mob.id, mob_power])
		assert(mob_power > previous_power, "Starting City mobs must remain strictly ordered by the approved Power curve: %s" % mob.id)
		previous_power = mob_power

		assert(quest.mob_definition != null and quest.mob_definition.id == mob.id, "Each quest must reference its matching mob.")
		assert(quest.mob_count_min >= 1 and quest.mob_count_max >= quest.mob_count_min, "Quest mob-count range must be valid: %s" % quest.id)
		assert(quest.distance_km_min >= 1 and quest.distance_km_max >= quest.distance_km_min, "Quest distance range must be valid: %s" % quest.id)
		assert(quest.gold_per_mob_min >= 1 and quest.gold_per_mob_max >= quest.gold_per_mob_min, "Quest gold-per-mob range must be valid: %s" % quest.id)

	assert(seen_mob_ids.size() == 15 and seen_quest_ids.size() == 15, "Starting City must keep exactly 15 tuned mob/quest pairs.")
	print("PASS: All 15 Starting City mobs follow the approved approximately 35-to-600 Power curve and all matching quest tuning ranges remain valid.")
	quit()
