extends SceneTree

const HexMapScript = preload("res://scripts/world/hex_map.gd")
const WorldStateScript = preload("res://scripts/world/world_state.gd")
const QuestPoolScript = preload("res://scripts/quests/quest_pool.gd")
const ActivityPlacementFinderScript = preload("res://scripts/world/activity_placement_finder.gd")
const SeededRngScript = preload("res://scripts/core/seeded_rng.gd")
const MapDefinition = preload("res://data/map/prototype_02_map.tres")

const EXPECTED_QUESTS := [
	{"file": "0101_ogre_stone_road.tres", "id": "ogre_stone_road", "mob": "ogre_veteran", "name": "Огр у каменной дороги", "band": "lower", "count": Vector2i(2, 3), "hex": Vector2i(3, 4), "gold": Vector2i(58, 62)},
	{"file": "0102_orcs_far_outpost.tres", "id": "orcs_far_outpost", "mob": "hardened_orc_raider", "name": "Орки у дальнего кордона", "band": "lower", "count": Vector2i(3, 5), "hex": Vector2i(3, 5), "gold": Vector2i(38, 41)},
	{"file": "0103_troll_deep_thicket.tres", "id": "troll_deep_thicket", "mob": "mature_forest_troll", "name": "Тролль в глубокой чаще", "band": "lower", "count": Vector2i(2, 4), "hex": Vector2i(3, 5), "gold": Vector2i(54, 58)},
	{"file": "0104_band_on_trade_road.tres", "id": "band_on_trade_road", "mob": "veteran_bandit", "name": "Банда на торговом тракте", "band": "lower", "count": Vector2i(4, 6), "hex": Vector2i(3, 5), "gold": Vector2i(33, 37)},
	{"file": "0105_roar_from_grey_hills.tres", "id": "roar_from_grey_hills", "mob": "old_mountain_beast", "name": "Рёв с серых холмов", "band": "lower", "count": Vector2i(3, 5), "hex": Vector2i(4, 5), "gold": Vector2i(44, 48)},
	{"file": "0106_pack_far_pastures.tres", "id": "pack_far_pastures", "mob": "warg_pack_leader", "name": "Стая у дальних пастбищ", "band": "lower", "count": Vector2i(4, 6), "hex": Vector2i(3, 5), "gold": Vector2i(37, 41)},
	{"file": "0107_berserker_burned_camp.tres", "id": "berserker_burned_camp", "mob": "orc_berserker", "name": "Берсерк у выжженного лагеря", "band": "lower", "count": Vector2i(3, 5), "hex": Vector2i(4, 5), "gold": Vector2i(49, 54)},
	{"file": "0108_mercenaries_south_road.tres", "id": "mercenaries_south_road", "mob": "hardened_mercenary", "name": "Наёмники на южной дороге", "band": "lower", "count": Vector2i(4, 6), "hex": Vector2i(3, 6), "gold": Vector2i(41, 46)},
	{"file": "0109_troll_old_quarry.tres", "id": "troll_old_quarry", "mob": "stone_troll", "name": "Тролль у старого карьера", "band": "lower", "count": Vector2i(2, 4), "hex": Vector2i(4, 6), "gold": Vector2i(74, 79)},
	{"file": "0110_fiery_tracks_stony_slopes.tres", "id": "fiery_tracks_stony_slopes", "mob": "fire_salamander", "name": "Огненные следы на каменистых склонах", "band": "middle", "count": Vector2i(3, 5), "hex": Vector2i(4, 6), "gold": Vector2i(59, 63)},
	{"file": "0111_storm_over_open_plain.tres", "id": "storm_over_open_plain", "mob": "storm_shaman", "name": "Гроза над открытой равниной", "band": "middle", "count": Vector2i(3, 5), "hex": Vector2i(4, 6), "gold": Vector2i(62, 66)},
	{"file": "0112_roar_old_caves.tres", "id": "roar_old_caves", "mob": "cave_ogre", "name": "Рёв из старых пещер", "band": "middle", "count": Vector2i(2, 4), "hex": Vector2i(5, 6), "gold": Vector2i(87, 92)},
	{"file": "0113_master_bandit_road.tres", "id": "master_bandit_road", "mob": "road_bandit_chief", "name": "Хозяин разбойничьего тракта", "band": "middle", "count": Vector2i(2, 3), "hex": Vector2i(4, 6), "gold": Vector2i(110, 116)},
	{"file": "0114_cold_tracks_hills.tres", "id": "cold_tracks_hills", "mob": "ice_monitor_lizard", "name": "Холодные следы среди холмов", "band": "middle", "count": Vector2i(3, 5), "hex": Vector2i(5, 6), "gold": Vector2i(72, 76)},
	{"file": "0115_orc_patrol_forest.tres", "id": "orc_patrol_forest", "mob": "orc_guard", "name": "Орочий дозор в лесу", "band": "middle", "count": Vector2i(4, 6), "hex": Vector2i(5, 6), "gold": Vector2i(60, 64)},
	{"file": "0116_mage_old_road.tres", "id": "mage_old_road", "mob": "battle_mage_mercenary", "name": "Маг на старой дороге", "band": "middle", "count": Vector2i(3, 5), "hex": Vector2i(4, 6), "gold": Vector2i(79, 84)},
	{"file": "0117_guardian_abandoned_quarry.tres", "id": "guardian_abandoned_quarry", "mob": "stone_golem", "name": "Страж заброшенной каменоломни", "band": "middle", "count": Vector2i(2, 4), "hex": Vector2i(5, 7), "gold": Vector2i(111, 116)},
	{"file": "0118_shaman_orc_thicket.tres", "id": "shaman_orc_thicket", "mob": "orc_shaman", "name": "Шаман в орочьей чаще", "band": "higher", "count": Vector2i(3, 5), "hex": Vector2i(5, 7), "gold": Vector2i(87, 91)},
	{"file": "0119_flame_among_stones.tres", "id": "flame_among_stones", "mob": "fire_elemental", "name": "Пламя среди камней", "band": "higher", "count": Vector2i(3, 5), "hex": Vector2i(5, 7), "gold": Vector2i(91, 95)},
	{"file": "0120_storm_lizard_plain.tres", "id": "storm_lizard_plain", "mob": "storm_lizard", "name": "Грозовой ящер на равнине", "band": "higher", "count": Vector2i(4, 6), "hex": Vector2i(5, 7), "gold": Vector2i(76, 80)},
	{"file": "0121_troll_far_thicket.tres", "id": "troll_far_thicket", "mob": "troll_veteran", "name": "Тролль из дальней чащи", "band": "higher", "count": Vector2i(3, 5), "hex": Vector2i(6, 7), "gold": Vector2i(99, 103)},
	{"file": "0122_black_knight_old_bridge.tres", "id": "black_knight_old_bridge", "mob": "black_knight", "name": "Чёрный рыцарь у старого моста", "band": "higher", "count": Vector2i(2, 3), "hex": Vector2i(5, 7), "gold": Vector2i(166, 172)},
	{"file": "0123_frost_dead_forest.tres", "id": "frost_dead_forest", "mob": "ice_elemental", "name": "Мороз в мёртвом лесу", "band": "higher", "count": Vector2i(3, 5), "hex": Vector2i(6, 7), "gold": Vector2i(108, 112)},
	{"file": "0124_warlord_fortified_camp.tres", "id": "warlord_fortified_camp", "mob": "orc_warlord", "name": "Воевода укреплённого лагеря", "band": "higher", "count": Vector2i(1, 2), "hex": Vector2i(6, 7), "gold": Vector2i(303, 309)},
	{"file": "0125_destroyer_stone_hills.tres", "id": "destroyer_stone_hills", "mob": "ogre_destroyer", "name": "Разрушитель с каменных холмов", "band": "higher", "count": Vector2i(2, 3), "hex": Vector2i(6, 7), "gold": Vector2i(188, 194)},
	{"file": "0126_colossus_split_cliff.tres", "id": "colossus_split_cliff", "mob": "stone_colossus", "name": "Исполин у расколотого утёса", "band": "higher", "count": Vector2i(1, 2), "hex": Vector2i(6, 7), "gold": Vector2i(330, 336)},
]

