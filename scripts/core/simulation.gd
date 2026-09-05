class_name Simulation
extends RefCounted

const WorldClockScript = preload("res://scripts/core/world_clock.gd")
const SeededRngScript = preload("res://scripts/core/seeded_rng.gd")
const HeroNameRepositoryScript = preload("res://scripts/core/hero_name_repository.gd")
const HexMapScript = preload("res://scripts/world/hex_map.gd")
const WorldStateScript = preload("res://scripts/world/world_state.gd")
const TravelSystemScript = preload("res://scripts/world/travel_system.gd")
const DungeonSystemScript = preload("res://scripts/dungeons/dungeon_system.gd")
const DungeonRunnerScript = preload("res://scripts/dungeons/dungeon_runner.gd")
const DungeonEvaluatorScript = preload("res://scripts/dungeons/dungeon_evaluator.gd")
const EventSystemScript = preload("res://scripts/events/event_system.gd")
const EventRunnerScript = preload("res://scripts/events/event_runner.gd")
const HeroStateScript = preload("res://scripts/hero/hero_state.gd")
const HeroTraitsScript = preload("res://scripts/hero/hero_traits.gd")
const TraitDevelopmentScript = preload("res://scripts/hero/trait_development.gd")
const GodStateScript = preload("res://scripts/god/god_state.gd")
const GodSystemScript = preload("res://scripts/god/god_system.gd")
const HeroProgressionScript = preload("res://scripts/hero/hero_progression.gd")
const StatResolverScript = preload("res://scripts/hero/stat_resolver.gd")
const EquipmentEvaluatorScript = preload("res://scripts/hero/equipment_evaluator.gd")
const PowerCalculatorScript = preload("res://scripts/combat/power_calculator.gd")
const CombatSimulatorScript = preload("res://scripts/combat/combat_simulator.gd")
const DebugLogScript = preload("res://scripts/narrative/debug_log.gd")
const DiaryScript = preload("res://scripts/narrative/diary.gd")
const QuestNarratorScript = preload("res://scripts/narrative/quest_narrator.gd")
const DungeonNarratorScript = preload("res://scripts/narrative/dungeon_narrator.gd")
const EventNarratorScript = preload("res://scripts/narrative/event_narrator.gd")
const QuestRunnerScript = preload("res://scripts/quests/quest_runner.gd")
const QuestPoolScript = preload("res://scripts/quests/quest_pool.gd")
const QuestEventScript = preload("res://scripts/quests/quest_event.gd")
const QuestEvaluatorScript = preload("res://scripts/quests/quest_evaluator.gd")
const LootGeneratorScript = preload("res://scripts/loot/loot_generator.gd")
const EquipmentRewardSystemScript = preload("res://scripts/loot/equipment_reward_system.gd")
const ItemGeneratorScript = preload("res://scripts/items/item_generator.gd")
const ItemInstanceScript = preload("res://scripts/model/runtime/item_instance.gd")
const EquipmentSaleSystemScript = preload("res://scripts/economy/equipment_sale_system.gd")
const ShopSystemScript = preload("res://scripts/economy/shop_system.gd")
const SpendingEvaluatorScript = preload("res://scripts/economy/spending_evaluator.gd")
const PotionPreparationSystemScript = preload("res://scripts/economy/potion_preparation_system.gd")

const DefaultInitialQuest = preload("res://data/quests/0001_goblin_road_problem.tres")
const DefaultStartingCityShop = preload("res://data/shops/starting_city_shop.tres")
const DefaultMapDefinition = preload("res://data/map/prototype_02_map.tres")
const DefaultStartingArmorDefinitions := [
	preload("res://data/items/starting_equipment/worn_shirt.tres"),
	preload("res://data/items/starting_equipment/worn_pants.tres"),
	preload("res://data/items/starting_equipment/worn_boots.tres"),
]
const TIME_EPSILON: float = 0.000001
const DEFAULT_SIMULATION_SEED: int = 1
const SHOP_RNG_SEED_OFFSET: int = 100003
const QUEST_PLACEMENT_RNG_SEED_OFFSET: int = 200003
const DUNGEON_PLACEMENT_RNG_SEED_OFFSET: int = 300003
const DUNGEON_VISION_RNG_SEED_OFFSET: int = 400003
const EVENT_PLACEMENT_RNG_SEED_OFFSET: int = 500003
const EVENT_RESOLUTION_RNG_SEED_OFFSET: int = 600003
const COMBAT_CONTEXT_QUEST: String = "quest"
const COMBAT_CONTEXT_DUNGEON: String = "dungeon"
const COMBAT_CONTEXT_EVENT: String = "event"

var world_clock = WorldClockScript.new()
var debug_log = DebugLogScript.new()
var diary = DiaryScript.new()
var quest_narrator = QuestNarratorScript.new()
var dungeon_narrator = DungeonNarratorScript.new()
var time_scale: float = 1.0
var simulation_seed: int = DEFAULT_SIMULATION_SEED
var seeded_rng
var hex_map
var world_state
var travel_system
var dungeon_system
var dungeon_runner
var dungeon_evaluator = DungeonEvaluatorScript.new()
var dungeon_vision_rng: RandomNumberGenerator
var event_system
var event_runner
var event_narrator = EventNarratorScript.new()
var trait_development = TraitDevelopmentScript.new()
var event_resolution_rng: RandomNumberGenerator
var temporary_events_enabled: bool = false
var pending_event_instance = null
var hero_state
var base_combat_stats
var combat_stats
var active_combat_session
var active_combat_mob_definition: Resource
var active_combat_context: String = ""
var skip_quest_advance_on_completed_combat_tick: bool = false

var hero_progression = HeroProgressionScript.new()
var stat_resolver = StatResolverScript.new()
var equipment_evaluator = EquipmentEvaluatorScript.new()
var power_calculator = PowerCalculatorScript.new()
var combat_simulator = CombatSimulatorScript.new()
var quest_runner
var quest_pool
var quest_evaluator = QuestEvaluatorScript.new()
var loot_generator = LootGeneratorScript.new()
var item_generator = ItemGeneratorScript.new()
var equipment_reward_system
var equipment_sale_system = EquipmentSaleSystemScript.new()
var spending_evaluator = SpendingEvaluatorScript.new()
var potion_preparation_system = PotionPreparationSystemScript.new()
var shop_system
var god_state
var god_system
var autonomous_quest_choice: bool = false
var last_quest_selection: Dictionary = {}
var combat_results_by_mob: Dictionary = {}
var pending_dungeon_preparation = null

