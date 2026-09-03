class_name PotionPreparationSystem
extends RefCounted

const BeltPotionRulesScript = preload("res://scripts/items/belt_potion_rules.gd")

const HEALING_EPSILON: float = 0.0001

var belt_rules = BeltPotionRulesScript.new()

func get_full_loadout_plan(hero_state, potion_definitions: Array, belt_item_override = null, available_gold_override: int = -1) -> Dictionary:
	var result: Dictionary = {
		"can_prepare": false,
		"reason": "invalid_state",
		"capacity": 0,
		"desired_levels": [],
		"purchase_counts": {},
		"purchase_cost": 0,
		"total_healing": 0.0,
	}
	if hero_state == null or hero_state.inventory == null or hero_state.equipment == null:
		return result

	var belt_item = belt_item_override if belt_item_override != null else hero_state.equipment.get_item("belt")
	var available_gold: int = hero_state.gold if available_gold_override < 0 else mini(hero_state.gold, available_gold_override)
	var capacity: int = belt_rules.get_capacity(belt_item)
	result["capacity"] = capacity
	if capacity <= 0:
		result["reason"] = "no_belt"
		return result

	var legal_definitions: Array = []
	for potion_definition in potion_definitions:
		if potion_definition != null and potion_definition.potion_level <= belt_rules.get_max_potion_level(belt_item):
			legal_definitions.append(potion_definition)
	if legal_definitions.is_empty():
		result["reason"] = "no_legal_potions"
		return result

	var combinations: Array = []
	build_loadout_combinations(legal_definitions, capacity, [], combinations)
	var inventory_counts: Dictionary = hero_state.inventory.get_healing_potion_counts()
	for desired_definitions in combinations:
		var desired_counts: Dictionary = {}
		var desired_levels: Array = []
		var purchase_counts: Dictionary = {}
		var purchase_cost: int = 0
		var total_healing: float = 0.0
		for potion_definition in desired_definitions:
			var level: int = int(potion_definition.potion_level)
			desired_levels.append(level)
			desired_counts[level] = int(desired_counts.get(level, 0)) + 1
			total_healing += float(potion_definition.healing_amount)
		for level in desired_counts:
			var missing_count: int = maxi(0, int(desired_counts[level]) - int(inventory_counts.get(level, 0)))
			if missing_count <= 0:
				continue
			var potion_definition = find_definition_by_level(legal_definitions, int(level))
			if potion_definition == null:
				purchase_cost = available_gold + 1
				break
			purchase_counts[level] = missing_count
			purchase_cost += missing_count * int(potion_definition.shop_price)
		if purchase_cost > available_gold:
			continue

		var is_better: bool = not bool(result["can_prepare"])
		if not is_better and total_healing > float(result["total_healing"]) + HEALING_EPSILON:
			is_better = true
		elif not is_better and is_equal_approx(total_healing, float(result["total_healing"])) and purchase_cost < int(result["purchase_cost"]):
			is_better = true
		if not is_better:
			continue

		result["can_prepare"] = true
		result["reason"] = "ready"
		result["desired_levels"] = desired_levels
		result["purchase_counts"] = purchase_counts
		result["purchase_cost"] = purchase_cost
		result["total_healing"] = total_healing

	if not bool(result["can_prepare"]):
		result["reason"] = "insufficient_gold"
	return result

func prepare_full_loadout(hero_state, potion_definitions: Array) -> Dictionary:
	var plan: Dictionary = get_full_loadout_plan(hero_state, potion_definitions)
	if not bool(plan.get("can_prepare", false)):
		return plan

	for level in plan["purchase_counts"]:
		var count: int = int(plan["purchase_counts"][level])
		var potion_definition = find_definition_by_level(potion_definitions, int(level))
		assert(potion_definition != null, "Prepared potion level must exist in the current shop potion definitions.")
		var cost: int = count * int(potion_definition.shop_price)
		assert(hero_state.gold >= cost, "Potion preparation plan must remain affordable when executed.")
		hero_state.gold -= cost
		hero_state.inventory.add_healing_potion(int(level), count)

	hero_state.prepared_healing_potion_levels = plan["desired_levels"].duplicate()
	return plan

