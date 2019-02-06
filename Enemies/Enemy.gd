extends KinematicBody2D

export (int) var health = 100
export (int) var bulletDamage = 50
var velocity = Vector2()

signal enemy_death

func _ready():
	
	pass

func bullet_hit():
	if health - bulletDamage <= 0:
		health = 0
		emit_signal('enemy_death')
		queue_free()
	else:
		health = health - bulletDamage
	
# Used for attacking the player through melee damage, currently in development as a figure out best practice	
func hit_player():
	pass
		
func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.normal)
		if collision.collider.has_method("enemy_touch"):
			collision.collider.enemy_touch()
