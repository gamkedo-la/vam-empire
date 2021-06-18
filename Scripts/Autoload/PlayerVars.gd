extends Node

signal target_change
signal shield_health_changed(val, change_amount)
signal shield_max_health_changed(val, change_amount)

signal hull_health_changed(val, change_amount)
signal hull_max_health_changed(val, change_amount)

signal energy_reserve_changed(val, change_amount)
signal energy_max_reserve_changed(val, change_amount)

signal picked_up
signal mission_updated
signal mission_complete

signal item_transfer(uuid)

signal player_died

signal attraction_changed

# File saving/loading methodology adapted from https://gdscript.com/solutions/how-to-save-and-load-godot-game-data/
var FILE_NAME

var player_node = null

# For instantiating a new player file
var player_defaults = {
	"name": " ",
	"cash": 10000,
	"current_ship": "res://Ships/StarterShip.tscn"	
}

var player = player_defaults

# Items currently stored on player ship
var ship_inventory = {}

# All items stored in player stash
var master_inventory = {}

var mission_state = {}

var target = null setget set_target, get_target

# Variables originally kept in Player.gd
var shield_health = 0 setget set_shield_health
var hull_health = 0 setget set_hull_health
var energy_reserve = 0 setget set_energy_reserve
var shield_max_health = 0 setget set_shield_max_health
var hull_max_health = 0 setget set_hull_max_health
var energy_max_reserve = 0 setget set_energy_max_reserve
var energy_recovery_per_s = 0 setget set_energy_recovery_per_s
var energy_recovery_delay_s = 0 setget set_energy_recovery_delay

# Enemy threat
var enemy_attraction:int = 0 setget set_enemy_attraction

func _ready():
	FILE_NAME = UserSettings.get_save_slot(UserSettings.current.save.current_slot)
	print("Current Player Save: ", FILE_NAME)

func set_target(val):
	if target:
		target.unset_target()
	target = val
	emit_signal("target_change", target)

func get_target():
	return target

func emit_signal_if_value_changed(signal_name, value, change_amount):
	if change_amount != 0:
		emit_signal(signal_name, value, change_amount)

func set_shield_health(val):
	var previous_val = shield_health
	shield_health = val
	shield_health = clamp(shield_health, 0, shield_max_health)
	emit_signal_if_value_changed("shield_health_changed", shield_health, shield_health - previous_val)
	
func set_hull_health(val):
	var previous_val = hull_health
	hull_health = val
	hull_health = clamp(hull_health, 0, hull_max_health)
	if hull_health <= 0:
		print_debug("Player died...")
		emit_signal("player_died")
	
	emit_signal_if_value_changed("hull_health_changed", hull_health, hull_health - previous_val)
	
func set_energy_reserve(val):
	var previous_val = energy_reserve
	energy_reserve = val
	energy_reserve = clamp(energy_reserve, 0, energy_max_reserve)
	emit_signal_if_value_changed("energy_reserve_changed", energy_reserve, energy_reserve - previous_val)
	
func set_shield_max_health(val):
	var previous_val = shield_max_health
	shield_max_health = val
	self.shield_health = min(shield_health, shield_max_health)
	emit_signal_if_value_changed("shield_max_health_changed", shield_max_health, shield_max_health - previous_val)
	
func set_hull_max_health(val):
	var previous_val = hull_max_health
	hull_max_health = val
	self.hull_health = min(hull_health, hull_max_health)
	emit_signal_if_value_changed("hull_max_health_changed", shield_max_health, shield_max_health - previous_val)

func set_energy_max_reserve(val):
	var previous_val = energy_max_reserve
	energy_max_reserve = val
	self.energy_reserve = min(energy_reserve, energy_max_reserve)
	emit_signal_if_value_changed("energy_max_reserve_changed", energy_max_reserve, energy_max_reserve - previous_val)

func set_energy_recovery_per_s(val):
	energy_recovery_per_s = val

func set_energy_recovery_delay(val):
	energy_recovery_delay_s = val
	
func set_enemy_attraction(val:int) -> void:
	enemy_attraction = val
	emit_signal("attraction_changed", enemy_attraction)

func new(name: String):
	player = player_defaults.duplicate()
	player.name = name
	mission_state = {}
	ship_inventory = {}
	master_inventory = {}
	save()

func save():
#	print_debug("Saving Player Save...")
	var file = File.new()
	var save = {}
	save["player"] = player
	save["ship_inventory"] = ship_inventory
	save["master_inventory"] = master_inventory
	save["mission_state"] = mission_state
#	print_debug("Save file...: ", save)
	file.open(FILE_NAME, File.WRITE)
	file.store_string(JSON.print(save, "\t"))
	#file.store_string(to_json(save))
	file.close()

func set_save_slot(slot):
	UserSettings.set_current_slot(slot)
	FILE_NAME = UserSettings.get_save_slot(slot)

	
func get_save_summary(slot):
	var remember_slot = UserSettings.current.save.current_slot
	FILE_NAME = UserSettings.get_save_slot(slot)
	load_save()
	var summary = str(" Name: [color=red]", player.name, "[/color]\n Cash: [color=red]", player.cash, "[/color]")
	FILE_NAME = UserSettings.get_save_slot(remember_slot)
	load_save()
	return summary
	
	
