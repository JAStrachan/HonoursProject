extends "res://Enemies/SquadEnemy.gd"

func _ready():
	Global.mediumEnemyCount += 1

func deathCount():
	Global.mediumEnemyCount -= 1
	
func grunt():
	pass
	# defines that the enemy is a grunt because we can check for methods.
	# The automatic name generation that comes with spawning objects ruins
	# Checking names for objects
