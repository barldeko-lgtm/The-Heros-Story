extends SceneTree

const EVENT_DIRECTORY := "res://data/events/starting_region"

func _init() -> void:
	var movement_counts := {
		"brave": 0,
		"cautious": 0,
		"noble": 0,
		"devious": 0,
		"generous": 0,
		"greedy": 0,
		"curious": 0,
		"conservative": 0,
	}
	var authored_count := 0
	for file_name in DirAccess.get_files_at(EVENT_DIRECTORY):
		if not file_name.ends_with(".tres"):
			continue
		var definition = load(EVENT_DIRECTORY.path_join(file_name))
		assert(definition != null and definition.validate_definition())
		authored_count += 1
		for stage in definition.stages:
			if stage.decision_role != 1 or stage.selection_rule != "highest_primary_attribute":
				continue
			for option in stage.options:
				var trait_id := movement_trait(option.personality_axis_id, option.personality_delta)
				if not trait_id.is_empty():
					movement_counts[trait_id] += 1

	assert(authored_count == 20)
	assert(movement_counts == {
		"brave": 11,
		"cautious": 11,
		"noble": 6,
		"devious": 5,
		"generous": 6,
		"greedy": 6,
		"curious": 7,
		"conservative": 5,
	})
	assert(movement_counts["brave"] == movement_counts["cautious"], "Brave/Cautious formative opportunities must remain exactly balanced because Courage influences first specialization.")
	print("PASS: Starting Region formative personality distribution is 11/11 Courage and 6/5/6/6/7/5 across the remaining trait sides.")
	quit()

func movement_trait(axis_id: String, delta: int) -> String:
	if delta == 0:
		return ""
	match axis_id:
		"courage":
			return "brave" if delta > 0 else "cautious"
		"morality":
			return "noble" if delta > 0 else "devious"
		"greed":
			return "generous" if delta > 0 else "greedy"
		"curiosity":
			return "curious" if delta > 0 else "conservative"
	return ""
