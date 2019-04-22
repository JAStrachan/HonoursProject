extends "res://addons/godot-behavior-tree-plugin/bt_base.gd"

# Leaf Node
func tick(tick):
	tick.actor.velocity = Vector2(0,0)
	tick.actor.detection_area_colour = Color(.867, .91, .247, 0.1) # yellow
	return OK
