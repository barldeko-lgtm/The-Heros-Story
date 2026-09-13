extends SceneTree

const Summary = preload("res://scripts/items/equipment_origin_statistics.gd")
const Snapshot = preload("res://scripts/core/simulation_snapshot.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var ui = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(ui)
	ui.set_process(false)
	await process_frame
	var simulation = ui.simulation
	var hero = simulation.hero_state
	assert(Summary.summarize(hero.equipment).starting == 3)
	var listing = simulation.shop_system.listings[0].item_instance
	assert(listing.acquisition_source == "unknown", "Stock is not a purchase.")
	hero.gold = 0
	assert(not simulation.shop_system.purchase_listing(hero, 0).purchased)
	assert(listing.acquisition_source == "unknown")
	hero.gold = 100000
	var purchase: Dictionary = simulation.shop_system.purchase_listing(hero, 0)
	assert(purchase.purchased and listing.acquisition_source == "purchased")
	assert(Summary.summarize(hero.equipment).purchased == 1)
	var rng := RandomNumberGenerator.new()
	rng.seed = 9172
	var reward: Dictionary = simulation.equipment_reward_system.receive_item(hero, listing.definition, 25, rng)
	assert(reward.item_instance.acquisition_source == "found")
	# Explicit equip isolates current-loadout counting from random item quality.
	hero.equipment.replace_item(reward.item_instance)
	assert(Summary.summarize(hero.equipment).purchased == 0)
	assert(Summary.summarize(hero.equipment).found == 1)
	hero.inventory.add_item(listing)
	assert(Summary.summarize(hero.equipment).purchased == 0, "Backpack gear must not count.")
	var dungeon = simulation.dungeon_system.get_all_dungeons()[0]
	var dungeon_reward: Dictionary = simulation.equipment_reward_system.resolve_dungeon_completion_reward(hero, dungeon.definition, rng)
	assert(dungeon_reward.item_instance.acquisition_source == "found")
	var mob = load("res://data/mobs/0006_bandit.tres")
	var event_reward: Dictionary = simulation.equipment_reward_system.resolve_authored_source_reward(hero, mob.equipment_drop_table, rng, 0)
	assert(event_reward.item_instance.acquisition_source == "found", "Authored event rewards use the same found provenance.")
	var drop: Dictionary = {}
	for attempt in 500:
		drop = simulation.equipment_reward_system.generate_mob_equipment_drop(mob, rng)
		if drop.item_instance != null:
			break
	assert(drop.item_instance != null and drop.item_instance.acquisition_source == "found", "Quest-buffer items receive provenance before review.")
	var captured: Dictionary = Snapshot.capture(simulation)
	var restored: Dictionary = Snapshot.restore(captured)
	assert(restored.error.is_empty())
	assert(Summary.summarize(restored.simulation.hero_state.equipment) == Summary.summarize(hero.equipment))
	var legacy: Dictionary = captured.duplicate(true)
	legacy.version = 3
	for node in legacy.nodes:
		if node.get("script", "") == "res://scripts/model/runtime/item_instance.gd":
			node.properties.erase("acquisition_source")
	var old: Dictionary = Snapshot.restore(legacy)
	assert(old.error.is_empty())
	assert(Summary.summarize(old.simulation.hero_state.equipment).unknown == old.simulation.hero_state.equipment.get_all_items().size())
	assert(legacy.version == 3, "Migration must not mutate source snapshot.")
	var malformed: Dictionary = captured.duplicate(true)
	for node in malformed.nodes:
		if node.get("script", "") == "res://scripts/model/runtime/item_instance.gd":
			node.properties.erase("acquisition_source")
			break
	assert(not Snapshot.restore(malformed).error.is_empty(), "Current schema still requires provenance.")
	ui.statistics_button.pressed.emit()
	assert(ui.equipment_origin_label.text.contains("Происхождение экипировки"))
	assert(not ui.equipment_origin_label.text.contains("Источник неизвестен"))
	await process_frame
	await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/equipment-origin-statistics.png")
	await process_frame
	await process_frame
	await process_frame
	ui.free()
	print("PASS: Purchase/reward/drop provenance, equipped-only totals, failed purchase, legacy v3 migration and current snapshot strictness.")
	quit()
