extends "res://Enemies/Enemy.gd"

func _ready():
	Global.largeEnemyCount += 1
	
func death():
	Global.update_enemy_death_count()
	
	target = null
	blackboard.set("target", target, behaviourTree, self)
	emit_signal("enemy_death", score_to_add)
	Global.largeEnemyCount -= 1
	queue_free()
	