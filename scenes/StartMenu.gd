extends Control

# Code to control the start scene and the various scenes it will move to

func _ready():
	Global.reset()

func _on_IndiviualAI_pressed():
	Global._deferred_goto_scene("res://scenes/Map.tscn")


func _on_SquadAI_pressed():
	Global._deferred_goto_scene("res://scenes/SquadMap.tscn")


func _on_Quit_pressed():
	get_tree().quit()