func _init(initial_seed: int = DEFAULT_SIMULATION_SEED, initial_quest_definition: Resource = DefaultInitialQuest, available_quest_definitions: Array = [], enable_temporary_events: bool = false) -> void:
	autonomous_quest_choice = initial_quest_definition == null
	simulation_seed = initial_seed
	temporary_events_enabled = enable_temporary_events
	seeded_rng = SeededRngScript.new(simulation_seed)
	hex_map = HexMapScript.new(DefaultMapDefinition)
	world_state = WorldStateScript.new(hex_map)
	travel_system = TravelSystemScript.new(hex_map, world_state)
	dungeon_system = DungeonSystemScript.new()
	dungeon_runner = DungeonRunnerScript.new(travel_system)
	var dungeon_placement_rng: RandomNumberGenerator = SeededRngScript.new(simulation_seed + DUNGEON_PLACEMENT_RNG_SEED_OFFSET).get_rng()
	dungeon_vision_rng = SeededRngScript.new(simulation_seed + DUNGEON_VISION_RNG_SEED_OFFSET).get_rng()
	var dungeon_origins: Dictionary = {
		hex_map.STARTING_REGION_ID: hex_map.definition.starting_city_center,
		hex_map.MID_REGION_ID: hex_map.definition.mid_city_center,
	}
	assert(dungeon_system.configure_map_placement(hex_map, world_state, dungeon_origins, dungeon_placement_rng), "Every automatically loaded ordinary dungeon must spawn on a valid reserved map footprint.")
	event_system = EventSystemScript.new()
	event_resolution_rng = SeededRngScript.new(simulation_seed + EVENT_RESOLUTION_RNG_SEED_OFFSET).get_rng()
	event_runner = EventRunnerScript.new(travel_system, trait_development, event_resolution_rng)
	if temporary_events_enabled:
		var event_placement_rng: RandomNumberGenerator = SeededRngScript.new(simulation_seed + EVENT_PLACEMENT_RNG_SEED_OFFSET).get_rng()
		assert(event_system.configure_map_placement(hex_map, world_state, dungeon_origins, event_placement_rng, world_clock.world_tick), "Every enabled temporary event must spawn on a valid reserved map footprint.")
	world_state.hero_position_changed.connect(on_hero_position_changed)
	god_state = GodStateScript.new()
	god_system = GodSystemScript.new(god_state)
	equipment_reward_system = EquipmentRewardSystemScript.new(loot_generator, item_generator, equipment_evaluator)
	shop_system = ShopSystemScript.new(DefaultStartingCityShop, item_generator, simulation_seed + SHOP_RNG_SEED_OFFSET)
	var name_repository = HeroNameRepositoryScript.new(seeded_rng.get_rng())
	hero_state = HeroStateScript.new(name_repository.get_random_name())
	trait_development.ensure_state(hero_state)
	equip_starting_armor()
	hero_state.traits = HeroTraitsScript.roll_starting_traits(seeded_rng.get_rng())
	var runner_initial_quest
	if autonomous_quest_choice:
		quest_pool = QuestPoolScript.new(available_quest_definitions, seeded_rng.get_rng())
		var quest_placement_rng: RandomNumberGenerator = SeededRngScript.new(simulation_seed + QUEST_PLACEMENT_RNG_SEED_OFFSET).get_rng()
		assert(quest_pool.configure_map_placement(hex_map, world_state, hex_map.STARTING_REGION_ID, hex_map.definition.starting_city_center, quest_placement_rng), "Starting City quest board must fit on valid unique map hexes.")
	else:
		var fixed_quest_pool = QuestPoolScript.new([initial_quest_definition], seeded_rng.get_rng())
		runner_initial_quest = fixed_quest_pool.create_offer(initial_quest_definition)
	quest_runner = QuestRunnerScript.new(runner_initial_quest, travel_system, hex_map.definition.starting_city_center)
	refresh_combat_stats()
	hero_state.current_hp = combat_stats.max_hp
	if temporary_events_enabled:
		for event_instance in event_system.get_active_events():
			debug_log.record_event(world_clock.world_tick, event_narrator.describe_spawn(event_instance))
	world_clock.tick_completed.connect(on_world_tick_completed)

func equip_starting_armor() -> void:
	for item_definition in DefaultStartingArmorDefinitions:
		var fixed_stats := {"armor": 1.0}
		var item_instance = ItemInstanceScript.new(item_definition, 1, 0, fixed_stats, [], 0.0, fixed_stats)
		assert(hero_state.equipment.equip_if_empty(item_instance), "Every starting armor piece must equip into its empty approved slot.")

func advance_time(delta_seconds: float) -> void:
	var remaining_seconds := maxf(0.0, delta_seconds * time_scale)
	while remaining_seconds > TIME_EPSILON:
		if active_combat_session != null:
			var consumed_combat_seconds := advance_active_combat(remaining_seconds)
			if consumed_combat_seconds <= TIME_EPSILON:
				return
			remaining_seconds = maxf(0.0, remaining_seconds - consumed_combat_seconds)
			continue
		if hero_state.loop_state == HeroState.DOING_QUEST:
			start_combat()
			continue
		if hero_state.loop_state == HeroState.DOING_DUNGEON:
			start_dungeon_combat()
			continue
		if hero_state.loop_state == HeroState.EVENT_COMBAT:
			start_event_combat()
			continue
		var seconds_until_next_tick: float = WorldClock.TICK_DURATION_SECONDS - world_clock.elapsed_seconds
		var world_time_step: float = minf(remaining_seconds, seconds_until_next_tick)
		if world_time_step <= TIME_EPSILON:
			return
		world_clock.advance_time(world_time_step)
		remaining_seconds -= world_time_step

func set_time_scale(new_time_scale: float) -> void:
	time_scale = new_time_scale

func refresh_combat_stats() -> void:
	base_combat_stats = stat_resolver.resolve(hero_state, false)
	combat_stats = stat_resolver.resolve(hero_state, true)

func get_hero_power() -> float:
	return power_calculator.calculate(base_combat_stats)

func get_current_hero_hp() -> float:
	if active_combat_session != null:
		return active_combat_session.hero_remaining_hp
	return hero_state.current_hp

func allocate_primary_attribute(attribute_id: String) -> bool:
	if active_combat_session != null:
		return false
	var previous_max_hp: float = combat_stats.max_hp
	if not hero_progression.allocate_primary_attribute(hero_state, attribute_id):
		return false
	refresh_combat_stats()
	hero_state.current_hp = clampf(hero_state.current_hp + (combat_stats.max_hp - previous_max_hp), 0.0, combat_stats.max_hp)
	hero_state.state_changed.emit()
	return true

func get_current_opponent_name() -> String:
	if active_combat_session == null or active_combat_mob_definition == null:
		return ""
	return active_combat_mob_definition.display_name

func get_current_opponent_stats():
	if active_combat_session == null:
		return null
	return active_combat_session.mob_stats

func get_current_opponent_hp() -> float:
	if active_combat_session == null:
		return 0.0
	return active_combat_session.mob_remaining_hp

func get_current_opponent_power() -> float:
	var opponent_stats = get_current_opponent_stats()
	if opponent_stats == null:
		return 0.0
	return power_calculator.calculate(opponent_stats)

