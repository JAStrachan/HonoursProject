extends "res://addons/godot-behavior-tree-plugin/action.gd"

func tick(tick):
	if tick.actor.target:
		tick.blackboard.set("target", tick.actor.target)
	
	return OK
