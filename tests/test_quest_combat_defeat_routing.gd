extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const WolfQuest = preload("res://data/quests/0002_wolf_hunt.tres")

func _init() -> void:
	var simulation = SimulationScript.new(1788676628, WolfQuest)
	simulation.hero_state.hero_name = "Дмитрий"
	simulation.hero_state.loop_state = HeroState.DOING_QUEST
	simulation.hero_state.active_quest = simulation.quest_runner.quest_definition
	simulation.hero_state.current_hp = 1.0

	var wolf = simulation.quest_runner.quest_definition.mob_definition
	wolf.attack = 500.0
	wolf.crit_chance = 0.0

	simulation.start_combat()
	assert(simulation.active_combat_session != null, "The quest fight must start as one live CombatSession.")
	simulation.advance_active_combat(10.0)

	assert(simulation.active_combat_session == null, "A lethal quest fight must finish instead of remaining active.")
	assert(simulation.hero_state.loop_state == HeroState.DEAD_RESPAWNING, "Quest defeat must route to QuestRunner and enter DEAD_RESPAWNING.")
	assert(simulation.hero_state.active_quest == null, "Quest defeat must cancel the active quest.")
	assert(simulation.quest_runner.respawn_ticks_remaining == 100, "Quest defeat must start the normal 100-tick resurrection delay.")
	assert(int(simulation.get_combat_results("wolf").get("total", 0)) == 1, "The lethal Wolf fight must be recorded exactly once.")
	assert(simulation.diary.entries.size() == 1, "Quest defeat must create exactly one death Diary entry.")
	assert(simulation.diary.entries[0].contains("Волк") and simulation.diary.entries[0].contains("Охота на волков"), "The death Diary entry must keep the real killer and quest context.")

	simulation.advance_time(0.1)
	assert(simulation.active_combat_session == null, "After quest defeat the same fight must not restart on the next update.")
	assert(int(simulation.get_combat_results("wolf").get("total", 0)) == 1, "No duplicate Wolf fight may be created after defeat.")

	print("PASS: Quest combat defeat routes once into death/respawn and cannot restart the same fight.")
	quit()
