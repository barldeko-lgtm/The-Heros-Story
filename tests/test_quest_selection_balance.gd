extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const HeroTraitsScript = preload("res://scripts/hero/hero_traits.gd")

const HERO_POWERS: Array[float] = [100.0, 150.0, 200.0, 250.0, 300.0, 350.0, 450.0, 550.0, 650.0]
const PROFILES := {
	"standard": [],
	"brave": [HeroTraitsScript.BRAVE],
	"cautious": [HeroTraitsScript.COWARD],
	"greedy": [HeroTraitsScript.GREEDY],
}

func _init() -> void:
	check_content_tuning()
	check_filter_coverage()
	check_live_selection_matrix()
	print("PASS: Starting City quest tuning keeps Stone Bridge Band restrained, adds stronger-quest count variety, and advances selection through the Power curve.")
	quit()

func check_content_tuning() -> void:
	var stone_bridge = load("res://data/quests/0009_stone_bridge_band.tres")
	var crocodile = load("res://data/quests/0010_swamp_path_predator.tres")
	var troll = load("res://data/quests/0012_forest_crossing_troll.tres")
	var lizard = load("res://data/quests/0013_limestone_cave_tracks.tres")
	var beast = load("res://data/quests/0014_roar_from_stony_slopes.tres")
	var orc = load("res://data/quests/0015_campfires_deep_in_forest.tres")
	assert(stone_bridge.gold_per_mob_min == 24 and stone_bridge.gold_per_mob_max == 28, "Stone Bridge Band must keep the approved 24-28 Gold-per-mob nerf.")
	assert(crocodile.mob_count_min == 1 and crocodile.mob_count_max == 3, "Swamp predator must support 1-3 enemies for stronger-quest variety.")
	assert(troll.mob_count_min == 1 and troll.mob_count_max == 3, "Forest troll quest must support 1-3 enemies for stronger-quest variety.")
	assert(lizard.mob_count_min == 1 and lizard.mob_count_max == 3, "Cave lizard quest must support 1-3 enemies for stronger-quest variety.")
	assert(beast.mob_count_min == 1 and beast.mob_count_max == 3, "Mountain beast quest must support 1-3 enemies for stronger-quest variety.")
	assert(orc.mob_count_min == 1 and orc.mob_count_max == 3, "Orc raider quest must support 1-3 enemies for stronger-quest variety.")

func check_filter_coverage() -> void:
	var simulation = SimulationScript.new(9199, null)
	var offers: Array = simulation.quest_pool.get_available_quests()
	for profile_name in ["standard", "brave", "cautious"]:
		var traits: Array[String] = []
		traits.assign(PROFILES[profile_name])
		for hero_power_int in range(45, 701):
			var result: Dictionary = simulation.quest_evaluator.select_quest(offers, float(hero_power_int), traits)
			assert(result.get("selected_quest") != null, "Current Starting City Power curve must not create a no-quest dead zone: profile=%s HeroPower=%d." % [profile_name, hero_power_int])

func check_live_selection_matrix() -> void:
	var histograms: Dictionary = {}
	var distinct_by_profile: Dictionary = {}
	for seed in range(9100, 9120):
		var simulation = SimulationScript.new(seed, null)
		var offers: Array = simulation.quest_pool.get_available_quests()
		for profile_name in PROFILES.keys():
			var traits: Array[String] = []
			traits.assign(PROFILES[profile_name])
			if not distinct_by_profile.has(profile_name):
				distinct_by_profile[profile_name] = {}
			for hero_power in HERO_POWERS:
				var result: Dictionary = simulation.quest_evaluator.select_quest(offers, hero_power, traits)
				var selected = result.get("selected_quest")
				assert(selected != null, "Every tested HeroPower/profile point must retain at least one valid Starting City quest: %s %.0f." % [profile_name, hero_power])
				distinct_by_profile[profile_name][selected.id] = true
				var key: String = "%s:%d" % [profile_name, int(hero_power)]
				if not histograms.has(key):
					histograms[key] = {}
				histograms[key][selected.id] = int(histograms[key].get(selected.id, 0)) + 1
				if hero_power >= 400.0:
					assert(selected.id != "stone_bridge_band", "Stone Bridge Band must be outgrown by every current risk profile by HeroPower 400.")

	for profile_name in PROFILES.keys():
		assert(distinct_by_profile[profile_name].size() >= 4, "Quest progression must move through several different winners across the tested Power curve: %s." % profile_name)

	for key in histograms.keys():
		if key in ["standard:200", "standard:300", "standard:450", "standard:550", "standard:650"]:
			print("BALANCE %s -> %s" % [key, str(histograms[key])])
