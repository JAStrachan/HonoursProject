extends "res://Enemies/Enemy.gd"

func _ready():
	Global.largeEnemyCount += 1
	
func death():
	Global.update_enemy_death_count()
		
	emit_signal("enemy_death", score_to_add)
	queue_free()
	Global.largeEnemyCount -= 1