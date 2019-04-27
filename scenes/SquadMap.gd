extends "res://scenes/Map.gd"


func _ready():
	pass
	
# A method for the children of Map.gd to insert their own values
func _on_ready():
	MediumEnemy = preload("res://Enemies/Grunt.tscn")
	SmallEnemy = preload("res://Enemies/Rat.tscn")
	LargeEnemy = preload("res://Enemies/Commander.tscn")

