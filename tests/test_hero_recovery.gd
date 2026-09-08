extends SceneTree

func _init() -> void:
	var path := "res://scripts/hero/hero_recovery.gd"
	if not ResourceLoader.exists(path):
		printerr("FAIL: shared HeroRecovery rules are missing.")
		quit(1)
		return
	var recovery: Script = load(path)
	var hero = load("res://scripts/hero/hero_state.gd").new("Recovery test")
	var stats = load("res://scripts/model/runtime/combat_stats.gd").new()
	stats.max_hp = 150.0
	hero.loop_state = HeroState.DEAD_RESPAWNING
	var remaining: int = recovery.RESPAWN_DURATION_TICKS
	assert(remaining == 100)
	for tick in range(99):
		remaining = recovery.advance_respawn(hero, stats, remaining)
		assert(remaining == 99 - tick)
		assert(hero.loop_state == HeroState.DEAD_RESPAWNING)
		assert(hero.current_hp == 0.0)
	remaining = recovery.advance_respawn(hero, stats, remaining)
	assert(remaining == 0)
	assert(hero.loop_state == HeroState.RECOVERING_IN_CITY)
	assert(hero.current_hp == 1.0)
	for tick in range(4):
		assert(not recovery.advance_city_recovery(hero, stats))
		assert(hero.loop_state == HeroState.RECOVERING_IN_CITY)
		assert(is_equal_approx(hero.current_hp, 1.0 + 30.0 * (tick + 1)))
	assert(recovery.advance_city_recovery(hero, stats))
	assert(hero.current_hp == stats.max_hp)
	assert(hero.loop_state == HeroState.CHOOSING_QUEST)
	# Instant resurrection shares the HP clamp, including unusually small MaxHP.
	hero.loop_state = HeroState.DEAD_RESPAWNING
	stats.max_hp = 0.5
	recovery.resurrect(hero, stats)
	assert(hero.current_hp == 0.5)
	assert(hero.loop_state == HeroState.RECOVERING_IN_CITY)
	assert(recovery.advance_city_recovery(hero, stats))
	# Recovery reads supplied live MaxHP, not a value captured at death.
	stats.max_hp = 200.0
	hero.current_hp = 150.0
	hero.loop_state = HeroState.RECOVERING_IN_CITY
	assert(not recovery.advance_city_recovery(hero, stats))
	assert(hero.current_hp == 190.0)
	assert(recovery.advance_city_recovery(hero, stats))
	assert(hero.current_hp == 200.0)
	test_runner_contracts()
	print("PASS: shared resurrection timing, HP clamp, live MaxHP and all three runner contracts.")
	quit()

func test_runner_contracts() -> void:
	var simulation = load("res://scripts/core/simulation.gd").new(12345)
	var hero = simulation.hero_state
	var stats = simulation.combat_stats
	stats.max_hp = 150.0
	hero.gold = 7
	hero.experience = 123
	for kind in ["quest", "dungeon", "event"]:
		var runner = simulation.quest_runner
		if kind == "dungeon":
			runner = simulation.dungeon_runner
		elif kind == "event":
			runner = simulation.event_runner
		for instant in [false, true]:
			hero.current_hp = 0.0
			hero.loop_state = HeroState.DEAD_RESPAWNING
			runner.respawn_ticks_remaining = 100
			if kind != "quest":
				# An inactive runner must not advance another activity's recovery.
				runner.failure_recovery_active = false
				assert(runner.advance_respawn(hero, stats) == {})
				assert(runner.force_resurrection(hero, stats) == null)
				assert(runner.respawn_ticks_remaining == 100)
				runner.failure_recovery_active = true
			if kind == "event":
				runner.failed_event_name = "Preserved event context"
			var result
			if instant:
				result = runner.force_resurrection(hero, stats)
			else:
				for tick in range(100):
					result = runner.advance(hero, stats) if kind == "quest" else runner.advance_respawn(hero, stats)
					assert(runner.respawn_ticks_remaining == 99 - tick)
					if tick < 99:
						assert(hero.loop_state == HeroState.DEAD_RESPAWNING and hero.current_hp == 0.0)
						assert(result.respawn_ticks_remaining == 99 - tick)
						if kind == "quest":
							assert(result.event_type == QuestEvent.HERO_WAITING_FOR_RESURRECTION)
						else:
							assert(result.type == "waiting")
			assert(runner.respawn_ticks_remaining == 0)
			assert(hero.current_hp == 1.0 and hero.loop_state == HeroState.RECOVERING_IN_CITY)
			assert(result.current_hp == 1.0 and result.respawn_ticks_remaining == 0)
			if kind == "quest":
				assert(result.event_type == QuestEvent.HERO_RESURRECTED)
				assert(result.quest_definition == runner.quest_definition)
				assert(result.max_hp == 150.0)
			else:
				assert(result.type == "resurrected")
				assert(runner.owns_respawn_state())
			if kind == "event":
				assert(result.event_name == "Preserved event context")
			assert(runner.force_resurrection(hero, stats) == null, "Repeated instant resurrection must be rejected.")
			for tick in range(5):
				result = runner.advance(hero, stats) if kind == "quest" else runner.advance_city_recovery(hero, stats)
				assert(is_equal_approx(hero.current_hp, minf(150.0, 1.0 + 30.0 * (tick + 1))))
				if kind == "quest":
					assert(result.event_type == QuestEvent.HERO_RECOVERING_IN_CITY)
				else:
					assert(result.type == "city_recovery" and result.fully_recovered == (tick == 4))
					assert(runner.owns_respawn_state() == (tick < 4))
				if tick < 4:
					assert(hero.loop_state == HeroState.RECOVERING_IN_CITY)
			assert(hero.loop_state == HeroState.CHOOSING_QUEST)
			assert(hero.gold == 7 and hero.experience == 123)
			if kind == "event":
				assert(runner.failed_event_name == "")
