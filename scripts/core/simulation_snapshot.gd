class_name SimulationSnapshot
extends RefCounted

## Explicit, JSON-safe graph snapshot for mutable Simulation state.
const VERSION := 1
const SimulationScript = preload("res://scripts/core/simulation.gd")
const WorldClockScript = preload("res://scripts/core/world_clock.gd")
const SeededRngScript = preload("res://scripts/core/seeded_rng.gd")
const HexMapScript = preload("res://scripts/world/hex_map.gd")
const WorldStateScript = preload("res://scripts/world/world_state.gd")
const TravelSystemScript = preload("res://scripts/world/travel_system.gd")
const DungeonSystemScript = preload("res://scripts/dungeons/dungeon_system.gd")
const DungeonRunnerScript = preload("res://scripts/dungeons/dungeon_runner.gd")
const EventSystemScript = preload("res://scripts/events/event_system.gd")
const EventRunnerScript = preload("res://scripts/events/event_runner.gd")
const HeroStateScript = preload("res://scripts/hero/hero_state.gd")
const EquipmentScript = preload("res://scripts/hero/equipment.gd")
const InventoryScript = preload("res://scripts/hero/inventory.gd")
const CombatStatsScript = preload("res://scripts/model/runtime/combat_stats.gd")
const HexDefinitionScript = preload("res://scripts/model/definitions/hex_definition.gd")
const CombatActionScript = preload("res://scripts/combat/combat_action.gd")
const CombatSessionScript = preload("res://scripts/combat/combat_session.gd")
const DungeonInstanceScript = preload("res://scripts/model/runtime/dungeon_instance.gd")
const EventInstanceScript = preload("res://scripts/model/runtime/event_instance.gd")
const ItemInstanceScript = preload("res://scripts/model/runtime/item_instance.gd")
const QuestOfferScript = preload("res://scripts/model/runtime/quest_offer.gd")
const QuestPoolScript = preload("res://scripts/quests/quest_pool.gd")
const QuestRunnerScript = preload("res://scripts/quests/quest_runner.gd")
const ShopSystemScript = preload("res://scripts/economy/shop_system.gd")
const GodStateScript = preload("res://scripts/god/god_state.gd")
const GodSystemScript = preload("res://scripts/god/god_system.gd")
const DebugLogScript = preload("res://scripts/narrative/debug_log.gd")
const DiaryScript = preload("res://scripts/narrative/diary.gd")
const DiaryRecorderScript = preload("res://scripts/narrative/diary_recorder.gd")
const DiaryNarratorScript = preload("res://scripts/narrative/diary_narrator.gd")

const MAX_NODES := 10000
const MAX_DEPTH := 64
const DATA_PREFIX := "res://data/"

static func capture(simulation) -> Dictionary:
	if simulation == null or not simulation is Simulation:
		return {"error": "capture requires a Simulation"}
	var context := {"nodes": [], "ids": {}, "error": ""}
	var root = _encode(simulation, context, 0)
	if not str(context.error).is_empty():
		return {"error": context.error}
	return {"version": VERSION, "root": root, "nodes": context.nodes}

static func restore(data: Dictionary) -> Dictionary:
	if not data.get("version") is int or data.get("version") != VERSION:
		return {"simulation": null, "error": "unsupported snapshot version"}
	var validation_error := _validate_snapshot(data)
	if not validation_error.is_empty():
		return {"simulation": null, "error": validation_error}
	var nodes: Array = data.nodes
	var root_id: int = data.root.ref
	var root_node: Dictionary = nodes[root_id]
	var properties: Dictionary = root_node.get("properties", {})
	var seed := _encoded_int(properties.get("simulation_seed"), 1)
	var autonomous := _encoded_bool(properties.get("autonomous_quest_choice"), false)
	var events := _encoded_bool(properties.get("temporary_events_enabled"), false)
	# Saved creation state is hydrated below, not replayed through the questionnaire.
	var simulation = SimulationScript.new(seed, null if autonomous else SimulationScript.DefaultInitialQuest, [], events)
	var context := {"nodes": nodes, "objects": {}, "error": "", "root_id": root_id, "root": simulation}
	var decoded = _decode(data.root, context, 0)
	if not str(context.error).is_empty() or decoded != simulation:
		return {"simulation": null, "error": str(context.error) if not str(context.error).is_empty() else "root decode failed"}
	# Constructor connections are intentionally restored only after state hydration.
	if not simulation.world_state.hero_position_changed.is_connected(simulation.on_hero_position_changed):
		simulation.world_state.hero_position_changed.connect(simulation.on_hero_position_changed)
	if not simulation.world_clock.tick_completed.is_connected(simulation.on_world_tick_completed):
		simulation.world_clock.tick_completed.connect(simulation.on_world_tick_completed)
	return {"simulation": simulation, "error": ""}

