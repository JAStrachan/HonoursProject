extends "res://addons/godot-behavior-tree-plugin/condition.gd"

# Checks if the npc is close enough to the threat, it doesn't want to get to close. If fail, goes to Chase action

func tick(tick):
	var target = tick.blackboard.get("target", tick.tree)
	var DISTANCE_FROM_THREAT = tick.blackboard.get("distance_from_threat", tick.tree)
	var line_of_sight = tick.blackboard.get("line_of_sight", tick.tree)
	var distanceToTarget = tick.actor.position.distance_to(target.position)
	
	if distanceToTarget > DISTANCE_FROM_THREAT + 10 or not line_of_sight:
		return FAILED #goes to chase action
	else:
		return OK # goes to ranged attack  action