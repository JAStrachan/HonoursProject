extends "res://addons/godot-behavior-tree-plugin/action.gd"

func tick(tick):
	tick.actor.set_modulate(Color(0,1,0))
	return OK
