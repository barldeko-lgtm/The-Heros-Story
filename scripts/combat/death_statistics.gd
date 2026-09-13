extends RefCounted

# Derived view of the existing lifetime per-mob records; no second totals store.
static func summarize(records: Dictionary) -> Dictionary:
	var result := {"total": 0, "quest": 0, "dungeon": 0, "event": 0, "unknown": 0, "killer_name": "", "killer_deaths": 0}
	var ids: Array = records.keys()
	ids.sort()
	for mob_id in ids:
		var record: Dictionary = records[mob_id]
		var deaths: int = int(record.get("losses", 0))
		result.total += deaths
		var contexts: Dictionary = record.get("deaths_by_activity", {})
		var known: int = 0
		for activity in ["quest", "dungeon", "event"]:
			var count: int = int(contexts.get(activity, 0))
			result[activity] += count
			known += count
		result.unknown += maxi(0, deaths - known)
		# Strict comparison after ID sorting makes ties stable, not frame-dependent.
		if deaths > int(result.killer_deaths):
			result.killer_deaths = deaths
			result.killer_name = str(record.get("display_name", mob_id))
	return result
