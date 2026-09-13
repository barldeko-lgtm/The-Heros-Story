extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const LootGeneratorScript = preload("res://scripts/loot/loot_generator.gd")
const CombatResultScript = preload("res://scripts/combat/combat_result.gd")

class ScriptedRng:
	var float_values: Array[float] = []
	var int_values: Array[int] = []

	func _init(initial_float_values: Array[float] = [], initial_int_values: Array[int] = []) -> void:
		float_values = initial_float_values.duplicate()
		int_values = initial_int_values.duplicate()

	func randf() -> float:
		assert(not float_values.is_empty(), "Scripted RNG ran out of float values.")
		return float_values.pop_front()

	func randi_range(from: int, to: int) -> int:
		assert(not int_values.is_empty(), "Scripted RNG ran out of integer values.")
		var value: int = int_values.pop_front()
		assert(value >= from and value <= to, "Scripted integer roll must stay inside the requested range.")
		return value

func _init() -> void:
	var simulation = SimulationScript.new(12001, null)
	var mid_dungeons: Array = simulation.dungeon_system.get_unknown_dungeons_in_region(simulation.hex_map.MID_REGION_ID)
	assert(mid_dungeons.size() == 3, "Arden must load exactly three ordinary Mid Region dungeons.")

	check_dungeon(simulation, "abandoned_border_fort", "plains", 4, 6, 310.0, 400.0, 15, 3000)
	check_dungeon(simulation, "ash_caves", "forest", 5, 7, 450.0, 580.0, 20, 5000)
	check_dungeon(simulation, "iron_fang_fortress", "hill", 6, 7, 650.0, 840.0, 25, 8000)

	assert(simulation.activate_mid_city_quest_context(), "Arden's ordinary quest board must still fit after reserving all three Mid Region dungeon hexes.")
	simulation.hero_state.current_city_id = HeroState.MID_CITY_ID
	assert(simulation.get_current_city_center() == simulation.hex_map.definition.mid_city_center, "Dungeon death/return routing in Arden must resolve the Arden city center.")
	test_arden_dungeon_success_returns_to_arden()
	test_arden_dungeon_death_returns_to_arden()

	print("PASS: Arden has three placed dungeons with approved 310/400, 450/580 and 650/840 Power bands plus ilvl 15/20/25 Rare/Epic rewards.")
	quit()

func check_dungeon(simulation, dungeon_id: String, terrain_id: String, min_distance: int, max_distance: int, ordinary_power: float, boss_power: float, item_level: int, gold_reward: int) -> void:
	var dungeon = find_dungeon(simulation, dungeon_id)
	assert(dungeon != null, "Expected Mid Region dungeon must load: %s" % dungeon_id)
	assert(dungeon.definition.region_id == simulation.hex_map.MID_REGION_ID, "Mid Region dungeon must keep the Arden region id.")
	assert(dungeon.definition.ordinary_encounter_count == 3, "Every current Arden dungeon must use three ordinary encounters before its boss.")
	assert(dungeon.definition.completion_gold_reward == gold_reward, "Arden dungeon must keep its approved Gold reward.")
	assert(is_equal_approx(dungeon.definition.completion_epic_chance, 0.25), "Arden dungeon rewards must keep the 75% Rare / 25% Epic split.")
	assert(dungeon.definition.completion_equipment_source != null and int(dungeon.definition.completion_equipment_source.item_level) == item_level, "Arden dungeon must reward its approved item level.")
	assert(dungeon.definition.ordinary_mob_definition.equipment_drop_table == null and dungeon.definition.boss_mob_definition.equipment_drop_table == null, "Dungeon enemies must not gain ordinary equipment drops.")
	assert(absf(dungeon.definition.ordinary_mob_definition.get_power() - ordinary_power) <= 1.0, "Ordinary dungeon mob Power must stay within one point of the approved target.")
	assert(absf(dungeon.definition.boss_mob_definition.get_power() - boss_power) <= 1.0, "Dungeon boss Power must stay within one point of the approved target.")

	var target_hex = simulation.hex_map.get_hex(dungeon.target_hex)
	assert(target_hex != null and target_hex.terrain_id == terrain_id, "Arden dungeon must spawn on its approved terrain.")
	var distance: int = simulation.hex_map.get_distance_steps(simulation.hex_map.definition.mid_city_center, dungeon.target_hex)
	assert(distance >= min_distance and distance <= max_distance, "Arden dungeon must stay inside its approved placement-distance band.")

	var loot_generator = LootGeneratorScript.new()
	var epic_roll: Dictionary = loot_generator.roll_dungeon_completion_equipment(dungeon.definition, ScriptedRng.new([0.249999], [0]))
	assert(int(epic_roll.get("item_level", 0)) == item_level and int(epic_roll.get("rarity", -1)) == 3, "Arden dungeon must produce Epic equipment at a roll below 25 percent.")
	var rare_roll: Dictionary = loot_generator.roll_dungeon_completion_equipment(dungeon.definition, ScriptedRng.new([0.25], [0]))
	assert(int(rare_roll.get("item_level", 0)) == item_level and int(rare_roll.get("rarity", -1)) == 2, "Arden dungeon must produce Rare equipment at or above the 25 percent Epic threshold.")