static func _encode(value, context: Dictionary, depth: int):
	if depth > MAX_DEPTH:
		context.error = "snapshot exceeds maximum graph depth"
		return null
	if value == null or value is bool or value is int or value is float or value is String:
		return value
	if value is Vector2i:
		return {"vector2i": [value.x, value.y]}
	if value is Vector2:
		return {"vector2": [value.x, value.y]}
	if value is PackedStringArray:
		return {"packed_string_array": Array(value)}
	if value is Array:
		var items: Array = []
		for item in value: items.append(_encode(item, context, depth + 1))
		return {"array": items}
	if value is Dictionary:
		var pairs: Array = []
		for key in value: pairs.append([_encode(key, context, depth + 1), _encode(value[key], context, depth + 1)])
		return {"dictionary": pairs}
	if value is RandomNumberGenerator:
		return _encode_rng(value, context)
	if value is Resource:
		var path: String = value.resource_path
		if not _is_allowed_resource_path(path):
			context.error = "resource outside allowlisted data path"
			return null
		return {"resource": path}
	if value is Object:
		var script = value.get_script()
		var path: String = script.resource_path if script != null else ""
		if not _is_allowed_script(path):
			context.error = "unallowlisted runtime type: %s" % path
			return null
		var key := str(value.get_instance_id())
		if context.ids.has(key): return {"ref": context.ids[key]}
		if context.nodes.size() >= MAX_NODES:
			context.error = "snapshot exceeds maximum node count"
			return null
		var id: int = context.nodes.size()
		context.ids[key] = id
		context.nodes.append({})
		var properties := {}
		for property in value.get_property_list():
			var name: String = str(property.name)
			# Godot 4 reports ordinary GDScript vars as SCRIPT_VARIABLE, not STORAGE.
			if name == "script" or not (int(property.usage) & PROPERTY_USAGE_SCRIPT_VARIABLE): continue
			properties[name] = _encode(value.get(name), context, depth + 1)
		context.nodes[id] = {"type": "object", "script": path, "properties": properties}
		return {"ref": id}
	context.error = "unsupported value type"
	return null

