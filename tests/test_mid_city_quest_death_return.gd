extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")

func _init() -> void:
	var simulation = SimulationScript.new(9517, null)
	var mid_center: Vector2i = simulation.hex_map.definition.mid_city_center
	simulation.hero_state.current_city_id = HeroState.MID_CITY_ID
	assert(simulation.world_state.set_hero_position(mid_center), "Death-return fixture must begin physically in Arden.")
	assert(simulation.activate_mid_city_quest_context(), "Death-return fixture must activate Arden's local quest context.")

	simulation.hero_state.strength = 70
	simulation.hero_state.dexterity = 30
	simulation.hero_state.constitution = 45
	simulation.hero_state.wisdom = 30
	simulation.refresh_combat_stats()
	simulation.hero_state.current_hp = simulation.combat_stats.max_hp
	simulation.hero_state.loop_state = HeroState.VISITING_GUILD
	simulation.advance_time(10.0)
	assert(simulation.hero_state.loop_state == HeroState.TRAVEL_TO_QUEST and simulation.hero_state.active_quest != null, "Arden death test must first accept a suitable local quest.")
	var accepted_quest = simulation.hero_state.active_quest
	assert(simulation.hex_map.get_hex(accepted_quest.target_hex).region_id == simulation.hex_map.MID_REGION_ID, "Lethal test quest must be located in Mid Region.")

	while simulation.hero_state.loop_state == HeroState.TRAVEL_TO_QUEST:
		simulation.advance_time(10.0)
	assert(simulation.hero_state.loop_state == HeroState.DOING_QUEST, "Hero must physically reach the Arden quest before the lethal fight.")
	assert(simulation.world_state.hero_position == accepted_quest.target_hex, "Hero must stand on the Mid Region quest target before combat.")

	accepted_quest.mob_definition.attack = 100000.0
	accepted_quest.mob_definition.attack_speed = 2.0
	accepted_quest.mob_definition.accuracy = 10000.0
	accepted_quest.mob_definition.crit_chance = 0.0
	simulation.set_time_scale(100.0)
	var guard: int = 0
	while simulation.hero_state.loop_state != HeroState.DEAD_RESPAWNING and guard < 1000:
		simulation.advance_time(0.01)
		guard += 1

	assert(guard < 1000 and simulation.hero_state.loop_state == HeroState.DEAD_RESPAWNING, "Deliberately lethal Arden combat must enter normal resurrection state.")
	assert(simulation.hero_state.current_city_id == HeroState.MID_CITY_ID, "Quest death in Mid Region must not change the authoritative current city.")
	if simulation.world_state.hero_position != mid_center:
		print("DEATH POSITION actual=%s expected=%s context=%s log=%s" % [simulation.world_state.hero_position, mid_center, simulation.active_combat_context, simulation.debug_log.get_text()])
		quit(1)
		return
	assert(simulation.world_state.hero_position == mid_center, "Quest death in Mid Region must return the hero to Arden for resurrection, never Dornwald.")
	assert(simulation.hero_state.active_quest == null, "A lethal Arden quest must be cancelled normally.")
	assert(simulation.quest_runner.respawn_ticks_remaining == 100, "Arden quest death must keep the shared 100-tick natural resurrection rule.")

	# Finish the normal resurrection + city recovery cycle and prove the city-local
	# quest context survives the whole failure path.
	simulation.advance_time(10.5)
	assert(simulation.hero_state.loop_state == HeroState.CHOOSING_QUEST, "After natural resurrection and full city recovery the Arden hero must return to ordinary quest choice.")
	assert(simulation.world_state.hero_position == mid_center, "Resurrection and recovery must keep the hero physically in Arden.")
	assert(simulation.hero_state.current_city_id == HeroState.MID_CITY_ID, "Recovery after an Arden quest death must preserve Arden as the authoritative current city.")
	assert(simulation.quest_pool.placement_region_id == simulation.hex_map.MID_REGION_ID, "Recovery must preserve the Mid Region local quest pool rather than restoring Dornwald's board.")

	simulation.advance_time(0.1)
	assert(simulation.hero_state.loop_state == HeroState.TRAVEL_TO_QUEST and simulation.hero_state.active_quest != null, "The first normal tick after Arden recovery must be able to accept another local quest.")
	assert(simulation.hex_map.get_hex(simulation.hero_state.active_quest.target_hex).region_id == simulation.hex_map.MID_REGION_ID, "The post-recovery quest must still target Mid Region.")

	print("PASS: Lethal Arden ordinary quest combat returns to Arden, completes normal recovery, and resumes the local Mid Region quest loop.")
	quit()
