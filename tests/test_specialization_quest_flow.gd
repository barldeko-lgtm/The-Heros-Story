extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const SpecializationQuestSystemScript = preload("res://scripts/hero/specialization_quest_system.gd")
const CombatResultScript = preload("res://scripts/combat/combat_result.gd")
const SimulationSnapshotScript = preload("res://scripts/core/simulation_snapshot.gd")

func _init() -> void:
	test_protector_quest_reward()
	test_slayer_quest_reward_and_growth()
	test_active_specialization_quest_survives_snapshot()
	print("PASS: Specialization Quest starts after a normal turn-in, spawns a known plains trial, stays separate from active_quest, and grants the approved class/rewards only at trainer turn-in.")
	quit()

func test_protector_quest_reward() -> void:
	var simulation = make_ready_simulation("protector", 23)
	turn_in_ordinary_quest_and_accept_specialization(simulation, 101)
	var dungeon = SpecializationQuestSystemScript.find_quest_dungeon(simulation.hero_state, simulation.dungeon_system)
	assert(dungeon != null and dungeon.discovered and dungeon.discovery_source == "specialization_quest", "Trainer acceptance must create one immediately known specialization dungeon.")
	assert(simulation.hex_map.get_hex(dungeon.target_hex).terrain_id == "plains", "Specialization dungeon must spawn on plains.")
	var distance: int = simulation.hex_map.get_distance_steps(simulation.hex_map.definition.mid_city_center, dungeon.target_hex)
	assert(distance >= 4 and distance <= 6, "Specialization dungeon must spawn 4-6 hexes from Arden.")
	assert(simulation.hero_state.active_quest == null, "Specialization Quest must not occupy the ordinary active_quest slot after the ordinary turn-in.")
	var gold_before_specialization_reward: int = simulation.hero_state.gold
	var con_before: int = simulation.hero_state.constitution
	var pending_before: int = simulation.hero_state.pending_primary_attribute_points
	assert(simulation.hero_state.hero_class_id == "warrior", "Accepting the Specialization Quest must not grant the class early.")

	complete_objective_and_turn_in(simulation, dungeon, 103)
	assert(simulation.hero_state.hero_class_id == "protector", "Protector class must be granted only when the completed trial is turned in to the trainer.")
	assert(simulation.hero_state.gold == gold_before_specialization_reward + 2000, "Specialization Quest must grant exactly 2000 Gold.")
	assert(simulation.hero_state.constitution == con_before + 3, "Level-23 Protector completion must catch up +3 CON for levels 21-23.")
	assert(simulation.hero_state.pending_primary_attribute_points == pending_before + 5, "Specialization Quest must grant five player-distributed attribute points.")
	var weapon = simulation.hero_state.equipment.get_item("weapon")
	var shield = simulation.hero_state.equipment.get_item("shield")
	assert(weapon != null and weapon.item_level == 20 and weapon.rarity == 2 and weapon.definition.id == "crimson_thornplate_sword_rare", "Protector reward must include the existing Rare ilvl20 one-handed sword.")
	assert(shield != null and shield.item_level == 20 and shield.rarity == 2 and shield.definition.id == "crimson_thornplate_shield_rare", "Protector reward must include the existing Rare ilvl20 shield.")
	assert(simulation.hero_state.shield_bash_skill_level == 0, "A Level-23 Protector must still wait until Level 25 for Shield Bash.")

func test_slayer_quest_reward_and_growth() -> void:
	var simulation = make_ready_simulation("slayer", 25)
	turn_in_ordinary_quest_and_accept_specialization(simulation, 201)
	var dungeon = SpecializationQuestSystemScript.find_quest_dungeon(simulation.hero_state, simulation.dungeon_system)
	var gold_before_specialization_reward: int = simulation.hero_state.gold
	var dex_before: int = simulation.hero_state.dexterity
	var strength_before: int = simulation.hero_state.strength
	var pending_before: int = simulation.hero_state.pending_primary_attribute_points
	complete_objective_and_turn_in(simulation, dungeon, 203)
	assert(simulation.hero_state.hero_class_id == "slayer", "Slayer class must be granted on trainer turn-in.")
	assert(simulation.hero_state.gold == gold_before_specialization_reward + 2000, "Slayer quest must grant exactly 2000 Gold.")
	assert(simulation.hero_state.dexterity == dex_before + 5, "Level-25 Slayer completion must catch up +5 DEX for levels 21-25.")
	assert(simulation.hero_state.strength == strength_before, "Slayer catch-up must not add extra STR.")
	assert(simulation.hero_state.pending_primary_attribute_points == pending_before + 5, "Slayer quest must grant five free player-distributed points.")
	assert(simulation.hero_state.crippling_blows_skill_level == 1, "Level-25+ Slayer must learn Crippling Blows SL1 immediately when the class is granted.")
	var greatsword = simulation.hero_state.equipment.get_item("weapon")
	assert(greatsword != null and greatsword.definition.id == "crimson_thornplate_greatsword_rare" and greatsword.item_level == 20 and greatsword.rarity == 2, "Slayer reward must be the Rare ilvl20 two-handed weapon.")
	assert(greatsword.get_base_stat("attack") == 60.0 and is_zero_approx(greatsword.get_base_stat("attack_speed")), "Slayer reward two-hander must use the approved +60/no-base-speed profile.")
	assert(simulation.hero_state.equipment.get_item("shield") == null, "Equipping the Slayer two-handed reward must leave the shield slot empty.")

	var dex_before_level_up: int = simulation.hero_state.dexterity
	var str_before_level_up: int = simulation.hero_state.strength
	var pending_before_level_up: int = simulation.hero_state.pending_primary_attribute_points
	simulation.hero_progression.apply_level_up(simulation.hero_state)
	assert(simulation.hero_state.dexterity == dex_before_level_up + 1, "Future Slayer levels must add +1 DEX specialization growth.")
	assert(simulation.hero_state.strength == str_before_level_up + 1, "Future Slayer levels must retain the base Warrior +1 STR growth.")
	assert(simulation.hero_state.pending_primary_attribute_points == pending_before_level_up + 4, "Future specialization levels must still add four player-distributed points.")

