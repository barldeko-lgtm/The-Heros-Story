class_name Simulation
extends RefCounted

const WorldClockScript = preload("res://scripts/core/world_clock.gd")
const SeededRngScript = preload("res://scripts/core/seeded_rng.gd")
const HeroNameRepositoryScript = preload("res://scripts/core/hero_name_repository.gd")
const HeroStateScript = preload("res://scripts/hero/hero_state.gd")
const HeroProgressionScript = preload("res://scripts/hero/hero_progression.gd")
const StatResolverScript = preload("res://scripts/hero/stat_resolver.gd")
const PowerCalculatorScript = preload("res://scripts/combat/power_calculator.gd")
const CombatSimulatorScript = preload("res://scripts/combat/combat_simulator.gd")
const DebugLogScript = preload("res://scripts/narrative/debug_log.gd")
const DiaryScript = preload("res://scripts/narrative/diary.gd")
const QuestNarratorScript = preload("res://scripts/narrative/quest_narrator.gd")
const QuestRunnerScript = preload("res://scripts/quests/quest_runner.gd")
const DefaultInitialQuest = preload("res://data/quests/0001_goblin_road_problem.tres")
const TIME_EPSILON: float = 0.000001
const DEFAULT_SIMULATION_SEED: int = 1

var world_clock = WorldClockScript.new()
var debug_log = DebugLogScript.new()
var diary = DiaryScript.new()
var quest_narrator = QuestNarratorScript.new()
var time_scale: float = 1.0
var simulation_seed: int = DEFAULT_SIMULATION_SEED
var seeded_rng
var hero_state
var combat_stats
var active_combat_session
var skip_quest_advance_on_completed_combat_tick: bool = false

var hero_progression = HeroProgressionScript.new()
var stat_resolver = StatResolverScript.new()
var power_calculator = PowerCalculatorScript.new()
var combat_simulator = CombatSimulatorScript.new()
var quest_runner
var combat_results_by_mob: Dictionary = {}

func _init(initial_seed: int = DEFAULT_SIMULATION_SEED, initial_quest_definition: Resource = DefaultInitialQuest) -> void:
	quest_runner = QuestRunnerScript.new(initial_quest_definition)
	simulation_seed = initial_seed
	seeded_rng = SeededRngScript.new(simulation_seed)
	var name_repository = HeroNameRepositoryScript.new(seeded_rng.get_rng())
	hero_state = HeroStateScript.new(name_repository.get_random_name())
	refresh_combat_stats()
	hero_state.current_hp = combat_stats.max_hp
	world_clock.tick_completed.connect(on_world_tick_completed)

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
		var seconds_until_next_tick: float = WorldClock.TICK_DURATION_SECONDS - world_clock.elapsed_seconds
		var world_time_step: float = minf(remaining_seconds, seconds_until_next_tick)
		if world_time_step <= TIME_EPSILON:
			return
		world_clock.advance_time(world_time_step)
		remaining_seconds -= world_time_step

func set_time_scale(new_time_scale: float) -> void:
	time_scale = new_time_scale

func refresh_combat_stats() -> void:
	combat_stats = stat_resolver.resolve(hero_state)

func get_hero_power() -> float:
	return power_calculator.calculate(combat_stats)

func get_current_hero_hp() -> float:
	if active_combat_session != null:
		return active_combat_session.hero_remaining_hp
	return hero_state.current_hp

func get_current_opponent_name() -> String:
	if active_combat_session == null:
		return ""
	return quest_runner.quest_definition.mob_definition.display_name

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
	return get_combat_results(quest_runner.quest_definition.mob_definition.id)

func get_active_combat_world_tick() -> int:
	return world_clock.world_tick + 1

func start_combat() -> void:
	active_combat_session = combat_simulator.create_session(combat_stats, quest_runner.get_current_mob_stats(), seeded_rng.get_rng())
	debug_log.record_combat_event(quest_narrator.describe_combat_started(hero_state.hero_name, quest_runner.quest_definition, quest_runner.get_next_mob_number(), quest_runner.quest_definition.mob_count), get_active_combat_world_tick())

func advance_active_combat(available_seconds: float) -> float:
	var previous_elapsed_seconds: float = active_combat_session.elapsed_seconds
	var actions = active_combat_session.advance(available_seconds)
	for action in actions:
		debug_log.record_combat_event(quest_narrator.describe_combat_action(action, hero_state.hero_name, quest_runner.quest_definition), get_active_combat_world_tick())
	var consumed_seconds: float = active_combat_session.elapsed_seconds - previous_elapsed_seconds
	if active_combat_session.is_finished:
		var combat_result = active_combat_session.get_result()
		var fought_mob_definition: Resource = quest_runner.quest_definition.mob_definition
		active_combat_session = null
		record_combat_result(fought_mob_definition, combat_result.hero_won)
		var combat_world_tick: int = get_active_combat_world_tick()
		var previous_level: int = hero_state.level
		if combat_result.hero_won:
			hero_progression.add_experience(hero_state, quest_runner.get_current_mob_experience_reward())
			if hero_state.level != previous_level:
				refresh_combat_stats()
		var event = quest_runner.complete_fight(hero_state, combat_stats, combat_result)
		if event != null:
			debug_log.record_combat_event(quest_narrator.describe(event), combat_world_tick)
			if hero_state.level != previous_level:
				debug_log.record_combat_event("%s повысил уровень: %d → %d." % [hero_state.hero_name, previous_level, hero_state.level], combat_world_tick)
		skip_quest_advance_on_completed_combat_tick = true
		world_clock.complete_tick()
	return consumed_seconds

func on_world_tick_completed(completed_tick: int) -> void:
	if skip_quest_advance_on_completed_combat_tick:
		skip_quest_advance_on_completed_combat_tick = false
		return
	if hero_state.loop_state == HeroState.DOING_QUEST:
		return
	var event = quest_runner.advance(hero_state, combat_stats)
	if event == null:
		debug_log.record_tick(completed_tick)
		return
	debug_log.record_event(completed_tick, quest_narrator.describe(event))
