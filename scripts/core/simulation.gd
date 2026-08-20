class_name Simulation
extends RefCounted

const WorldClockScript = preload("res://scripts/core/world_clock.gd")
const SeededRngScript = preload("res://scripts/core/seeded_rng.gd")
const HeroNameRepositoryScript = preload("res://scripts/core/hero_name_repository.gd")
const HeroStateScript = preload("res://scripts/hero/hero_state.gd")
const HeroTraitsScript = preload("res://scripts/hero/hero_traits.gd")
const GodStateScript = preload("res://scripts/god/god_state.gd")
const HeroProgressionScript = preload("res://scripts/hero/hero_progression.gd")
const StatResolverScript = preload("res://scripts/hero/stat_resolver.gd")
const PowerCalculatorScript = preload("res://scripts/combat/power_calculator.gd")
const CombatSimulatorScript = preload("res://scripts/combat/combat_simulator.gd")
const DebugLogScript = preload("res://scripts/narrative/debug_log.gd")
const DiaryScript = preload("res://scripts/narrative/diary.gd")
const QuestNarratorScript = preload("res://scripts/narrative/quest_narrator.gd")
const QuestRunnerScript = preload("res://scripts/quests/quest_runner.gd")
const QuestPoolScript = preload("res://scripts/quests/quest_pool.gd")
const QuestEvaluatorScript = preload("res://scripts/quests/quest_evaluator.gd")

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
var base_combat_stats
var combat_stats
var active_combat_session
var skip_quest_advance_on_completed_combat_tick: bool = false

var hero_progression = HeroProgressionScript.new()
var stat_resolver = StatResolverScript.new()
var power_calculator = PowerCalculatorScript.new()
var combat_simulator = CombatSimulatorScript.new()
var quest_runner
var quest_pool
var quest_evaluator = QuestEvaluatorScript.new()
var god_state
var autonomous_quest_choice: bool = false
var last_quest_selection: Dictionary = {}
var combat_results_by_mob: Dictionary = {}
var pending_quest_offer_replacement

func _init(initial_seed: int = DEFAULT_SIMULATION_SEED, initial_quest_definition: Resource = DefaultInitialQuest, available_quest_definitions: Array = []) -> void:
	autonomous_quest_choice = initial_quest_definition == null
	simulation_seed = initial_seed
	seeded_rng = SeededRngScript.new(simulation_seed)
	god_state = GodStateScript.new()
	var name_repository = HeroNameRepositoryScript.new(seeded_rng.get_rng())
	hero_state = HeroStateScript.new(name_repository.get_random_name())
	hero_state.traits = HeroTraitsScript.roll_starting_traits(seeded_rng.get_rng())
	var runner_initial_quest
	if autonomous_quest_choice:
		quest_pool = QuestPoolScript.new(available_quest_definitions, seeded_rng.get_rng())
	else:
		var fixed_quest_pool = QuestPoolScript.new([initial_quest_definition], seeded_rng.get_rng())
		runner_initial_quest = fixed_quest_pool.create_offer(initial_quest_definition)
	quest_runner = QuestRunnerScript.new(runner_initial_quest)
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
	base_combat_stats = stat_resolver.resolve(hero_state, false)
	combat_stats = stat_resolver.resolve(hero_state, true)

func get_hero_power() -> float:
	return power_calculator.calculate(base_combat_stats)

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
	var hero_damage_multiplier: float = HeroTraitsScript.get_damage_multiplier(hero_state.traits, quest_runner.quest_definition.mob_definition.category)
	active_combat_session = combat_simulator.create_session(combat_stats, quest_runner.get_current_mob_stats(), seeded_rng.get_rng(), hero_damage_multiplier)
	debug_log.record_combat_event(quest_narrator.describe_combat_started(hero_state.hero_name, quest_runner.quest_definition, quest_runner.get_next_mob_number(), quest_runner.quest_definition.mob_count), get_active_combat_world_tick())

func advance_active_combat(available_seconds: float) -> float:
	var previous_elapsed_seconds: float = active_combat_session.elapsed_seconds
	var actions = active_combat_session.advance(available_seconds)
	for action in actions:
		debug_log.record_combat_event(quest_narrator.describe_combat_action(action, hero_state.hero_name, quest_runner.quest_definition), get_active_combat_world_tick())
	var consumed_seconds: float = active_combat_session.elapsed_seconds - previous_elapsed_seconds
	if active_combat_session.is_finished:
		var combat_result = active_combat_session.get_result()
		consume_combat_buff_fight()
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
			refresh_finished_quest_offer_if_needed(event)
			debug_log.record_combat_event(quest_narrator.describe(event), combat_world_tick)
			if hero_state.level != previous_level:
				debug_log.record_combat_event("%s повысил уровень: %d → %d." % [hero_state.hero_name, previous_level, hero_state.level], combat_world_tick)
		skip_quest_advance_on_completed_combat_tick = true
		world_clock.complete_tick()
	return consumed_seconds

