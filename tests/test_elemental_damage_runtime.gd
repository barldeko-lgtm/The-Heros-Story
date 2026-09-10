extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const SimulationSnapshotScript = preload("res://scripts/core/simulation_snapshot.gd")
const ItemInstanceScript = preload("res://scripts/model/runtime/item_instance.gd")

func _init() -> void:
	var fire_mob: Resource = load("res://data/mobs/mid_region/0110_fire_salamander.tres")
	assert(fire_mob != null and fire_mob.attack_damage_type == "fire", "Elemental runtime test requires the authored Fire Salamander.")

	var simulation = SimulationScript.new(31415)
	simulation.combat_stats.max_hp = 10000.0
	simulation.combat_stats.attack = 0.0
	simulation.combat_stats.attack_speed = 1.0
	simulation.combat_stats.dodge = 0.0
	simulation.combat_stats.armor = 1000.0
	simulation.combat_stats.fire_resistance = 40.0
	simulation.combat_stats.block = 0.0
	simulation.hero_state.current_hp = 10000.0
	simulation.start_combat_session(fire_mob, "quest", simulation.hero_state.current_hp)
	assert(is_equal_approx(simulation.get_current_opponent_power(), fire_mob.get_power()), "Live opponent Power must use the elemental mob's authored damage-type weighting.")
	simulation.advance_active_combat(1.70)

	var first_mob_action = find_last_mob_action(simulation.active_combat_session.actions)
	assert(first_mob_action != null, "Simulation must resolve a real authored mob attack.")
	assert(first_mob_action.damage_type == "fire", "Simulation must pass MobDefinition.attack_damage_type into CombatSession.")
	var first_raw_damage: float = fire_mob.attack * (fire_mob.crit_damage if first_mob_action.is_critical else 1.0)
	assert(is_equal_approx(first_mob_action.damage, first_raw_damage * 0.60), "40 percent Fire Resistance must reduce the authored Fire hit by exactly 40 percent while Armor is ignored.")

	var captured: Dictionary = SimulationSnapshotScript.capture(simulation)
	assert(str(captured.get("error", "")).is_empty(), "An active elemental fight must remain snapshot-safe.")
	var restored_result: Dictionary = SimulationSnapshotScript.restore(captured)
	assert(str(restored_result.get("error", "")).is_empty(), "An active elemental fight must restore successfully.")
	var restored = restored_result.get("simulation")
	assert(restored != null and restored.active_combat_mob_definition == fire_mob, "Restored combat must retain the authored elemental mob resource.")
	var action_count_before: int = restored.active_combat_session.actions.size()
	restored.advance_active_combat(2.0)
	var new_actions: Array = restored.active_combat_session.actions.slice(action_count_before)
	var restored_mob_action = find_last_mob_action(new_actions)
	assert(restored_mob_action != null and restored_mob_action.damage_type == "fire", "Restored combat must continue using the mob's authored elemental damage type.")

	var ring_definition: Resource = load("res://data/items/visual_families/ironward_vanguard/ironward_ring_1.tres")
	var ring = ItemInstanceScript.new(ring_definition, 5, 0, {"fire_resistance": 20.0}, [], 0.0, {"fire_resistance": 20.0})
	assert(ring.get_tooltip_text().contains("Базовое сопротивление огню: +20.00%"), "Equipment tooltip must present Resistance as a direct percentage.")

	print("PASS: Authored elemental mob attacks use direct-percent Resistance, elemental Power weighting, ignore Armor, survive active-combat save/restore, and display gear Resistance as percent.")
	quit()

func find_last_mob_action(actions: Array):
	for index in range(actions.size() - 1, -1, -1):
		if actions[index].attacker_id == "mob":
			return actions[index]
	return null
