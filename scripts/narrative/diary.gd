class_name Diary
extends RefCounted

signal text_changed(text: String)

var entries: Array[String] = []

func get_text() -> String:
	return "\n".join(entries)
