extends "res://addons/godot-behavior-tree-plugin/action.gd"

func tick(tick):
	var squad = tick.blackboard.get("squad",tick.tree, tick.actor)
	
	for squadMember in squad:
		if is_instance_valid(squadMember) and squadMember.has_method("is_enemy"):
			shoot(squadMember, tick)
	
	shoot(tick.actor, tick)
	
	return OK
	
func shoot(enemy, tick):
	if enemy.enemy_line_of_sight:
		enemy.shoot()