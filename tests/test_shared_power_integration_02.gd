extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const PowerCalculatorScript = preload("res://scripts/combat/power_calculator.gd")
const ItemPowerCalculatorScript = preload("res://scripts/items/item_power_calculator.gd")

func _init() -> void:
	var calculator = PowerCalculatorScript.new()
	var simulation = SimulationScript.new(1)
	assert(is_equal_approx(simulation.get_hero_power(), calculator.calculate_hero(simulation.base_combat_stats, simulation.hero_state)), "Simulation HeroPower must use the shared PowerCalculator including permanent Warrior ability valuation.")

	var goblin: Resource = load("res://data/mobs/0001_goblin.tres")
	assert(goblin != null, "Goblin definition must load for mob Power integration.")
	assert(is_equal_approx(goblin.get_power(), calculator.calculate(goblin.get_combat_stats(), "physical", "physical")), "Mob Power must use the shared PowerCalculator with the current Warrior's physical incoming-pressure profile.")
	var stone_golem: Resource = load("res://data/mobs/mid_region/0117_stone_golem.tres")
	assert(stone_golem != null, "Stone Golem must load for armored MobPower integration.")
	assert(stone_golem.get_power() > calculator.calculate(stone_golem.get_combat_stats()), "Armored MobPower must value Armor against the Warrior's physical offense rather than the generic mixed incoming profile.")

	var common_chest: Resource = load("res://data/items/visual_families/ironward_vanguard/boar_chestplate.tres")
	assert(common_chest != null, "Common chestplate must load for ItemPower integration.")
	assert(absf(ItemPowerCalculatorScript.get_reference_power() - 433.012701892) < 0.0001, "ItemPower must use the approved fixed Prototype 0.2 reference profile.")
	assert(absf(common_chest.get_item_power() - 16.659765117) < 0.0001, "ItemPower must apply item stats through the shared Prototype 0.2 Power formula.")

	print("PASS: HeroPower, MobPower, and ItemPower share the Prototype 0.2 PowerCalculator with contextual Mob defense evaluation.")
	quit()
