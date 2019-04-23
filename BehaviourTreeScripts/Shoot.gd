extends "res://addons/godot-behavior-tree-plugin/action.gd"

func tick(tick):
	var line_of_sight = tick.blackboard.get("line_of_sight", tick.tree, tick.actor)
	if line_of_sight:
		tick.actor.shoot()
	return OK