static func _decode(value, context: Dictionary, depth: int):
	if depth > MAX_DEPTH:
		context.error = "snapshot exceeds maximum graph depth"
		return null
	if not value is Dictionary: return value
	if value.has("vector2i"):
		var a: Array = value.vector2i
		if a.size() != 2: context.error = "invalid Vector2i"; return null
		return Vector2i(int(a[0]), int(a[1]))
	if value.has("vector2"):
		var b: Array = value.vector2
		if b.size() != 2: context.error = "invalid Vector2"; return null
		return Vector2(float(b[0]), float(b[1]))
	if value.has("packed_string_array"): return PackedStringArray(value.packed_string_array)
	if value.has("array"):
		var array: Array = []
		for item in value.array: array.append(_decode(item, context, depth + 1))
		return array
	if value.has("dictionary"):
		var dictionary := {}
		for pair in value.dictionary:
			if not pair is Array or pair.size() != 2: context.error = "invalid dictionary pair"; return null
			dictionary[_decode(pair[0], context, depth + 1)] = _decode(pair[1], context, depth + 1)
		return dictionary

	if value.has("resource"):
		var path := str(value.resource)
		if not _is_allowed_resource_path(path): context.error = "resource outside allowlist"; return null
		var resource = load(path)
		if resource == null: context.error = "missing authored resource"; return null
		return resource
	if value.has("ref"):
		var id := int(value.ref)
		if id < 0 or id >= context.nodes.size(): context.error = "invalid object reference"; return null
		if context.objects.has(id): return context.objects[id]
		if id == context.root_id:
			context.objects[id] = context.root
			_hydrate(context.root, context.nodes[id], context, depth + 1)
			return context.root
		var node = context.nodes[id]
		if not node is Dictionary: context.error = "invalid object node"; return null
		if str(node.get("type", "")) == "rng":
			var rng := RandomNumberGenerator.new()
			rng.seed = int(node.get("seed", 0))
			rng.state = int(node.get("state", 0))
			context.objects[id] = rng
			return rng
		if str(node.get("type", "")) != "object": context.error = "invalid object node"; return null
		var object = _new_allowed(str(node.get("script", "")))
		if object == null: context.error = "unsupported runtime type: %s" % str(node.get("script", "")); return null
		context.objects[id] = object
		_hydrate(object, node, context, depth + 1)
		return object
	context.error = "unknown encoded value"
	return null

static func _hydrate(object, node: Dictionary, context: Dictionary, depth: int) -> void:
	var properties: Dictionary = node.get("properties", {})
	var property_info := {}
	for info in object.get_property_list():
		if str(info.name) == "script" or not (int(info.usage) & PROPERTY_USAGE_SCRIPT_VARIABLE):
			continue
		property_info[str(info.name)] = info
		if not properties.has(str(info.name)):
			context.error = "missing serialized property: %s" % str(info.name)
			return
	for name in properties:
		if not property_info.has(name):
			context.error = "unknown serialized property: %s" % str(name)
			return
		var value = _decode(properties[name], context, depth + 1)
		if not str(context.error).is_empty(): return
		if not _property_accepts_value(property_info[name], object.get(name), value):
			context.error = "invalid property type: %s" % str(name)
			return
		var current_value = object.get(name)
		if current_value is Array and current_value.is_typed():
			# Object.set silently refuses an untyped Array for a typed property.
			var typed_value: Array = current_value.duplicate()
			typed_value.assign(value)
			value = typed_value
		object.set(name, value)

static func _validate_snapshot(data: Dictionary) -> String:
	if not data.has("root") or not data.has("nodes") or not data.nodes is Array:
		return "malformed snapshot envelope"
	if not data.root is Dictionary or data.root.size() != 1 or not data.root.has("ref") or not data.root.ref is int:
		return "malformed snapshot graph"
	var nodes: Array = data.nodes
	if nodes.is_empty() or nodes.size() > MAX_NODES:
		return "malformed snapshot graph"
	var root_id: int = data.root.ref
	if root_id < 0 or root_id >= nodes.size() or not nodes[root_id] is Dictionary:
		return "invalid root reference"
	var root_node: Dictionary = nodes[root_id]
	if root_node.get("type") != "object" or root_node.get("script") != "res://scripts/core/simulation.gd":
		return "root is not Simulation"
	for node in nodes:
		var node_error := _validate_node(node, nodes)
		if not node_error.is_empty():
			return node_error
	return ""

static func _validate_node(node, nodes: Array) -> String:
	if not node is Dictionary or not node.has("type") or not node.type is String:
		return "invalid object node"
	if node.type == "rng":
		if node.size() != 3 or not node.has("seed") or not node.has("state") or not node.seed is int or not node.state is int:
			return "invalid RNG node"
		return ""
	if node.type != "object" or node.size() != 3 or not node.has("script") or not node.script is String or not node.has("properties") or not node.properties is Dictionary:
		return "invalid object node"
	if not _is_allowed_script(node.script):
		return "unsupported runtime type: %s" % node.script
	for property_name in node.properties:
		if not property_name is String:
			return "invalid serialized property name"
		var value_error := _validate_encoded_value(node.properties[property_name], nodes, 0)
		if not value_error.is_empty():
			return value_error
	return ""

