extends "res://Enemies/Enemy.gd"

# The medium enemy script. The general parent enemy is based off this one so not much is needed to change

func _ready():
	Global.mediumEnemyCount += 1

func deathCount():
	# Is overridden in child classes
	Global.mediumEnemyCount -= 1