func record_combat_result(mob_definition: Resource, hero_won: bool) -> String:
	var mob_id: String = mob_definition.id
	var stats: Dictionary = combat_results_by_mob.get(mob_id, {
		"display_name": mob_definition.display_name,
		"total": 0,
		"wins": 0,
		"losses": 0,
	})
	stats["total"] += 1
	if hero_won:
		stats["wins"] += 1
	else:
		stats["losses"] += 1
	combat_results_by_mob[mob_id] = stats

	var win_rate: float = 100.0 * float(stats["wins"]) / float(stats["total"])
	return "СТАТИСТИКА %s: %d боёв | побед %d | поражений %d | winrate %.1f%%" % [
		stats["display_name"],
		stats["total"],
		stats["wins"],
		stats["losses"],
		win_rate,
	]

func get_combat_results(mob_id: String) -> Dictionary:
	return combat_results_by_mob.get(mob_id, {}).duplicate()

func get_current_combat_results() -> Dictionary:
	if active_combat_mob_definition != null:
		return get_combat_results(active_combat_mob_definition.id)
	if dungeon_runner != null and dungeon_runner.active_dungeon != null:
		var dungeon_mob = dungeon_runner.get_current_mob_definition()
		if dungeon_mob != null:
			return get_combat_results(dungeon_mob.id)
	if quest_runner == null or quest_runner.quest_definition == null or quest_runner.quest_definition.mob_definition == null:
		return {}
	return get_combat_results(quest_runner.quest_definition.mob_definition.id)

func choose_next_quest() -> bool:
	if not autonomous_quest_choice:
		return true

	var guided_quest_id: String = god_state.consume_quest_guidance()
	last_quest_selection = quest_evaluator.select_quest(quest_pool.get_available_quests(), get_hero_power(), hero_state.traits, guided_quest_id, GodStateScript.QUEST_GUIDANCE_MODIFIER)
	var selected_quest = last_quest_selection.get("selected_quest")
	if selected_quest == null:
		return false

	quest_runner.quest_definition = selected_quest
	return true

func get_active_combat_world_tick() -> int:
	return world_clock.world_tick + 1

func start_combat() -> void:
	var mob_definition: Resource = quest_runner.quest_definition.mob_definition
	start_combat_session(mob_definition, COMBAT_CONTEXT_QUEST, hero_state.current_hp)
	debug_log.record_combat_event(quest_narrator.describe_combat_started(hero_state.hero_name, quest_runner.quest_definition, quest_runner.get_next_mob_number(), quest_runner.quest_definition.mob_count), get_active_combat_world_tick())

func start_dungeon_combat() -> void:
	var mob_definition = dungeon_runner.get_current_mob_definition()
	assert(mob_definition != null, "Dungeon combat requires a current authored encounter.")
	start_combat_session(mob_definition, COMBAT_CONTEXT_DUNGEON, hero_state.current_hp)
	debug_log.record_combat_event(
		dungeon_narrator.describe_combat_started(
			hero_state.hero_name,
			dungeon_runner.active_dungeon.definition.display_name,
			mob_definition,
			dungeon_runner.get_current_encounter_number(),
			dungeon_runner.get_total_encounter_count(),
			dungeon_runner.current_encounter_is_boss()
		),
		get_active_combat_world_tick()
	)

func start_event_combat() -> void:
	var mob_definition = event_runner.get_current_mob_definition()
	assert(mob_definition != null and event_runner.active_event != null, "Event combat requires an authored active event encounter.")
	start_combat_session(mob_definition, COMBAT_CONTEXT_EVENT, hero_state.current_hp)
	debug_log.record_combat_event(
		event_narrator.describe_combat_started(hero_state.hero_name, event_runner.active_event.definition.display_name, mob_definition),
		get_active_combat_world_tick()
	)

func start_combat_session(mob_definition: Resource, combat_context: String, starting_hero_hp: float) -> void:
	var hero_damage_multiplier: float = HeroTraitsScript.get_damage_multiplier(hero_state.traits, mob_definition.category)
	active_combat_session = combat_simulator.create_session(
		combat_stats,
		mob_definition.get_combat_stats(),
		seeded_rng.get_rng(),
		hero_damage_multiplier,
		hero_state.power_strike_skill_level,
		hero_state.wisdom,
		hero_state.battle_guard_skill_level
	)
	active_combat_session.hero_remaining_hp = clampf(starting_hero_hp, 0.0, combat_stats.max_hp)
	active_combat_mob_definition = mob_definition
	active_combat_context = combat_context

func advance_active_combat(available_seconds: float) -> float:
	var previous_elapsed_seconds: float = active_combat_session.elapsed_seconds
	var actions = active_combat_session.advance(available_seconds)
	for action in actions:
		if active_combat_context == COMBAT_CONTEXT_EVENT:
			debug_log.record_combat_event(event_narrator.describe_combat_action(action, hero_state.hero_name, active_combat_mob_definition), get_active_combat_world_tick())
		elif active_combat_context == COMBAT_CONTEXT_DUNGEON:
			debug_log.record_combat_event(dungeon_narrator.describe_combat_action(action, hero_state.hero_name, active_combat_mob_definition), get_active_combat_world_tick())
		else:
			debug_log.record_combat_event(quest_narrator.describe_combat_action(action, hero_state.hero_name, quest_runner.quest_definition), get_active_combat_world_tick())
	var consumed_seconds: float = active_combat_session.elapsed_seconds - previous_elapsed_seconds
	if active_combat_session.is_finished:
		var combat_result = active_combat_session.get_result()
		var fought_mob_definition: Resource = active_combat_mob_definition
		var finished_combat_context: String = active_combat_context
		var dungeon_was_boss: bool = finished_combat_context == COMBAT_CONTEXT_DUNGEON and dungeon_runner.current_encounter_is_boss()
		consume_combat_buff_fight()
		active_combat_session = null
		record_combat_result(fought_mob_definition, combat_result.hero_won)
		var combat_world_tick: int = get_active_combat_world_tick()
		var previous_level: int = hero_state.level
		if combat_result.hero_won:
			hero_progression.add_experience(hero_state, fought_mob_definition.experience_reward)
			if hero_state.level != previous_level:
				refresh_combat_stats()

		if finished_combat_context == COMBAT_CONTEXT_EVENT:
			complete_event_combat(fought_mob_definition, combat_result, combat_world_tick)
		elif finished_combat_context == COMBAT_CONTEXT_DUNGEON:
			complete_dungeon_combat(fought_mob_definition, combat_result, dungeon_was_boss, combat_world_tick)
		else:
			if combat_result.hero_won:
				resolve_mob_equipment_drop(fought_mob_definition, combat_world_tick)
			var event = quest_runner.complete_fight(hero_state, combat_stats, combat_result)
			if event != null:
				if event.event_type == QuestEventScript.HERO_DIED:
					assert(world_state.set_hero_position(hex_map.definition.starting_city_center), "Dead hero must return to the current city map position for resurrection.")
					refresh_finished_quest_offer_if_needed(event, combat_world_tick)
				debug_log.record_combat_event(quest_narrator.describe(event), combat_world_tick)

		if hero_state.level != previous_level:
			debug_log.record_combat_event("%s повысил уровень: %d → %d." % [hero_state.hero_name, previous_level, hero_state.level], combat_world_tick)
		active_combat_mob_definition = null
		active_combat_context = ""
		skip_quest_advance_on_completed_combat_tick = true
		world_clock.complete_tick()
	return consumed_seconds

