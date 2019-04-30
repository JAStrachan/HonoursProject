extends "res://addons/godot-behavior-tree-plugin/action.gd"

# Behaviour for moving towards a target that has been detected.

func tick(tick):
	
	var target = tick.blackboard.get("target", tick.tree, tick.actor)
	var DISTANCE_FROM_THREAT = tick.blackboard.get("distance_from_threat", tick.tree, tick.actor)
	
	tick.actor.get_world_path(target.position)
	var distanceToTarget = tick.actor.position.distance_to(target.position)
	
	var line_of_sight = getLineOfSight(tick)

	if distanceToTarget > DISTANCE_FROM_THREAT + 10 or not line_of_sight:
		tick.actor.moving_through_path() #goes to chase state
		tick.actor.detection_area_colour = Color(1,0,0,0.1) # red
	else:
		tick.actor.stop_movement() # goes to ranged attack state
		tick.actor.detection_area_colour = Color(0, 0.764, 0.819,0.1) # cyan-ish
		
	return OK
	
func getLineOfSight(tick):
	var line_of_sight = tick.actor.detect_enemies()
	if line_of_sight:
		tick.blackboard.set("line_of_sight", line_of_sight, tick.tree, tick.actor)
	else:
		tick.blackboard.set("line_of_sight", line_of_sight, tick.tree, tick.actor)
	return line_of_sight