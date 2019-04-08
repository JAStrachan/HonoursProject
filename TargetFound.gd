extends "res://addons/godot-behavior-tree-plugin/condition.gd"

func tick(tick):
	if tick.blackboard.get("target"):
		return OK
	#if tick.actor.target:
	#	return OK
	else:
		return FAILED
