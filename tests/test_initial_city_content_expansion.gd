extends SceneTree

const NEW_CONTENT := [
	{"mob_file": "0004_giant_rat.tres", "mob_id": "giant_rat", "quest_file": "0004_granary_rat_problem.tres", "quest_id": "granary_rat_problem", "power_min": 14.0, "power_max": 15.0},
	{"mob_file": "0005_wild_boar.tres", "mob_id": "wild_boar", "quest_file": "0005_boars_in_fields.tres", "quest_id": "boars_in_fields", "power_min": 19.0, "power_max": 20.0},
	{"mob_file": "0006_bandit.tres", "mob_id": "bandit", "quest_file": "0006_trade_road_ambush.tres", "quest_id": "trade_road_ambush", "power_min": 23.0, "power_max": 25.0},
	{"mob_file": "0007_giant_spider.tres", "mob_id": "giant_spider", "quest_file": "0007_old_mill_webs.tres", "quest_id": "old_mill_webs", "power_min": 30.0, "power_max": 32.0},
	{"mob_file": "0008_rabid_elk.tres", "mob_id": "rabid_elk", "quest_file": "0008_fearless_elk.tres", "quest_id": "fearless_elk", "power_min": 39.0, "power_max": 41.0},
	{"mob_file": "0009_bandit_veteran.tres", "mob_id": "bandit_veteran", "quest_file": "0009_stone_bridge_band.tres", "quest_id": "stone_bridge_band", "power_min": 47.0, "power_max": 49.0},
	{"mob_file": "0010_swamp_crocodile.tres", "mob_id": "swamp_crocodile", "quest_file": "0010_swamp_path_predator.tres", "quest_id": "swamp_path_predator", "power_min": 58.0, "power_max": 61.0},
	{"mob_file": "0011_young_ogre.tres", "mob_id": "young_ogre", "quest_file": "0011_hill_ogre.tres", "quest_id": "hill_ogre", "power_min": 69.0, "power_max": 73.0},
	{"mob_file": "0012_forest_troll.tres", "mob_id": "forest_troll", "quest_file": "0012_forest_crossing_troll.tres", "quest_id": "forest_crossing_troll", "power_min": 94.0, "power_max": 98.0},
	{"mob_file": "0013_cave_lizard.tres", "mob_id": "cave_lizard", "quest_file": "0013_limestone_cave_tracks.tres", "quest_id": "limestone_cave_tracks", "power_min": 80.0, "power_max": 84.0},
]

func _init() -> void:
	var goblin = load("res://data/mobs/0001_goblin.tres")
	var bear = load("res://data/mobs/0003_bear.tres")
	assert(goblin != null and bear != null, "Current Goblin and Bear references must exist.")

	var seen_mob_ids := {}
	var seen_quest_ids := {}
	var stronger_than_bear := 0

	for content in NEW_CONTENT:
		var mob = load("res://data/mobs/%s" % content["mob_file"])
		var quest = load("res://data/quests/%s" % content["quest_file"])
		assert(mob != null, "New mob resource must exist: %s" % content["mob_file"])
		assert(quest != null, "New quest resource must exist: %s" % content["quest_file"])
		assert(mob.id == content["mob_id"], "New mob ID must match its approved content entry.")
		assert(quest.id == content["quest_id"], "New quest ID must match its approved content entry.")
		assert(not seen_mob_ids.has(mob.id), "New mob IDs must be unique.")
		assert(not seen_quest_ids.has(quest.id), "New quest IDs must be unique.")
		seen_mob_ids[mob.id] = true
		seen_quest_ids[quest.id] = true

		assert(mob.get_power() > goblin.get_power(), "Every new initial-city mob must be stronger than the Goblin: %s" % mob.id)
		assert(mob.get_power() >= content["power_min"] and mob.get_power() <= content["power_max"], "New mob Power must stay inside its approved progression band: %s" % mob.id)
		if mob.get_power() > bear.get_power():
			stronger_than_bear += 1

		assert(quest.mob_definition != null and quest.mob_definition.id == mob.id, "Each new quest must reference its matching mob.")
		assert(quest.mob_count_min >= 1 and quest.mob_count_max >= quest.mob_count_min, "Quest mob-count range must be valid: %s" % quest.id)
		assert(quest.distance_km_min >= 1 and quest.distance_km_max >= quest.distance_km_min, "Quest distance range must be valid: %s" % quest.id)
		assert(quest.gold_per_mob_min >= 1 and quest.gold_per_mob_max >= quest.gold_per_mob_min, "Quest gold-per-mob range must be valid: %s" % quest.id)

	assert(stronger_than_bear == 6, "Exactly six of the ten new mobs must be stronger than the Bear.")
	print("PASS: Ten initial-city mobs and quests satisfy content, range, and Power tiers.")
	quit()
