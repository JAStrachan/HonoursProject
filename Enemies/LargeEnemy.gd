extends "res://Enemies/Enemy.gd"

func _ready():
	Global.largeEnemyCount += 1
	
func deathCount():
	# Is overridden in child classes
	Global.largeEnemyCount -= 1