func complete_event_combat(fought_mob_definition: Resource, combat_result, combat_world_tick: int) -> void:
	var event_instance = event_runner.active_event
	assert(event_instance != null, "Finished event combat must still belong to its active event.")
	var event_name: String = event_instance.definition.display_name
	var result: Dictionary = event_runner.complete_combat(hero_state, combat_stats, combat_result)
	if combat_result.hero_won:
		debug_log.record_combat_event(
			event_narrator.describe_fight_won(hero_state.hero_name, event_name, fought_mob_definition, fought_mob_definition.experience_reward, hero_state.current_hp, combat_stats.max_hp),
			combat_world_tick
		)
		return

	var cancelled_quest = quest_runner.cancel_for_external_failure(hero_state)
	if autonomous_quest_choice and quest_pool != null and cancelled_quest != null:
		quest_pool.cancel_taken_offer(cancelled_quest)
	assert(event_system.complete_instance(event_instance, "combat_failure"), "Failed event must release its world activity.")
	event_runner.finalize_failure()
	assert(world_state.set_hero_position(hex_map.definition.starting_city_center), "Dead event hero must return to the current city map position for resurrection.")
	debug_log.record_combat_event(
		event_narrator.describe_death(hero_state.hero_name, event_name, fought_mob_definition, int(result.get("respawn_ticks_remaining", 0))),
		combat_world_tick
	)

func complete_dungeon_combat(fought_mob_definition: Resource, combat_result, was_boss: bool, combat_world_tick: int) -> void:
	var result: Dictionary = dungeon_runner.complete_fight(hero_state, combat_stats, combat_result)
	if result.is_empty():
		return
	var result_type: String = str(result.get("type", ""))
	if combat_result.hero_won:
		debug_log.record_combat_event(
			dungeon_narrator.describe_fight_won(hero_state.hero_name, fought_mob_definition, fought_mob_definition.experience_reward, hero_state.current_hp, combat_stats.max_hp, was_boss),
			combat_world_tick
		)
	if result_type == "died":
		var attempt_start_power: float = float(result.get("attempt_start_power", 0.0))
		var ordinary_encounters_completed: int = int(result.get("ordinary_encounters_completed", 0))
		var reached_boss: bool = bool(result.get("was_boss", false))
		var retry_growth: float = dungeon_evaluator.get_retry_growth(ordinary_encounters_completed, reached_boss)
		var required_retry_power: float = dungeon_evaluator.get_required_retry_power(attempt_start_power, ordinary_encounters_completed, reached_boss)
		dungeon_runner.active_dungeon.record_failed_attempt(attempt_start_power, ordinary_encounters_completed, reached_boss)
		assert(world_state.set_hero_position(hex_map.definition.starting_city_center), "Dead dungeon hero must return to the current city map position for resurrection.")
		debug_log.record_combat_event(
			dungeon_narrator.describe_death(hero_state.hero_name, dungeon_runner.active_dungeon.definition.display_name, fought_mob_definition, dungeon_runner.respawn_ticks_remaining),
			combat_world_tick
		)
		debug_log.record_combat_event(
			dungeon_narrator.describe_retry_requirement(hero_state.hero_name, dungeon_runner.active_dungeon.definition.display_name, attempt_start_power, required_retry_power, retry_growth),
			combat_world_tick
		)
	elif result_type == "completed":
		var completed_dungeon = dungeon_runner.active_dungeon
		var dungeon_definition: Resource = completed_dungeon.definition
		var gold_reward: int = maxi(0, dungeon_definition.completion_gold_reward)
		hero_state.gold += gold_reward
		var previous_max_hp: float = combat_stats.max_hp
		var reward_result: Dictionary = equipment_reward_system.resolve_dungeon_completion_reward(hero_state, dungeon_definition, seeded_rng.get_rng())
		var reward_item = reward_result.get("item_instance")
		assert(reward_item != null, "Completed dungeon must produce its guaranteed equipment reward.")
		debug_log.record_combat_event(dungeon_narrator.describe_completed(hero_state.hero_name, dungeon_definition.display_name, gold_reward), combat_world_tick)
		finalize_item_reward(reward_result, combat_world_tick, previous_max_hp)
		assert(dungeon_system.remove_completed_dungeon_from_map(completed_dungeon), "Completed dungeon must release its map activity and disappear from the map.")
		assert(dungeon_runner.begin_return_to_city(hero_state, hex_map.definition.starting_city_center), "Completed dungeon must start a real return route to the city.")
		debug_log.record_combat_event(dungeon_narrator.describe_return_started(hero_state.hero_name, dungeon_definition.display_name, travel_system.get_remaining_steps()), combat_world_tick)

func on_world_tick_completed(completed_tick: int) -> void:
	god_state.advance_world_tick()
	if temporary_events_enabled:
		for expired_event in event_system.advance_world_tick(completed_tick):
			if pending_event_instance == expired_event:
				pending_event_instance = null
			debug_log.record_event(completed_tick, event_narrator.describe_expired(expired_event))
	if shop_system.advance_world_tick(completed_tick):
		debug_log.record_event(completed_tick, "Магазин: ассортимент обновлён.")
	if autonomous_quest_choice and quest_pool.advance_world_tick(completed_tick):
		debug_log.record_event(completed_tick, "Доска заданий: предложения обновлены.")
	if skip_quest_advance_on_completed_combat_tick:
		skip_quest_advance_on_completed_combat_tick = false
		return
	if hero_state.loop_state == HeroState.EVENT_ACTIVE:
		advance_event_tick(completed_tick)
		return
	if hero_state.loop_state == HeroState.EVENT_COMBAT:
		return
	if hero_state.loop_state == HeroState.DEAD_RESPAWNING and event_runner.owns_respawn_state():
		advance_event_respawn_tick(completed_tick)
		return
	if hero_state.loop_state == HeroState.RECOVERING_IN_CITY and event_runner.owns_respawn_state():
		advance_event_city_recovery_tick(completed_tick)
		return
	if hero_state.loop_state == HeroState.VISITING_MARKET:
		advance_market_sale_tick(completed_tick)
		return
	if hero_state.loop_state == HeroState.SHOPPING:
		advance_shop_purchase_tick(completed_tick)
		return
	if hero_state.loop_state == HeroState.PREPARING_DUNGEON:
		advance_dungeon_potion_purchase_tick(completed_tick)
		return
	if hero_state.loop_state == HeroState.TRAVEL_TO_DUNGEON:
		advance_dungeon_travel_tick(completed_tick)
		return
	if hero_state.loop_state == HeroState.AT_DUNGEON_ENTRANCE:
		if dungeon_runner.enter(hero_state):
			debug_log.record_event(completed_tick, "%s вошёл в данж «%s»." % [hero_state.hero_name, dungeon_runner.active_dungeon.definition.display_name])
		else:
			debug_log.record_tick(completed_tick)
		return
	if hero_state.loop_state == HeroState.DUNGEON_BETWEEN_FIGHTS:
		advance_dungeon_between_fights_tick(completed_tick)
		return
	if hero_state.loop_state == HeroState.DUNGEON_RETURNING_TO_CITY:
		advance_dungeon_return_tick(completed_tick)
		return
	if hero_state.loop_state == HeroState.DUNGEON_COMPLETED:
		push_error("Completed dungeon must transition immediately into return travel.")
		debug_log.record_tick(completed_tick)
		return
	if hero_state.loop_state == HeroState.DEAD_RESPAWNING and dungeon_runner.owns_respawn_state():
		advance_dungeon_respawn_tick(completed_tick)
		return
	if hero_state.loop_state == HeroState.RECOVERING_IN_CITY and dungeon_runner.owns_respawn_state():
		advance_dungeon_city_recovery_tick(completed_tick)
		return
	if hero_state.loop_state == HeroState.DOING_QUEST or hero_state.loop_state == HeroState.DOING_DUNGEON:
		return
	if hero_state.loop_state == HeroState.CHOOSING_QUEST and not choose_next_quest():
		debug_log.record_event(completed_tick, "%s не нашёл подходящего квеста." % hero_state.hero_name)
		return
	var event = quest_runner.advance(hero_state, combat_stats)
	if event == null:
		debug_log.record_tick(completed_tick)
		begin_pending_event_if_ready(completed_tick)
		return
	refresh_finished_quest_offer_if_needed(event, completed_tick)
	debug_log.record_event(completed_tick, quest_narrator.describe(event))
	begin_pending_event_if_ready(completed_tick)

