class_name ItemInstance
extends RefCounted

var definition: Resource

func _init(initial_definition: Resource) -> void:
	assert(initial_definition != null, "ItemInstance requires an ItemDefinition.")
	definition = initial_definition
