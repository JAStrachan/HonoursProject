extends "res://addons/godot-behavior-tree-plugin/action.gd"

func open(tick):
	pass
	
func tick(tick):
	return OK

func close(tick):
	queue_free()