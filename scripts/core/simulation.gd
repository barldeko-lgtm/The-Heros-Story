class_name Simulation
extends RefCounted

const WorldClockScript = preload("res://scripts/core/world_clock.gd")
const HeroNameRepositoryScript = preload("res://scripts/core/hero_name_repository.gd")
const HeroStateScript = preload("res://scripts/hero/hero_state.gd")
const StatResolverScript = preload("res://scripts/hero/stat_resolver.gd")
const PowerCalculatorScript = preload("res://scripts/combat/power_calculator.gd")
const DebugLogScript = preload("res://scripts/narrative/debug_log.gd")
const DiaryScript = preload("res://scripts/narrative/diary.gd")

var world_clock = WorldClockScript.new()
var debug_log = DebugLogScript.new()
var diary = DiaryScript.new()
var time_scale: float = 1.0
var hero_state
var combat_stats

var stat_resolver = StatResolverScript.new()
var power_calculator = PowerCalculatorScript.new()

func _init() -> void:
	var name_repository = HeroNameRepositoryScript.new()
	hero_state = HeroStateScript.new(name_repository.get_random_name())
	refresh_combat_stats()
	hero_state.current_hp = combat_stats.max_hp
	world_clock.tick_completed.connect(on_world_tick_completed)

func advance_time(delta_seconds: float) -> void:
	world_clock.advance_time(delta_seconds * time_scale)

func set_time_scale(new_time_scale: float) -> void:
	time_scale = new_time_scale

func refresh_combat_stats() -> void:
	combat_stats = stat_resolver.resolve(hero_state)

func get_hero_power() -> float:
	return power_calculator.calculate(combat_stats)

func on_world_tick_completed(completed_tick: int) -> void:
	debug_log.record_tick(completed_tick)