static func _validate_encoded_value(value, nodes: Array, depth: int) -> String:
	if depth > MAX_DEPTH:
		return "snapshot exceeds maximum graph depth"
	if value == null or value is bool or value is int or value is float or value is String:
		return ""
	if not value is Dictionary or value.size() != 1:
		return "unknown encoded value"
	if value.has("vector2i"):
		var vector2i_value = value.vector2i
		if not vector2i_value is Array or vector2i_value.size() != 2 or not vector2i_value[0] is int or not vector2i_value[1] is int:
			return "invalid Vector2i"
		return ""
	if value.has("vector2"):
		var vector2_value = value.vector2
		if not vector2_value is Array or vector2_value.size() != 2 or not (vector2_value[0] is int or vector2_value[0] is float) or not (vector2_value[1] is int or vector2_value[1] is float):
			return "invalid Vector2"
		return ""
	if value.has("packed_string_array"):
		if not value.packed_string_array is Array:
			return "invalid PackedStringArray"
		for item in value.packed_string_array:
			if not item is String: return "invalid PackedStringArray"
		return ""
	if value.has("array"):
		if not value.array is Array: return "invalid encoded array"
		for item in value.array:
			var item_error := _validate_encoded_value(item, nodes, depth + 1)
			if not item_error.is_empty(): return item_error
		return ""
	if value.has("dictionary"):
		if not value.dictionary is Array: return "invalid encoded dictionary"
		for pair in value.dictionary:
			if not pair is Array or pair.size() != 2: return "invalid dictionary pair"
			var key_error := _validate_encoded_value(pair[0], nodes, depth + 1)
			if not key_error.is_empty(): return key_error
			var value_error := _validate_encoded_value(pair[1], nodes, depth + 1)
			if not value_error.is_empty(): return value_error
		return ""
	if value.has("resource"):
		return "" if value.resource is String and _is_allowed_resource_path(value.resource) else "resource outside allowlist"
	if value.has("ref"):
		if not value.ref is int or value.ref < 0 or value.ref >= nodes.size(): return "invalid object reference"
		return ""
	return "unknown encoded value"

static func _property_accepts_value(info: Dictionary, current_value, value) -> bool:
	var expected_type: int = int(info.get("type", TYPE_NIL))
	if value == null:
		# Constructed runtime owners are required; nullable activity fields start null.
		if current_value is Object and not current_value is Resource:
			return false
		return expected_type == TYPE_NIL or expected_type == TYPE_OBJECT
	if current_value is Object:
		if not value is Object or current_value.get_class() != value.get_class():
			return false
		if current_value.get_script() != value.get_script():
			return false
	match expected_type:
		# Untyped script variables still have a constructor default that gives us a
		# safe runtime shape without imposing a separate snapshot schema.
		TYPE_NIL: return current_value == null or typeof(value) == typeof(current_value)
		TYPE_BOOL: return value is bool
		TYPE_INT: return value is int
		TYPE_FLOAT: return value is int or value is float
		TYPE_STRING: return value is String
		TYPE_VECTOR2: return value is Vector2
		TYPE_VECTOR2I: return value is Vector2i
		TYPE_ARRAY:
			if not value is Array: return false
			if current_value is Array and current_value.is_typed():
				for item in value:
					if typeof(item) != current_value.get_typed_builtin(): return false
					if item is Object and current_value.get_typed_script() != null and item.get_script() != current_value.get_typed_script(): return false
			return true
		TYPE_DICTIONARY: return value is Dictionary
		TYPE_PACKED_STRING_ARRAY: return value is PackedStringArray
		TYPE_OBJECT: return value is Object
		_: return typeof(value) == expected_type

