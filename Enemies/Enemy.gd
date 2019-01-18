extends KinematicBody2D

export (int) var health = 100
export (int) var bulletDamage = 50

signal enemy_death

func _ready():
	
	pass

func bullet_hit():
	pass
	
	
func hit():
	if health - bulletDamage <= 0:
		health = 0
		emit_signal('enemy_death')
		queue_free()
	else:
		health = health - bulletDamage