func begin_pending_event_if_ready(completed_tick: int) -> bool:
	if not temporary_events_enabled or pending_event_instance == null or event_runner.active_event != null:
		return false
	var event_instance = pending_event_instance
	pending_event_instance = null
	if not event_system.get_active_events().has(event_instance) or not event_system.engage(event_instance):
		return false
	var result: Dictionary = event_runner.begin(hero_state, event_instance)
	if result.is_empty():
		return false
	debug_log.record_event(completed_tick, event_narrator.describe_started(event_instance))
	return true

func advance_event_tick(completed_tick: int) -> void:
	var result: Dictionary = event_runner.advance(hero_state)
	if result.is_empty():
		debug_log.record_tick(completed_tick)
		return
	var result_type: String = str(result.get("type", ""))
	if result_type == "stage_progress":
		if bool(result.get("stage_started", false)):
			debug_log.record_event(completed_tick, event_narrator.describe_stage(result["event_instance"], result["stage"], int(result.get("ticks_remaining", 0))))
		else:
			debug_log.record_tick(completed_tick)
		return
	if result_type == "scene_completed":
		debug_log.record_event(completed_tick, event_narrator.describe_stage(result["event_instance"], result["stage"]))
		return
	if result_type == "formative_decision":
		debug_log.record_event(completed_tick, event_narrator.describe_formative_decision(result))
		return
	if result_type == "expressive_trait_check":
		debug_log.record_event(completed_tick, event_narrator.describe_trait_check(result))
		return
	if result_type != "event_completed":
		debug_log.record_tick(completed_tick)
		return

	var event_instance = result["event_instance"]
	var end_stage = result["stage"]
	var event_name: String = event_instance.definition.display_name
	if end_stage.gold_reward > 0:
		hero_state.gold += end_stage.gold_reward
	if end_stage.equipment_reward_source != null:
		var previous_max_hp: float = combat_stats.max_hp
		var reward_result: Dictionary = equipment_reward_system.resolve_authored_source_reward(
			hero_state,
			end_stage.equipment_reward_source,
			event_resolution_rng,
			end_stage.equipment_rarity_override
		)
		assert(reward_result.get("item_instance") != null, "Authored event equipment reward must produce one item.")
		finalize_item_reward(reward_result, completed_tick, previous_max_hp)
	debug_log.record_event(completed_tick, event_narrator.describe_completed(hero_state.hero_name, event_name, end_stage))
	assert(event_system.complete_instance(event_instance, end_stage.outcome_id), "Completed event must release its world activity.")
	assert(event_runner.finish_success(hero_state), "Completed event must restore the interrupted hero activity.")

func advance_event_respawn_tick(completed_tick: int) -> void:
	var result: Dictionary = event_runner.advance_respawn(hero_state, combat_stats)
	if result.is_empty():
		debug_log.record_tick(completed_tick)
		return
	if str(result.get("type", "")) == "resurrected":
		debug_log.record_event(completed_tick, event_narrator.describe_resurrected(hero_state.hero_name, str(result.get("event_name", "")), hero_state.current_hp))
	else:
		debug_log.record_event(completed_tick, event_narrator.describe_waiting_for_resurrection(hero_state.hero_name, str(result.get("event_name", "")), event_runner.respawn_ticks_remaining))

func advance_event_city_recovery_tick(completed_tick: int) -> void:
	var result: Dictionary = event_runner.advance_city_recovery(hero_state, combat_stats)
	if result.is_empty():
		debug_log.record_tick(completed_tick)
		return
	debug_log.record_event(completed_tick, event_narrator.describe_city_recovery(hero_state.hero_name, hero_state.current_hp, combat_stats.max_hp, bool(result.get("fully_recovered", false))))

func advance_market_sale_tick(completed_tick: int) -> Dictionary:
	var empty_result: Dictionary = {
		"sold_items": [],
		"sold_count": 0,
		"gold_gained": 0,
	}
	if hero_state.loop_state != HeroState.VISITING_MARKET:
		return empty_result
	var result: Dictionary = equipment_sale_system.sell_ordinary_inventory(hero_state)
	hero_state.loop_state = HeroState.SHOPPING
	if result["sold_count"] > 0:
		debug_log.record_event(completed_tick, "Рынок: продано предметов: %d, получено +%d золота." % [result["sold_count"], result["gold_gained"]])
	else:
		debug_log.record_event(completed_tick, "%s посетил рынок, но продавать было нечего." % hero_state.hero_name)
	return result

