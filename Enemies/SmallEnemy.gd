extends "res://Enemies/Enemy.gd"

func _ready():
	Global.smallEnemyCount += 1
	
func death():
	Global.update_enemy_death_count()
		
	emit_signal("enemy_death", score_to_add)
	queue_free()
	Global.smallEnemyCount -= 1
	
## Overriding this method because the small enemies cannot heal
#func heal(health_boost):
#	pass