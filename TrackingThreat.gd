extends "res://addons/godot-behavior-tree-plugin/action.gd"

# Moves towards the threat without line of sight so no firing
func tick(tick):
	tick.actor.detection_area_colour = Color(0,1,0,0.1) # green
	tick.actor.moving_through_path()
