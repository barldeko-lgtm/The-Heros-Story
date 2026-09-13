extends SceneTree

const CombatSessionScript = preload("res://scripts/combat/combat_session.gd")
const CombatStatsScript = preload("res://scripts/model/runtime/combat_stats.gd")
const HeroProgressionScript = preload("res://scripts/hero/hero_progression.gd")
const HeroStateScript = preload("res://scripts/hero/hero_state.gd")

func _init() -> void:
	test_level_25_auto_unlock()
	test_shield_bash_priority_stun_and_fallback()
	test_crippling_blows_priority_damage_and_slow()
	test_attack_progress_rescaling()
	test_runtime_slow_expiration()
	print("PASS: Protector Shield Bash and Slayer Crippling Blows SL1 unlock at 25 and follow approved autonomous combat rules.")
	quit()

func test_level_25_auto_unlock() -> void:
	var progression = HeroProgressionScript.new()
	var protector = HeroStateScript.new("Защитник")
	protector.level = 24
	protector.hero_class_id = "protector"
	progression.apply_level_up(protector)
	assert(protector.level == 25 and protector.shield_bash_skill_level == 1, "Protector must learn Shield Bash SL1 automatically at Level 25.")
	assert(protector.crippling_blows_skill_level == 0, "Protector must not learn the Slayer skill.")

	var slayer = HeroStateScript.new("Истребитель")
	slayer.level = 24
	slayer.hero_class_id = "slayer"
	progression.apply_level_up(slayer)
	assert(slayer.level == 25 and slayer.crippling_blows_skill_level == 1, "Slayer must learn Crippling Blows SL1 automatically at Level 25.")
	assert(slayer.shield_bash_skill_level == 0, "Slayer must not learn the Protector skill.")

	var late_path = HeroStateScript.new("Поздний выбор")
	late_path.level = 25
	late_path.hero_class_id = "protector"
	assert(progression.ensure_first_specialization_skill(late_path), "A specialization fixed at or after Level 25 must receive its SL1 immediately.")
	assert(late_path.shield_bash_skill_level == 1, "Late Protector path must receive Shield Bash SL1.")

func test_shield_bash_priority_stun_and_fallback() -> void:
	var hero = make_stats(1000.0, 100.0, 1.0)
	var mob = make_stats(10000.0, 10.0, 1.0)
	mob.dodge = 1000000.0
	var session = CombatSessionScript.new(hero, mob, make_rng(10), 1.0, 1, 5, 0, 1, 0, true)
	session.rage = 100
	var actions: Array = session.advance(1.5)
	assert(actions.size() == 1 and actions[0].action_id == CombatSessionScript.SHIELD_BASH_ID, "Ready Shield Bash must take priority over Power Strike.")
	assert(actions[0].did_hit and is_zero_approx(actions[0].damage), "Shield Bash must be guaranteed and deal no direct damage.")
	assert(session.rage == 75, "Shield Bash must cost exactly 25 Rage.")
	assert(is_equal_approx(session.mob_next_attack_time, 5.0), "A 3-second SL1 stun must freeze the enemy's pending 2.0-second attack until 5.0 seconds.")

	actions = session.advance(2.0)
	assert(actions.size() == 1 and actions[0].action_id == CombatSessionScript.POWER_STRIKE_ID, "While Shield Bash is on cooldown, the ordinary Power Strike must be allowed on the next hero attack.")
	assert(session.mob_next_attack_time >= 5.0 - 0.000001, "Enemy attack progress must not accumulate during Shield Bash stun.")

	var no_shield = CombatSessionScript.new(hero, mob, make_rng(11), 1.0, 1, 5, 0, 1, 0, false)
	no_shield.rage = 30
	actions = no_shield.advance(1.5)
	assert(actions.size() == 1 and actions[0].action_id == CombatSessionScript.POWER_STRIKE_ID, "Shield Bash must require an equipped shield; Power Strike remains the fallback when no shield is present.")

	var wise = CombatSessionScript.new(hero, mob, make_rng(12), 1.0, 0, 105, 0, 1, 0, true)
	assert(is_equal_approx(wise.get_shield_bash_stun_duration(), 4.0), "WIS 105 must add exactly 1 second to the SL1 Shield Bash stun under the approved formula.")