func test_arden_dungeon_success_returns_to_arden() -> void:
	var simulation = SimulationScript.new(12002, null)
	var dungeon = find_dungeon(simulation, "abandoned_border_fort")
	assert(dungeon != null, "Arden success-routing test requires the first Mid Region dungeon.")
	simulation.hero_state.current_city_id = HeroState.MID_CITY_ID
	dungeon.discover("test")
	var dungeon_hex: Vector2i = dungeon.target_hex
	assert(simulation.world_state.set_hero_position(dungeon_hex), "Arden success-routing test must place the hero on the dungeon hex.")
	simulation.dungeon_runner.active_dungeon = dungeon
	simulation.dungeon_runner.ordinary_encounters_completed = dungeon.definition.ordinary_encounter_count
	simulation.hero_state.loop_state = HeroState.DOING_DUNGEON
	var boss = dungeon.definition.boss_mob_definition
	var result = CombatResultScript.new(true, simulation.combat_stats.max_hp, 0.0, 1.0, [])
	simulation.complete_dungeon_combat(boss, result, true, simulation.world_clock.world_tick)
	assert(simulation.hero_state.loop_state == HeroState.DUNGEON_RETURNING_TO_CITY, "Arden dungeon completion must start return travel.")
	var route_to_arden: Array[Vector2i] = simulation.hex_map.find_path(dungeon_hex, simulation.hex_map.definition.mid_city_center)
	assert(simulation.travel_system.get_remaining_steps() == route_to_arden.size() - 1, "Arden dungeon completion must route back to Arden, not Dornwald.")

func test_arden_dungeon_death_returns_to_arden() -> void:
	var simulation = SimulationScript.new(12003, null)
	var dungeon = find_dungeon(simulation, "ash_caves")
	assert(dungeon != null, "Arden death-routing test requires the second Mid Region dungeon.")
	simulation.hero_state.current_city_id = HeroState.MID_CITY_ID
	dungeon.discover("test")
	assert(simulation.world_state.set_hero_position(dungeon.target_hex), "Arden death-routing test must place the hero on the dungeon hex.")
	simulation.dungeon_runner.active_dungeon = dungeon
	simulation.dungeon_runner.ordinary_encounters_completed = 0
	simulation.dungeon_runner.attempt_start_power = simulation.get_hero_power()
	simulation.hero_state.loop_state = HeroState.DOING_DUNGEON
	var ordinary_mob = dungeon.definition.ordinary_mob_definition
	var result = CombatResultScript.new(false, 0.0, ordinary_mob.max_hp, 1.0, [])
	simulation.complete_dungeon_combat(ordinary_mob, result, false, simulation.world_clock.world_tick)
	assert(simulation.hero_state.loop_state == HeroState.DEAD_RESPAWNING, "Arden dungeon defeat must enter the normal dungeon respawn state.")
	assert(simulation.world_state.hero_position == simulation.hex_map.definition.mid_city_center, "Arden dungeon death must return the hero to Arden, not Dornwald.")

func find_dungeon(simulation, dungeon_id: String):
	for dungeon in simulation.dungeon_system.get_all_dungeons():
		if dungeon != null and dungeon.definition != null and dungeon.definition.id == dungeon_id:
			return dungeon
	return null
