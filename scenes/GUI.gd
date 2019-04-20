extends MarginContainer

onready var health_label = $HBoxContainer/HBoxContainer/HealthUI/Background/HealthValue

onready var score_label = $HBoxContainer/HBoxContainer2/ScoreUI/Background/ScoreValue

func update_health(newHealth):
	health_label.text = str(newHealth)


func _on_Player_health_changed(newHealth):
	update_health(newHealth)


func _on_Player_score_changed(newScore):
	score_label.text = str(newScore)