func test_active_specialization_quest_survives_snapshot() -> void:
	var simulation = make_ready_simulation("protector", 22)
	turn_in_ordinary_quest_and_accept_specialization(simulation, 301)
	var original_dungeon = SpecializationQuestSystemScript.find_quest_dungeon(simulation.hero_state, simulation.dungeon_system)
	assert(original_dungeon != null)
	var captured: Dictionary = SimulationSnapshotScript.capture(simulation)
	assert(str(captured.get("error", "")).is_empty(), "Active Specialization Quest must be serializable through the existing snapshot graph.")
	var restored_result: Dictionary = SimulationSnapshotScript.restore(captured)
	assert(str(restored_result.get("error", "")).is_empty(), "Active Specialization Quest snapshot must restore without a schema-specific flag.")
	var restored = restored_result.get("simulation")
	var restored_dungeon = SpecializationQuestSystemScript.find_quest_dungeon(restored.hero_state, restored.dungeon_system)
	assert(restored_dungeon != null and not restored_dungeon.completed and restored_dungeon.discovered, "Restored chosen path + dungeon instance must reconstruct the active parallel Specialization Quest.")
	assert(restored_dungeon.target_hex == original_dungeon.target_hex and restored_dungeon.discovery_source == "specialization_quest", "Specialization dungeon location and known state must survive save/load.")

func make_ready_simulation(specialization_id: String, level: int):
	var simulation = SimulationScript.new(74000 + level, preload("res://data/quests/0001_goblin_road_problem.tres"))
	var hero = simulation.hero_state
	hero.level = level
	hero.experience_to_next_level = simulation.hero_progression.get_experience_required_for_next_level(level)
	hero.first_specialization_id = specialization_id
	hero.hero_class_id = "warrior"
	hero.specialization_decision_active = false
	hero.current_city_id = HeroState.MID_CITY_ID
	var _position_ok: bool = simulation.world_state.set_hero_position(simulation.hex_map.definition.mid_city_center)
	assert(_position_ok)
	hero.loop_state = HeroState.TURNING_IN_QUEST
	hero.active_quest = simulation.quest_runner.quest_definition
	return simulation

func turn_in_ordinary_quest_and_accept_specialization(simulation, turn_in_tick: int) -> void:
	simulation.on_world_tick_completed(turn_in_tick)
	assert(simulation.hero_state.loop_state == HeroState.VISITING_WARRIOR_TRAINER, "Chosen Warrior must visit the trainer only after the ordinary quest turn-in.")
	assert(SpecializationQuestSystemScript.find_quest_dungeon(simulation.hero_state, simulation.dungeon_system) == null, "Specialization dungeon must not exist before the trainer gives the quest.")
	simulation.on_world_tick_completed(turn_in_tick + 1)
	assert(simulation.hero_state.loop_state == HeroState.VISITING_MARKET, "After accepting the parallel Specialization Quest, normal city routine must continue.")
	assert(SpecializationQuestSystemScript.quest_is_active(simulation.hero_state, simulation.dungeon_system), "Accepted Specialization Quest must remain active in parallel with ordinary questing.")

func complete_objective_and_turn_in(simulation, dungeon, trainer_tick: int) -> void:
	assert(dungeon != null)
	var gold_before_boss: int = simulation.hero_state.gold
	var _position_ok: bool = simulation.world_state.set_hero_position(dungeon.target_hex)
	assert(_position_ok)
	simulation.dungeon_runner.active_dungeon = dungeon
	simulation.dungeon_runner.ordinary_encounters_completed = dungeon.definition.ordinary_encounter_count
	simulation.hero_state.loop_state = HeroState.DOING_DUNGEON
	var boss = dungeon.definition.boss_mob_definition
	var result = CombatResultScript.new(true, simulation.combat_stats.max_hp, 0.0, 1.0, [])
	simulation.complete_dungeon_combat(boss, result, true, trainer_tick - 20)
	assert(dungeon.completed and simulation.hero_state.hero_class_id == "warrior", "Boss victory must complete only the trial objective; the hero remains Warrior until trainer turn-in.")
	assert(simulation.hero_state.gold == gold_before_boss, "Specialization dungeon itself must grant no Gold.")
	assert(simulation.hero_state.loop_state == HeroState.DUNGEON_RETURNING_TO_CITY, "Specialization boss victory must start the normal return route.")
	var route_guard := 0
	while simulation.hero_state.loop_state == HeroState.DUNGEON_RETURNING_TO_CITY and route_guard < 30:
		simulation.advance_dungeon_return_tick(trainer_tick - 19 + route_guard)
		route_guard += 1
	assert(route_guard < 30 and simulation.hero_state.loop_state == HeroState.VISITING_WARRIOR_TRAINER, "Returning from a completed specialization trial must route to the Warrior Trainer.")
	simulation.on_world_tick_completed(trainer_tick)
	assert(simulation.hero_state.loop_state == HeroState.VISITING_MARKET, "Completed Specialization Quest must return to the normal city market cycle after trainer turn-in.")
