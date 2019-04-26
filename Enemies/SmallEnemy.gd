extends "res://Enemies/Enemy.gd"

func _ready():
	Global.smallEnemyCount += 1
	
func death():
	Global.update_enemy_death_count()
	
	target = null
	blackboard.set("target", target, behaviourTree, self)
	emit_signal("enemy_death", score_to_add)
	Global.smallEnemyCount -= 1
	
	queue_free()
	
	
## Overriding this method because the small enemies cannot heal
func heal(health_boost):
	pass