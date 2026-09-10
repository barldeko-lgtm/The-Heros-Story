extends RefCounted

# Only primitive Variant data is decoded; executable objects are never accepted.
const FORMAT_VERSION := 1
const MAX_FILE_BYTES := 64 * 1024 * 1024
const SLOTS := ["manual", "auto"]
var directory: String

func _init(save_directory: String = "user://saves") -> void:
	directory = save_directory

func slot_path(slot: String) -> String:
	return directory.path_join(slot + ".ths") if slot in SLOTS else ""

func read_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"error": "Сохранение отсутствует"}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"error": "Не удалось открыть сохранение"}
	var size := file.get_length()
	if size < 33 or size > MAX_FILE_BYTES:
		return {"error": "Неверный размер сохранения"}
	var digest := file.get_buffer(32)
	var bytes := file.get_buffer(size - 32)
	file.close()
	var hash := HashingContext.new()
	hash.start(HashingContext.HASH_SHA256)
	hash.update(bytes)
	if hash.finish() != digest:
		return {"error": "Сохранение повреждено (контрольная сумма)"}
	var data = bytes_to_var(bytes)
	if not data is Dictionary or data.get("version") != FORMAT_VERSION:
		return {"error": "Несовместимая версия сохранения"}
	if not data.get("snapshot") is Dictionary or not data.get("metadata") is Dictionary:
		return {"error": "Неполное сохранение"}
	var meta: Dictionary = data.metadata
	if not meta.get("slot") in SLOTS or not meta.get("saved_at") is int or not meta.get("hero") is String or not meta.get("level") is int:
		return {"error": "Повреждена информация о сохранении"}
	return data

func candidates(slot: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not slot in SLOTS:
		return result
	for suffix in ["", ".bak"]:
		var data := read_file(slot_path(slot) + suffix)
		if not data.has("error") and data.metadata.slot == slot:
			data["backup"] = not suffix.is_empty()
			result.append(data)
	return result

func write_slot(slot: String, snapshot: Dictionary, hero: String, level: int) -> Dictionary:
	if not slot in SLOTS or snapshot.is_empty() or snapshot.has("error"):
		return {"error": "Некорректное состояние для сохранения"}
	var error := DirAccess.make_dir_recursive_absolute(directory)
	if error != OK:
		return {"error": "Не удалось создать папку сохранений: %s" % error_string(error)}
	var saved_at := int(Time.get_unix_time_from_system() * 1000.0)
	for existing_slot in SLOTS:
		for candidate in candidates(existing_slot):
			saved_at = maxi(saved_at, int(candidate.metadata.saved_at) + 1)
	var data := {"version": FORMAT_VERSION, "metadata": {"slot": slot, "saved_at": saved_at, "hero": hero, "level": level}, "snapshot": snapshot}
	var bytes := var_to_bytes(data)
	if bytes.size() > MAX_FILE_BYTES - 32:
		return {"error": "Сохранение слишком большое"}
	var path := slot_path(slot)
	var temporary := path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return {"error": "Не удалось записать временный файл"}
	var hash := HashingContext.new()
	hash.start(HashingContext.HASH_SHA256)
	hash.update(bytes)
	file.store_buffer(hash.finish())
	file.store_buffer(bytes)
	file.flush()
	error = file.get_error()
	file.close()
	if error != OK or read_file(temporary).has("error"):
		return {"error": "Проверка записанного файла не пройдена"}
	# Never rotate a corrupt primary over a good backup.
	if not read_file(path).has("error"):
		var backup_temp := path + ".bak.tmp"
		error = DirAccess.copy_absolute(path, backup_temp)
		if error != OK or read_file(backup_temp).has("error"):
			return {"error": "Не удалось подготовить резервную копию"}
		error = DirAccess.rename_absolute(backup_temp, path + ".bak")
		if error != OK:
			return {"error": "Не удалось обновить резервную копию"}
	error = DirAccess.rename_absolute(temporary, path)
	if error != OK:
		return {"error": "Не удалось заменить сохранение: %s" % error_string(error)}
	var verified := read_file(path)
	if verified.has("error"):
		return verified
	return {"metadata": verified.metadata}
