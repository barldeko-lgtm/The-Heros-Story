extends SceneTree

const CALCULATOR_PATH := "res://scripts/items/item_power_calculator.gd"

func _init() -> void:
	if not ResourceLoader.exists(CALCULATOR_PATH):
		push_error("ItemPowerCalculator must exist.")
		quit(1)
		return
	var calculator_script: Script = load(CALCULATOR_PATH)
	var common: Resource = load("res://data/items/visual_families/ironward_vanguard/boar_chestplate.tres")
	var uncommon: Resource = load("res://data/items/visual_families/ironward_vanguard/boar_chestplate_uncommon.tres")
	var rare: Resource = load("res://data/items/visual_families/ironward_vanguard/boar_chestplate_rare.tres")
	assert(calculator_script != null and common != null and uncommon != null and rare != null, "Item power dependencies must load.")

	assert(is_equal_approx(calculator_script.get_reference_power(), 433.012701892), "Reference combat profile must use the approved Prototype 0.2 Power.")
	assert(is_equal_approx(calculator_script.calculate(common), 18.451295985), "Common chestplate ItemPower must use the shared Power formula.")
	assert(is_equal_approx(calculator_script.calculate(uncommon), 29.956283218), "Uncommon chestplate ItemPower must use the shared Power formula.")
	assert(is_equal_approx(calculator_script.calculate(rare), 42.672987403), "Rare chestplate ItemPower must use the shared Power formula.")
	assert(common.get_tooltip_text().contains("Сила предмета: 18.45"), "Common tooltip must display calculated ItemPower.")
	assert(uncommon.get_tooltip_text().contains("Сила предмета: 29.96"), "Uncommon tooltip must display calculated ItemPower.")
	assert(rare.get_tooltip_text().contains("Сила предмета: 42.67"), "Rare tooltip must display calculated ItemPower.")

	print("PASS: Every item card calculates and displays static ItemPower through the shared Power formula.")
	quit()
