extends Area2D

export (int) var HEALTH_BOOST = 50

func _ready():
	pass


func _on_HealthBoost_body_entered(body):
	if body.has_method("heal"):
		body.heal(HEALTH_BOOST)
	queue_free()
