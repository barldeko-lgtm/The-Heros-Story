extends SceneTree

const Selection = preload("res://scripts/dungeons/dungeon_trip_selection.gd")

class Readiness:
	extends RefCounted
	var seen: Array = []
	func evaluate_retry_readiness(candidate, _power: float) -> Dictionary:
		seen.append(candidate)
		return candidate

class Preparation:
	extends RefCounted
	var calls: int = 0
	var allowed: bool = true
	func get_full_loadout_plan(_hero, _definitions: Array) -> Dictionary:
		calls += 1
		return {"can_prepare": allowed, "purchase_cost": 0}

class FailFirstRunner:
	extends RefCounted
	var calls: Array = []
	var actual
	func _init(runner) -> void:
		actual = runner
	func begin_trip(hero, dungeon, power: float) -> bool:
		calls.append(dungeon)
		return false if calls.size() == 1 else actual.begin_trip(hero, dungeon, power)

func _init() -> void:
	var ready := {"ready": true, "id": "a"}
	var second := {"ready": true, "id": "b"}
	var blocked := {"ready": false, "reason": "retry_power_too_low"}
	var invalid := {"ready": false, "reason": "invalid_or_completed"}
	var evaluator = Readiness.new()
	var preparation = Preparation.new()
	var selection = Selection.new([blocked, ready, second], null, 100.0, evaluator, preparation, [])
	assert(selection.select_next().dungeon == ready)
	assert(evaluator.seen.size() == 2 and preparation.calls == 1, "Selection must stop at the first ready candidate.")
	assert(selection.select_next().dungeon == second, "A failed launch must allow the next candidate.")
	assert(selection.select_next().is_empty())
	assert(selection.get_blocked_reason().kind == "power")
	assert(Selection.find_power_ready([invalid, blocked, second], 100.0, evaluator) == second)
	preparation.allowed = false
	selection = Selection.new([ready, blocked], null, 100.0, evaluator, preparation, [])
	assert(selection.select_next().is_empty())
	assert(selection.get_blocked_reason().kind == "power", "Power refusal retains explanation priority over potion refusal.")
	selection = Selection.new([invalid, ready], null, 100.0, evaluator, preparation, [])
	assert(selection.select_next().is_empty())
	assert(selection.get_blocked_reason().kind == "potions")
	selection = Selection.new([], null, 100.0, evaluator, preparation, [])
	assert(selection.select_next().is_empty() and selection.get_blocked_reason().is_empty())
	# Real Simulation integration: a failed first launch must still try the second.
	var simulation = load("res://scripts/core/simulation.gd").new(9160, null)
	var candidates: Array = simulation.dungeon_system.get_all_dungeons()
	for dungeon in candidates:
		dungeon.discover("test")
	var belt = simulation.item_generator.generate(load("res://data/items/visual_families/ironward_vanguard/ironward_belt.tres"), 5, RandomNumberGenerator.new())
	simulation.hero_state.equipment.replace_item(belt)
	simulation.hero_state.inventory.add_healing_potion(5)
	simulation.hero_state.gold = 0
	var runner = FailFirstRunner.new(simulation.dungeon_runner)
	simulation.dungeon_runner = runner
	var tick: int = simulation.world_clock.world_tick
	assert(simulation.try_start_discovered_dungeon_trip(tick))
	assert(runner.calls.size() == 2 and runner.calls[0] != runner.calls[1])
	assert(simulation.world_clock.world_tick == tick and simulation.hero_state.gold == 0)
	assert(simulation.hero_state.loop_state == HeroState.TRAVEL_TO_DUNGEON)
	assert(simulation.hero_state.inventory.get_healing_potion_count(5) == 1)
	print("PASS: Ordered lazy selection, refusal priority, empty/invalid candidates and real failed-launch fallback without extra time/spending.")
	quit()
