extends "res://Enemies/SquadEnemy.gd"

func _ready():
	Global.mediumEnemyCount += 1
	
func death():
	Global.update_enemy_death_count()
	
	target = null
	blackboard.set("target", target, behaviourTree, self)
	Global.mediumEnemyCount -= 1
	emit_signal("enemy_death", score_to_add)
	
	queue_free()
	
func grunt():
	pass
	# defines that the enemy is a grunt because we can check for methods.
	# The automatic name generation that comes with spawning objects ruins
	# Checking names for objects
