extends "res://addons/godot-behavior-tree-plugin/action.gd"

# Behaviour for running away from player

func tick(tick):
	tick.actor.detection_area_colour = Color(0.5,0.5,0.5,0.1) # not red
	tick.actor.stop_movement()
	return OK