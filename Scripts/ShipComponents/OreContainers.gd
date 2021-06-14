extends Node2D


var containers = []
var tracked_minerals = []

func _ready() -> void:
	for container in self.get_children():
		if container is Sprite:
			containers.append(container)
			container.connect("ready_for_work", self, "_assign_work")


func _mineral_removed(mineral:MineralDrop) -> void:
	if tracked_minerals.has(mineral):
		tracked_minerals.erase(mineral)

func _assign_work(container) -> void:
	if tracked_minerals.size() > 0:
		if !container.busy:
			container.retrieve_mineral(tracked_minerals[0])
			tracked_minerals[0].assigned_droid = true
			tracked_minerals.remove(0)

func _on_OrePickup_area_entered(area):
	var area_par = area.get_parent()
	if area_par.is_in_group("pickup"):
		area_par.pickup()



func _on_OreDetector_area_entered(area):
	var mineral = area.get_parent()
	print_debug(mineral)
	if mineral.is_in_group("pickup"):
		if !mineral.assigned_droid:
			for container in containers:
				if !container.busy:
					container.retrieve_mineral(mineral)
					mineral.assigned_droid = true
					return
			if !mineral.assigned_droid:
				tracked_minerals.append(mineral)
				mineral.connect("removed", self, "_mineral_removed")

