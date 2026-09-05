class_name EventStageDefinition
extends Resource

enum StageType {
	SCENE,
	DECISION,
	TRAVEL,
	COMBAT,
	END,
}

enum DecisionRole {
	NEUTRAL,
	FORMATIVE,
	EXPRESSIVE,
}

enum TravelTarget {
	NONE,
	ENCOUNTER_HEX,
	SECONDARY_TARGET,
}

const RULE_NONE := ""
const RULE_HIGHEST_PRIMARY_ATTRIBUTE := "highest_primary_attribute"
const RULE_TRAIT_PRESENT := "trait_present"

@export var id: String = ""
@export var stage_type: StageType = StageType.SCENE
@export var decision_role: DecisionRole = DecisionRole.NEUTRAL
@export_range(1, 20, 1) var duration_ticks: int = 1
@export_multiline var scene_text: String = ""
@export_multiline var diary_text: String = ""
@export var next_stage_id: String = ""
@export var travel_target: TravelTarget = TravelTarget.NONE

@export var selection_rule: String = RULE_NONE
@export var options: Array[Resource] = []
@export var checked_trait_id: String = ""
@export var trait_present_stage_id: String = ""
@export var trait_absent_stage_id: String = ""

@export var mob_definition: Resource
@export var combat_victory_stage_id: String = ""

@export var outcome_id: String = ""
@export var gold_reward: int = 0
@export var equipment_reward_source: Resource
@export var equipment_rarity_override: int = -1