func load_save():
	var file = File.new()	
	if file.file_exists(FILE_NAME):
		file.open(FILE_NAME, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			# Temporary to upconvert 'player' only saves
			if data.has_all(player_defaults.keys()):
				var temp_data = {}
				temp_data["player"] = data.duplicate(true)
				temp_data["ship_inventory"] = {}
				temp_data["master_inventory"] = {}
				temp_data["mission_state"] = {}
				data.clear()
				data = temp_data.duplicate()
			# Does the save file have all of the 'high level' dictionaries/keys i.e. Sound, Graphics, Difficulty?
			if data.player.has_all(player_defaults.keys()):
				for key in player_defaults.keys():
					# Is this key a nested dictionary? i.e Sound, Graphics, Difficulty
					if typeof(player_defaults[key]) == TYPE_DICTIONARY:
						if !data.player.has_all(player_defaults[key].keys()):
							for subkey in player_defaults[key].keys():
								# If the Save File was missing any sub-keys, i.e. UserSettings.sound.music_volume, replace 
								# that single setting with the user_default to avoid regenerating the entire config file from scratch
								if !data.player[key].has(subkey):
									print_debug("Setting [", subkey,"] from System Defaults.")
									data.player[key][subkey] = player_defaults[key][subkey]
					else:
						if !data.player.has(key):
							print_debug("Setting [", key,"] from System Defaults.")							
							data.player[key] = key
				
				player = data.player
				
				# Backwards compatibility for post-player-only and pre-inventory saves
				ship_inventory = data.ship_inventory if data.has("ship_inventory") else {}
				master_inventory = data.master_inventory if data.has("master_inventory") else {}
				mission_state = data.mission_state if data.has("mission_state") else {}
				save()
				return true
		else:
			printerr("Corrupted [Player Save] Save Data!")			
	else:
		printerr("No saved [Player Save] data to load")
	# No save data, version didn't match, or corrupted save file all lead to making a new() config file
	return false

func pickup_item(uuid: String, cnt: int):
	var inventory = player_node.get_ship_inventory()
	inventory.insert_item_by_uuid(uuid)	
	emit_signal("picked_up", uuid, cnt)
#	_increment_item_objective(uuid, cnt)

func increment_ship_inventory(uuid, cnt:int):
	if ship_inventory.has(uuid):
		ship_inventory[uuid] += cnt
	else:
		ship_inventory[uuid] = cnt
	#print_debug("PlayerVars.ship_inventory: ", ship_inventory)

func increment_master_inventory(uuid, cnt:int):
	if master_inventory.has(uuid):
		master_inventory[uuid] += cnt
	else:
		master_inventory[uuid] = cnt
	
	if master_inventory[uuid] <= 0:
		master_inventory.erase(uuid)

func _increment_item_objective(uuid: String, cnt: int) -> void:
	if mission_state.size() > 0:
		for mission in mission_state:
			print_debug(mission)
			if mission_state[mission].objectives.size() > 0:
				for objective in mission_state[mission].objectives:
					if objective.type == "item":
						if objective.has(uuid):
							if objective.complete < objective[uuid]:
								objective.complete += cnt
						print_debug(objective)

func transfer_ship_to_base() -> void:
	for inv_key in ship_inventory.keys():
		var ship_item_cnt = ship_inventory[inv_key]
		while ship_inventory[inv_key] > 0:
			increment_ship_inventory(inv_key, -1)
			increment_master_inventory(inv_key, 1)
			
			emit_signal("item_transfer", inv_key)
	ship_inventory.clear()
	save()

func clear_ship_inventory():
	ship_inventory.clear()

func old_load_save():
	var file = File.new()
	if file.file_exists(FILE_NAME):
		file.open(FILE_NAME, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			player = data
		else:
			printerr("Corrupted Player Save Data!")
	else:
		printerr("No saved data to load")

func save_exists(slot):
	var CHECK_SLOT = UserSettings.get_save_slot(slot)
	var file = File.new()
	if file.file_exists(CHECK_SLOT):
		return true
	else:
		return false

func delete_save(slot):
	var dir = Directory.new()
	
	dir.remove(UserSettings.get_save_slot(slot))

# Subtract health from either hull or shield by given amount. Negative value indicates healing
func take_damage(amount, position):
	if amount <= 1 && amount >= -1:
		return

	# We should update shield health when shields are up and we're taking damage, or hull is full and we're healing
	var update_shield = false
	if (amount > 0 && shield_health > 0) || (amount < 0 && hull_health == hull_max_health):
		update_shield = true

	if update_shield:
		var pre_shield = self.shield_health
		self.shield_health -= amount
		Effects.show_player_shield_dmg_text(position, int(round(amount)))
		if shield_health > pre_shield:
			Effects.emit_signal("ChargeShield", true)
	else:
		self.hull_health -= amount
		Effects.show_player_hp_dmg_text(position, int(round(amount)))

func accept_mission(miss:Mission) -> bool:
	mission_state[miss.mission_id] = {}	
	mission_state[miss.mission_id]["status"] = miss.status
	if miss.mission_type == Mission.MissionType.ITEM:
		mission_state[miss.mission_id]["goal"] = miss.item_goal
	elif miss.mission_type == Mission.MissionType.KILL:
		mission_state[miss.mission_id]["goal"] = miss.kill_goal
	mission_state[miss.mission_id]["completed"] = miss.completed
	mission_state[miss.mission_id]["name"] = miss.m_name

	save()
	return true
	
func complete_mission(miss:Mission) -> void:
	mission_state[miss.mission_id].status = Mission.Status.COMPLETE
	save()
