class_name Diary
extends RefCounted

signal text_changed(text: String)

var entries: Array[String] = []

func add_entry(world_tick: int, text: String) -> bool:
	var clean_text: String = text.strip_edges()
	if clean_text.is_empty():
		return false
	entries.append("Тик %d — %s" % [world_tick, clean_text])
	text_changed.emit(get_text())
	return true

func get_text() -> String:
	return "\n\n".join(entries)