static func _encode_rng(rng: RandomNumberGenerator, context: Dictionary):
	var key := "rng:%d" % rng.get_instance_id()
	if context.ids.has(key): return {"ref": context.ids[key]}
	if context.nodes.size() >= MAX_NODES:
		context.error = "snapshot exceeds maximum node count"
		return null
	var id: int = context.nodes.size()
	context.ids[key] = id
	context.nodes.append({"type": "rng", "seed": rng.seed, "state": rng.state})
	return {"ref": id}

static func _is_allowed_script(path: String) -> bool:
	return path.begins_with("res://scripts/") and not path.begins_with("res://scripts/ui/")

static func _is_allowed_resource_path(path: String) -> bool:
	if not path.begins_with(DATA_PREFIX) or path.contains(".."):
		return false
	if not (path.ends_with(".tres") or path.ends_with(".res")):
		return false
	return path.simplify_path() == path

static func _new_allowed(path: String):
	match path:
		"res://scripts/core/world_clock.gd": return WorldClockScript.new()
		"res://scripts/core/seeded_rng.gd": return SeededRngScript.new(1)
		"res://scripts/world/hex_map.gd": return HexMapScript.new(SimulationScript.DefaultMapDefinition)
		"res://scripts/world/world_state.gd": return WorldStateScript.new(_dummy_hex_map())
		"res://scripts/world/travel_system.gd": return TravelSystemScript.new(_dummy_hex_map(), _dummy_world_state())
		"res://scripts/dungeons/dungeon_system.gd": return DungeonSystemScript.new([])
		"res://scripts/dungeons/dungeon_runner.gd": return DungeonRunnerScript.new(_dummy_travel_system())
		"res://scripts/events/event_system.gd": return EventSystemScript.new([])
		"res://scripts/events/event_runner.gd": return EventRunnerScript.new(_dummy_travel_system(), preload("res://scripts/hero/trait_development.gd").new(), RandomNumberGenerator.new())
		"res://scripts/hero/hero_state.gd": return HeroStateScript.new("")
		"res://scripts/hero/equipment.gd": return EquipmentScript.new()
		"res://scripts/hero/inventory.gd": return InventoryScript.new()
		"res://scripts/model/runtime/combat_stats.gd": return CombatStatsScript.new()
		"res://scripts/model/definitions/hex_definition.gd": return HexDefinitionScript.new(Vector2i.ZERO, "")
		"res://scripts/combat/combat_action.gd": return CombatActionScript.new("", 0.0, 0.0, false)
		"res://scripts/combat/combat_session.gd": return CombatSessionScript.new(_dummy_combat_stats(), _dummy_combat_stats())
		"res://scripts/model/runtime/dungeon_instance.gd": return DungeonInstanceScript.new(null, Vector2i.ZERO, "")
		"res://scripts/model/runtime/event_instance.gd": return EventInstanceScript.new(preload("res://data/events/starting_region/0001_old_clearing_ambush.tres"), Vector2i.ZERO, "", 0)
		"res://scripts/model/runtime/item_instance.gd": return ItemInstanceScript.new(preload("res://data/items/starting_equipment/worn_shirt.tres"), 1, 0, {}, [], 0.0, {})
		"res://scripts/model/runtime/quest_offer.gd": return QuestOfferScript.new(SimulationScript.DefaultInitialQuest, 0, 0.0, 0)
		"res://scripts/quests/quest_pool.gd": return QuestPoolScript.new()
		"res://scripts/quests/quest_runner.gd": return QuestRunnerScript.new(null)
		"res://scripts/economy/shop_system.gd": return ShopSystemScript.new(null, null, 1)
		"res://scripts/god/god_state.gd": return GodStateScript.new()
		"res://scripts/god/god_system.gd": return GodSystemScript.new(null)
		"res://scripts/narrative/debug_log.gd": return DebugLogScript.new()
		"res://scripts/narrative/diary.gd": return DiaryScript.new()
		"res://scripts/narrative/diary_recorder.gd": return DiaryRecorderScript.new(null)
		"res://scripts/narrative/diary_narrator.gd": return DiaryNarratorScript.new(null)
		"res://scripts/world/activity_placement_finder.gd": return preload("res://scripts/world/activity_placement_finder.gd").new()
		"res://scripts/events/event_decision_resolver.gd": return preload("res://scripts/events/event_decision_resolver.gd").new()
		"res://scripts/items/belt_potion_rules.gd": return preload("res://scripts/items/belt_potion_rules.gd").new()
		"res://scripts/loot/equipment_reward_system.gd": return preload("res://scripts/loot/equipment_reward_system.gd").new(null, null, null)
		"res://scripts/economy/item_price_calculator.gd": return preload("res://scripts/economy/item_price_calculator.gd").new()
		"res://scripts/economy/skill_training_system.gd": return preload("res://scripts/economy/skill_training_system.gd").new()
		_:
			# Stateless rule/narration objects have no constructor requirements.
			var script = _allowlisted_builtin(path)
			return script.new() if script != null else null