func use_between_fight_potions(hero_state, max_hp: float, next_is_boss: bool, potion_definitions: Array) -> Dictionary:
	var result: Dictionary = {
		"consumed_levels": [],
		"consumed_count": 0,
		"raw_healing": 0.0,
		"actual_healing": 0.0,
		"overheal": 0.0,
	}
	if hero_state == null or hero_state.inventory == null or max_hp <= 0.0:
		return result
	var hp_before: float = clampf(hero_state.current_hp, 0.0, max_hp)
	var missing_hp: float = maxf(0.0, max_hp - hp_before)
	if missing_hp <= HEALING_EPSILON:
		return result

	prune_unavailable_prepared_potions(hero_state)
	if hero_state.prepared_healing_potion_levels.is_empty():
		return result

	var selected_indices: Array[int] = []
	if next_is_boss:
		selected_indices = select_boss_potions(hero_state.prepared_healing_potion_levels, missing_hp, potion_definitions)
	else:
		selected_indices = select_efficient_ordinary_potions(hero_state.prepared_healing_potion_levels, missing_hp, potion_definitions)
	if selected_indices.is_empty():
		return result

	selected_indices.sort()
	selected_indices.reverse()
	var raw_healing: float = 0.0
	var consumed_levels: Array = []
	for prepared_index in selected_indices:
		var level: int = int(hero_state.prepared_healing_potion_levels[prepared_index])
		var potion_definition = find_definition_by_level(potion_definitions, level)
		if potion_definition == null or not hero_state.inventory.remove_healing_potion(level):
			continue
		raw_healing += float(potion_definition.healing_amount)
		consumed_levels.append(level)
		hero_state.prepared_healing_potion_levels.remove_at(prepared_index)

	hero_state.current_hp = minf(max_hp, hp_before + raw_healing)
	result["consumed_levels"] = consumed_levels
	result["consumed_count"] = consumed_levels.size()
	result["raw_healing"] = raw_healing
	result["actual_healing"] = hero_state.current_hp - hp_before
	result["overheal"] = maxf(0.0, raw_healing - float(result["actual_healing"]))
	return result

func build_loadout_combinations(legal_definitions: Array, remaining_slots: int, current: Array, output: Array) -> void:
	if remaining_slots <= 0:
		output.append(current.duplicate())
		return
	for potion_definition in legal_definitions:
		current.append(potion_definition)
		build_loadout_combinations(legal_definitions, remaining_slots - 1, current, output)
		current.pop_back()

func select_efficient_ordinary_potions(prepared_levels: Array, missing_hp: float, potion_definitions: Array) -> Array[int]:
	var valid_indices: Array[int] = []
	for index in prepared_levels.size():
		if find_definition_by_level(potion_definitions, int(prepared_levels[index])) != null:
			valid_indices.append(index)
	if valid_indices.is_empty():
		return []

	var best_indices: Array[int] = []
	var best_total: float = 0.0
	var subset_count: int = 1 << valid_indices.size()
	for mask in range(1, subset_count):
		var total_healing: float = 0.0
		var subset: Array[int] = []
		for local_index in valid_indices.size():
			if (mask & (1 << local_index)) == 0:
				continue
			var prepared_index: int = valid_indices[local_index]
			var potion_definition = find_definition_by_level(potion_definitions, int(prepared_levels[prepared_index]))
			total_healing += float(potion_definition.healing_amount)
			subset.append(prepared_index)
		if total_healing > missing_hp + HEALING_EPSILON:
			continue
		if total_healing > best_total + HEALING_EPSILON or (is_equal_approx(total_healing, best_total) and (best_indices.is_empty() or subset.size() < best_indices.size())):
			best_total = total_healing
			best_indices = subset
	return best_indices

func select_boss_potions(prepared_levels: Array, missing_hp: float, potion_definitions: Array) -> Array[int]:
	var valid_indices: Array[int] = []
	for index in prepared_levels.size():
		if find_definition_by_level(potion_definitions, int(prepared_levels[index])) != null:
			valid_indices.append(index)
	if valid_indices.is_empty():
		return []

	var best_indices: Array[int] = []
	var best_total: float = INF
	var subset_count: int = 1 << valid_indices.size()
	for mask in range(1, subset_count):
		var total_healing: float = 0.0
		var subset: Array[int] = []
		for local_index in valid_indices.size():
			if (mask & (1 << local_index)) == 0:
				continue
			var prepared_index: int = valid_indices[local_index]
			var potion_definition = find_definition_by_level(potion_definitions, int(prepared_levels[prepared_index]))
			total_healing += float(potion_definition.healing_amount)
			subset.append(prepared_index)
		if total_healing + HEALING_EPSILON < missing_hp:
			continue
		if total_healing < best_total - HEALING_EPSILON or (is_equal_approx(total_healing, best_total) and subset.size() < best_indices.size()):
			best_total = total_healing
			best_indices = subset

	if not best_indices.is_empty():
		return best_indices
	return valid_indices

func prune_unavailable_prepared_potions(hero_state) -> void:
	var remaining_counts: Dictionary = hero_state.inventory.get_healing_potion_counts()
	var valid_prepared: Array = []
	for level_value in hero_state.prepared_healing_potion_levels:
		var level: int = int(level_value)
		var available: int = int(remaining_counts.get(level, 0))
		if available <= 0:
			continue
		valid_prepared.append(level)
		remaining_counts[level] = available - 1
	hero_state.prepared_healing_potion_levels = valid_prepared

func find_definition_by_level(potion_definitions: Array, potion_level: int):
	for potion_definition in potion_definitions:
		if potion_definition != null and int(potion_definition.potion_level) == potion_level:
			return potion_definition
	return null
