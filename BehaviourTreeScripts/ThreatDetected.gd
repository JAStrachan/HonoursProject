extends "res://addons/godot-behavior-tree-plugin/condition.gd"


func tick(tick):
	var target = tick.blackboard.get("target", tick.tree, tick.actor)
	
	if target:
		return OK
	else:
		return FAILED
