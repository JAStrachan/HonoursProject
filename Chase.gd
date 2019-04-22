extends "res://addons/godot-behavior-tree-plugin/action.gd"

func tick(tick):
	tick.actor.detection_area_colour = Color(1,0,0,0.1) # red
	tick.actor.moving_through_path()
	tick.actor.shoot()
			
