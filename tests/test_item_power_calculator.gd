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

	assert(is_equal_approx(calculator_script.get_reference_power(), 0.724568837), "Reference combat profile must retain its approved Power.")
	assert(is_equal_approx(calculator_script.calculate(common), 4.636106690), "Common chestplate ItemPower must use the shared Power formula.")
	assert(is_equal_approx(calculator_script.calculate(uncommon), 7.104690214), "Uncommon chestplate ItemPower must use the shared Power formula.")
	assert(is_equal_approx(calculator_script.calculate(rare), 10.184143277), "Rare chestplate ItemPower must use the shared Power formula.")
	assert(common.get_tooltip_text().contains("Сила предмета: 4.64"), "Common tooltip must display calculated ItemPower.")
	assert(uncommon.get_tooltip_text().contains("Сила предмета: 7.10"), "Uncommon tooltip must display calculated ItemPower.")
	assert(rare.get_tooltip_text().contains("Сила предмета: 10.18"), "Rare tooltip must display calculated ItemPower.")

	print("PASS: Every item card calculates and displays static ItemPower through the shared Power formula.")
	quit()
