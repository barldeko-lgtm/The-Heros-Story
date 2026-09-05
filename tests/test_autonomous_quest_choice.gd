extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const MobDefinitionScript = preload("res://scripts/model/definitions/mob_definition.gd")
const QuestDefinitionScript = preload("res://scripts/model/definitions/quest_definition.gd")
const QuestOfferScript = preload("res://scripts/model/runtime/quest_offer.gd")

func _init() -> void:
	var cheap_quest = make_quest("cheap", 30.0, 10, 1.0, 1)
	var middle_quest = make_quest("middle", 35.0, 20, 1.0, 1)
	var valuable_quest = make_quest("valuable", 40.0, 30, 1.0, 1)

	# null initial quest enables autonomous selection.
	# Explicit in-memory quest list keeps this test independent of tuned .tres data.
	var simulation = SimulationScript.new(123, null, [cheap_quest, middle_quest, valuable_quest])
	simulation.hero_state.hero_name = "Алексей"

	simulation.advance_time(10.0)

	assert(simulation.world_clock.world_tick == 1, "Quest choice must happen on the normal world tick.")
	assert(simulation.hero_state.active_quest != null, "Autonomous choice must assign a quest before QuestRunner starts it.")
	assert(simulation.hero_state.active_quest.id == "valuable", "Simulation must execute the quest selected by QuestEvaluator.")
	assert(simulation.hero_state.loop_state == HeroState.TRAVEL_TO_QUEST, "QuestRunner must still own execution after selection.")
	assert(simulation.last_quest_selection["selected_quest"].id == "valuable", "Simulation must expose the latest selection result for deterministic tests/debugging.")
	var log_text: String = simulation.debug_log.get_text()
	assert(log_text.contains("Топ-3 из 3 подходящих:"), "Autonomous quest selection must show the top three eligible QuestScore candidates in the debug log.")
	assert(log_text.contains("1. «valuable»") and log_text.contains("2. «middle»") and log_text.contains("3. «cheap»"), "Quest debug ranking must follow the actual QuestScore order.")
	assert(log_text.contains("← выбран"), "The winning quest must be marked inside the top-three debug ranking.")
	assert(log_text.contains("Расчёт выбранного: база") and log_text.contains("Смелость/Осторожность") and log_text.contains("Хитрость/Благородство") and log_text.contains("Жадность") and log_text.contains("Бог") and log_text.contains("итог"), "The winning quest log must expose every current QuestScore component.")

	print("PASS: Simulation autonomously chooses a quest, logs the top three candidates and the winner's QuestScore breakdown, then QuestRunner executes it.")
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


	var template = QuestDefinitionScript.new()
	template.id = quest_id
	template.display_name = quest_id
	template.mob_definition = mob
	return QuestOfferScript.new(template, mob_count, distance, int(reward / mob_count))
