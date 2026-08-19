extends SceneTree

func _init() -> void:
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	assert(simulation_script != null, "Simulation script must exist.")

	var simulation: RefCounted = simulation_script.new(12345)
	simulation.hero_state.hero_name = "Алексей"
	simulation.hero_progression.add_experience(simulation.hero_state, 1123)
	simulation.refresh_combat_stats()
	simulation.hero_state.current_hp = simulation.combat_stats.max_hp
	simulation.hero_state.gold = 7

	assert(simulation.hero_state.level == 2, "Death test must start with a previously earned level.")
	assert(simulation.hero_state.experience == 123, "Death test must start with retained excess XP.")

	simulation.quest_runner.quest_definition.mob_definition.attack = 500.0
	simulation.quest_runner.quest_definition.mob_definition.crit_chance = 0.0

	simulation.advance_time(30.0)
	assert(simulation.hero_state.loop_state == HeroState.DOING_QUEST, "The hero must reach the quest before the lethal fight.")

	simulation.advance_time(2.0)
	assert(simulation.active_combat_session == null, "The lethal fight must finish.")
	assert(simulation.world_clock.world_tick == 4, "A defeated fight must still consume exactly one world tick.")
	assert(simulation.hero_state.loop_state == HeroState.DEAD_RESPAWNING, "Defeat must enter DEAD_RESPAWNING.")
	assert(is_zero_approx(simulation.hero_state.current_hp), "Dead hero HP must be clamped to zero.")
	assert(simulation.hero_state.active_quest == null, "Death must cancel the active quest.")
	assert(simulation.quest_runner.respawn_ticks_remaining == 100, "Natural resurrection must start with exactly 100 ticks.")
	assert(simulation.hero_state.level == 2, "Previously earned levels must survive death.")
	assert(simulation.hero_state.experience == 123, "Previously earned XP must survive death and the losing mob must grant no XP.")
	assert(simulation.hero_state.gold == 7, "A failed quest must not grant turn-in Gold.")
	assert(simulation.debug_log.get_text().contains("погиб"), "Death must be visible in the debug log.")

	simulation.advance_time(990.0)
	assert(simulation.hero_state.loop_state == HeroState.DEAD_RESPAWNING, "The hero must still be dead after 99 respawn ticks.")
	assert(simulation.quest_runner.respawn_ticks_remaining == 1, "Exactly one respawn tick must remain after 99 ticks.")
	assert(is_zero_approx(simulation.hero_state.current_hp), "HP must remain zero while dead.")
	assert(simulation.debug_log.get_text().contains("Тиков до возрождения: 1"), "Debug log must expose the remaining resurrection timer.")

	simulation.advance_time(10.0)
	assert(simulation.hero_state.loop_state == HeroState.RECOVERING_IN_CITY, "The 100th respawn tick must resurrect the hero into city recovery.")
	assert(is_equal_approx(simulation.hero_state.current_hp, 1.0), "Natural resurrection must return the hero with exactly 1 HP.")
	assert(simulation.quest_runner.respawn_ticks_remaining == 0, "Respawn timer must reach zero after resurrection.")
	assert(simulation.debug_log.get_text().contains("возродился в городе с 1.0 HP"), "Resurrection with 1 HP must be visible in the debug log.")

	simulation.advance_time(40.0)
	assert(simulation.hero_state.loop_state == HeroState.RECOVERING_IN_CITY, "Four recovery ticks must not fully heal a level-2 Warrior resurrected at 1 HP.")
	assert(is_equal_approx(simulation.hero_state.current_hp, 121.0), "City recovery must add 20% MaxHP per world tick.")

	simulation.advance_time(10.0)
	assert(simulation.hero_state.loop_state == HeroState.CHOOSING_QUEST, "Full city recovery must return the hero to quest selection.")
	assert(is_equal_approx(simulation.hero_state.current_hp, simulation.combat_stats.max_hp), "City recovery must stop at full MaxHP.")
	assert(simulation.hero_state.level == 2 and simulation.hero_state.experience == 123, "Recovery must not alter retained progression.")
	assert(simulation.hero_state.gold == 7, "Recovery after a failed quest must not create Gold.")

	print("PASS: Death cancels the quest, waits 100 ticks, resurrects at 1 HP, and fully recovers in the city.")
	quit()
