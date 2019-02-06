extends MarginContainer

onready var health_label = $HBoxContainer/HealthUI/Background/HealthValue

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func update_health(newHealth):
	health_label.text = str(newHealth)


func _on_Player_health_changed(newHealth):
	update_health(newHealth)
