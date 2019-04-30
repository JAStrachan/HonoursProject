extends Area2D

export (int) var HEALTH_BOOST = 50

func _ready():
	add_to_group("HealthBoost")

# When a body has entered and has the method "heal" heal them. 
func _on_HealthBoost_body_entered(body):
	if body.has_method("heal"):
		body.heal(HEALTH_BOOST)
		queue_free()

# When spawned where to be positioned
func spawn(pos):
	position = pos