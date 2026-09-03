class_name HeroState
extends RefCounted

const EquipmentScript = preload("res://scripts/hero/equipment.gd")
const InventoryScript = preload("res://scripts/hero/inventory.gd")

const CHOOSING_QUEST := "CHOOSING_QUEST"
const TRAVEL_TO_QUEST := "TRAVEL_TO_QUEST"
const DOING_QUEST := "DOING_QUEST"
const RECOVERING_AFTER_FIGHT := "RECOVERING_AFTER_FIGHT"
const RETURNING_TO_CITY := "RETURNING_TO_CITY"
const TURNING_IN_QUEST := "TURNING_IN_QUEST"
const VISITING_MARKET := "VISITING_MARKET"
const SHOPPING := "SHOPPING"
const PREPARING_DUNGEON := "PREPARING_DUNGEON"
const TRAVEL_TO_DUNGEON := "TRAVEL_TO_DUNGEON"
const AT_DUNGEON_ENTRANCE := "AT_DUNGEON_ENTRANCE"
const DOING_DUNGEON := "DOING_DUNGEON"
const DUNGEON_BETWEEN_FIGHTS := "DUNGEON_BETWEEN_FIGHTS"
const DUNGEON_COMPLETED := "DUNGEON_COMPLETED"
const DUNGEON_RETURNING_TO_CITY := "DUNGEON_RETURNING_TO_CITY"
const DEAD_RESPAWNING := "DEAD_RESPAWNING"
const RECOVERING_IN_CITY := "RECOVERING_IN_CITY"

signal state_changed

var hero_name: String
var hero_class_id: String = "warrior"
var level: int = 1
var experience: int = 0
var experience_to_next_level: int = 1000
var strength: int = 5
var dexterity: int = 5
var intelligence: int = 5
var constitution: int = 5
var wisdom: int = 5
var power_strike_skill_level: int = 0
var battle_guard_skill_level: int = 0
var current_hp: float = 0.0
var gold: int = 0
var traits: Array[String] = []
var loop_state: String = CHOOSING_QUEST
var active_quest
var active_effects: Array[Dictionary] = []
var equipment = EquipmentScript.new()
var inventory = InventoryScript.new()
var prepared_healing_potion_levels: Array = []

func _init(initial_name: String) -> void:
	hero_name = initial_name
