extends SceneTree

const HeroStateScript = preload("res://scripts/hero/hero_state.gd")
const TraitDevelopmentScript = preload("res://scripts/hero/trait_development.gd")

func _init() -> void:
	var hero = HeroStateScript.new("Тест")
	var traits = TraitDevelopmentScript.new()
	traits.apply_starting_traits(hero, [traits.TRAIT_BRAVE, traits.TRAIT_NOBLE])
	assert(traits.get_axis_value(hero, traits.AXIS_COURAGE) == 40, "Starting Brave must initialize Courage at +40.")
	assert(traits.get_axis_value(hero, traits.AXIS_MORALITY) == 40, "Starting Noble must initialize Morality at +40.")
	assert(traits.has_trait(hero, traits.TRAIT_BRAVE) and traits.has_trait(hero, traits.TRAIT_NOBLE), "Starting traits must become established immediately at their ±40 activation threshold.")
	traits.reset_state(hero)

	assert(traits.get_axis_value(hero, traits.AXIS_COURAGE) == 0)
	assert(not traits.has_trait(hero, traits.TRAIT_BRAVE))

	traits.apply_movement(hero, traits.AXIS_COURAGE, 39)
	assert(not traits.has_trait(hero, traits.TRAIT_BRAVE), "Brave must not activate before +40.")
	traits.apply_movement(hero, traits.AXIS_COURAGE, 1)
	assert(traits.has_trait(hero, traits.TRAIT_BRAVE), "Brave must activate at +40.")

	traits.apply_movement(hero, traits.AXIS_COURAGE, -19)
	assert(traits.has_trait(hero, traits.TRAIT_BRAVE), "Brave must remain established above +20.")
	traits.apply_movement(hero, traits.AXIS_COURAGE, -1)
	assert(not traits.has_trait(hero, traits.TRAIT_BRAVE), "Brave must return to neutral at +20.")

	traits.apply_movement(hero, traits.AXIS_COURAGE, -60)
	assert(traits.has_trait(hero, traits.TRAIT_CAUTIOUS), "Cautious must activate at -40 or below after returning to neutral.")
	traits.apply_movement(hero, traits.AXIS_COURAGE, 40)
	assert(not traits.has_trait(hero, traits.TRAIT_CAUTIOUS), "Cautious must return to neutral at -20.")
	assert(not traits.has_trait(hero, traits.TRAIT_BRAVE), "One large opposing movement must not jump directly from Cautious to Brave.")

	print("PASS: Final personality axes use ±40 activation and ±20 return-to-neutral hysteresis.")
	quit()
