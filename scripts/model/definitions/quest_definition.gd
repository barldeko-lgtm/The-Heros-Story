class_name QuestDefinition
extends Resource

@export var id: String
@export var display_name: String
@export var mob_definition: Resource

# Immutable template ranges. A QuestOffer owns the concrete rolled values.
@export var mob_count_min: int = 1
@export var mob_count_max: int = 1
@export var distance_km_min: int = 1
@export var distance_km_max: int = 1
@export var gold_per_mob_min: int = 0
@export var gold_per_mob_max: int = 0
