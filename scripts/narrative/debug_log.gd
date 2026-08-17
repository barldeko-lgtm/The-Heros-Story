class_name DebugLog
extends RefCounted

signal text_changed(text: String)

var entries: Array[String] = []

func record_tick(world_tick: int) -> void:
	record_event(world_tick, "")

func record_event(world_tick: int, message: String) -> void:
	var entry: String = "Тик %d" % world_tick
	if not message.is_empty():
		entry += " — %s" % message
	entries.append(entry)
	text_changed.emit(get_text())

func get_text() -> String:
	return "\n".join(entries)
