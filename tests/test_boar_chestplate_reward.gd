extends SceneTree

const ITEM_PATH := "res://data/items/visual_families/ironward_vanguard/boar_chestplate.tres"
const BOAR_QUEST_PATH := "res://data/quests/0005_boars_in_fields.tres"

func _init() -> void:
	call_deferred("run_test")

func fail_test(message: String) -> void:
	push_error(message)
	quit(1)

func run_test() -> void:
	if not ResourceLoader.exists(ITEM_PATH):
		fail_test("Boar chestplate item definition must exist.")
		return
	var simulation_script: Script = load("res://scripts/core/simulation.gd")
	var main_ui_script: Script = load("res://scripts/ui/main_ui.gd")
	var boar_quest: Resource = load(BOAR_QUEST_PATH)
	if simulation_script == null or main_ui_script == null or boar_quest == null:
		fail_test("Reward integration dependencies must load.")
		return

	var simulation = simulation_script.new(1, boar_quest)
	var starting_max_hp: float = simulation.base_combat_stats.max_hp
	var starting_attack: float = simulation.base_combat_stats.attack
	var starting_hp: float = simulation.hero_state.current_hp
	simulation.hero_state.loop_state = HeroState.TURNING_IN_QUEST
	simulation.on_world_tick_completed(1)

	var equipped_item = simulation.hero_state.equipment.get_item("chest")
	if equipped_item == null:
		fail_test("The first completed boar quest must automatically equip its chestplate reward.")
		return
	assert(equipped_item.definition.id == "boar_chestplate", "The equipped reward must be the Boar Chestplate.")
	assert(simulation.hero_state.claimed_item_reward_ids.has("boar_chestplate"), "The unique reward must be recorded as claimed.")
	assert(is_equal_approx(simulation.base_combat_stats.max_hp, starting_max_hp + 25.0), "+20 MaxHP and +1 Strength must add 25 final MaxHP.")
	assert(is_equal_approx(simulation.base_combat_stats.attack, starting_attack + 1.0), "+1 Strength must add 1 Attack.")
	assert(is_equal_approx(simulation.base_combat_stats.damage_reduction, 0.05), "10 Armor must provide five percent damage reduction.")
	assert(is_equal_approx(simulation.hero_state.current_hp, starting_hp + 25.0), "Equipping at full health must increase current HP with the new maximum.")
	assert(simulation.debug_log.get_text().contains("Кираса Авангарда Железного Оплота"), "The reward and automatic equip must be reported in the debug log.")

	var first_item_instance = equipped_item
	simulation.hero_state.loop_state = HeroState.TURNING_IN_QUEST
	simulation.on_world_tick_completed(2)
	assert(simulation.hero_state.equipment.get_item("chest") == first_item_instance, "Repeated boar quests must not grant or replace the unique chestplate.")

	var main_ui = main_ui_script.new()
	main_ui.simulation = simulation
	get_root().add_child(main_ui)
	await process_frame
	main_ui.inventory_button.pressed.emit()
	await process_frame
	var chest_icon := main_ui.find_child("ChestEquipmentIcon", true, false) as TextureRect
	var chest_overlay := main_ui.find_child("HeroChestOverlay", true, false) as TextureRect
	var chest_slot := main_ui.find_child("ChestSlot", true, false) as PanelContainer
	if chest_icon == null or chest_overlay == null or chest_slot == null:
		fail_test("Inventory UI must expose the equipped chest icon, hero overlay, and chest slot.")
		return
	assert(chest_icon.texture == equipped_item.definition.icon_texture, "The equipped slot must use chest2 from the item definition.")
	assert(chest_overlay.visible and chest_overlay.texture == equipped_item.definition.hero_overlay_texture, "The portrait must show chest1 from the item definition.")
	assert(chest_slot.tooltip_text.contains("Кираса Авангарда Железного Оплота"), "Hover tooltip must show the item name.")
	assert(chest_slot.tooltip_text.contains("Максимальное здоровье: +20"), "Hover tooltip must show MaxHP.")
	assert(chest_slot.tooltip_text.contains("Броня: +10"), "Hover tooltip must show Armor.")
	assert(chest_slot.tooltip_text.contains("Сила: +1"), "Hover tooltip must show Strength.")

	main_ui.free()
	print("PASS: Boar quest grants, equips, applies, and displays the unique chestplate.")
	quit()
