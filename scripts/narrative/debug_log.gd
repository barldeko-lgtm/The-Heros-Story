class_name DebugLog
extends RefCounted

signal text_changed(text: String)

var entries: Array[String] = []

func record_tick(world_tick: int) -> void:
	entries.append("Тик %d" % world_tick)
	text_changed.emit(get_text())

func get_text() -> String:
	return "\n".join(entries)
