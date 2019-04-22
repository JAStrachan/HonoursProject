extends "res://addons/godot-behavior-tree-plugin/action.gd"

func tick(tick):
		tick.actor.velocity = Vector2(0,0)
		tick.actor.detection_area_colour = Color(0, 0.764, 0.819,0.1) # cyan-ish
		
		tick.actor.shoot()
