extends "res://Enemies/Enemy.gd"

func _ready():
	Global.smallEnemyCount += 1
	behaviourTree = get_node('/root/Map/SmallEnemyTree')
	
func death():
	Global.update_enemy_death_count()
		
	emit_signal("enemy_death", score_to_add)
	queue_free()
	Global.smallEnemyCount -= 1