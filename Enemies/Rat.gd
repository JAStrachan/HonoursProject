extends "res://Enemies/SquadEnemy.gd"

func _ready():
	Global.smallEnemyCount += 1
	
## Overriding this method because the small enemies cannot heal
func heal(health_boost):
	pass
	
func deathCount():
	Global.smallEnemyCount -= 1
	
func rat():
	pass
	# defines that the enemy is a rat because we can check for methods.
	# The automatic name generation that comes with spawning objects ruins
	# Checking names for objects

