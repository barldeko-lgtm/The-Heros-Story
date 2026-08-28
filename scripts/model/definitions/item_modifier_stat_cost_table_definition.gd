class_name ItemModifierStatCostTableDefinition
extends Resource

const UNPRICED_COST: float = -1.0

@export var stat_ids: Array[String] = []
@export var budget_costs: Array[float] = []
@export var unpriced_stat_ids: Array[String] = []

func get_stat_cost(stat_id: String) -> float:
	var stat_index: int = stat_ids.find(stat_id)
	if stat_index < 0 or stat_index >= budget_costs.size():
		return UNPRICED_COST
	return budget_costs[stat_index]
