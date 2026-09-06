extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const CombatResultScript = preload("res://scripts/combat/combat_result.gd")

func _init() -> void:
	var simulation = SimulationScript.new(9102, null)
	var dungeon = null
	for candidate in simulation.dungeon_system.get_all_dungeons():
		if candidate.definition.id == "abandoned_iron_mines":
			dungeon = candidate
			break
	assert(dungeon != null, "Focused Diary test requires the first Starting Region dungeon.")
	if not dungeon.discovered:
		dungeon.discover("test")
	assert(simulation.world_state.set_hero_position(dungeon.target_hex), "Focused Diary test hero must be placeable on the dungeon hex.")
	assert(simulation.dungeon_runner.begin_trip(simulation.hero_state, dungeon, simulation.get_hero_power()), "Focused Diary test must start the dungeon trip.")
	var travel_result: Dictionary = simulation.dungeon_runner.advance(simulation.hero_state)
	assert(bool(travel_result.get("arrived", false)), "Starting on the dungeon target must resolve travel as arrived.")
	assert(simulation.dungeon_runner.enter(simulation.hero_state), "Focused Diary test must enter the dungeon.")

	var fought_mob = simulation.dungeon_runner.get_current_mob_definition()
	var dungeon_name: String = dungeon.definition.display_name
	var killer_name: String = fought_mob.display_name
	var diary_count_before_death: int = simulation.diary.entries.size()
	var loss = CombatResultScript.new(false, 0.0, 10.0, 1.0, [])
	simulation.complete_dungeon_combat(fought_mob, loss, false, 77)

	assert(simulation.hero_state.loop_state == HeroState.DEAD_RESPAWNING, "Dungeon defeat must enter the normal death state.")
	assert(simulation.diary.entries.size() == diary_count_before_death + 1, "Dungeon defeat must add exactly one Diary entry.")
	var death_entry: String = simulation.diary.entries.back()
	assert(death_entry.begins_with("Тик 77 — "), "Dungeon death Diary entry must keep the real combat world tick.")
	assert(death_entry.contains(dungeon_name), "Dungeon death Diary entry must name the dungeon activity.")
	assert(death_entry.contains(killer_name), "Dungeon death Diary entry must name the killer.")
	assert(death_entry.contains("данжа"), "Dungeon death Diary entry must identify the activity as a dungeon.")

	simulation.dungeon_runner.respawn_ticks_remaining = 1
	simulation.advance_dungeon_respawn_tick(78)
	assert(simulation.hero_state.loop_state == HeroState.RECOVERING_IN_CITY, "Dungeon natural resurrection must enter city recovery.")
	assert(simulation.diary.entries.size() == diary_count_before_death + 2, "Dungeon natural resurrection must add one additional Diary entry.")
	var resurrection_entry: String = simulation.diary.entries.back()
	assert(resurrection_entry.begins_with("Тик 78 — ") and resurrection_entry.contains("обычного ожидания"), "Dungeon natural resurrection must use the shared natural-resurrection wording and real tick.")

	print("PASS: Dungeon combat death and natural resurrection write contextual Diary entries with real ticks.")
	quit()
