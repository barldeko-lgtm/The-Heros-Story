extends SceneTree

const DungeonSystemScript = preload("res://scripts/dungeons/dungeon_system.gd")
const ProtectorDungeon = preload("res://data/dungeons/specialization/protector_bastion_last_watch.tres")
const SlayerDungeon = preload("res://data/dungeons/specialization/slayer_scarlet_fang_pit.tres")

func _init() -> void:
	assert(ProtectorDungeon != null and SlayerDungeon != null, "Both specialization dungeon definitions must load.")
	assert(ProtectorDungeon.ordinary_encounter_count == 2 and SlayerDungeon.ordinary_encounter_count == 2, "Both specialization trials must use exactly two ordinary enemies before the boss.")
	assert(absf(ProtectorDungeon.ordinary_mob_definition.get_power() - 340.0) <= 1.0, "Protector ordinary trial enemy must stay at approximately 340 Power.")
	assert(absf(SlayerDungeon.ordinary_mob_definition.get_power() - 340.0) <= 1.0, "Slayer ordinary trial enemy must stay at approximately 340 Power.")
	assert(absf(ProtectorDungeon.boss_mob_definition.get_power() - 420.0) <= 1.0, "Protector trial boss must stay at approximately 420 Power.")
	assert(absf(SlayerDungeon.boss_mob_definition.get_power() - 420.0) <= 1.0, "Slayer trial boss must stay at approximately 420 Power.")
	assert_same_combat_profile(ProtectorDungeon.ordinary_mob_definition, SlayerDungeon.ordinary_mob_definition, "ordinary")
	assert_same_combat_profile(ProtectorDungeon.boss_mob_definition, SlayerDungeon.boss_mob_definition, "boss")
	assert(ProtectorDungeon.completion_gold_reward == 0 and SlayerDungeon.completion_gold_reward == 0, "Specialization dungeon material rewards stay deferred until quest integration.")
	assert(ProtectorDungeon.completion_equipment_source == null and SlayerDungeon.completion_equipment_source == null, "Specialization dungeon equipment rewards stay deferred until quest integration.")

	var ordinary_system = DungeonSystemScript.new()
	for definition in ordinary_system.get_definitions():
		assert(definition.id != ProtectorDungeon.id and definition.id != SlayerDungeon.id, "Specialization dungeons must remain outside the ordinary automatic population until explicitly connected.")

	print("PASS: Protector/Slayer specialization dungeons are mirrored 2+boss trials at approximately 340/420 Power and remain excluded from ordinary auto-population.")
	quit()

func assert_same_combat_profile(left, right, label: String) -> void:
	for property_name in ["attack_damage_type", "max_hp", "attack", "attack_speed", "accuracy", "dodge", "armor", "fire_resistance", "cold_resistance", "lightning_resistance", "block", "crit_chance", "crit_damage", "experience_reward"]:
		assert(left.get(property_name) == right.get(property_name), "Mirrored %s specialization enemies must keep the same combat profile: %s" % [label, property_name])
