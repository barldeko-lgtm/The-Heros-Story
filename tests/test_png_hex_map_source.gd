extends SceneTree

func _init() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var decoder_script: Script = load("res://scripts/world/hex_map_image_decoder.gd")
	assert(decoder_script != null, "Exact-color hex-map decoder must exist.")
	var decoder = decoder_script.new()
	var map_definition = load("res://data/map/prototype_02_map.tres")
	assert(map_definition != null and map_definition.layout_texture != null, "Map definition must reference the editable PNG layout.")

	var decoded: Dictionary = map_definition.reload_from_image()
	assert(decoded["succeeded"], "Production PNG must decode without unknown colors or malformed markers: %s" % decoded["errors"])
	assert(decoded["terrain_by_cell"].size() == map_definition.width * map_definition.height, "PNG must define every one of the 20 by 15 hexes.")
	assert(decoded["counts"].get("hero_start", 0) == 1, "PNG must contain exactly one bright hero-start hex.")
	assert(decoded["counts"].get("starting_city", 0) == 6, "Six city hexes must surround the unique hero-start center.")
	assert(decoded["counts"].get("mid_city", 0) == 7, "Mid-Level City must occupy seven purple hexes.")
	assert(map_definition.starting_city_center == Vector2i(4, 9), "Hero start must be decoded from the unique PNG marker.")
	assert(map_definition.mid_city_center == Vector2i(15, 5), "Mid-Level City center must be derived from its seven-hex PNG cluster.")
	assert(map_definition.validate_layout(), "Decoded cities, terrain, and road must satisfy the logical hex-map contract.")

	var recolored_image: Image = map_definition.layout_texture.get_image().duplicate()
	var recolored_cell := Vector2i(0, 0)
	assert(map_definition.get_terrain_id(recolored_cell) == "plains", "Recolor probe requires a current plains hex.")
	recolored_image.set_pixelv(map_definition.get_source_pixel(recolored_cell), decoder.FOREST_COLOR)
	var recolored_texture := ImageTexture.create_from_image(recolored_image)
	var recolored_result: Dictionary = decoder.decode(recolored_texture, map_definition)
	assert(recolored_result["succeeded"], "One exact palette recolor must remain a valid map.")
	assert(recolored_result["terrain_by_cell"][recolored_cell] == "forest", "Changing one PNG hex center to the forest color must change decoded terrain.")

	var invalid_image: Image = map_definition.layout_texture.get_image().duplicate()
	invalid_image.set_pixelv(map_definition.get_source_pixel(recolored_cell), Color8(1, 2, 3, 255))
	var invalid_result: Dictionary = decoder.decode(ImageTexture.create_from_image(invalid_image), map_definition)
	assert(not invalid_result["succeeded"], "Unknown PNG colors must be rejected instead of becoming plains.")
	assert(str(invalid_result["errors"]).contains("(0, 0)"), "Unknown-color error must report the affected hex coordinate.")

	var map_scene: PackedScene = load("res://scenes/ui/screens/map_screen.tscn")
	var map_screen = map_scene.instantiate()
	get_root().add_child(map_screen)
	await process_frame
	assert(map_screen.get_drawn_terrain_count("hero_start") == 1, "MapScreen must render the unique start marker decoded from PNG.")
	assert(map_screen.get_drawn_terrain_count("forest") == decoded["counts"].get("forest", 0), "MapScreen terrain counts must come from PNG decoding.")
	map_screen.free()

	print("PASS: Exact-color PNG controls all 300 hexes, identifies hero start, rejects unknown colors, and feeds MapScreen.")
	quit()
