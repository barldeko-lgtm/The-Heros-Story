extends SceneTree

func _init() -> void:
	var path := "res://scripts/hero/hero_background.gd"
	if not ResourceLoader.exists(path):
		printerr("FAIL: HeroBackground is missing.")
		quit(1)
		return
	var background = load(path).new()
	var questions: Array = background.questions
	assert(questions.size() == 4)
	assert(questions[0].answers.size() == 5)
	for question in questions.slice(1):
		assert(question.answers.size() == 4)
	var childhood_deltas: Dictionary = {}
	for option in questions[1].answers:
		assert(option.attribute == "" and absi(int(option.delta)) == 20)
		childhood_deltas[option.axis] = int(option.delta)
	assert(childhood_deltas.size() == 4)
	for question in questions.slice(2):
		var stats: Array = []
		var axes: Array = []
		for option in question.answers:
			stats.append(option.attribute)
			axes.append(option.axis)
			assert(int(option.delta) * 2 == -int(childhood_deltas[option.axis]))
		stats.sort()
		axes.sort()
		assert(stats == ["constitution", "dexterity", "intelligence", "strength"])
		assert(axes == ["courage", "curiosity", "greed", "morality"])
	assert(questions[2].answers[1].attribute == "constitution")
	for family in range(5):
		for childhood in range(4):
			for youth in range(4):
				for departure in range(4):
					var result: Dictionary = background.resolve_answers([family, childhood, youth, departure])
					assert(not result.is_empty())
					var total: int = 0
					for amount in result.attributes.values():
						total += int(amount)
					assert(total == 3, "Every background must grant exactly three attribute points.")
					for value in result.personality.values():
						assert(absi(int(value)) <= 20, "No background may establish a visible trait.")
	assert(background.resolve_answers([]).is_empty())
	assert(background.resolve_answers([0, 0, 0]).is_empty())
	assert(background.resolve_answers([5, 0, 0, 0]).is_empty())
	assert(background.resolve_answers([0, -1, 0, 0]).is_empty())
	assert(background.resolve_answers([0, 0.5, 0, 0]).is_empty())
	var hero = load("res://scripts/hero/hero_state.gd").new("Background test")
	var traits = load("res://scripts/hero/trait_development.gd").new()
	traits.apply_starting_traits(hero, ["brave"])
	assert(not background.apply_to(hero, traits, [0, -1, 0, 0]))
	assert(hero.strength == 5 and traits.get_axis_value(hero, "courage") == 40)
	assert(background.apply_to(hero, traits, [0, 0, 3, 1]))
	assert(hero.strength == 6 and hero.intelligence == 6 and hero.constitution == 6)
	assert(hero.pending_primary_attribute_points == 0)
	assert(traits.get_established_traits(hero).is_empty())
	assert(traits.get_axis_value(hero, "courage") == 0, "+20 Brave and two +10 Cautious must cancel.")
	assert(hero.background_answers == [0, 0, 3, 1])
	assert(not background.apply_to(hero, traits, [1, 1, 1, 1]), "Background cannot be applied twice.")
	assert(hero.strength == 6 and hero.dexterity == 5)
	print("PASS: background choices validate atomically, grant three points, cancel opposite shifts and apply once.")
	quit()
