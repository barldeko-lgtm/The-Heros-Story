class_name GodState
extends RefCounted

const MAX_ENERGY: float = 100.0
const STARTING_ENERGY: float = 100.0
const ENERGY_RECOVERY_TICKS: int = 6
const ENERGY_RECOVERY_AMOUNT: float = 1.0

const HEALING_COST: float = 10.0
const HEALING_COOLDOWN_TICKS: int = 30
const COMBAT_BUFF_COST: float = 10.0
const COMBAT_BUFF_COOLDOWN_TICKS: int = 120
const COMBAT_BUFF_FIGHTS: int = 5
const COMBAT_BUFF_PHYSICAL_DAMAGE_MULTIPLIER: float = 1.15
const COMBAT_BUFF_EFFECT_ID: String = "divine_combat_blessing"
const QUEST_GUIDANCE_COST: float = 5.0
const QUEST_GUIDANCE_COOLDOWN_TICKS: int = 360
const QUEST_GUIDANCE_MODIFIER: float = 0.20
const RESURRECTION_COST_PER_REMAINING_TICK: float = 0.5

var energy: float = STARTING_ENERGY
var energy_recovery_tick_progress: int = 0
var healing_cooldown_ticks: int = 0
var combat_buff_cooldown_ticks: int = 0

var quest_guidance_cooldown_ticks: int = 0
var guided_quest_id: String = ""

func advance_world_tick() -> void:
	healing_cooldown_ticks = maxi(0, healing_cooldown_ticks - 1)
	combat_buff_cooldown_ticks = maxi(0, combat_buff_cooldown_ticks - 1)
	quest_guidance_cooldown_ticks = maxi(0, quest_guidance_cooldown_ticks - 1)

	energy_recovery_tick_progress += 1
	if energy_recovery_tick_progress >= ENERGY_RECOVERY_TICKS:
		energy_recovery_tick_progress = 0
		energy = minf(MAX_ENERGY, energy + ENERGY_RECOVERY_AMOUNT)

func try_activate_healing() -> bool:
	if healing_cooldown_ticks > 0 or not spend_energy(HEALING_COST):
		return false
	healing_cooldown_ticks = HEALING_COOLDOWN_TICKS
	return true

func try_activate_combat_buff(effect_is_active: bool) -> bool:
	if combat_buff_cooldown_ticks > 0 or effect_is_active or not spend_energy(COMBAT_BUFF_COST):
		return false
	combat_buff_cooldown_ticks = COMBAT_BUFF_COOLDOWN_TICKS
	return true

func try_set_quest_guidance(quest_id: String) -> bool:
	if quest_id.is_empty() or quest_guidance_cooldown_ticks > 0 or not spend_energy(QUEST_GUIDANCE_COST):
		return false
	quest_guidance_cooldown_ticks = QUEST_GUIDANCE_COOLDOWN_TICKS
	guided_quest_id = quest_id
	return true

func consume_quest_guidance() -> String:
	var result := guided_quest_id
	guided_quest_id = ""
	return result

func get_resurrection_cost(remaining_respawn_ticks: int) -> float:
	return float(maxi(0, remaining_respawn_ticks)) * RESURRECTION_COST_PER_REMAINING_TICK

func try_spend_resurrection(remaining_respawn_ticks: int) -> bool:
	if remaining_respawn_ticks <= 0:
		return false
	return spend_energy(get_resurrection_cost(remaining_respawn_ticks))

func spend_energy(cost: float) -> bool:
	if cost < 0.0 or energy + 0.000001 < cost:
		return false
	energy -= cost
	return true
