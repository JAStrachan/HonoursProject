extends "res://addons/godot-behavior-tree-plugin/condition.gd"

# Checks if the health of the npc is low from a variable set in the enemy's main code. It so it doesn't have to poll a calculation

func tick(tick):
	if tick.actor.healthLow:
		return OK
	else:
		return FAILED
