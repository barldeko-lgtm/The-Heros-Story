extends SceneTree

const DiaryScript = preload("res://scripts/narrative/diary.gd")

func _init() -> void:
	var diary = DiaryScript.new()
	var temporary_entry_id: int = diary.add_temporary_entry(1, "Временная запись")
	assert(temporary_entry_id > 0, "A temporary Diary entry must return a removable positive id.")
	assert(diary.remove_entry(temporary_entry_id), "A temporary Diary entry must be removable by id.")
	assert(diary.entries.is_empty(), "Removing a temporary Diary entry must remove its visible text.")

	for tick in range(1, 102):
		assert(diary.add_entry(tick, "Запись %d" % tick))

	assert(diary.entries.size() == DiaryScript.MAX_ENTRIES, "Diary must retain at most 100 entries.")
	assert(diary.entry_ids.size() == diary.entries.size(), "Diary entry ids must stay aligned with retained visible entries.")
	assert(diary.entries.front().begins_with("Тик 2 — "), "Adding the 101st Diary entry must evict the oldest entry.")
	assert(diary.entries.back().begins_with("Тик 101 — "), "Diary must retain the newest entry after trimming.")
	assert(not diary.get_text().contains("Тик 1 — Запись 1\n"), "Trimmed Diary text must not expose the evicted oldest entry.")

	print("PASS: Diary retains only the newest 100 entries and supports removable temporary entries.")
	quit()
