extends "res://addons/godot-behavior-tree-plugin/condition.gd"

# Stops this branch from executing if the line of sight isn't achievable, moves to the TrackingThreat action

func tick(tick):
	if tick.actor.detect_enemies():
		return OK
	else:
		return FAILED
	