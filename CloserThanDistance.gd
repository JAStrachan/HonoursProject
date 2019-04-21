extends "res://addons/godot-behavior-tree-plugin/condition.gd"

# Checks if the npc is close enough to the threat, it doesn't want to get to close. If fail, goes to Chase action

func tick(tick):
	var target = tick.blackboard.get("target", tick, self)
	#var distanceToTarget = tick.actor.position.distance_to(target.position)