func advance_shop_purchase_tick(completed_tick: int) -> Dictionary:
	var empty_result: Dictionary = {
		"purchased": false,
		"item_instance": null,
		"price_paid": 0,
		"replaced_item": null,
		"replaced_item_sale_value": 0,
		"power_gain": 0.0,
	}
	if hero_state.loop_state != HeroState.SHOPPING:
		return empty_result

	debug_log.record_event(completed_tick, get_shop_stock_debug_text())
	var equipment_gold_budget: int = get_equipment_purchase_gold_budget()
	var purchase_listings: Array = get_equipment_purchase_listings_with_dungeon_prep_safety()
	var best_purchase: Dictionary = spending_evaluator.select_best_equipment_purchase(hero_state, purchase_listings, equipment_gold_budget)
	if best_purchase.is_empty():
		debug_log.record_event(completed_tick, "%s осмотрел магазин, но достаточно выгодных покупок не нашёл." % hero_state.hero_name)
		finish_shopping_phase(completed_tick)
		return empty_result

	var previous_max_hp: float = combat_stats.max_hp
	var result: Dictionary = shop_system.purchase_listing(
		hero_state,
		int(best_purchase["listing_index"]),
		str(best_purchase.get("target_slot", ""))
	)
	if not bool(result.get("purchased", false)):
		debug_log.record_event(completed_tick, "%s не смог завершить выбранную покупку." % hero_state.hero_name)
		finish_shopping_phase(completed_tick)
		return result

	refresh_combat_stats()
	hero_state.current_hp = clampf(hero_state.current_hp + (combat_stats.max_hp - previous_max_hp), 0.0, combat_stats.max_hp)
	result["power_gain"] = float(best_purchase.get("power_gain", 0.0))
	var purchased_item = result["item_instance"]
	var log_text: String
	if str(best_purchase.get("comparison_mode", "")) == "belt_utility":
		log_text = "%s купил «%s» (%s, ilvl %d) за %d золота; пояс теперь поддерживает до %.0f HP лечения." % [
			hero_state.hero_name,
			purchased_item.definition.display_name,
			purchased_item.get_quality_display_name(),
			purchased_item.item_level,
			result["price_paid"],
			float(best_purchase.get("candidate_belt_healing", 0.0)),
		]
	else:
		log_text = "%s купил «%s» (%s, ilvl %d) за %d золота; сила героя +%.2f." % [
			hero_state.hero_name,
			purchased_item.definition.display_name,
			purchased_item.get_quality_display_name(),
			purchased_item.item_level,
			result["price_paid"],
			result["power_gain"],
		]
	if result["replaced_item"] != null:
		log_text += " Старый предмет «%s» сразу продан за %d золота." % [result["replaced_item"].definition.display_name, result["replaced_item_sale_value"]]
	debug_log.record_event(completed_tick, log_text)

	if spending_evaluator.select_best_equipment_purchase(
		hero_state,
		get_equipment_purchase_listings_with_dungeon_prep_safety(),
		get_equipment_purchase_gold_budget()
	).is_empty():
		finish_shopping_phase(completed_tick)
	return result

func get_equipment_purchase_listings_with_dungeon_prep_safety() -> Array:
	var listings: Array = shop_system.get_listings().duplicate(true)
	if dungeon_system == null or shop_system == null:
		return listings
	var current_region_id: String = get_current_region_id()
	if current_region_id.is_empty():
		return listings
	var current_hero_power: float = get_hero_power()
	var has_power_ready_dungeon: bool = false
	for candidate in dungeon_system.get_discovered_dungeons_in_region(current_region_id):
		if bool(dungeon_evaluator.evaluate_retry_readiness(candidate, current_hero_power).get("ready", false)):
			has_power_ready_dungeon = true
			break
	if not has_power_ready_dungeon:
		return listings

	var potion_definitions: Array = shop_system.get_healing_potion_definitions()
	for listing_index in listings.size():
		var listing: Dictionary = listings[listing_index]
		var item_instance = listing.get("item_instance")
		if item_instance == null or item_instance.definition == null or item_instance.definition.equipment_slot != "belt":
			continue
		var price: int = shop_system.item_price_calculator.get_reference_shop_value_for_item(item_instance)
		if price < 0 or price > hero_state.gold:
			continue
		var remaining_gold: int = hero_state.gold - price
		var candidate_plan: Dictionary = potion_preparation_system.get_full_loadout_plan(
			hero_state,
			potion_definitions,
			item_instance,
			remaining_gold
		)
		if bool(candidate_plan.get("can_prepare", false)):
			continue
		listings[listing_index] = {"item_instance": null}
	return listings

func get_equipment_purchase_gold_budget() -> int:
	var plan: Dictionary = get_ready_dungeon_potion_plan()
	if plan.is_empty() or not bool(plan.get("can_prepare", false)):
		return hero_state.gold
	return maxi(0, hero_state.gold - int(plan.get("purchase_cost", 0)))

func get_ready_dungeon_potion_plan() -> Dictionary:
	if dungeon_system == null or shop_system == null:
		return {}
	var current_region_id: String = get_current_region_id()
	if current_region_id.is_empty():
		return {}
	var current_hero_power: float = get_hero_power()
	for candidate in dungeon_system.get_discovered_dungeons_in_region(current_region_id):
		var readiness: Dictionary = dungeon_evaluator.evaluate_retry_readiness(candidate, current_hero_power)
		if not bool(readiness.get("ready", false)):
			continue
		var plan: Dictionary = potion_preparation_system.get_full_loadout_plan(hero_state, shop_system.get_healing_potion_definitions())
		plan["dungeon"] = candidate
		return plan
	return {}

func finish_shopping_phase(completed_tick: int) -> void:
	if try_start_discovered_dungeon_trip(completed_tick):
		return
	hero_state.loop_state = HeroState.CHOOSING_QUEST

func try_start_discovered_dungeon_trip(completed_tick: int) -> bool:
	if dungeon_system == null or dungeon_runner == null:
		return false
	var current_region_id: String = get_current_region_id()
	if current_region_id.is_empty():
		return false
	var candidates: Array = dungeon_system.get_discovered_dungeons_in_region(current_region_id)
	if candidates.is_empty():
		return false
	var current_hero_power: float = get_hero_power()
	var first_blocked_readiness: Dictionary = {}
	var first_blocked_dungeon = null
	var first_potion_blocked_plan: Dictionary = {}
	var first_potion_blocked_dungeon = null
	for candidate in candidates:
		var readiness: Dictionary = dungeon_evaluator.evaluate_retry_readiness(candidate, current_hero_power)
		if bool(readiness.get("ready", false)):
			var preparation_plan: Dictionary = potion_preparation_system.get_full_loadout_plan(hero_state, shop_system.get_healing_potion_definitions())
			if not bool(preparation_plan.get("can_prepare", false)):
				if first_potion_blocked_plan.is_empty():
					first_potion_blocked_plan = preparation_plan
					first_potion_blocked_dungeon = candidate
				continue
			if int(preparation_plan.get("purchase_cost", 0)) > 0:
				pending_dungeon_preparation = candidate
				hero_state.loop_state = HeroState.PREPARING_DUNGEON
				debug_log.record_event(
					completed_tick,
					dungeon_narrator.describe_potion_purchase_started(
						hero_state.hero_name,
						candidate.definition.display_name,
						int(preparation_plan.get("purchase_cost", 0))
					)
				)
				return true
			var preparation: Dictionary = potion_preparation_system.prepare_full_loadout(hero_state, shop_system.get_healing_potion_definitions())
			if not begin_prepared_dungeon_trip(candidate, current_hero_power, preparation, completed_tick):
				continue
			return true
		if first_blocked_readiness.is_empty() and str(readiness.get("reason", "")) == "retry_power_too_low":
			first_blocked_readiness = readiness
			first_blocked_dungeon = candidate
	if first_blocked_dungeon != null:
		debug_log.record_event(
			completed_tick,
			dungeon_narrator.describe_retry_postponed(
				hero_state.hero_name,
				first_blocked_dungeon.definition.display_name,
				float(first_blocked_readiness.get("current_power", current_hero_power)),
				float(first_blocked_readiness.get("required_power", 0.0))
			)
			)
	elif first_potion_blocked_dungeon != null:
		debug_log.record_event(
			completed_tick,
			dungeon_narrator.describe_potion_postponed(
				hero_state.hero_name,
				first_potion_blocked_dungeon.definition.display_name,
				str(first_potion_blocked_plan.get("reason", "")),
				int(first_potion_blocked_plan.get("capacity", 0))
			)
			)
	return false

