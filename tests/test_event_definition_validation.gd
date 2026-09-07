extends SceneTree

const Definition = preload("res://scripts/model/definitions/event_definition.gd")
const Stage = preload("res://scripts/model/definitions/event_stage_definition.gd")
const Option = preload("res://scripts/model/definitions/event_option_definition.gd")
const Mob = preload("res://scripts/model/definitions/mob_definition.gd")
const Traits = preload("res://scripts/hero/hero_traits.gd")
const Resolver = preload("res://scripts/events/event_decision_resolver.gd")
var failures: int = 0
var checks: int = 0

func check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failures += 1
		printerr("FAIL: " + label)

func fixture():
	var definition = Definition.new()
	definition.id = "validation_probe"
	definition.display_name = "Validation probe"
	definition.region_id = "starting_region"
	definition.start_stage_id = "start"
	var start = Stage.new()
	start.id = "start"
	start.next_stage_id = "end"
	var ending = Stage.new()
	ending.id = "end"
	ending.stage_type = Stage.StageType.END
	ending.outcome_id = "success"
	ending.diary_text = "Finished."
	definition.stages.assign([start, ending])
	return definition

func _init() -> void:
	var definition = fixture()
	check(definition.validate_definition(), "Valid scene and end")
	definition.stages[0].set("stage_type", 999)
	check(not definition.validate_definition(), "Unknown stage type rejected")

	definition = fixture()
	var stage = definition.stages[0]
	stage.stage_type = Stage.StageType.TRAVEL
	stage.travel_target = Stage.TravelTarget.ENCOUNTER_HEX
	check(definition.validate_definition(), "Valid encounter travel")
	stage.set("travel_target", 999)
	check(not definition.validate_definition(), "Unknown travel target rejected")
	stage.travel_target = Stage.TravelTarget.SECONDARY_TARGET
	definition.secondary_target_enabled = true
	check(definition.validate_definition(), "Valid secondary target travel")

	definition = fixture()
	stage = definition.stages[0]
	stage.stage_type = Stage.StageType.DECISION
	stage.selection_rule = Stage.RULE_HIGHEST_PRIMARY_ATTRIBUTE
	var option = Option.new()
	option.id = "choice"
	option.next_stage_id = "end"
	stage.options.assign([option])
	for attribute in Resolver.ALLOWED_WARRIOR_ATTRIBUTES:
		option.driver_attribute = attribute
		check(definition.validate_definition(), "Valid attribute: " + attribute)
	for attribute in ["", "strenght", "intelligence"]:
		option.driver_attribute = attribute
		check(not definition.validate_definition(), "Invalid attribute rejected: " + attribute)

	stage.selection_rule = Stage.RULE_TRAIT_PRESENT
	stage.trait_present_stage_id = "end"
	stage.trait_absent_stage_id = "end"
	for trait_id in Traits.ALL:
		stage.checked_trait_id = trait_id
		check(definition.validate_definition(), "Valid single trait: " + trait_id)
	stage.checked_trait_id = "braev"
	check(not definition.validate_definition(), "Unknown single trait rejected")
	stage.selection_rule = Stage.RULE_ANY_TRAIT_PRESENT
	stage.checked_trait_ids = PackedStringArray(Traits.ALL)
	check(definition.validate_definition(), "Valid trait list")
	stage.checked_trait_ids.append("braev")
	check(not definition.validate_definition(), "Unknown trait within valid list rejected")

	definition = fixture()
	stage = definition.stages[0]
	stage.stage_type = Stage.StageType.COMBAT
	stage.combat_victory_stage_id = "end"
	stage.mob_definition = Mob.new()
	check(definition.validate_definition(), "Valid mob resource")
	stage.mob_definition = Resource.new()
	check(not definition.validate_definition(), "Wrong mob resource rejected")

	# Last: the old validator raises a script error for this malformed resource.
	definition = fixture()
	stage = definition.stages[0]
	stage.stage_type = Stage.StageType.DECISION
	stage.selection_rule = Stage.RULE_HIGHEST_PRIMARY_ATTRIBUTE
	stage.options.assign([Resource.new()])
	var malformed_result = definition.validate_definition()
	check(typeof(malformed_result) == TYPE_BOOL and malformed_result == false, "Wrong option resource returns false")

	var directory := "res://data/events/starting_region"
	var authored_count: int = 0
	for file_name in DirAccess.get_files_at(directory):
		if file_name.ends_with(".tres"):
			var authored = load(directory.path_join(file_name))
			check(authored.validate_definition(), "Authored event: " + file_name)
			authored_count += 1
	check(authored_count > 0, "Authored event coverage is not empty")
	print("Event validation: %d checks, %d authored events, %d failures" % [checks, authored_count, failures])
	quit(1 if failures > 0 else 0)