func _init() -> void:
	var hex_map = HexMapScript.new(MapDefinition)
	var blank_world_state = WorldStateScript.new(hex_map)
	var finder = ActivityPlacementFinderScript.new()
	var seen_ids := {}
	var seen_mobs := {}
	var band_counts := {"lower": 0, "middle": 0, "higher": 0}
	var terrain_usage := {"forest": 0, "plains": 0, "hill": 0, "road": 0}
	var previous_xp: int = -1

	for expected in EXPECTED_QUESTS:
		var quest = load("res://data/quests/mid_city/%s" % expected["file"])
		assert(quest != null, "Arden quest resource must exist: %s" % expected["file"])
		assert(quest.id == expected["id"] and quest.display_name == expected["name"], "Arden quest identity/name must match the approved table: %s" % expected["file"])
		assert(quest.mob_definition != null and quest.mob_definition.id == expected["mob"], "Each Arden quest must reference its matching 0101-0126 mob: %s" % quest.id)
		assert(quest.strength_band == expected["band"], "Arden quest band must match the approved 9/8/9 split: %s" % quest.id)
		assert(Vector2i(quest.mob_count_min, quest.mob_count_max) == expected["count"], "Arden quest mob-count range must match the approved table: %s" % quest.id)
		assert(Vector2i(quest.placement_distance_hex_min, quest.placement_distance_hex_max) == expected["hex"], "Arden quest hex-distance range must match the approved table: %s" % quest.id)
		assert(Vector2i(quest.gold_per_mob_min, quest.gold_per_mob_max) == expected["gold"], "Arden quest Gold-per-mob range must match the approved table: %s" % quest.id)
		assert(quest.distance_km_min == quest.placement_distance_hex_min * 3 and quest.distance_km_max == quest.placement_distance_hex_max * 3, "Legacy kilometre range must mirror the real 3-km-per-hex placement range: %s" % quest.id)
		assert(quest.placement_distance_hex_min >= 3 and quest.placement_distance_hex_max <= 7, "Every Arden ordinary quest must stay in the approved 3-7 hex range: %s" % quest.id)
		assert(quest.placement_forbidden_tags.has("city"), "Arden ordinary quests must never place inside city hexes: %s" % quest.id)
		assert(not quest.placement_allowed_terrain_ids.is_empty() or not quest.placement_allowed_tags.is_empty(), "Every Arden quest must constrain its authored location by terrain or road tag: %s" % quest.id)
		assert(not seen_ids.has(quest.id) and not seen_mobs.has(quest.mob_definition.id), "Arden quest ids and mob assignments must be one-to-one and unique: %s" % quest.id)
		seen_ids[quest.id] = true
		seen_mobs[quest.mob_definition.id] = true
		band_counts[quest.strength_band] += 1
		for terrain_id in quest.placement_allowed_terrain_ids:
			if terrain_usage.has(terrain_id):
				terrain_usage[terrain_id] += 1
		if quest.placement_allowed_tags.has("road"):
			terrain_usage["road"] += 1

		var candidates: Array[Vector2i] = finder.find_valid_centers(
			hex_map,
			blank_world_state,
			hex_map.MID_REGION_ID,
			hex_map.definition.mid_city_center,
			quest.placement_distance_hex_min,
			quest.placement_distance_hex_max,
			quest.placement_allowed_terrain_ids,
			quest.placement_allowed_tags,
			quest.placement_forbidden_tags,
			0
		)
		assert(not candidates.is_empty(), "Every Arden quest must have at least one real valid map location in its authored terrain/range: %s" % quest.id)
		assert(quest.mob_definition.experience_reward > 0, "Every connected Arden quest mob must grant XP: %s" % quest.mob_definition.id)
		assert(quest.mob_definition.experience_reward > previous_xp, "Arden mob XP rewards must rise with the approved Power progression: %s" % quest.mob_definition.id)
		previous_xp = quest.mob_definition.experience_reward

	assert(seen_ids.size() == 26 and seen_mobs.size() == 26, "Arden must expose exactly 26 one-to-one ordinary mob/quest pairs.")
	assert(band_counts == {"lower": 9, "middle": 8, "higher": 9}, "Arden ordinary quests must use the approved 9 lower / 8 middle / 9 higher split.")
	assert(terrain_usage["forest"] >= 5 and terrain_usage["plains"] >= 5 and terrain_usage["hill"] >= 8 and terrain_usage["road"] >= 5, "Arden quest locations must preserve a broad mix of forest, plains, hills and road problems.")

	for probe_seed in [11, 37, 101, 777, 2026, 9401]:
		var world_state = WorldStateScript.new(hex_map)
		var board_rng: RandomNumberGenerator = SeededRngScript.new(probe_seed).get_rng()
		var placement_rng: RandomNumberGenerator = SeededRngScript.new(probe_seed + 10000).get_rng()
		var pool = QuestPoolScript.new([], board_rng, "res://data/quests/mid_city")
		assert(pool.quest_templates.size() == 26, "Arden QuestPool must load all 26 local templates from its own directory.")
		var selected_ids_before_placement: Array[String] = []
		for pending_offer in pool.get_available_quests():
			selected_ids_before_placement.append(pending_offer.id)
		assert(pool.configure_map_placement(hex_map, world_state, hex_map.MID_REGION_ID, hex_map.definition.mid_city_center, placement_rng), "Arden's 4/4/4 board must fit on unique valid Mid Region targets for sampled seeds.")
		var offers: Array = pool.get_available_quests()
		if offers.size() != 12:
			var placed_ids: Array[String] = []
			for placed_offer in offers:
				placed_ids.append(placed_offer.id)
			print("Arden placement failure seed=%d selected=%s placed=%s" % [probe_seed, selected_ids_before_placement, placed_ids])
			quit(1)
			return
		assert(offers.size() == 12, "Arden must expose the full current 4/4/4 board when all bands have enough templates.")
		var offer_bands := {"lower": 0, "middle": 0, "higher": 0}
		var targets := {}
		for offer in offers:
			offer_bands[offer.template.strength_band] += 1
			assert(offer.has_map_target(), "Every active Arden offer must own a real target hex.")
			assert(not targets.has(offer.target_hex), "Active Arden offers must never share a target hex.")
			targets[offer.target_hex] = true
			var target_hex = hex_map.get_hex(offer.target_hex)
			assert(target_hex != null and target_hex.region_id == hex_map.MID_REGION_ID, "Every Arden board target must stay in Mid Region.")
			assert(offer.map_distance_steps >= offer.template.placement_distance_hex_min and offer.map_distance_steps <= offer.template.placement_distance_hex_max, "Arden offer route distance must obey its authored range.")
		assert(offer_bands == {"lower": 4, "middle": 4, "higher": 4}, "Every Arden board roll must preserve the current 4/4/4 composition.")

	print("PASS: Arden has 26 authored 0101-0126 quests with approved rewards/counts, 3-7-hex terrain placement, XP, and a valid local 4/4/4 board.")
	quit()
