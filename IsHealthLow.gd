extends "res://addons/godot-behavior-tree-plugin/condition.gd"

func _ready():
	pass # Replace with function body.

func tick(tick):
	if tick.actor.healthLow:
		return OK
	else:
		return FAILED
