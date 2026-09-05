extends SceneTree

const QuestPoolScript = preload("res://scripts/quests/quest_pool.gd")
const QuestEventScript = preload("res://scripts/quests/quest_event.gd")
const QUEST_PATHS := [
	"res://data/quests/0001_goblin_road_problem.tres",
	"res://data/quests/0002_wolf_hunt.tres",
]

func _init() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	var quest_templates: Array = []
	for quest_path in QUEST_PATHS:
		var quest_template: Resource = load(quest_path)
		assert(quest_template != null, "QuestPool lifecycle test templates must load.")
		quest_templates.append(quest_template)

	var quest_pool = QuestPoolScript.new([], rng)
	quest_pool.set_quest_templates(quest_templates)
	if not quest_pool.has_method("handle_quest_event"):
		push_error("QuestPool must own quest-offer lifecycle events.")
		quit(1)
		return
	var initial_offers: Array = quest_pool.get_available_quests()
	assert(initial_offers.size() == 2, "Focused QuestPool lifecycle test requires two offers.")

	var turned_in_offer = initial_offers[0]
	var untouched_offer = initial_offers[1]
	var selected_event = QuestEventScript.new(QuestEventScript.HERO_SELECTED_QUEST, "Алексей", turned_in_offer)
	quest_pool.handle_quest_event(selected_event, "TRAVEL_TO_QUEST", 10)
	assert(quest_pool.get_available_quests() == [untouched_offer], "Accepting a quest must remove it from the active board without filling the vacancy immediately.")

	var turn_in_event = QuestEventScript.new(QuestEventScript.HERO_TURNED_IN_QUEST, "Алексей", turned_in_offer)
	quest_pool.handle_quest_event(turn_in_event, "VISITING_MARKET", 20)
	assert(quest_pool.get_template_cooldown_until_tick(turned_in_offer.id) == 120, "Completed template must stay unavailable for 100 world ticks counted from turn-in completion.")
	assert(quest_pool.get_available_quests() == [untouched_offer], "Turning in a quest must not refill its board vacancy immediately.")

	assert(quest_pool.advance_world_tick(50), "The first shared board rotation must happen at tick 50.")
	var tick_50_offers: Array = quest_pool.get_available_quests()
	assert(tick_50_offers.size() == 1 and tick_50_offers[0].id != turned_in_offer.id, "Completed template must be excluded from board rolls while its 100-tick cooldown is active.")
	assert(quest_pool.advance_world_tick(100), "The second shared board rotation must happen at tick 100 while cooldown is still active.")
	assert(quest_pool.get_eligible_templates_for_band("lower", 119).size() == 1, "Completed template must still be unavailable one tick before cooldown expiry.")
	assert(quest_pool.get_eligible_templates_for_band("lower", 120).size() == 2, "Completed template must become eligible again exactly when its 100-tick cooldown expires.")
	assert(quest_pool.advance_world_tick(150), "The first shared board rotation after cooldown expiry must happen at tick 150.")
	var tick_150_offers: Array = quest_pool.get_available_quests()
	assert(tick_150_offers.size() == 2, "Both focused templates must be able to fill the lower band again after cooldown expiry.")
	assert(tick_150_offers.any(func(offer): return offer.id == turned_in_offer.id), "Completed template must be allowed to return on a later board roll after cooldown expiry.")

	print("PASS: QuestPool owns accepted-offer vacancies, global 50-tick rotation, and 100-tick completion cooldowns.")
	quit()
