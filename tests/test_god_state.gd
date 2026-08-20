extends SceneTree

const GodStateScript = preload("res://scripts/god/god_state.gd")

func _init() -> void:
	var god_state = GodStateScript.new()
	assert(is_equal_approx(god_state.energy, 100.0), "God energy must start full at 100.")

	assert(god_state.try_activate_healing(), "Healing must activate with enough energy and no cooldown.")
	assert(is_equal_approx(god_state.energy, 90.0), "Healing must cost 10 energy.")
	assert(god_state.healing_cooldown_ticks == 30, "Healing must start a 30-tick cooldown.")
	assert(not god_state.try_activate_healing(), "Healing must not reactivate during its cooldown.")

	for _tick in 6:
		god_state.advance_world_tick()
	assert(is_equal_approx(god_state.energy, 91.0), "God energy must recover by one every six world ticks.")
	assert(god_state.healing_cooldown_ticks == 24, "Cooldowns must decrease on every world tick.")

	assert(god_state.try_activate_combat_buff(false), "Combat buff must activate with enough energy and no active copy.")
	assert(god_state.combat_buff_cooldown_ticks == 120, "Combat buff must start a 120-tick cooldown.")
	assert(not god_state.try_activate_combat_buff(true), "GodState must reject activation while HeroState already owns the active effect.")

	assert(god_state.try_set_quest_guidance("wolf_hunt"), "Quest guidance must accept one available quest ID.")
	assert(god_state.quest_guidance_cooldown_ticks == 360, "Quest guidance must start a 360-tick cooldown.")
	assert(god_state.consume_quest_guidance() == "wolf_hunt", "Guidance must apply to exactly one next quest-selection action.")
	assert(god_state.consume_quest_guidance().is_empty(), "Consumed guidance must not survive another selection.")

	assert(is_equal_approx(god_state.get_resurrection_cost(20), 10.0), "Twenty remaining respawn ticks must cost 10 energy.")
	var energy_before_resurrection: float = god_state.energy
	assert(god_state.try_spend_resurrection(20), "Instant resurrection must spend energy when affordable.")
	assert(is_equal_approx(god_state.energy, energy_before_resurrection - 10.0), "Instant resurrection must deduct half the remaining ticks as energy.")

	print("PASS: GodState owns energy, recovery, cooldowns, guidance, and resurrection cost.")
	quit()
