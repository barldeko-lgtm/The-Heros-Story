extends SceneTree
const Store = preload("res://scripts/core/save_store.gd")
func _initialize() -> void:
	var directory := "res://.godot/save-store-test-" + str(Time.get_ticks_usec())
	var store = Store.new(directory)
	var ok := true
	ok = ok and store.write_slot("invalid", {"test": 1}, "Герой", 1).has("error")
	ok = ok and store.candidates("manual").is_empty()
	ok = ok and not store.write_slot("manual", {"test": 1}, "Герой", 1).has("error")
	ok = ok and not store.write_slot("manual", {"test": 2}, "Герой", 2).has("error")
	ok = ok and store.candidates("manual").size() == 2
	ok = ok and store.candidates("manual")[0].snapshot.test == 2
	ok = ok and store.candidates("manual")[1].snapshot.test == 1
	ok = ok and not store.write_slot("auto", {"test": 3}, "Герой", 3).has("error")
	ok = ok and store.candidates("auto")[0].metadata.saved_at > store.candidates("manual")[0].metadata.saved_at
	var file := FileAccess.open(store.slot_path("manual"), FileAccess.WRITE)
	file.store_string("damaged")
	file.close()
	ok = ok and store.candidates("manual").size() == 1 and store.candidates("manual")[0].backup
	ok = ok and store.candidates("auto")[0].snapshot.test == 3
	ok = ok and not store.write_slot("manual", {"test": 4}, "Герой", 4).has("error")
	ok = ok and store.candidates("manual")[1].snapshot.test == 1
	ok = ok and store.candidates("manual")[0].metadata.saved_at > store.candidates("auto")[0].metadata.saved_at
	var blocked = Store.new(store.slot_path("auto")) # A regular file cannot be a directory.
	ok = ok and blocked.write_slot("auto", {"test": 5}, "Герой", 5).has("error")
	ok = ok and store.candidates("auto")[0].snapshot.test == 3
	print("PASS: slot isolation, verified replacement, backup rotation, corruption recovery and failed writes") if ok else printerr("FAIL: save store")
	quit(0 if ok else 1)