func advance_dungeon_potion_purchase_tick(completed_tick: int) -> Dictionary:
	if hero_state.loop_state != HeroState.PREPARING_DUNGEON or pending_dungeon_preparation == null:
		return {}
	var dungeon = pending_dungeon_preparation
	var current_hero_power: float = get_hero_power()
	var readiness: Dictionary = dungeon_evaluator.evaluate_retry_readiness(dungeon, current_hero_power)
	if not bool(readiness.get("ready", false)):
		if str(readiness.get("reason", "")) == "retry_power_too_low":
			debug_log.record_event(
				completed_tick,
				dungeon_narrator.describe_retry_postponed(
					hero_state.hero_name,
					dungeon.definition.display_name,
					float(readiness.get("current_power", current_hero_power)),
					float(readiness.get("required_power", 0.0))
				)
			)
		pending_dungeon_preparation = null
		hero_state.loop_state = HeroState.CHOOSING_QUEST
		return readiness

	var preparation: Dictionary = potion_preparation_system.prepare_full_loadout(hero_state, shop_system.get_healing_potion_definitions())
	if not bool(preparation.get("can_prepare", false)):
		debug_log.record_event(
			completed_tick,
			dungeon_narrator.describe_potion_postponed(
				hero_state.hero_name,
				dungeon.definition.display_name,
				str(preparation.get("reason", "")),
				int(preparation.get("capacity", 0))
			)
		)
		pending_dungeon_preparation = null
		hero_state.loop_state = HeroState.CHOOSING_QUEST
		return preparation

	if not begin_prepared_dungeon_trip(dungeon, current_hero_power, preparation, completed_tick):
		pending_dungeon_preparation = null
		hero_state.loop_state = HeroState.CHOOSING_QUEST
	return preparation

func begin_prepared_dungeon_trip(dungeon, current_hero_power: float, preparation: Dictionary, completed_tick: int) -> bool:
	if dungeon == null or not bool(preparation.get("can_prepare", false)):
		return false
	if not dungeon_runner.begin_trip(hero_state, dungeon, current_hero_power):
		return false
	pending_dungeon_preparation = null
	debug_log.record_event(completed_tick, dungeon_narrator.describe_potion_prepared(hero_state.hero_name, dungeon.definition.display_name, preparation))
	debug_log.record_event(completed_tick, "%s закончил дела в городе и отправился в данж «%s»." % [hero_state.hero_name, dungeon.definition.display_name])
	return true

func advance_dungeon_travel_tick(completed_tick: int) -> void:
	var result: Dictionary = dungeon_runner.advance(hero_state)
	if result.is_empty():
		debug_log.record_tick(completed_tick)
		return
	if hero_state.loop_state == HeroState.AT_DUNGEON_ENTRANCE:
		debug_log.record_event(completed_tick, "%s прибыл ко входу в данж «%s»." % [hero_state.hero_name, dungeon_runner.active_dungeon.definition.display_name])
		assert(dungeon_runner.enter(hero_state), "Arrival at a valid active dungeon must begin the expedition without an extra world-tick delay.")
	else:
		debug_log.record_event(completed_tick, "%s идёт к данжу «%s». Осталось гексов: %d." % [hero_state.hero_name, dungeon_runner.active_dungeon.definition.display_name, int(result.get("remaining_steps", 0))])

func advance_dungeon_between_fights_tick(completed_tick: int) -> void:
	var next_is_boss: bool = dungeon_runner.active_dungeon != null \
		and dungeon_runner.ordinary_encounters_completed >= dungeon_runner.active_dungeon.definition.ordinary_encounter_count
	var potion_result: Dictionary = potion_preparation_system.use_between_fight_potions(
		hero_state,
		combat_stats.max_hp,
		next_is_boss,
		shop_system.get_healing_potion_definitions()
	)
	var result: Dictionary = dungeon_runner.advance_between_fights(hero_state)
	if result.is_empty():
		debug_log.record_tick(completed_tick)
		return
	debug_log.record_event(
		completed_tick,
			dungeon_narrator.describe_between_fights(
				hero_state.hero_name,
				hero_state.current_hp,
				combat_stats.max_hp,
				bool(result.get("next_is_boss", false)),
				potion_result
			)
	)

func advance_dungeon_return_tick(completed_tick: int) -> void:
	var dungeon_name: String = dungeon_runner.active_dungeon.definition.display_name
	var result: Dictionary = dungeon_runner.advance_return_to_city(hero_state)
	if result.is_empty():
		debug_log.record_tick(completed_tick)
		return
	if bool(result.get("arrived", false)):
		debug_log.record_event(completed_tick, dungeon_narrator.describe_returned_to_city(hero_state.hero_name, dungeon_name))
	else:
		debug_log.record_event(completed_tick, dungeon_narrator.describe_returning_to_city(hero_state.hero_name, dungeon_name, int(result.get("remaining_steps", 0))))

func advance_dungeon_respawn_tick(completed_tick: int) -> void:
	var result: Dictionary = dungeon_runner.advance_respawn(hero_state, combat_stats)
	if result.is_empty():
		debug_log.record_tick(completed_tick)
		return
	if str(result.get("type", "")) == "resurrected":
		debug_log.record_event(completed_tick, dungeon_narrator.describe_resurrected(hero_state.hero_name, hero_state.current_hp))
	else:
		debug_log.record_event(completed_tick, dungeon_narrator.describe_waiting_for_resurrection(hero_state.hero_name, dungeon_runner.respawn_ticks_remaining))

func advance_dungeon_city_recovery_tick(completed_tick: int) -> void:
	var result: Dictionary = dungeon_runner.advance_city_recovery(hero_state, combat_stats)
	if result.is_empty():
		debug_log.record_tick(completed_tick)
		return
	debug_log.record_event(
		completed_tick,
		dungeon_narrator.describe_city_recovery(
			hero_state.hero_name,
			hero_state.current_hp,
			combat_stats.max_hp,
			bool(result.get("fully_recovered", false))
		)
	)

