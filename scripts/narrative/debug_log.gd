class_name DebugLog
extends RefCounted

signal text_changed(text: String)

const MAX_VISIBLE_WORLD_TICKS: int = 100

var entries: Array[String] = []
var entry_world_ticks: Array[int] = []
var latest_world_tick: int = 0

func record_tick(world_tick: int) -> void:
	record_event(world_tick, "")

func record_event(world_tick: int, message: String) -> void:
	var entry: String = "Тик %d" % world_tick
	if not message.is_empty():
		entry += " — %s" % message
	append_entry(world_tick, entry)

func record_combat_event(message: String, world_tick: int = -1) -> void:
	var combat_world_tick: int = world_tick
	if combat_world_tick < 0:
		combat_world_tick = latest_world_tick
	append_entry(combat_world_tick, "Бой — %s" % message)

func append_entry(world_tick: int, entry: String) -> void:
	entries.append(entry)
	entry_world_ticks.append(world_tick)
	latest_world_tick = maxi(latest_world_tick, world_tick)
	trim_old_entries()
	text_changed.emit(get_text())

func trim_old_entries() -> void:
	var oldest_visible_tick: int = latest_world_tick - MAX_VISIBLE_WORLD_TICKS + 1
	while not entry_world_ticks.is_empty() and entry_world_ticks[0] < oldest_visible_tick:
		entry_world_ticks.pop_front()
		entries.pop_front()

func get_text() -> String:
	return "\n".join(entries)
