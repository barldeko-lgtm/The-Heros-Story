class_name Diary
extends RefCounted

signal text_changed(text: String)

const MAX_ENTRIES: int = 100

var entries: Array[String] = []
var entry_ids: Array[int] = []
var next_entry_id: int = 1

func add_entry(world_tick: int, text: String) -> bool:
	var clean_text: String = text.strip_edges()
	if clean_text.is_empty():
		return false
	entries.append("Тик %d — %s" % [world_tick, clean_text])
	entry_ids.append(-1)
	trim_old_entries()
	text_changed.emit(get_text())
	return true

func add_temporary_entry(world_tick: int, text: String) -> int:
	var clean_text: String = text.strip_edges()
	if clean_text.is_empty():
		return -1
	var entry_id: int = next_entry_id
	next_entry_id += 1
	entries.append("Тик %d — %s" % [world_tick, clean_text])
	entry_ids.append(entry_id)
	trim_old_entries()
	text_changed.emit(get_text())
	return entry_id

func remove_entry(entry_id: int) -> bool:
	if entry_id <= 0:
		return false
	var entry_index: int = entry_ids.find(entry_id)
	if entry_index < 0:
		return false
	entries.remove_at(entry_index)
	entry_ids.remove_at(entry_index)
	text_changed.emit(get_text())
	return true

func trim_old_entries() -> void:
	while entries.size() > MAX_ENTRIES:
		entries.pop_front()
		entry_ids.pop_front()

func get_text() -> String:
	return "\n".join(entries)
