extends "res://Enemies/SquadEnemy.gd"

func _ready():
	Global.smallEnemyCount += 1
	
func death():
	if inSquad:
		squadLeader._on_squad_members_death(self)
	Global.update_enemy_death_count()
	
	target = null
	blackboard.set("target", target, behaviourTree, self)
	emit_signal("enemy_death", score_to_add)
	Global.smallEnemyCount -= 1
	
	queue_free()
	
	
## Overriding this method because the small enemies cannot heal
func heal(health_boost):
	pass
	
func rat():
	pass
	# defines that the enemy is a rat because we can check for methods.
	# The automatic name generation that comes with spawning objects ruins
	# Checking names for objects

