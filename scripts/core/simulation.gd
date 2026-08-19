class_name Simulation
extends RefCounted

const WorldClockScript = preload("res://scripts/core/world_clock.gd")
const HeroNameRepositoryScript = preload("res://scripts/core/hero_name_repository.gd")
const HeroStateScript = preload("res://scripts/hero/hero_state.gd")
const StatResolverScript = preload("res://scripts/hero/stat_resolver.gd")
const PowerCalculatorScript = preload("res://scripts/combat/power_calculator.gd")
const CombatSimulatorScript = preload("res://scripts/combat/combat_simulator.gd")
const DebugLogScript = preload("res://scripts/narrative/debug_log.gd")
const DiaryScript = preload("res://scripts/narrative/diary.gd")
const QuestNarratorScript = preload("res://scripts/narrative/quest_narrator.gd")
const QuestRunnerScript = preload("res://scripts/quests/quest_runner.gd")
const InitialQuest = preload("res://data/quests/0001_goblin_road_problem.tres")
const TIME_EPSILON: float = 0.000001

var world_clock = WorldClockScript.new()
var debug_log = DebugLogScript.new()
var diary = DiaryScript.new()
var quest_narrator = QuestNarratorScript.new()
var time_scale: float = 1.0
var hero_state
var combat_stats
var active_combat_session
var skip_quest_advance_on_completed_combat_tick: bool = false

var stat_resolver = StatResolverScript.new()
var power_calculator = PowerCalculatorScript.new()
var combat_simulator = CombatSimulatorScript.new()
var quest_runner = QuestRunnerScript.new(InitialQuest)

func _init() -> void:
	var name_repository = HeroNameRepositoryScript.new()
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

func start_combat() -> void:
	active_combat_session = combat_simulator.create_session(combat_stats, quest_runner.get_current_mob_stats())
	debug_log.record_combat_event(quest_narrator.describe_combat_started(hero_state.hero_name, quest_runner.quest_definition, quest_runner.get_next_mob_number(), quest_runner.quest_definition.mob_count))

func advance_active_combat(available_seconds: float) -> float:
	var previous_elapsed_seconds: float = active_combat_session.elapsed_seconds
	var actions = active_combat_session.advance(available_seconds)
	for action in actions:
		debug_log.record_combat_event(quest_narrator.describe_combat_action(action, hero_state.hero_name, quest_runner.quest_definition))
	var consumed_seconds: float = active_combat_session.elapsed_seconds - previous_elapsed_seconds
	if active_combat_session.is_finished:
		var combat_result = active_combat_session.get_result()
		active_combat_session = null
		var event = quest_runner.complete_fight(hero_state, combat_stats, combat_result)
		if event == null:
			debug_log.record_combat_event("Герой погиб. Смерть и возвращение в город ещё не реализованы.")
		else:
			debug_log.record_combat_event(quest_narrator.describe(event))
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
