extends "res://addons/godot-behavior-tree-plugin/condition.gd"

# Stops this branch from executing if the line of sight isn't achievable, moves to the TrackingThreat action

func tick(tick):
	var line_of_sight = tick.actor.detect_enemies()
	if line_of_sight:
		tick.blackboard.set("line_of_sight", line_of_sight, tick.tree)
		return OK
	else:
		return FAILED
	