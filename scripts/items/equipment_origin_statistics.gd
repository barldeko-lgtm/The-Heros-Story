extends RefCounted

static func summarize(equipment) -> Dictionary:
	var result := {"purchased": 0, "found": 0, "starting": 0, "unknown": 0}
	for item in equipment.get_all_items():
		if item == null:
			continue
		var source: String = item.acquisition_source
		if not result.has(source):
			source = "unknown"
		result[source] += 1
	return result
