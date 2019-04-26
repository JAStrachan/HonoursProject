extends MarginContainer

onready var health_label = $HBoxContainer/HBoxContainer/HealthUI/Background/HealthValue

onready var score_label = $HBoxContainer/HBoxContainer2/ScoreUI/Background/ScoreValue

func _ready():
	Global.connect("score_changed",self, "_on_Score_changed")

func update_health(newHealth):
	health_label.text = str(newHealth)


func _on_Player_health_changed(newHealth):
	update_health(newHealth)


func _on_Score_changed(newScore):
	score_label.text = str(newScore)