func on_world_tick_completed(completed_tick: int) -> void:
	god_state.advance_world_tick()
	if skip_quest_advance_on_completed_combat_tick:
		skip_quest_advance_on_completed_combat_tick = false
		return
	if hero_state.loop_state == HeroState.DOING_QUEST:
		return
	if hero_state.loop_state == HeroState.CHOOSING_QUEST and not choose_next_quest():
		debug_log.record_event(completed_tick, "%s не нашёл подходящего квеста." % hero_state.hero_name)
		return
	var event = quest_runner.advance(hero_state, combat_stats)
	if event == null:
		debug_log.record_tick(completed_tick)
		return
	refresh_finished_quest_offer_if_needed(event)
	debug_log.record_event(completed_tick, quest_narrator.describe(event))

func use_instant_resurrection() -> bool:
	if hero_state.loop_state != HeroState.DEAD_RESPAWNING:
		return false
	if not god_state.try_spend_resurrection(quest_runner.respawn_ticks_remaining):
		return false
	var event = quest_runner.force_resurrection(hero_state, combat_stats)
	if event != null:
		debug_log.record_event(world_clock.world_tick, quest_narrator.describe(event))
	return event != null

func use_divine_healing() -> bool:
	if hero_state.loop_state == HeroState.DEAD_RESPAWNING:
		return false
	var current_hp: float = get_current_hero_hp()
	if current_hp >= combat_stats.max_hp or not god_state.try_activate_healing():
		return false
	var healed_hp: float = minf(combat_stats.max_hp, current_hp + combat_stats.max_hp * 0.50)
	if active_combat_session != null:
		active_combat_session.hero_remaining_hp = healed_hp
	else:
		hero_state.current_hp = healed_hp
	return true

func use_combat_buff() -> bool:
	if not god_state.try_activate_combat_buff(get_combat_buff_fights_remaining() > 0):
		return false
	hero_state.active_effects.append({
		"id": GodStateScript.COMBAT_BUFF_EFFECT_ID,
		"attack_bonus": GodStateScript.COMBAT_BUFF_ATTACK_BONUS,
		"fights_remaining": GodStateScript.COMBAT_BUFF_FIGHTS,
	})
	refresh_combat_stats()
	return true

func get_combat_buff_effect_index() -> int:
	for index in hero_state.active_effects.size():
		if hero_state.active_effects[index].get("id", "") == GodStateScript.COMBAT_BUFF_EFFECT_ID:
			return index
	return -1

func get_combat_buff_fights_remaining() -> int:
	var effect_index := get_combat_buff_effect_index()
	if effect_index < 0:
		return 0
	return int(hero_state.active_effects[effect_index].get("fights_remaining", 0))

func consume_combat_buff_fight() -> void:
	var effect_index := get_combat_buff_effect_index()
	if effect_index < 0:
		return
	var effect: Dictionary = hero_state.active_effects[effect_index]
	effect["fights_remaining"] = maxi(0, int(effect.get("fights_remaining", 0)) - 1)
	if effect["fights_remaining"] <= 0:
		hero_state.active_effects.remove_at(effect_index)
	else:
		hero_state.active_effects[effect_index] = effect
	refresh_combat_stats()

func guide_hero_to_quest(quest_id: String) -> bool:
	if not autonomous_quest_choice:
		return false
	for quest in quest_pool.get_available_quests():
		if quest.id == quest_id:
			return god_state.try_set_quest_guidance(quest_id)
	return false

func refresh_finished_quest_offer_if_needed(event) -> void:
	if not autonomous_quest_choice:
		return
	if event.event_type == QuestEvent.HERO_TURNED_IN_QUEST:
		quest_pool.replace_offer(event.quest_definition)
		return
	if event.event_type == QuestEvent.HERO_DIED:
		pending_quest_offer_replacement = event.quest_definition
		return
	if event.event_type == QuestEvent.HERO_RECOVERING_IN_CITY and hero_state.loop_state == HeroState.CHOOSING_QUEST and pending_quest_offer_replacement != null:
		quest_pool.replace_offer(pending_quest_offer_replacement)
		pending_quest_offer_replacement = null
