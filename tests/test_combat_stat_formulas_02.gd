extends SceneTree

const DAMAGE_RESOLVER_PATH := "res://scripts/combat/damage_resolver.gd"

func _init() -> void:
	if not ResourceLoader.exists(DAMAGE_RESOLVER_PATH):
		push_error("Prototype 0.2 DamageResolver must exist.")
		quit(1)
		return
	var resolver_script: Script = load(DAMAGE_RESOLVER_PATH)
	assert(resolver_script != null, "DamageResolver script must load.")

	assert(is_equal_approx(resolver_script.calculate_dodge_chance(0.0, 0.0), 0.0), "Zero Dodge must produce zero DodgeChance.")
	assert(is_equal_approx(resolver_script.calculate_hit_chance(0.0, 0.0), 1.0), "Zero Dodge must preserve 100 percent HitChance.")
	assert(is_equal_approx(resolver_script.calculate_dodge_chance(100.0, 50.0), 0.20), "50 Dodge against 100 Accuracy must produce 20 percent DodgeChance.")
	assert(is_equal_approx(resolver_script.calculate_dodge_chance(0.0, 1000000.0), 0.50), "DodgeChance must be capped at 50 percent.")

	assert(is_equal_approx(resolver_script.calculate_physical_taken(100.0), 0.50), "100 Armor must leave 50 percent physical damage.")
	assert(is_equal_approx(resolver_script.calculate_physical_taken(0.0), 1.0), "Zero Armor must leave all physical damage.")
	assert(is_equal_approx(resolver_script.calculate_elemental_taken(100.0), 0.50), "100 Resistance must leave 50 percent elemental damage.")
	assert(is_equal_approx(resolver_script.calculate_elemental_taken(-50.0), 1.0), "Negative Resistance must be treated as zero.")
	assert(is_equal_approx(resolver_script.calculate_elemental_taken(1000000.0), 0.25), "Elemental damage reduction must be capped at 75 percent.")

	assert(is_equal_approx(resolver_script.calculate_block_chance(200.0), 0.50), "200 Block must reach the 50 percent BlockChance cap.")
	assert(is_equal_approx(resolver_script.calculate_block_chance(-10.0), 0.0), "Negative Block must be treated as zero.")
	assert(is_equal_approx(resolver_script.calculate_block_multiplier(200.0), 0.625), "50 percent BlockChance with 75 percent reduction must produce a 0.625 expected multiplier.")
	assert(is_equal_approx(resolver_script.calculate_mitigated_damage(100.0, "physical", 100.0, 0.0, false), 50.0), "100 Armor must reduce a 100 physical hit to 50.")
	assert(is_equal_approx(resolver_script.calculate_mitigated_damage(100.0, "physical", 100.0, 0.0, true), 12.5), "Block must leave 25 percent before Armor.")
	assert(is_equal_approx(resolver_script.calculate_mitigated_damage(100.0, "fire", 0.0, 100.0, true), 12.5), "Block must apply before elemental Resistance.")

	print("PASS: Prototype 0.2 hit, mitigation, Resistance, and Block formulas are centralized.")
	quit()
