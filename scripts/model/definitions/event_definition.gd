class_name EventDefinition
extends Resource

const EventStageDefinitionScript = preload("res://scripts/model/definitions/event_stage_definition.gd")

@export var id: String = ""
@export var display_name: String = ""
@export var region_id: String = ""
@export var placement_distance_hex_min: int = 0
@export var placement_distance_hex_max: int = 0
@export var placement_allowed_terrain_ids: PackedStringArray = PackedStringArray()
@export var placement_allowed_tags: PackedStringArray = PackedStringArray()
@export var placement_forbidden_tags: PackedStringArray = PackedStringArray()
@export var placement_radius: int = 1
@export var activation_radius: int = 1
@export var secondary_target_enabled: bool = false
@export var secondary_target_distance_hex_min: int = 0
@export var secondary_target_distance_hex_max: int = 0
@export var secondary_target_distance_from_event_hex_min: int = 0
@export var secondary_target_distance_from_event_hex_max: int = 0
@export var secondary_target_allowed_terrain_ids: PackedStringArray = PackedStringArray()
@export var secondary_target_allowed_tags: PackedStringArray = PackedStringArray()
@export var secondary_target_forbidden_tags: PackedStringArray = PackedStringArray()
@export var secondary_target_radius: int = 0
@export var secondary_target_must_be_farther_from_region_origin: bool = false
@export var lifetime_ticks: int = 200
@export var start_stage_id: String = ""
@export var stages: Array[Resource] = []

func get_stage(stage_id: String):
	for stage in stages:
		if stage != null and stage.id == stage_id:
			return stage
	return null

func validate_definition() -> bool:
	if id.is_empty() or display_name.is_empty() or region_id.is_empty() or start_stage_id.is_empty():
		return false
	if placement_distance_hex_min < 0 or placement_distance_hex_max < placement_distance_hex_min:
		return false
	if placement_radius < 0 or activation_radius < 0 or lifetime_ticks < 1:
		return false
	if secondary_target_enabled:
		if secondary_target_distance_hex_min < 0 or secondary_target_distance_hex_max < secondary_target_distance_hex_min:
			return false
		if secondary_target_distance_from_event_hex_min < 0 or secondary_target_distance_from_event_hex_max < secondary_target_distance_from_event_hex_min:
			return false
		if secondary_target_radius < 0:
			return false

	var stage_ids: Dictionary = {}
	for stage in stages:
		if stage == null or stage.get_script() != EventStageDefinitionScript or stage.id.is_empty() or stage_ids.has(stage.id):
			return false
		stage_ids[stage.id] = true
	if not stage_ids.has(start_stage_id):
		return false

	for stage in stages:
		if stage.stage_type == EventStageDefinitionScript.StageType.SCENE and not stage.next_stage_id.is_empty() and not stage_ids.has(stage.next_stage_id):
			return false
		if stage.stage_type == EventStageDefinitionScript.StageType.TRAVEL:
			if stage.next_stage_id.is_empty() or not stage_ids.has(stage.next_stage_id):
				return false
			if stage.travel_target == EventStageDefinitionScript.TravelTarget.NONE:
				return false
			if stage.travel_target == EventStageDefinitionScript.TravelTarget.SECONDARY_TARGET and not secondary_target_enabled:
				return false
		if stage.stage_type == EventStageDefinitionScript.StageType.DECISION:
			if stage.selection_rule == EventStageDefinitionScript.RULE_HIGHEST_PRIMARY_ATTRIBUTE:
				if stage.options.is_empty() or stage.options.size() > 3:
					return false
				for option in stage.options:
					if option == null or option.next_stage_id.is_empty() or not stage_ids.has(option.next_stage_id):
						return false
			elif stage.selection_rule == EventStageDefinitionScript.RULE_TRAIT_PRESENT:
				if stage.checked_trait_id.is_empty() or not stage_ids.has(stage.trait_present_stage_id) or not stage_ids.has(stage.trait_absent_stage_id):
					return false
			else:
				return false
		if stage.stage_type == EventStageDefinitionScript.StageType.COMBAT:
			if stage.mob_definition == null or stage.combat_victory_stage_id.is_empty() or not stage_ids.has(stage.combat_victory_stage_id):
				return false
		if stage.stage_type == EventStageDefinitionScript.StageType.END:
			if stage.outcome_id.is_empty() or stage.diary_text.is_empty():
				return false
	return true