static func _allowlisted_builtin(path: String):
	var scripts := {
		"res://scripts/dungeons/dungeon_evaluator.gd": preload("res://scripts/dungeons/dungeon_evaluator.gd"),
		"res://scripts/hero/hero_progression.gd": preload("res://scripts/hero/hero_progression.gd"),
		"res://scripts/hero/stat_resolver.gd": preload("res://scripts/hero/stat_resolver.gd"),
		"res://scripts/hero/equipment_evaluator.gd": preload("res://scripts/hero/equipment_evaluator.gd"),
		"res://scripts/hero/trait_development.gd": preload("res://scripts/hero/trait_development.gd"),
		"res://scripts/combat/power_calculator.gd": preload("res://scripts/combat/power_calculator.gd"),
		"res://scripts/combat/combat_simulator.gd": preload("res://scripts/combat/combat_simulator.gd"),
		"res://scripts/loot/loot_generator.gd": preload("res://scripts/loot/loot_generator.gd"),
		"res://scripts/items/item_generator.gd": preload("res://scripts/items/item_generator.gd"),
		"res://scripts/economy/equipment_sale_system.gd": preload("res://scripts/economy/equipment_sale_system.gd"),
		"res://scripts/economy/spending_evaluator.gd": preload("res://scripts/economy/spending_evaluator.gd"),
		"res://scripts/economy/potion_preparation_system.gd": preload("res://scripts/economy/potion_preparation_system.gd"),
		"res://scripts/economy/dungeon_preparation_budget.gd": preload("res://scripts/economy/dungeon_preparation_budget.gd"),
		"res://scripts/quests/quest_evaluator.gd": preload("res://scripts/quests/quest_evaluator.gd"),
		"res://scripts/narrative/quest_narrator.gd": preload("res://scripts/narrative/quest_narrator.gd"),
		"res://scripts/narrative/dungeon_narrator.gd": preload("res://scripts/narrative/dungeon_narrator.gd"),
		"res://scripts/narrative/event_narrator.gd": preload("res://scripts/narrative/event_narrator.gd"),
		"res://scripts/narrative/economy_narrator.gd": preload("res://scripts/narrative/economy_narrator.gd"),
		"res://scripts/narrative/item_narrator.gd": preload("res://scripts/narrative/item_narrator.gd"),
	}
	return scripts.get(path)

static func _dummy_hex_map():
	return HexMapScript.new(SimulationScript.DefaultMapDefinition)

static func _dummy_world_state():
	return WorldStateScript.new(_dummy_hex_map())

static func _dummy_travel_system():
	var map = _dummy_hex_map()
	return TravelSystemScript.new(map, WorldStateScript.new(map))

static func _dummy_combat_stats():
	var stats = CombatStatsScript.new()
	stats.max_hp = 1.0
	stats.attack = 1.0
	stats.attack_speed = 1.0
	return stats

static func _encoded_int(value, fallback: int) -> int:
	return int(value) if value != null and not value is Dictionary else fallback
static func _encoded_bool(value, fallback: bool) -> bool:
	return bool(value) if value != null and not value is Dictionary else fallback
