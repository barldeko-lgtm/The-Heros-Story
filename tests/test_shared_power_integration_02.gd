extends SceneTree

const SimulationScript = preload("res://scripts/core/simulation.gd")
const PowerCalculatorScript = preload("res://scripts/combat/power_calculator.gd")
const ItemPowerCalculatorScript = preload("res://scripts/items/item_power_calculator.gd")

func _init() -> void:
	var calculator = PowerCalculatorScript.new()
	var simulation = SimulationScript.new(1)
	assert(is_equal_approx(simulation.get_hero_power(), calculator.calculate(simulation.base_combat_stats)), "Simulation HeroPower must use the shared PowerCalculator.")

	var goblin: Resource = load("res://data/mobs/0001_goblin.tres")
	assert(goblin != null, "Goblin definition must load for mob Power integration.")
	assert(is_equal_approx(goblin.get_power(), calculator.calculate(goblin.get_combat_stats())), "Mob Power must use the same shared PowerCalculator.")

	var common_chest: Resource = load("res://data/items/visual_families/ironward_vanguard/boar_chestplate.tres")
	assert(common_chest != null, "Common chestplate must load for ItemPower integration.")
	assert(absf(ItemPowerCalculatorScript.get_reference_power() - 433.012701892) < 0.0001, "ItemPower must use the approved fixed Prototype 0.2 reference profile.")
	assert(absf(common_chest.get_item_power() - 18.451295985) < 0.0001, "ItemPower must apply item stats through the shared Prototype 0.2 Power formula.")

	print("PASS: HeroPower, MobPower, and ItemPower share the Prototype 0.2 PowerCalculator.")
	quit()
