extends "res://addons/godot-behavior-tree-plugin/action.gd"

# The ranged attack action. Contains a test if ranged action is applicable

func tick(tick):
	var target = tick.blackboard.get("target", tick.tree)
	var DISTANCE_FROM_THREAT = tick.blackboard.get("distance_from_threat", tick.tree)
	var line_of_sight = tick.blackboard.get("line_of_sight", tick.tree)
	var distanceToTarget = tick.actor.position.distance_to(target.position)
	
	if distanceToTarget > DISTANCE_FROM_THREAT + 10 or not line_of_sight:
		return FAILED #goes to chase action
	else:
		tick.actor.velocity = Vector2(0,0)
		tick.actor.detection_area_colour = Color(0, 0.764, 0.819,0.1) # cyan-ish
		tick.actor.shoot()
		return OK # goes to ranged attack  action
