class_name SeededRng
extends RefCounted

var seed_value: int
var random_number_generator: RandomNumberGenerator = RandomNumberGenerator.new()

func _init(initial_seed: int) -> void:
	seed_value = initial_seed
	random_number_generator.seed = seed_value

func get_rng() -> RandomNumberGenerator:
	return random_number_generator