func get_shop_stock_debug_text() -> String:
	var white_slots: Array[String] = []
	var green_slots: Array[String] = []
	for listing in shop_system.get_listings():
		var item_instance = listing.get("item_instance")
		if item_instance == null or item_instance.definition == null:
			continue
		var slot_name: String = get_shop_slot_debug_name(item_instance.definition.equipment_slot)
		if item_instance.rarity == 1:
			green_slots.append(slot_name)
		else:
			white_slots.append(slot_name)
	var white_text: String = ", ".join(white_slots) if not white_slots.is_empty() else "нет"
	var green_text: String = ", ".join(green_slots) if not green_slots.is_empty() else "нет"
	return "Магазин: белые — %s; зелёные — %s." % [white_text, green_text]

func get_shop_slot_debug_name(equipment_slot: String) -> String:
	match equipment_slot:
		"helmet": return "шлем"
		"chest": return "нагрудник"
		"gloves": return "перчатки"
		"pants": return "штаны"
		"boots": return "сапоги"
		"weapon": return "меч"
		"shield": return "щит"
		"necklace": return "ожерелье"
		"earrings": return "серьги"
		"ring_1": return "кольцо 1"
		"ring_2": return "кольцо 2"
		"belt": return "пояс"
	return equipment_slot

func resolve_mob_equipment_drop(mob_definition: Resource, completed_tick: int, rng_override = null) -> Dictionary:
	var rng = rng_override if rng_override != null else seeded_rng.get_rng()
	var previous_max_hp: float = combat_stats.max_hp
	var result: Dictionary = equipment_reward_system.resolve_mob_equipment_drop(hero_state, mob_definition, rng)
	return finalize_item_reward(result, completed_tick, previous_max_hp)

func receive_item_reward(item_definition: Resource, completed_tick: int = 0, item_level: int = 5, rng_override = null, rarity_override: int = -1) -> Dictionary:
	var rng = rng_override if rng_override != null else seeded_rng.get_rng()
	var previous_max_hp: float = combat_stats.max_hp
	var result: Dictionary = equipment_reward_system.receive_item(hero_state, item_definition, item_level, rng, rarity_override)
	return finalize_item_reward(result, completed_tick, previous_max_hp)

func finalize_item_reward(result: Dictionary, completed_tick: int, previous_max_hp: float) -> Dictionary:
	var item_instance = result.get("item_instance")
	if item_instance == null:
		return result
	if bool(result.get("equipped", false)):
		refresh_combat_stats()
		hero_state.current_hp = clampf(hero_state.current_hp + (combat_stats.max_hp - previous_max_hp), 0.0, combat_stats.max_hp)
		debug_log.record_event(completed_tick, "%s получил «%s» (%s, ilvl %d) и надел предмет." % [hero_state.hero_name, item_instance.definition.display_name, item_instance.get_quality_display_name(), item_instance.item_level])
	else:
		debug_log.record_event(completed_tick, "%s получил «%s» (%s, ilvl %d) и убрал предмет в инвентарь." % [hero_state.hero_name, item_instance.definition.display_name, item_instance.get_quality_display_name(), item_instance.item_level])

	if result.get("dropped_item") != null:
		var dropped_instance = result["dropped_item"]
		debug_log.record_event(completed_tick, "Инвентарь переполнен: самый старый предмет «%s» (%s) выпал." % [dropped_instance.definition.display_name, dropped_instance.get_quality_display_name()])
	return result

func get_active_respawn_owner():
	if event_runner != null and event_runner.owns_respawn_state():
		return event_runner
	if dungeon_runner != null and dungeon_runner.owns_respawn_state():
		return dungeon_runner
	return quest_runner

func get_respawn_ticks_remaining() -> int:
	var respawn_owner = get_active_respawn_owner()
	if respawn_owner == null:
		return 0
	return int(respawn_owner.respawn_ticks_remaining)

func use_instant_resurrection() -> bool:
	var event_respawn_active: bool = event_runner != null and event_runner.owns_respawn_state()
	var dungeon_respawn_active: bool = dungeon_runner != null and dungeon_runner.owns_respawn_state()
	var result: Dictionary = god_system.use_instant_resurrection(hero_state, get_active_respawn_owner(), combat_stats)
	var event = result.get("event")
	if event != null:
		if event_respawn_active:
			debug_log.record_event(world_clock.world_tick, event_narrator.describe_resurrected(hero_state.hero_name, str(event.get("event_name", "")), hero_state.current_hp))
		elif dungeon_respawn_active:
			debug_log.record_event(world_clock.world_tick, dungeon_narrator.describe_resurrected(hero_state.hero_name, hero_state.current_hp))
		else:
			debug_log.record_event(world_clock.world_tick, quest_narrator.describe(event))
	return bool(result.get("succeeded", false))

func use_divine_healing() -> bool:
	return god_system.use_divine_healing(hero_state, combat_stats, active_combat_session)

func use_combat_buff() -> bool:
	if not god_system.use_combat_buff(hero_state):
		return false
	refresh_combat_stats()
	return true

func get_combat_buff_fights_remaining() -> int:
	return god_system.get_combat_buff_fights_remaining(hero_state)

func consume_combat_buff_fight() -> void:
	if not god_system.consume_combat_buff_fight(hero_state):
		return
	refresh_combat_stats()

func guide_hero_to_quest(quest_id: String) -> bool:
	var available_quests: Array = [] if quest_pool == null else quest_pool.get_available_quests()
	return god_system.guide_hero_to_quest(quest_id, autonomous_quest_choice, available_quests)

func get_current_region_id() -> String:
	if hex_map == null or world_state == null:
		return ""
	var current_hex = hex_map.get_hex(world_state.hero_position)
	return "" if current_hex == null else current_hex.region_id

func has_unknown_dungeon_in_current_region() -> bool:
	if dungeon_system == null:
		return false
	return not dungeon_system.get_unknown_dungeons_in_region(get_current_region_id()).is_empty()

func use_divine_vision() -> bool:
	var revealed_dungeon = god_system.use_vision(dungeon_system, get_current_region_id(), dungeon_vision_rng)
	if revealed_dungeon == null:
		return false
	record_dungeon_discovery(revealed_dungeon, "Божественное видение открыло")
	return true

func on_hero_position_changed(cell: Vector2i) -> void:
	if dungeon_system != null:
		for discovered_dungeon in dungeon_system.discover_at_hex(cell):
			record_dungeon_discovery(discovered_dungeon, "%s обнаружил" % hero_state.hero_name)
	if not temporary_events_enabled or event_system == null or event_runner == null:
		return
	if pending_event_instance != null or event_runner.active_event != null:
		return
	if hero_state.loop_state != HeroState.TRAVEL_TO_QUEST and hero_state.loop_state != HeroState.RETURNING_TO_CITY:
		return
	pending_event_instance = event_system.find_encounter_at_hex(cell)

func record_dungeon_discovery(dungeon_instance, prefix: String) -> void:
	if dungeon_instance == null or dungeon_instance.definition == null:
		return
	debug_log.record_event(world_clock.world_tick, "%s данж «%s»." % [prefix, dungeon_instance.definition.display_name])

func refresh_finished_quest_offer_if_needed(event, completed_tick: int) -> void:
	if not autonomous_quest_choice:
		return
	quest_pool.handle_quest_event(event, hero_state.loop_state, completed_tick)
