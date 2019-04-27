extends "res://addons/godot-behavior-tree-plugin/action.gd"

func tick(tick):
	var squad = tick.blackboard.get("squad",tick.tree, tick.actor)
	var target = tick.blackboard.get("target", tick.tree, tick.actor)
	for squadMember in squad:
		if is_instance_valid(squadMember):
			moveToAttack(squadMember, target, tick)
	
	moveToAttack(tick.actor, target, tick)
	
	return OK
	
func moveToAttack(enemy, target, tick):
	
	var DISTANCE_FROM_THREAT = enemy.DISTANCE_FROM_THREAT #tick.blackboard.get("distance_from_threat", tick.tree, tick.actor)

	enemy.get_world_path(target.position)
	var distanceToTarget = enemy.position.distance_to(target.position)
	
	var line_of_sight = enemy.detect_enemies()
	if line_of_sight:
		# the tick.actor is because the node scope is referencing the actor, in this case the commander
		tick.blackboard.set("line_of_sight", line_of_sight, tick.tree, tick.actor)
	else:
		tick.blackboard.set("line_of_sight", line_of_sight, tick.tree, tick.actor)
		
	if distanceToTarget > DISTANCE_FROM_THREAT + 10 or not line_of_sight:
		enemy.moving_through_path() #goes to chase state
		
		enemy.detection_area_colour = Color(1,0,0,0.1) # red
	else:
		enemy.stop_movement() # goes to ranged attack state
		enemy.detection_area_colour = Color(0, 0.764, 0.819,0.1) # cyan-ish