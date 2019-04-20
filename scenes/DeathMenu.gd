extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Button_pressed():
	Global.goto_scene("res://Map.tscn")
	Global.reset_enemy_count()
	Global.reset_score()
