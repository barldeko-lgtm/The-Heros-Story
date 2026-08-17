extends SceneTree

func _init() -> void:
	var repository_script: Script = load("res://scripts/core/hero_name_repository.gd")
	assert(repository_script != null, "HeroNameRepository script must exist.")

	var repository: RefCounted = repository_script.new()
	var names: Array[String] = repository.load_names()
	assert(names.size() == 10, "The initial hero-name list must contain exactly 10 names.")
	for hero_name in names:
		assert(not hero_name.strip_edges().is_empty(), "Hero names must not be empty.")

	print("PASS: Hero name list has ten non-empty names.")
	quit()
