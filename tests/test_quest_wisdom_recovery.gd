extends SceneTree

const QuestRunnerScript = preload("res://scripts/quests/quest_runner.gd")
const HeroStateScript = preload("res://scripts/hero/hero_state.gd")
const QuestDefinitionScript = preload("res://scripts/model/definitions/quest_definition.gd")
const QuestOfferScript = preload("res://scripts/model/runtime/quest_offer.gd")
const MobDefinitionScript = preload("res://scripts/model/definitions/mob_definition.gd")
const CombatStatsScript = preload("res://scripts/model/runtime/combat_stats.gd")

func _init() -> void:
	var quest_runner = QuestRunnerScript.new(make_quest_offer())
	var hero_state = HeroStateScript.new("Тест")
	var combat_stats = CombatStatsScript.new()
	combat_stats.max_hp = 1000.0

	hero_state.wisdom = 5
	assert(is_equal_approx(quest_runner.get_post_fight_recovery_percent(hero_state), 0.16), "WIS 5 must recover 15% base + 1% from Wisdom = 16% MaxHP per tick.")
	hero_state.loop_state = HeroState.RECOVERING_AFTER_FIGHT
	hero_state.current_hp = 500.0
	quest_runner.advance(hero_state, combat_stats)
	assert(is_equal_approx(hero_state.current_hp, 660.0), "WIS 5 ordinary quest recovery must restore 16% MaxHP in one world tick.")

	hero_state.wisdom = 20
	assert(is_equal_approx(quest_runner.get_post_fight_recovery_percent(hero_state), 0.19), "WIS 20 must recover 19% MaxHP per tick.")

	hero_state.wisdom = 200
	assert(is_equal_approx(quest_runner.get_post_fight_recovery_percent(hero_state), 0.40), "Wisdom-based ordinary quest recovery must cap at 40% MaxHP per tick.")

	print("PASS: Ordinary quest post-fight recovery uses 15% base + 0.2 percentage points per WIS, capped at 40%.")
	quit()

func make_quest_offer():
	var mob = MobDefinitionScript.new()
	mob.id = "recovery_test_mob"
	mob.display_name = "Recovery Test Mob"
	mob.max_hp = 100.0
	mob.attack = 1.0
	mob.attack_speed = 1.0

	var template = QuestDefinitionScript.new()
	template.id = "recovery_test_quest"
	template.display_name = "Recovery Test Quest"
	template.mob_definition = mob
	return QuestOfferScript.new(template, 2, 1.0, 0)
