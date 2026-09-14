extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const EVENT_PATHS := [
	"res://data/events/starting_region/0016_scattered_earnings.tres",
	"res://data/events/starting_region/0017_old_mill_debt.tres",
	"res://data/events/starting_region/0018_rain_over_caravan.tres",
	"res://data/events/starting_region/0019_parcel_for_forester.tres",
	"res://data/events/starting_region/0020_old_hunters_cache.tres",
]

func _init() -> void:
	var definitions: Array = []
	for path in EVENT_PATHS:
		var definition = load(path)
		assert(definition != null and definition.validate_definition(), "Balancing event must load and pass EventDefinition validation: %s" % path)
		definitions.append(definition)
		assert_no_combat(definition)

	assert(definitions[0].display_name == "Рассыпавшаяся выручка")
	assert(definitions[1].display_name == "Долг у старой мельницы")
	assert(definitions[2].display_name == "Ливень над обозом")
	assert(definitions[3].display_name == "Посылка лесничему")
	assert(definitions[4].display_name == "Тайник старого охотника")

	var secondary_count := 0
	var movement_counts := {
		"devious": 0,
		"generous": 0,
		"greedy": 0,
		"conservative": 0,
	}
	var attribute_counts := {
		"strength": 0,
		"dexterity": 0,
		"constitution": 0,
		"wisdom": 0,
	}
	for definition in definitions:
		if definition.secondary_target_enabled:
			secondary_count += 1
		var decision = definition.get_stage("first_decision")
		assert(decision != null and decision.decision_role == 1 and decision.selection_rule == "highest_primary_attribute")
		assert(decision.options.size() == 3)
		for option in decision.options:
			attribute_counts[option.driver_attribute] += 1
			var trait_id: String = movement_trait(option.personality_axis_id, option.personality_delta)
			assert(movement_counts.has(trait_id), "Every new formative option must move only toward one of the four underrepresented traits.")
			movement_counts[trait_id] += 1

	assert(secondary_count == 2, "Exactly two of events 16-20 must own a secondary map objective.")
	assert(definitions[3].secondary_target_enabled and definitions[4].secondary_target_enabled)
	assert(not definitions[0].secondary_target_enabled and not definitions[1].secondary_target_enabled and not definitions[2].secondary_target_enabled)
	assert(movement_counts == {"devious": 4, "generous": 4, "greedy": 4, "conservative": 3})
	assert(attribute_counts == {"strength": 4, "dexterity": 4, "constitution": 4, "wisdom": 3})

	var simulation = SimulationScript.new(1162001, null, [], true)
	assert(count_region_events(simulation, "starting_region") == 20, "Starting Region event pool must contain twenty authored definitions.")
	print("PASS: Events 16-20 are non-combat personality-balancing stories with 4 Devious / 4 Generous / 4 Greedy / 3 Conservative formative branches and exactly two secondary-map detours.")
	quit()

func count_region_events(simulation, region_id: String) -> int:
	var count := 0
	for definition in simulation.event_system.event_definitions:
		if definition != null and definition.region_id == region_id:
			count += 1
	return count

func movement_trait(axis_id: String, delta: int) -> String:
	if axis_id == "morality" and delta < 0:
		return "devious"
	if axis_id == "greed" and delta > 0:
		return "generous"
	if axis_id == "greed" and delta < 0:
		return "greedy"
	if axis_id == "curiosity" and delta < 0:
		return "conservative"
	return ""

func assert_no_combat(definition) -> void:
	for stage in definition.stages:
		assert(stage.stage_type != 3, "Balancing event must contain no COMBAT stage: %s" % definition.id)
