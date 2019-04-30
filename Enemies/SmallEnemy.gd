extends "res://Enemies/Enemy.gd"

func _ready():
	Global.smallEnemyCount += 1
	
## Overriding this method because the small enemies cannot heal
func heal(health_boost):
	pass
	
func deathCount():
	Global.smallEnemyCount -= 1