func test_crippling_blows_priority_damage_and_slow() -> void:
	var hero = make_stats(1000.0, 100.0, 1.0)
	var mob = make_stats(10000.0, 10.0, 1.0)
	var session = CombatSessionScript.new(hero, mob, make_rng(20), 1.0, 1, 5, 0, 0, 1, true)
	session.rage = 100
	var actions: Array = session.advance(1.5)
	assert(actions.size() == 2, "Crippling Blows must replace one attack opportunity with exactly two strikes.")
	for action in actions:
		assert(action.action_id == CombatSessionScript.CRIPPLING_BLOWS_ID and action.did_hit, "Both deterministic Crippling Blows strikes must be recorded independently.")
		assert(is_equal_approx(action.damage, 65.0), "Each SL1 Crippling Blows strike must deal 0.65 of ordinary resolved weapon-hit damage before target defenses.")
	assert(session.rage == 75, "Crippling Blows must cost exactly 25 Rage.")
	assert(is_equal_approx(session.crippling_slow_reduction, 0.15), "SL1 Crippling Blows must reduce enemy Attack Speed by 15 percent at base WIS.")
	assert(is_equal_approx(session.crippling_slow_active_until, 11.5), "Crippling Blows slow must last exactly 10 seconds from the attack time.")
	var expected_slowed_interval := 2.0 / 0.85
	var expected_next_attack := 1.5 + expected_slowed_interval * 0.25
	assert(is_equal_approx(session.mob_attack_interval, expected_slowed_interval), "Attack Speed reduction must lengthen the enemy attack interval by the reciprocal speed multiplier.")
	assert(is_equal_approx(session.mob_next_attack_time, expected_next_attack), "Applying the slow must preserve the enemy's existing 75 percent attack progress.")

	actions = session.advance(2.0)
	var saw_power_strike := false
	for action in actions:
		if action.attacker_id == "hero" and action.action_id == CombatSessionScript.POWER_STRIKE_ID:
			saw_power_strike = true
	assert(saw_power_strike, "While Crippling Blows is on cooldown, Power Strike must be used when it is ready and Rage is sufficient.")

	var wise = CombatSessionScript.new(hero, mob, make_rng(21), 1.0, 0, 105, 0, 0, 1, true)
	assert(is_equal_approx(wise.get_crippling_blows_attack_speed_reduction(), 0.20), "WIS 105 must raise the SL1 Crippling Blows reduction from 15 to 20 percent.")

func test_attack_progress_rescaling() -> void:
	var session = CombatSessionScript.new(make_stats(1000.0, 10.0, 1.0), make_stats(1000.0, 1.0, 1.0))
	session.elapsed_seconds = 0.5
	session.apply_crippling_slow(0.15)
	assert(is_equal_approx(session.mob_next_attack_time, 2.264705882352941), "Slow application must preserve 25 percent completed attack progress.")
	session.elapsed_seconds = 1.0
	session.expire_crippling_slow()
	assert(is_equal_approx(session.mob_attack_interval, 2.0), "Slow expiration must restore the original enemy attack interval.")
	assert(is_equal_approx(session.mob_next_attack_time, 2.075), "Slow removal must preserve the current percentage of attack progress instead of resetting or granting free progress.")

func test_runtime_slow_expiration() -> void:
	var hero = make_stats(10000.0, 0.0, 1.0)
	var mob = make_stats(10000.0, 0.0, 1.0)
	var session = CombatSessionScript.new(hero, mob, make_rng(30), 1.0, 0, 5, 0, 0, 1, true)
	session.rage = 25
	var opening_actions: Array = session.advance(1.5)
	assert(opening_actions.size() == 2 and session.crippling_slow_reduction > 0.0, "Runtime slow-expiration probe must begin with Crippling Blows active.")
	session.advance(10.0)
	assert(is_zero_approx(session.crippling_slow_reduction) and is_zero_approx(session.crippling_slow_active_until), "The live combat scheduler must expire Crippling Blows after exactly 10 seconds.")
	assert(is_equal_approx(session.mob_attack_interval, 2.0), "Live slow expiration must restore the enemy's ordinary attack interval.")

func make_stats(max_hp: float, attack: float, attack_speed: float):
	var stats = CombatStatsScript.new()
	stats.max_hp = max_hp
	stats.attack = attack
	stats.attack_speed = attack_speed
	stats.accuracy = 100.0
	stats.dodge = 0.0
	stats.armor = 0.0
	stats.block = 0.0
	stats.crit_chance = 0.0
	stats.crit_damage = 1.5
	return stats

func make_rng(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng
