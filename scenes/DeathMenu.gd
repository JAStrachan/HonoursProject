extends Control

onready var score_label = $MarginContainer/VBoxContainer/ScoreAndEnemyCount/Score/ScoreNumber
onready var noOfEnemies_label = $MarginContainer/VBoxContainer/ScoreAndEnemyCount/NoOfEnemies/NoOfEnemiesNumber

# Called when the node enters the scene tree for the first time.
func _ready():
	score_label.text = str(Global.score)
	noOfEnemies_label.text = str(Global.no_of_dead_enemies)


func _on_Button_pressed():
	Global.goto_scene("res://Map.tscn")
	Global.reset_enemy_count()
	Global.reset_score()
