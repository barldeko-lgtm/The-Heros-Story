extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const MobDefinitionScript = preload("res://scripts/model/definitions/mob_definition.gd")
const QuestDefinitionScript = preload("res://scripts/model/definitions/quest_definition.gd")
const QuestOfferScript = preload("res://scripts/model/runtime/quest_offer.gd")

func _init() -> void:
	var cheap_quest = make_quest("cheap", 10.0, 10, 1.0, 1)
	var valuable_quest = make_quest("valuable", 20.0, 30, 1.0, 1)

	# null initial quest enables autonomous selection.
	# Explicit in-memory quest list keeps this test independent of tuned .tres data.
	var simulation = SimulationScript.new(123, null, [cheap_quest, valuable_quest])
	simulation.hero_state.hero_name = "Алексей"

	simulation.advance_time(10.0)

	assert(simulation.world_clock.world_tick == 1, "Quest choice must happen on the normal world tick.")
	assert(simulation.hero_state.active_quest != null, "Autonomous choice must assign a quest before QuestRunner starts it.")
	assert(simulation.hero_state.active_quest.id == "valuable", "Simulation must execute the quest selected by QuestEvaluator.")
	assert(simulation.hero_state.loop_state == HeroState.TRAVEL_TO_QUEST, "QuestRunner must still own execution after selection.")
	assert(simulation.last_quest_selection["selected_quest"].id == "valuable", "Simulation must expose the latest selection result for deterministic tests/debugging.")

	print("PASS: Simulation autonomously chooses a quest, then QuestRunner executes it.")
	quit()

func make_quest(quest_id: String, target_power: float, reward: int, distance: float, mob_count: int):
	var mob = MobDefinitionScript.new()
	mob.id = "mob_" + quest_id
	mob.display_name = mob.id
	mob.max_hp = target_power * target_power
	mob.attack = 1.0
	mob.attack_speed = 2.0
	mob.crit_chance = 0.0
	mob.crit_damage = 1.5
	mob.damage_reduction = 0.0

	var template = QuestDefinitionScript.new()
	template.id = quest_id
	template.display_name = quest_id
	template.mob_definition = mob
	return QuestOfferScript.new(template, mob_count, distance, int(reward / mob_count))
