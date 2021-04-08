extends Node2D

export(String) var weap_name

enum WeapTypes {
	PHYS_PROJECTILE,
	ENERGY_PROJECTILE,
	LASER,
	MINING_LASER,
	MINING_DRILL,
	DRONE_BAY,
	 }
export (WeapTypes) var type
enum MountTypes {
	FIXED,
	GIMBALED
}
export (MountTypes) var mount

export(PackedScene) var projectile
export(PackedScene) var beam
